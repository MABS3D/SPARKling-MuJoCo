with MJ.Smooth_Kernels;
package body MJ.Fixed_Tendons with SPARK_Mode is
   procedure Load (M : MJ.Models.Model; C : in out Description_Access;
                   Result : out Load_Status)
   is
      Plan : Mass_Plan (0 .. Max_Terms - 1);
      Used : Natural := 0;
      Coefs : Real_Array (0 .. 255) := [others => 0.0];
      Temp : Description_Access := null;
   begin
      Result := Invalid;
      if M.S.Ntendon = 0 then Result := Success; return; end if;
      if M.S.Ntendon > Max_Tendons or else M.S.Nwrap > Max_Terms
        or else M.S.Njten > Max_Terms or else M.S.Nv > 256
      then Result := Capacity; return; end if;
      --  The first runtime tranche is fixed tendons. Spatial wrapping needs
      --  site poses and a changing Jacobian, and is explicitly rejected here.
      for K in 0 .. M.S.Nwrap - 1 loop
         if M.Wraps.Wrap_Type (K) /= 1 then Result := Unsupported; return; end if;
      end loop;
      Temp := new Description (M.S.Ntendon, M.S.Nwrap, M.S.Njten, 0);
      for I in 0 .. M.S.Ntendon - 1 loop
         declare
            Adr : constant Integer := M.Tendons.Tendon_Adr (I);
            Num : constant Integer := M.Tendons.Tendon_Num (I);
            Ja : constant Integer := M.Tendons.Ten_J_Rowadr (I);
            Jn : constant Integer := M.Tendons.Ten_J_Rownnz (I);
         begin
            if Adr not in 0 .. M.S.Nwrap or else Num not in 0 .. M.S.Nwrap - Adr
              or else Ja not in 0 .. M.S.Njten or else Jn not in 0 .. M.S.Njten - Ja
              or else M.Tendons.Tendon_Lengthspring (2 * I) not in Tier0_Real
              or else M.Tendons.Tendon_Lengthspring (2 * I + 1) not in Tier0_Real
              or else M.Tendons.Tendon_Lengthspring (2 * I) > M.Tendons.Tendon_Lengthspring (2 * I + 1)
              or else M.Tendons.Tendon_Stiffness (I) not in Nonneg_Tier0
              or else M.Tendons.Tendon_Damping (I) not in Nonneg_Tier0
              or else M.Tendons.Tendon_Armature (I) not in Nonneg_Tier0
              or else M.Tendons.Tendon_Stiffnesspoly (2 * I) not in Tier0_Real
              or else M.Tendons.Tendon_Stiffnesspoly (2 * I + 1) not in Tier0_Real
              or else M.Tendons.Tendon_Dampingpoly (2 * I) not in Tier0_Real
              or else M.Tendons.Tendon_Dampingpoly (2 * I + 1) not in Tier0_Real
            then Free (Temp); return; end if;
            Temp.Tendons (I + 1) :=
              (Law => (Lower => M.Tendons.Tendon_Lengthspring (2 * I),
                       Upper => M.Tendons.Tendon_Lengthspring (2 * I + 1),
                       Stiffness => M.Tendons.Tendon_Stiffness (I),
                       Damping => M.Tendons.Tendon_Damping (I),
                       Armature => M.Tendons.Tendon_Armature (I),
                       Spring_Poly => [M.Tendons.Tendon_Stiffnesspoly (2 * I), M.Tendons.Tendon_Stiffnesspoly (2 * I + 1)],
                       Damper_Poly => [M.Tendons.Tendon_Dampingpoly (2 * I), M.Tendons.Tendon_Dampingpoly (2 * I + 1)]),
               Terms => (Adr + 1, Num), Jacobian => (Ja + 1, Jn));
            Coefs := [others => 0.0];
            for K in Adr .. Adr + Num - 1 loop
               declare
                  J : constant Integer := M.Wraps.Wrap_Objid (K);
               begin
                  if J not in 0 .. M.S.Njnt - 1 or else M.Wraps.Wrap_Prm (K) not in Tier0_Real then
                     Free (Temp); return;
                  end if;
                  declare
                     V : constant Integer := M.Joints.Jnt_Dofadr (J);
                  begin
                     if V not in 0 .. M.S.Nv - 1 or else M.Joints.Jnt_Qposadr (J) /= V
                       or else M.Joints.Jnt_Type (J) not in 2 .. 3
                     then Free (Temp); return; end if;
                     Temp.Terms (K + 1) := (V, M.Wraps.Wrap_Prm (K));
                     Coefs (V) := Coefs (V) + M.Wraps.Wrap_Prm (K);
                  end;
               end;
            end loop;
            for K in Ja .. Ja + Jn - 1 loop
               declare
                  V : constant Integer := M.Tendons.Ten_J_Colind (K);
               begin
                  if V not in 0 .. M.S.Nv - 1
                    or else (K > Ja and then V < M.Tendons.Ten_J_Colind (K - 1))
                    or else Coefs (V) not in Tier0_Real
                  then Free (Temp); return; end if;
                  Temp.Jacobian (K + 1) := (V, Coefs (V));
                  Coefs (V) := 0.0;
               end;
            end loop;
            if (for some X of Coefs => X /= 0.0) then Free (Temp); return; end if;
            --  mj_tendonArmature adds only at the existing M sparsity pattern.
            --  In particular C 3.14 does NOT insert cross-branch entries.
            --  Fixed Jacobians permit caching each product (not regrouping
            --  different tendons' sums); retain C's tendon/row order.
            if Temp.Tendons (I + 1).Law.Armature /= 0.0 then
               for K in Ja .. Ja + Jn - 1 loop
                  declare
                     V : constant Natural := Temp.Jacobian (K + 1).Dof;
                     A : constant Integer := M.Sparse.M_Rowadr (V);
                     N : constant Integer := M.Sparse.M_Rownnz (V);
                  begin
                     if A not in 0 .. M.S.Nc or else N not in 0 .. M.S.Nc - A then
                        Free (Temp); return;
                     end if;
                     if Temp.Jacobian (K + 1).Coefficient /= 0.0 then
                        for H in A .. A + N - 1 loop
                           for L in Ja .. Ja + Jn - 1 loop
                              if M.Sparse.M_Colind (H) = Temp.Jacobian (L + 1).Dof then
                                 declare
                                    W : constant Natural := Temp.Jacobian (L + 1).Dof;
                                    Delta_M : constant Real := TK.Mass_Entry
                                      (0.0, Temp.Tendons (I + 1).Law.Armature,
                                       Temp.Jacobian (K + 1).Coefficient, Temp.Jacobian (L + 1).Coefficient);
                                 begin
                                    if Used = Max_Terms then
                                       Free (Temp); Result := Capacity; return;
                                    end if;
                                    Plan (Used) := (V * M.S.Nv + W, W * M.S.Nv + V, Delta_M);
                                    Used := Used + 1;
                                 end;
                                 exit;
                              end if;
                           end loop;
                        end loop;
                     end if;
                  end;
               end loop;
            end if;
         end;
      end loop;
      C := new Description'(Nt => Temp.Nt, Nw => Temp.Nw, Nz => Temp.Nz, Nm => Used,
        Tendons => Temp.Tendons, Terms => Temp.Terms, Jacobian => Temp.Jacobian,
        Mass => Plan (0 .. Used - 1));
      Free (Temp);
      if not Ready (C, M.S.Nv) then Free (C); return; end if;
      Result := Success;
   end Load;

   procedure Kinematics (C : Description; I : Natural; Q, V : Real_Array;
                         Length, Velocity : out TK.Coordinate)
   is
      T : constant Tendon := C.Tendons (I);
   begin
      TK.Fixed_Kinematics
        (C.Terms (T.Terms.First .. T.Terms.First + T.Terms.Count - 1),
         C.Jacobian (T.Jacobian.First .. T.Jacobian.First + T.Jacobian.Count - 1),
         Q, V, Length, Velocity);
   end Kinematics;

   procedure Project_Pair
     (Spring, Damper : in out Real_Array; Index : Natural; J : Tier0_Real;
      Fs, Fd : TK.Tendon_Force; Ok : out Boolean)
   is
      S : constant Real := TK.Project (Spring (Index), J, Fs);
      D : constant Real := TK.Project (Damper (Index), J, Fd);
   begin
      Ok := S in TK.Mass_Value and then D in TK.Mass_Value;
      if Ok then
         Spring (Index) := S;
         Damper (Index) := D;
      end if;
   end Project_Pair;

   procedure Project_Small_Pair
     (Spring, Damper : in out Real_Array; Index : Natural; J : Tier0_Real;
      Fs, Fd : TK.Small_Force)
   is
   begin
      Spring (Index) := TK.Project_Small (Spring (Index), J, Fs);
      Damper (Index) := TK.Project_Small (Damper (Index), J, Fd);
   end Project_Small_Pair;

   procedure Add_Passive
     (C : Description; Q, V : Real_Array; Spring_Enabled, Damper_Enabled : Boolean;
      Spring, Damper : in out Real_Array; Ok : out Boolean)
   is
      Length, Velocity : TK.Coordinate;
      Fs, Fd : TK.Tendon_Force;
      First, Last : Integer;
   begin
      Ok := False;
      for I in C.Tendons'Range loop
         Kinematics (C, I, Q, V, Length, Velocity);
         TK.Spring_Damper (C.Tendons (I).Law, Length, Velocity,
                          Spring_Enabled, Damper_Enabled, Fs, Fd);
         if Fs /= 0.0 or else Fd /= 0.0 then
            First := C.Tendons (I).Jacobian.First;
            Last := First + C.Tendons (I).Jacobian.Count - 1;
            if Fs in TK.Small_Force and then Fd in TK.Small_Force then
               --  This gate is per tendon. The scalar kernel proves that
               --  every rounded update stays bounded, including at the
               --  work interval endpoints, without a per-DOF runtime guard.
               for K in First .. Last loop
                  Project_Small_Pair (Spring, Damper, C.Jacobian (K).Dof,
                    C.Jacobian (K).Coefficient, Fs, Fd);
                  pragma Loop_Invariant (for all X of Spring => X in TK.Mass_Value);
                  pragma Loop_Invariant (for all X of Damper => X in TK.Mass_Value);
               end loop;
            else
               for K in First .. Last loop
                  Project_Pair (Spring, Damper, C.Jacobian (K).Dof,
                    C.Jacobian (K).Coefficient, Fs, Fd, Ok);
                  if not Ok then return; end if;
                  pragma Loop_Invariant (for all X of Spring => X in -1.0e60 .. 1.0e60);
                  pragma Loop_Invariant (for all X of Damper => X in -1.0e60 .. 1.0e60);
               end loop;
            end if;
         end if;
         pragma Loop_Invariant (for all X of Spring => X in -1.0e60 .. 1.0e60);
         pragma Loop_Invariant (for all X of Damper => X in -1.0e60 .. 1.0e60);
      end loop;
      Ok := True;
   end Add_Passive;

   procedure Unfold_Mass (C : Description; Initial : Real_Array; Nv, Count : Natural) is
   begin
      null;
   end Unfold_Mass;

   procedure Store_Mass_Pair (Mass : in out Real_Array; Nv, Target, Mirror : Natural;
                              Change : TK.Mass_Change) is
      X : constant TK.Mass_Value := TK.Accumulate_Mass (Mass (Target), Change);
      Original : constant Real_Array := Mass with Ghost => Static;
   begin
      pragma Assert (Static => Target = (Target / Nv) * Nv + (Target mod Nv));
      pragma Assert (Static => Mass (MJ.Smooth_Kernels.Matrix_Offset (Nv, Target / Nv, Target mod Nv)) =
        Mass (MJ.Smooth_Kernels.Matrix_Offset (Nv, Target mod Nv, Target / Nv)));
      pragma Assert (Static => Mass (Target) = Mass (Mirror));
      Mass (Target) := X;
      Mass (Mirror) := X;
      MJ.Smooth_Dynamics.Prove_Symmetry_After_Update
        (Mass, Original, Nv, Target / Nv, Target mod Nv, X);
   end Store_Mass_Pair;

   procedure Add_Mass (C : Description; Nv : Natural;
                       Mass : in out Real_Array; Ok : out Boolean)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Model);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      Initial : constant Real_Array := Mass with Ghost => Static;
   begin
      for K in C.Mass'Range loop
         Unfold_Mass (C, Initial, Nv, K);
         Store_Mass_Pair (Mass, Nv, C.Mass (K).Index, C.Mass (K).Mirror, C.Mass (K).Value);
         pragma Loop_Invariant (for all X of Mass => X in TK.Mass_Value);
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Symmetric (Mass, Nv));
         pragma Loop_Invariant (Static => (for all I in Mass'Range =>
           Mass (I) = Mass_Model (C, Initial, Nv, I, K)));
      end loop;
      Ok := True;
   end Add_Mass;
end MJ.Fixed_Tendons;

with Ada.Unchecked_Deallocation;
with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Tendon_Geometry;
with MJ.Smooth_Math;
with MJ.Smooth_Kernels;

package body MJ.Spatial_Tendon_Models with SPARK_Mode is
   procedure Release is new Ada.Unchecked_Deallocation (Description, Description_Access);
   procedure Free (T : in out Description_Access) is
   begin
      Release (T);
   end Free;

   --  Keep the 487-array model validator outside the copying proof. The
   --  worker needs only these four groups, established by Valid_Layout.
   procedure Load_Valid (M : MJ.Models.Model; T : in out Description_Access;
                         Accepted : out Boolean) with
     Global => null,
     Pre => T = null and then M.S.Nv <= 256 and then M.S.Nq <= Max_Objects
       and then M.S.Nbody in 1 .. Max_Objects
       and then M.S.Ntendon in 1 .. Max_Objects
       and then M.S.Nsite in 0 .. Max_Objects
       and then M.S.Ngeom in 0 .. Max_Objects
       and then M.S.Nwrap in 0 .. Max_Objects
       and then MJ.Models.Site_Layout_OK (M.S, M.Sites)
       and then MJ.Models.Geom_Layout_OK (M.S, M.Geoms)
       and then MJ.Models.Tendon_Layout_OK (M.S, M.Tendons)
       and then MJ.Models.Wrap_Layout_OK (M.S, M.Wraps)
       and then MJ.Models.Joint_Layout_OK (M.S, M.Joints)
       and then MJ.Models.Sparse_Layout_OK (M.S, M.Sparse),
     Post => (if Accepted then Ready (T, M.S.Nbody) and then Count (T) = M.S.Ntendon
              else T = null);

   procedure Load_Valid (M : MJ.Models.Model; T : in out Description_Access;
                         Accepted : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ready);
      Q : MJ.Smooth_Math.Quaternion;
      R : MJ.Smooth_Math.Matrix;
      OK : Boolean;
      Obj : Integer;
      Plan : Mass_Plan (1 .. TK.Max_Terms);
      Used : Natural := 0;
      Coefs : Real_Array (0 .. M.S.Nv - 1) := [others => 0.0];
   begin
      Accepted := False;
      T := new Description (M.S.Ntendon, M.S.Nsite, M.S.Ngeom, M.S.Nwrap, 0);
      T.Nb := M.S.Nbody; T.Nq := M.S.Nq; T.Nv := M.S.Nv;
      for I in 0 .. T.Ns - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         if M.Sites.Site_Bodyid (I) not in 0 .. M.S.Nbody - 1 then Free (T); return; end if;
         T.Sites (I + 1) := (Position => (M.Sites.Site_Pos (3 * I),
           M.Sites.Site_Pos (3 * I + 1), M.Sites.Site_Pos (3 * I + 2)),
           Body_Id => M.Sites.Site_Bodyid (I));
      end loop;
      for I in 0 .. T.Ng - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         if M.Geoms.Geom_Bodyid (I) not in 0 .. M.S.Nbody - 1 then Free (T); return; end if;
         --  Non-wrapping geometries are retained only for stable object ids.
         T.Geometries (I + 1).Body_Id := M.Geoms.Geom_Bodyid (I);
         if M.Geoms.Geom_Type (I) in 2 | 5 then
            for K in Q'Range loop Q (K) := M.Geoms.Geom_Quat (4 * I + K); end loop;
            MJ.Smooth_Math.Normalize (Q, OK);
            if not OK then Free (T); return; end if;
            R := MJ.Smooth_Math.Rotation (Q);
            for A in 1 .. 3 loop
               T.Geometries (I + 1).Position (A) := M.Geoms.Geom_Pos (3 * I + A - 1);
               for B in 1 .. 3 loop T.Geometries (I + 1).Orientation (A, B) := R (A - 1, B - 1); end loop;
            end loop;
            T.Geometries (I + 1).Kind := (if M.Geoms.Geom_Type (I) = 2
              then MJ.Tendon_Geometry.Sphere else MJ.Tendon_Geometry.Cylinder);
            T.Geometries (I + 1).Radius := M.Geoms.Geom_Size (3 * I);
         end if;
      end loop;
      for I in 0 .. T.Nw - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         Obj := M.Wraps.Wrap_Objid (I);
         case M.Wraps.Wrap_Type (I) is
            when 1 =>
               if Obj not in 0 .. M.S.Njnt - 1
                 or else M.Joints.Jnt_Type (Obj) not in 2 .. 3
                 or else M.Joints.Jnt_Qposadr (Obj) not in 0 .. M.S.Nq - 1
                 or else M.Joints.Jnt_Dofadr (Obj) not in 0 .. M.S.Nv - 1
                 or else M.Wraps.Wrap_Prm (I) not in Tier0_Real
               then Free (T); return; end if;
               T.Terms (I + 1) := (M.Joints.Jnt_Qposadr (Obj), M.Wraps.Wrap_Prm (I));
            when 2 => T.Nodes (I + 1) := (Kind => Pulley_Node, Divisor => M.Wraps.Wrap_Prm (I), others => <>);
            when 3 =>
               if Obj not in 0 .. T.Ns - 1 then Free (T); return; end if;
               T.Nodes (I + 1) := (Kind => Site_Node, Object_Id => Obj, others => <>);
            when 4 | 5 =>
               if Obj not in 0 .. T.Ng - 1
                 or else M.Geoms.Geom_Type (Obj) /= (if M.Wraps.Wrap_Type (I) = 4 then 2 else 5)
                 or else M.Wraps.Wrap_Prm (I) < -1.0
                 or else M.Wraps.Wrap_Prm (I) > Real (Max_Objects)
               then Free (T); return; end if;
               if Real (Integer (M.Wraps.Wrap_Prm (I))) /= M.Wraps.Wrap_Prm (I) then Free (T); return; end if;
               T.Nodes (I + 1) := (Kind => Geometry_Node, Object_Id => Obj,
                 Side_Id => Integer (M.Wraps.Wrap_Prm (I)), others => <>);
            when others => Free (T); return;
         end case;
      end loop;
      for I in 0 .. T.Nt - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         if M.Tendons.Tendon_Num (I) not in 1 .. T.Nw
           or else M.Tendons.Tendon_Adr (I) not in 0 .. T.Nw - M.Tendons.Tendon_Num (I)
         then Free (T); return; end if;
         if M.Tendons.Tendon_Armature (I) not in Nonneg_Tier0 then Free (T); return; end if;
         T.Tendons (I + 1) := (
           Fixed => M.Wraps.Wrap_Type (M.Tendons.Tendon_Adr (I)) = 1,
           Jacobian_Count => 0, Armature => M.Tendons.Tendon_Armature (I), First => M.Tendons.Tendon_Adr (I), Count => M.Tendons.Tendon_Num (I),
           Lower => M.Tendons.Tendon_Lengthspring (2 * I), Upper => M.Tendons.Tendon_Lengthspring (2 * I + 1),
           Stiffness => M.Tendons.Tendon_Stiffness (I), Damping => M.Tendons.Tendon_Damping (I),
           Spring_Linear => M.Tendons.Tendon_Stiffnesspoly (2 * I),
           Spring_Quadratic => M.Tendons.Tendon_Stiffnesspoly (2 * I + 1),
           Damper_Linear => M.Tendons.Tendon_Dampingpoly (2 * I),
           Damper_Quadratic => M.Tendons.Tendon_Dampingpoly (2 * I + 1));
         declare
            P : constant Parameters := T.Tendons (I + 1);
            Ns : constant Natural := T.Ns;
            Ng : constant Natural := T.Ng;
            Sites : constant Site_Array (0 .. Ns - 1) := T.Sites;
            Geometries : constant Geometry_Array (0 .. Ng - 1) := T.Geometries;
            Route : constant Route_Array (0 .. P.Count - 1) := T.Nodes (P.First + 1 .. P.First + P.Count);
         begin
            if P.Fixed then
               declare
                  Ja : constant Integer := M.Tendons.Ten_J_Rowadr (I);
                  Jn : constant Integer := M.Tendons.Ten_J_Rownnz (I);
               begin
                  if Ja not in 0 .. M.S.Njten or else Jn not in 0 .. M.S.Njten - Ja
                    or else Jn > P.Count then Free (T); return; end if;
                  Coefs := [others => 0.0];
                  for K in P.First .. P.First + P.Count - 1 loop
                     if M.Wraps.Wrap_Type (K) /= 1 then Free (T); return; end if;
                     Obj := M.Joints.Jnt_Dofadr (M.Wraps.Wrap_Objid (K));
                     Coefs (Obj) := Coefs (Obj) + M.Wraps.Wrap_Prm (K);
                  end loop;
                  T.Tendons (I + 1).Jacobian_Count := Jn;
                  for K in 0 .. Jn - 1 loop
                     Obj := M.Tendons.Ten_J_Colind (Ja + K);
                     if Obj not in 0 .. T.Nv - 1 or else Coefs (Obj) not in Tier0_Real
                       or else (K > 0 and then Obj < M.Tendons.Ten_J_Colind (Ja + K - 1))
                     then Free (T); return; end if;
                     T.Jacobian (P.First + K + 1) := (Obj, Coefs (Obj));
                     Coefs (Obj) := 0.0;
                  end loop;
                  if (for some X of Coefs => X /= 0.0) then Free (T); return; end if;
                  --  Preserve C's tendon/row/column order and reduced M pattern.
                  --  Duplicate joint columns carry zero after their first slot.
                  if P.Armature /= 0.0 then
                     for K in P.First + 1 .. P.First + Jn loop
                        declare
                           V : constant Natural := T.Jacobian (K).Dof;
                           A : constant Integer := M.Sparse.M_Rowadr (V);
                           N : constant Integer := M.Sparse.M_Rownnz (V);
                        begin
                           if A not in 0 .. M.S.Nc or else N not in 0 .. M.S.Nc - A then Free (T); return; end if;
                           if T.Jacobian (K).Coefficient /= 0.0 then
                              for H in A .. A + N - 1 loop
                                 for L in P.First + 1 .. P.First + Jn loop
                                    if M.Sparse.M_Colind (H) = T.Jacobian (L).Dof then
                                       if Used = TK.Max_Terms then Free (T); return; end if;
                                       Used := Used + 1;
                                       declare
                                          W : constant Natural := T.Jacobian (L).Dof;
                                       begin
                                          Plan (Used) := (V * T.Nv + W, W * T.Nv + V,
                                            TK.Mass_Entry (0.0, P.Armature, T.Jacobian (K).Coefficient, T.Jacobian (L).Coefficient));
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
            else
               --  A spatial armature also needs velocity-dependent inertial bias.
               if P.Armature /= 0.0 or else not Valid_Path (Route, Sites, Geometries) then Free (T); return; end if;
               for K in P.First .. P.First + P.Count - 1 loop
                  if M.Wraps.Wrap_Type (K) = 1 then Free (T); return; end if;
               end loop;
               T.Has_Spatial := True;
            end if;
         end;
      end loop;
      if Used > 0 then
         declare
            Previous : constant Description := T.all;
         begin
            Free (T);
            T := new Description'
              (Nt => Previous.Nt, Ns => Previous.Ns, Ng => Previous.Ng, Nw => Previous.Nw, Nm => Used,
               Nb => Previous.Nb, Nq => Previous.Nq, Nv => Previous.Nv, Has_Spatial => Previous.Has_Spatial,
               Terms => Previous.Terms, Jacobian => Previous.Jacobian, Mass => Plan (1 .. Used),
               Tendons => Previous.Tendons, Sites => Previous.Sites,
               Geometries => Previous.Geometries, Nodes => Previous.Nodes);
         end;
      end if;
      if not Ready (T, M.S.Nbody) then Free (T); return; end if;
      Accepted := True;
   end Load_Valid;

   procedure Load (M : MJ.Models.Model; T : in out Description_Access;
                   Accepted : out Boolean) is
   begin
      Accepted := False;
      if not MJ.Models.Valid_Layout (M) then return; end if;
      if M.S.Ntendon = 0 then Accepted := True; return; end if;
      --  Routing consumes world poses and velocity-space Jacobian columns.
      --  Quaternion coordinates therefore need not have the same size as nv.
      if M.S.Nv > 256 or else M.S.Nq > Max_Objects or else M.S.Nbody not in 1 .. Max_Objects
        or else M.S.Ntendon not in 1 .. Max_Objects
        or else M.S.Nsite not in 0 .. Max_Objects
        or else M.S.Ngeom not in 0 .. Max_Objects
        or else M.S.Nwrap not in 0 .. Max_Objects then return; end if;
      Load_Valid (M, T, Accepted);
   end Load;

   procedure Spring_Damper (P : Parameters; Length, Velocity : Real;
                            Spring_Enabled, Damper_Enabled : Boolean;
                            Spring, Damper : out Real) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Polynomial);
      X : Displacement_Real;
   begin
      Spring := 0.0; Damper := 0.0;
      if Spring_Enabled then
         X := Displacement (Length, P.Lower, P.Upper);
         Spring := -X * Polynomial (P.Stiffness, P.Spring_Linear, P.Spring_Quadratic, X, False);
      end if;
      if Damper_Enabled then
         Damper := -Velocity * Polynomial (P.Damping, P.Damper_Linear, P.Damper_Quadratic, Velocity, True);
      end if;
   end Spring_Damper;
   procedure Unfold_Mass (C : Description; Initial : Real_Array; Nv, Count : Natural) is
   begin
      null;
   end Unfold_Mass;

   procedure Store_Mass_Pair (Mass : in out Real_Array; Nv, Target, Mirror : Natural;
                              Change : TK.Mass_Change) is
      X : constant TK.Mass_Value := TK.Accumulate_Mass (Mass (Target), Change);
   begin
      pragma Assert (Static => Target = (Target / Nv) * Nv + (Target mod Nv));
      pragma Assert (Static => Mass (MJ.Smooth_Kernels.Matrix_Offset (Nv, Target / Nv, Target mod Nv)) =
        Mass (MJ.Smooth_Kernels.Matrix_Offset (Nv, Target mod Nv, Target / Nv)));
      pragma Assert (Static => Mass (Target) = Mass (Mirror));
      MJ.Smooth_Dynamics.Store_Symmetric (Mass, Nv, Target / Nv, Target mod Nv, X);
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
end MJ.Spatial_Tendon_Models;

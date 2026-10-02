with Interfaces;
with MJ.Models.Validity;
with MJ.Data.Forward;
with MJ.Data.Pipeline;
with MJ.Data.Inertia_Phase;
with MJ.Contact_Geometry;
with MJ.Contact_Parameters;
with MJ.Heightfield_Contacts;
with MJ.Joint_Limits;
with MJ.Joint_Limit_Math;
with MJ.Constrained_Kernels;

package body MJ.Data.Constrained with SPARK_Mode is
   package Scene renames MJ.Collision_Scene;
   package CG renames MJ.Contact_Geometry;
   package CP renames MJ.Contact_Parameters;
   package JL renames MJ.Joint_Limits;
   package CK renames MJ.Constrained_Kernels;
   use type RG.Status, CA.Result, CA.Constraint_Kind, CS.Status, JL.Status;
   use type Interfaces.Unsigned_32, Interfaces.Unsigned_8;

   function Disabled (Flags, Flag : Integer) return Boolean is
     (Flags >= 0 and then (Flags / Flag) mod 2 = 1);
   function Ready (E : Engine) return Boolean is (E.Initialized and then Is_Ready (E.D));
   function State (E : Engine) return Real_Array is (State_Values (E.D));
   function Diagnostics (E : Engine) return Trace is (E.T);

   function Parameters (Ref, Imp : Real_Array; Id : Natural) return LR.Parameters is
   begin
      if Imp (5 * Id + 4) > 1.0 and then Imp (5 * Id + 4) /= 2.0 then
         raise Constraint_Error with "solimp power is not supported";
      end if;
      return (Ref (2 * Id), Ref (2 * Id + 1), Imp (5 * Id), Imp (5 * Id + 1),
        Imp (5 * Id + 2), Imp (5 * Id + 3),
        (if Imp (5 * Id + 4) <= 1.0 then LR.Linear else LR.Quadratic));
   end Parameters;

   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
      Original_Flags : constant Integer := M.Opt.Disableflags;
      Shapes : Scene.Geometry_Array (0 .. Max_G - 1);
      Empty_Pairs : Scene.Declared_Array (1 .. 0);
      Empty_Exclusions : RG.Exclusion_Array (1 .. 0);
      S : RG.Status;
   begin
      if not Is_Empty (E.D) then Result := Already_Allocated; return; end if;
      Result := Invalid_Model;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      Result := Unsupported_Feature;
      --  Explicit first integrated domain; never discard an enabled feature.
      if M.S.Nv not in 1 .. Max_V or else M.S.Ngeom > Max_G
        or else M.S.Njnt > Max_V or else M.S.Nbody > Max_Bodies then Result := Capacity_Exceeded; return; end if;
      if M.S.Na /= 0 or else M.S.Nflex /= 0 or else M.S.Nmocap /= 0
        or else M.S.Nplugin /= 0 or else M.S.Nhistory /= 0 or else M.S.Neq /= 0 or else M.S.Ntendon /= 0 or else M.S.Npair /= 0
        or else M.S.Nexclude /= 0 or else M.Flg_Surfacevel or else M.Flg_Adhesion
        or else M.Opt.Integrator /= 0 or else M.Opt.Density /= 0.0 or else M.Opt.Viscosity /= 0.0
        or else M.Opt.Cone /= 0 or else M.Opt.Noslip_Iterations /= 0
        or else M.Opt.Enableflags /= 0
        or else not Disabled (M.Opt.Disableflags, Dsbl_Warmstart)
        or else not Disabled (M.Opt.Disableflags, Dsbl_Island)
        or else M.Opt.Solver not in 0 .. 2
        or else M.Opt.Iterations not in 0 .. 100_000
        or else M.Opt.Ls_Iterations not in 1 .. 1_000
        or else M.Opt.Impratio not in 1.0e-10 .. 1.0e10
        or else M.Stat.Meaninertia <= 0.0
        or else (M.S.Nsensor > 0 and then not Disabled (M.Opt.Disableflags, Dsbl_Sensor))
      then return; end if;
      E.Flags := M.Opt.Disableflags;
      E.Impratio := M.Opt.Impratio;
      E.Settings := (Algorithm => CS.Method'Val (M.Opt.Solver),
        Iterations => M.Opt.Iterations, LS_Iterations => M.Opt.Ls_Iterations,
        Tolerance => M.Opt.Tolerance, LS_Tolerance => M.Opt.Ls_Tolerance,
        Scale => 1.0 / (M.Stat.Meaninertia * Real (M.S.Nv)));
      E.Ng := M.S.Ngeom; E.Nj := M.S.Njnt;
      for B in 0 .. M.S.Nbody - 1 loop
         E.Bodies (B) := (Leaf => (if M.Bodies.Body_Dofnum (B) > 0
           then M.Bodies.Body_Dofadr (B) + M.Bodies.Body_Dofnum (B) - 1
           elsif B = 0 then -1 else E.Bodies (M.Bodies.Body_Parentid (B)).Leaf),
           Translation => M.Bodies.Body_Invweight0 (2 * B),
           Rotation => M.Bodies.Body_Invweight0 (2 * B + 1));
      end loop;
      for I in 0 .. M.S.Nv - 1 loop
         E.Dofs (I) := (M.Dofs.Dof_Parentid (I), M.Dofs.Dof_Frictionloss (I),
           M.Dofs.Dof_Invweight0 (I), Parameters (M.Dofs.Dof_Solref.all, M.Dofs.Dof_Solimp.all, I));
      end loop;
      for I in 0 .. E.Nj - 1 loop
         E.Joints (I) := (Kind => Joint_Kind'Val (M.Joints.Jnt_Type (I)),
           Qadr => M.Joints.Jnt_Qposadr (I), Vadr => M.Joints.Jnt_Dofadr (I),
           Is_Limited => M.Joints.Jnt_Limited (I) /= 0,
           Low => M.Joints.Jnt_Range (2 * I), High => M.Joints.Jnt_Range (2 * I + 1),
           Margin => M.Joints.Jnt_Margin (I),
           Params => Parameters (M.Joints.Jnt_Solref.all, M.Joints.Jnt_Solimp.all, I));
      end loop;
      for G in 0 .. E.Ng - 1 loop
         declare
            B : constant Natural := M.Geoms.Geom_Bodyid (G);
            W : constant Natural := M.Bodies.Body_Weldid (B);
            K : constant Integer := M.Geoms.Geom_Type (G);
            Q : constant Quaternion := Read_Quaternion (M.Geoms.Geom_Quat.all, 4 * G);
         begin
            if K not in 0 | 2 .. 6 then return; end if;
            E.Geoms (G) := (B, Read_Vector (M.Geoms.Geom_Pos.all, 3 * G), Rotation (Q));
            Shapes (G).Solid.Rigid :=
              (Kind => RG.Shape_Kind'Val ((if K = 0 then 0 else K - 1)),
               Size => RG.Vec (Read_Vector (M.Geoms.Geom_Size.all, 3 * G)),
               Body_Id => B, Weld => W,
               Weld_Parent => M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (W)),
               Dynamic => W /= 0,
               Contype => Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Contype (G)),
               Conaffinity => Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Conaffinity (G)),
               Margin => M.Geoms.Geom_Margin (G), Gap => M.Geoms.Geom_Gap (G));
            Shapes (G).Surface := (Priority => M.Geoms.Geom_Priority (G),
              Dim => M.Geoms.Geom_Condim (G), Mix => M.Geoms.Geom_Solmix (G),
              Ref => [for I in 0 .. 1 => M.Geoms.Geom_Solref (2 * G + I)],
              Imp => [for I in 0 .. 4 => M.Geoms.Geom_Solimp (5 * G + I)],
              Fri => [for I in 0 .. 2 => M.Geoms.Geom_Friction (3 * G + I)],
              Adhesion => 0.0);
            if not CP.Valid (Shapes (G).Surface) then return; end if;
            declare
               P : constant LR.Parameters := Parameters (M.Geoms.Geom_Solref.all, M.Geoms.Geom_Solimp.all, G);
            begin null; end;
         end;
      end loop;
      Scene.Initialize (E.Scene, Shapes (0 .. E.Ng - 1), CG.Empty_Vertices,
        MJ.Heightfield_Contacts.Elevation_Array'(1 .. 0 => 0.0), CG.Empty_Graph,
        Empty_Pairs, Empty_Exclusions,
        (Filter_Parent => not Disabled (E.Flags, Dsbl_Filterparent),
         Enabled => not Disabled (E.Flags, Dsbl_Contact) and then not Disabled (E.Flags, Dsbl_Constraint),
         Sleep_Filter => False, Tolerance => M.Opt.Ccd_Tolerance,
         Iterations => M.Opt.Ccd_Iterations), (others => <>), S);
      if S /= RG.Success then Result := Invalid_Model; return; end if;
      --  Exclusive in-out borrow during initialization. The smooth subengine
      --  handles free dynamics; this wrapper owns all admitted constraints.
      --  Restore the caller's flags on every exit, without aliasing model
      --  ownership through a shallow copy of its access-valued fields.
      if not Disabled (M.Opt.Disableflags, Dsbl_Constraint) then
         M.Opt.Disableflags := M.Opt.Disableflags + Dsbl_Constraint;
      end if;
      MJ.Data.Create (M, E.D, Result);
      M.Opt.Disableflags := Original_Flags;
      E.Initialized := Result = Success;
      E.T.Valid := False;
   exception
      when Constraint_Error =>
         M.Opt.Disableflags := Original_Flags;
         MJ.Data.Free (E.D); E.Initialized := False; Result := Unsupported_Feature;
      when others => M.Opt.Disableflags := Original_Flags; raise;
   end Create;

   procedure Free (E : in out Engine; Result : out Status) is
   begin
      MJ.Data.Free (E.D); E.Initialized := False; E.T.Valid := False; Result := Success;
   end Free;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Status) is
   begin
      MJ.Data.Set_State (E.D, Qpos, Qvel, New_Time, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_State;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      MJ.Data.Set_Control (E.D, Index, Value, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_Control;
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      MJ.Data.Set_Applied_Force (E.D, Index, Value, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_Applied_Force;

   procedure Generate_Contacts (E : in out Engine; Result : out Status) is
      Ng : constant Natural := E.Ng;
      Poses : RG.Pose_Array (0 .. Ng - 1);
      S : RG.Status;
   begin
      for G in Poses'Range loop
         declare
            B : constant Body_State := E.D.Kinematic.Bodies (E.Geoms (G).Body_Id);
         begin
            Poses (G).Position := RG.Vec (B.Position + Apply (B.Rotation, E.Geoms (G).Position));
            for I in 0 .. 2 loop
               for J in 0 .. 2 loop
                  Poses (G).Rotation (3 * I + J) :=
                    (B.Rotation (I, 0) * E.Geoms (G).Rotation (0, J)
                     + B.Rotation (I, 1) * E.Geoms (G).Rotation (1, J))
                     + B.Rotation (I, 2) * E.Geoms (G).Rotation (2, J);
               end loop;
            end loop;
         end;
      end loop;
      Scene.Generate (E.Scene, Poses, CG.Empty_Vertices, CG.Empty_Facets,
        MJ.Heightfield_Contacts.Elevation_Array'(1 .. 0 => 0.0), CG.Empty_Graph,
        E.Contacts, E.T.Ncontact, S);
      Result := (case S is when RG.Success => Success,
        when RG.Capacity_Limit => Capacity_Exceeded, when others => Numeric_Limit);
   end Generate_Contacts;

   procedure Assemble (E : in out Engine; Result : out Status) is
      S : CA.Result;
   begin
      CA.Reset (E.Rows, E.D.Nv);
      Result := Success;
      if Disabled (E.Flags, Dsbl_Constraint) then return; end if;
      if not Disabled (E.Flags, Dsbl_Frictionloss) then
         for V in 0 .. E.D.Nv - 1 loop
            CA.Add_Dof_Friction (E.Rows, V, E.Dofs (V).Loss, S);
            if S = CA.Capacity_Limit then Result := Capacity_Exceeded; return; end if;
         end loop;
      end if;
      if not Disabled (E.Flags, Dsbl_Limit) then
         for I in 0 .. E.Nj - 1 loop
            declare
               P : constant Joint_Description := E.Joints (I);
               Q : constant JL.Quaternion := (if P.Kind = Ball then
                 JL.Quaternion (Read_Quaternion (E.D.State.Qpos.all, P.Qadr)) else [1.0, 0.0, 0.0, 0.0]);
               B : constant JL.Batch := JL.Build (P.Kind, I, P.Vadr, E.D.State.Qpos (P.Qadr),
                 Q, P.Low, P.High, P.Margin, P.Is_Limited);
            begin
               if B.Result /= JL.Success then Result := Numeric_Limit; return; end if;
               for R in 1 .. B.Count loop
                  declare
                     C : CA.Column_Array (1 .. B.Rows (R).Width);
                     J : CA.Matrix (1 .. 1, C'Range);
                  begin
                     for K in C'Range loop
                        C (K) := P.Vadr + K - 1; J (1, K) := B.Rows (R).Jacobian (K - 1);
                     end loop;
                     CA.Append (E.Rows, CA.Limit_Joint, I, C, J,
                       [1 => (B.Rows (R).Position, P.Margin)], 0.0, S);
                     if S /= CA.Success then Result := Capacity_Exceeded; return; end if;
                  end;
               end loop;
            end;
         end loop;
      end if;
      for Id in 0 .. E.T.Ncontact - 1 loop
         declare
            C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Id);
            B1 : constant Natural := E.Geoms (C.Geoms.First).Body_Id;
            B2 : constant Natural := E.Geoms (C.Geoms.Second).Body_Id;
            A : Integer := E.Bodies (B1).Leaf;
            B : Integer := E.Bodies (B2).Leaf;
            Chain, Reverse_Chain : CA.Column_Array (1 .. Max_V);
            N : Natural := 0;
            Dim : constant CP.Dimension := C.Dim;
            J : CA.Matrix (1 .. Dim, 1 .. Max_V);
         begin
            if not C.Excluded then
               --  Merge both parent chains until their common ancestor: no
               --  structural zeros from shared ancestors enter the rows.
               while A /= B loop
                  N := N + 1;
                  if A > B then Reverse_Chain (N) := A; A := E.Dofs (A).Parent;
                  else Reverse_Chain (N) := B; B := E.Dofs (B).Parent; end if;
               end loop;
               for K in 1 .. N loop
                  Chain (K) := Reverse_Chain (N - K + 1);
                  declare
                     V : constant Natural := Chain (K);
                     O1 : constant Natural := Jacobian_Offset (E.D, B1, V);
                     O2 : constant Natural := Jacobian_Offset (E.D, B2, V);
                     W1 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O1);
                     W2 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O2);
                     R1 : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (B1).Center;
                     R2 : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (B2).Center;
                     L1 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O1);
                     L2 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O2);
                     Linear, Angular : Vector;
                  begin
                     for X in 0 .. 2 loop
                        Linear (X) := CK.Point_Component (L2 (X), W2 ((X+1) mod 3), W2 ((X+2) mod 3),
                          R2 ((X+1) mod 3), R2 ((X+2) mod 3))
                          - CK.Point_Component (L1 (X), W1 ((X+1) mod 3), W1 ((X+2) mod 3),
                          R1 ((X+1) mod 3), R1 ((X+2) mod 3));
                        Angular (X) := W2 (X) - W1 (X);
                     end loop;
                     for R in 1 .. C.Dim loop
                        declare
                           X : constant Natural := (R - 1) mod 3;
                           Z : constant Vector := (if R <= 3 then Linear else Angular);
                        begin
                           J (R, K) := CK.Frame_Component (Z (0), Z (1), Z (2),
                             C.Frame (3 * X), C.Frame (3 * X + 1), C.Frame (3 * X + 2));
                        end;
                     end loop;
                  end;
               end loop;
               declare
                  Width : constant Natural := N;
                  Compact : CA.Matrix (1 .. Dim, 1 .. Width);
               begin
                  for R in 1 .. C.Dim loop
                     for K in 1 .. N loop Compact (R, K) := J (R, K); end loop;
                  end loop;
                  C.Efc_Address := (if N = 0 then -1 else E.Rows.Rows);
                  CA.Add_Contact (E.Rows, Id, C.Dim, CA.Pyramidal, Chain (1 .. N), Compact,
                    [for K in 1 .. 5 => C.Param.Fri (K - 1)], C.Distance, C.Param.Include_Margin, S);
                  if S = CA.Capacity_Limit then Result := Capacity_Exceeded; return; end if;
               end;
            end if;
         end;
      end loop;
   end Assemble;

   procedure Prepare_And_Solve (E : in out Engine; Result : out Status) is
      Nv : constant Natural := E.D.Nv;
      Nr : constant Natural := E.Rows.Rows;
      Mass : CS.Matrix (1 .. Nv, 1 .. Nv);
      J : CS.Matrix (1 .. Nr, 1 .. Nv) := [others => [others => 0.0]];
      A, A_Free : CS.Vector (1 .. Nv);
      Aref, Force : CS.Vector (1 .. Nr) := [others => 0.0];
   begin
      Result := Numeric_Limit;
      E.T.Nv := Nv; E.T.Nrow := Nr;
      for V in 1 .. Nv loop
         A_Free (V) := E.D.Dynamics.Acceleration (V - 1);
         A (V) := A_Free (V); E.T.A_Free (V) := A_Free (V);
         for W in 1 .. Nv loop Mass (V, W) := E.D.Dynamics.Mass ((V - 1) * Nv + W - 1); end loop;
         E.T.Constraint_Force (V) := 0.0;
      end loop;
      for R in 1 .. Nr loop
         declare
            Row : CA.Row renames E.Rows.Descriptors (R);
            P : LR.Parameters;
            Diag : Real;
            Friction : constant Boolean := Row.Kind = CA.Friction_Dof;
            Velocity : Real := 0.0;
         begin
            for K in Row.Offset + 1 .. Row.Offset + Row.Nonzeros loop
               J (R, E.Rows.Columns (K) + 1) := E.Rows.Values (K);
               Velocity := Velocity + E.Rows.Values (K) * E.D.State.Qvel (E.Rows.Columns (K));
            end loop;
            if Friction then P := E.Dofs (Row.Id).Params; Diag := E.Dofs (Row.Id).Weight;
            elsif Row.Kind = CA.Limit_Joint then
               P := E.Joints (Row.Id).Params; Diag := E.Dofs (E.Joints (Row.Id).Vadr).Weight;
            else
               declare
                  Contact_Id : constant Natural := Row.Id;
                  C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Contact_Id);
                  B1 : constant Natural := E.Geoms (C.Geoms.First).Body_Id;
                  B2 : constant Natural := E.Geoms (C.Geoms.Second).Body_Id;
                  Tran : constant Real := E.Bodies (B1).Translation + E.Bodies (B2).Translation;
               begin
                  P := Parameters (Real_Array (C.Param.Ref), Real_Array (C.Param.Imp), 0);
                  Diag := (if C.Dim = 1 then Tran else Tran + (C.Param.Fri (0) * C.Param.Fri (0)) * Tran);
               end;
            end if;
            declare
               EP : constant LR.Effective_Parameters := LR.Sanitize (P, E.D.Timestep, not Disabled (E.Flags, Dsbl_Refsafe));
               Imp : constant Real := LR.Impedance (EP, Row.Param.Position, Row.Param.Margin);
               K : constant Real := (if Friction then 0.0 else LR.Stiffness (EP));
               B : constant Real := LR.Damping (EP);
               Reg : Real := Real'Max (Min_Val, ((1.0 - Imp) * Diag) / Imp);
            begin
               if Row.Kind = CA.Contact_Pyramidal then
                  declare
                     Mu : constant Real := E.Contacts (Row.Id).Param.Fri (0)
                       * MJ.Joint_Limit_Math.Sqrt ((Reg / Real'Max (Min_Val, E.Impratio)) / Reg);
                  begin Reg := ((2.0 * Mu) * Mu) * Reg; end;
               end if;
               Aref (R) := (-B * Velocity) - ((K * Imp) * (Row.Param.Position - Row.Param.Margin));
               E.Solver_Rows (R) := (Form => (if Friction then CS.Friction else CS.Unilateral),
                 R => Reg, D => 1.0 / Reg, Bound => Row.Loss, others => <>);
               E.T.Aref (R) := Aref (R); E.T.R (R) := Reg;
               for V in 1 .. Nv loop E.T.J (R, V) := J (R, V); end loop;
            end;
         end;
      end loop;
      CS.Solve (Mass, J, A_Free, Aref, E.Solver_Rows (1 .. Nr), E.Settings, A, Force, E.T.Report);
      if E.T.Report.Outcome not in CS.Converged | CS.Iteration_Limit then return; end if;
      for R in 1 .. Nr loop
         E.T.Force (R) := Force (R);
         for K in E.Rows.Descriptors (R).Offset + 1 ..
           E.Rows.Descriptors (R).Offset + E.Rows.Descriptors (R).Nonzeros loop
            declare
               V : constant Positive := E.Rows.Columns (K) + 1;
            begin
               E.T.Constraint_Force (V) := CK.Accumulate_Force (E.T.Constraint_Force (V), E.Rows.Values (K), Force (R));
            end;
         end loop;
      end loop;
      --  Admission before publication: no partial output acceleration/force.
      for V in 1 .. Nv loop
         if A (V) not in Tier0_Real or else
           E.D.Dynamics.Total (V-1) + E.T.Constraint_Force (V) not in Tier0_Real then return; end if;
      end loop;
      for V in 1 .. Nv loop
         E.D.Dynamics.Acceleration (V-1) := A (V);
         E.D.Dynamics.Total (V-1) := E.D.Dynamics.Total (V-1) + E.T.Constraint_Force (V);
         E.T.Acceleration (V) := A (V);
      end loop;
      E.T.Valid := True; Result := Success;
   end Prepare_And_Solve;

   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      E.T.Valid := False;
      Result := Not_Allocated;
      if not Ready (E) then return; end if;
      MJ.Data.Forward.Evaluate (E.D, Result, External);
      if Result /= Success then return; end if;
      Generate_Contacts (E, Result);
      if Result /= Success then return; end if;
      if E.T.Ncontact > 0 then
         Pipeline.Ensure_Jacobians (E.D, Result);
         if Result /= Success then return; end if;
      end if;
      Assemble (E, Result);
      if Result /= Success then return; end if;
      Prepare_And_Solve (E, Result);
   exception
      when Constraint_Error => E.T.Valid := False; Result := Numeric_Limit;
   end Evaluate;

   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Next_Time, Value : Real;
      Q : Quaternion;
   begin
      Evaluate (E, Result, External);
      if Result /= Success then return; end if;
      --  As mj_EulerSkip: solve (M+h*damping)*rate = smooth_force+J'*force.
      --  With no damping, copy the solver's constrained acceleration instead.
      Inertia_Phase.Solve_Euler (E.D, Result);
      if Result /= Success then E.T.Valid := False; return; end if;
      Result := Numeric_Limit;
      Next_Time := E.D.Clock + E.D.Timestep;
      if Next_Time not in Nonneg_Tier0 then return; end if;
      for V in 0 .. E.D.Nv - 1 loop
         Value := CK.Velocity_Update (E.D.State.Qvel (V), E.D.Scratch.Solution (V), E.D.Timestep);
         if Value not in Tier0_Real then return; end if;
         E.D.Scratch.Next_Qvel (V) := Value;
      end loop;
      E.D.Scratch.Next_Qpos.all := E.D.State.Qpos.all;
      for P of E.D.Joint_Config.all loop
         if P.Group_Type in 2 .. 3 or else (P.Group_Type = 0 and then P.Component < 3) then
            Value := E.D.State.Qpos (P.Qadr) + E.D.Timestep * E.D.Scratch.Next_Qvel (P.Vadr);
            if Value not in Tier0_Real then return; end if;
            E.D.Scratch.Next_Qpos (P.Qadr) := Value;
         elsif (P.Group_Type = 1 and then P.Component = 0)
           or else (P.Group_Type = 0 and then P.Component = 3) then
            Q := MJ.Manifold_Math.Integrated (Read_Quaternion (E.D.State.Qpos.all, P.Qadr),
              Read_Vector (E.D.Scratch.Next_Qvel.all, P.Vadr), E.D.Timestep);
            for K in 0 .. 3 loop
               if Q (K) not in Tier0_Real then return; end if;
               E.D.Scratch.Next_Qpos (P.Qadr + K) := Q (K);
            end loop;
         end if;
      end loop;
      E.D.State.Qpos.all := E.D.Scratch.Next_Qpos.all;
      E.D.State.Qvel.all := E.D.Scratch.Next_Qvel.all;
      E.D.Clock := Next_Time;
      Invalidate (E.D.Cache);
      Result := Success;
   exception
      when Constraint_Error => E.T.Valid := False; Result := Numeric_Limit;
   end Step;
end MJ.Data.Constrained;

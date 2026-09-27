with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;
with MJ.Solver_Kernels;
with MJ.Solver_Reductions;
with MJ.Data.Pipeline;
with MJ.Data.Spatial;
with MJ.Smooth_Topology;

package body MJ.Data.Inertia_Phase with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   --  CRB and RNE share inertias/axes prepared once in the root COM frame.
   procedure Try_Assemble_CRB (D : Simulation; Mass : out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid and then D.Cache.Spatial_Valid
       and then D.Nv <= 256
       and then Mass'First = 0 and then Mass'Last = D.Nv * D.Nv - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Mass)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, D.Nv)
   is
      package SK renames MJ.Spatial_Kernels;
      package T renames MJ.Smooth_Topology;
      type Inertia_Array is array (Natural range <>) of SK.Inertia;
      Composite : Inertia_Array (0 .. D.Nb - 1) with Relaxed_Initialization;
   begin
      Ok := False;
      Mass := [others => 0.0];
      if D.Nv = 0 then Ok := True; return; end if;
      for B in Composite'Range loop
         Composite (B) := MJ.Spatial_Storage.Load_Inertia (D.Kinematic.Spatial_Inertias.all, 10 * B);
         pragma Loop_Invariant (for all K in Composite'First .. B => Composite (K)'Initialized);
         pragma Loop_Invariant (for all K in Composite'First .. B => SK.Bounded (Composite (K), 1.0e40));
      end loop;
      for B in reverse 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (for all K in Composite'Range => SK.Bounded (Composite (K), 1.0e40));
         declare
            P : constant Natural := D.Body_Config (B).Parent;
            Sum : SK.Inertia;
         begin
            if P > 0 then
               Sum := SK.Add (Composite (P), Composite (B));
               if not SK.Bounded (Sum, 1.0e40) then return; end if;
               Composite (P) := Sum;
            end if;
         end;
      end loop;
      for I in 0 .. D.Nv - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass)
           and then MJ.Smooth_Dynamics.Symmetric (Mass, D.Nv));
         if T.Simple_Count (D.Topology, I) > 0 then
            MJ.Smooth_Dynamics.Store_Symmetric
              (Mass, D.Nv, I, I, T.Fixed_Inertia (D.Topology, I));
         else
            declare
               Product : constant SK.Motion := SK.Multiply
                 (Composite (T.Dof_Body (D.Topology, I)),
                  MJ.Spatial_Storage.Load_Motion (D.Kinematic.Spatial_Motions.all, 6 * T.Dof_Joint (D.Topology, I)));
               J : Integer := I;
               Value : Real;
            begin
               while J >= 0 loop
                  pragma Loop_Variant (Decreases => J);
                  pragma Loop_Invariant (J in 0 .. I);
                  pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass)
                    and then MJ.Smooth_Dynamics.Symmetric (Mass, D.Nv));
                  Value := (if J = I then T.Armature (D.Topology, I) else 0.0)
                    + SK.Dot (MJ.Spatial_Storage.Load_Motion (D.Kinematic.Spatial_Motions.all, 6 * T.Dof_Joint (D.Topology, J)), Product);
                  if not Within_Work (Value) then return; end if;
                  MJ.Smooth_Dynamics.Store_Symmetric (Mass, D.Nv, I, J, Value);
                  J := T.Parent_Dof (D.Topology, J);
               end loop;
            end;
         end if;
      end loop;
      Ok := True;
   end Try_Assemble_CRB;

   procedure Assemble (D : in out Simulation; Result : out Status) is
      Nv : constant Natural := D.Nv;
      Used_CRB, Spatial_Ok : Boolean;
   begin
      if not Phase_Ready (D) then
         Result := Not_Allocated;
         pragma Assert (Stable_Ready (D)); return;
      elsif not D.Cache.Pose_Valid then
         Result := Stale_Results;
         pragma Assert (Stable_Ready (D)); return;
      end if;
      D.Cache.Mass_Valid := False;
      D.Cache.Force_Valid := False;
      D.Dynamics.Mass.all := [others => 0.0];
      Result := Numeric_Limit;
      Used_CRB := False;
      if D.Nv >= 3 then
         declare
            Candidate : Real_Array (0 .. Nv * Nv - 1) with Relaxed_Initialization;
         begin
            Spatial.Prepare (D, Spatial_Ok);
            if Spatial_Ok then Try_Assemble_CRB (D, Candidate, Used_CRB); end if;
            if Used_CRB then D.Dynamics.Mass.all := Candidate; end if;
         end;
      end if;
      if Used_CRB then
         D.Cache.Mass_Valid := True;
         Result := Success;
         pragma Assert (Stable_Ready (D)); return;
      end if;
      D.Dynamics.Mass.all := [others => 0.0];
      Pipeline.Ensure_Jacobians (D, Result);
      if Result /= Success then pragma Assert (Stable_Ready (D)); return; end if;
      Prove_Jacobian_Readiness (D);
      Result := Numeric_Limit;
      --  Kinetic energy: M = sum(m*Jv'Jv + Jw'*I_world*Jw) + armature.
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         pragma Loop_Invariant (Symmetric_Mass (D));
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            R : constant Matrix := D.Kinematic.Bodies (B).Inertial_Rotation;
            First : constant Natural := 3 * B * D.Nv;
            Last : constant Integer := First + 3 * D.Nv - 1;
            Columns : MJ.Smooth_Dynamics.Inertia_Column_Array (0 .. Nv - 1);
         begin
            MJ.Smooth_Dynamics.Prepare_Mass_Columns
              (D.Kinematic.Angular_Jacobian (First .. Last), R, C.Inertia, Columns);
            for I in 0 .. D.Nv - 1 loop
               pragma Loop_Invariant (Static => Stable_Ready (D));
               pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
               pragma Loop_Invariant (Symmetric_Mass (D));
               declare
                  Li : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, First + 3 * I);
                  Ai : constant Vector := Read_Vector (D.Kinematic.Angular_Jacobian.all, First + 3 * I);
               begin
                  for J in 0 .. I loop
                     pragma Loop_Invariant (Static => Stable_Ready (D));
                     pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
                     pragma Loop_Invariant (Symmetric_Mass (D));
                     declare
                        Lj : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, First + 3 * J);
                        Value : constant Real := MJ.Smooth_Dynamics.Prepared_Mass_Contribution
                          (D.Dynamics.Mass (I * D.Nv + J), C.Mass, Li, Lj, Ai, Columns (J));
                     begin
                        if not Within_Work (Value) then pragma Assert (Stable_Ready (D)); return; end if;
                        D.Dynamics.Mass (I * D.Nv + J) := Value;
                        D.Dynamics.Mass (J * D.Nv + I) := Value;
                     end;
                  end loop;
               end;
            end loop;
         end;
      end loop;
      for J in 0 .. D.Nj - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         pragma Loop_Invariant (Symmetric_Mass (D));
         declare
            V : constant Natural := D.Joint_Config (J).Vadr;
            I : constant Natural := V * D.Nv + V;
            Value : constant Real := D.Dynamics.Mass (I) + D.Joint_Config (J).Armature;
         begin
            if not Within_Work (Value) then
               pragma Assert (Stable_Ready (D)); return;
            end if;
            D.Dynamics.Mass (I) := Value;
         end;
      end loop;
      D.Cache.Mass_Valid := True;
      Result := Success;
      pragma Assert (Stable_Ready (D));
   end Assemble;

   --  A positive divisor may be much smaller than Min_Val in a uniformly
   --  small, well-conditioned system. Bound the quotient before dividing.
   function Division_Bounded (Numerator, Denominator : Real) return Boolean is
     (Within_Work (Numerator) and then Denominator > 0.0
      and then (Denominator >= 1.0
                or else abs Numerator <= Work_Limit * Denominator));

   --  Solve (A / Diagonal_Scale) x = Rhs using the existing A = L D L' factors.
   --  Scaling D alone leaves L unchanged. Rhs is workspace; Solution is output.
   procedure Solve_Factored
     (D : in out Simulation; Diagonal_Scale : Real; Pivots : Real_Array; Result : out Status)
     with Global => null, Pre => Stable_Ready (D), Post => Stable_Ready (D) and then Shape (D) = Shape (D)'Old
   is
      N : constant Natural := D.Nv;
      Value, Pivot : Real;
   begin
      Result := Numeric_Limit;
      if Diagonal_Scale <= 0.0 then
         pragma Assert (Stable_Ready (D)); return;
      end if;
      --  L y = b; the forward RHS becomes y, not D^-1*y yet.
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         Value := D.Scratch.Rhs (I);
         for J in 0 .. I - 1 loop
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            Value := Value - D.Scratch.Factor (I * N + J) * D.Scratch.Rhs (J);
         end loop;
         if not Within_Work (Value) then
            pragma Assert (Stable_Ready (D)); return;
         end if;
         D.Scratch.Rhs (I) := Value;
      end loop;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         Pivot := (if Pivots'Length = N then Pivots (I)
                   else D.Scratch.Factor (I * N + I) / Diagonal_Scale);
         if not Division_Bounded (D.Scratch.Rhs (I), Pivot) then
            pragma Assert (Stable_Ready (D)); return;
         end if;
         Value := D.Scratch.Rhs (I) / Pivot;
         if not Within_Work (Value) then
            pragma Assert (Stable_Ready (D)); return;
         end if;
         D.Scratch.Rhs (I) := Value;
      end loop;
      --  L' x = D^-1*y. Reverse iteration also handles nv=0.
      for I in reverse 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         Value := D.Scratch.Rhs (I);
         for J in I + 1 .. N - 1 loop
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            Value := Value - D.Scratch.Factor (J * N + I) * D.Scratch.Solution (J);
         end loop;
         if not Within_Work (Value) then
            pragma Assert (Stable_Ready (D)); return;
         end if;
         D.Scratch.Solution (I) := Value;
      end loop;
      Result := Success;
      pragma Assert (Stable_Ready (D));
   end Solve_Factored;

   procedure Check_Condition
     (D : in out Simulation; Matrix_Norm, Condition_Limit : Real; Result : out Status)
     with Global => null, Pre => Stable_Ready (D), Post => Stable_Ready (D) and then Shape (D) = Shape (D)'Old
   is
      Value : Real;
      --  The factor and norm are unchanged across the basis-vector solves.
      --  Cache the same divisions, without replacing them by reciprocals.
      N : constant Natural := D.Nv;
      Pivots : Real_Array (0 .. (if Matrix_Norm in Min_Val .. 1.0e100 then N else 0) - 1)
        with Relaxed_Initialization;
   begin
      --  Each solve gives one column of ||A||_inf * A^-1. Its largest absolute
      --  row sum estimates kappa_inf(A), with no explicit inverse stored.
      --  The scaled D avoids huge inverse entries solely due to small units.
      D.Scratch.Condition_Sums.all := [others => 0.0];
      if Matrix_Norm in Min_Val .. 1.0e100 then
         MJ.Smooth_Dynamics.Prepare_Scaled_Diagonal
           (D.Scratch.Factor.all, D.Nv, Matrix_Norm, Pivots);
      end if;
      for Column in 0 .. D.Nv - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         D.Scratch.Rhs.all := [others => 0.0];
         D.Scratch.Rhs (Column) := 1.0;
         Solve_Factored (D, Matrix_Norm, Pivots, Result);
         if Result /= Success then
            pragma Assert (Stable_Ready (D)); return;
         end if;
         for I in 0 .. D.Nv - 1 loop
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            Value := D.Scratch.Condition_Sums (I) + abs D.Scratch.Solution (I);
            if not Within_Work (Value) then
               Result := Numeric_Limit;
               pragma Assert (Stable_Ready (D)); return;
            elsif Value >= Condition_Limit then
               Result := Ill_Conditioned_Inertia;
               pragma Assert (Stable_Ready (D)); return;
            end if;
            D.Scratch.Condition_Sums (I) := Value;
         end loop;
      end loop;
      Result := Success;
      pragma Assert (Stable_Ready (D));
   end Check_Condition;

   --  C's reverse L' D L algorithm on full ancestor rows. A row of an
   --  ancestor occupies the corresponding prefix of every descendant row.
   procedure Solve_Compatible (D : in out Simulation; Result : out Status)
     with Global => null,
     Pre => Is_Ready (D) and then Array_Bounded (D.Scratch.Ancestor_Factor)
       and then Array_Bounded (D.Dynamics.Total),
     Post => Stable_Ready (D) and then Shape (D) = Shape (D)'Old and then Is_Ready (D)
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if D.First_Clamped'Old >= 0 then D.First_Clamped = D.First_Clamped'Old)
       and then (if Result = Success then Array_Bounded (D.Scratch.Solution))
   is
      package SK renames MJ.Solver_Kernels;
      package SR renames MJ.Solver_Reductions;
      package AR renames MJ.Ancestor_Rows;
      N : constant Natural := D.Nv;
      Inverses : array (0 .. N - 1) of SK.Inverse_Real := [others => 1.0];
      Pivot : SK.Positive_Pivot;
      Multiplier : SK.Scale_Real;
      Value : Real;
      Accepted : Boolean;
   begin
      Result := Numeric_Limit;
      for K in reverse 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         pragma Loop_Invariant (Array_Bounded (D.Scratch.Ancestor_Factor));
         declare
            First : constant Natural := AR.Start (D.Ancestors, K);
            Diag : constant Natural := AR.Length (D.Ancestors, K) - 1;
            Last : constant Natural := First + Diag;
         begin
            Pivot := SK.Clamp_Pivot (D.Scratch.Ancestor_Factor (Last));
            if D.Scratch.Ancestor_Factor (Last) < Min_Val and then D.First_Clamped < 0 then
               D.First_Clamped := K;
            end if;
            D.Scratch.Ancestor_Factor (Last) := Pivot;
            Inverses (K) := SK.Reciprocal (Pivot);
            for A in reverse 0 .. Diag - 1 loop
               pragma Loop_Invariant (Static => Stable_Ready (D));
               pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
               pragma Loop_Invariant (Array_Bounded (D.Scratch.Ancestor_Factor));
               declare
                  I : constant Natural := (if Diag = K then A else AR.Column (D.Ancestors, K, A));
               begin
                  pragma Assert (Static => I = AR.Column (D.Ancestors, K, A));
                  pragma Assert (Static => AR.Length (D.Ancestors, I) = A + 1);
                  AR.Rows_Disjoint (D.Ancestors, I, K);
                  declare
                     Target : constant Natural :=
                       (if Diag = K then AR.Dense_Prefix_Start (D.Ancestors, I)
                        else AR.Start (D.Ancestors, I));
                  begin
                     pragma Assert (Static => Target + A < First);
                     Multiplier := SK.Scale (-D.Scratch.Ancestor_Factor (First + A), Inverses (K));
                     SK.Add_Row_Disjoint
                       (D.Scratch.Ancestor_Factor.all, Target, First, A + 1,
                        Multiplier, Accepted);
                     if not Accepted then pragma Assert (Stable_Ready (D)); return; end if;
                  end;
               end;
            end loop;
            SK.Scale_Row
              (D.Scratch.Ancestor_Factor (First .. Last - 1), Inverses (K), Accepted);
            if not Accepted then pragma Assert (Stable_Ready (D)); return; end if;
         end;
      end loop;
      D.Scratch.Solution.all := D.Dynamics.Total.all;
      --  L' y = rhs, followed by diagonal scaling, then L x = y.
      for I in reverse 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         pragma Loop_Invariant (Array_Bounded (D.Scratch.Solution));
         declare
            First : constant Natural := AR.Start (D.Ancestors, I);
            Diag : constant Natural := AR.Length (D.Ancestors, I) - 1;
         begin
            if D.Scratch.Solution (I) /= 0.0 and then Diag > 0 then
               if Diag = I then
                  --  Full prefix: preserve the contiguous SIMD row kernel.
                  SK.Add_Row
                    (D.Scratch.Solution (0 .. I - 1),
                     D.Scratch.Ancestor_Factor (First .. First + Diag - 1),
                     -D.Scratch.Solution (I), Accepted);
                  if not Accepted then pragma Assert (Stable_Ready (D)); return; end if;
               else
                  for A in 0 .. Diag - 1 loop
                     pragma Loop_Invariant (Static => Stable_Ready (D));
                     pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
                     declare
                        J : constant Natural := AR.Column (D.Ancestors, I, A);
                     begin
                        Value := SK.Add_Product
                          (D.Scratch.Solution (J), D.Scratch.Ancestor_Factor (First + A),
                           -D.Scratch.Solution (I));
                        if not Within_Work (Value) then pragma Assert (Stable_Ready (D)); return; end if;
                        D.Scratch.Solution (J) := Value;
                     end;
                  end loop;
               end if;
            end if;
         end;
      end loop;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         pragma Loop_Invariant (Array_Bounded (D.Scratch.Solution));
         Value := SK.Scale (D.Scratch.Solution (I), Inverses (I));
         if not Within_Work (Value) then pragma Assert (Stable_Ready (D)); return; end if;
         D.Scratch.Solution (I) := Value;
      end loop;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         pragma Loop_Invariant (Array_Bounded (D.Scratch.Solution));
         SR.Forward_Value
           (D.Ancestors, I, D.Scratch.Ancestor_Factor.all, D.Scratch.Solution.all,
            D.Scratch.Solution (I), Value, Accepted);
         if not Accepted then pragma Assert (Stable_Ready (D)); return; end if;
         D.Scratch.Solution (I) := Value;
      end loop;
      Result := Success;
      pragma Assert (Stable_Ready (D));
   end Solve_Compatible;

   --  Keep the public dense mass and the strict solver unchanged. Pack only
   --  structural entries, once per physical solve; no tolerance drops terms.
   procedure Load_Ancestor_Factor (D : in out Simulation; Damping_Step : Real;
                                   Result : out Status) with
     Global => null,
     Pre => Is_Ready (D) and then D.Cache.Mass_Valid
       and then Damping_Step in 0.0 .. Max_Val,
     Post => Stable_Ready (D) and then Shape (D) = Shape (D)'Old and then Is_Ready (D)
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if Result = Success then Array_Bounded (D.Scratch.Ancestor_Factor))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      package AR renames MJ.Ancestor_Rows;
      Value : Real;
   begin
      Result := Numeric_Limit;
      AR.Copy_Matrix (D.Ancestors, D.Dynamics.Mass.all, D.Scratch.Ancestor_Factor.all);
      if Damping_Step > 0.0 then
         for I in 0 .. D.Nv - 1 loop
            declare
               Last : constant Natural := AR.Start (D.Ancestors, I) + AR.Length (D.Ancestors, I) - 1;
            begin
               Value := D.Scratch.Ancestor_Factor (Last) + Damping_Step * D.Joint_Config (I).Damping;
               if not Within_Work (Value) then pragma Assert (Stable_Ready (D)); return; end if;
               D.Scratch.Ancestor_Factor (Last) := Value;
            end;
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            pragma Loop_Invariant (Static => State_Values (D) = State_Values (D)'Loop_Entry);
            pragma Loop_Invariant (Static => Input_Values (D) = Input_Values (D)'Loop_Entry);
            pragma Loop_Invariant (Static => Is_Ready (D));
            pragma Loop_Invariant (Static => Array_Bounded (D.Scratch.Ancestor_Factor));
         end loop;
      end if;
      Result := Success;
      pragma Assert (Stable_Ready (D));
   end Load_Ancestor_Factor;

   procedure Solve (D : in out Simulation; Damping_Step : Real; Result : out Status)
     with Global => null, Pre => Stable_Ready (D), Post => Stable_Ready (D) and then Shape (D) = Shape (D)'Old
   is
      N : constant Natural := D.Nv;
      --  Dimensionless draft acceptance policy, not a proved error bound.
      Relative_Tolerance : constant Real :=
        64.0 * Real'Model_Epsilon * Real (Natural'Max (1, N));
      Matrix_Norm : Real := 0.0;
      Row_Sum, Value : Real;
   begin
      Result := Numeric_Limit;
      if D.Solver_Policy = Compatible then
         Load_Ancestor_Factor (D, Damping_Step, Result);
         if Result = Success then Solve_Compatible (D, Result); end if;
         pragma Assert (Stable_Ready (D)); return;
      end if;
      D.Scratch.Factor.all := D.Dynamics.Mass.all;
      if N = 0 then
         Result := Success;
         pragma Assert (Stable_Ready (D)); return;
      end if;
      if Damping_Step > 0.0 then
         for J in 0 .. D.Nj - 1 loop
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            declare
               V : constant Natural := D.Joint_Config (J).Vadr;
               Index : constant Natural := V * N + V;
            begin
               Value := D.Scratch.Factor (Index) + Damping_Step * D.Joint_Config (J).Damping;
               if not Within_Work (Value) then
                  pragma Assert (Stable_Ready (D)); return;
               end if;
               D.Scratch.Factor (Index) := Value;
            end;
         end loop;
      end if;
      --  Measure the matrix actually solved: M, or M + h*diag(damping).
      --  A row has at most Max_Dofs entries of magnitude Work_Limit.
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         Row_Sum := 0.0;
         for J in 0 .. N - 1 loop
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            Value := D.Scratch.Factor (I * N + J);
            if not Within_Work (Value) then
               pragma Assert (Stable_Ready (D)); return;
            end if;
            Row_Sum := Row_Sum + abs Value;
         end loop;
         Matrix_Norm := Real'Max (Matrix_Norm, Row_Sum);
      end loop;
      if Matrix_Norm = 0.0 then
         Result := Singular_Inertia;
         pragma Assert (Stable_Ready (D)); return;
      end if;

      --  In-place LDL': D on the diagonal, unit-diagonal L below it.
      --  No regularization. Pivot and condition policies use relative scales.
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         for J in 0 .. I - 1 loop
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            Value := D.Scratch.Factor (I * N + J);
            for K in 0 .. J - 1 loop
               pragma Loop_Invariant (Static => Stable_Ready (D));
               pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
               Value := Value - D.Scratch.Factor (I * N + K)
                 * D.Scratch.Factor (K * N + K) * D.Scratch.Factor (J * N + K);
            end loop;
            if not Division_Bounded (Value, D.Scratch.Factor (J * N + J)) then
               pragma Assert (Stable_Ready (D)); return;
            end if;
            Value := Value / D.Scratch.Factor (J * N + J);
            if not Within_Work (Value) then
               pragma Assert (Stable_Ready (D)); return;
            end if;
            D.Scratch.Factor (I * N + J) := Value;
         end loop;
         Value := D.Scratch.Factor (I * N + I);
         for K in 0 .. I - 1 loop
            pragma Loop_Invariant (Static => Stable_Ready (D));
            pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
            Value := Value - D.Scratch.Factor (I * N + K)
              * D.Scratch.Factor (I * N + K) * D.Scratch.Factor (K * N + K);
         end loop;
         if not Within_Work (Value) then
            pragma Assert (Stable_Ready (D)); return;
         elsif Value <= 0.0 then
            Result := Singular_Inertia;
            pragma Assert (Stable_Ready (D)); return;
         elsif Value / Matrix_Norm <= Relative_Tolerance then
            Result := Ill_Conditioned_Inertia;
            pragma Assert (Stable_Ready (D)); return;
         end if;
         D.Scratch.Factor (I * N + I) := Value;
      end loop;

      Check_Condition (D, Matrix_Norm, 1.0 / Relative_Tolerance, Result);
      if Result /= Success then
         pragma Assert (Stable_Ready (D)); return;
      end if;
      --  Condition estimation consumed the RHS and solution buffers.
      D.Scratch.Rhs.all := D.Dynamics.Total.all;
      Solve_Factored (D, 1.0, [1 .. 0 => 0.0], Result);
      pragma Assert (Stable_Ready (D));
   end Solve;

   procedure Solve_Acceleration (D : in out Simulation; Result : out Status) is
      Value : Real;
   begin
      if not Phase_Ready (D) then
         Result := Not_Allocated;
         pragma Assert (Stable_Ready (D)); return;
      elsif not (D.Cache.Pose_Valid and then D.Cache.Mass_Valid and then D.Cache.Passive_Valid and then D.Cache.Actuation_Valid) then
         Result := Stale_Results;
         pragma Assert (Stable_Ready (D)); return;
      end if;
      D.Cache.Force_Valid := False;
      for I in 0 .. D.Nv - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         Value := MJ.Smooth_Dynamics.Total_Force
           (D.Dynamics.Gravity (I), D.Dynamics.Bias (I), D.Dynamics.Passive (I),
            D.Dynamics.Actuator (I), D.State.Applied (I));
         if not Within_Work (Value) then
            Result := Numeric_Limit;
            pragma Assert (Stable_Ready (D)); return;
         end if;
         D.Dynamics.Total (I) := Value;
      end loop;
      Solve (D, 0.0, Result);
      if Result /= Success then
         pragma Assert (Stable_Ready (D)); return;
      end if;
      for I in 0 .. D.Nv - 1 loop
         pragma Loop_Invariant (Static => Stable_Ready (D));
         pragma Loop_Invariant (Static => Shape (D) = Shape (D)'Loop_Entry);
         if D.Scratch.Solution (I) not in Tier0_Real then
            Result := Numeric_Limit;
            pragma Assert (Stable_Ready (D)); return;
         end if;
      end loop;
      D.Dynamics.Acceleration.all := D.Scratch.Solution.all;
      D.Cache.Force_Valid := True;
      pragma Assert (Stable_Ready (D));
   end Solve_Acceleration;

   function Damping_Present (D : Simulation) return Boolean
     with Global => null, Pre => Is_Ready (D),
     Post => Damping_Present'Result = (for some J in 0 .. D.Nj - 1 => D.Joint_Config (J).Damping > 0.0)
   is
   begin
      for J in 0 .. D.Nj - 1 loop
         if D.Joint_Config (J).Damping > 0.0 then return True; end if;
         pragma Loop_Invariant (for all K in 0 .. J => D.Joint_Config (K).Damping = 0.0);
      end loop;
      return False;
   end Damping_Present;

   procedure Solve_Euler (D : in out Simulation; Result : out Status) is
   begin
      if not Phase_Ready (D) then
         Result := Not_Allocated;
      elsif not D.Cache.Force_Valid then
         Result := Stale_Results;
      elsif D.Implicit_Damping and then Damping_Present (D) then
         Solve (D, D.Timestep, Result);
      else
         D.Scratch.Solution.all := D.Dynamics.Acceleration.all;
         Result := Success;
      end if;
      pragma Assert (Stable_Ready (D));
   end Solve_Euler;
end MJ.Data.Inertia_Phase;

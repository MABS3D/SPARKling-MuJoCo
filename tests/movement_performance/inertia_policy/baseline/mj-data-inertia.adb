with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;

package body MJ.Data.Inertia with SPARK_Mode is
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   --  Composite rigid body assembly in one common frame per root tree. The
   --  original Jacobian assembly remains the fallback outside this fast domain.
   procedure Try_Assemble_CRB (D : Simulation; Mass : out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid and then D.Nv <= 256
       and then Mass'First = 0 and then Mass'Last = D.Nv * D.Nv - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Mass)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, D.Nv)
   is
      package SK renames MJ.Spatial_Kernels;
      type Inertia_Array is array (Natural range <>) of SK.Inertia;
      type Motion_Array is array (Natural range <>) of SK.Motion;
      type Vector_Array is array (Natural range <>) of Vector;
      type Index_Array is array (Natural range <>) of Integer;
      Composite : Inertia_Array (0 .. D.Nb - 1) := [others => [others => 0.0]];
      Motions : Motion_Array (0 .. D.Nv - 1) := [others => [others => 0.0]];
      Moment, Center : Vector_Array (0 .. D.Nb - 1) := [others => Zero];
      Submass : Real_Array (0 .. D.Nb - 1) := [others => 0.0];
      Root : Index_Array (0 .. D.Nb - 1) := [others => 0];
      Last_Dof : Index_Array (0 .. D.Nb - 1) := [others => -1];
      Parent_Dof : Index_Array (0 .. D.Nv - 1) := [others => -1];
      Dof_Body : Index_Array (0 .. D.Nv - 1) := [others => 0];
      Armature : Real_Array (0 .. D.Nv - 1) := [others => 0.0];
   begin
      Ok := False;
      Mass := [others => 0.0];
      if D.Nv = 0 then Ok := True; return; end if;
      for B in 1 .. D.Nb - 1 loop
         if not Bounded (D.Kinematic.Bodies (B).Center, Max_Val) then return; end if;
         Root (B) := (if D.Body_Config (B).Parent = 0 then B else Root (D.Body_Config (B).Parent));
         Submass (B) := D.Body_Config (B).Mass;
         Moment (B) := SK.Mass_Moment (D.Body_Config (B).Mass, D.Kinematic.Bodies (B).Center);
         pragma Loop_Invariant (for all K in Root'Range => Root (K) in 0 .. D.Nb - 1);
         pragma Loop_Invariant (for all K in 1 .. B => Root (K) in 1 .. K
           and then Bounded (D.Kinematic.Bodies (K).Center, Max_Val));
         pragma Loop_Invariant (for all K in Submass'Range => Submass (K) in 0.0 .. 1.0e14
           and then Bounded (Moment (K), 1.0e24));
      end loop;
      for B in reverse 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (for all K in Submass'Range => Submass (K) in 0.0 .. 1.0e14
           and then Bounded (Moment (K), 1.0e24));
         declare
            P : constant Natural := D.Body_Config (B).Parent;
         begin
            if P > 0 then
               Submass (P) := Submass (P) + Submass (B);
               Moment (P) := Moment (P) + Moment (B);
               if Submass (P) > 1.0e14 or else not Bounded (Moment (P), 1.0e24) then return; end if;
            end if;
         end;
      end loop;
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (for all K in Center'Range => Bounded (Center (K), Max_Val));
         if Root (B) = B then
            Center (B) := (if Submass (B) < Min_Val then D.Kinematic.Bodies (B).Center
                          else (1.0 / Submass (B)) * Moment (B));
            if not Bounded (Center (B), Max_Val) then return; end if;
         end if;
      end loop;
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (for all K in Composite'Range => SK.Bounded (Composite (K), 1.0e40));
         pragma Loop_Invariant (for all K in Motions'Range => SK.Bounded (Motions (K), 1.0e12)
           and then Parent_Dof (K) in -1 .. K - 1 and then Dof_Body (K) in 0 .. D.Nb - 1);
         pragma Loop_Invariant (for all K in Last_Dof'Range => Last_Dof (K) in -1 .. D.Nv - 1);
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            Origin : constant Vector := Center (Root (B));
            Offset : constant Vector := SK.Frame_Offset (D.Kinematic.Bodies (B).Center, Origin);
         begin
            Composite (B) := SK.Make_Inertia
              (D.Kinematic.Bodies (B).Inertial_Rotation, C.Inertia, C.Mass, Offset);
            Last_Dof (B) := Last_Dof (C.Parent);
            for K in 0 .. C.Joint_Count - 1 loop
               pragma Loop_Invariant (for all V in Motions'Range => SK.Bounded (Motions (V), 1.0e12)
                 and then Parent_Dof (V) in -1 .. V - 1 and then Dof_Body (V) in 0 .. D.Nb - 1);
               pragma Loop_Invariant (for all V in Last_Dof'Range => Last_Dof (V) in -1 .. D.Nv - 1);
               declare
                  J : constant Natural := C.First_Joint + K;
                  Joint : constant Joint_Parameters := D.Joint_Config (J);
                  V : constant Natural := Joint.Vadr;
                  Pose : constant Joint_State := D.Kinematic.Joints (J);
               begin
                  if not Bounded (Pose.Anchor, Max_Val) or else Last_Dof (B) >= V then return; end if;
                  Parent_Dof (V) := Last_Dof (B);
                  Last_Dof (B) := V;
                  Dof_Body (V) := B;
                  Armature (V) := Joint.Armature;
                  Motions (V) := SK.Joint_Motion (Pose.Direction, SK.Frame_Offset (Origin, Pose.Anchor), Joint.Kind = Hinge_Joint);
                  if not SK.Bounded (Motions (V), 1.0e12) then return; end if;
               end;
            end loop;
         end;
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
         declare
            Product : constant SK.Motion := SK.Multiply (Composite (Dof_Body (I)), Motions (I));
            J : Integer := I;
            Value : Real;
         begin
            while J >= 0 loop
               pragma Loop_Variant (Decreases => J);
               pragma Loop_Invariant (J in 0 .. I);
               pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass)
                 and then MJ.Smooth_Dynamics.Symmetric (Mass, D.Nv));
               Value := (if J = I then Armature (I) else 0.0) + SK.Dot (Motions (J), Product);
               if not Within_Work (Value) then return; end if;
               MJ.Smooth_Dynamics.Store_Symmetric (Mass, D.Nv, I, J, Value);
               J := Parent_Dof (J);
            end loop;
         end;
      end loop;
      Ok := True;
   end Try_Assemble_CRB;

   procedure Assemble (D : in out Simulation; Result : out Status) is
      Used_CRB : Boolean;
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      elsif not D.Cache.Pose_Valid then
         Result := Stale_Results;
         return;
      end if;
      D.Cache.Mass_Valid := False;
      D.Cache.Force_Valid := False;
      D.Dynamics.Mass.all := [others => 0.0];
      Result := Numeric_Limit;
      Used_CRB := False;
      if D.Nv >= 3 then
         declare
            Candidate : Real_Array (0 .. D.Nv * D.Nv - 1);
         begin
            Try_Assemble_CRB (D, Candidate, Used_CRB);
            if Used_CRB then D.Dynamics.Mass.all := Candidate; end if;
         end;
      end if;
      if Used_CRB then
         D.Cache.Mass_Valid := True;
         Result := Success;
         return;
      end if;
      D.Dynamics.Mass.all := [others => 0.0];
      --  Kinetic energy: M = sum(m*Jv'Jv + Jw'*I_world*Jw) + armature.
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (Symmetric_Mass (D));
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            R : constant Matrix := D.Kinematic.Bodies (B).Inertial_Rotation;
            First : constant Natural := 3 * B * D.Nv;
            Last : constant Integer := First + 3 * D.Nv - 1;
            Columns : MJ.Smooth_Dynamics.Inertia_Column_Array (0 .. D.Nv - 1);
         begin
            MJ.Smooth_Dynamics.Prepare_Mass_Columns
              (D.Kinematic.Angular_Jacobian (First .. Last), R, C.Inertia, Columns);
            for I in 0 .. D.Nv - 1 loop
               pragma Loop_Invariant (Symmetric_Mass (D));
               declare
                  Li : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, First + 3 * I);
                  Ai : constant Vector := Read_Vector (D.Kinematic.Angular_Jacobian.all, First + 3 * I);
               begin
                  for J in 0 .. I loop
                     pragma Loop_Invariant (Symmetric_Mass (D));
                     declare
                        Lj : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, First + 3 * J);
                        Value : constant Real := MJ.Smooth_Dynamics.Prepared_Mass_Contribution
                          (D.Dynamics.Mass (I * D.Nv + J), C.Mass, Li, Lj, Ai, Columns (J));
                     begin
                        if not Within_Work (Value) then return; end if;
                        D.Dynamics.Mass (I * D.Nv + J) := Value;
                        D.Dynamics.Mass (J * D.Nv + I) := Value;
                     end;
                  end loop;
               end;
            end loop;
         end;
      end loop;
      for J in 0 .. D.Nj - 1 loop
         pragma Loop_Invariant (Symmetric_Mass (D));
         declare
            V : constant Natural := D.Joint_Config (J).Vadr;
            I : constant Natural := V * D.Nv + V;
            Value : constant Real := D.Dynamics.Mass (I) + D.Joint_Config (J).Armature;
         begin
            if not Within_Work (Value) then
               return;
            end if;
            D.Dynamics.Mass (I) := Value;
         end;
      end loop;
      D.Cache.Mass_Valid := True;
      Result := Success;
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
   is
      N : constant Natural := D.Nv;
      Value, Pivot : Real;
   begin
      Result := Numeric_Limit;
      if Diagonal_Scale <= 0.0 then
         return;
      end if;
      --  L y = b; the forward RHS becomes y, not D^-1*y yet.
      for I in 0 .. N - 1 loop
         Value := D.Scratch.Rhs (I);
         for J in 0 .. I - 1 loop
            Value := Value - D.Scratch.Factor (I * N + J) * D.Scratch.Rhs (J);
         end loop;
         if not Within_Work (Value) then
            return;
         end if;
         D.Scratch.Rhs (I) := Value;
      end loop;
      for I in 0 .. N - 1 loop
         Pivot := (if Pivots'Length = N then Pivots (I)
                   else D.Scratch.Factor (I * N + I) / Diagonal_Scale);
         if not Division_Bounded (D.Scratch.Rhs (I), Pivot) then
            return;
         end if;
         Value := D.Scratch.Rhs (I) / Pivot;
         if not Within_Work (Value) then
            return;
         end if;
         D.Scratch.Rhs (I) := Value;
      end loop;
      --  L' x = D^-1*y. Reverse iteration also handles nv=0.
      for I in reverse 0 .. N - 1 loop
         Value := D.Scratch.Rhs (I);
         for J in I + 1 .. N - 1 loop
            Value := Value - D.Scratch.Factor (J * N + I) * D.Scratch.Solution (J);
         end loop;
         if not Within_Work (Value) then
            return;
         end if;
         D.Scratch.Solution (I) := Value;
      end loop;
      Result := Success;
   end Solve_Factored;

   procedure Check_Condition
     (D : in out Simulation; Matrix_Norm, Condition_Limit : Real; Result : out Status)
   is
      Value : Real;
      --  The factor and norm are unchanged across the basis-vector solves.
      --  Cache the same divisions, without replacing them by reciprocals.
      Pivots : Real_Array (0 .. (if Matrix_Norm in Min_Val .. 1.0e100 then D.Nv else 0) - 1);
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
         D.Scratch.Rhs.all := [others => 0.0];
         D.Scratch.Rhs (Column) := 1.0;
         Solve_Factored (D, Matrix_Norm, Pivots, Result);
         if Result /= Success then
            return;
         end if;
         for I in 0 .. D.Nv - 1 loop
            Value := D.Scratch.Condition_Sums (I) + abs D.Scratch.Solution (I);
            if not Within_Work (Value) then
               Result := Numeric_Limit;
               return;
            elsif Value >= Condition_Limit then
               Result := Ill_Conditioned_Inertia;
               return;
            end if;
            D.Scratch.Condition_Sums (I) := Value;
         end loop;
      end loop;
      Result := Success;
   end Check_Condition;

   procedure Solve (D : in out Simulation; Damping_Step : Real; Result : out Status) is
      N : constant Natural := D.Nv;
      --  Dimensionless draft acceptance policy, not a proved error bound.
      Relative_Tolerance : constant Real :=
        64.0 * Real'Model_Epsilon * Real (Natural'Max (1, N));
      Matrix_Norm : Real := 0.0;
      Row_Sum, Value : Real;
   begin
      Result := Numeric_Limit;
      D.Scratch.Factor.all := D.Dynamics.Mass.all;
      if N = 0 then
         Result := Success;
         return;
      end if;
      if Damping_Step > 0.0 then
         for J in 0 .. D.Nj - 1 loop
            declare
               V : constant Natural := D.Joint_Config (J).Vadr;
               Index : constant Natural := V * N + V;
            begin
               Value := D.Scratch.Factor (Index) + Damping_Step * D.Joint_Config (J).Damping;
               if not Within_Work (Value) then
                  return;
               end if;
               D.Scratch.Factor (Index) := Value;
            end;
         end loop;
      end if;
      --  Measure the matrix actually solved: M, or M + h*diag(damping).
      --  A row has at most Max_Dofs entries of magnitude Work_Limit.
      for I in 0 .. N - 1 loop
         Row_Sum := 0.0;
         for J in 0 .. N - 1 loop
            Value := D.Scratch.Factor (I * N + J);
            if not Within_Work (Value) then
               return;
            end if;
            Row_Sum := Row_Sum + abs Value;
         end loop;
         Matrix_Norm := Real'Max (Matrix_Norm, Row_Sum);
      end loop;
      if Matrix_Norm = 0.0 then
         Result := Singular_Inertia;
         return;
      end if;

      --  In-place LDL': D on the diagonal, unit-diagonal L below it.
      --  No regularization. Pivot and condition policies use relative scales.
      for I in 0 .. N - 1 loop
         for J in 0 .. I - 1 loop
            Value := D.Scratch.Factor (I * N + J);
            for K in 0 .. J - 1 loop
               Value := Value - D.Scratch.Factor (I * N + K)
                 * D.Scratch.Factor (K * N + K) * D.Scratch.Factor (J * N + K);
            end loop;
            if not Division_Bounded (Value, D.Scratch.Factor (J * N + J)) then
               return;
            end if;
            Value := Value / D.Scratch.Factor (J * N + J);
            if not Within_Work (Value) then
               return;
            end if;
            D.Scratch.Factor (I * N + J) := Value;
         end loop;
         Value := D.Scratch.Factor (I * N + I);
         for K in 0 .. I - 1 loop
            Value := Value - D.Scratch.Factor (I * N + K)
              * D.Scratch.Factor (I * N + K) * D.Scratch.Factor (K * N + K);
         end loop;
         if not Within_Work (Value) then
            return;
         elsif Value <= 0.0 then
            Result := Singular_Inertia;
            return;
         elsif Value / Matrix_Norm <= Relative_Tolerance then
            Result := Ill_Conditioned_Inertia;
            return;
         end if;
         D.Scratch.Factor (I * N + I) := Value;
      end loop;

      Check_Condition (D, Matrix_Norm, 1.0 / Relative_Tolerance, Result);
      if Result /= Success then
         return;
      end if;
      --  Condition estimation consumed the RHS and solution buffers.
      D.Scratch.Rhs.all := D.Dynamics.Total.all;
      Solve_Factored (D, 1.0, [1 .. 0 => 0.0], Result);
   end Solve;

   procedure Solve_Acceleration (D : in out Simulation; Result : out Status) is
      Value : Real;
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      elsif not (D.Cache.Pose_Valid and then D.Cache.Mass_Valid and then D.Cache.Passive_Valid and then D.Cache.Actuation_Valid) then
         Result := Stale_Results;
         return;
      end if;
      D.Cache.Force_Valid := False;
      for I in 0 .. D.Nv - 1 loop
         Value := MJ.Smooth_Dynamics.Total_Force
           (D.Dynamics.Gravity (I), D.Dynamics.Bias (I), D.Dynamics.Passive (I),
            D.Dynamics.Actuator (I), D.State.Applied (I));
         if not Within_Work (Value) then
            Result := Numeric_Limit;
            return;
         end if;
         D.Dynamics.Total (I) := Value;
      end loop;
      Solve (D, 0.0, Result);
      if Result /= Success then
         return;
      end if;
      for I in 0 .. D.Nv - 1 loop
         if D.Scratch.Solution (I) not in Tier0_Real then
            Result := Numeric_Limit;
            return;
         end if;
      end loop;
      D.Dynamics.Acceleration.all := D.Scratch.Solution.all;
      D.Cache.Force_Valid := True;
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
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif not D.Cache.Force_Valid then
         Result := Stale_Results;
      elsif D.Implicit_Damping and then Damping_Present (D) then
         Solve (D, D.Timestep, Result);
      else
         D.Scratch.Solution.all := D.Dynamics.Acceleration.all;
         Result := Success;
      end if;
   end Solve_Euler;
end MJ.Data.Inertia;

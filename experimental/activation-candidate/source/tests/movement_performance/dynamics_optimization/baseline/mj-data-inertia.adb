with MJ.Smooth_Dynamics;

package body MJ.Data.Inertia with SPARK_Mode is
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   procedure Assemble (D : in out Simulation; Result : out Status) is
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
      --  Kinetic energy: M = sum(m*Jv'Jv + Jw'*I_world*Jw) + armature.
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (Symmetric_Mass (D));
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            R : constant Matrix := D.Kinematic.Bodies (B).Inertial_Rotation;
         begin
            for I in 0 .. D.Nv - 1 loop
               pragma Loop_Invariant (Symmetric_Mass (D));
               declare
                  Ibase : constant Natural := Jacobian_Offset (D, B, I);
                  Li : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, Ibase);
                  Ai : constant Vector := Read_Vector (D.Kinematic.Angular_Jacobian.all, Ibase);
               begin
                  for J in 0 .. I loop
                     pragma Loop_Invariant (Symmetric_Mass (D));
                     declare
                        Jbase : constant Natural := Jacobian_Offset (D, B, J);
                        Lj : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, Jbase);
                        Aj : constant Vector := Read_Vector (D.Kinematic.Angular_Jacobian.all, Jbase);
                        Value : constant Real := MJ.Smooth_Dynamics.Mass_Contribution
                          (D.Dynamics.Mass (I * D.Nv + J), C.Mass, Li, Lj, Ai, Aj, R, C.Inertia);
                     begin
                        if not Within_Work (Value) then
                           return;
                        end if;
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
     (D : in out Simulation; Diagonal_Scale : Real; Result : out Status)
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
         Pivot := D.Scratch.Factor (I * N + I) / Diagonal_Scale;
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
   begin
      --  Each solve gives one column of ||A||_inf * A^-1. Its largest absolute
      --  row sum estimates kappa_inf(A), with no explicit inverse stored.
      --  The scaled D avoids huge inverse entries solely due to small units.
      D.Scratch.Condition_Sums.all := [others => 0.0];
      for Column in 0 .. D.Nv - 1 loop
         D.Scratch.Rhs.all := [others => 0.0];
         D.Scratch.Rhs (Column) := 1.0;
         Solve_Factored (D, Matrix_Norm, Result);
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
      Solve_Factored (D, 1.0, Result);
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

   procedure Solve_Euler (D : in out Simulation; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif not D.Cache.Force_Valid then
         Result := Stale_Results;
      elsif D.Implicit_Damping then
         Solve (D, D.Timestep, Result);
      else
         D.Scratch.Solution.all := D.Dynamics.Acceleration.all;
         Result := Success;
      end if;
   end Solve_Euler;
end MJ.Data.Inertia;

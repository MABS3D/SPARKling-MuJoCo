with MJ.Data.Pipeline;
with MJ.Data.Euler;
with MJ.Manifold_Math;
with MJ.Integration_Kernels;
with MJ.Integration_PCG;
with MJ.Activation;
with MJ.Data.Integration_Operators;
with MJ.Data.Manifold_Actuation;
package body MJ.Data.Integrators with SPARK_Mode is
   package K renames MJ.Integration_Kernels;
   procedure Create (M : in out MJ.Models.Model; D : in out Simulation;
                     Selected : out Selection; Result : out Status;
                     Solver_Policy : Inertia_Policy := Compatible) is
      Original : constant Integer := M.Opt.Integrator;
   begin
      Selected := (others => <>);
      if Original not in 0 .. 4 then Result := Unsupported_Feature; return; end if;
      if M.Opt.Iterations < 0 or else M.Opt.Tolerance not in Nonneg_Tier0 then
         Result := Invalid_Model; return;
      end if;
      Selected := (Kind => Method'Val (Original), Use_Couplings => M.Opt.Solver /= 0,
        Iterations => M.Opt.Iterations, Tolerance => M.Opt.Tolerance);
      M.Opt.Integrator := 0;
      MJ.Data.Create (M, D, Result, Solver_Policy);
      M.Opt.Integrator := Original;
   exception
      when others => M.Opt.Integrator := Original; raise;
   end Create;

   procedure Position_Update (D : Simulation; Q, Rate : Real_Array; H : Real;
                              Next : out Real_Array; Ok : out Boolean) is
      Value : Real; Rotation_Value : Quaternion;
   begin
      Ok := False; Next := Q;
      for P of D.Joint_Config.all loop
         if P.Group_Type in 2 .. 3 or else (P.Group_Type = 0 and then P.Component < 3) then
            Value := K.Advance (Q (P.Qadr), Rate (P.Vadr), H);
            if Value not in Tier0_Real then return; end if;
            Next (P.Qadr) := Value;
         elsif (P.Group_Type = 1 and then P.Component = 0)
           or else (P.Group_Type = 0 and then P.Component = 3) then
            Rotation_Value := MJ.Manifold_Math.Integrated
              (Read_Quaternion (Q, P.Qadr), Read_Vector (Rate, P.Vadr), H);
            for I in 0 .. 3 loop Next (P.Qadr + I) := Rotation_Value (I); end loop;
         end if;
      end loop;
      Ok := True;
   end Position_Update;

   procedure Solve (A : in out Real_Array; B : in out Real_Array; N : Natural; Ok : out Boolean) is
      Pivot, Factor, Value : Real;
   begin
      Ok := False;
      -- Ordered elimination, retaining an explicit numerical failure policy.
      for I in 0 .. N - 1 loop
         Pivot := A (I*N+I);
         if abs Pivot < Min_Val then return; end if;
         for R in I + 1 .. N - 1 loop
            Factor := A (R*N+I) / Pivot;
            if Factor not in K.Operand then return; end if;
            A (R*N+I) := 0.0;
            for C in I + 1 .. N - 1 loop
               Value := K.Update_Entry (A (R*N+C), Factor, A (I*N+C));
               if Value not in K.Operand then return; end if;
               A (R*N+C) := Value;
            end loop;
            Value := K.Update_Entry (B (R), Factor, B (I));
            if Value not in K.Operand then return; end if;
            B (R) := Value;
         end loop;
      end loop;
      for I in reverse 0 .. N - 1 loop
         Value := B (I);
         for J in I + 1 .. N - 1 loop
            Value := K.Update_Entry (Value, A (I*N+J), B (J));
            if Value not in K.Operand then return; end if;
         end loop;
         Value := Value / A (I*N+I);
         if Value not in Tier0_Real then return; end if;
         B (I) := Value;
      end loop;
      Ok := True;
   end Solve;

   procedure Native_Operators (D : in out Simulation; Selected : Selection;
                              Deriv, Addition, Shift, Backbone, Gyro : out Real_Array;
                              Has_Couplings : out Boolean; Result : out Status) is
   begin
      Integration_Operators.Build (D, Selected.Kind = Implicit_Velocity,
        Selected.Kind = Discrete, Selected.Use_Couplings, Deriv, Addition, Shift, Backbone, Gyro, Has_Couplings, Result);
   end Native_Operators;

   procedure Step (D : in out Simulation; Selected : Selection; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads;
      Velocity_Jacobian : Real_Array := [1 .. 0 => 0.0];
      Discrete_Addition : Real_Array := [1 .. 0 => 0.0];
      Discrete_Shift : Real_Array := [1 .. 0 => 0.0]) is
   begin
      if not Is_Ready (D) then Result := Not_Allocated; return; end if;
      if Selected.Kind = Euler then MJ.Data.Euler.Step (D, Result, External); return; end if;
      declare
         Nq : constant Natural := D.Nq; Nv : constant Natural := D.Nv;
         Na : constant Natural := D.Nactivation;
         Q0 : constant Real_Array := D.State.Qpos.all;
         V0 : constant Real_Array := D.State.Qvel.all;
         Act0 : constant State_Vector := D.Activation (0 .. Integer (Na)-1);
         Clock0 : constant Nonneg_Tier0 := D.Clock;
         H : constant Nonneg_Tier0 := D.Timestep;
         type Stages is array (Natural range <>, Natural range <>) of Real;
         Vstage, Fstage : Stages (0 .. 3, 0 .. Integer (Nv)-1);
         Astage : Stages (0 .. 3, 0 .. Integer (Na)-1);
         Q : Real_Array (0 .. Integer (Nq)-1);
         V, Rate, Position_Rate : Real_Array (0 .. Integer (Nv)-1);
         Activation_Rate : Real_Array (0 .. Integer (Na)-1);
         Next_Act : State_Vector (0 .. Integer (Na)-1);
         Matrix, Deriv, Addition : Real_Array (0 .. Integer (Nv*Nv)-1);
         Backbone, Gyro : Real_Array (0 .. Integer (Nv*Nv)-1) := [others => 0.0];
         Right, Solution : Real_Array (0 .. Integer (Nv)-1);
         Has_Couplings, Converged : Boolean := False;
         Shift : Real_Array (0 .. Integer (Nv)-1);
         Weights : constant Real_Array (0 .. 3) := [1.0/6.0, 1.0/3.0, 1.0/3.0, 1.0/6.0];
         Ok : Boolean; Value, W : Real;
         procedure Restore is
         begin
            D.State.Qpos.all := Q0; D.State.Qvel.all := V0;
            D.Activation (0 .. Integer (Na)-1) := Act0;
            D.Clock := Clock0; Invalidate (D.Cache);
         end Restore;
      begin
         Result := Numeric_Limit;
         if Clock0 + H not in Nonneg_Tier0 then return; end if;
         if (Velocity_Jacobian'Length /= 0 and then Velocity_Jacobian'Length /= Nv*Nv)
           or else (Discrete_Addition'Length /= 0 and then Discrete_Addition'Length /= Nv*Nv)
           or else (Discrete_Shift'Length /= 0 and then Discrete_Shift'Length /= Nv)
           or else ((Discrete_Addition'Length = 0) /= (Discrete_Shift'Length = 0)) then
            Result := Invalid_Size; return;
         end if;
         Pipeline.Evaluate_Ready (D, Result, External);
         if Result /= Success then return; end if;
         if Selected.Kind = RK4 then
            for I in 0 .. Nv-1 loop Vstage (0,I) := V0 (I); Fstage (0,I) := D.Dynamics.Acceleration (I); end loop;
            for I in 0 .. Na-1 loop Astage (0,I) := D.Act_Dot (I); end loop;
            for Stage in 1 .. 3 loop
               Position_Rate := [others => 0.0]; Rate := [others => 0.0]; Activation_Rate := [others => 0.0];
               for J in 0 .. Stage-1 loop
                  W := (if J = Stage-1 then (if Stage = 3 then 1.0 else 0.5) else 0.0);
                  for I in 0 .. Nv-1 loop
                     Position_Rate (I) := K.Add_Weighted (Position_Rate (I), Vstage (J,I), W);
                     Rate (I) := K.Add_Weighted (Rate (I), Fstage (J,I), W);
                  end loop;
                  for I in 0 .. Na-1 loop Activation_Rate (I) := K.Add_Weighted (Activation_Rate (I), Astage (J,I), W); end loop;
               end loop;
               Position_Update (D, Q0, Position_Rate, H, Q, Ok);
               if not Ok then Restore; Result := Numeric_Limit; return; end if;
               for I in 0 .. Nv-1 loop
                  Value := K.Advance (V0 (I), Rate (I), H);
                  if Value not in Tier0_Real then Restore; Result := Numeric_Limit; return; end if;
                  V (I) := Value;
               end loop;
               for I in 0 .. Na-1 loop
                  Value := K.Advance (Act0 (I), Activation_Rate (I), H);
                  if Value not in Tier0_Real then Restore; Result := Numeric_Limit; return; end if;
                  D.Activation (I) := Value;
               end loop;
               D.State.Qpos.all := Q; D.State.Qvel.all := V;
               D.Clock := Clock0 + (if Stage = 3 then H else 0.5*H);
               Invalidate (D.Cache); Pipeline.Evaluate_Ready (D, Result, External);
               if Result /= Success then Restore; return; end if;
               for I in 0 .. Nv-1 loop Vstage (Stage,I) := V (I); Fstage (Stage,I) := D.Dynamics.Acceleration (I); end loop;
               for I in 0 .. Na-1 loop Astage (Stage,I) := D.Act_Dot (I); end loop;
            end loop;
            Position_Rate := [others => 0.0]; Rate := [others => 0.0]; Activation_Rate := [others => 0.0];
            for J in 0 .. 3 loop
               for I in 0 .. Nv-1 loop
                  Position_Rate (I) := K.Add_Weighted (Position_Rate (I), Vstage (J,I), Weights (J));
                  Rate (I) := K.Add_Weighted (Rate (I), Fstage (J,I), Weights (J));
               end loop;
               for I in 0 .. Na-1 loop Activation_Rate (I) := K.Add_Weighted (Activation_Rate (I), Astage (J,I), Weights (J)); end loop;
            end loop;
            Restore;
         else
            if Selected.Kind = Discrete and then Discrete_Addition'Length /= 0 then
               Addition := Discrete_Addition; Shift := Discrete_Shift;
            elsif Selected.Kind /= Discrete and then Velocity_Jacobian'Length /= 0 then
               Deriv := Velocity_Jacobian;
            else
               Native_Operators (D, Selected, Deriv, Addition, Shift, Backbone, Gyro, Has_Couplings, Result);
               if Result /= Success then return; end if;
            end if;
            for I in 0 .. Nv-1 loop
               Rate (I) := D.Dynamics.Total (I) + (if Selected.Kind = Discrete then Shift (I) else 0.0);
               for J in 0 .. Nv-1 loop
                  Value := (if Selected.Kind = Discrete then D.Dynamics.Mass (I*Nv+J) + Addition (I*Nv+J)
                    else K.Implicit_Cell (D.Dynamics.Mass (I*Nv+J), Deriv (I*Nv+J), H));
                  if Value not in K.Operand then Result := Numeric_Limit; return; end if;
                  Matrix (I*Nv+J) := Value;
                  Backbone (I*Nv+J) := D.Dynamics.Mass (I*Nv+J)+Backbone (I*Nv+J);
               end loop;
            end loop;
            if Selected.Kind = Implicit_Fast then
               for I in 0 .. Nv-1 loop
                  for J in I+1 .. Nv-1 loop
                     if not (Integration_Operators.Standalone_Free (D,I)
                       and then Integration_Operators.Standalone_Free (D,J)
                       and then D.Joint_Config (I).Body_Id = D.Joint_Config (J).Body_Id) then
                        Matrix (I*Nv+J) := Matrix (J*Nv+I);
                     end if;
                  end loop;
               end loop;
            end if;
            Right := Rate;
            if Selected.Kind = Discrete and then Has_Couplings then
               MJ.Integration_PCG.Solve (Matrix, Backbone, Right, Nv,
                 Selected.Iterations, Selected.Tolerance, Solution, Ok, Converged);
               if Ok then Rate := Solution; end if;
            else
               Solve (Matrix, Rate, Nv, Ok);
            end if;
            if not Ok then Result := Singular_Inertia; return; end if;
            if Selected.Kind = Discrete then
               -- The unsymmetric free-body gyro solve follows the symmetric
               -- global metric solve and overwrites only decoupled body rows.
               for I in 0 .. Integer (Nv)-1 loop
                  if D.Joint_Config (I).Group_Type = 0 and then D.Joint_Config (I).Component = 0
                    and then (for some Row in I .. I+5 =>
                      (for some Col in I .. I+5 => Gyro (Row*Nv+Col) /= 0.0)) then
                     declare
                        Block_Matrix : Real_Array (0 .. 35);
                        Block_Right : Real_Array (0 .. 5);
                     begin
                        for R in 0 .. 5 loop
                           Block_Right (R) := Right (I+R);
                           for C in 0 .. 5 loop
                              Block_Matrix (6*R+C) := (D.Dynamics.Mass ((I+R)*Nv+I+C)
                                + Addition ((I+R)*Nv+I+C))+Gyro ((I+R)*Nv+I+C);
                           end loop;
                        end loop;
                        Solve (Block_Matrix, Block_Right, 6, Ok);
                        if not Ok then Result := Singular_Inertia; return; end if;
                        Rate (I .. I+5) := Block_Right;
                     end;
                  end if;
               end loop;
            end if;
            Activation_Rate := Activation_Rates (D);
            Position_Rate := V0;
            for I in 0 .. Nv-1 loop Position_Rate (I) := K.Advance (V0 (I), Rate (I), H); end loop;
         end if;
         Result := Numeric_Limit;
         for I in 0 .. Nv-1 loop
            Value := K.Advance (V0 (I), Rate (I), H);
            if Value not in Tier0_Real then return; end if;
            V (I) := Value;
         end loop;
         Position_Update (D, Q0, Position_Rate, H, Q, Ok);
         if not Ok then return; end if;
         Next_Act := Act0;
         for A of D.Actuator_Config.all loop
            if A.Activation_Id >= 0 then
               Value := MJ.Activation.Next_Value (A.Kind, Act0 (A.Activation_Id), Activation_Rate (A.Activation_Id), H,
                 A.Tau, A.Factor, A.Activation_Limited, A.Activation_Lower, A.Activation_Upper);
               if Value not in Tier0_Real then return; end if;
               Next_Act (A.Activation_Id) := Value;
            end if;
         end loop;
         D.State.Qpos.all := Q; D.State.Qvel.all := V;
         D.Activation (0 .. Integer (Na)-1) := Next_Act;
         D.Clock := Clock0 + H; Invalidate (D.Cache); Result := Success;
      exception
         when Constraint_Error => Restore; Result := Numeric_Limit;
         when others => Restore; raise;
      end;
   end Step;
end MJ.Data.Integrators;

with MJ.Constraint_Solvers.Cholesky;
with MJ.Data.External_Loads;
with MJ.Smooth_Dynamics;
package body MJ.Data.Constrained.NoSlip with SPARK_Mode is
   package Parent renames MJ.Data.Constrained;
   package NS renames MJ.NoSlip;
   package Linear renames MJ.Constraint_Solvers.Cholesky;
   use type Linear.Status, NS.Status, CA.Constraint_Kind;
   function Ready (E : Engine) return Boolean is (Parent.Ready (E.Base));
   function State (E : Engine) return Real_Array is (Parent.State (E.Base));
   function Complete_State (E : Engine) return Real_Array is (Parent.Complete_State (E.Base));
   function Activation_Count (E : Engine) return Natural is (Parent.Activation_Count (E.Base));
   function Activation_Values (E : Engine) return Real_Array is (Parent.Activation_Values (E.Base));
   function Activation_Rates (E : Engine) return Real_Array is (Parent.Activation_Rates (E.Base));
   function Diagnostics (E : Engine) return Trace is (Parent.Diagnostics (E.Base));
   function NoSlip_Diagnostics (E : Engine) return NS.Report is (E.Report);
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
      Saved : constant Integer := M.Opt.Noslip_Iterations;
   begin
      if Ready (E) then Result := Already_Allocated; return; end if;
      if Saved not in 0 .. 100_000 or else M.Opt.Noslip_Tolerance not in 0.0 .. 1.0e20 then
         Result := Invalid_Model; return;
      end if;
      E.Settings.Iterations := Saved;
      E.Settings.Tolerance := M.Opt.Noslip_Tolerance;
      M.Opt.Noslip_Iterations := 0;
      Parent.Create (M, E.Base, Result);
      M.Opt.Noslip_Iterations := Saved;
      if Result = Success then E.Settings.Scale := E.Base.Settings.Scale; end if;
      E.Report := (others => <>);
   exception
      when others => M.Opt.Noslip_Iterations := Saved; raise;
   end Create;
   procedure Free (E : in out Engine; Result : out Status) is
   begin Parent.Free (E.Base, Result); E.Report := (others => <>); end Free;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Status) is
   begin Parent.Set_State (E.Base, Qpos, Qvel, New_Time, Result); end Set_State;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin Parent.Set_Activation (E.Base, Values, Result); end Set_Activation;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin Parent.Set_Control (E.Base, Index, Value, Result); end Set_Control;
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin Parent.Set_Applied_Force (E.Base, Index, Value, Result); end Set_Applied_Force;

   function Dot4 (A, B : CS.Vector) return Real is
      S0, S1, S2, S3, S : Real := 0.0;
      I : Natural := 1;
   begin
      while I + 3 <= A'Length loop
         S0 := S0 + A (I) * B (I); S1 := S1 + A (I + 1) * B (I + 1);
         S2 := S2 + A (I + 2) * B (I + 2); S3 := S3 + A (I + 3) * B (I + 3);
         I := I + 4;
      end loop;
      S := (S0 + S2) + (S1 + S3);
      case A'Length - (I - 1) is
         when 3 => S := S + (A (I) * B (I) + A (I + 1) * B (I + 1) + A (I + 2) * B (I + 2));
         when 2 => S := S + (A (I) * B (I) + A (I + 1) * B (I + 1));
         when 1 => S := S + A (I) * B (I);
         when others => null;
      end case;
      return S;
   end Dot4;

   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      E.Report := (others => <>);
      Parent.Evaluate (E.Base, Result, External);
      if Result /= Success then return; end if;
      if E.Settings.Iterations = 0 then E.Report.Outcome := NS.Disabled; return; end if;
      if E.Base.T.Nrow = 0 then E.Report.Outcome := NS.Converged; return; end if;
      declare
         Nv : constant Positive := E.Base.D.Nv;
         Nr : constant Positive := E.Base.T.Nrow;
         M, L : CS.Matrix (1 .. Nv, 1 .. Nv);
         J, Inverse_J : CS.Matrix (1 .. Nr, 1 .. Nv);
         AR : CS.Matrix (1 .. Nr, 1 .. Nr);
         B, Force : CS.Vector (1 .. Nr);
         RHS, X, Projected, Acc : CS.Vector (1 .. Nv);
         Smooth_Total : Real_Array (0 .. Nv - 1);
         Rows : NS.Rows (1 .. Nr);
         Linear_Result : Linear.Status;
      begin
         Result := Numeric_Limit;
         --  Rebuild the exact existing smooth RHS, including body loads, rather
         --  than subtracting old constraint forces from a rounded total.
         for V in 1 .. Nv loop
            for W in 1 .. Nv loop M (V, W) := E.Base.D.Dynamics.Mass ((V - 1) * Nv + W - 1); end loop;
            Smooth_Total (V - 1) := MJ.Smooth_Dynamics.Total_Force
              (E.Base.D.Dynamics.Gravity (V - 1), E.Base.D.Dynamics.Bias (V - 1),
               E.Base.D.Dynamics.Passive (V - 1), E.Base.D.Dynamics.Actuator (V - 1), E.Base.D.State.Applied (V - 1));
         end loop;
         MJ.Data.External_Loads.Apply_Buffers
           (E.Base.D.Body_Config.all, E.Base.D.Joint_Config.all, E.Base.D.Kinematic.Bodies.all,
            E.Base.D.Kinematic.Joints.all, External, Smooth_Total, Result);
         if Result /= Success then E.Base.T.Valid := False; return; end if;
         Result := Numeric_Limit;
         Linear.Factor (M, L, Linear_Result);
         if Linear_Result /= Linear.Success then E.Base.T.Valid := False; return; end if;
         for R in 1 .. Nr loop
            for V in 1 .. Nv loop J (R, V) := E.Base.T.J (R, V); RHS (V) := J (R, V); end loop;
            B (R) := Dot4 (RHS, E.Base.T.A_Free (1 .. Nv)) - E.Base.T.Aref (R);
            Linear.Backsolve (L, RHS, X, Linear_Result);
            if Linear_Result /= Linear.Success then E.Base.T.Valid := False; return; end if;
            for V in 1 .. Nv loop Inverse_J (R, V) := X (V); end loop;
            Force (R) := E.Base.T.Force (R);
            Rows (R) := (Form => NS.Kind'Val (CA.Constraint_Kind'Pos (E.Base.Rows.Descriptors (R).Kind)),
              Dimension => 1, R => E.Base.T.R (R), Bound => E.Base.Rows.Descriptors (R).Loss, others => <>);
            if Rows (R).Form in NS.Pyramidal | NS.Elliptic then
               declare
                  C : MJ.Full_Contacts.Full_Contact renames E.Base.Contacts (E.Base.Rows.Descriptors (R).Id);
               begin
                  Rows (R).Dimension := (if R = C.Efc_Address + 1 then C.Dim else 0);
                  Rows (R).Friction := [for T in 1 .. 5 => C.Param.Fri (T - 1)];
               end;
            end if;
         end loop;
         for R in 1 .. Nr loop
            for V in 1 .. Nv loop RHS (V) := J (R, V); end loop;
            for C in 1 .. Nr loop
               for V in 1 .. Nv loop X (V) := Inverse_J (C, V); end loop;
               AR (R, C) := Dot4 (RHS, X);
            end loop;
            AR (R, R) := AR (R, R) + Rows (R).R;
         end loop;
         NS.Solve (AR, B, Rows, E.Settings, Force, E.Report);
         if E.Report.Outcome not in NS.Converged | NS.Iteration_Limit then E.Base.T.Valid := False; return; end if;
         Projected := [others => 0.0];
         for R in 1 .. Nr loop
            for P in E.Base.Rows.Descriptors (R).Offset + 1 ..
              E.Base.Rows.Descriptors (R).Offset + E.Base.Rows.Descriptors (R).Nonzeros loop
               declare V : constant Positive := E.Base.Rows.Columns (P) + 1;
               begin Projected (V) := Projected (V) + E.Base.Rows.Values (P) * Force (R); end;
            end loop;
         end loop;
         Linear.Backsolve (L, Projected, X, Linear_Result);
         if Linear_Result /= Linear.Success then E.Base.T.Valid := False; return; end if;
         for V in 1 .. Nv loop
            Acc (V) := E.Base.T.A_Free (V) + X (V);
            if Acc (V) not in Tier0_Real or else Smooth_Total (V - 1) + Projected (V) not in Tier0_Real then
               E.Base.T.Valid := False; return;
            end if;
         end loop;
         --  Publish only after all values have been admitted.
         for R in 1 .. Nr loop E.Base.T.Force (R) := Force (R); end loop;
         for V in 1 .. Nv loop
            E.Base.T.Constraint_Force (V) := Projected (V);
            E.Base.T.Acceleration (V) := Acc (V);
            E.Base.D.Dynamics.Acceleration (V - 1) := Acc (V);
            E.Base.D.Dynamics.Total (V - 1) := Smooth_Total (V - 1) + Projected (V);
         end loop;
         E.Base.T.Valid := True; Result := Success;
      end;
   exception
      when Constraint_Error => E.Base.T.Valid := False; Result := Numeric_Limit;
   end Evaluate;
   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Evaluate (E, Result, External);
      if Result = Success then Parent.Advance (E.Base, Result); end if;
   end Step;
end MJ.Data.Constrained.NoSlip;

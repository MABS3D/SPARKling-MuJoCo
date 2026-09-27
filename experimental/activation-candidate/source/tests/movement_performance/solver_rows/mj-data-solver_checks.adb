with MJ.Data.Forward;
with MJ.Data.Inertia;

package body MJ.Data.Solver_Checks is
   procedure Check (D : in out Simulation) is
      N : constant Natural := D.Nv;
      Q : constant State_Vector := [for X of D.State.Qpos.all => X];
      V : constant State_Vector := [for X of D.State.Qvel.all => X];
      Before : constant Real_Array := State_Values (D);
      Inputs : constant Real_Array := Input_Values (D);
      T : constant Real := D.Clock;
      Saved_Clamped : constant Dof_Diagnostic := D.First_Clamped;
      Result : Status;
      procedure Require (Condition : Boolean; Context : String) is
      begin
         if not Condition then raise Program_Error with Context; end if;
      end Require;
   begin
      if N < 2 or else D.Solver_Policy /= Compatible then return; end if;
      Forward.Evaluate (D, Result);
      Require (Result = Success, "initial forward");
      --  Reject every position in the first updated factor row, including
      --  SIMD tails. Synthetic bounded symmetric matrices need not be SPD:
      --  they isolate error handling independently of physical assembly.
      for Bad in 0 .. N - 2 loop
         D.Dynamics.Mass.all := [others => 0.0];
         for I in 0 .. N - 2 loop D.Dynamics.Mass (I * N + I) := 1.0; end loop;
         if Bad = N - 2 then
            D.Dynamics.Mass ((N - 1) * N + Bad) := 1.0e40;
            D.Dynamics.Mass (Bad * N + N - 1) := 1.0e40;
         else
            D.Dynamics.Mass ((N - 1) * N + N - 2) := -1.0e-20;
            D.Dynamics.Mass ((N - 2) * N + N - 1) := -1.0e-20;
            D.Dynamics.Mass ((N - 1) * N + Bad) := Work_Limit;
            D.Dynamics.Mass (Bad * N + N - 1) := Work_Limit;
            D.Dynamics.Mass ((N - 2) * N + Bad) := Work_Limit;
            D.Dynamics.Mass (Bad * N + N - 2) := Work_Limit;
         end if;
         D.First_Clamped := -1;
         Require (Is_Ready (D), "bounded synthetic mass rejected by readiness");
         Inertia.Solve_Acceleration (D, Result);
         Require (Result = Numeric_Limit, "bad factor row accepted");
         Require (D.First_Clamped = N - 1, "clamp diagnostic lost on row failure");
         Require (Is_Ready (D) and then not D.Cache.Force_Valid,
           "failed factorization published acceleration");
         Require (State_Values (D) = Before and then Input_Values (D) = Inputs,
           "failed factorization changed physical state or inputs");
         --  Poisoned scratch must be overwritten before it is reused.
         Forward.Evaluate (D, Result);
         Require (Result = Success and then D.First_Clamped = N - 1,
           "retry failed or cleared sticky diagnostic");
         Require (State_Values (D) = Before and then Input_Values (D) = Inputs,
           "retry changed physical state or inputs");
      end loop;
      D.First_Clamped := Saved_Clamped;
      Set_State (D, Q, V, T, Result);
      Require (Result = Success, "restore state after solver checks");
   end Check;
end MJ.Data.Solver_Checks;

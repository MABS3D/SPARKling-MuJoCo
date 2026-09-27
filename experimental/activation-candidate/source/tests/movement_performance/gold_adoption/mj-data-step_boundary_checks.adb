with Ada.Assertions;
with MJ.Data.Euler;
with MJ.Data.Inertia_Phase;

package body MJ.Data.Step_Boundary_Checks is
   procedure Check (D : in out Simulation; Contracts_Enabled : Boolean) is
      Result : Status;
      Empty : Simulation;
      Initial : constant Real_Array := State_Values (D);
      Inputs : constant Real_Array := Input_Values (D);

      procedure Require (Condition : Boolean; Context : String) is
      begin
         if not Condition then raise Program_Error with Context; end if;
      end Require;
   begin
      MJ.Data.Euler.Step (Empty, Result);
      Require (Result = Not_Allocated and then Is_Empty (Empty), "empty step");
      Require (Is_Ready (D), "initial readiness");

      --  This error occurs before evaluation, and must preserve the input state.
      declare
         Saved_Time : constant Nonneg_Tier0 := D.Clock;
         Saved_Step : constant Nonneg_Tier0 := D.Timestep;
      begin
         D.Clock := Max_Val;
         D.Timestep := Max_Val;
         MJ.Data.Euler.Step (D, Result);
         Require (Result = Numeric_Limit and then D.Clock = Max_Val,
                  "step time limit");
         Require (Is_Ready (D) and then Input_Values (D) = Inputs,
                  "time rejection changed inputs or readiness");
         D.Clock := Saved_Time;
         D.Timestep := Saved_Step;
      end;

      --  Direct corruption is outside Valid_State. Only the checked build
      --  invokes Step on it: release callers must satisfy the public contract.
      if Contracts_Enabled and then D.Nv > 0 then
         declare
            Saved : constant Real := D.State.Qvel (0);
            Rejected : Boolean := False;
         begin
            D.State.Qvel (0) := Max_Val * 2.0;
            begin
               MJ.Data.Euler.Step (D, Result);
            exception
               when Ada.Assertions.Assertion_Error => Rejected := True;
            end;
            D.State.Qvel (0) := Saved;
            Require (Rejected, "step accepted an invalid checked input");
         end;
      end if;

      --  Is_Ready permits a current acceleration with an obsolete mass.
      --  Implicit damping must reject that combination before using the mass.
      if (for some J of D.Joint_Config.all => J.Damping > 0.0) then
         declare
            Saved_Cache : constant Cache_Flags := D.Cache;
            Saved_Implicit : constant Boolean := D.Implicit_Damping;
            Saved_Acceleration : constant Real_Array := D.Dynamics.Acceleration.all;
            Saved_Total : constant Real_Array := D.Dynamics.Total.all;
            Saved_Solution : constant Real_Array := D.Scratch.Solution.all;
         begin
            D.Dynamics.Acceleration.all := [others => 0.0];
            D.Dynamics.Total.all := [others => 0.0];
            D.Cache.Force_Valid := True;
            D.Cache.Mass_Valid := False;
            D.Implicit_Damping := True;
            Require (Is_Ready (D), "stale mass fixture is outside the contract");
            Inertia_Phase.Solve_Euler (D, Result);
            Require (Result = Stale_Results, "implicit damping accepted stale mass");
            Require (D.Scratch.Solution.all = Saved_Solution,
                     "stale mass rejection changed solution");
            D.Cache := Saved_Cache;
            D.Implicit_Damping := Saved_Implicit;
            D.Dynamics.Acceleration.all := Saved_Acceleration;
            D.Dynamics.Total.all := Saved_Total;
         end;
      end if;
      Require (Is_Ready (D) and then State_Values (D) = Initial
        and then Input_Values (D) = Inputs, "step boundary checks changed inputs or state");
   end Check;
end MJ.Data.Step_Boundary_Checks;

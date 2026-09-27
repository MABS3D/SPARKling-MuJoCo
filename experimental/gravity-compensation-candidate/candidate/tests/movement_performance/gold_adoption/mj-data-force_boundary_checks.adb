with Ada.Assertions;
with MJ.Data.Forces;
with MJ.Data.Pipeline;

package body MJ.Data.Force_Boundary_Checks is
   procedure Check (D : in out Simulation; Contracts_Enabled : Boolean) is
      Result : Status;
      Empty : Simulation;
      Initial : constant Real_Array := State_Values (D);
      Inputs : constant Real_Array := Input_Values (D);

      procedure Require (Condition : Boolean; Context : String) is
      begin
         if not Condition then raise Program_Error with Context; end if;
      end Require;

      procedure Reject_Invalid (Context : String) is
         Before_State : constant Real_Array := State_Values (D);
         Before_Inputs : constant Real_Array := Input_Values (D);
      begin
         Require (not Is_Ready (D), Context & ": invalid fixture");
         --  Corruption violates the public Valid_State precondition. Checked
         --  builds reject it there; release builds retain the explicit guard.
         begin
            MJ.Data.Forces.Compute (D, Result);
            Require (not Contracts_Enabled, Context & ": precondition not checked");
            Require (Result = Not_Allocated, Context & ": accepted invalid data");
         exception
            when Ada.Assertions.Assertion_Error =>
               Require (Contracts_Enabled, Context & ": unexpected contract check");
         end;
         Require (State_Values (D) = Before_State
           and then Input_Values (D) = Before_Inputs,
           Context & ": changed state or inputs");
      end Reject_Invalid;
   begin
      MJ.Data.Forces.Compute (Empty, Result);
      Require (Result = Not_Allocated and then Is_Empty (Empty), "empty status");
      Require (Is_Ready (D), "initial readiness");
      MJ.Data.Forces.Compute (D, Result);
      Require (Result = Stale_Results, "stale pose status");
      if D.Nv > 0 then
         declare
            Saved : constant Real := D.State.Qvel (0);
         begin
            D.State.Qvel (0) := Max_Val * 2.0;
            Reject_Invalid ("velocity");
            D.State.Qvel (0) := Saved;
         end;
      end if;
      Pipeline.Update_Poses (D, Result);
      Require (Result = Success, "pose setup");
      declare
         Saved : constant Vector := D.Kinematic.Bodies (0).Position;
      begin
         D.Kinematic.Bodies (0).Position := [Work_Limit * 2.0, 0.0, 0.0];
         Reject_Invalid ("published pose cache");
         D.Kinematic.Bodies (0).Position := Saved;
      end;
      declare
         Saved : constant Real := D.Kinematic.Spatial_Inertias (0);
      begin
         D.Kinematic.Spatial_Inertias (0) := 1.0e60;
         D.Cache.Spatial_Valid := True;
         Reject_Invalid ("published spatial cache");
         D.Cache.Spatial_Valid := False;
         D.Kinematic.Spatial_Inertias (0) := Saved;
      end;
      declare
         Saved : constant Vector := D.Body_Config (0).Position;
      begin
         D.Body_Config (0).Position := [Max_Val * 2.0, 0.0, 0.0];
         Reject_Invalid ("configuration");
         D.Body_Config (0).Position := Saved;
      end;
      Require (Is_Ready (D), "restored readiness");
      Require (State_Values (D) = Initial and then Input_Values (D) = Inputs,
               "boundary checks changed state or inputs");
      Invalidate (D.Cache);
   end Check;
end MJ.Data.Force_Boundary_Checks;

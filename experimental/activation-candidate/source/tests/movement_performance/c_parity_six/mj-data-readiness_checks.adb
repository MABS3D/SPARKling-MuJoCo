with MJ.Data.Actuation_Phase;
with MJ.Data.Pipeline;

package body MJ.Data.Readiness_Checks is
   procedure Check (D : in out Simulation) is
      Result : Status;
      Initial : constant Real_Array := State_Values (D);
      Inputs : constant Real_Array := Input_Values (D);
      procedure Require (Condition : Boolean; Context : String) is
      begin
         if not Condition then raise Program_Error with Context; end if;
      end Require;
      procedure Check_Equivalent is
      begin
         Require (Stable_Ready (D), "stable configuration changed");
         Require (Phase_Ready (D) = Is_Ready (D), "phase guard differs from full readiness");
      end Check_Equivalent;
   begin
      Check_Equivalent;
      if D.Nv > 0 then
         declare
            Saved : constant Real := D.State.Qvel (0);
         begin
            D.State.Qvel (0) := Max_Val * 2.0;
            Check_Equivalent;
            Require (not Phase_Ready (D), "invalid mutable input accepted");
            Actuation_Phase.Compute (D, Result);
            Require (Result = Not_Allocated, "phase did not reject invalid input");
            D.State.Qvel (0) := Saved;
         end;
      end if;
      Pipeline.Update_Poses (D, Result);
      Require (Result = Success, "pose setup");
      Check_Equivalent;
      declare
         Saved : constant Vector := D.Kinematic.Bodies (0).Position;
      begin
         D.Kinematic.Bodies (0).Position := [Work_Limit * 2.0, 0.0, 0.0];
         Check_Equivalent;
         Require (not Phase_Ready (D), "invalid published cache accepted");
         Actuation_Phase.Compute (D, Result);
         Require (Result = Not_Allocated, "phase did not reject invalid cache");
         D.Kinematic.Bodies (0).Position := Saved;
      end;
      --  A valid spatial flag may not certify stale/out-of-domain data.
      D.Cache.Spatial_Valid := False;
      D.Kinematic.Spatial_Inertias (0) := 1.0e60;
      Check_Equivalent;
      D.Cache.Spatial_Valid := True;
      Require (not Is_Ready (D), "out-of-domain spatial cache accepted");
      D.Cache.Spatial_Valid := False;
      Check_Equivalent;
      --  Configuration is still checked at the public entry boundary.
      declare
         Saved : constant Vector := D.Body_Config (0).Position;
      begin
         D.Body_Config (0).Position := [Max_Val * 2.0, 0.0, 0.0];
         Require (not Stable_Ready (D) and then not Is_Ready (D),
                  "invalid immutable configuration accepted at full guard");
         D.Body_Config (0).Position := Saved;
      end;
      Check_Equivalent;
      Require (State_Values (D) = Initial and then Input_Values (D) = Inputs,
               "guard checks modified state/inputs");
      Invalidate (D.Cache);
   end Check;
end MJ.Data.Readiness_Checks;

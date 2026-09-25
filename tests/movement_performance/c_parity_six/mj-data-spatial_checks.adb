with MJ.Data.Pipeline;
with MJ.Data.Inertia;
with MJ.Data.Forces;
with MJ.Spatial_Kernels;

package body MJ.Data.Spatial_Checks is
   procedure Check (D : in out Simulation) is
      use type MJ.Spatial_Kernels.Inertia;
      use type MJ.Spatial_Kernels.Motion;
      Initial_Q : constant State_Vector := [for X of D.State.Qpos.all => Tier0_Real (X)];
      Initial_V : constant State_Vector := [for X of D.State.Qvel.all => Tier0_Real (X)];
      Initial_Time : constant Real := Time (D);
      Result : Status;
      procedure Require (Condition : Boolean; Context : String) is
      begin
         if not Condition then raise Program_Error with Context; end if;
      end Require;
      procedure Prepare is
      begin
         Pipeline.Update_Poses (D, Result);
         Require (Result = Success, "spatial check: pose update");
         Inertia.Assemble (D, Result);
         Require (Result = Success, "spatial check: inertia assembly");
      end Prepare;
   begin
      --  The differential suite's 12-DOF serial chain exercises nonzero
      --  cdofdot; independent scalar root bodies would not reach this branch.
      if D.Nv /= 12 then return; end if;
      Prepare;
      Require (D.Cache.Spatial_Valid and then not D.Cache.Cartesian_Motion_Valid,
               "normal path did not prepare shared spatial data lazily");
      Forces.Compute (D, Result);
      Require (Result = Success and then not D.Cache.Cartesian_Motion_Valid,
               "normal RNE materialized redundant Cartesian motion");
      declare
         High_Velocity : State_Vector (0 .. D.Nv - 1) := [others => 1.0e8];
      begin
         Set_State (D, Initial_Q, High_Velocity, Initial_Time, Result);
         Require (Result = Success, "spatial check: high velocity state");
      end;
      Require (not D.Cache.Spatial_Valid and then not D.Cache.Cartesian_Motion_Valid,
               "state change did not invalidate both spatial representations");
      Prepare;
      Require (D.Cache.Spatial_Valid and then not D.Cache.Cartesian_Motion_Valid,
               "RNE-only fallback fixture failed comPos preparation");
      declare
         Before_Bodies : constant Body_State_Array := D.Kinematic.Bodies.all;
         Before_Joints : constant Joint_State_Array := D.Kinematic.Joints.all;
         Before_Mass : constant Real_Array := D.Dynamics.Mass.all;
         Before_Inertias : constant Real_Array := D.Kinematic.Spatial_Inertias.all;
         Before_Motions : constant Real_Array := D.Kinematic.Spatial_Motions.all;
         Before_State : constant Real_Array := State_Values (D);
         Before_Inputs : constant Real_Array := Input_Values (D);
      begin
         Forces.Compute (D, Result);
         Require (Result = Success and then D.Cache.Cartesian_Motion_Valid,
                  "high-velocity RNE did not complete the Cartesian fallback");
         Require (D.Cache.Pose_Valid and then D.Cache.Mass_Valid and then D.Cache.Spatial_Valid,
                  "fallback invalidated reusable pose/mass/spatial data");
         Require (D.Dynamics.Mass.all = Before_Mass and then State_Values (D) = Before_State
           and then Input_Values (D) = Before_Inputs, "fallback changed physical inputs or mass");
         Require (D.Kinematic.Joints.all = Before_Joints, "fallback changed cached joint axes");
         Require (D.Kinematic.Spatial_Inertias.all = Before_Inertias
           and then D.Kinematic.Spatial_Motions.all = Before_Motions, "fallback changed packed spatial data");
         for B in Before_Bodies'Range loop
            Require (D.Kinematic.Bodies (B).Position = Before_Bodies (B).Position
              and then D.Kinematic.Bodies (B).Center = Before_Bodies (B).Center
              and then D.Kinematic.Bodies (B).Orientation = Before_Bodies (B).Orientation
              and then D.Kinematic.Bodies (B).Rotation = Before_Bodies (B).Rotation
              and then D.Kinematic.Bodies (B).Inertial_Rotation = Before_Bodies (B).Inertial_Rotation
,
              "fallback changed published body geometry or inertia");
         end loop;
      end;
      Set_State (D, Initial_Q, Initial_V, Initial_Time, Result);
      Require (Result = Success and then not D.Cache.Spatial_Valid
        and then not D.Cache.Cartesian_Motion_Valid, "retry did not invalidate stale motion");
      Prepare;
      Forces.Compute (D, Result);
      Require (Result = Success and then D.Cache.Spatial_Valid
        and then not D.Cache.Cartesian_Motion_Valid, "normal retry did not return to spatial RNE");
      Invalidate (D.Cache);
   end Check;
end MJ.Data.Spatial_Checks;

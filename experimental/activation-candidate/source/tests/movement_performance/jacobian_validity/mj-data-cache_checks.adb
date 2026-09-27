with MJ.Data.Pipeline;
with MJ.Data.Kinematics;
with MJ.Data.Inertia;
with MJ.Data.Forces;

package body MJ.Data.Cache_Checks is
   procedure Check (D : in out Simulation) is
      Result : Status;
      Q : constant State_Vector := [for I in D.State.Qpos'Range => D.State.Qpos (I)];
      V : constant State_Vector := [for I in D.State.Qvel'Range => D.State.Qvel (I)];
      T : constant Real := D.Clock;
      procedure Require (Condition : Boolean; Context : String) is
      begin
         if not Condition then raise Program_Error with Context; end if;
      end Require;
   begin
      Require (not D.Cache.Jacobian_Valid, "state setter retained Jacobians");
      --  Public API builds the complete representation as before.
      Kinematics.Update (D, Result);
      Require (Result = Success and then D.Cache.Jacobian_Valid, "public kinematics");
      declare
         Linear : constant Real_Array := D.Kinematic.Linear_Jacobian.all;
         Angular : constant Real_Array := D.Kinematic.Angular_Jacobian.all;
      begin
         --  Control/applied-force changes do not change the kinematic state.
         if D.Nu > 0 then
            Set_Control (D, 0, D.State.Ctrl (0), Result);
            Require (Result = Success and then D.Cache.Jacobian_Valid, "control invalidation");
         end if;
         if D.Nv > 0 then
            Set_Applied_Force (D, 0, D.State.Applied (0), Result);
            Require (Result = Success and then D.Cache.Jacobian_Valid, "force invalidation");
         end if;
         --  Retry is idempotent; the bounded arrays remain intact.
         Pipeline.Ensure_Jacobians (D, Result);
         Require (Result = Success and then D.Kinematic.Linear_Jacobian.all = Linear
           and then D.Kinematic.Angular_Jacobian.all = Angular, "materialized retry");
         Inertia.Assemble (D, Result);
         Require (Result = Success, "eager mass");
         Forces.Compute (D, Result);
         Require (Result = Success, "eager forces");
         declare
            Mass : constant Real_Array := D.Dynamics.Mass.all;
            Gravity : constant Real_Array := D.Dynamics.Gravity.all;
            Bias : constant Real_Array := D.Dynamics.Bias.all;
            Passive : constant Real_Array := D.Dynamics.Passive.all;
         begin
            --  Mark deliberately out-of-work storage stale. The ordinary
            --  pipeline must never consume it before complete materialization.
            D.Cache.Jacobian_Valid := False;
            D.Kinematic.Linear_Jacobian.all := [others => 1.0e100];
            D.Kinematic.Angular_Jacobian.all := [others => -1.0e100];
            Require (Is_Ready (D), "stale storage was scanned");
            D.Cache.Jacobian_Valid := True;
            if D.Kinematic.Linear_Jacobian'Length > 0 then
               Require (not Is_Ready (D), "materialized invalid storage accepted");
            end if;
            D.Cache.Jacobian_Valid := False;
            Pipeline.Update_Poses (D, Result);
            Require (Result = Success and then not D.Cache.Jacobian_Valid, "deferred poses");
            Require ((for all X of D.Kinematic.Linear_Jacobian.all => X = 1.0e100)
              and then (for all X of D.Kinematic.Angular_Jacobian.all => X = -1.0e100),
              "pose update still clears unused storage");
            Require (Is_Ready (D), "deferred bounds");
            --  Exercise both consumers, including a second fallback reusing the cache.
            Inertia.Assemble (D, Result);
            Require (Result = Success and then D.Dynamics.Mass.all = Mass, "lazy mass");
            Forces.Compute (D, Result);
            Require (Result = Success and then D.Dynamics.Gravity.all = Gravity
              and then D.Dynamics.Bias.all = Bias and then D.Dynamics.Passive.all = Passive,
              "lazy forces");
            Pipeline.Ensure_Jacobians (D, Result);
            Require (Result = Success and then D.Kinematic.Linear_Jacobian.all = Linear
              and then D.Kinematic.Angular_Jacobian.all = Angular, "lazy materialization");
            Require (D.Cache.Mass_Valid and then D.Cache.Passive_Valid,
              "materialization changed other caches");
         end;
      end;
      --  Force a bounded pose whose hinge Jacobian exceeds the work domain.
      --  A failed rebuild must not publish partial results; retry uses fresh poses.
      for J in 0 .. D.Nj - 1 loop
         if D.Joint_Config (J).Kind = Hinge_Joint then
            D.Cache.Jacobian_Valid := False;
            D.Kinematic.Bodies (D.Joint_Config (J).Body_Id).Center := [Work_Limit, 0.0, 0.0];
            D.Kinematic.Joints (J).Anchor := [-Work_Limit, 0.0, 0.0];
            D.Kinematic.Joints (J).Direction := [0.0, 1.0, 0.0];
            Require (Is_Ready (D), "bounded failure fixture");
            Pipeline.Ensure_Jacobians (D, Result);
            Require (Result = Numeric_Limit and then not D.Cache.Jacobian_Valid
              and then Is_Ready (D), "failed rebuild published partial Jacobians");
            Require (D.Cache.Mass_Valid and then D.Cache.Passive_Valid,
              "failed rebuild changed other caches");
            Kinematics.Update (D, Result);
            Require (Result = Success and then D.Cache.Jacobian_Valid, "failed rebuild retry");
            exit;
         end if;
      end loop;
      Require (D.State.Qpos.all = Real_Array'[for X of Q => X] and then D.State.Qvel.all = Real_Array'[for X of V => X]
        and then D.Clock = T, "cache checks changed physical state");
      Set_State (D, Q, V, T, Result);
      D.Cache.Jacobian_Valid := True;
      Require (not Is_Ready (D), "Jacobian flag without poses accepted");
      D.Cache.Jacobian_Valid := False;
      Require (Result = Success and then not D.Cache.Jacobian_Valid
        and then not D.Cache.Pose_Valid, "state invalidation");
   end Check;
end MJ.Data.Cache_Checks;

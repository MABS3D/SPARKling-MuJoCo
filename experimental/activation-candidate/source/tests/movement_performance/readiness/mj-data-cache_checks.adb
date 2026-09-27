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
            Pipeline.Update_Poses (D, Result);
            Require (Result = Success and then not D.Cache.Jacobian_Valid, "deferred poses");
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
      Require (D.State.Qpos.all = Real_Array'[for X of Q => X] and then D.State.Qvel.all = Real_Array'[for X of V => X]
        and then D.Clock = T, "cache checks changed physical state");
      Set_State (D, Q, V, T, Result);
      Require (Result = Success and then not D.Cache.Jacobian_Valid
        and then not D.Cache.Pose_Valid, "state invalidation");
   end Check;
end MJ.Data.Cache_Checks;

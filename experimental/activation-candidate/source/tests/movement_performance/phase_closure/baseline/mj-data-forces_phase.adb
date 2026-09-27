with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;
with MJ.Data.Pipeline;
with MJ.Data.Spatial;
with MJ.Spatial_Dynamics;
with MJ.Smooth_Topology;

package body MJ.Data.Forces_Phase with SPARK_Mode is
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   --  Scalar-joint comVel and RNE. All vectors share the root subtree COM
   --  frame prepared for CRB; no repeated inertia rotation or wrench shifting.
   procedure Try_Recursive
     (D : Simulation; Gravity_Out, Bias_Out : out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid and then D.Cache.Spatial_Valid
       and then Gravity_Out'First = 0 and then Gravity_Out'Last = D.Nv - 1
       and then Bias_Out'First = 0 and then Bias_Out'Last = D.Nv - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
       and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
   is
      package SK renames MJ.Spatial_Kernels;
      package SD renames MJ.Spatial_Dynamics;
      package T renames MJ.Smooth_Topology;
      type Motion_Array is array (Natural range <>) of SK.Motion;
      Velocity, Acceleration : Motion_Array (0 .. D.Nb - 1) with Relaxed_Initialization;
      Bias, Gravity : Motion_Array (0 .. D.Nb - 1) with Relaxed_Initialization;
   begin
      Ok := False;
      Gravity_Out := [others => 0.0];
      Bias_Out := [others => 0.0];
      Velocity (0) := [others => 0.0];
      Acceleration (0) := [others => 0.0];
      Bias (0) := [others => 0.0];
      Gravity (0) := [others => 0.0];
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (for all K in 0 .. B - 1 => Velocity (K)'Initialized
           and then Acceleration (K)'Initialized and then Bias (K)'Initialized
           and then Gravity (K)'Initialized);
         pragma Loop_Invariant (for all K in 0 .. B - 1 => SK.Bounded (Velocity (K), 1.0e12)
           and then SK.Bounded (Acceleration (K), 1.0e12)
           and then SK.Bounded (Bias (K), 1.0e54) and then SK.Bounded (Gravity (K), 1.0e54));
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            Vel : SK.Motion := Velocity (C.Parent);
            Delta_Acc : SK.Motion := [others => 0.0];
            Acc, Rate, Candidate : SK.Motion;
         begin
            --  cdofdot uses the velocity before adding the current scalar DOF,
            --  exactly as mj_comVel; the self cross product need not be formed.
            for K in 0 .. C.Joint_Count - 1 loop
               pragma Loop_Invariant (SK.Bounded (Vel, 1.0e12) and then SK.Bounded (Delta_Acc, 1.0e12));
               declare
                  J : constant Natural := C.First_Joint + K;
                  V : constant Natural := D.Joint_Config (J).Vadr;
                  Axis : constant SK.Motion := MJ.Spatial_Storage.Load_Motion (D.Kinematic.Spatial_Motions.all, 6 * J);
               begin
                  Rate := SD.Cross_Motion (Vel, Axis);
                  Candidate := SD.Add_Scaled (Vel, Axis, D.State.Qvel (V));
                  if not SK.Bounded (Candidate, 1.0e12) then return; end if;
                  Vel := Candidate;
                  Candidate := SD.Add_Scaled (Delta_Acc, Rate, D.State.Qvel (V));
                  if not SK.Bounded (Candidate, 1.0e12) then return; end if;
                  Delta_Acc := Candidate;
               end;
            end loop;
            Acc := SK.Add_Wrenches (Acceleration (C.Parent), Delta_Acc);
            if not SK.Bounded (Acc, 1.0e12) then return; end if;
            Velocity (B) := Vel;
            Acceleration (B) := Acc;
            declare
               I : constant SK.Inertia := MJ.Spatial_Storage.Load_Inertia (D.Kinematic.Spatial_Inertias.all, 10 * B);
               Inertial : constant SK.Motion := SK.Multiply (I, Acc);
               Momentum : constant SK.Motion := SK.Multiply (I, Vel);
               Gyroscopic : constant SK.Motion := SD.Cross_Force (Vel, Momentum);
            begin
               if not SK.Bounded (Gyroscopic, 1.0e54) then return; end if;
               Candidate := SK.Add_Wrenches (Inertial, Gyroscopic);
               if not SK.Bounded (Candidate, 1.0e54) then return; end if;
               Bias (B) := Candidate;
               Gravity (B) := (if D.Gravity_Enabled then SD.Gravity_Force
                 (I (6), I (7), I (8), I (9), D.Gravity (0), D.Gravity (1), D.Gravity (2))
                 else [others => 0.0]);
            end;
         end;
      end loop;
      for B in reverse 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (for all K in Bias'Range => SK.Bounded (Bias (K), 1.0e54)
           and then SK.Bounded (Gravity (K), 1.0e54));
         declare
            P : constant Natural := D.Body_Config (B).Parent;
            Sum : SK.Motion;
         begin
            if P > 0 then
               Sum := SK.Add_Wrenches (Bias (P), Bias (B));
               if not SK.Bounded (Sum, 1.0e54) then return; end if;
               Bias (P) := Sum;
               Sum := SK.Add_Wrenches (Gravity (P), Gravity (B));
               if not SK.Bounded (Sum, 1.0e54) then return; end if;
               Gravity (P) := Sum;
            end if;
         end;
      end loop;
      for V in 0 .. D.Nv - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
           and then MJ.Smooth_Dynamics.Work_Array (Bias_Out));
         declare
            Axis : constant SK.Motion := MJ.Spatial_Storage.Load_Motion (D.Kinematic.Spatial_Motions.all, 6 * T.Dof_Joint (D.Topology, V));
            Body_Id : constant Natural := T.Dof_Body (D.Topology, V);
            G : constant Real := SK.Dot (Axis, Gravity (Body_Id));
            B : constant Real := SK.Dot (Axis, Bias (Body_Id));
         begin
            if not Within_Work (G) or else not Within_Work (B) then return; end if;
            Gravity_Out (V) := G;
            Bias_Out (V) := B;
         end;
      end loop;
      Ok := True;
   end Try_Recursive;

   procedure Compute (D : in out Simulation; Result : out Status) is
      Nv : constant Natural := D.Nv;
      Used_Recursive : Boolean := False;
      Spatial_Ok : Boolean;
   begin
      if not Phase_Ready (D) then
         Result := Not_Allocated;
         pragma Assert (Static => Stable_Ready (D));
         return;
      elsif not D.Cache.Pose_Valid then
         Result := Stale_Results;
         pragma Assert (Static => Stable_Ready (D));
         return;
      end if;
      D.Cache.Passive_Valid := False;
      D.Cache.Force_Valid := False;
      D.Dynamics.Gravity.all := [others => 0.0];
      D.Dynamics.Bias.all := [others => 0.0];
      D.Dynamics.Passive.all := [others => 0.0];
      Result := Numeric_Limit;

      if D.Nv >= 3 then
         declare
            Gravity, Bias : Real_Array (0 .. Nv - 1);
         begin
            Spatial.Prepare (D, Spatial_Ok);
            if Spatial_Ok then Try_Recursive (D, Gravity, Bias, Used_Recursive); end if;
            if Used_Recursive then
               D.Dynamics.Gravity.all := Gravity;
               D.Dynamics.Bias.all := Bias;
            end if;
         end;
      end if;
      if not Used_Recursive then
         Pipeline.Ensure_Cartesian_Motion (D, Result);
         if Result /= Success then
            pragma Assert (Static => Stable_Ready (D));
            return;
         end if;
         Pipeline.Ensure_Jacobians (D, Result);
         if Result /= Success then
            pragma Assert (Static => Stable_Ready (D));
            return;
         end if;
         Prove_Jacobian_Readiness (D);
         Result := Numeric_Limit;
         D.Dynamics.Gravity.all := [others => 0.0];
         D.Dynamics.Bias.all := [others => 0.0];

         for B in 1 .. D.Nb - 1 loop
            declare
               C : constant Body_Parameters := D.Body_Config (B);
               S : constant Body_State := D.Kinematic.Bodies (B);
               Offset : constant Vector := Apply (S.Rotation, C.Inertial_Position);
               Acceleration : constant Vector := S.Linear_Bias
                 + Cross (S.Angular_Bias, Offset)
                 + Cross (S.Angular_Velocity, Cross (S.Angular_Velocity, Offset));
               Force : constant Vector := C.Mass * Acceleration;
               Momentum : constant Vector := Inertia_Times
                 (S.Inertial_Rotation, C.Inertia, S.Angular_Velocity);
               Torque : constant Vector := Inertia_Times
                 (S.Inertial_Rotation, C.Inertia, S.Angular_Bias)
                 + Cross (S.Angular_Velocity, Momentum);
               Gravity : constant Vector := (if D.Gravity_Enabled then C.Mass * D.Gravity else Zero);
            begin
               if not Bounded (Force) or else not Bounded (Torque) or else not Bounded (Gravity) then
                  pragma Assert (Static => Stable_Ready (D));
                  return;
               end if;
               --  Virtual work at each COM: Jv' f + Jw' tau. The body recursion
               --  supplied qacc=0 accelerations, including centripetal/Coriolis
               --  terms; no finite differencing of the mass matrix is needed.
               for I in 0 .. D.Nv - 1 loop
                  declare
                     Base : constant Natural := Jacobian_Offset (D, B, I);
                     Linear : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, Base);
                     Angular : constant Vector := Read_Vector (D.Kinematic.Angular_Jacobian.all, Base);
                     G : constant Real := MJ.Smooth_Dynamics.Gravity_Contribution
                       (D.Dynamics.Gravity (I), Linear, Gravity);
                     Bias : constant Real := MJ.Smooth_Dynamics.Bias_Contribution
                       (D.Dynamics.Bias (I), Linear, Force, Angular, Torque);
                  begin
                     if not Within_Work (G) or else not Within_Work (Bias) then
                        pragma Assert (Static => Stable_Ready (D));
                        return;
                     end if;
                     D.Dynamics.Gravity (I) := G;
                     D.Dynamics.Bias (I) := Bias;
                  end;
               end loop;
            end;
         end loop;

      end if;

      for J in 0 .. D.Nj - 1 loop
         declare
            C : constant Joint_Parameters := D.Joint_Config (J);
            Value : constant Real := MJ.Smooth_Kernels.Passive_Force
              (D.State.Qpos (C.Qadr), C.Spring_Reference, D.State.Qvel (C.Vadr),
               C.Stiffness, C.Damping, D.Spring_Enabled, D.Damper_Enabled);
         begin
            if not Within_Work (Value) then
               pragma Assert (Static => Stable_Ready (D));
               return;
            end if;
            D.Dynamics.Passive (C.Vadr) := Value;
         end;
      end loop;
      D.Cache.Passive_Valid := True;
      Result := Success;
      pragma Assert (Static => Stable_Ready (D));
   end Compute;
end MJ.Data.Forces_Phase;

with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;

package body MJ.Data.Forces with SPARK_Mode is
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   --  Accumulate separate gravity/bias wrenches in a common root frame,
   --  preserving the public distinction between the two force arrays.
   procedure Try_Recursive
     (D : Simulation; Gravity_Out, Bias_Out : out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid
       and then Gravity_Out'First = 0 and then Gravity_Out'Last = D.Nv - 1
       and then Bias_Out'First = 0 and then Bias_Out'Last = D.Nv - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
       and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
   is
      package SK renames MJ.Spatial_Kernels;
      type Motion_Array is array (Natural range <>) of SK.Motion;
      type Index_Array is array (Natural range <>) of Natural;
      Bias, Gravity : Motion_Array (0 .. D.Nb - 1) := [others => [others => 0.0]];
      Root : Index_Array (0 .. D.Nb - 1) := [others => 0];
   begin
      Ok := False;
      Gravity_Out := [others => 0.0];
      Bias_Out := [others => 0.0];
      for B in 1 .. D.Nb - 1 loop
         if not Bounded (D.Kinematic.Bodies (B).Center, Max_Val) then return; end if;
         Root (B) := (if D.Body_Config (B).Parent = 0 then B else Root (D.Body_Config (B).Parent));
         pragma Loop_Invariant (for all K in Root'Range => Root (K) < D.Nb);
         pragma Loop_Invariant (for all K in 1 .. B => Root (K) in 1 .. K
           and then Bounded (D.Kinematic.Bodies (K).Center, Max_Val));
      end loop;
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (for all K in Bias'Range => SK.Bounded (Bias (K), 1.0e54)
           and then SK.Bounded (Gravity (K), 1.0e54));
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            S : constant Body_State := D.Kinematic.Bodies (B);
            Offset : constant Vector := MJ.Smooth_Dynamics.Apply_Config (S.Rotation, C.Inertial_Position);
            Acceleration : constant Vector := MJ.Smooth_Dynamics.Center_Acceleration
              (S.Linear_Bias, S.Angular_Bias, S.Angular_Velocity, Offset);
            Force : constant Vector := MJ.Smooth_Dynamics.Mass_Force (C.Mass, Acceleration);
            Torque : constant Vector := MJ.Smooth_Dynamics.Inertial_Torque
              (S.Inertial_Rotation, C.Inertia, S.Angular_Bias, S.Angular_Velocity);
            G : constant Vector := (if D.Gravity_Enabled then C.Mass * D.Gravity else Zero);
            Arm : constant Vector := SK.Frame_Offset (S.Center, D.Kinematic.Bodies (Root (B)).Center);
         begin
            if not Bounded (Force, 1.0e40) or else not Bounded (Torque, 1.0e40)
              or else not Bounded (G, 1.0e40) then return; end if;
            Bias (B) := SK.Wrench (Force, Torque, Arm);
            Gravity (B) := SK.Wrench (G, Zero, Arm);
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
      for J in 0 .. D.Nj - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
           and then MJ.Smooth_Dynamics.Work_Array (Bias_Out));
         declare
            C : constant Joint_Parameters := D.Joint_Config (J);
            Pose : constant Joint_State := D.Kinematic.Joints (J);
            Axis : SK.Motion;
            G, B : Real;
         begin
            if not Bounded (Pose.Anchor, Max_Val) then return; end if;
            Axis := SK.Joint_Motion (Pose.Direction,
              SK.Frame_Offset (D.Kinematic.Bodies (Root (C.Body_Id)).Center, Pose.Anchor), C.Kind = Hinge_Joint);
            G := SK.Dot (Axis, Gravity (C.Body_Id));
            B := SK.Dot (Axis, Bias (C.Body_Id));
            if not Within_Work (G) or else not Within_Work (B) then return; end if;
            Gravity_Out (C.Vadr) := G;
            Bias_Out (C.Vadr) := B;
         end;
      end loop;
      Ok := True;
   end Try_Recursive;

   procedure Compute (D : in out Simulation; Result : out Status) is
      Used_Recursive : Boolean := False;
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      elsif not D.Cache.Pose_Valid then
         Result := Stale_Results;
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
            Gravity, Bias : Real_Array (0 .. D.Nv - 1);
         begin
            Try_Recursive (D, Gravity, Bias, Used_Recursive);
            if Used_Recursive then
               D.Dynamics.Gravity.all := Gravity;
               D.Dynamics.Bias.all := Bias;
            end if;
         end;
      end if;
      if not Used_Recursive then
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
               return;
            end if;
            D.Dynamics.Passive (C.Vadr) := Value;
         end;
      end loop;
      D.Cache.Passive_Valid := True;
      Result := Success;
   end Compute;
end MJ.Data.Forces;

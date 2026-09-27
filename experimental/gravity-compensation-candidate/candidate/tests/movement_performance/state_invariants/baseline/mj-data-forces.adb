with MJ.Smooth_Dynamics;

package body MJ.Data.Forces with SPARK_Mode is
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   procedure Compute (D : in out Simulation; Result : out Status) is
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

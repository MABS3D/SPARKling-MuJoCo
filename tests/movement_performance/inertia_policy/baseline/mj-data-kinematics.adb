with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;

package body MJ.Data.Kinematics with SPARK_Mode is
   function Motion_Bounded (S : Body_State) return Boolean is
     (Bounded (S.Position) and then Bounded (S.Center)
      and then Bounded (S.Linear_Velocity) and then Bounded (S.Angular_Velocity)
      and then Bounded (S.Linear_Bias) and then Bounded (S.Angular_Bias));

   procedure Fixed_Frame (P : Body_State; C : Body_Parameters; S : out Body_State; Ok : out Boolean)
     with Global => null,
     Pre => Body_Bounded (P) and then Bounded (C.Position, Max_Val)
       and then Unit_Quaternion (C.Orientation),
     Post => (if Ok then Body_Bounded (S)
       and then S.Position = P.Position + Apply_Config (P.Rotation, C.Position)
       and then S.Angular_Velocity = P.Angular_Velocity and then S.Angular_Bias = P.Angular_Bias
       and then S.Linear_Velocity = P.Linear_Velocity
         + Cross_Local (P.Angular_Velocity, Apply_Config (P.Rotation, C.Position))
       and then S.Linear_Bias = P.Linear_Bias + Cross_Local (P.Angular_Bias, Apply_Config (P.Rotation, C.Position))
         + Cross_Transport (P.Angular_Velocity, Cross_Local (P.Angular_Velocity, Apply_Config (P.Rotation, C.Position)))
       and then S.Rotation = Rotation (S.Orientation))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      R : constant Vector := Apply_Config (P.Rotation, C.Position);
      Normal : Boolean;
   begin
      Quaternion_Bounds (P.Orientation);
      Quaternion_Bounds (C.Orientation);
      S := (others => <>);
      Ok := False;
      S.Position := P.Position + R;
      S.Orientation := Multiply (P.Orientation, C.Orientation);
      Normalize (S.Orientation, Normal);
      if not Normal then return; end if;
      S.Rotation := Rotation (S.Orientation);
      S.Angular_Velocity := P.Angular_Velocity;
      S.Angular_Bias := P.Angular_Bias;
      S.Linear_Velocity := P.Linear_Velocity + Cross_Local (P.Angular_Velocity, R);
      S.Linear_Bias := P.Linear_Bias + Cross_Local (P.Angular_Bias, R)
        + Cross_Transport (P.Angular_Velocity, Cross_Local (P.Angular_Velocity, R));
      Ok := Motion_Bounded (S);
   end Fixed_Frame;

   procedure Update (D : in out Simulation; Result : out Status) is
      Normal : Boolean;
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      Invalidate (D.Cache);
      Result := Numeric_Limit;
      D.Kinematic.Bodies (0) := (others => <>);
      D.Kinematic.Linear_Jacobian.all := [others => 0.0];
      D.Kinematic.Angular_Jacobian.all := [others => 0.0];

      --  Parents precede children. Apply every scalar joint in body order,
      --  treating intermediate frames as massless; inertia belongs to the
      --  final body frame. This also supports multiple joints on one body.
      for B in 1 .. D.Nb - 1 loop
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            P : constant Body_State := D.Kinematic.Bodies (C.Parent);
            S : Body_State;
            IQ : Quaternion;
         begin
            Fixed_Frame (P, C, S, Normal);
            if not Normal then return; end if;

            for Offset in 0 .. C.Joint_Count - 1 loop
               declare
                  J : constant Natural := C.First_Joint + Offset;
                  Joint : constant Joint_Parameters := D.Joint_Config (J);
                  Q : constant Real := D.State.Qpos (Joint.Qadr) - Joint.Reference;
                  Qd : constant Real := D.State.Qvel (Joint.Vadr);
                  Direction : constant Vector := Apply (S.Rotation, Joint.Direction);
                  Anchor_Offset : constant Vector := Apply (S.Rotation, Joint.Anchor);
                  Anchor : constant Vector := S.Position + Anchor_Offset;
               begin
                  D.Kinematic.Joints (J) := (Anchor => Anchor, Direction => Direction);
                  if Joint.Kind = Slide_Joint then
                     declare
                        Shift : constant Vector := Q * Direction;
                     begin
                        S.Position := S.Position + Shift;
                        S.Linear_Velocity := S.Linear_Velocity
                          + Cross (S.Angular_Velocity, Shift) + Qd * Direction;
                        S.Linear_Bias := S.Linear_Bias + Cross (S.Angular_Bias, Shift)
                          + Cross (S.Angular_Velocity, Cross (S.Angular_Velocity, Shift))
                          + (2.0 * Qd) * Cross (S.Angular_Velocity, Direction);
                     end;
                  else
                     declare
                        Anchor_Velocity : constant Vector := S.Linear_Velocity
                          + Cross (S.Angular_Velocity, Anchor_Offset);
                        Anchor_Acceleration : constant Vector := S.Linear_Bias
                          + Cross (S.Angular_Bias, Anchor_Offset)
                          + Cross (S.Angular_Velocity, Cross (S.Angular_Velocity, Anchor_Offset));
                        New_Offset : Vector;
                     begin
                        --  alpha(qacc=0) includes the derivative of the moving axis.
                        S.Angular_Bias := S.Angular_Bias
                          + Qd * Cross (S.Angular_Velocity, Direction);
                        S.Angular_Velocity := S.Angular_Velocity + Qd * Direction;
                        S.Orientation := Multiply
                          (S.Orientation, Axis_Angle (Joint.Direction, Q));
                        Normalize (S.Orientation, Normal);
                        if not Normal then
                           return;
                        end if;
                        S.Rotation := Rotation (S.Orientation);
                        New_Offset := Apply (S.Rotation, Joint.Anchor);
                        S.Position := Anchor - New_Offset;
                        S.Linear_Velocity := Anchor_Velocity
                          - Cross (S.Angular_Velocity, New_Offset);
                        S.Linear_Bias := Anchor_Acceleration
                          - Cross (S.Angular_Bias, New_Offset)
                          - Cross (S.Angular_Velocity, Cross (S.Angular_Velocity, New_Offset));
                     end;
                  end if;
                  if not Motion_Bounded (S) or else not Bounded (Anchor)
                    or else not Bounded (Direction, 1.00001)
                  then
                     return;
                  end if;
               end;
            end loop;

            S.Center := S.Position + Apply (S.Rotation, C.Inertial_Position);
            IQ := Multiply (S.Orientation, C.Inertial_Orientation);
            Normalize (IQ, Normal);
            if not Normal or else not Motion_Bounded (S) then
               return;
            end if;
            S.Inertial_Rotation := Rotation (IQ);
            D.Kinematic.Bodies (B) := S;
         end;
      end loop;

      --  Jv/Jw refer to the inertial COM, not the body origin. A joint affects
      --  its own body and descendants; unrelated tree columns stay zero.
      for B in 1 .. D.Nb - 1 loop
         declare
            Ancestor : Natural := B;
         begin
            while Ancestor > 0 loop
               pragma Loop_Variant (Decreases => Ancestor);
               declare
                  C : constant Body_Parameters := D.Body_Config (Ancestor);
               begin
                  for Offset in 0 .. C.Joint_Count - 1 loop
                     declare
                        J : constant Natural := C.First_Joint + Offset;
                        Joint : constant Joint_Parameters := D.Joint_Config (J);
                        Pose : constant Joint_State := D.Kinematic.Joints (J);
                        Base : constant Natural := Jacobian_Offset (D, B, Joint.Vadr);
                        Linear, Angular : Vector;
                     begin
                        if Joint.Kind = Hinge_Joint then
                           Angular := Pose.Direction;
                           Linear := Cross (Pose.Direction, D.Kinematic.Bodies (B).Center - Pose.Anchor);
                        else
                           Angular := Zero;
                           Linear := Pose.Direction;
                        end if;
                        if not Bounded (Linear) or else not Bounded (Angular) then
                           return;
                        end if;
                        Write_Vector (D.Kinematic.Linear_Jacobian.all, Base, Linear);
                        Write_Vector (D.Kinematic.Angular_Jacobian.all, Base, Angular);
                     end;
                  end loop;
                  Ancestor := C.Parent;
               end;
            end loop;
         end;
      end loop;
      D.Cache.Pose_Valid := True;
      Result := Success;
   end Update;
end MJ.Data.Kinematics;

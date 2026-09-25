with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;
with MJ.Data.Inertia_Phase;
with MJ.Data.Forces_Phase;
with MJ.Data.Actuation_Phase;
with MJ.Data.Jacobians;

package body MJ.Data.Pipeline with SPARK_Mode is
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
   pragma Unevaluated_Use_Of_Old (Allow);
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

   procedure Widen_Rotation_Bounds (R : Matrix) with Ghost => Static,
     Global => null, Pre => Bounded (R, 8.0), Post => Bounded (R, 16.0)
   is
   begin
      null;
   end Widen_Rotation_Bounds;

   procedure Fixed_Position (P : Body_State; C : Body_Parameters; S : out Body_State; Ok : out Boolean)
     with Global => null,
     Pre => Body_Bounded (P) and then Bounded (C.Position, Max_Val)
       and then Unit_Quaternion (C.Orientation),
     Post => (if Ok then Body_Bounded (S)
       and then S.Position = P.Position + Apply_Config (P.Rotation, C.Position)
       and then S.Rotation = Rotation (S.Orientation)
       and then S.Linear_Velocity = Zero and then S.Angular_Velocity = Zero
       and then S.Linear_Bias = Zero and then S.Angular_Bias = Zero)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      R : constant Vector := Apply_Config (P.Rotation, C.Position);
      Normal : Boolean;
   begin
      Quaternion_Bounds (P.Orientation);
      Quaternion_Bounds (C.Orientation);
      S := (others => <>);
      pragma Assert (Static => Bounded (S.Inertial_Rotation, 16.0));
      Ok := False;
      S.Position := P.Position + R;
      S.Orientation := Multiply (P.Orientation, C.Orientation);
      Normalize (S.Orientation, Normal);
      if not Normal then return; end if;
      --  Retain the complete geometric state, discarding normalization's
      --  internal scaled-norm arithmetic from the remaining obligations.
      pragma Assert_And_Cut (Static => Bounded (P.Position)
        and then Bounded (P.Rotation, 16.0)
        and then Bounded (C.Position, Max_Val)
        and then Unit_Quaternion (S.Orientation)
        and then S.Position = P.Position + Apply_Config (P.Rotation, C.Position)
        and then S.Center = Zero and then Bounded (S.Inertial_Rotation, 16.0)
        and then S.Linear_Velocity = Zero and then S.Angular_Velocity = Zero
        and then S.Linear_Bias = Zero and then S.Angular_Bias = Zero);
      S.Rotation := Rotation (S.Orientation);
      Widen_Rotation_Bounds (S.Rotation);
      Ok := Motion_Bounded (S);
   end Fixed_Position;

   procedure Build_Bodies
     (Body_Config : Body_Parameter_Array; Joint_Config : Joint_Parameter_Array;
      Qpos, Qvel : Real_Array; With_Motion : Boolean;
      Bodies : in out Body_State_Array; Joints : in out Joint_State_Array; Result : out Status)
     with Global => null,
     Post => Bodies'First = Bodies'First'Old and then Bodies'Last = Bodies'Last'Old
       and then Joints'First = Joints'First'Old and then Joints'Last = Joints'Last'Old
   is
      Normal : Boolean;
   begin
      Result := Numeric_Limit;
      Bodies (0) := (others => <>);
      --  This builder leaves Jacobians untouched. Its caller controls cache
      --  publication, including temporary Cartesian fallback construction.

      --  Parents precede children. Apply every scalar joint in body order,
      --  treating intermediate frames as massless; inertia belongs to the
      --  final body frame. This also supports multiple joints on one body.
      for B in 1 .. Bodies'Last loop
         declare
            C : constant Body_Parameters := Body_Config (B);
            P : constant Body_State := Bodies (C.Parent);
            S : Body_State;
            IQ : Quaternion;
         begin
            if With_Motion then Fixed_Frame (P, C, S, Normal);
            else Fixed_Position (P, C, S, Normal); end if;
            if not Normal then return; end if;

            for Offset in 0 .. C.Joint_Count - 1 loop
               declare
                  J : constant Natural := C.First_Joint + Offset;
                  Joint : constant Joint_Parameters := Joint_Config (J);
                  Q : constant Real := Qpos (Joint.Qadr) - Joint.Reference;
                  Qd : constant Real := Qvel (Joint.Vadr);
                  Direction : constant Vector := Apply (S.Rotation, Joint.Direction);
                  Anchor_Offset : constant Vector := Apply (S.Rotation, Joint.Anchor);
                  Anchor : constant Vector := S.Position + Anchor_Offset;
               begin
                  Joints (J) := (Anchor => Anchor, Direction => Direction, others => <>);
                  if Joint.Kind = Slide_Joint then
                     declare
                        Shift : constant Vector := Q * Direction;
                     begin
                        S.Position := S.Position + Shift;
                        if With_Motion then
                        S.Linear_Velocity := S.Linear_Velocity
                          + Cross (S.Angular_Velocity, Shift) + Qd * Direction;
                        S.Linear_Bias := S.Linear_Bias + Cross (S.Angular_Bias, Shift)
                          + Cross (S.Angular_Velocity, Cross (S.Angular_Velocity, Shift))
                          + (2.0 * Qd) * Cross (S.Angular_Velocity, Direction);
                        end if;
                     end;
                  else
                     declare
                        Anchor_Velocity : constant Vector := (if With_Motion then S.Linear_Velocity
                          + Cross (S.Angular_Velocity, Anchor_Offset) else Zero);
                        Anchor_Acceleration : constant Vector := (if With_Motion then S.Linear_Bias
                          + Cross (S.Angular_Bias, Anchor_Offset)
                          + Cross (S.Angular_Velocity, Cross (S.Angular_Velocity, Anchor_Offset)) else Zero);
                        New_Offset : Vector;
                     begin
                        --  alpha(qacc=0) includes the derivative of the moving axis.
                        if With_Motion then
                        S.Angular_Bias := S.Angular_Bias
                          + Qd * Cross (S.Angular_Velocity, Direction);
                        S.Angular_Velocity := S.Angular_Velocity + Qd * Direction;
                        end if;
                        S.Orientation := Multiply
                          (S.Orientation, Axis_Angle (Joint.Direction, Q));
                        Normalize (S.Orientation, Normal);
                        if not Normal then
                           return;
                        end if;
                        S.Rotation := Rotation (S.Orientation);
                        New_Offset := Apply (S.Rotation, Joint.Anchor);
                        S.Position := Anchor - New_Offset;
                        if With_Motion then
                        S.Linear_Velocity := Anchor_Velocity
                          - Cross (S.Angular_Velocity, New_Offset);
                        S.Linear_Bias := Anchor_Acceleration
                          - Cross (S.Angular_Bias, New_Offset)
                          - Cross (S.Angular_Velocity, Cross (S.Angular_Velocity, New_Offset));
                        end if;
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
            Bodies (B) := S;
         end;
      end loop;

      Result := Success;
   end Build_Bodies;

   procedure Update_Poses
     (D : in out Simulation; Result : out Status; With_Cartesian_Motion : Boolean := False) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      With_Motion : constant Boolean := With_Cartesian_Motion or else D.Nv < 3;
   begin
      Invalidate (D.Cache);
      Build_Bodies (D.Body_Config.all, D.Joint_Config.all, D.State.Qpos.all, D.State.Qvel.all,
                    With_Motion, D.Kinematic.Bodies.all, D.Kinematic.Joints.all, Result);
      if Result = Success then
         D.Cache.Pose_Valid := True;
         D.Cache.Cartesian_Motion_Valid := With_Motion;
      end if;
      --  Kinematic publication cannot change either allocated array's bounds.
      pragma Assert (Static => D.Kinematic.Bodies'First = 0
        and then Int64 (D.Kinematic.Bodies'Length) = Int64 (D.Nb));
      pragma Assert (Static => D.Kinematic.Joints'First = 0
        and then Int64 (D.Kinematic.Joints'Length) = Int64 (D.Nj));
      pragma Assert (Static => Stable_Ready (D));
   end Update_Poses;

   procedure Ensure_Cartesian_Motion (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Nb : constant Natural := D.Nb;
      Nj : constant Natural := D.Nj;
   begin
      if D.Cache.Cartesian_Motion_Valid then
         Result := Success;
         pragma Assert (Static => Stable_Ready (D));
         return;
      end if;
      --  Rare wide-domain fallback. Recompute in temporary storage; publish
      --  only the motion fields after success, preserving poses and CRB data.
      declare
         Bodies : Body_State_Array (0 .. Nb - 1);
         Joints : Joint_State_Array (0 .. Nj - 1);
      begin
         Build_Bodies (D.Body_Config.all, D.Joint_Config.all, D.State.Qpos.all, D.State.Qvel.all,
                       True, Bodies, Joints, Result);
         if Result /= Success then
            pragma Assert (Static => Stable_Ready (D));
            return;
         end if;
         for B in Bodies'Range loop
            pragma Loop_Invariant (Stable_Ready (D));
            D.Kinematic.Bodies (B).Linear_Velocity := Bodies (B).Linear_Velocity;
            D.Kinematic.Bodies (B).Angular_Velocity := Bodies (B).Angular_Velocity;
            D.Kinematic.Bodies (B).Linear_Bias := Bodies (B).Linear_Bias;
            D.Kinematic.Bodies (B).Angular_Bias := Bodies (B).Angular_Bias;
         end loop;
      end;
      D.Cache.Cartesian_Motion_Valid := True;
      --  Kinematic publication cannot change either allocated array's bounds.
      pragma Assert (Static => D.Kinematic.Bodies'First = 0
        and then Int64 (D.Kinematic.Bodies'Length) = Int64 (D.Nb));
      pragma Assert (Static => D.Kinematic.Joints'First = 0
        and then Int64 (D.Kinematic.Joints'Length) = Int64 (D.Nj));
      pragma Assert (Static => Stable_Ready (D));
   end Ensure_Cartesian_Motion;

   procedure Ensure_Jacobians (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Accepted : Boolean;
   begin
      if D.Cache.Jacobian_Valid then
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
         Result := Success;
         return;
      end if;
      Jacobians.Build
        (D.Body_Config.all, D.Joint_Config.all,
         D.Kinematic.Bodies.all, D.Kinematic.Joints.all,
         D.Kinematic.Linear_Jacobian.all, D.Kinematic.Angular_Jacobian.all, Accepted);
      pragma Assert (Static => Is_Ready (D));
      D.Cache.Jacobian_Valid := Accepted;
      pragma Assert (Static => Is_Ready (D));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Result := (if Accepted then Success else Numeric_Limit);
   end Ensure_Jacobians;

   procedure Evaluate_Ready (D : in out Simulation; Result : out Status) is
      --  Compose phase contracts without expanding their representation.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Forces_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
   begin
      declare
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
      Update_Poses (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      declare
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
      Inertia_Phase.Assemble (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      declare
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
      Forces_Phase.Compute (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      declare
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
      Actuation_Phase.Compute (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      declare
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
      Inertia_Phase.Solve_Acceleration (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
   end Evaluate_Ready;
end MJ.Data.Pipeline;

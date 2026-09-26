with MJ.Pose_Arithmetic;
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

   procedure Widen_Rotation_Bounds (R : Matrix) with Ghost => Static,
     Global => null, Pre => Bounded (R, 8.0), Post => Bounded (R, 16.0)
   is
   begin
      null;
   end Widen_Rotation_Bounds;

   --  Keep normalization's scaled-norm details local to its proved kernel.
   --  This wrapper exposes only the facts required by the tree traversal.
   procedure Identity_Is_Unit with Ghost => Static, Global => null,
     Post => Unit_Quaternion (Identity_Quaternion)
   is
   begin
      null;
   end Identity_Is_Unit;

   procedure Normalize_Orientation (Q : in out Quaternion; Ok : out Boolean)
     with Global => null,
     Post => (if Ok then Unit_Quaternion (Q) else Q = Q'Old)
   is
   begin
      Normalize (Q, Ok);
   end Normalize_Orientation;

   procedure Fixed_Position (P : Body_State; C : Body_Parameters; S : out Body_State; Ok : out Boolean)
     with Global => null,
     Pre => Body_Bounded (P) and then Bounded (C.Position, Max_Val)
       and then Unit_Quaternion (C.Orientation),
     Post => (if Ok then Body_Bounded (S) and then Unit_Quaternion (S.Orientation)
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
      Normalize_Orientation (S.Orientation, Normal);
      if not Normal then return; end if;
      --  Retain the complete geometric state, discarding normalization's
      --  internal scaled-norm arithmetic from the remaining obligations.
      pragma Assert (Static => Bounded (P.Position));
      pragma Assert (Static => Bounded (P.Rotation, 16.0));
      pragma Assert (Static => Bounded (C.Position, Max_Val));
      pragma Assert (Static => Unit_Quaternion (S.Orientation));
      pragma Assert (Static => S.Position = P.Position + Apply_Config (P.Rotation, C.Position));
      pragma Assert (Static => S.Center = Zero);
      pragma Assert (Static => Bounded (S.Inertial_Rotation, 16.0));
      pragma Assert (Static => S.Linear_Velocity = Zero and then S.Angular_Velocity = Zero);
      pragma Assert (Static => S.Linear_Bias = Zero and then S.Angular_Bias = Zero);
      S.Rotation := Rotation (S.Orientation);
      Widen_Rotation_Bounds (S.Rotation);
      Ok := Motion_Bounded (S);
   end Fixed_Position;
   pragma Inline_Always (Fixed_Position);

   procedure Fixed_Frame (P : Body_State; C : Body_Parameters; S : out Body_State; Ok : out Boolean)
     with Global => null,
     Pre => Body_Bounded (P) and then Bounded (C.Position, Max_Val)
       and then Unit_Quaternion (C.Orientation),
     Post => (if Ok then Body_Bounded (S) and then Unit_Quaternion (S.Orientation)
       and then S.Position = P.Position + Apply_Config (P.Rotation, C.Position)
       and then S.Angular_Velocity = P.Angular_Velocity and then S.Angular_Bias = P.Angular_Bias
       and then S.Linear_Velocity = Transport_Velocity
         (P.Linear_Velocity, P.Angular_Velocity, Apply_Config (P.Rotation, C.Position))
       and then S.Linear_Bias = Center_Acceleration
         (P.Linear_Bias, P.Angular_Bias, P.Angular_Velocity, Apply_Config (P.Rotation, C.Position))
       and then S.Rotation = Rotation (S.Orientation))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      R : constant Vector := Apply_Config (P.Rotation, C.Position);
      Velocity : constant Vector := Transport_Velocity (P.Linear_Velocity, P.Angular_Velocity, R);
      Bias : constant Vector := Center_Acceleration (P.Linear_Bias, P.Angular_Bias, P.Angular_Velocity, R);
   begin
      Fixed_Position (P, C, S, Ok);
      if not Ok then return; end if;
      S.Angular_Velocity := P.Angular_Velocity;
      S.Angular_Bias := P.Angular_Bias;
      S.Linear_Velocity := Velocity;
      S.Linear_Bias := Bias;
      Ok := Motion_Bounded (S);
   end Fixed_Frame;

   procedure Store_Body_Pose
     (Bodies : in out Body_State_Array; B : Natural; S : Body_State)
     with Global => null,
     Pre => Bodies'First = 0 and then B in Bodies'Range
       and then Unit_Quaternion (S.Orientation) and then Body_Bounded (S)
       and then (for all K in 0 .. B - 1 => Body_Bounded (Bodies (K)))
       and then (for all K in 0 .. B - 1 => Unit_Quaternion (Bodies (K).Orientation)),
     Post => Bodies'First = Bodies'First'Old and then Bodies'Last = Bodies'Last'Old
       and then Bodies (B) = S
       and then (for all K in 0 .. B => Body_Bounded (Bodies (K)))
       and then (for all K in Bodies'Range => (if K /= B then Bodies (K) = Bodies'Old (K)))
       and then (for all K in 0 .. B => Unit_Quaternion (Bodies (K).Orientation))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
   begin
      Bodies (B) := S;
   end Store_Body_Pose;

   procedure Expose_Body_Bounds (S : Body_State) with Ghost => Static,
     Global => null, Pre => Body_Bounded (S),
     Post => Motion_Bounded (S) and then Unit_Quaternion (S.Orientation)
       and then Bounded (S.Rotation, 16.0) and then Bounded (S.Inertial_Rotation, 16.0)
   is
   begin
      null;
   end Expose_Body_Bounds;

   procedure Establish_Body_Bounds (S : Body_State) with Ghost => Static,
     Global => null,
     Pre => Motion_Bounded (S) and then Unit_Quaternion (S.Orientation)
       and then Bounded (S.Rotation, 16.0) and then Bounded (S.Inertial_Rotation, 16.0),
     Post => Body_Bounded (S)
   is
   begin
      null;
   end Establish_Body_Bounds;

   procedure Joint_Orientation
     (Q : in out Quaternion; Direction : Vector; Angle : Real;
      R : out Matrix; Ok : out Boolean)
     with Global => null,
     Pre => Unit_Quaternion (Q) and then Unit_Vector (Direction)
       and then Angle in -2.0e10 .. 2.0e10,
     Post => (if Ok then Unit_Quaternion (Q) and then Bounded (R, 16.0)
       and then R = Rotation (Q))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
   begin
      Quaternion_Bounds (Q);
      R := Identity;
      Q := Multiply (Q, Axis_Angle (Direction, Angle));
      Normalize_Orientation (Q, Ok);
      if not Ok then return; end if;
      R := Rotation (Q);
      Widen_Rotation_Bounds (R);
   end Joint_Orientation;

   procedure Expose_Unit_Vector (V : Vector) with Ghost => Static,
     Global => null, Pre => Unit_Vector (V), Post => Bounded (V, 1.000001)
   is
   begin
      null;
   end Expose_Unit_Vector;

   procedure Apply_One_Joint
     (S : in out Body_State; Joint : Joint_Parameters; Q, Qd : Real;
      With_Motion : Boolean; State : out Joint_State; Ok : out Boolean)
     with Global => null,
     Pre => Body_Bounded (S) and then Unit_Vector (Joint.Direction)
       and then Bounded (Joint.Anchor, Max_Val)
       and then Q in -2.0e10 .. 2.0e10 and then Qd in -Max_Val .. Max_Val,
     Post => (if Ok then Body_Bounded (S) and then Unit_Quaternion (S.Orientation)
       and then Joint_Bounded (State))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      function "+" (A, B : Vector) return Vector renames MJ.Pose_Arithmetic."+";
      function "-" (A, B : Vector) return Vector renames MJ.Pose_Arithmetic."-";
      function "*" (S : Real; V : Vector) return Vector renames MJ.Pose_Arithmetic."*";
      function Cross (A, B : Vector) return Vector renames MJ.Pose_Arithmetic.Cross;
      function Apply_Config (R : Matrix; V : Vector) return Vector
        renames MJ.Pose_Arithmetic.Apply_Config;
      Normal : Boolean;
   begin
      Ok := False;
      Expose_Unit_Vector (Joint.Direction);
      Expose_Body_Bounds (S);
      Quaternion_Bounds (S.Orientation);
      declare
         Position : Vector := S.Position;
         Orientation : Quaternion := S.Orientation;
         Rotation_Matrix : Matrix := S.Rotation;
         Linear_Velocity : Vector := S.Linear_Velocity;
         Angular_Velocity : Vector := S.Angular_Velocity;
         Linear_Bias : Vector := S.Linear_Bias;
         Angular_Bias : Vector := S.Angular_Bias;
            Direction : constant Vector := Apply_Config (Rotation_Matrix, Joint.Direction);
            Anchor_Offset : constant Vector := Apply_Config (Rotation_Matrix, Joint.Anchor);
            Anchor : constant Vector := Position + Anchor_Offset;
         begin
            pragma Assert (Static => Bounded (Anchor, 1.0e66));
            State := (Anchor => Anchor, Direction => Direction, others => <>);
            if Joint.Kind = Slide_Joint then
               declare
                  Shift : constant Vector := Q * Direction;
               begin
                  Position := Position + Shift;
                  if With_Motion then
                  Linear_Velocity := MJ.Pose_Arithmetic.Slide_Velocity
                    (Linear_Velocity, Angular_Velocity, Shift, Direction, Qd);
                  Linear_Bias := MJ.Pose_Arithmetic.Slide_Bias
                    (Linear_Bias, Angular_Bias, Angular_Velocity, Shift, Direction, Qd);
                  end if;
               end;
            else
               declare
                  Anchor_Velocity : constant Vector := (if With_Motion then MJ.Pose_Arithmetic.Anchor_Velocity
                    (Linear_Velocity, Angular_Velocity, Anchor_Offset) else Zero);
                  Anchor_Acceleration : constant Vector := (if With_Motion then MJ.Pose_Arithmetic.Anchor_Bias
                    (Linear_Bias, Angular_Bias, Angular_Velocity, Anchor_Offset) else Zero);
                  New_Offset : Vector;
               begin
                  --  alpha(qacc=0) includes the derivative of the moving axis.
                  if With_Motion then
                  Angular_Bias := MJ.Pose_Arithmetic.Hinge_Angular_Bias
                    (Angular_Bias, Angular_Velocity, Direction, Qd);
                  Angular_Velocity := MJ.Pose_Arithmetic.Hinge_Angular_Velocity
                    (Angular_Velocity, Direction, Qd);
                  end if;
                  Joint_Orientation (Orientation, Joint.Direction, Q, Rotation_Matrix, Normal);
                  if not Normal then return; end if;
                  New_Offset := Apply_Config (Rotation_Matrix, Joint.Anchor);
                  pragma Assert (Static => Bounded (Anchor, 1.0e66));
                  pragma Assert (Static => Bounded (New_Offset, 1.0e12));
                  Position := Anchor - New_Offset;
                  if With_Motion then
                  Linear_Velocity := MJ.Pose_Arithmetic.Hinge_Linear_Velocity
                    (Anchor_Velocity, Angular_Velocity, New_Offset);
                  Linear_Bias := MJ.Pose_Arithmetic.Hinge_Linear_Bias
                    (Anchor_Acceleration, Angular_Bias, Angular_Velocity, New_Offset);
                  end if;
               end;
            end if;
            S := (S with delta
              Position => Position, Orientation => Orientation, Rotation => Rotation_Matrix,
              Linear_Velocity => Linear_Velocity, Angular_Velocity => Angular_Velocity,
              Linear_Bias => Linear_Bias, Angular_Bias => Angular_Bias);
            if not Motion_Bounded (S) or else not Bounded (Anchor)
              or else not Bounded (Direction, 1.00001)
            then
               return;
            end if;
            pragma Assert (Static => Bounded (S.Rotation, 16.0));
            pragma Assert (Static => Bounded (S.Inertial_Rotation, 16.0));
            Establish_Body_Bounds (S);
      end;
      Ok := True;
   end Apply_One_Joint;

   procedure Finalize_Body_Frame (S : in out Body_State; C : Body_Parameters; Ok : out Boolean)
     with Global => null,
     Pre => Body_Bounded (S) and then Bounded (C.Inertial_Position, Max_Val)
       and then Unit_Quaternion (C.Inertial_Orientation),
     Post => (if Ok then Body_Bounded (S) and then Unit_Quaternion (S.Orientation))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      function "+" (A, B : Vector) return Vector renames MJ.Pose_Arithmetic."+";
      function Apply_Config (R : Matrix; V : Vector) return Vector renames MJ.Pose_Arithmetic.Apply_Config;
      IQ : Quaternion;
      Normal : Boolean;
   begin
      Ok := False;
      Expose_Body_Bounds (S);
      declare
         Center : constant Vector := S.Position + Apply_Config (S.Rotation, C.Inertial_Position);
         Inertial_Rotation : Matrix;
      begin
         Quaternion_Bounds (S.Orientation);
         Quaternion_Bounds (C.Inertial_Orientation);
         IQ := Multiply (S.Orientation, C.Inertial_Orientation);
         Normalize_Orientation (IQ, Normal);
         if not Normal then return; end if;
         Inertial_Rotation := Rotation (IQ);
         Widen_Rotation_Bounds (Inertial_Rotation);
         S := (S with delta Center => Center, Inertial_Rotation => Inertial_Rotation);
         if not Motion_Bounded (S) then return; end if;
         Establish_Body_Bounds (S);
      end;
      Ok := True;
   end Finalize_Body_Frame;

   subtype Joint_Angle is Real range -2.0e10 .. 2.0e10;
   function Joint_Displacement (Position, Reference : Tier0_Real) return Joint_Angle
     with Global => null, Post => Joint_Displacement'Result = Position - Reference
   is
   begin
      return Position - Reference;
   end Joint_Displacement;

   procedure Build_One_Body
     (P : Body_State; C : Body_Parameters; Joint_Config : Joint_Parameter_Array;
      Qpos, Qvel : Real_Array; With_Motion : Boolean;
      S : out Body_State; Joints : in out Joint_State_Array; Result : out Status)
     with Global => null,
     Pre => Body_Bounded (P)
       and then Joint_Config'First = 0 and then Joint_Config'Length <= Max_Dofs
       and then Joints'First = 0 and then Joints'Last = Joint_Config'Last
       and then Qpos'First = 0 and then Qpos'Last = Joint_Config'Last
       and then Qvel'First = 0 and then Qvel'Last = Joint_Config'Last
       and then (for all X of Qpos => X in -Max_Val .. Max_Val)
       and then (for all X of Qvel => X in -Max_Val .. Max_Val)
       and then C.Joint_Count <= Joint_Config'Length
       and then (if C.Joint_Count > 0 then C.First_Joint >= 0
         and then C.First_Joint <= Joint_Config'Length - C.Joint_Count)
       and then Bounded (C.Position, Max_Val)
       and then Bounded (C.Inertial_Position, Max_Val)
       and then Unit_Quaternion (C.Orientation) and then Unit_Quaternion (C.Inertial_Orientation)
       and then (for all J in Joint_Config'Range =>
         Joint_Config (J).Qadr = J and then Joint_Config (J).Vadr = J
         and then Unit_Vector (Joint_Config (J).Direction)
         and then Bounded (Joint_Config (J).Anchor, Max_Val)),
     Post => (if Result = Success then Body_Bounded (S) and then Unit_Quaternion (S.Orientation)
       and then (for all J in Joints'Range =>
         (if Joint_Bounded (Joints'Old (J)) then Joint_Bounded (Joints (J))))
       and then (for all J in Joints'Range =>
         (if C.Joint_Count > 0 and then J in C.First_Joint .. C.First_Joint + C.Joint_Count - 1
          then Joint_Bounded (Joints (J)) else Joints (J) = Joints'Old (J))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Joints : constant Joint_State_Array := Joints with Ghost => Static;
      Normal : Boolean;
   begin
      Result := Numeric_Limit;
      if With_Motion then Fixed_Frame (P, C, S, Normal);
      else Fixed_Position (P, C, S, Normal); end if;
      if not Normal then return; end if;

      for Offset in 0 .. C.Joint_Count - 1 loop
         declare
            J : constant Natural := C.First_Joint + Offset;
            Q : constant Real := Joint_Displacement (Qpos (Joint_Config (J).Qadr), Joint_Config (J).Reference);
            Qd : constant Real := Qvel (Joint_Config (J).Vadr);
         begin
            Apply_One_Joint (S, Joint_Config (J), Q, Qd, With_Motion, Joints (J), Normal);
            if not Normal then return; end if;
         end;
         pragma Loop_Invariant (Static => (for all J in Joints'Range =>
           (if J in C.First_Joint .. C.First_Joint + Offset
            then Joint_Bounded (Joints (J)) else Joints (J) = Initial_Joints (J))));
         pragma Loop_Invariant (Static => (for all J in Joints'Range =>
           (if Joint_Bounded (Initial_Joints (J)) then Joint_Bounded (Joints (J)))));
         pragma Loop_Invariant (Unit_Quaternion (S.Orientation));
         pragma Loop_Invariant (Body_Bounded (S));
         pragma Loop_Invariant (Bounded (S.Rotation, 16.0));
         pragma Loop_Invariant (Bounded (S.Inertial_Rotation, 16.0));
      end loop;

      Finalize_Body_Frame (S, C, Normal);
      if not Normal then return; end if;
      Result := Success;
   end Build_One_Body;

   procedure Initialize_World (S : out Body_State)
     with Global => null, Post => Body_Bounded (S) and then Unit_Quaternion (S.Orientation)
       and then S = Body_State'(others => <>)
   is
   begin
      S := (others => <>);
   end Initialize_World;

   procedure Build_Bodies
     (Body_Config : Body_Parameter_Array; Joint_Config : Joint_Parameter_Array;
      Qpos, Qvel : Real_Array; With_Motion : Boolean;
      Bodies : in out Body_State_Array; Joints : in out Joint_State_Array; Result : out Status)
     with Global => null,
     Pre => Body_Config'First = 0 and then Body_Config'Length in 1 .. Max_Bodies
       and then Bodies'First = 0 and then Bodies'Last = Body_Config'Last
       and then Joint_Config'First = 0 and then Joint_Config'Length <= Max_Dofs
       and then Joints'First = 0 and then Joints'Last = Joint_Config'Last
       and then Qpos'First = 0 and then Qpos'Last = Joint_Config'Last
       and then Qvel'First = 0 and then Qvel'Last = Joint_Config'Last
       and then (for all X of Qpos => X in -Max_Val .. Max_Val)
       and then (for all X of Qvel => X in -Max_Val .. Max_Val)
       and then (for all B in Body_Config'Range =>
         (if B = 0 then Body_Config (B).Parent = 0
          else Body_Config (B).Parent < B)
         and then Body_Config (B).Joint_Count <= Joint_Config'Length
         and then (if Body_Config (B).Joint_Count > 0 then
           Body_Config (B).First_Joint >= 0
           and then Body_Config (B).First_Joint <= Joint_Config'Length - Body_Config (B).Joint_Count)
         and then Bounded (Body_Config (B).Position, Max_Val)
         and then Bounded (Body_Config (B).Inertial_Position, Max_Val)
         and then Unit_Quaternion (Body_Config (B).Orientation)
         and then Unit_Quaternion (Body_Config (B).Inertial_Orientation))
       and then (for all J in Joint_Config'Range =>
         Joint_Config (J).Body_Id in 1 .. Body_Config'Last
         and then Body_Config (Joint_Config (J).Body_Id).Joint_Count > 0
         and then J in Body_Config (Joint_Config (J).Body_Id).First_Joint ..
           Body_Config (Joint_Config (J).Body_Id).First_Joint
             + Body_Config (Joint_Config (J).Body_Id).Joint_Count - 1)
       and then (for all J in Joint_Config'Range =>
         Joint_Config (J).Qadr = J and then Joint_Config (J).Vadr = J
         and then Unit_Vector (Joint_Config (J).Direction)
         and then Bounded (Joint_Config (J).Anchor, Max_Val)),
     Post => (if Result = Success then (for all B of Bodies => Body_Bounded (B))
       and then (for all J of Joints => Joint_Bounded (J)))
       and then Bodies'First = Bodies'First'Old and then Bodies'Last = Bodies'Last'Old
       and then Joints'First = Joints'First'Old and then Joints'Last = Joints'Last'Old
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      S : Body_State;
   begin
      Initialize_World (Bodies (0));
      --  This builder leaves Jacobians untouched. Its caller controls cache
      --  publication, including temporary Cartesian fallback construction.

      --  Parents precede children. Apply every scalar joint in body order,
      --  treating intermediate frames as massless; inertia belongs to the
      --  final body frame. This also supports multiple joints on one body.
      for B in 1 .. Bodies'Last loop
         declare
         begin
            pragma Assert (Static => (for all J in Joint_Config'Range =>
              (if Joint_Config (J).Body_Id = B then Body_Config (B).Joint_Count > 0
                and then J in Body_Config (B).First_Joint .. Body_Config (B).First_Joint + Body_Config (B).Joint_Count - 1)));
            Build_One_Body (Bodies (Body_Config (B).Parent), Body_Config (B), Joint_Config, Qpos, Qvel, With_Motion, S, Joints, Result);
            if Result /= Success then return; end if;
            pragma Assert (Static => (for all J in Joints'Range =>
              (if Joint_Config (J).Body_Id = B then Joint_Bounded (Joints (J)))));
            pragma Assert (Static => (for all J in Joints'Range =>
              (if Joint_Config (J).Body_Id < B then Joint_Bounded (Joints (J)))));
            Store_Body_Pose (Bodies, B, S);
         end;
         pragma Loop_Invariant (for all J in Joints'Range =>
           (if Joint_Config (J).Body_Id <= B then Joint_Bounded (Joints (J))));
         pragma Loop_Invariant (for all K in 0 .. B => Unit_Quaternion (Bodies (K).Orientation));
         pragma Loop_Invariant (for all K in 0 .. B => Body_Bounded (Bodies (K)));
      end loop;

      Result := Success;
   end Build_Bodies;

   procedure Expose_State_Layout (D : Simulation)
     with Ghost => Static, Global => null, Pre => Storage_Ready (D),
     Post => D.State.Qpos /= null and then D.State.Qpos'First = 0
       and then D.State.Qpos'Last = D.Nq - 1 and then Int64 (D.State.Qpos'Length) = Int64 (D.Nq)
       and then D.State.Qvel /= null and then D.State.Qvel'First = 0
       and then D.State.Qvel'Last = D.Nv - 1 and then Int64 (D.State.Qvel'Length) = Int64 (D.Nv)
       and then D.Kinematic.Joints /= null and then D.Kinematic.Joints'Last = D.Nj - 1
       and then D.Kinematic.Bodies /= null and then D.Kinematic.Bodies'Last = D.Nb - 1
       and then D.Body_Config /= null and then D.Body_Config'Last = D.Nb - 1
   is
   begin
      null;
   end Expose_State_Layout;

   --  Prove the representation once; callers use the opaque readiness fact.
   procedure Expose_Stable_Ready (D : Simulation) with Ghost => Static,
     Global => null, Pre => Stable_Ready (D),
     Post => Storage_Ready (D) and then Configuration_Bounded (D)
       and then Configuration_Valid (D.Body_Config.all, D.Joint_Config.all,
         D.Actuator_Config.all, D.Nb, D.Nj, D.Na)
   is
   begin
      null;
   end Expose_Stable_Ready;

   procedure Establish_Stable_Ready (D : Simulation) with Ghost => Static,
     Global => null,
     Pre => Storage_Ready (D) and then Configuration_Bounded (D)
       and then Configuration_Valid (D.Body_Config.all, D.Joint_Config.all,
         D.Actuator_Config.all, D.Nb, D.Nj, D.Na),
     Post => Stable_Ready (D)
   is
   begin
      null;
   end Establish_Stable_Ready;

   procedure Update_Poses
     (D : in out Simulation; Result : out Status; With_Cartesian_Motion : Boolean := False) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Has_Real_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Clock : constant Real := D.Clock with Ghost => Static;
      With_Motion : constant Boolean := With_Cartesian_Motion or else D.Nv < 3;
   begin
      Expose_Stable_Ready (D);
      Expose_State_Layout (D);
      Invalidate (D.Cache);
      pragma Assert (Static => D.Body_Config.all'First = 0);
      pragma Assert (Static => D.Body_Config.all'Length in 1 .. Max_Bodies);
      pragma Assert (Static => D.Kinematic.Bodies.all'First = 0);
      pragma Assert (Static => D.Kinematic.Bodies.all'Last = D.Body_Config.all'Last);
      pragma Assert (Static => D.Joint_Config.all'First = 0);
      pragma Assert (Static => D.Joint_Config.all'Length <= Max_Dofs);
      pragma Assert (Static => D.Kinematic.Joints.all'First = 0);
      pragma Assert (Static => D.Kinematic.Joints.all'Last = D.Joint_Config.all'Last);
      pragma Assert (Static => D.State.Qpos.all'First = 0);
      pragma Assert (Static => D.State.Qpos.all'Last = D.Joint_Config.all'Last);
      pragma Assert (Static => D.State.Qvel.all'First = 0);
      pragma Assert (Static => D.State.Qvel.all'Last = D.Joint_Config.all'Last);
      pragma Assert (Static => (for all X of D.State.Qpos.all => X in -Max_Val .. Max_Val));
      pragma Assert (Static => (for all X of D.State.Qvel.all => X in -Max_Val .. Max_Val));
      pragma Assert (Static => (for all B in D.Body_Config.all'Range =>
         (if B = 0 then D.Body_Config.all (B).Parent = 0
          else D.Body_Config.all (B).Parent < B)
         and then D.Body_Config.all (B).Joint_Count <= D.Joint_Config.all'Length
         and then (if D.Body_Config.all (B).Joint_Count > 0 then
           D.Body_Config.all (B).First_Joint >= 0
           and then D.Body_Config.all (B).First_Joint <= D.Joint_Config.all'Length - D.Body_Config.all (B).Joint_Count)
         and then Bounded (D.Body_Config.all (B).Position, Max_Val)
         and then Bounded (D.Body_Config.all (B).Inertial_Position, Max_Val)
         and then Unit_Quaternion (D.Body_Config.all (B).Orientation)
         and then Unit_Quaternion (D.Body_Config.all (B).Inertial_Orientation)));
      pragma Assert (Static => (for all J in D.Joint_Config.all'Range =>
         D.Joint_Config.all (J).Body_Id in 1 .. D.Body_Config.all'Last
         and then D.Body_Config.all (D.Joint_Config.all (J).Body_Id).Joint_Count > 0
         and then J in D.Body_Config.all (D.Joint_Config.all (J).Body_Id).First_Joint ..
           D.Body_Config.all (D.Joint_Config.all (J).Body_Id).First_Joint
             + D.Body_Config.all (D.Joint_Config.all (J).Body_Id).Joint_Count - 1));
      pragma Assert (Static => (for all J in D.Joint_Config.all'Range =>
         D.Joint_Config.all (J).Qadr = J and then D.Joint_Config.all (J).Vadr = J
         and then Unit_Vector (D.Joint_Config.all (J).Direction)
         and then Bounded (D.Joint_Config.all (J).Anchor, Max_Val)));

      Build_Bodies (D.Body_Config.all, D.Joint_Config.all, D.State.Qpos.all, D.State.Qvel.all,
                    With_Motion, D.Kinematic.Bodies.all, D.Kinematic.Joints.all, Result);
      if Result = Success then
         D.Cache := (D.Cache with delta Pose_Valid => True,
           Cartesian_Motion_Valid => With_Motion);
         pragma Assert (Static => Caches_Bounded (D));
      end if;
      pragma Assert (Static => Position_Values (D) = Initial_Pos);
      pragma Assert (Static => Velocity_Values (D) = Initial_Vel);
      pragma Assert (Static => D.Clock = Initial_Clock);
      pragma Assert (Static => State_Values (D) = Initial_State);
      --  Kinematic publication cannot change either allocated array's bounds.
      pragma Assert (Static => D.Kinematic.Bodies'First = 0
        and then Int64 (D.Kinematic.Bodies'Length) = Int64 (D.Nb));
      pragma Assert (Static => D.Kinematic.Joints'First = 0
        and then Int64 (D.Kinematic.Joints'Length) = Int64 (D.Nj));
      pragma Assert (Static => Ancestor_Storage_Ready (D));
      pragma Assert (Static => Topology_Storage_Ready (D));
      pragma Assert (Static => Has_Real_Layout (D.Kinematic.Linear_Jacobian, 3 * D.Nb * D.Nv));
      pragma Assert (Static => Has_Real_Layout (D.Kinematic.Angular_Jacobian, 3 * D.Nb * D.Nv));
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Configuration_Bounded (D));
      Establish_Stable_Ready (D);
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => Is_Ready (D));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Update_Poses;

   procedure Copy_Motion (S : in out Body_State; From : Body_State)
     with Global => null, Pre => Body_Bounded (S) and then Body_Bounded (From),
     Post => S = (S'Old with delta Linear_Velocity => From.Linear_Velocity,
         Angular_Velocity => From.Angular_Velocity, Linear_Bias => From.Linear_Bias,
         Angular_Bias => From.Angular_Bias)
       and then Body_Bounded (S)
       and then S.Position = S'Old.Position and then S.Center = S'Old.Center
       and then S.Orientation = S'Old.Orientation and then S.Rotation = S'Old.Rotation
       and then S.Inertial_Rotation = S'Old.Inertial_Rotation
       and then S.Linear_Velocity = From.Linear_Velocity
       and then S.Angular_Velocity = From.Angular_Velocity
       and then S.Linear_Bias = From.Linear_Bias and then S.Angular_Bias = From.Angular_Bias
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
   begin
      S := (S with delta Linear_Velocity => From.Linear_Velocity,
        Angular_Velocity => From.Angular_Velocity,
        Linear_Bias => From.Linear_Bias, Angular_Bias => From.Angular_Bias);
   end Copy_Motion;

   procedure Copy_Motions (Target : in out Body_State_Array; Source : Body_State_Array)
     with Global => null,
     Pre => Target'First = Source'First and then Target'Last = Source'Last
       and then (for all B in Target'Range => Body_Bounded (Target (B)))
       and then (for all B in Source'Range => Body_Bounded (Source (B))),
     Post => Target'First = Target'First'Old and then Target'Last = Target'Last'Old
       and then (for all B in Target'Range => Body_Bounded (Target (B)))
       and then (for all B in Target'Range => Target (B) =
         (Target'Old (B) with delta Linear_Velocity => Source (B).Linear_Velocity,
          Angular_Velocity => Source (B).Angular_Velocity,
          Linear_Bias => Source (B).Linear_Bias, Angular_Bias => Source (B).Angular_Bias))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
   begin
      for B in Target'Range loop
         Copy_Motion (Target (B), Source (B));
         pragma Loop_Invariant (for all K in Target'Range => Body_Bounded (Target (K)));
         pragma Loop_Invariant (for all K in Target'Range =>
           (if K <= B then Target (K) =
              (Target'Loop_Entry (K) with delta Linear_Velocity => Source (K).Linear_Velocity,
               Angular_Velocity => Source (K).Angular_Velocity,
               Linear_Bias => Source (K).Linear_Bias, Angular_Bias => Source (K).Angular_Bias)
            else Target (K) = Target'Loop_Entry (K)));
      end loop;
   end Copy_Motions;

   procedure Ensure_Cartesian_Motion (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Has_Real_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Input : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Clock : constant Real := D.Clock with Ghost => Static;
      Nb : constant Natural := D.Nb;
      Nj : constant Natural := D.Nj;
   begin
      Expose_Stable_Ready (D);
      Expose_State_Layout (D);
      if D.Cache.Cartesian_Motion_Valid then
         Result := Success;
      else
         --  Rare wide-domain fallback. Publish only after successful building;
         --  all paths meet below for the same public-state preservation proof.
         declare
            Bodies : Body_State_Array (0 .. Nb - 1);
            Joints : Joint_State_Array (0 .. Nj - 1);
         begin
            Build_Bodies (D.Body_Config.all, D.Joint_Config.all,
                          D.State.Qpos.all, D.State.Qvel.all,
                          True, Bodies, Joints, Result);
            if Result = Success then
               Copy_Motions (D.Kinematic.Bodies.all, Bodies);
               D.Cache := (D.Cache with delta Cartesian_Motion_Valid => True);
            end if;
         end;
      end if;
      --  Kinematic publication cannot change either allocated array's bounds.
      pragma Assert (Static => D.Kinematic.Bodies'First = 0
        and then Int64 (D.Kinematic.Bodies'Length) = Int64 (D.Nb));
      pragma Assert (Static => D.Kinematic.Joints'First = 0
        and then Int64 (D.Kinematic.Joints'Length) = Int64 (D.Nj));
      pragma Assert (Static => Ancestor_Storage_Ready (D));
      pragma Assert (Static => Topology_Storage_Ready (D));
      pragma Assert (Static => Has_Real_Layout (D.Kinematic.Linear_Jacobian, 3 * D.Nb * D.Nv));
      pragma Assert (Static => Has_Real_Layout (D.Kinematic.Angular_Jacobian, 3 * D.Nb * D.Nv));
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Configuration_Bounded (D));
      Establish_Stable_Ready (D);
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => Position_Values (D) = Initial_Pos);
      pragma Assert (Static => Velocity_Values (D) = Initial_Vel);
      pragma Assert (Static => D.Clock = Initial_Clock);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Input);
      pragma Assert (Static => Inputs_Bounded (D));
      pragma Assert (Static => Caches_Bounded (D));
      pragma Assert (Static => Is_Ready (D));
      pragma Assert (Static => Positions_Current (D));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
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

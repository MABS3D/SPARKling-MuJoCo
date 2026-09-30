package body MJ.Data.Actuation_Phase with SPARK_Mode is
   use type MJ.Activation.Dynamics;
   procedure State_Query_Images (D : Simulation)
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => Position_Values (D) = D.State.Qpos.all
       and then Velocity_Values (D) = D.State.Qvel.all
   is
   begin
      null;
   end State_Query_Images;

   procedure Compute_Ready (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Phase_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Actuation.Reduced_Force);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Actuation.Force_Law);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Qpos : constant Real_Array := D.State.Qpos.all with Ghost => Static;
      Initial_Qvel : constant Real_Array := D.State.Qvel.all with Ghost => Static;
      Initial_Position : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Velocity : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Control : constant Real_Array := D.State.Ctrl.all with Ghost => Static;
      Initial_Applied : constant Real_Array := D.State.Applied.all with Ghost => Static;
      Initial_Time : constant Nonneg_Tier0 := D.Clock with Ghost => Static;
   begin
      State_Query_Images (D);
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => Initial_Position = Initial_Qpos);
      pragma Assert (Static => Initial_Velocity = Initial_Qvel);
      pragma Assert (Static => Initial_Inputs = Input_Image (Initial_Control, Initial_Applied));
      D.Cache.Force_Valid := False;
      D.Cache.Actuation_Valid := False;
      D.Activation_Can_Advance := True;
      if D.Nactivation = 0 then
      MJ.Smooth_Actuation.Compute
        (D.Actuator_Config.all, D.State.Qpos.all, D.State.Qvel.all, D.State.Ctrl.all,
         D.Actuation_Enabled, D.Clamp_Control, D.Actuators.Length.all, D.Actuators.Velocity.all,
         D.Actuators.Force.all, D.Dynamics.Actuator.all);
      else
         declare
            Ok : Boolean;
         begin
            MJ.Smooth_Actuation.Compute_Activated
              (D.Actuator_Config.all, D.State.Qpos.all, D.State.Qvel.all, D.State.Ctrl.all,
               D.Activation, D.Timestep, D.Actuation_Enabled, D.Clamp_Control,
               D.Next_Activation, D.Drive, D.Act_Dot, D.Actuators.Length.all,
               D.Actuators.Velocity.all, D.Actuators.Force.all, D.Dynamics.Actuator.all, Ok,
               D.Activation_Can_Advance);
            if not Ok then Result := Numeric_Limit; return; end if;
         end;
      end if;
      D.Cache.Actuation_Valid := True;
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => D.State.Qpos.all = Initial_Qpos);
      pragma Assert (Static => D.State.Qvel.all = Initial_Qvel);
      pragma Assert (Static => D.Clock = Initial_Time);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Caches_Bounded (D));
      pragma Assert (Configuration_Bounded (D));
      pragma Assert (Is_Ready (D));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      State_Query_Images (D);
      MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), D.State.Qpos.all, Initial_Qpos);
      MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Initial_Qpos, Initial_Position);
      MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), D.State.Qvel.all, Initial_Qvel);
      MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Initial_Qvel, Initial_Velocity);
      Equal_Input_Images (D.State.Ctrl.all, Initial_Control, D.State.Applied.all, Initial_Applied);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      pragma Assert (Static => Position_Values (D) = Initial_Position);
      pragma Assert (Static => Velocity_Values (D) = Initial_Velocity);
      Result := Success;
   end Compute_Ready;
   procedure Compute (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Phase_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      --  Both callers already establish readiness; this is a proof, not a scan.
      pragma Assert (Static => Phase_Ready (D));
      declare
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         pragma Assert (Static => Before_Config = Initial_Config);
         Compute_Ready (D, Result);
         pragma Assert (Static => Configuration (D) = Before_Config);
         pragma Assert (Static => Configuration (D) = Initial_Config);
      end;
   end Compute;
end MJ.Data.Actuation_Phase;

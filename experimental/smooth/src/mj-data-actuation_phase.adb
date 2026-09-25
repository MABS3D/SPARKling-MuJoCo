package body MJ.Data.Actuation_Phase with SPARK_Mode is
   procedure Compute (D : in out Simulation; Result : out Status) is
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
      Initial_Time : constant Nonneg_Tier0 := D.Clock with Ghost => Static;
   begin
      if not Phase_Ready (D) then
         Result := Not_Allocated;
         pragma Assert (Static => Stable_Ready (D));
         return;
      end if;
      D.Cache.Force_Valid := False;
      MJ.Smooth_Actuation.Compute
        (D.Actuator_Config.all, D.State.Qpos.all, D.State.Qvel.all, D.State.Ctrl.all,
         D.Actuation_Enabled, D.Clamp_Control, D.Actuators.Length.all, D.Actuators.Velocity.all,
         D.Actuators.Force.all, D.Dynamics.Actuator.all);
      D.Cache.Actuation_Valid := True;
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => D.State.Qpos.all = Initial_Qpos);
      pragma Assert (Static => D.State.Qvel.all = Initial_Qvel);
      pragma Assert (Static => D.Clock = Initial_Time);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Caches_Bounded (D));
      pragma Assert (Configuration_Bounded (D));
      pragma Assert (Is_Ready (D));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Result := Success;
   end Compute;
end MJ.Data.Actuation_Phase;

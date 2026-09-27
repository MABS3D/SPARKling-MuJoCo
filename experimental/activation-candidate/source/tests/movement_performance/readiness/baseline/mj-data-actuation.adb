package body MJ.Data.Actuation with SPARK_Mode is
   procedure Compute (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Actuation.Reduced_Force);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Actuation.Force_Law);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      D.Cache.Force_Valid := False;
      MJ.Smooth_Actuation.Compute
        (D.Actuator_Config.all, D.State.Qpos.all, D.State.Qvel.all, D.State.Ctrl.all,
         D.Actuation_Enabled, D.Clamp_Control, D.Actuators.Length.all, D.Actuators.Velocity.all,
         D.Actuators.Force.all, D.Dynamics.Actuator.all);
      D.Cache.Actuation_Valid := True;
      pragma Assert (Caches_Bounded (D));
      pragma Assert (Configuration_Bounded (D));
      pragma Assert (Is_Ready (D));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Result := Success;
   end Compute;
end MJ.Data.Actuation;

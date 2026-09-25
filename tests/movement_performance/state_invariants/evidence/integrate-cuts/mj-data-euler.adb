with MJ.Data.Forward;
with MJ.Data.Inertia;

package body MJ.Data.Euler with SPARK_Mode is
   procedure Integrate (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Control : constant Real_Array := D.State.Ctrl.all with Ghost => Static;
      Initial_Applied : constant Real_Array := D.State.Applied.all with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Initial_Bodies : constant Body_Parameter_Array := D.Body_Config.all with Ghost => Static;
      Initial_Joints : constant Joint_Parameter_Array := D.Joint_Config.all with Ghost => Static;
      Initial_Actuators : constant Actuator_Parameter_Array := D.Actuator_Config.all with Ghost => Static;
      Next_Time : constant Real := D.Clock + D.Timestep;
      Ok : Boolean;
   begin
      if Next_Time not in Nonneg_Tier0 then
         Result := Numeric_Limit;
         return;
      end if;
      --  Stage both vectors before committing any state; the scalar kernel's
      --  functional contract specifies the exact semi-implicit update.
      MJ.Smooth_Kernels.Stage_Euler
        (D.State.Qpos.all, D.State.Qvel.all, D.Scratch.Solution.all, D.Timestep,
         D.Scratch.Next_Qpos.all, D.Scratch.Next_Qvel.all, Ok);
      pragma Assert (Is_Ready (D));
      Equal_Input_Images (D.State.Ctrl.all, Initial_Control, D.State.Applied.all, Initial_Applied);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if not Ok then
         Result := Numeric_Limit;
         return;
      end if;
      D.State.Qpos.all := D.Scratch.Next_Qpos.all;
      D.State.Qvel.all := D.Scratch.Next_Qvel.all;
      D.Clock := Next_Time;
      Invalidate (D.Cache);
      pragma Assert (MJ.Smooth_Kernels.All_Tier0 (D.State.Qpos.all));
      pragma Assert (MJ.Smooth_Kernels.All_Tier0 (D.State.Qvel.all));
      pragma Assert (Configuration_Bounded (D));
      pragma Assert (Caches_Bounded (D));
      pragma Assert (Is_Ready (D));
      Equal_Input_Images (D.State.Ctrl.all, Initial_Control, D.State.Applied.all, Initial_Applied);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      pragma Assert (Static => D.Body_Config.all = Initial_Bodies);
      pragma Assert (Static => D.Joint_Config.all = Initial_Joints);
      pragma Assert (Static => D.Actuator_Config.all = Initial_Actuators);
      pragma Assert (Static => Configuration (D).Bodies = Initial_Config.Bodies);
      pragma Assert (Static => Configuration (D).Joints = Initial_Config.Joints);
      pragma Assert (Static => Configuration (D).Actuators = Initial_Config.Actuators);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      Result := Success;
   end Integrate;
   procedure Step (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Forces_Current);
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Next_Time : Real;
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         pragma Assert (Static => State_Values (D) = Initial_State);
         return;
      end if;
      Next_Time := Time (D) + Step_Size (D);
      if Next_Time not in Nonneg_Tier0 then
         Result := Numeric_Limit;
         return;
      end if;
      Forward.Evaluate (D, Result);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         pragma Assert (Static => State_Values (D) = Initial_State);
         return;
      end if;
      declare
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      begin
         Inertia.Solve_Euler (D, Result);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
      end;
      if Result /= Success then
         pragma Assert (Static => State_Values (D) = Initial_State);
         return;
      end if;
      declare
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      begin
         Integrate (D, Result);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         if Result /= Success then
            MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
            pragma Assert (Static => State_Values (D) = Initial_State);
         end if;
      end;
   end Step;
end MJ.Data.Euler;

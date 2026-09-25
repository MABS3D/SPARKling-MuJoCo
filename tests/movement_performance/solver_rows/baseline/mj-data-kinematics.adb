with MJ.Data.Pipeline;

package body MJ.Data.Kinematics with SPARK_Mode is
   procedure Update (D : in out Simulation; Result : out Status) is
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
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      if not Is_Ready (D) then
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
         Result := Not_Allocated;
         return;
      end if;
      Pipeline.Update_Poses (D, Result);
      if Result = Success then
         declare
            Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
            Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
            Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
            Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
            Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
         begin
            Pipeline.Ensure_Jacobians (D, Result);
            MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
            MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
            MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
            MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
            Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         end;
      end if;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Update;
end MJ.Data.Kinematics;

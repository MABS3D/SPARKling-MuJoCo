with MJ.Data.Pipeline;

package body MJ.Data.Forward with SPARK_Mode is
   procedure Evaluate (D : in out Simulation; Result : out Status) is
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
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      if not Is_Ready (D) then
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
         Result := Not_Allocated;
         return;
      end if;
      Pipeline.Evaluate_Ready (D, Result);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Evaluate;
end MJ.Data.Forward;

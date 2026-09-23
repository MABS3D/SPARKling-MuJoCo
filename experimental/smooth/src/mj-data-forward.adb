with MJ.Data.Kinematics;
with MJ.Data.Inertia;
with MJ.Data.Forces;
with MJ.Data.Actuation;

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
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
   begin
      Kinematics.Update (D, Result);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      Inertia.Assemble (D, Result);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      Forces.Compute (D, Result);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      Actuation.Compute (D, Result);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         return;
      end if;
      Inertia.Solve_Acceleration (D, Result);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
   end Evaluate;
end MJ.Data.Forward;

private package MJ.Data.Advanced_Control.Evaluation with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Evaluate (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Global => null,
       Post => (Static => State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Activation (E) = Activation (E)'Old and then Inputs (E) = Inputs (E)'Old
         and then Output_Count (E) = Output_Count (E)'Old
         and then Activation (E)'Length = Activation (E)'Old'Length
         and then Velocity_Count (E) = Velocity_Count (E)'Old
         and then (if Result /= Success then
           Capture_Evaluation (E) = Capture_Evaluation (E)'Old));
end MJ.Data.Advanced_Control.Evaluation;

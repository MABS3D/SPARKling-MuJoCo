--  Controller-independent preparation of the shared dynamic state.
private package MJ.Data.Controller_Dynamics with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Prepare (D : in out Simulation; Has_Sites : Boolean; Result : out Status)
     with Pre => (Static => Is_Ready (D));
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
end MJ.Data.Controller_Dynamics;

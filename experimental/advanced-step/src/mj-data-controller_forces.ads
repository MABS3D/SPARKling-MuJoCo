--  Internal admission and publication of controller generalized forces.
private package MJ.Data.Controller_Forces with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   --  Publish only admitted generalized forces. The caller owns one state;
   --  its positions, velocities and user inputs are untouched by this phase.
   procedure Publish
     (D : in out Simulation; Values : Real_Array; Result : out Status)
     with Pre => (Static => Is_Ready (D));
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => (if Result = Success then
     D.Cache.Actuation_Valid and then not D.Cache.Force_Valid
     and then D.Dynamics.Actuator.all = Values));
end MJ.Data.Controller_Forces;

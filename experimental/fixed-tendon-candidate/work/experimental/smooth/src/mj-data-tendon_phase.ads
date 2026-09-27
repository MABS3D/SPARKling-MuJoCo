private package MJ.Data.Tendon_Phase with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Passive (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then D.Tendon_Config /= null,
     Post => Is_Ready (D) and then (if Result = Success then Array_Bounded (D.Dynamics.Passive))
       and then D.Cache = D.Cache'Old;
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then State_Values (D) = State_Values (D)'Old
     and then Input_Values (D) = Input_Values (D)'Old);
   procedure Inertia (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Mass_Current (D) and then Symmetric_Mass (D),
     Post => Is_Ready (D) and then (if Result = Success then Mass_Current (D) and then Symmetric_Mass (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then State_Values (D) = State_Values (D)'Old
     and then Input_Values (D) = Input_Values (D)'Old);
end MJ.Data.Tendon_Phase;

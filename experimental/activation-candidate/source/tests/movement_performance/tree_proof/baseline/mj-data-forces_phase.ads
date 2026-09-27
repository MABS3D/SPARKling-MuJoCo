--  Review draft. Bias is the velocity-dependent inertial term only;
--  gravity is a separate physical generalized force, with positive sign.
private package MJ.Data.Forces_Phase with SPARK_Mode is
   --  These total value queries are safe to snapshot unconditionally on entry.
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Compute (D : in out Simulation; Result : out Status) with Global => null, Pre => Stable_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Passive_Current (D));
   pragma Postcondition (Stable_Ready (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

end MJ.Data.Forces_Phase;

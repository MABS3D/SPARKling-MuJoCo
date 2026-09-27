--  Review draft. Evaluate unconstrained dynamics at the current state.
--  Does not advance qpos, qvel, controls, applied forces or time.
package MJ.Data.Forward with SPARK_Mode is
   --  These total value queries are safe to snapshot unconditionally on entry.
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Evaluate (D : in out Simulation; Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Positions_Current (D) and then Forces_Current (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

end MJ.Data.Forward;

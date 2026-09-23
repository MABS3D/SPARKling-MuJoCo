--  Review draft. World-frame poses, origin velocities and COM Jacobians.
package MJ.Data.Kinematics with SPARK_Mode is
   --  These total value queries are safe to snapshot unconditionally on entry.
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Update (D : in out Simulation; Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Positions_Current (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

end MJ.Data.Kinematics;

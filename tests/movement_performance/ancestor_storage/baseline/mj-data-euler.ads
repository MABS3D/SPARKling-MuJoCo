--  Review draft. Semi-implicit Euler, including optional implicit linear
--  damping as in mj_Euler. A returned failure leaves qpos/qvel/time unchanged;
--  derived buffers and scratch may have been recomputed.
package MJ.Data.Euler with SPARK_Mode is
   --  These total value queries are safe to snapshot unconditionally on entry.
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Step (D : in out Simulation; Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old;
   pragma Postcondition (Is_Ready (D) = Is_Ready (D)'Old);
   pragma Postcondition (Shape (D) = Shape (D)'Old);
   pragma Postcondition (Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (if Result = Success then Is_Ready (D));
   pragma Postcondition (if Result = Success then Time (D) = Time (D)'Old + Step_Size (D)'Old);
   pragma Postcondition (if Result = Success then not Positions_Current (D) and then not Forces_Current (D));
   pragma Postcondition (if Result /= Success then State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);

   pragma Postcondition (Static => (if Result = Success then
     MJ.Smooth_Kernels.Euler_Update (Position_Values (D)'Old, Velocity_Values (D)'Old,
       Step_Rates (D), Position_Values (D), Velocity_Values (D), Step_Size (D)'Old)));
private
   procedure Integrate (D : in out Simulation; Result : out Status) with Global => null, Pre => Is_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old;
   pragma Postcondition (Is_Ready (D));
   pragma Postcondition (Shape (D) = Shape (D)'Old);
   pragma Postcondition (Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (if Result = Success then Is_Ready (D));
   pragma Postcondition (if Result = Success then Time (D) = Time (D)'Old + Step_Size (D)'Old);
   pragma Postcondition (if Result = Success then not Positions_Current (D) and then not Forces_Current (D));
   pragma Postcondition (if Result /= Success then State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);

   pragma Postcondition (Static => (if Result = Success then
     MJ.Smooth_Kernels.Euler_Update (Position_Values (D)'Old, Velocity_Values (D)'Old,
       Step_Rates (D), Position_Values (D), Velocity_Values (D), Step_Size (D)'Old)));
end MJ.Data.Euler;

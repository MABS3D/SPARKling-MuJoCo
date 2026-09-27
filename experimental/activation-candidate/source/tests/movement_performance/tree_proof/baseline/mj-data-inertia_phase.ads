--  Compatible factors use compact full ancestor rows; strict retains the
--  dense diagnostic solver. Public mass entries use row * nv + column.
private package MJ.Data.Inertia_Phase with SPARK_Mode is
   --  These total value queries are safe to snapshot unconditionally on entry.
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Assemble (D : in out Simulation; Result : out Status) with Global => null, Pre => Stable_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Mass_Current (D)
         and then Symmetric_Mass (D));
   pragma Postcondition (Stable_Ready (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

   procedure Solve_Acceleration (D : in out Simulation; Result : out Status) with Global => null, Pre => Stable_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Forces_Current (D));
   pragma Postcondition (Stable_Ready (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);


   --  Reuses the current smooth RHS and solves (M + h*diag(damping))*a = RHS.
   --  The result is scratch data for Euler; stored forward qacc is preserved.
   procedure Solve_Euler (D : in out Simulation; Result : out Status) with Global => null, Pre => Stable_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Forces_Current (D));
   pragma Postcondition (Stable_Ready (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

end MJ.Data.Inertia_Phase;

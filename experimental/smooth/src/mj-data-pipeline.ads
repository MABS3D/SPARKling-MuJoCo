--  Internal composition: callers establish readiness before entering.
--  Jacobians are materialized only by the public kinematics API or a fallback.
private package MJ.Data.Pipeline with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Update_Poses
     (D : in out Simulation; Result : out Status; With_Cartesian_Motion : Boolean := False) with Global => null, Pre => Is_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then not D.Cache.Jacobian_Valid
       and then (if Result = Success then Is_Ready (D) and then Positions_Current (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

   pragma Postcondition (Stable_Ready (D));

   procedure Ensure_Cartesian_Motion (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D),
     Post => Is_Ready (D) and then Positions_Current (D)
       and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Mass_Current (D) = Mass_Current (D)'Old
       and then Passive_Current (D) = Passive_Current (D)'Old
       and then Actuation_Current (D) = Actuation_Current (D)'Old
       and then Forces_Current (D) = Forces_Current (D)'Old
       and then (if Result = Success then D.Cache.Cartesian_Motion_Valid);
   pragma Postcondition (Stable_Ready (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

   procedure Ensure_Jacobians (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D),
     Post => Is_Ready (D) and then Positions_Current (D)
       and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Mass_Current (D) = Mass_Current (D)'Old
       and then Passive_Current (D) = Passive_Current (D)'Old
       and then Actuation_Current (D) = Actuation_Current (D)'Old
       and then Forces_Current (D) = Forces_Current (D)'Old
       and then (if Result = Success then D.Cache.Jacobian_Valid);
   pragma Postcondition (Stable_Ready (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

   procedure Evaluate_Ready (D : in out Simulation; Result : out Status) with Global => null, Pre => Is_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Positions_Current (D) and then Forces_Current (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

end MJ.Data.Pipeline;

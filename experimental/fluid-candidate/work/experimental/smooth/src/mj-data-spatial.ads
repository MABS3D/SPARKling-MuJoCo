--  Shared comPos preparation for CRB and recursive inverse dynamics.
private package MJ.Data.Spatial with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Prepare (D : in out Simulation; Ok : out Boolean)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid,
     Post => Is_Ready (D) and then D.Cache.Pose_Valid
       and then (if Ok then D.Cache.Spatial_Valid and then Spatial_Bounded (D.Kinematic))
       and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then Mass_Current (D) = Mass_Current (D)'Old
       and then Passive_Current (D) = Passive_Current (D)'Old
       and then Actuation_Current (D) = Actuation_Current (D)'Old
       and then Forces_Current (D) = Forces_Current (D)'Old;
   pragma Postcondition (Stable_Ready (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);
end MJ.Data.Spatial;

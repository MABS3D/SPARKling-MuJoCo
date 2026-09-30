--  Integration point shared by Forward, Euler and the public Forces API.
private package MJ.Data.Spatial_Tendon_Phase with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Compute_Passive (D : in out Simulation; Result : out Status) with
     Global => null,
     Pre => Is_Ready (D) and then Positions_Current (D)
       and then not D.Cache.Passive_Valid,
     Post => (Static => Is_Ready (D) and then Stable_Ready (D)
       and then Shape (D) = Shape (D)'Old
       and then Configuration (D) = Configuration (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then Position_Values (D) = Position_Values (D)'Old
       and then Velocity_Values (D) = Velocity_Values (D)'Old
       and then not D.Cache.Passive_Valid
       and then D.Dynamics.Gravity.all = D.Dynamics.Gravity.all'Old
       and then D.Dynamics.Bias.all = D.Dynamics.Bias.all'Old
       and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
       and then (if Result = Success then Array_Bounded (D.Dynamics.Passive)
         and then (if D.Tendons /= null then Array_Bounded (D.Tendon_Outputs, 4.0e103))));
end MJ.Data.Spatial_Tendon_Phase;

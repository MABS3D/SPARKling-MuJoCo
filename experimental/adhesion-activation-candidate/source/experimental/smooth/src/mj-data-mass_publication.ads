with MJ.Smooth_Dynamics;
private package MJ.Data.Mass_Publication with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   --  Publish an already bounded symmetric dense mass without inspecting it
   --  at runtime. Its producer remains responsible for proving these inputs.
   procedure Publish (D : in out Simulation; Mass : Real_Array)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid
       and then MJ.Smooth_Dynamics.Square_Layout (Mass, D.Nv)
       and then MJ.Smooth_Dynamics.Work_Array (Mass)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, D.Nv),
     Post => Is_Ready (D) and then Mass_Current (D) and then Symmetric_Mass (D)
       and then not Forces_Current (D)
       and then Passive_Current (D) = Passive_Current (D)'Old
       and then Actuation_Current (D) = Actuation_Current (D)'Old
       and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then D.Dynamics.Mass.all = Mass;
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);
   procedure Mark_Ready (D : in out Simulation)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid
       and then MJ.Smooth_Dynamics.Square_Layout (D.Dynamics.Mass.all, D.Nv)
       and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Mass.all)
       and then MJ.Smooth_Dynamics.Symmetric (D.Dynamics.Mass.all, D.Nv),
     Post => Is_Ready (D) and then Mass_Current (D) and then Symmetric_Mass (D)
       and then not Forces_Current (D)
       and then Passive_Current (D) = Passive_Current (D)'Old
       and then Actuation_Current (D) = Actuation_Current (D)'Old
       and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then D.Dynamics.Mass.all = D.Dynamics.Mass.all'Old;
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);
end MJ.Data.Mass_Publication;

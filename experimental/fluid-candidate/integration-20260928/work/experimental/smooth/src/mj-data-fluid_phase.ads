with MJ.Smooth_Dynamics;
private package MJ.Data.Fluid_Phase with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Initialize
     (M : MJ.Models.Model; Bodies : Body_Parameter_Array;
      Spring_Enabled, Damper_Enabled : Boolean; Fluid : out Fluid_Options;
      Elements : in out MJ.Fluid_Kernels.Element_Access; Result : out Status)
     with Global => null,
     Pre => Elements = null and then MJ.Models.Sizes_In_Range (M.S)
       and then MJ.Models.Geom_Layout_OK (M.S, M.Geoms)
       and then Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
       and then Bodies'Length = M.S.Nbody
       and then (for all B of Bodies => Bounded (B.Inertial_Position, Max_Val)
         and then Bounded (B.Inertia, Max_Val) and then Unit_Quaternion (B.Inertial_Orientation)),
     Post => MJ.Fluid_Kernels.Storage_Valid (Elements, Bodies'Length)
       and then (if Result /= Success then Elements = null)
       and then (if Result = Success then Fluid.Density = M.Opt.Density
         and then Fluid.Viscosity = M.Opt.Viscosity and then Fluid.Wind = Read_Vector (M.Opt.Wind, 0));
   procedure Release (Elements : in out MJ.Fluid_Kernels.Element_Access; Fluid : out Fluid_Options)
     with Global => null,
     Post => Elements = null and then Fluid = Fluid_Options'(others => <>);
   procedure Accumulate (D : in out Simulation; Result : out Status;
                         Root_Velocity : MJ.Fluid_Kernels.Motion_Array := MJ.Fluid_Kernels.No_Motions)
     with Global => null,
     Pre => Is_Ready (D) and then Positions_Current (D)
       and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Passive.all)
       and then (if Root_Velocity'Length /= 0 then
         Root_Velocity'First = 0 and then Root_Velocity'Length in 1 .. Max_Bodies
         and then Root_Velocity'Length = D.Nb
         and then MJ.Fluid_Kernels.Motions_Bounded (Root_Velocity)
         and then D.Cache.Spatial_Valid),
     Post => (Static => Is_Ready (D));
   pragma Postcondition (Static => Stable_Ready (D));
   pragma Postcondition (Static => D.Cache = D.Cache'Old);
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);
   pragma Postcondition (Static => Position_Values (D) = Position_Values (D)'Old);
   pragma Postcondition (Static => Velocity_Values (D) = Velocity_Values (D)'Old);
   pragma Postcondition (Static => Positions_Current (D) = Positions_Current (D)'Old);
   pragma Postcondition (Static => Time (D) = Time (D)'Old);
   pragma Postcondition (Static => Step_Size (D) = Step_Size (D)'Old);
   pragma Postcondition (Static => D.Dynamics.Gravity.all = D.Dynamics.Gravity.all'Old);
   pragma Postcondition (Static => D.Dynamics.Bias.all = D.Dynamics.Bias.all'Old);
   pragma Postcondition (Static => MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Passive.all));
end MJ.Data.Fluid_Phase;

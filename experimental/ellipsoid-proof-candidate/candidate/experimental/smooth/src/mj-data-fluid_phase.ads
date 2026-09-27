private package MJ.Data.Fluid_Phase with SPARK_Mode is
   procedure Initialize (M : MJ.Models.Model; D : in out Simulation; Result : out Status)
     with Global => null;
   procedure Release (D : in out Simulation) with Global => null,
     Post => D.Fluid_Elements = null;
   procedure Accumulate (D : in out Simulation; Result : out Status;
                         Root_Velocity : MJ.Fluid_Kernels.Motion_Array := MJ.Fluid_Kernels.No_Motions)
     with Global => null,
     Pre => Is_Ready (D) and then Positions_Current (D);
end MJ.Data.Fluid_Phase;

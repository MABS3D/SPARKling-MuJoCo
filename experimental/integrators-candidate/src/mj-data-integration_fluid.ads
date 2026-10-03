private package MJ.Data.Integration_Fluid with SPARK_Mode is
   procedure Add (D : in out Simulation; Drag_Only, Symmetrize_Nonfree : Boolean;
                  Deriv : in out Real_Array; Result : out Status)
     with Global => null, Pre => Is_Ready (D);
end MJ.Data.Integration_Fluid;

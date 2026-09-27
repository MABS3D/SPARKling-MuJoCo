package body MJ.Gravity_Bounds with SPARK_Mode is
   procedure Bound_Sum (A, B : Real; NA, NB : Weight) is
   begin
      null;
   end Bound_Sum;
   procedure Budget_Bounds (N : Weight) is
   begin
      null;
   end Budget_Bounds;
   procedure Bound_Wrench_Sum
     (A, B : MJ.Spatial_Kernels.Motion; NA, NB : Weight)
   is
   begin
      Bound_Sum (A (0), B (0), NA, NB);
      Bound_Sum (A (1), B (1), NA, NB);
      Bound_Sum (A (2), B (2), NA, NB);
      Bound_Sum (A (3), B (3), NA, NB);
      Bound_Sum (A (4), B (4), NA, NB);
      Bound_Sum (A (5), B (5), NA, NB);
   end Bound_Wrench_Sum;
end MJ.Gravity_Bounds;

package body MJ.Site_Kinematics with SPARK_Mode is
   function World_Coordinate
     (Origin, R0, R1, R2, X, Y, Z : Real) return Real is
   begin
      return ((R0 * X + R1 * Y) + R2 * Z) + Origin;
   end World_Coordinate;

   function Point_Column
     (Linear, Angular_A, Angular_B, Offset_A, Offset_B : Real) return Real is
   begin
      return Linear + (Angular_A * Offset_B - Angular_B * Offset_A);
   end Point_Column;
end MJ.Site_Kinematics;

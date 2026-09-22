package body MJ.BLAS with SPARK_Mode is
   function Add3 (A, B : Vector_3) return Vector_3 is
   begin
      return [A (0) + B (0), A (1) + B (1), A (2) + B (2)];
   end Add3;

   function Sub3 (A, B : Vector_3) return Vector_3 is
   begin
      return [A (0) - B (0), A (1) - B (1), A (2) - B (2)];
   end Sub3;

   function Scl3 (A : Vector_3; Scale : Tier0_Real) return Vector_3 is
   begin
      return [A (0) * Scale, A (1) * Scale, A (2) * Scale];
   end Scl3;

   function Dot3 (A, B : Vector_3) return Tier1_Real is
   begin
      return ((A (0) * B (0)) + (A (1) * B (1))) + (A (2) * B (2));
   end Dot3;
end MJ.BLAS;

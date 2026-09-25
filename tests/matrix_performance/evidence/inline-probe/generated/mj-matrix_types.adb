package body MJ.Matrix_Types with SPARK_Mode is
   function Row (A : Matrix; I : Natural) return Real_Array is
      R : Real_Array (0 .. A'Length (2) - 1) := [others => 0.0];
   begin
      for J in R'Range loop
         R (J) := A (I, J);
         pragma Loop_Invariant (for all K in 0 .. J => R (K) = A (I, K));
      end loop;
      return R;
   end Row;
   function Column (A : Matrix; J : Natural) return Real_Array is
      R : Real_Array (0 .. A'Length (1) - 1) := [others => 0.0];
   begin
      for I in R'Range loop
         R (I) := A (I, J);
         pragma Loop_Invariant (for all K in 0 .. I => R (K) = A (K, J));
      end loop;
      return R;
   end Column;
end MJ.Matrix_Types;

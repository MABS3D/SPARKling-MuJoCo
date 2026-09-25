package body MJ.Solver_Kernels with SPARK_Mode is
   function Clamp_Pivot (Value : Work_Real) return Positive_Pivot is
     (if Value < Min_Val then Min_Val else Value);
   function Reciprocal (Value : Positive_Pivot) return Inverse_Real is (1.0 / Value);
   function Scale (Value : Work_Real; Inverse : Inverse_Real) return Scale_Real is
     (Value * Inverse);
   function Add_Product (Previous, Value : Work_Real; Multiplier : Scale_Real)
     return Update_Real is (Previous + Value * Multiplier);
end MJ.Solver_Kernels;

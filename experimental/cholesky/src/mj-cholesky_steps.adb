package body MJ.Cholesky_Steps with SPARK_Mode is
   function Product (A, B : Operand) return Product_Value is (A * B);

   function Update_Square (Diagonal, X : Wide_Operand; Plus : Boolean)
     return Squared is
     (Diagonal * Diagonal + (if Plus then X * X else (-X) * X));

   function Clamp (Value : Real; Minimum : Threshold) return Real is
     (if Value < Minimum then Minimum else Value);

   function Root (Value : Real; Minimum : Threshold) return Real is
     (MJ.Quaternion_Math.Sqrt (Clamp (Value, Minimum)));

   function Factor_Entry (Original, Dot : Operand; Inverse : Operand)
     return Real is ((Original - Dot) * Inverse);

   function Update_Entry (Original, S, X, Inverse_C : Operand;
                          Plus : Boolean) return Real is
     (if Plus then (Original + S * X) * Inverse_C
      else (Original - S * X) * Inverse_C);

   function Update_Vector (C, X, S, New_Entry : Wide_Operand) return Real is
     (C * X - S * New_Entry);
end MJ.Cholesky_Steps;

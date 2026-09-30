with MJ.Types; use MJ.Types;
with MJ.Quaternion_Math;

--  Rounded scalar equations used by the dense Cholesky algorithms.
package MJ.Cholesky_Steps with SPARK_Mode is
   subtype Operand is Real range -1.0e100 .. 1.0e100;
   subtype Wide_Operand is Real range -1.0e150 .. 1.0e150;
   subtype Squared is Real range -2.1e300 .. 2.1e300;
   subtype Threshold is Real range Min_Val .. 1.0e60;

   subtype Product_Value is Real range -1.1e200 .. 1.1e200;
   function Product (A, B : Operand) return Product_Value
     with Global => null, Inline_Always,
     Post => Product'Result = A * B;

   function Update_Square (Diagonal, X : Wide_Operand; Plus : Boolean)
     return Squared with Global => null,
     Post => Update_Square'Result =
       Diagonal * Diagonal + (if Plus then X * X else (-X) * X);

   function Clamp (Value : Real; Minimum : Threshold) return Real
     with Global => null,
     Post => Clamp'Result = (if Value < Minimum then Minimum else Value)
       and then Clamp'Result >= Minimum;

   function Root (Value : Real; Minimum : Threshold) return Real
     with Global => null,
     Post => Root'Result = MJ.Quaternion_Math.Sqrt (Clamp (Value, Minimum));

   function Factor_Entry (Original, Dot : Operand; Inverse : Operand)
     return Real with Global => null,
     Post => Factor_Entry'Result = (Original - Dot) * Inverse;

   function Update_Entry (Original, S, X, Inverse_C : Operand;
                          Plus : Boolean) return Real
     with Global => null,
     Post => Update_Entry'Result =
       (if Plus then (Original + S * X) * Inverse_C
        else (Original - S * X) * Inverse_C);

   function Update_Vector (C, X, S, New_Entry : Wide_Operand) return Real
     with Global => null,
     Post => Update_Vector'Result = C * X - S * New_Entry;
end MJ.Cholesky_Steps;

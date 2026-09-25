with MJ.Types; use MJ.Types;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;

package MJ.Solver_Kernels with SPARK_Mode is
   subtype Positive_Pivot is Real range Min_Val .. 1.0e60;
   subtype Inverse_Real is Real range 1.0e-61 .. 1.0e15;
   subtype Scale_Real is Real range -1.0e76 .. 1.0e76;
   subtype Update_Real is Real range -1.0e137 .. 1.0e137;
   function Clamp_Pivot (Value : Work_Real) return Positive_Pivot
     with Global => null,
     Post => Clamp_Pivot'Result = (if Value < Min_Val then Min_Val else Value);
   function Reciprocal (Value : Positive_Pivot) return Inverse_Real
     with Global => null, Post => Reciprocal'Result = 1.0 / Value;
   function Scale (Value : Work_Real; Inverse : Inverse_Real) return Scale_Real
     with Global => null, Post => Scale'Result = Value * Inverse;
   function Add_Product (Previous, Value : Work_Real; Multiplier : Scale_Real)
     return Update_Real with Global => null,
     Post => Add_Product'Result = Previous + Value * Multiplier;
end MJ.Solver_Kernels;

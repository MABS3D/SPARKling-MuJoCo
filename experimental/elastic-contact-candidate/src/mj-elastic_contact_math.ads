with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with Ada.Numerics.Long_Elementary_Functions;

package MJ.Elastic_Contact_Math with SPARK_Mode is
   --  Bounds are calculation budgets, not physical clipping thresholds.
   subtype Scalar is Real range -1.0e100 .. 1.0e100;
   subtype Positive_Scalar is Real range Min_Val .. 1.0e100;
   subtype Inverse_Sum is Real range Min_Val .. 5.0e15;
   subtype Contact_Impedance is Real range 0.00001 .. 1.0;
   function Regularizer (I : Contact_Impedance; Inv : Inverse_Sum) return Real
     with Global => null, Post => Regularizer'Result in Min_Val .. 1.0e21
       and then Regularizer'Result = Real'Max (Min_Val, ((1.0-I)*Inv)/I);
   function Dot (A, B : Vector) return Real with Global => null,
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => Dot'Result in -4.0e200 .. 4.0e200 and then
       Dot'Result = (A (0)*B (0) + A (1)*B (1)) + A (2)*B (2);
   function Cross (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => Bounded (Cross'Result, 3.0e200) and then
       Cross'Result = [A (1)*B (2)-A (2)*B (1),
                       A (2)*B (0)-A (0)*B (2),
                       A (0)*B (1)-A (1)*B (0)];
   function Add (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => Bounded (Add'Result, 3.0e100) and then
       (for all K in Axis => Add'Result (K) = A (K)+B (K));
   function Sub (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e100) and then Bounded (B, 1.0e100),
     Post => Bounded (Sub'Result, 3.0e100) and then
       (for all K in Axis => Sub'Result (K) = A (K)-B (K));
   function Scale (A : Vector; S : Scalar) return Vector with Global => null,
     Pre => Bounded (A, 1.0e100),
     Post => Bounded (Scale'Result, 2.0e200) and then
       (for all K in Axis => Scale'Result (K) = A (K)*S);
   function Norm (A : Vector) return Real with Global => null,
     Pre => Bounded (A, 1.0e100),
     Post => Norm'Result >= 0.0 and then Norm'Result =
       Ada.Numerics.Long_Elementary_Functions.Sqrt
         ((A (0)*A (0)+A (1)*A (1))+A (2)*A (2));
   function Clip (X : Scalar) return Real with Global => null,
     Post => Clip'Result in -1.0 .. 1.0 and then
       Clip'Result = Real'Max (-1.0, Real'Min (1.0, X));
   --  One projected Gauss-Seidel update, with the CURRENT coupled residual.
   function Project (Old_Force : Scalar; Residual : Scalar;
                     Diagonal : Positive_Scalar) return Real with Global => null,
     Post => Project'Result in 0.0 .. 2.0e115 and then
       Project'Result = Real'Max (0.0, Old_Force-Residual*(1.0/Diagonal));
   function Scatter (Old_Value, Jacobian, Force : Scalar) return Real with Global => null,
     Post => Scatter'Result in -2.0e200 .. 2.0e200 and then
       Scatter'Result = Old_Value+Jacobian*Force;
   function Weighted_Inverse (Distance : Real) return Real with Global => null,
     Pre => Distance in 0.0 .. 1.0e100,
     Post => Weighted_Inverse'Result in 0.0 .. 1.0e15 and then
       Weighted_Inverse'Result = 1.0/Real'Max (Min_Val, Distance);
end MJ.Elastic_Contact_Math;

with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
package body MJ.Elastic_Contact_Math with SPARK_Mode is
   function Regularizer (I : Contact_Impedance; Inv : Inverse_Sum) return Real is
   begin return Real'Max (Min_Val, ((1.0-I)*Inv)/I); end Regularizer;
   function Dot (A, B : Vector) return Real is
   begin return (A (0)*B (0)+A (1)*B (1))+A (2)*B (2); end Dot;
   function Cross (A, B : Vector) return Vector is
   begin return [A (1)*B (2)-A (2)*B (1), A (2)*B (0)-A (0)*B (2),
                 A (0)*B (1)-A (1)*B (0)]; end Cross;
   function Add (A, B : Vector) return Vector is
   begin
      return [A (0)+B (0), A (1)+B (1), A (2)+B (2)];
   end Add;
   function Sub (A, B : Vector) return Vector is
   begin
      return [A (0)-B (0), A (1)-B (1), A (2)-B (2)];
   end Sub;
   function Scale (A : Vector; S : Scalar) return Vector is
   begin
      return [A (0)*S, A (1)*S, A (2)*S];
   end Scale;
   function Norm (A : Vector) return Real is
   begin return Sqrt ((A (0)*A (0)+A (1)*A (1))+A (2)*A (2)); end Norm;
   function Clip (X : Scalar) return Real is
   begin return Real'Max (-1.0, Real'Min (1.0, X)); end Clip;
   function Project (Old_Force : Scalar; Residual : Scalar;
                     Diagonal : Positive_Scalar) return Real is
   begin return Real'Max (0.0, Old_Force-Residual*(1.0/Diagonal)); end Project;
   function Scatter (Old_Value, Jacobian, Force : Scalar) return Real is
   begin return Old_Value+Jacobian*Force; end Scatter;
   function Weighted_Inverse (Distance : Real) return Real is
   begin return 1.0/Real'Max (Min_Val, Distance); end Weighted_Inverse;
end MJ.Elastic_Contact_Math;

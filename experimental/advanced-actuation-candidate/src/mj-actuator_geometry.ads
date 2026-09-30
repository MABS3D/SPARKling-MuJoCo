with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
package MJ.Actuator_Geometry with SPARK_Mode is
   package Model with Ghost => Static is
      function Norm4 (Q : Quaternion) return Real is
        (Math.Sqrt (((Q (0)*Q (0)+Q (1)*Q (1))+Q (2)*Q (2))+Q (3)*Q (3)))
        with Pre => Bounded (Q,1.0e10);
      function Normalized (Q : Quaternion) return Quaternion is
        (declare N : constant Real := Norm4 (Q);
         begin (if N<Min_Val then Identity elsif abs (N-1.0)<=Min_Val then Q
         else (Q (0)*(1.0/N),Q (1)*(1.0/N),Q (2)*(1.0/N),Q (3)*(1.0/N))))
        with Pre => Bounded (Q,1.0e10);
   end Model;
   function Normalize (Q : Quaternion) return Quaternion with
     Pre => Bounded (Q,1.0e10), Post => Bounded (Normalize'Result,1.0e26);
   pragma Postcondition (Static => Normalize'Result=Model.Normalized (Q));
   function Conjugate (Q : Quaternion) return Quaternion is ((Q (0),-Q (1),-Q (2),-Q (3)));
   function Multiply (A, B : Quaternion) return Quaternion with
     Pre => Bounded (A,1.0e26) and then Bounded (B,1.0e26),
     Post => Bounded (Multiply'Result,1.0e53)
       and then Multiply'Result=(((A (0)*B (0)-A (1)*B (1))-A (2)*B (2))-A (3)*B (3),
         ((A (0)*B (1)+A (1)*B (0))+A (2)*B (3))-A (3)*B (2),
         ((A (0)*B (2)-A (1)*B (3))+A (2)*B (0))+A (3)*B (1),
         ((A (0)*B (3)+A (1)*B (2))-A (2)*B (1))+A (3)*B (0));
   function Rotate (V : Vector; Q : Quaternion) return Vector with
     Pre => Bounded (V,1.0e10) and then Bounded (Q,1.0e26),
     Post => Bounded (Rotate'Result,1.0e64);
   function Log (Q : Quaternion) return Vector with Pre => Bounded (Q,1.0e53);
   function Difference (Target, Current : Quaternion) return Vector with
     Pre => Bounded (Target,1.0e26) and then Bounded (Current,1.0e26);
   function Expmap (V : Vector) return Quaternion with
     Pre => Bounded (V,1.0e10), Post => Bounded (Expmap'Result,1.0e26);
   function Mat_Vector (M : Matrix; V : Vector; Transpose : Boolean := False) return Vector with
     Pre => Bounded (V,1.0e10), Post => Bounded (Mat_Vector'Result,1.0e21)
       and then (for all I in 0 .. 2 => Mat_Vector'Result (I)=
         (if Transpose then (M (0,I)*V (0)+M (1,I)*V (1))+M (2,I)*V (2)
          else (M (I,0)*V (0)+M (I,1)*V (1))+M (I,2)*V (2)));
   type Slider_Result is record
      Length : Real := 0.0;
      DA, DV : Vector := Zero;
      Feasible : Boolean := False;
   end record;
   function Slider (Axis, Displacement : Vector; Rod : Input) return Slider_Result with
     Pre => Bounded (Axis,1.0e10) and then Bounded (Displacement,1.0e10);
   function SO3_Force (Error, Speed : Vector; KP, Constant_Bias, KV : Input) return Vector with
     Pre => Bounded (Error,1.0e10) and then Bounded (Speed,1.0e10),
     Post => (for all K in 0 .. 2 => SO3_Force'Result (K)=(KP*Error (K)+Constant_Bias)+KV*Speed (K));
   function Limit_Norm (Force : Vector; Limit : Nonneg_Tier0) return Vector with Pre => Bounded (Force,1.0e40);
end MJ.Actuator_Geometry;

with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
with MJ.Trigonometry;
package MJ.Actuator_Geometry with SPARK_Mode is
   function Expmap_Term (X, N, S : Real) return Real with Inline_Always,
     Pre => X in -1.0e10 .. 1.0e10 and then N >= Min_Val
       and then S in -1.0 .. 1.0,
     Post => Expmap_Term'Result in -1.0e26 .. 1.0e26
       and then Expmap_Term'Result = (X/N)*S;
   function Expmap_Norm (V : Vector) return Real is
     (Math.Sqrt ((V (0)*V (0)+V (1)*V (1))+V (2)*V (2)))
     with Global => null, Inline_Always,
       Pre => Bounded (V,1.0e10), Post => Expmap_Norm'Result >= 0.0;
   function Expmap_Sine (N : Real) return Real is (Math.Sin (N*0.5))
     with Global => null, Inline_Always,
       Post => Expmap_Sine'Result in -1.0 .. 1.0;
   subtype Normalization_Scale is Real range 0.0 .. 1.1e15;
   function Normalize_Norm (Q : Quaternion) return Real is
     (Math.Sqrt (((Q (0)*Q (0)+Q (1)*Q (1))+Q (2)*Q (2))+Q (3)*Q (3)))
     with Global => null, Inline_Always,
       Pre => Bounded (Q,1.0e10), Post => Normalize_Norm'Result >= 0.0;
   function Normalize_Reciprocal (N : Real) return Normalization_Scale
     with Global => null, Inline_Always, Pre => N >= Min_Val,
       Post => Normalize_Reciprocal'Result = 1.0/N;
   function Normalize_Term (X : Real; Inv : Normalization_Scale) return Real
     with Global => null, Inline_Always, Pre => X in -1.0e10 .. 1.0e10,
       Post => Normalize_Term'Result in -1.0e26 .. 1.0e26
         and then Normalize_Term'Result = X*Inv;
   package Model with Ghost => Static is
      function Expmap (V : Vector) return Quaternion is
        (declare N : constant Real := Expmap_Norm (V);
         begin (if N<Min_Val then Identity else
           (MJ.Trigonometry.Cosine (N*0.5),
            Expmap_Term (V (0),N,Expmap_Sine (N)),
            Expmap_Term (V (1),N,Expmap_Sine (N)),
            Expmap_Term (V (2),N,Expmap_Sine (N)))))
        with Pre => Bounded (V,1.0e10), Post => Bounded (Expmap'Result,1.0e26);
      function Norm4 (Q : Quaternion) return Real is (Normalize_Norm (Q))
        with Pre => Bounded (Q,1.0e10);
      function Normalized (Q : Quaternion) return Quaternion is
        (declare N : constant Real := Norm4 (Q);
         begin (if N<Min_Val then Identity elsif abs (N-1.0)<=Min_Val then Q
         else (declare Inv : constant Normalization_Scale := Normalize_Reciprocal (N);
           begin (Normalize_Term (Q (0),Inv),Normalize_Term (Q (1),Inv),
                  Normalize_Term (Q (2),Inv),Normalize_Term (Q (3),Inv)))))
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
   pragma Postcondition (Static => Expmap'Result = Model.Expmap (V));
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

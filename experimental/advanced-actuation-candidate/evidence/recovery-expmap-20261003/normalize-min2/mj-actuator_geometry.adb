with Ada.Numerics;
with MJ.Trigonometry;
package body MJ.Actuator_Geometry with SPARK_Mode is
   function Expmap_Term (X, N, S : Real) return Real is
      subtype Axis_Component is Real range -1.1e25 .. 1.1e25;
      Axis : constant Axis_Component := X/N;
   begin
      return Axis*S;
   end Expmap_Term;
   function Normalize_Reciprocal (N : Real) return Normalization_Scale is (1.0/N);
   function Normalize_Term (X : Real; Inv : Normalization_Scale) return Real is (X*Inv);
   subtype Q_Component is Real range -1.0e26 .. 1.0e26;
   subtype Q_Product is Real range -1.1e52 .. 1.1e52;
   subtype Q_Two_Terms is Real range -2.3e52 .. 2.3e52;
   subtype Q_Three_Terms is Real range -3.5e52 .. 3.5e52;
   subtype Q_Four_Terms is Real range -5.0e52 .. 5.0e52;
   function Product (A, B : Q_Component) return Q_Product is (A*B)
     with Post => Product'Result=A*B;
   function Normalize (Q : Quaternion) return Quaternion is
      N : constant Real := Normalize_Norm (Q);
      R : Quaternion := Q;
      Inv : Normalization_Scale;
   begin
      if N<Min_Val then return Identity;
      elsif abs (N-1.0)>Min_Val then
         Inv := Normalize_Reciprocal (N);
         for K in 0 .. 3 loop R (K) := Normalize_Term (Q (K),Inv); end loop;
      end if;
      return R;
   end Normalize;
   function Multiply (A, B : Quaternion) return Quaternion is
      T0 : constant Q_Two_Terms := Product (A (0),B (0))-Product (A (1),B (1));
      T1 : constant Q_Two_Terms := Product (A (0),B (1))+Product (A (1),B (0));
      T2 : constant Q_Two_Terms := Product (A (0),B (2))-Product (A (1),B (3));
      T3 : constant Q_Two_Terms := Product (A (0),B (3))+Product (A (1),B (2));
      U0 : constant Q_Three_Terms := T0-Product (A (2),B (2));
      U1 : constant Q_Three_Terms := T1+Product (A (2),B (3));
      U2 : constant Q_Three_Terms := T2+Product (A (2),B (0));
      U3 : constant Q_Three_Terms := T3-Product (A (2),B (1));
      R0 : constant Q_Four_Terms := U0-Product (A (3),B (3));
      R1 : constant Q_Four_Terms := U1-Product (A (3),B (2));
      R2 : constant Q_Four_Terms := U2+Product (A (3),B (1));
      R3 : constant Q_Four_Terms := U3+Product (A (3),B (0));
   begin return (R0,R1,R2,R3); end Multiply;
   function Rotate (V : Vector; Q : Quaternion) return Vector is
      T : Vector;
   begin
      if Q=Identity then return V; end if;
      T := ((Q (0)*V (0)+Q (2)*V (2))-Q (3)*V (1),
            (Q (0)*V (1)+Q (3)*V (0))-Q (1)*V (2),
            (Q (0)*V (2)+Q (1)*V (1))-Q (2)*V (0));
      return (V (0)+2.0*(Q (2)*T (2)-Q (3)*T (1)),
              V (1)+2.0*(Q (3)*T (0)-Q (1)*T (2)),
              V (2)+2.0*(Q (1)*T (1)-Q (2)*T (0)));
   end Rotate;
   function Log (Q : Quaternion) return Vector is
      A : Vector := (Q (1),Q (2),Q (3));
      N : constant Real := Math.Sqrt ((A (0)*A (0)+A (1)*A (1))+A (2)*A (2));
      S : Real := N;
      Inv : Real;
   begin
      -- mji__normalize3 uses one reciprocal and preserves the original norm,
      -- including the tiny fallback, before mji_quat2Vel computes its angle.
      if N<Min_Val then A := (1.0,0.0,0.0);
      else
         Inv := 1.0/N;
         A := (A (0)*Inv,A (1)*Inv,A (2)*Inv);
      end if;
      -- atan2(0,0) in C is 0; Ada raises Argument_Error for that pair.
      if S=0.0 and then Q (0)=0.0 then S := 0.0;
      else S := 2.0*Math.Arctan (S,Q (0)); end if;
      if S>Ada.Numerics.Pi then S := S-2.0*Ada.Numerics.Pi; end if;
      return (A (0)*S,A (1)*S,A (2)*S);
   end Log;
   function Difference (Target, Current : Quaternion) return Vector is
   begin return Log (Multiply (Conjugate (Current),Target)); end Difference;
   function Expmap (V : Vector) return Quaternion is
      N : constant Real := Expmap_Norm (V);
      S : Real;
   begin
      if N<Min_Val then return Identity; end if;
      S := Expmap_Sine (N);
      return (MJ.Trigonometry.Cosine (N*0.5),Expmap_Term (V (0),N,S),
              Expmap_Term (V (1),N,S),Expmap_Term (V (2),N,S));
   end Expmap;
   function Mat_Vector (M : Matrix; V : Vector; Transpose : Boolean := False) return Vector is
      R : Vector;
   begin
      for I in 0 .. 2 loop
         if Transpose then R (I) := (M (0,I)*V (0)+M (1,I)*V (1))+M (2,I)*V (2);
         else R (I) := (M (I,0)*V (0)+M (I,1)*V (1))+M (I,2)*V (2); end if;
      end loop;
      return R;
   end Mat_Vector;
   function Slider (Axis, Displacement : Vector; Rod : Input) return Slider_Result is
      A : constant Real := (Displacement (0)*Axis (0)+Displacement (1)*Axis (1))+Displacement (2)*Axis (2);
      D : constant Real := (A*A+Rod*Rod)-((Displacement (0)*Displacement (0)+Displacement (1)*Displacement (1))+Displacement (2)*Displacement (2));
      R : Slider_Result;
      Root, C, Inv : Real;
   begin
      R.Length := A;
      if D<=0.0 then
         R.DA := Displacement; R.DV := Axis;
      else
         Root := Math.Sqrt (D);
         R.Length := A-Root;
         Inv := 1.0/Root; C := 1.0-A/Root;
         for K in 0 .. 2 loop
            R.DV (K) := Axis (K)*C+Displacement (K)*Inv;
            R.DA (K) := Displacement (K)*C;
         end loop;
         R.Feasible := True;
      end if;
      return R;
   end Slider;
   function SO3_Force (Error, Speed : Vector; KP, Constant_Bias, KV : Input) return Vector is
      R : Vector;
   begin
      for K in 0 .. 2 loop R (K) := (KP*Error (K)+Constant_Bias)+KV*Speed (K); end loop;
      return R;
   end SO3_Force;
   function Limit_Norm (Force : Vector; Limit : Nonneg_Tier0) return Vector is
      N : constant Real := Math.Sqrt ((Force (0)*Force (0)+Force (1)*Force (1))+Force (2)*Force (2));
   begin
      if N>Limit then
         return (Force (0)*(Limit/N),Force (1)*(Limit/N),Force (2)*(Limit/N));
      end if;
      return Force;
   end Limit_Norm;
end MJ.Actuator_Geometry;

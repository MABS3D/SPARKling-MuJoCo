with Ada.Numerics.Long_Elementary_Functions;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

package MJ.Rigid_Math with SPARK_Mode is
   function Bounded (A : Vec) return Boolean is
     (for all X of A => X in -1.0e60 .. 1.0e60) with Ghost;
   function Matrix_Bounded (R : Matrix) return Boolean is
     (for all X of R => X in -1.0e60 .. 1.0e60) with Ghost;
   function Add (A, B : Vec) return Vec with Inline, Global => null,
     Pre => Bounded (A) and Bounded (B),
     Post => (for all I in Axis => Add'Result (I) = A (I) + B (I));
   function Sub (A, B : Vec) return Vec with Inline, Global => null,
     Pre => Bounded (A) and Bounded (B),
     Post => (for all I in Axis => Sub'Result (I) = A (I) - B (I));
   function Scale (A : Vec; S : Real) return Vec with Inline, Global => null,
     Pre => Bounded (A) and S in -1.0e200 .. 1.0e200,
     Post => (for all I in Axis => Scale'Result (I) = A (I) * S);
   function Dot (A, B : Vec) return Real with Inline, Global => null,
     Pre => Bounded (A) and Bounded (B),
     Post => Dot'Result = (A (0) * B (0) + A (1) * B (1)) + A (2) * B (2);
   function Cross (A, B : Vec) return Vec with Inline, Global => null,
     Pre => Bounded (A) and Bounded (B),
     Post => Cross'Result = Vec'[A (1)*B (2)-A (2)*B (1),
                               A (2)*B (0)-A (0)*B (2), A (0)*B (1)-A (1)*B (0)];
   function Norm (A : Vec) return Real with Inline, Global => null, Pre => Bounded (A),
     Post => Norm'Result >= 0.0 and then Norm'Result =
       Ada.Numerics.Long_Elementary_Functions.Sqrt (Dot (A, A));
   function Unit (A : Vec) return Vec with Inline, Global => null, Pre => Bounded (A),
     Post => (if Norm (A) < Min_Val then Unit'Result = Vec'[1.0, 0.0, 0.0]
              else Unit'Result = Scale (A, 1.0/Norm (A)))
       and then (if (for all X of A => X in -1.0e23 .. 1.0e23) then
         (for all X of Unit'Result => X in -1.0e39 .. 1.0e39));
   --  The conservative bound above follows from the tiny-norm guard alone;
   --  it makes no accuracy assumption about the runtime square root.
   function Transform (R : Matrix; A : Vec) return Vec with Inline, Global => null,
     Pre => Matrix_Bounded (R) and Bounded (A),
     Post => Transform'Result = Vec'[Dot ([R (0), R (1), R (2)], A),
          Dot ([R (3), R (4), R (5)], A), Dot ([R (6), R (7), R (8)], A)];
   function Local (R : Matrix; A : Vec) return Vec with Inline, Global => null,
     Pre => Matrix_Bounded (R) and Bounded (A),
     Post => Local'Result = Vec'[Dot ([R (0), R (3), R (6)], A),
          Dot ([R (1), R (4), R (7)], A), Dot ([R (2), R (5), R (8)], A)];
   function Column (R : Matrix; I : Axis) return Vec is
     ([R (I), R (3+I), R (6+I)]) with Inline, Global => null;
   function Clip (X, Lo, Hi : Real) return Real is
     (Real'Max (Lo, Real'Min (Hi, X))) with Inline, Global => null,
     Pre => Lo <= Hi, Post => Clip'Result in Lo .. Hi
       and then (if X < Lo then Clip'Result = Lo elsif X > Hi then Clip'Result = Hi else Clip'Result = X);
end MJ.Rigid_Math;

with MJ.Types; use MJ.Types;
package MJ.Integration_Duals with SPARK_Mode is
   type Dual is record Value, Rate : Real := 0.0; end record;
   function Bounded (A : Dual) return Boolean is
     (A.Value in -1.0e60 .. 1.0e60 and then A.Rate in -1.0e60 .. 1.0e60);
   function C (A : Real) return Dual is ((A, 0.0));
   function "+" (A, B : Dual) return Dual with Global => null,
     Pre => Bounded (A) and then Bounded (B),
     Post => "+"'Result = Dual'(A.Value+B.Value, A.Rate+B.Rate);
   function "-" (A, B : Dual) return Dual with Global => null,
     Pre => Bounded (A) and then Bounded (B),
     Post => "-"'Result = Dual'(A.Value-B.Value, A.Rate-B.Rate);
   function "*" (A, B : Dual) return Dual with Global => null,
     Pre => Bounded (A) and then Bounded (B),
     Post => "*"'Result = Dual'(A.Value*B.Value, A.Rate*B.Value+A.Value*B.Rate);
   function Inv (A : Dual) return Dual with Global => null, Pre => Bounded (A);
   function Root (A : Dual) return Dual with Global => null,
     Pre => Bounded (A) and then A.Value >= 0.0;
   type Triple is array (Natural range 0 .. 2) of Dual;
   function Cross (A, B : Triple) return Triple with Global => null;
   function Norm (A : Triple) return Dual with Global => null;
end MJ.Integration_Duals;

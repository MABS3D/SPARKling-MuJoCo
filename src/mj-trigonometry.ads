with Ada.Numerics.Long_Elementary_Functions;
with MJ.Types; use MJ.Types;

--  Rounded elementary operations used by the MuJoCo-compatible paths.
package MJ.Trigonometry with SPARK_Mode is
   --  GNAT's Cos returns 1 throughout this interval. The rounded quadratic
   --  retains the binary64 variation near its upper end. Its FP expression
   --  is specified below; universal equivalence to libm is not asserted.
   Cosine_Tiny_Threshold : constant Real := 2.0**(-26);
   function Cosine (X : Real) return Real with Global => null, Inline_Always,
     Post => Cosine'Result in -1.0 .. 1.0 and then Cosine'Result =
       (if abs X < Cosine_Tiny_Threshold then 1.0 - (X*X)/2.0
        else Ada.Numerics.Long_Elementary_Functions.Cos (X));
end MJ.Trigonometry;

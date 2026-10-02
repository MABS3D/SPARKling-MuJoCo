with MJ.Types; use MJ.Types;

--  Elementary runtime boundary, like the standard runtime Sqrt.
--  GNAT Generic_Elementary_Functions.Arctan reduces the quadrants through
--  atan and extra rounded subtractions; MuJoCo calls libm atan2 directly.
--  They can choose different sides of the strict pi branch. Do not strengthen
--  this imported runtime declaration with an assumed accuracy/range contract.
--  Callers check its returned angle before further arithmetic.
package MJ.Joint_Limit_Math with SPARK_Mode is
   function Atan2 (Y, X : Real) return Real
     with Import, Convention => C, External_Name => "atan2", Global => null;
   function Sqrt (X : Real) return Real
     with Import, Convention => C, External_Name => "sqrt", Global => null,
     Pre => X >= 0.0;
end MJ.Joint_Limit_Math;

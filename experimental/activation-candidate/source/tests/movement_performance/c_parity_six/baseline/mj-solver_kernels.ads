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

   --  Complete independent entries before reporting a domain failure. These
   --  routines operate on disposable solver scratch: a rejected row must not
   --  be used by the next factorization/substitution stage. No reassociation
   --  of floating-point additions or multiplication is permitted.
   procedure Add_Row
     (Target : in out Real_Array; Source : Real_Array;
      Multiplier : Scale_Real; Ok : out Boolean)
     with Global => null,
     Pre => Target'Length = Source'Length
       and then Work_Array (Target) and then Work_Array (Source),
     Post => Ok = Work_Array (Target)
       and then (for all I in Target'Range =>
         Target (I) = Add_Product (Target'Old (I),
           Source (Source'First + (I - Target'First)), Multiplier));

   procedure Scale_Row
     (Target : in out Real_Array; Inverse : Inverse_Real; Ok : out Boolean)
     with Global => null, Pre => Work_Array (Target),
     Post => Ok = Work_Array (Target)
       and then (for all I in Target'Range =>
         Target (I) = Scale (Target'Old (I), Inverse));
end MJ.Solver_Kernels;

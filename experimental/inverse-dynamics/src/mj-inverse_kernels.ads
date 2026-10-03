with MJ.Types; use MJ.Types;

-- Ordered binary64 operations from MuJoCo 3.14.0 inverse dynamics.
package MJ.Inverse_Kernels with SPARK_Mode is
   function Product (Coefficient, Acceleration : Real) return Real
     with Global => null,
       Pre => Coefficient in -1.0e60 .. 1.0e60
         and then Acceleration in -1.0e10 .. 1.0e10,
       Post => Product'Result = Coefficient * Acceleration
         and then Product'Result in -1.0e71 .. 1.0e71;
   function Accumulate (Previous, Coefficient, Acceleration : Real) return Real
     with Global => null,
       Pre => Previous in -1.0e100 .. 1.0e100
         and then Coefficient in -1.0e60 .. 1.0e60
         and then Acceleration in -1.0e10 .. 1.0e10,
       Post => Accumulate'Result = Previous + Coefficient * Acceleration
         and then Accumulate'Result in -1.1e100 .. 1.1e100;
   function Required (Inertial, Bias, Gravity, Passive, Constraint : Real) return Real
     with Global => null,
       Pre => Inertial in -1.0e100 .. 1.0e100
         and then Bias in -1.0e60 .. 1.0e60
         and then Gravity in -1.0e60 .. 1.0e60
         and then Passive in -1.0e60 .. 1.0e60
         and then Constraint in -1.0e60 .. 1.0e60,
       Post => Required'Result = (Bias - Gravity) + ((Inertial - Passive) - Constraint)
         and then Required'Result in -1.1e100 .. 1.1e100;
   procedure Initialize_Entry
     (Values : in out Real_Array; Index : Natural; Coefficient, Acceleration : Real)
     with Global => null, Inline_Always,
       Pre => Index in Values'Range
         and then Coefficient in -1.0e60 .. 1.0e60
         and then Acceleration in -1.0e10 .. 1.0e10,
       Post => Values (Index) = Product (Coefficient, Acceleration)
         and then (for all K in Values'Range =>
           (if K /= Index then Values (K) = Values'Old (K)));
   pragma Postcondition (Static =>
     (if (for all X of Values'Old => X in -1.0e100 .. 1.0e100) then
        (for all X of Values => X in -1.0e100 .. 1.0e100)));
   procedure Scatter (Values : in out Real_Array; Index : Natural;
                      Coefficient, Acceleration : Real; Accepted : out Boolean)
     with Global => null,
       Pre => Index in Values'Range
         and then Values (Index) in -1.0e100 .. 1.0e100
         and then Coefficient in -1.0e60 .. 1.0e60
         and then Acceleration in -1.0e10 .. 1.0e10,
       Post => (if Accepted then
         Values (Index) = Accumulate (Values'Old (Index), Coefficient, Acceleration)
         and then Values (Index) in -1.0e100 .. 1.0e100
         and then (for all K in Values'Range =>
           (if K /= Index then Values (K) = Values'Old (K)))
         else Values = Values'Old);
   -- Composed preservation for callers maintaining bounded work vectors.
   -- This follows from the exact entry update and unchanged other entries.
   pragma Postcondition (Static =>
     (if (for all X of Values'Old => X in -1.0e100 .. 1.0e100) then
        (for all X of Values => X in -1.0e100 .. 1.0e100)));
end MJ.Inverse_Kernels;

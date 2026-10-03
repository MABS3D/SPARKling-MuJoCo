with MJ.Types; use MJ.Types;

-- Exact binary64 models; these contracts do not assert exact real derivatives.
package MJ.Derivative_Kernels with SPARK_Mode is
   type Matrix is array (Natural range <>, Natural range <>) of Real;
   subtype Operand is Real range -1.0e100 .. 1.0e100;
   subtype Increment is Real range 1.0e-15 .. 1.0;
   subtype Reciprocal is Real range 0.5 .. 1.0e15;
   subtype Slope is Real range -4.0e115 .. 4.0e115;
   type Stencil is (Zero, Forward, Backward, Central);

   function Scaled_Difference (Left, Right : Operand; Scale : Reciprocal)
     return Slope with Global => null,
     Post => Scaled_Difference'Result = Scale * (Right - Left);
   function Smooth_Force (Actuator, Passive, Bias : Operand) return Real
     with Global => null,
     Post => Smooth_Force'Result = (Actuator + Passive) - Bias
       and then Smooth_Force'Result in -4.0e100 .. 4.0e100;
   function Within (A, B, Low, High : Operand) return Boolean is
     (A >= Low and then A <= High and then B >= Low and then B <= High)
     with Global => null;
   function Control_Stencil
     (Value : Operand; Eps : Increment; Is_Limited, Centered : Boolean;
      Low, High : Operand) return Stencil
     with Global => null, Pre => Low <= High,
     Post => Control_Stencil'Result =
       (if not Is_Limited or else Within (Value, Value + Eps, Low, High) then
          (if Centered and then
             (not Is_Limited or else Within (Value - Eps, Value, Low, High))
           then Central else Forward)
        elsif not Is_Limited or else Within (Value - Eps, Value, Low, High)
          then Backward else Zero);
   procedure Store_Column
     (Target : in out Matrix; Column : Natural; Values : Real_Array)
     with Global => null,
     Pre => Column in Target'Range (2)
       and then Values'First = Target'First (1)
       and then Values'Last = Target'Last (1),
     Post => (for all R in Target'Range (1) => Target (R, Column) = Values (R))
       and then (for all R in Target'Range (1) =>
         (for all C in Target'Range (2) =>
           (if C /= Column then Target (R, C) = Target'Old (R, C))));
   procedure Store_Row
     (Target : in out Matrix; Row : Natural; Values : Real_Array)
     with Global => null,
     Pre => Row in Target'Range (1)
       and then Values'First = Target'First (2)
       and then Values'Last = Target'Last (2),
     Post => (for all C in Target'Range (2) => Target (Row, C) = Values (C))
       and then (for all R in Target'Range (1) =>
         (for all C in Target'Range (2) =>
           (if R /= Row then Target (R, C) = Target'Old (R, C))));
   procedure Differentiate
     (Left, Right : Real_Array; Scale : Reciprocal; Values : out Real_Array)
     with Global => null,
     Pre => Left'First = Right'First and then Left'Last = Right'Last
       and then Values'First = Left'First and then Values'Last = Left'Last
       and then (for all X of Left => X in Operand)
       and then (for all X of Right => X in Operand),
     Post => (for all I in Values'Range =>
       Values (I) = Scaled_Difference (Left (I), Right (I), Scale));
   function Product_Update (Previous, Coefficient, Value : Real) return Real
     with Global => null,
     Pre => Previous in -1.0e150 .. 1.0e150
       and then Coefficient in Operand and then Value in Operand,
     Post => Product_Update'Result = Previous + Coefficient * Value
       and then Product_Update'Result in -2.0e200 .. 2.0e200;
end MJ.Derivative_Kernels;

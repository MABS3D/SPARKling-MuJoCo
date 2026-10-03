--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see repository LICENSE.
--  Modified: ordered joint/tendon equality formulas, MuJoCo 3.14.0.
with MJ.Types; use MJ.Types;
package MJ.Equality_Scalar with SPARK_Mode is
   type Coefficients is array (Natural range 0 .. 4) of Tier0_Real;
   subtype Offset_Value is Real range -2.1e10 .. 2.1e10;
   subtype Scaled_Coefficient is Real range -4.1e10 .. 4.1e10;
   subtype Degree is Positive range 1 .. 4;
   subtype Linear_Value is Real range -1.0e22 .. 1.0e22;
   subtype Quadratic_Value is Real range -1.0e33 .. 1.0e33;
   subtype Cubic_Value is Real range -1.0e44 .. 1.0e44;
   subtype Quartic_Value is Real range -1.0e55 .. 1.0e55;
   subtype Polynomial_Value is Real range -1.0e56 .. 1.0e56;
   subtype Slope_Value is Real range -1.0e45 .. 1.0e45;
   subtype Base_Value is Real range -4.0e10 .. 4.0e10;
   subtype Residual_Value is Real range -1.0e57 .. 1.0e57;

   function Offset (Position, Reference : Tier0_Real) return Offset_Value
     with Global => null, Inline_Always,
       Post => Offset'Result = Position-Reference;
   function Scale (N : Degree; A : Tier0_Real) return Scaled_Coefficient
     with Global => null, Inline_Always, Post => Scale'Result = Real (N)*A;
   function Linear (A : Scaled_Coefficient; D : Offset_Value) return Linear_Value
     with Global => null, Inline_Always, Post => Linear'Result = A*D;
   function Quadratic (A : Scaled_Coefficient; D : Offset_Value) return Quadratic_Value
     with Global => null, Inline_Always, Post => Quadratic'Result = Linear (A, D)*D;
   function Cubic (A : Scaled_Coefficient; D : Offset_Value) return Cubic_Value
     with Global => null, Inline_Always, Post => Cubic'Result = Quadratic (A, D)*D;
   function Quartic (A : Scaled_Coefficient; D : Offset_Value) return Quartic_Value
     with Global => null, Inline_Always, Post => Quartic'Result = Cubic (A, D)*D;

   --  Preserve the expanded, left-associated C expression, rather than Horner.
   --  The constant coefficient is subtracted separately before this sum.
   function Polynomial (C : Coefficients; D : Offset_Value) return Polynomial_Value
     with Global => null, Inline_Always,
       Post => Polynomial'Result =
         ((Linear (C (1), D)+Quadratic (C (2), D))+Cubic (C (3), D))+Quartic (C (4), D);
   function Slope (C : Coefficients; D : Offset_Value) return Slope_Value
     with Global => null, Inline_Always,
       Post => Slope'Result =
         ((C (1)+Linear (Scale (2, C (2)), D))+Quadratic (Scale (3, C (3)), D))
           + Cubic (Scale (4, C (4)), D);
   function Base_Error (Position, Reference, Constant_Term : Tier0_Real)
                        return Base_Value
     with Global => null, Inline_Always,
       Post => Base_Error'Result = (Position-Reference)-Constant_Term;
   function Coupled_Error (Base : Base_Value; Tail : Polynomial_Value)
                           return Residual_Value
     with Global => null, Inline_Always, Post => Coupled_Error'Result = Base-Tail;

   type Geometry is record
      Position : Residual_Value;
      Derivative : Slope_Value;
   end record;
   function Evaluate
     (Position0, Reference0, Position1, Reference1 : Tier0_Real;
      C : Coefficients; Has_Second : Boolean) return Geometry
     with Global => null,
       Post => (Static =>
         Evaluate'Result.Position =
           (if Has_Second then Coupled_Error (Base_Error (Position0, Reference0, C (0)),
               Polynomial (C, Offset (Position1, Reference1)))
            else Base_Error (Position0, Reference0, C (0)))
         and then Evaluate'Result.Derivative =
           (if Has_Second then Slope (C, Offset (Position1, Reference1)) else 0.0));

   --  A coupled spatial tendon can exceed the assembly storage range. Return
   --  the full bounded result so the caller can reject before narrowing it.
   function Jacobian (J0, J1 : Tier2_Real; Derivative : Slope_Value)
                      return Tier3_Real
     with Global => null, Inline_Always,
       Post => Jacobian'Result = J0+(-Derivative)*J1;
end MJ.Equality_Scalar;

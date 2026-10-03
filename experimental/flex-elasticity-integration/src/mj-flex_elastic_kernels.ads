with MJ.Types; use MJ.Types;

-- Ordered binary64 operations from MuJoCo 3.14.0 engine_passive.c.
package MJ.Flex_Elastic_Kernels with SPARK_Mode is
   subtype Axis is Integer range 0 .. 2;
   subtype Coordinate is Real range -1.0e10 .. 1.0e10;
   subtype Coefficient is Real range -1.0e40 .. 1.0e40;
   subtype Strain is Real range -1.0e70 .. 1.0e70;
   subtype Force_Value is Real range -1.0e120 .. 1.0e120;
   subtype Work is Real range -1.0e150 .. 1.0e150;
   subtype Jacobian_Input is Real range -1.0e15 .. 1.0e15;
   subtype Jacobian_Value is Real range -3.0e25 .. 3.0e25;
   type Coordinates is array (Axis) of Coordinate;
   type Vector is array (Axis) of Real;
   type Six is array (Integer range 0 .. 5) of Strain;
   type Metric is array (Integer range 0 .. 5, Integer range 0 .. 5) of Coefficient;
   type Four is array (Integer range 0 .. 3) of Coordinate;
   type Four_Coefficients is array (Integer range 0 .. 3) of Coefficient;
   function Elongation (Length, Rest : Nonneg_Tier0) return Strain is
     (Length * Length - Rest * Rest) with Global => null,
       Post => Elongation'Result = Length * Length - Rest * Rest;
   function Damping_Elongation
     (Length : Nonneg_Tier0; Speed : Coordinate; H, Damping : Nonneg_Tier0)
      return Strain
     with Global => null, Pre => H = 0.0 or else H >= Min_Val,
       Post => Damping_Elongation'Result =
         (if H = 0.0 or else Damping = 0.0 then 0.0
          else ((Speed * H) * (2.0 * Length - Speed * H)) * (Damping / H));
   function Tension (E : Six; K : Metric; N : Positive; Column : Integer) return Real
     with Global => null, Pre => N in 3 | 6 and then Column in 0 .. N - 1,
       Post => Tension'Result in -1.0e112 .. 1.0e112 and then
         Tension'Result =
           (if N = 3 then ((0.0 + E (0) * K (0, Column)) + E (1) * K (1, Column)) + E (2) * K (2, Column)
            else (((((0.0 + E (0) * K (0, Column)) + E (1) * K (1, Column)) + E (2) * K (2, Column))
              + E (3) * K (3, Column)) + E (4) * K (4, Column)) + E (5) * K (5, Column));
   function Bending_Row (K : Four_Coefficients; X : Four) return Real
     with Global => null,
       Post => Bending_Row'Result in -1.0e52 .. 1.0e52 and then
         Bending_Row'Result = (((0.0 + K (0) * X (0)) + K (1) * X (1))
           + K (2) * X (2)) + K (3) * X (3);
   function Curved_Row (Row : Real; Beta : Coefficient; Normal : Real) return Real
     with Global => null, Pre => Row in -1.0e52 .. 1.0e52 and then Normal in -1.0e22 .. 1.0e22,
       Post => Curved_Row'Result in -1.0e64 .. 1.0e64
         and then Curved_Row'Result = Row + Beta * Normal;
   function Stretch_Update (Previous : Force_Value; T : Real; Gradient : Real) return Work
     with Global => null, Pre => T in -1.0e112 .. 1.0e112 and then Gradient in -2.0e10 .. 2.0e10,
       Post => Stretch_Update'Result = Previous - T * Gradient;
   function Project (X, Y, Z : Force_Value; A, B, C : Jacobian_Value) return Work
     with Global => null,
       Post => Project'Result = (A * X + B * Y) + C * Z;
   function Accumulate (Previous : Force_Value; Contribution : Work) return Real
     with Global => null, Post => Accumulate'Result in -2.0e150 .. 2.0e150
       and then Accumulate'Result = Previous + Contribution;
   function Jacobian_Component (L, WA, WB : Jacobian_Input; DA, DB : Coordinate) return Real
     with Global => null,
       Post => Jacobian_Component'Result in -3.0e25 .. 3.0e25
         and then Jacobian_Component'Result = L + (WA * DB - WB * DA);
end MJ.Flex_Elastic_Kernels;

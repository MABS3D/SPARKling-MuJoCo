package body MJ.Flex_Elastic_Kernels with SPARK_Mode is
   function Damping_Elongation
     (Length : Nonneg_Tier0; Speed : Coordinate; H, Damping : Nonneg_Tier0) return Strain is
      DL : Real;
   begin
      if H = 0.0 or else Damping = 0.0 then return 0.0; end if;
      DL := Speed * H;
      return (DL * (2.0 * Length - DL)) * (Damping / H);
   end Damping_Elongation;
   function Tension (E : Six; K : Metric; N : Positive; Column : Integer) return Real is
      S : Real := ((0.0 + E (0) * K (0, Column)) + E (1) * K (1, Column)) + E (2) * K (2, Column);
   begin
      pragma Assert (S in -4.0e110 .. 4.0e110);
      if N = 6 then
         S := ((S + E (3) * K (3, Column)) + E (4) * K (4, Column)) + E (5) * K (5, Column);
         pragma Assert (S in -8.0e110 .. 8.0e110);
      end if;
      return S;
   end Tension;
   function Bending_Row (K : Four_Coefficients; X : Four) return Real is
     ((((0.0 + K (0) * X (0)) + K (1) * X (1)) + K (2) * X (2)) + K (3) * X (3));
   function Curved_Row (Row : Real; Beta : Coefficient; Normal : Real) return Real is (Row + Beta * Normal);
   function Stretch_Update (Previous : Force_Value; T : Real; Gradient : Real) return Work is (Previous - T * Gradient);
   function Project (X, Y, Z : Force_Value; A, B, C : Jacobian_Value) return Work is ((A * X + B * Y) + C * Z);
   function Accumulate (Previous : Force_Value; Contribution : Work) return Real is (Previous + Contribution);
   function Jacobian_Component (L, WA, WB : Jacobian_Input; DA, DB : Coordinate) return Real is (L + (WA * DB - WB * DA));
end MJ.Flex_Elastic_Kernels;

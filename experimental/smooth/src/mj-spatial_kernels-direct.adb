with MJ.Types; use MJ.Types;

package body MJ.Spatial_Kernels.Direct with SPARK_Mode is
   function Angular_Value
     (A, B, C, D, E : Real; X, Y, Z, U, V : Real; Reverse_Signs : Boolean)
     return Real with Global => null,
     Pre => A in Inertia_Real and then B in Inertia_Real and then C in Inertia_Real
       and then D in Inertia_Real and then E in Inertia_Real
       and then X in Motion_Real and then Y in Motion_Real and then Z in Motion_Real
       and then U in Motion_Real and then V in Motion_Real,
     Post => Angular_Value'Result in Product_Real
       and then Angular_Value'Result =
       (if Reverse_Signs then (((A*X + B*Y) + C*Z) + D*U) - E*V
        else (((A*X + B*Y) + C*Z) - D*U) + E*V);
   function Linear_Value (A, B, C : Real; X, Y, Z : Real)
     return Real with Global => null,
     Pre => A in Inertia_Real and then B in Inertia_Real and then C in Inertia_Real
       and then X in Motion_Real and then Y in Motion_Real and then Z in Motion_Real,
     Post => Linear_Value'Result in Product_Real
       and then Linear_Value'Result = (A*X - B*Y) + C*Z;
   function Angular_Value
     (A, B, C, D, E : Real; X, Y, Z, U, V : Real; Reverse_Signs : Boolean)
     return Real is
      AX : constant Real := A*X;
      BY : constant Real := B*Y;
      CZ : constant Real := C*Z;
      DU : constant Real := D*U;
      EV : constant Real := E*V;
      Pair : constant Real := AX + BY;
      Triple : constant Real := Pair + CZ;
   begin
      pragma Assert (Static => AX in -2.0e52 .. 2.0e52);
      pragma Assert (Static => BY in -2.0e52 .. 2.0e52);
      pragma Assert (Static => CZ in -2.0e52 .. 2.0e52);
      pragma Assert (Static => DU in -2.0e52 .. 2.0e52);
      pragma Assert (Static => EV in -2.0e52 .. 2.0e52);
      pragma Assert (Static => Pair in -5.0e52 .. 5.0e52);
      pragma Assert (Static => Triple in -8.0e52 .. 8.0e52);
      if Reverse_Signs then return (Triple + DU) - EV;
      else return (Triple - DU) + EV; end if;
   end Angular_Value;
   function Linear_Value (A, B, C : Real; X, Y, Z : Real)
     return Real is
      AX : constant Real := A*X;
      BY : constant Real := B*Y;
      CZ : constant Real := C*Z;
   begin
      pragma Assert (Static => AX in -2.0e52 .. 2.0e52);
      pragma Assert (Static => BY in -2.0e52 .. 2.0e52);
      pragma Assert (Static => CZ in -2.0e52 .. 2.0e52);
      return (AX - BY) + CZ;
   end Linear_Value;
   --  Proved ghost bridges keep each scalar functional equality small.
   procedure Prove_Angular_Equality
     (A, B, C, D, E, X, Y, Z, U, V : Real; Reverse_Signs : Boolean)
     with Ghost => Static, Global => null,
     Pre => A in Inertia_Real and then B in Inertia_Real and then C in Inertia_Real
       and then D in Inertia_Real and then E in Inertia_Real
       and then X in Motion_Real and then Y in Motion_Real and then Z in Motion_Real
       and then U in Motion_Real and then V in Motion_Real,
     Post => Angular_Value (A, B, C, D, E, X, Y, Z, U, V, Reverse_Signs) =
       Angular_Component (A, B, C, D, E, X, Y, Z, U, V, Reverse_Signs)
   is
   begin
      null;
   end Prove_Angular_Equality;
   procedure Prove_Linear_Equality (A, B, C, X, Y, Z : Real)
     with Ghost => Static, Global => null,
     Pre => A in Inertia_Real and then B in Inertia_Real and then C in Inertia_Real
       and then X in Motion_Real and then Y in Motion_Real and then Z in Motion_Real,
     Post => Linear_Value (A, B, C, X, Y, Z) = Linear_Component (A, B, C, X, Y, Z)
   is
   begin
      null;
   end Prove_Linear_Equality;
   function Multiply (I : Inertia; V : Motion) return Motion is
      X : constant Real := Angular_Value
        (I (0), I (3), I (4), I (8), I (7), V (0), V (1), V (2), V (4), V (5), False);
      Y : constant Real := Angular_Value
        (I (3), I (1), I (5), I (8), I (6), V (0), V (1), V (2), V (3), V (5), True);
      Z : constant Real := Angular_Value
        (I (4), I (5), I (2), I (7), I (6), V (0), V (1), V (2), V (3), V (4), False);
      U : constant Real := Linear_Value (I (8), I (7), I (9), V (1), V (2), V (3));
      W : constant Real := Linear_Value (I (6), I (8), I (9), V (2), V (0), V (4));
      T : constant Real := Linear_Value (I (7), I (6), I (9), V (0), V (1), V (5));
      Expected : constant Motion := MJ.Spatial_Kernels.Multiply (I, V) with Ghost => Static;
   begin
      pragma Assert (Static => X in Product_Real);
      pragma Assert (Static => Y in Product_Real);
      pragma Assert (Static => Z in Product_Real);
      pragma Assert (Static => U in Product_Real);
      pragma Assert (Static => W in Product_Real);
      pragma Assert (Static => T in Product_Real);
      Prove_Angular_Equality
        (I (0), I (3), I (4), I (8), I (7), V (0), V (1), V (2), V (4), V (5), False);
      Prove_Angular_Equality
        (I (3), I (1), I (5), I (8), I (6), V (0), V (1), V (2), V (3), V (5), True);
      Prove_Angular_Equality
        (I (4), I (5), I (2), I (7), I (6), V (0), V (1), V (2), V (3), V (4), False);
      Prove_Linear_Equality (I (8), I (7), I (9), V (1), V (2), V (3));
      Prove_Linear_Equality (I (6), I (8), I (9), V (2), V (0), V (4));
      Prove_Linear_Equality (I (7), I (6), I (9), V (0), V (1), V (5));
      pragma Assert (Static => X = Expected (0));
      pragma Assert (Static => Y = Expected (1));
      pragma Assert (Static => Z = Expected (2));
      pragma Assert (Static => U = Expected (3));
      pragma Assert (Static => W = Expected (4));
      pragma Assert (Static => T = Expected (5));
      pragma Assert_And_Cut (Static =>
        Bounded (Expected, 1.0e54)
        and then Expected = MJ.Spatial_Kernels.Multiply (I, V)
        and then X = Expected (0) and then Y = Expected (1)
        and then Z = Expected (2) and then U = Expected (3)
        and then W = Expected (4) and then T = Expected (5));
      return [X, Y, Z, U, W, T];
   end Multiply;
end MJ.Spatial_Kernels.Direct;

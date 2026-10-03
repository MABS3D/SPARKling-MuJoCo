--  Adapted from MuJoCo 3.14.0, Copyright 2021 DeepMind Technologies Limited.
--  SPDX-License-Identifier: Apache-2.0
with MJ.Types; use MJ.Types;
package MJ.NoSlip_Kernels with SPARK_Mode is
   subtype Coefficient is Real range -1.0e20 .. 1.0e20;
   subtype Regularization is Real range 0.0 .. 1.0e20;
   subtype Force_Value is Real range -1.0e20 .. 1.0e20;
   subtype Positive_Force is Force_Value range 0.0 .. 1.0e20;
   subtype Proposed_Force is Real range 0.0 .. 2.0e20;
   subtype Residual_Value is Real range -1.0e50 .. 1.0e50;
   subtype Inverse is Real range 1.0e-21 .. 1.0e16;
   subtype Cost_Value is Real range -1.0e95 .. 1.0e95;
   subtype Difference is Real range -2.0e20 .. 2.0e20;
   subtype Curvature_Value is Real range -1.0e21 .. 1.0e21;
   subtype Positive_Curvature is Curvature_Value range Min_Val .. 1.0e21;
   subtype Linear_Value is Real range -1.0e51 .. 1.0e51;
   subtype Offset_Value is Real range -1.0e70 .. 1.0e70;
   type Pair_Force is record
      First, Second : Proposed_Force := 0.0;
   end record;
   type Pair_Result is record
      Force : Pair_Force;
      Change : Cost_Value := 0.0;
      Restored : Boolean := False;
   end record;

   function Midpoint (F0, F1 : Positive_Force) return Positive_Force
     with Global => null, Inline_Always,
       Post => Midpoint'Result = 0.5 * (F0 + F1);
   function Curvature (A00, A01, A10, A11 : Coefficient) return Curvature_Value
     with Global => null, Inline_Always,
       Post => Curvature'Result = ((A00 + A11) - A01) - A10;
   function Linear_Offset (A00, A11 : Coefficient; Mid : Positive_Force;
                          B0, B1 : Residual_Value) return Linear_Value
     with Global => null, Inline_Always,
       Post => Linear_Offset'Result = (Mid * (A00 - A11) + B0) - B1;
   function Ratio_Offset (K0 : Linear_Value; K1 : Positive_Curvature) return Offset_Value
     with Global => null, Inline_Always, Post => Ratio_Offset'Result = -K0 / K1;
   function Clamp_Offset (Mid : Positive_Force; Y : Offset_Value) return Pair_Force
     with Global => null, Inline_Always,
       Post => Clamp_Offset'Result =
         (if Y < -Mid then (0.0, 2.0 * Mid)
          elsif Y > Mid then (2.0 * Mid, 0.0) else (Mid + Y, Mid - Y));

   package Model with Ghost => Static is
      function Clip (X : Real; Bound : Regularization) return Force_Value is
        (if X < -Bound then -Bound elsif X > Bound then Bound else X)
        with Pre => X in -1.0e70 .. 1.0e70;
      function Pair_Proposal
        (A00, A01, A10, A11 : Coefficient; B0, B1 : Residual_Value;
         F0, F1 : Positive_Force) return Pair_Force is
        (declare Mid : constant Positive_Force := Midpoint (F0, F1);
                 K1 : constant Curvature_Value := Curvature (A00, A01, A10, A11);
                 K0 : constant Linear_Value := Linear_Offset (A00, A11, Mid, B0, B1);
         begin
           (if K1 < Min_Val then (Mid, Mid) else
             Clamp_Offset (Mid, Ratio_Offset (K0, K1))))
        with Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Pair_Cost
        (A00, A01, A10, A11 : Coefficient; Old, New_Force : Pair_Force;
         R0, R1 : Residual_Value) return Cost_Value is
        (declare D0 : constant Real := New_Force.First - Old.First;
                 D1 : constant Real := New_Force.Second - Old.Second;
         begin
           0.5 * ((0.0 + D0 * (0.0 + (A00 * D0 + A01 * D1)))
                    + D1 * (0.0 + (A10 * D0 + A11 * D1)))
           + (0.0 + (D0 * R0 + D1 * R1)))
        with Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;

   function Inverse_Diagonal (AR : Coefficient; R : Regularization) return Inverse
     with Global => null, Inline_Always,
       Post => Inverse_Diagonal'Result = 1.0 / Real'Max (Min_Val, AR - R);
   function Block_Diagonal (AR : Coefficient; R : Regularization) return Real
     with Global => null, Inline_Always,
       Post => Block_Diagonal'Result = Real'Max (1.0e-10, AR - R)
         and then Block_Diagonal'Result in 1.0e-10 .. 1.0e20;
   function Dry_Force
     (Old : Force_Value; Res : Residual_Value; Inv : Inverse;
      Bound : Regularization) return Force_Value
     with Global => null, Inline_Always,
       Post => (Static => Dry_Force'Result = Model.Clip (Old - Res * Inv, Bound)
         and then Dry_Force'Result in -Bound .. Bound);
   function Scalar_Change
     (Old, New_Force : Force_Value; Res : Residual_Value; Inv : Inverse)
      return Cost_Value
     with Global => null, Inline_Always,
       Post => Scalar_Change'Result =
         (((0.5 * (New_Force - Old)) * (New_Force - Old)) / Inv)
           + (New_Force - Old) * Res;
   function Propose_Pair
     (A00, A01, A10, A11 : Coefficient; B0, B1 : Residual_Value;
      F0, F1 : Positive_Force) return Pair_Force
     with Global => null, Inline_Always,
       Post => (Static => Propose_Pair'Result =
         Model.Pair_Proposal (A00, A01, A10, A11, B0, B1, F0, F1));
   function Pair_Change
     (A00, A01, A10, A11 : Coefficient; Old, New_Force : Pair_Force;
      R0, R1 : Residual_Value) return Cost_Value
     with Global => null, Inline_Always,
       Post => (Static => Pair_Change'Result =
         Model.Pair_Cost (A00, A01, A10, A11, Old, New_Force, R0, R1));
   function Accept_Pair (Old, Proposed : Pair_Force; Change : Cost_Value)
     return Pair_Result
     with Global => null, Inline_Always,
       Post => Accept_Pair'Result =
         (if Change > 1.0e-10 then (Old, 0.0, True)
          else (Proposed, Change, False));
end MJ.NoSlip_Kernels;

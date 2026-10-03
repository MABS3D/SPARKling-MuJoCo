package body MJ.NoSlip_Kernels with SPARK_Mode is
   function Midpoint (F0, F1 : Positive_Force) return Positive_Force is
     (0.5 * (F0 + F1));
   function Curvature (A00, A01, A10, A11 : Coefficient) return Curvature_Value is
     (((A00 + A11) - A01) - A10);
   function Linear_Offset (A00, A11 : Coefficient; Mid : Positive_Force;
                          B0, B1 : Residual_Value) return Linear_Value is
     ((Mid * (A00 - A11) + B0) - B1);
   function Ratio_Offset (K0 : Linear_Value; K1 : Positive_Curvature) return Offset_Value is
     (-K0 / K1);
   function Clamp_Offset (Mid : Positive_Force; Y : Offset_Value) return Pair_Force is
   begin
      if Y < -Mid then return (0.0, 2.0 * Mid);
      elsif Y > Mid then return (2.0 * Mid, 0.0);
      else return (Mid + Y, Mid - Y); end if;
   end Clamp_Offset;
   function Inverse_Diagonal (AR : Coefficient; R : Regularization) return Inverse is
      Denominator : constant Real range Min_Val .. 1.0e20 := Real'Max (Min_Val, AR - R);
   begin
      return 1.0 / Denominator;
   end Inverse_Diagonal;
   function Block_Diagonal (AR : Coefficient; R : Regularization) return Real is
     (Real'Max (1.0e-10, AR - R));
   function Dry_Force
     (Old : Force_Value; Res : Residual_Value; Inv : Inverse;
      Bound : Regularization) return Force_Value is
      X : constant Real := Old - Res * Inv;
   begin
      if X < -Bound then return -Bound;
      elsif X > Bound then return Bound;
      else return X; end if;
   end Dry_Force;
   function Scalar_Change
     (Old, New_Force : Force_Value; Res : Residual_Value; Inv : Inverse)
      return Cost_Value is
      Delta_F : constant Difference := New_Force - Old;
      Quadratic : constant Real range -1.0e63 .. 1.0e63 := ((0.5 * Delta_F) * Delta_F) / Inv;
      Linear : constant Real range -1.0e72 .. 1.0e72 := Delta_F * Res;
   begin
      return Quadratic + Linear;
   end Scalar_Change;
   function Propose_Pair
     (A00, A01, A10, A11 : Coefficient; B0, B1 : Residual_Value;
      F0, F1 : Positive_Force) return Pair_Force is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Pair_Proposal);
      Mid : constant Positive_Force := Midpoint (F0, F1);
      K1 : constant Curvature_Value := Curvature (A00, A01, A10, A11);
      K0 : constant Linear_Value := Linear_Offset (A00, A11, Mid, B0, B1);
   begin
      if K1 < Min_Val then return (Mid, Mid); end if;
      return Clamp_Offset (Mid, Ratio_Offset (K0, K1));
   end Propose_Pair;
   function Pair_Change
     (A00, A01, A10, A11 : Coefficient; Old, New_Force : Pair_Force;
      R0, R1 : Residual_Value) return Cost_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Pair_Cost);
      D0 : constant Difference := New_Force.First - Old.First;
      D1 : constant Difference := New_Force.Second - Old.Second;
      Quadratic : constant Real range -1.0e64 .. 1.0e64 :=
        (0.0 + D0 * (0.0 + (A00 * D0 + A01 * D1)))
          + D1 * (0.0 + (A10 * D0 + A11 * D1));
      Linear : constant Real range -1.0e72 .. 1.0e72 := 0.0 + (D0 * R0 + D1 * R1);
   begin
      return 0.5 * Quadratic + Linear;
   end Pair_Change;
   function Accept_Pair (Old, Proposed : Pair_Force; Change : Cost_Value)
     return Pair_Result is
     (if Change > 1.0e-10 then (Old, 0.0, True)
      else (Proposed, Change, False));
end MJ.NoSlip_Kernels;

package body MJ.Joint_Limit_Response with SPARK_Mode is
   function Scale_Impedance (Y : MJ.Solimp_Curve.Value;
                            D0, DW : MJ.Contact_Rows.Impedance_Value)
                            return MJ.Contact_Rows.Raw_Impedance is
   begin
      return D0 + Y * (DW - D0);
   end Scale_Impedance;
   function Divide_Width (X : Curve_Term; Width : Positive_Width) return Slope is
   begin
      return X / Width;
   end Divide_Width;
   function Sanitize (P : Parameters; H : Nonneg_Tier0; Ref_Safe : Boolean := True;
                      Metric : Boolean := False) return Effective_Parameters is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Sanitize);
      Mixed : constant Boolean := (P.Ref0 > 0.0) /= (P.Ref1 > 0.0);
      T : Reference_Time := (if Mixed then 0.02 else P.Ref0);
   begin
      if T > 0.0 and then Ref_Safe and then not Metric then T := Real'Max (T, 2.0*H); end if;
      return (T, (if Mixed then 1.0 else P.Ref1),
        Real'Min (Max_Imp, Real'Max (Min_Imp, P.D0)),
        Real'Min (Max_Imp, Real'Max (Min_Imp, P.D_Width)), Real'Max (0.0, P.Width),
        Real'Min (Max_Imp, Real'Max (Min_Imp, P.Midpoint)), Real'Max (1.0, P.Power), Mixed);
   end Sanitize;
   function Stiffness (P : Effective_Parameters) return Gain is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.K);
   begin
      if P.Ref0 > 0.0 then
         return 1.0 / Real'Max (Min_Val,
           ((((P.D_Width * P.D_Width) * P.Ref0) * P.Ref0) * P.Ref1) * P.Ref1);
      end if;
      return -P.Ref0 / Real'Max (Min_Val, P.D_Width * P.D_Width);
   end Stiffness;
   function Damping (P : Effective_Parameters) return Gain is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.B);
   begin
      if P.Ref0 > 0.0 then return 2.0 / Real'Max (Min_Val, P.D_Width * P.Ref0); end if;
      return -P.Ref1 / Real'Max (Min_Val, P.D_Width);
   end Damping;
   function Impedance (P : Effective_Parameters; Position : MJ.Joint_Limits.Distance;
                       Margin : Tier0_Real) return MJ.Contact_Rows.Raw_Impedance is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Impedance);
      X : Real;
      Y : MJ.Solimp_Curve.Value;
      Curve : MJ.Solimp_Curve.Result;
   begin
      if P.D0 = P.D_Width or else P.Width <= Min_Val then return 0.5*(P.D0 + P.D_Width); end if;
      X := abs ((Position - Margin) / P.Width);
      if X >= 1.0 then return P.D_Width; elsif X <= 0.0 then return P.D0; end if;
      if P.Power = Linear then Y := X;
      elsif P.Power = Quadratic then Y := MJ.Contact_Rows.Shape (X, P.Midpoint);
      else
         Curve := MJ.Solimp_Curve.Evaluate (X, P.Midpoint, P.Power);
         if not Curve.Valid then return 0.0; end if;
         Y := Curve.Y;
      end if;
      return Scale_Impedance (Y, P.D0, P.D_Width);
   end Impedance;
   function Shape_Derivative (X : MJ.Contact_Rows.Unit_Fraction;
                             Mid : MJ.Contact_Rows.Impedance_Value; Power : Curve_Power)
                             return Curve_Slope is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Shape_Derivative);
   begin
      if Power = Linear then return 1.0;
      elsif Power = Quadratic then
         if X <= Mid then return (2.0 * (1.0 / Mid)) * X; end if;
         declare D : constant MJ.Contact_Rows.Curve_Denominator := 1.0 - Mid;
         begin return (2.0 * (1.0 / D)) * (1.0 - X); end;
      end if;
      return MJ.Solimp_Curve.Evaluate (X, Mid, Power).YP;
   end Shape_Derivative;
   function Impedance_Derivative (P : Effective_Parameters; Position : MJ.Joint_Limits.Distance;
                                  Margin : Tier0_Real) return Slope is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Derivative);
      Raw_X, X : Real;
      YP : Curve_Slope;
      Signed, Scaled : Curve_Term;
   begin
      if P.D0 = P.D_Width or else P.Width <= Min_Val then return 0.0; end if;
      Raw_X := (Position - Margin) / P.Width;
      X := abs Raw_X;
      if X >= 1.0 or else X <= 0.0 then return 0.0; end if;
      YP := Shape_Derivative (X, P.Midpoint, P.Power);
      Signed := YP * (if Raw_X < 0.0 then -1.0 else 1.0);
      Scaled := Signed * (P.D_Width - P.D0);
      return Divide_Width (Scaled, P.Width);
   end Impedance_Derivative;
   function Row_Velocity (Row : MJ.Joint_Limits.Row; V : Vector) return Tier1_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Velocity);
   begin
      if Row.Width = 1 then return Row.Jacobian (0) * V (0); end if;
      return ((Row.Jacobian (0) * V (0)) + (Row.Jacobian (1) * V (1))) + (Row.Jacobian (2) * V (2));
   end Row_Velocity;
   function Reference (K, B : Gain; I : MJ.Contact_Rows.Checked_Impedance;
                       Position : MJ.Joint_Limits.Distance; Margin : Tier0_Real;
                       Velocity : Tier1_Real; H : Nonneg_Tier0; Metric : Boolean) return Acceleration is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Reference);
   begin
      return (-B * Velocity) - ((K * I) * ((Position - Margin) + (if Metric then H * Velocity else 0.0)));
   end Reference;
   procedure Prepare (Row : MJ.Joint_Limits.Row; V : Vector; P : Effective_Parameters;
                      Diag_Approx : MJ.Contact_Rows.Inverse_Mass; H : Nonneg_Tier0;
                      Metric : Boolean; R : out Prepared_Row) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Matches);
      Vel : constant Tier1_Real := Row_Velocity (Row, V);
      I : constant MJ.Contact_Rows.Raw_Impedance := Impedance (P, Row.Position, Row.Margin);
      IP : constant Slope := Impedance_Derivative (P, Row.Position, Row.Margin);
   begin
      if Metric then
         R := (Result => MJ.Joint_Limits.Unsupported_Integrator, others => <>);
         return;
      end if;
      R := (Velocity => Vel, Impedance => I, Derivative => IP, others => <>);
      if I not in MJ.Contact_Rows.Checked_Impedance then return; end if;
      R.Result := MJ.Joint_Limits.Success;
      R.K := Stiffness (P); R.B := Damping (P);
      R.R := MJ.Contact_Rows.Regularizer (I, Diag_Approx); R.D := 1.0 / R.R;
      R.Aref := Reference (R.K, R.B, I, Row.Position, Row.Margin, Vel, H, Metric);
   end Prepare;
end MJ.Joint_Limit_Response;

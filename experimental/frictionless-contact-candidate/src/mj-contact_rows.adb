package body MJ.Contact_Rows with SPARK_Mode is

   function Mass_Inverse (Mass : Positive_Parameter) return Inverse_Mass is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Mass_Inverse);
   begin
      return 1.0 / Mass;
   end Mass_Inverse;
   function Stiffness (P : Parameters; H : Nonneg_Tier0) return Gain is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Stiffness);
      D2 : constant Unit_Fraction := P.D_Width * P.D_Width;
      T : constant Effective_Time := Real'Max (P.Time_Constant, 2.0*H);
      V1 : constant Product_One := D2*T;
      V2 : constant Product_Two := V1*T;
      V3 : constant Product_Three := V2*P.Damping_Ratio;
      V4 : constant Product_Four := V3*P.Damping_Ratio;
   begin
      return 1.0 / Real'Max (Min_Val, V4);
   end Stiffness;
   function Damping (P : Parameters; H : Nonneg_Tier0) return Gain is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Damping);
   begin
      return 2.0 / Real'Max (Min_Val, P.D_Width * Real'Max (P.Time_Constant, 2.0*H));
   end Damping;
   function Regularizer (I : Checked_Impedance; Inv_M : Inverse_Mass) return Regularization is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Regularizer);
   begin
      return Real'Max (Min_Val, ((1.0-I) * Inv_M) / I);
   end Regularizer;
   function Smooth (Mass : Positive_Parameter; Gravity, Applied : Tier0_Real) return Smooth_Acceleration is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Smooth);
   begin
      return ((Mass * Gravity) + Applied) * (1.0 / Mass);
   end Smooth;
   function Reference (K, B : Gain; I : Checked_Impedance; Position, Margin : Separation; Velocity : Tier0_Real) return Reference_Acceleration is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Reference);
   begin
      return (-B * Velocity) - ((K * I) * (Position - Margin));
   end Reference;
   function Projected_Force (B : Residual; AR : Row_Diagonal) return Normal_Load is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Projected_Force);
   begin
      return Real'Max (0.0, 0.0 - B * (1.0 / AR));
   end Projected_Force;
   function Accelerated (Smooth : Smooth_Acceleration; Force : Normal_Load; Inv_M : Inverse_Mass) return Total_Acceleration is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Accelerated);
   begin
      return Smooth + Force * Inv_M;
   end Accelerated;
   function Shape (X : Real; Mid : Impedance_Value) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Shape);
   begin
      if X <= Mid then
         declare
            A : constant Curve_Scale := 1.0/Mid;
            X2 : constant Unit_Fraction := X*X;
         begin return A*X2; end;
      else
         declare
            D : constant Curve_Denominator := 1.0-Mid;
            B : constant Curve_Scale := 1.0/D;
            XX : constant Unit_Fraction := 1.0-X;
            X2 : constant Unit_Fraction := XX*XX;
         begin return 1.0-B*X2; end;
      end if;
   end Shape;
   function Impedance (P : Parameters; Position, Margin : Separation) return Raw_Impedance is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Impedance);
      X : Real range 0.0 .. 3.0e27;
      Y : Real range -2.0e4 .. 2.0e4;
   begin
      if P.D0 = P.D_Width or else P.Width <= Min_Val then
         return 0.5 * (P.D0 + P.D_Width);
      end if;
      X := abs ((Position - Margin) / P.Width);
      if X >= 1.0 then
         return P.D_Width;
      elsif X <= 0.0 then
         return P.D0;
      end if;
      Y := Shape (X, P.Midpoint);
      return P.D0 + Y * (P.D_Width - P.D0);
   end Impedance;
   procedure Assemble (R : out Row_Result; P : Parameters; H : Nonneg_Tier0; Inv_M : Inverse_Mass; Position, Margin : Separation; Velocity : Tier0_Real; Smooth : Smooth_Acceleration) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Matches);
      I : constant Raw_Impedance := Impedance (P, Position, Margin);
   begin
      if I not in Checked_Impedance then
         R := (Accepted => False, Impedance => I, Acceleration => Smooth, others => <>);
         return;
      end if;
      declare
         K : constant Gain := Stiffness (P, H);
         B : constant Gain := Damping (P, H);
         Reg : constant Regularization := Regularizer (I, Inv_M);
         AR : constant Row_Diagonal := Inv_M + Reg;
         Aref : constant Reference_Acceleration := Reference (K, B, I, Position, Margin, Velocity);
         F : constant Normal_Load := Projected_Force (Smooth - Aref, AR);
         A : constant Total_Acceleration := Accelerated (Smooth, F, Inv_M);
      begin
         R := (True, I, K, B, Reg, AR, Aref, F, A);
      end;
   end Assemble;
end MJ.Contact_Rows;

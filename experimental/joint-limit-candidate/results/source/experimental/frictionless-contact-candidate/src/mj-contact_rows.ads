with MJ.Types; use MJ.Types;
package MJ.Contact_Rows with SPARK_Mode is
   subtype Unit_Fraction is Real range 0.0 .. 1.0;
   subtype Effective_Time is Real range Min_Val .. 2.0e10;
   subtype Product_One is Real range 0.0 .. 3.0e10;
   subtype Product_Two is Real range 0.0 .. 1.0e21;
   subtype Product_Three is Real range 0.0 .. 1.0e32;
   subtype Product_Four is Real range 0.0 .. 1.0e43;
   subtype Curve_Scale is Real range 1.0 .. 1.2e4;
   subtype Curve_Denominator is Real range 0.00009 .. 1.0;
   subtype Positive_Parameter is Real range Min_Val .. 1.0e10;
   subtype Impedance_Value is Real range 0.0001 .. 0.9999;
   subtype Checked_Impedance is Real range 0.00001 .. 1.0;
   subtype Raw_Impedance is Real range -1.0e5 .. 1.0e5;
   subtype Separation is Real range -1.0e12 .. 1.0e12;
   subtype Inverse_Mass is Real range Min_Val .. 1.0e15;
   subtype Gain is Real range 0.0 .. 2.0e15;
   subtype Regularization is Real range Min_Val .. 1.0e20;
   subtype Row_Diagonal is Real range Min_Val .. 2.0e20;
   subtype Smooth_Acceleration is Real range -1.0e41 .. 1.0e41;
   subtype Reference_Acceleration is Real range -1.0e30 .. 1.0e30;
   subtype Residual is Real range -1.0e42 .. 1.0e42;
   subtype Normal_Load is Real range 0.0 .. 1.0e58;
   subtype Total_Acceleration is Real range -1.0e75 .. 1.0e75;
   type Parameters is record
      Time_Constant : Positive_Parameter := 0.02;
      Damping_Ratio : Positive_Parameter := 1.0;
      D0 : Impedance_Value := 0.9;
      D_Width : Impedance_Value := 0.95;
      Width : Nonneg_Tier0 := 0.001;
      Midpoint : Impedance_Value := 0.5;
   end record;
   type Row_Result is record
      Accepted : Boolean := False;
      Impedance : Real range -1.0e5 .. 1.0e5 := 0.0;
      K, B : Gain := 0.0;
      R : Regularization := Min_Val;
      AR : Row_Diagonal := Min_Val;
      Aref : Reference_Acceleration := 0.0;
      Force : Normal_Load := 0.0;
      Acceleration : Total_Acceleration := 0.0;
   end record;

   package Model with Ghost => Static is
      function Mass_Inverse (Mass : Positive_Parameter) return Inverse_Mass is
        (1.0 / Mass) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Stiffness (P : Parameters; H : Nonneg_Tier0) return Gain is
        (declare D2 : constant Unit_Fraction := P.D_Width * P.D_Width;
                 T : constant Effective_Time := Real'Max (P.Time_Constant, 2.0*H);
                 V1 : constant Product_One := D2*T;
                 V2 : constant Product_Two := V1*T;
                 V3 : constant Product_Three := V2*P.Damping_Ratio;
                 V4 : constant Product_Four := V3*P.Damping_Ratio;
         begin 1.0 / Real'Max (Min_Val, V4)) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Damping (P : Parameters; H : Nonneg_Tier0) return Gain is
        (2.0 / Real'Max (Min_Val, P.D_Width * Real'Max (P.Time_Constant, 2.0*H))) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Regularizer (I : Checked_Impedance; Inv_M : Inverse_Mass) return Regularization is
        (Real'Max (Min_Val, ((1.0-I) * Inv_M) / I)) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Smooth (Mass : Positive_Parameter; Gravity, Applied : Tier0_Real) return Smooth_Acceleration is
        (((Mass * Gravity) + Applied) * (1.0 / Mass)) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Reference (K, B : Gain; I : Checked_Impedance; Position, Margin : Separation; Velocity : Tier0_Real) return Reference_Acceleration is
        ((-B * Velocity) - ((K * I) * (Position - Margin))) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Projected_Force (B : Residual; AR : Row_Diagonal) return Normal_Load is
        (Real'Max (0.0, 0.0 - B * (1.0 / AR))) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Accelerated (Smooth : Smooth_Acceleration; Force : Normal_Load; Inv_M : Inverse_Mass) return Total_Acceleration is
        (Smooth + Force * Inv_M) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Shape (X : Real; Mid : Impedance_Value) return Real is
        (if X <= Mid then
           (declare A : constant Curve_Scale := 1.0/Mid;
                    X2 : constant Unit_Fraction := X*X;
            begin A*X2)
         else
           (declare D : constant Curve_Denominator := 1.0-Mid;
                    B : constant Curve_Scale := 1.0/D;
                    XX : constant Unit_Fraction := 1.0-X;
                    X2 : constant Unit_Fraction := XX*XX;
            begin 1.0-B*X2))
        with Global => null, Pre => X in 0.0 .. 1.0,
        Post => Shape'Result in -2.0e4 .. 2.0e4,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Impedance (P : Parameters; Position, Margin : Separation) return Raw_Impedance is
        (if P.D0 = P.D_Width or else P.Width <= Min_Val then 0.5*(P.D0+P.D_Width)
         else (declare X : constant Real := abs ((Position-Margin)/P.Width);
               begin (if X >= 1.0 then P.D_Width elsif X <= 0.0 then P.D0
                 else P.D0 + Shape (X, P.Midpoint) * (P.D_Width-P.D0))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      --  Ordered output relations avoid re-expanding the entire floating-point
      --  solve in each caller. Every field, including rejection defaults, is fixed.
      function Matches (P : Parameters; H : Nonneg_Tier0; Inv_M : Inverse_Mass;
                        Position, Margin : Separation; Velocity : Tier0_Real;
                        Smooth : Smooth_Acceleration; R : Row_Result) return Boolean is
        (R.Impedance = Impedance (P, Position, Margin)
         and then R.Accepted = (R.Impedance in Checked_Impedance)
         and then (if not R.Accepted then
           R = (Accepted => False, Impedance => R.Impedance,
                Acceleration => Smooth, others => <>)
         else R.K = Stiffness (P, H)
           and then R.B = Damping (P, H)
           and then R.R = Regularizer (R.Impedance, Inv_M)
           and then R.AR = Inv_M+R.R
           and then R.Aref = Reference (R.K, R.B, R.Impedance, Position, Margin, Velocity)
           and then R.Force = Projected_Force (Smooth-R.Aref, R.AR)
           and then R.Acceleration = Accelerated (Smooth, R.Force, Inv_M)))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   function Mass_Inverse (Mass : Positive_Parameter) return Inverse_Mass with Inline_Always, Global => null,
     Post => (Static => Mass_Inverse'Result = Model.Mass_Inverse (Mass));
   function Stiffness (P : Parameters; H : Nonneg_Tier0) return Gain with Inline_Always, Global => null,
     Post => (Static => Stiffness'Result = Model.Stiffness (P, H));
   function Damping (P : Parameters; H : Nonneg_Tier0) return Gain with Inline_Always, Global => null,
     Post => (Static => Damping'Result = Model.Damping (P, H));
   function Regularizer (I : Checked_Impedance; Inv_M : Inverse_Mass) return Regularization with Inline_Always, Global => null,
     Post => (Static => Regularizer'Result = Model.Regularizer (I, Inv_M));
   function Smooth (Mass : Positive_Parameter; Gravity, Applied : Tier0_Real) return Smooth_Acceleration with Inline_Always, Global => null,
     Post => (Static => Smooth'Result = Model.Smooth (Mass, Gravity, Applied));
   function Reference (K, B : Gain; I : Checked_Impedance; Position, Margin : Separation; Velocity : Tier0_Real) return Reference_Acceleration with Inline_Always, Global => null,
     Post => (Static => Reference'Result = Model.Reference (K, B, I, Position, Margin, Velocity));
   function Projected_Force (B : Residual; AR : Row_Diagonal) return Normal_Load with Inline_Always, Global => null,
     Post => (Static => Projected_Force'Result = Model.Projected_Force (B, AR));
   function Accelerated (Smooth : Smooth_Acceleration; Force : Normal_Load; Inv_M : Inverse_Mass) return Total_Acceleration with Inline_Always, Global => null,
     Post => (Static => Accelerated'Result = Model.Accelerated (Smooth, Force, Inv_M));
   function Shape (X : Real; Mid : Impedance_Value) return Real with
     Inline_Always, Global => null, Pre => X in 0.0 .. 1.0,
     Post => (Static => Shape'Result in -2.0e4 .. 2.0e4
       and then Shape'Result = Model.Shape (X, Mid));
   function Impedance (P : Parameters; Position, Margin : Separation) return Raw_Impedance with Inline_Always, Global => null,
     Post => (Static => Impedance'Result in -1.0e5 .. 1.0e5
       and then Impedance'Result = Model.Impedance (P, Position, Margin));
   procedure Assemble (R : out Row_Result; P : Parameters; H : Nonneg_Tier0; Inv_M : Inverse_Mass; Position, Margin : Separation; Velocity : Tier0_Real; Smooth : Smooth_Acceleration) with
     Inline_Always, Global => null,
     Post => (Static => Model.Matches (P, H, Inv_M, Position, Margin, Velocity, Smooth, R));
end MJ.Contact_Rows;

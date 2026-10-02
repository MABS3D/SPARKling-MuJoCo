with MJ.Types; use MJ.Types;
with MJ.Contact_Rows;
with MJ.Joint_Limits;
with MJ.BLAS;

--  Joint-limit KBIP, R, D and aref before solving J*M^-1*J' + R.
--  Diag_Approx is dof_invweight0 at the first DOF, as in C; it is not
--  necessarily the current projected inverse inertia of a ball joint.
package MJ.Joint_Limit_Response with SPARK_Mode is
   use type MJ.Joint_Limits.Status;
   subtype Vector is MJ.Joint_Limits.Vector;
   type Curve_Power is (Linear, Quadratic);
   type Parameters is record
      Ref0 : Tier0_Real := 0.02;
      Ref1 : Tier0_Real := 1.0;
      D0 : Tier0_Real := 0.9;
      D_Width : Tier0_Real := 0.95;
      Width : Tier0_Real := 0.001;
      Midpoint : Tier0_Real := 0.5;
      Power : Curve_Power := Quadratic;
   end record;
   subtype Reference_Time is Real range -2.0e10 .. 2.0e10;
   type Effective_Parameters is record
      Ref0 : Reference_Time;
      Ref1 : Tier0_Real;
      D0, D_Width : MJ.Contact_Rows.Impedance_Value;
      Width : Nonneg_Tier0;
      Midpoint : MJ.Contact_Rows.Impedance_Value;
      Power : Curve_Power;
      Used_Default : Boolean;
   end record;
   subtype Gain is Real range 0.0 .. 1.0e26;
   subtype Slope is Real range -1.0e21 .. 1.0e21;
   subtype Curve_Slope is Real range 0.0 .. 3.0e4;
   subtype Curve_Term is Real range -3.0e4 .. 3.0e4;
   subtype Positive_Width is Real range Min_Val .. 1.0e10;
   function Divide_Width (X : Curve_Term; Width : Positive_Width) return Slope
     with Global => null, Post => Divide_Width'Result = X / Width;
   subtype Acceleration is Real range -1.0e75 .. 1.0e75;
   type Prepared_Row is record
      Result : MJ.Joint_Limits.Status := MJ.Joint_Limits.Numeric_Limit;
      Velocity : Tier1_Real := 0.0;
      Impedance : MJ.Contact_Rows.Raw_Impedance := 0.0;
      Derivative : Slope := 0.0;
      K, B : Gain := 0.0;
      R : MJ.Contact_Rows.Regularization := Min_Val;
      D : Real range 0.0 .. 1.0e15 := 0.0;
      Aref : Acceleration := 0.0;
   end record;

   package Model with Ghost => Static is
      function Sanitize (P : Parameters; H : Nonneg_Tier0; Ref_Safe, Metric : Boolean)
                         return Effective_Parameters is
        (declare Mixed : constant Boolean := (P.Ref0 > 0.0) /= (P.Ref1 > 0.0);
                 T : constant Tier0_Real := (if Mixed then 0.02 else P.Ref0);
         begin ((if T > 0.0 and then Ref_Safe and then not Metric then Real'Max (T, 2.0*H) else T),
           (if Mixed then 1.0 else P.Ref1),
           Real'Min (Max_Imp, Real'Max (Min_Imp, P.D0)),
           Real'Min (Max_Imp, Real'Max (Min_Imp, P.D_Width)),
           Real'Max (0.0, P.Width),
           Real'Min (Max_Imp, Real'Max (Min_Imp, P.Midpoint)), P.Power, Mixed))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function K (P : Effective_Parameters) return Gain is
        (if P.Ref0 > 0.0 then
          1.0 / Real'Max (Min_Val,
            ((((P.D_Width * P.D_Width) * P.Ref0) * P.Ref0) * P.Ref1) * P.Ref1)
         else -P.Ref0 / Real'Max (Min_Val, P.D_Width * P.D_Width))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function B (P : Effective_Parameters) return Gain is
        (if P.Ref0 > 0.0 then 2.0 / Real'Max (Min_Val, P.D_Width * P.Ref0)
         else -P.Ref1 / Real'Max (Min_Val, P.D_Width))
        with Global => null, Pre => (P.Ref0 > 0.0) = (P.Ref1 > 0.0),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Impedance (P : Effective_Parameters; Position : MJ.Joint_Limits.Distance;
                          Margin : Tier0_Real) return MJ.Contact_Rows.Raw_Impedance is
        (if P.D0 = P.D_Width or else P.Width <= Min_Val then 0.5 * (P.D0 + P.D_Width)
         else (declare X : constant Real := abs ((Position - Margin) / P.Width);
          begin (if X >= 1.0 then P.D_Width elsif X <= 0.0 then P.D0 else
            P.D0 + (if P.Power = Linear then X else MJ.Contact_Rows.Model.Shape (X, P.Midpoint))
                   * (P.D_Width - P.D0))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Shape_Derivative (X : MJ.Contact_Rows.Unit_Fraction;
                                Mid : MJ.Contact_Rows.Impedance_Value; Power : Curve_Power)
                                return Curve_Slope is
        (if Power = Linear then 1.0 elsif X <= Mid then (2.0 * (1.0 / Mid)) * X else
          (declare D : constant MJ.Contact_Rows.Curve_Denominator := 1.0 - Mid;
           begin (2.0 * (1.0 / D)) * (1.0 - X)))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Derivative (P : Effective_Parameters; Position : MJ.Joint_Limits.Distance;
                           Margin : Tier0_Real) return Slope is
        (if P.D0 = P.D_Width or else P.Width <= Min_Val then 0.0
         else (declare Raw_X : constant Real := (Position - Margin) / P.Width;
                       X : constant Real := abs Raw_X;
          begin (if X >= 1.0 or else X <= 0.0 then 0.0 else
            (declare YP : constant Curve_Slope := Shape_Derivative (X, P.Midpoint, P.Power);
                     Signed : constant Curve_Term := YP * (if Raw_X < 0.0 then -1.0 else 1.0);
                     Scaled : constant Curve_Term := Signed * (P.D_Width - P.D0);
             begin Divide_Width (Scaled, P.Width)))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Velocity (Row : MJ.Joint_Limits.Row; V : Vector) return Tier1_Real is
        (if Row.Width = 1 then Row.Jacobian (0) * V (0) else
          ((Row.Jacobian (0) * V (0)) + (Row.Jacobian (1) * V (1))) + (Row.Jacobian (2) * V (2)))
        with Global => null, Pre => MJ.BLAS.In_Tier0 (Row.Jacobian) and then MJ.BLAS.In_Tier0 (V),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Reference (K, B : Gain; I : MJ.Contact_Rows.Checked_Impedance;
                          Position : MJ.Joint_Limits.Distance; Margin : Tier0_Real;
                          Velocity : Tier1_Real; H : Nonneg_Tier0; Metric : Boolean) return Acceleration is
        ((-B * Velocity) - ((K * I) * ((Position - Margin) + (if Metric then H * Velocity else 0.0))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Matches (Row : MJ.Joint_Limits.Row; V : Vector; P : Effective_Parameters;
                        Diag_Approx : MJ.Contact_Rows.Inverse_Mass; H : Nonneg_Tier0;
                        Metric : Boolean; R : Prepared_Row) return Boolean is
        (if Metric then R = (Result => MJ.Joint_Limits.Unsupported_Integrator, others => <>)
         else R.Velocity = Velocity (Row, V)
         and then R.Impedance = Impedance (P, Row.Position, Row.Margin)
         and then R.Derivative = Derivative (P, Row.Position, Row.Margin)
         and then (if R.Impedance not in MJ.Contact_Rows.Checked_Impedance then
           R = (Result => MJ.Joint_Limits.Numeric_Limit, Velocity => R.Velocity,
                Impedance => R.Impedance, Derivative => R.Derivative, others => <>)
          else R.Result = MJ.Joint_Limits.Success and then R.K = K (P) and then R.B = B (P)
           and then R.R = MJ.Contact_Rows.Model.Regularizer (R.Impedance, Diag_Approx)
           and then R.D = 1.0 / R.R
           and then R.Aref = Reference (R.K, R.B, R.Impedance, Row.Position, Row.Margin,
                                       R.Velocity, H, Metric)))
        with Global => null, Pre => MJ.BLAS.In_Tier0 (Row.Jacobian) and then MJ.BLAS.In_Tier0 (V)
          and then (P.Ref0 > 0.0) = (P.Ref1 > 0.0),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   function Sanitize (P : Parameters; H : Nonneg_Tier0; Ref_Safe : Boolean := True;
                      Metric : Boolean := False) return Effective_Parameters
     with Global => null,
     Post => (Static => Sanitize'Result = Model.Sanitize (P, H, Ref_Safe, Metric)
       and then (Sanitize'Result.Ref0 > 0.0) = (Sanitize'Result.Ref1 > 0.0));
   function Stiffness (P : Effective_Parameters) return Gain with Global => null,
     Post => (Static => Stiffness'Result = Model.K (P));
   function Damping (P : Effective_Parameters) return Gain with Global => null,
     Pre => (P.Ref0 > 0.0) = (P.Ref1 > 0.0),
     Post => (Static => Damping'Result = Model.B (P));
   function Impedance (P : Effective_Parameters; Position : MJ.Joint_Limits.Distance;
                       Margin : Tier0_Real) return MJ.Contact_Rows.Raw_Impedance with Global => null,
     Post => (Static => Impedance'Result = Model.Impedance (P, Position, Margin));
   function Impedance_Derivative (P : Effective_Parameters; Position : MJ.Joint_Limits.Distance;
                                  Margin : Tier0_Real) return Slope with Global => null,
     Post => (Static => Impedance_Derivative'Result = Model.Derivative (P, Position, Margin));
   function Shape_Derivative (X : MJ.Contact_Rows.Unit_Fraction;
                             Mid : MJ.Contact_Rows.Impedance_Value; Power : Curve_Power)
                             return Curve_Slope with Global => null,
     Post => (Static => Shape_Derivative'Result = Model.Shape_Derivative (X, Mid, Power));
   function Row_Velocity (Row : MJ.Joint_Limits.Row; V : Vector) return Tier1_Real
     with Global => null, Pre => MJ.BLAS.In_Tier0 (Row.Jacobian) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => Row_Velocity'Result = Model.Velocity (Row, V));
   function Reference (K, B : Gain; I : MJ.Contact_Rows.Checked_Impedance;
                       Position : MJ.Joint_Limits.Distance; Margin : Tier0_Real;
                       Velocity : Tier1_Real; H : Nonneg_Tier0; Metric : Boolean) return Acceleration
     with Global => null, Post => (Static => Reference'Result = Model.Reference
       (K, B, I, Position, Margin, Velocity, H, Metric));
   procedure Prepare (Row : MJ.Joint_Limits.Row; V : Vector; P : Effective_Parameters;
                      Diag_Approx : MJ.Contact_Rows.Inverse_Mass; H : Nonneg_Tier0;
                      Metric : Boolean; R : out Prepared_Row)
     with Global => null, Pre => MJ.BLAS.In_Tier0 (Row.Jacobian) and then MJ.BLAS.In_Tier0 (V)
       and then (P.Ref0 > 0.0) = (P.Ref1 > 0.0),
     Post => (Static => Model.Matches (Row, V, P, Diag_Approx, H, Metric, R));
   --  The discrete integrator has coupled changes to K/B/R and aref in 3.14.0.
   --  It is explicitly rejected here, rather than silently using Euler rows.
end MJ.Joint_Limit_Response;

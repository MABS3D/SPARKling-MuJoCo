with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
-- MuJoCo 3.14.0 scalar actuator laws, ordered binary64 arithmetic.
package MJ.Actuator_Curves with SPARK_Mode is
   package Model with Ghost => Static is
      function Clamp (X : Scalar; Lo, Hi : Input) return Scalar is
        (Real'Min (Hi, Real'Max (Lo, X))) with Global => null,
       Pre => Lo <= Hi,
       Post => Clamp'Result in Lo .. Hi,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Affine (P : Parameters; Length, Velocity : Input) return Scalar is
        ((P (0) + P (1)*Length) + P (2)*Velocity) with Global => null,
       Post => Affine'Result in -1.0e21 .. 1.0e21,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Scaled_Length (Length, Range_Lo, Range_Hi : Input; P : Parameters) return Curve_Argument is
        ((declare L0 : constant Length_Scale := (Range_Hi-Range_Lo)/Real'Max (Min_Val, P (1)-P (0));
       begin P (0) + (Length-Range_Lo)/Real'Max (Min_Val, L0))) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Scaled_Velocity (Velocity, Range_Lo, Range_Hi : Input; P : Parameters) return Curve_Argument is
        ((declare L0 : constant Length_Scale := (Range_Hi-Range_Lo)/Real'Max (Min_Val, P (1)-P (0));
       begin Velocity/Real'Max (Min_Val, L0*P (6)))) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Muscle_Scale (Acceleration : Input; P : Parameters) return Real is
        ((if P (2) < 0.0 then P (3)/Real'Max (Min_Val, Acceleration) else P (2))) with Global => null,
       Post => Muscle_Scale'Result in -1.0e26 .. 1.0e26,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Length_Curve (Length : Curve_Argument; Lo, Hi : Input) return Curve_Value is
        ((if Length < Lo or else Length > Hi then 0.0 else
       (declare A : constant Half_Range := 0.5*(Lo+1.0);
                B : constant Half_Range := 0.5*(1.0+Hi);
        begin (if Length <= A then
          (declare X : constant Curve_Ratio := (Length-Lo)/Real'Max (Min_Val, A-Lo); begin (0.5*X)*X)
        elsif Length <= 1.0 then
          (declare X : constant Curve_Ratio := (1.0-Length)/Real'Max (Min_Val, 1.0-A); begin 1.0-(0.5*X)*X)
        elsif Length <= B then
          (declare X : constant Curve_Ratio := (Length-1.0)/Real'Max (Min_Val, B-1.0); begin 1.0-(0.5*X)*X)
        else
          (declare X : constant Curve_Ratio := (Hi-Length)/Real'Max (Min_Val, Hi-B); begin (0.5*X)*X))))) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Velocity_Curve (Velocity : Curve_Argument; Maximum : Input) return Real is
        ((declare Y : constant Velocity_Scale := Maximum-1.0;
       begin (if Velocity <= -1.0 then 0.0
         elsif Velocity <= 0.0 then (Velocity+1.0)*(Velocity+1.0)
         elsif Velocity <= Y then Maximum-(Y-Velocity)*(Y-Velocity)/Real'Max (Min_Val, Y)
         else Maximum))) with Global => null,
       Post => Velocity_Curve'Result in -1.0e40 .. 1.0e40,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Muscle_Gain (Length, Velocity, Range_Lo, Range_Hi, Acceleration : Input; P : Parameters) return Scalar is
        ((-Muscle_Scale (Acceleration, P)*Length_Curve (Scaled_Length (Length, Range_Lo, Range_Hi, P), P (4), P (5)))
       *Velocity_Curve (Scaled_Velocity (Velocity, Range_Lo, Range_Hi, P), P (8))) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Muscle_Bias (Length, Range_Lo, Range_Hi, Acceleration : Input; P : Parameters) return Scalar is
        ((declare L : constant Curve_Argument := Scaled_Length (Length, Range_Lo, Range_Hi, P);
                F : constant Length_Scale := Muscle_Scale (Acceleration, P);
                B : constant Half_Range := 0.5*(1.0+P (5));
       begin (if L <= 1.0 then 0.0 elsif L <= B then
         (declare X : constant Curve_Ratio := (L-1.0)/Real'Max (Min_Val, B-1.0);
          begin (((-F*P (7))*0.5)*X)*X)
       else (declare X : constant Curve_Ratio := (L-B)/Real'Max (Min_Val, B-1.0);
          begin (-F*P (7))*(0.5+X))))) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Sigmoid (X : Curve_Argument) return Real is
        ((if X <= 0.0 then 0.0 elsif X >= 1.0 then 1.0
       else (declare U : constant Unit_Fraction := X; begin ((U*U)*U)*((3.0*U)*(2.0*U-5.0)+10.0)))) with Global => null,
       Post => Sigmoid'Result in -100.0 .. 100.0,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Muscle_Timescale (Difference : Real; Tau_Act, Tau_Deact : Real; Width : Input) return Real is
        ((if Width < Min_Val then (if Difference > 0.0 then Tau_Act else Tau_Deact)
       else Tau_Deact+(Tau_Act-Tau_Deact)*Sigmoid (Difference/Width+0.5))) with Global => null,
       Pre => Difference in -2.0e10 .. 2.0e10 and then Tau_Act in -2.0e20 .. 2.0e20 and then Tau_Deact in -1.0e11 .. 1.0e11,
       Post => Muscle_Timescale'Result in -1.0e24 .. 1.0e24,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Muscle_Derivative (Control, Activation : Input; P : Parameters) return Scalar is
        ((declare A : constant Unit_Fraction := Clamp (Activation, 0.0, 1.0);
                T : constant Activation_Scale := 0.5+1.5*A;
                Difference : constant Real := Clamp (Control, 0.0, 1.0)-Activation;
       begin Difference/Real'Max (Min_Val, Muscle_Timescale (Difference, P (0)*T, P (1)/T, P (2))))) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Filter_Derivative (Control, Activation : Input; Tau : Input) return Scalar is
        ((Control-Activation)/Real'Max (Min_Val, Tau)) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Euler (Activation : Input; Derivative : Scalar; H : Positive_Real) return Scalar is
        (Activation+Derivative*H) with Global => null,
       Pre => Derivative in -1.0e130 .. 1.0e130,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Wrap_Setpoint (Control, Length : Input; Period : Positive_Real) return Real is
        (Control-Period*Real'Rounding ((Control-Length)/Period)) with Global => null,
       Post => Wrap_Setpoint'Result in -1.0e27 .. 1.0e27,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Integral_Derivative (Control, Length, Integral, Limit : Input; Period : Nonneg_Tier0) return Real is
        ((declare Err : constant Real := (if Period > 0.0 then
         (Control-Length)-Period*Real'Rounding ((Control-Length)/Period) else Control-Length);
       begin (if Limit <= 0.0 then Err elsif Integral >= Limit then Real'Min (Err, 0.0)
       elsif Integral <= -Limit then Real'Max (Err, 0.0) else Err))) with Global => null,
       Pre => Period = 0.0 or else Period >= Min_Val,
       Post => Integral_Derivative'Result in -1.0e27 .. 1.0e27,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function PID_Force (Position, Velocity, Feedforward, Integral, Length, Speed : Input; Gain, Bias : Parameters; Period : Nonneg_Tier0) return Scalar is
        ((declare Ref : constant Wrapped_Value := (if Period > 0.0 then Wrap_Setpoint (Position, Length, Period) else Position);
       begin (((-Bias (1)*Ref-Bias (2)*Velocity)+Feedforward)
         +(if Gain (0)>0.0 then Gain (0)*Integral else 0.0))+Affine (Bias, Length, Speed))) with Global => null,
       Pre => Period = 0.0 or else Period >= Min_Val,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function DC_Voltage (Position, Velocity, Feedforward, Voltage, Integral, Length, Speed : Input; Gain : Parameters; Controller : Boolean) return Scalar is
        ((if not Controller then Voltage else
       (declare Torque : constant Torque_Value := ((Gain (4)*(Position-Length)+Gain (6)*(Velocity-Speed))+Gain (5)*Integral)+Feedforward;
                Raw : constant Voltage_Value := (Gain (0)/Gain (1))*Torque+Gain (1)*Speed;
       begin (if Gain (7)>0.0 then Clamp (Raw, -Gain (7), Gain (7)) else Raw)+Voltage))) with Global => null,
       Pre => not Controller or else Gain (1) >= Min_Val,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function DC_Resistance (Temperature : Input; Dyn, Gain : Parameters; Thermal : Boolean) return Real is
        (Real'Max (Min_Val, (if Thermal then Gain (0)*(1.0+Gain (2)*((Temperature+Dyn (4))-Gain (3))) else Gain (0)))) with Global => null,
       Post => DC_Resistance'Result in Min_Val .. 1.0e32,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function DC_Current_Derivative (Voltage : Scalar; Speed, Current : Input; Resistance, Tau : Positive_Real; K, Limit : Input) return Scalar is
        ((declare Raw : constant Current_Rate := ((Voltage/Resistance-(K/Resistance)*Speed)-Current)/Tau;
       begin (if Limit > 0.0 then Clamp (Raw, -Limit, Limit) else Raw))) with Global => null,
       Pre => Voltage in -1.0e100 .. 1.0e100,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function DC_Thermal_Derivative (Current, Temperature : Input; Resistance : Input; Thermal_R, Capacity : Positive_Real) return Scalar is
        (((Resistance*Current)*Current-Temperature/Thermal_R)/Capacity) with Global => null,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Force (Gain, Drive, Bias : Scalar) return Scalar is
        (Gain*Drive+Bias) with Global => null,
       Pre => Gain in -1.0e100 .. 1.0e100 and then Drive in -1.0e10 .. 1.0e10 and then Bias in -1.0e120 .. 1.0e120,
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   function Clamp (X : Scalar; Lo, Hi : Input) return Scalar with Global => null,
     Pre => Lo <= Hi,
     Post => True;
   pragma Postcondition (Static => (Clamp'Result = Model.Clamp (X, Lo, Hi) and then Clamp'Result in Lo .. Hi));
   function Affine (P : Parameters; Length, Velocity : Input) return Scalar with Global => null,
     Post => True;
   pragma Postcondition (Static => (Affine'Result = Model.Affine (P, Length, Velocity) and then Affine'Result in -1.0e21 .. 1.0e21));
   function Scaled_Length (Length, Range_Lo, Range_Hi : Input; P : Parameters) return Curve_Argument with Global => null,
     Post => True;
   pragma Postcondition (Static => (Scaled_Length'Result = Model.Scaled_Length (Length, Range_Lo, Range_Hi, P)));
   function Scaled_Velocity (Velocity, Range_Lo, Range_Hi : Input; P : Parameters) return Curve_Argument with Global => null,
     Post => True;
   pragma Postcondition (Static => (Scaled_Velocity'Result = Model.Scaled_Velocity (Velocity, Range_Lo, Range_Hi, P)));
   function Muscle_Scale (Acceleration : Input; P : Parameters) return Real with Global => null,
     Post => True;
   pragma Postcondition (Static => (Muscle_Scale'Result = Model.Muscle_Scale (Acceleration, P) and then Muscle_Scale'Result in -1.0e26 .. 1.0e26));
   function Length_Curve (Length : Curve_Argument; Lo, Hi : Input) return Curve_Value with Global => null,
     Post => True;
   pragma Postcondition (Static => (Length_Curve'Result = Model.Length_Curve (Length, Lo, Hi)));
   function Velocity_Curve (Velocity : Curve_Argument; Maximum : Input) return Real with Global => null,
     Post => True;
   pragma Postcondition (Static => (Velocity_Curve'Result = Model.Velocity_Curve (Velocity, Maximum) and then Velocity_Curve'Result in -1.0e40 .. 1.0e40));
   function Muscle_Gain (Length, Velocity, Range_Lo, Range_Hi, Acceleration : Input; P : Parameters) return Scalar with Global => null,
     Post => True;
   pragma Postcondition (Static => (Muscle_Gain'Result = Model.Muscle_Gain (Length, Velocity, Range_Lo, Range_Hi, Acceleration, P)));
   function Muscle_Bias (Length, Range_Lo, Range_Hi, Acceleration : Input; P : Parameters) return Scalar with Global => null,
     Post => True;
   pragma Postcondition (Static => (Muscle_Bias'Result = Model.Muscle_Bias (Length, Range_Lo, Range_Hi, Acceleration, P)));
   function Sigmoid (X : Curve_Argument) return Real with Global => null,
     Post => True;
   pragma Postcondition (Static => (Sigmoid'Result = Model.Sigmoid (X) and then Sigmoid'Result in -100.0 .. 100.0));
   function Muscle_Timescale (Difference : Real; Tau_Act, Tau_Deact : Real; Width : Input) return Real with Global => null,
     Pre => Difference in -2.0e10 .. 2.0e10 and then Tau_Act in -2.0e20 .. 2.0e20 and then Tau_Deact in -1.0e11 .. 1.0e11,
     Post => True;
   pragma Postcondition (Static => (Muscle_Timescale'Result = Model.Muscle_Timescale (Difference, Tau_Act, Tau_Deact, Width) and then Muscle_Timescale'Result in -1.0e24 .. 1.0e24));
   function Muscle_Derivative (Control, Activation : Input; P : Parameters) return Scalar with Global => null,
     Post => True;
   pragma Postcondition (Static => (Muscle_Derivative'Result = Model.Muscle_Derivative (Control, Activation, P)));
   function Filter_Derivative (Control, Activation : Input; Tau : Input) return Scalar with Global => null,
     Post => True;
   pragma Postcondition (Static => (Filter_Derivative'Result = Model.Filter_Derivative (Control, Activation, Tau)));
   function Euler (Activation : Input; Derivative : Scalar; H : Positive_Real) return Scalar with Global => null,
     Pre => Derivative in -1.0e130 .. 1.0e130,
     Post => True;
   pragma Postcondition (Static => (Euler'Result = Model.Euler (Activation, Derivative, H)));
   function Wrap_Setpoint (Control, Length : Input; Period : Positive_Real) return Real with Global => null,
     Post => True;
   pragma Postcondition (Static => (Wrap_Setpoint'Result = Model.Wrap_Setpoint (Control, Length, Period) and then Wrap_Setpoint'Result in -1.0e27 .. 1.0e27));
   function Integral_Derivative (Control, Length, Integral, Limit : Input; Period : Nonneg_Tier0) return Real with Global => null,
     Pre => Period = 0.0 or else Period >= Min_Val,
     Post => True;
   pragma Postcondition (Static => (Integral_Derivative'Result = Model.Integral_Derivative (Control, Length, Integral, Limit, Period) and then Integral_Derivative'Result in -1.0e27 .. 1.0e27));
   function PID_Force (Position, Velocity, Feedforward, Integral, Length, Speed : Input; Gain, Bias : Parameters; Period : Nonneg_Tier0) return Scalar with Global => null,
     Pre => Period = 0.0 or else Period >= Min_Val,
     Post => True;
   pragma Postcondition (Static => (PID_Force'Result = Model.PID_Force (Position, Velocity, Feedforward, Integral, Length, Speed, Gain, Bias, Period)));
   function DC_Voltage (Position, Velocity, Feedforward, Voltage, Integral, Length, Speed : Input; Gain : Parameters; Controller : Boolean) return Scalar with Global => null,
     Pre => not Controller or else Gain (1) >= Min_Val,
     Post => True;
   pragma Postcondition (Static => (DC_Voltage'Result = Model.DC_Voltage (Position, Velocity, Feedforward, Voltage, Integral, Length, Speed, Gain, Controller)));
   function DC_Resistance (Temperature : Input; Dyn, Gain : Parameters; Thermal : Boolean) return Real with Global => null,
     Post => True;
   pragma Postcondition (Static => (DC_Resistance'Result = Model.DC_Resistance (Temperature, Dyn, Gain, Thermal) and then DC_Resistance'Result in Min_Val .. 1.0e32));
   function DC_Current_Derivative (Voltage : Scalar; Speed, Current : Input; Resistance, Tau : Positive_Real; K, Limit : Input) return Scalar with Global => null,
     Pre => Voltage in -1.0e100 .. 1.0e100,
     Post => True;
   pragma Postcondition (Static => (DC_Current_Derivative'Result = Model.DC_Current_Derivative (Voltage, Speed, Current, Resistance, Tau, K, Limit)));
   function DC_Thermal_Derivative (Current, Temperature : Input; Resistance : Input; Thermal_R, Capacity : Positive_Real) return Scalar with Global => null,
     Post => True;
   pragma Postcondition (Static => (DC_Thermal_Derivative'Result = Model.DC_Thermal_Derivative (Current, Temperature, Resistance, Thermal_R, Capacity)));
   function Force (Gain, Drive, Bias : Scalar) return Scalar with Global => null,
     Pre => Gain in -1.0e100 .. 1.0e100 and then Drive in -1.0e10 .. 1.0e10 and then Bias in -1.0e120 .. 1.0e120,
     Post => True;
   pragma Postcondition (Static => (Force'Result = Model.Force (Gain, Drive, Bias)));
end MJ.Actuator_Curves;

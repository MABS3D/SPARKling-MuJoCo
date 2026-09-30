package body MJ.Actuator_Curves with SPARK_Mode is
   function Clamp (X : Scalar; Lo, Hi : Input) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Clamp);
   begin
      return Real'Min (Hi, Real'Max (Lo, X));
   end Clamp;
   function Affine (P : Parameters; Length, Velocity : Input) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Affine);
   begin
      return (P (0) + P (1)*Length) + P (2)*Velocity;
   end Affine;
   function Scaled_Length (Length, Range_Lo, Range_Hi : Input; P : Parameters) return Curve_Argument is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Scaled_Length);
   begin
      return (declare L0 : constant Length_Scale := (Range_Hi-Range_Lo)/Real'Max (Min_Val, P (1)-P (0));
       begin P (0) + (Length-Range_Lo)/Real'Max (Min_Val, L0));
   end Scaled_Length;
   function Scaled_Velocity (Velocity, Range_Lo, Range_Hi : Input; P : Parameters) return Curve_Argument is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Scaled_Velocity);
   begin
      return (declare L0 : constant Length_Scale := (Range_Hi-Range_Lo)/Real'Max (Min_Val, P (1)-P (0));
       begin Velocity/Real'Max (Min_Val, L0*P (6)));
   end Scaled_Velocity;
   function Muscle_Scale (Acceleration : Input; P : Parameters) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Muscle_Scale);
   begin
      return (if P (2) < 0.0 then P (3)/Real'Max (Min_Val, Acceleration) else P (2));
   end Muscle_Scale;
   function Length_Curve (Length : Curve_Argument; Lo, Hi : Input) return Curve_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Length_Curve);
   begin
      return (if Length < Lo or else Length > Hi then 0.0 else
       (declare A : constant Half_Range := 0.5*(Lo+1.0);
                B : constant Half_Range := 0.5*(1.0+Hi);
        begin (if Length <= A then
          (declare X : constant Curve_Ratio := (Length-Lo)/Real'Max (Min_Val, A-Lo); begin (0.5*X)*X)
        elsif Length <= 1.0 then
          (declare X : constant Curve_Ratio := (1.0-Length)/Real'Max (Min_Val, 1.0-A); begin 1.0-(0.5*X)*X)
        elsif Length <= B then
          (declare X : constant Curve_Ratio := (Length-1.0)/Real'Max (Min_Val, B-1.0); begin 1.0-(0.5*X)*X)
        else
          (declare X : constant Curve_Ratio := (Hi-Length)/Real'Max (Min_Val, Hi-B); begin (0.5*X)*X))));
   end Length_Curve;
   function Velocity_Curve (Velocity : Curve_Argument; Maximum : Input) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Velocity_Curve);
   begin
      return (declare Y : constant Velocity_Scale := Maximum-1.0;
       begin (if Velocity <= -1.0 then 0.0
         elsif Velocity <= 0.0 then (Velocity+1.0)*(Velocity+1.0)
         elsif Velocity <= Y then Maximum-(Y-Velocity)*(Y-Velocity)/Real'Max (Min_Val, Y)
         else Maximum));
   end Velocity_Curve;
   function Muscle_Gain (Length, Velocity, Range_Lo, Range_Hi, Acceleration : Input; P : Parameters) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Muscle_Gain);
   begin
      return (-Muscle_Scale (Acceleration, P)*Length_Curve (Scaled_Length (Length, Range_Lo, Range_Hi, P), P (4), P (5)))
       *Velocity_Curve (Scaled_Velocity (Velocity, Range_Lo, Range_Hi, P), P (8));
   end Muscle_Gain;
   function Muscle_Bias (Length, Range_Lo, Range_Hi, Acceleration : Input; P : Parameters) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Muscle_Bias);
   begin
      return (declare L : constant Curve_Argument := Scaled_Length (Length, Range_Lo, Range_Hi, P);
                F : constant Length_Scale := Muscle_Scale (Acceleration, P);
                B : constant Half_Range := 0.5*(1.0+P (5));
       begin (if L <= 1.0 then 0.0 elsif L <= B then
         (declare X : constant Curve_Ratio := (L-1.0)/Real'Max (Min_Val, B-1.0);
          begin (((-F*P (7))*0.5)*X)*X)
       else (declare X : constant Curve_Ratio := (L-B)/Real'Max (Min_Val, B-1.0);
          begin (-F*P (7))*(0.5+X))));
   end Muscle_Bias;
   function Sigmoid (X : Curve_Argument) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Sigmoid);
   begin
      return (if X <= 0.0 then 0.0 elsif X >= 1.0 then 1.0
       else (declare U : constant Unit_Fraction := X; begin ((U*U)*U)*((3.0*U)*(2.0*U-5.0)+10.0)));
   end Sigmoid;
   function Muscle_Timescale (Difference : Real; Tau_Act, Tau_Deact : Real; Width : Input) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Muscle_Timescale);
   begin
      return (if Width < Min_Val then (if Difference > 0.0 then Tau_Act else Tau_Deact)
       else Tau_Deact+(Tau_Act-Tau_Deact)*Sigmoid (Difference/Width+0.5));
   end Muscle_Timescale;
   function Muscle_Derivative (Control, Activation : Input; P : Parameters) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Muscle_Derivative);
   begin
      return (declare A : constant Unit_Fraction := Clamp (Activation, 0.0, 1.0);
                T : constant Activation_Scale := 0.5+1.5*A;
                Difference : constant Real := Clamp (Control, 0.0, 1.0)-Activation;
       begin Difference/Real'Max (Min_Val, Muscle_Timescale (Difference, P (0)*T, P (1)/T, P (2))));
   end Muscle_Derivative;
   function Filter_Derivative (Control, Activation : Input; Tau : Input) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Filter_Derivative);
   begin
      return (Control-Activation)/Real'Max (Min_Val, Tau);
   end Filter_Derivative;
   function Euler (Activation : Input; Derivative : Scalar; H : Positive_Real) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Euler);
   begin
      return Activation+Derivative*H;
   end Euler;
   function Wrap_Setpoint (Control, Length : Input; Period : Positive_Real) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Wrap_Setpoint);
   begin
      return Control-Period*Real'Rounding ((Control-Length)/Period);
   end Wrap_Setpoint;
   function Integral_Derivative (Control, Length, Integral, Limit : Input; Period : Nonneg_Tier0) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Integral_Derivative);
   begin
      return (declare Err : constant Real := (if Period > 0.0 then
         (Control-Length)-Period*Real'Rounding ((Control-Length)/Period) else Control-Length);
       begin (if Limit <= 0.0 then Err elsif Integral >= Limit then Real'Min (Err, 0.0)
       elsif Integral <= -Limit then Real'Max (Err, 0.0) else Err));
   end Integral_Derivative;
   function PID_Force (Position, Velocity, Feedforward, Integral, Length, Speed : Input; Gain, Bias : Parameters; Period : Nonneg_Tier0) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.PID_Force);
   begin
      return (declare Ref : constant Wrapped_Value := (if Period > 0.0 then Wrap_Setpoint (Position, Length, Period) else Position);
       begin (((-Bias (1)*Ref-Bias (2)*Velocity)+Feedforward)
         +(if Gain (0)>0.0 then Gain (0)*Integral else 0.0))+Affine (Bias, Length, Speed));
   end PID_Force;
   function DC_Voltage (Position, Velocity, Feedforward, Voltage, Integral, Length, Speed : Input; Gain : Parameters; Controller : Boolean) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.DC_Voltage);
   begin
      return (if not Controller then Voltage else
       (declare Torque : constant Torque_Value := ((Gain (4)*(Position-Length)+Gain (6)*(Velocity-Speed))+Gain (5)*Integral)+Feedforward;
                Raw : constant Voltage_Value := (Gain (0)/Gain (1))*Torque+Gain (1)*Speed;
       begin (if Gain (7)>0.0 then Clamp (Raw, -Gain (7), Gain (7)) else Raw)+Voltage));
   end DC_Voltage;
   function DC_Resistance (Temperature : Input; Dyn, Gain : Parameters; Thermal : Boolean) return Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.DC_Resistance);
   begin
      return Real'Max (Min_Val, (if Thermal then Gain (0)*(1.0+Gain (2)*((Temperature+Dyn (4))-Gain (3))) else Gain (0)));
   end DC_Resistance;
   function DC_Current_Derivative (Voltage : Scalar; Speed, Current : Input; Resistance, Tau : Positive_Real; K, Limit : Input) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.DC_Current_Derivative);
   begin
      return (declare Raw : constant Current_Rate := ((Voltage/Resistance-(K/Resistance)*Speed)-Current)/Tau;
       begin (if Limit > 0.0 then Clamp (Raw, -Limit, Limit) else Raw));
   end DC_Current_Derivative;
   function DC_Thermal_Derivative (Current, Temperature : Input; Resistance : Input; Thermal_R, Capacity : Positive_Real) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.DC_Thermal_Derivative);
   begin
      return ((Resistance*Current)*Current-Temperature/Thermal_R)/Capacity;
   end DC_Thermal_Derivative;
   function Force (Gain, Drive, Bias : Scalar) return Scalar is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Force);
   begin
      return Gain*Drive+Bias;
   end Force;
end MJ.Actuator_Curves;

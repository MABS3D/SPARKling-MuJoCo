with MJ.Actuator_Curves;
with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
package MJ.Advanced_Actuators with SPARK_Mode is
   type Servo_Input is record
      Position, Velocity, Feedforward, Voltage : Input := 0.0;
      Has_Position, Has_Velocity, Has_Feedforward, Has_Voltage : Boolean := False;
   end record;
   subtype Slot is Integer range -1 .. 4;
   type DC_Slots is record
      Slew, Integral, Temperature, Bristle, Current : Slot := -1;
      N : Natural range 0 .. 5 := 0;
   end record;
   type State is array (Natural range 0 .. 4) of Input;
   type State_Derivative is array (Natural range 0 .. 4) of Scalar;
   function Slots (Dyn, Gain : Parameters) return DC_Slots with
     Post => Slots'Result.N=Boolean'Pos (Dyn (7)>0.0)+Boolean'Pos (Gain (5)>0.0)
       +Boolean'Pos (Dyn (2)>0.0)+Boolean'Pos (Dyn (5)>0.0)+Boolean'Pos (Dyn (0)>0.0)
       and then Slots'Result.Slew=(if Dyn (7)>0.0 then 0 else -1)
       and then Slots'Result.Integral=(if Gain (5)>0.0 then Boolean'Pos (Dyn (7)>0.0) else -1)
       and then Slots'Result.Temperature=(if Dyn (2)>0.0 then Boolean'Pos (Dyn (7)>0.0)+Boolean'Pos (Gain (5)>0.0) else -1)
       and then Slots'Result.Bristle=(if Dyn (5)>0.0 then Boolean'Pos (Dyn (7)>0.0)+Boolean'Pos (Gain (5)>0.0)+Boolean'Pos (Dyn (2)>0.0) else -1)
       and then Slots'Result.Current=(if Dyn (0)>0.0 then Slots'Result.N-1 else -1);
   function Stribeck (Speed, Coulomb, Static_Force, Transition_Speed : Input) return Real;
   function Filter_Next (Activation : Input; Derivative : Scalar; H, Tau : Positive_Real) return Real with
     Pre => Derivative in -1.0e100 .. 1.0e100;
   function Bristle_Next (Activation, Speed : Input; H : Positive_Real; Dyn, Bias : Parameters) return Real with
     Pre => Dyn (5)>=0.0;
   type PID_Result is record
      Force, Effective_Position, Slew_Dot, Integral_Dot, Next_Integral : Real := 0.0;
   end record;
   package Model with Ghost => Static is
      function Effective_Position (U : Servo_Input; Previous : Input; H : Positive_Real;
                                   Period : Nonneg_Tier0; Rate : Input) return Real is
        (if Rate<=0.0 then (if U.Has_Position then U.Position else 0.0) else
          (declare Raw : constant Real := (if U.Has_Position then U.Position else 0.0);
                   Wrapped : constant Real := (if Period>0.0 then
                     Raw-Period*Real'Rounding ((Raw-Previous)/Period) else Raw);
           begin Real'Min (Previous+Rate*H,Real'Max (Previous-Rate*H,Wrapped))))
        with Pre => Period=0.0 or else Period>=Min_Val;
      function Integral_Dot (Position : Real; Length, Integral, Limit : Input;
                             Period : Nonneg_Tier0) return Real is
        (declare Err : constant Real := Position-Length;
                 Wrapped : constant Real := (if Period>0.0 then Err-Period*Real'Rounding (Err/Period) else Err);
         begin (if Limit<=0.0 then Wrapped elsif Integral>=Limit then Real'Min (Wrapped,0.0)
                elsif Integral<=-Limit then Real'Max (Wrapped,0.0) else Wrapped))
        with Pre => Position in -1.0e28 .. 1.0e28 and then (Period=0.0 or else Period>=Min_Val);
      function PID_Law (R : PID_Result; U : Servo_Input; Length, Speed, Previous, Integral : Input;
                        H : Positive_Real; Period : Nonneg_Tier0; Dyn, Gain, Bias : Parameters;
                        Actearly : Boolean) return Boolean is
        (R.Effective_Position=Effective_Position (U,Previous,H,Period,Dyn (1))
         and then R.Effective_Position in -1.0e28 .. 1.0e28
         and then R.Slew_Dot=(if Dyn (1)>0.0 then (R.Effective_Position-Previous)/H else 0.0)
         and then R.Integral_Dot=(if Gain (0)>0.0 then Integral_Dot (R.Effective_Position,Length,Integral,Dyn (0),Period) else 0.0)
         and then R.Next_Integral=(if Gain (0)>0.0 then Integral+R.Integral_Dot*H else Integral)
         and then (declare Ref : constant Real := (if Period>0.0 then
                      R.Effective_Position-Period*Real'Rounding ((R.Effective_Position-Length)/Period) else R.Effective_Position);
                            Drive : constant Real := (if Actearly then R.Next_Integral else Integral);
                            Feed : constant Real := (-Bias (1)*Ref-Bias (2)*(if U.Has_Velocity then U.Velocity else 0.0))
                              +(if U.Has_Feedforward then U.Feedforward else 0.0);
                   begin R.Force=(Feed+(if Gain (0)>0.0 then Gain (0)*Drive else 0.0))
                     +((Bias (0)+Bias (1)*Length)+Bias (2)*Speed)))
        with Pre => Period=0.0 or else Period>=Min_Val;
   end Model;
   function PID (U : Servo_Input; Length, Speed, Slew_State, Integral_State : Input;
                 H : Positive_Real; Period : Nonneg_Tier0; Dyn, Gain, Bias : Parameters;
                 Actearly : Boolean := False) return PID_Result with
     Pre => (Period=0.0 or else Period>=Min_Val)
       and then (Dyn (1)<=0.0 or else U.Has_Position);
   pragma Postcondition (Static => Model.PID_Law (PID'Result,U,Length,Speed,Slew_State,Integral_State,H,Period,Dyn,Gain,Bias,Actearly));
   type Next_State is array (Natural range 0 .. 4) of Real;
   type DC_Result is record
      Force, Voltage, Resistance, Effective_Position : Real := 0.0;
      Dot : State_Derivative := (others => 0.0);
      Next : Next_State := (others => 0.0);
   end record;
   function Raw_Resistance (Activation : State; Dyn, Gain : Parameters) return Real is
     (if Dyn (2)>0.0 then Gain (0)*(1.0+Gain (2)*((Activation (Slots (Dyn,Gain).Temperature)+Dyn (4))-Gain (3))) else Gain (0));
   function DC_Force_Law (R : DC_Result; Activation : State; Length, Speed : Input; Dyn, Gain, Bias : Parameters;
                          Actearly, Limit_Force : Boolean; Lower, Upper : Input) return Real is
     (declare S : constant DC_Slots := Slots (Dyn,Gain);
              Electric : constant Real := (if S.Current>=0 then Gain (1)*(if Actearly then R.Next (S.Current) else Activation (S.Current))
                else (Gain (1)/R.Resistance)*R.Voltage-((Gain (1)/R.Resistance)*Gain (1))*Speed);
              Clamped : constant Real := (if Limit_Force then Real'Min (Upper,Real'Max (Lower,Electric)) else Electric);
              Cogged : constant Real := Clamped+(if Bias (0)/=0.0 then Bias (0)*Math.Sin (Bias (1)*Length+Bias (2)) else 0.0);
      begin Cogged-(if S.Bristle>=0 then Dyn (5)*Activation (S.Bristle)+Dyn (6)*R.Dot (S.Bristle) else 0.0))
     with Ghost => Static, Pre => R.Resistance in Min_Val .. 1.0e32
       and then R.Voltage in -1.0e100 .. 1.0e100
       and then (for all X of R.Next => X in -1.0e190 .. 1.0e190)
       and then (for all X of R.Dot => X in -1.0e190 .. 1.0e190);
   function DC_Law (R : DC_Result; U : Servo_Input; Length, Speed : Input; Activation : State;
                    H : Positive_Real; Dyn, Gain, Bias : Parameters; Actearly, Limit_Force : Boolean;
                    Lower, Upper : Input) return Boolean is
     (declare S : constant DC_Slots := Slots (Dyn,Gain);
              RR : constant Real := Raw_Resistance (Activation,Dyn,Gain);
      begin R.Resistance in Min_Val .. 1.0e32
        and then R.Voltage in -1.0e100 .. 1.0e100
        and then (for all X of R.Next => X in -1.0e190 .. 1.0e190)
        and then (for all X of R.Dot => X in -1.0e190 .. 1.0e190)
        and then R.Effective_Position=Model.Effective_Position (U,(if S.Slew>=0 then Activation (S.Slew) else 0.0),H,0.0,Dyn (7))
        and then R.Effective_Position in Input
        and then R.Voltage=MJ.Actuator_Curves.Model.DC_Voltage
          (R.Effective_Position,(if U.Has_Velocity then U.Velocity else 0.0),(if U.Has_Feedforward then U.Feedforward else 0.0),
           (if U.Has_Voltage then U.Voltage else 0.0),(if S.Integral>=0 then Activation (S.Integral) else 0.0),Length,Speed,Gain,
           U.Has_Position or else U.Has_Velocity or else U.Has_Feedforward)
        and then R.Resistance=Real'Max (Min_Val,RR)
        and then R.Force=DC_Force_Law (R,Activation,Length,Speed,Dyn,Gain,Bias,Actearly,Limit_Force,Lower,Upper)
        and then (for all K in 0 .. 4 => R.Dot (K)=
          (if K=S.Slew then (R.Effective_Position-Activation (K))/H
           elsif K=S.Integral then Model.Integral_Dot (R.Effective_Position,Length,Activation (K),Dyn (8),0.0)
           elsif K=S.Temperature then
             (declare I : constant Real := (if S.Current>=0 then Activation (S.Current) else (R.Voltage-Gain (1)*Speed)/RR);
              begin ((RR*I)*I-Activation (K)/Dyn (2))/Dyn (3))
           elsif K=S.Bristle then ((-Dyn (5)*abs Speed)/Real'Max (Min_Val,Stribeck (Speed,Bias (3),Bias (4),Bias (5))))*Activation (K)+Speed
           elsif K=S.Current then
             (declare Dot_I : constant Real := ((R.Voltage/RR-(Gain (1)/RR)*Speed)-Activation (K))/Dyn (0);
              begin (if Dyn (1)>0.0 then Real'Min (Dyn (1),Real'Max (-Dyn (1),Dot_I)) else Dot_I))
           else 0.0))
        and then (for all K in 0 .. 4 => R.Next (K)=
          (if K=S.Current then Filter_Next (Activation (K),R.Dot (K),H,Real'Max (Min_Val,Dyn (0)))
           elsif K=S.Bristle then Bristle_Next (Activation (K),Speed,H,Dyn,Bias)
           elsif K<S.N then
             (declare Value : constant Real := Activation (K)+R.Dot (K)*H;
              begin (if K=S.Integral and then Dyn (8)>0.0 then Real'Min (Dyn (8),Real'Max (-Dyn (8),Value)) else Value))
           else Activation (K))))
     with Ghost => Static,
       Pre => Gain (0)>=Min_Val and then Raw_Resistance (Activation,Dyn,Gain)>=Min_Val
         and then (if U.Has_Position or else U.Has_Velocity or else U.Has_Feedforward then Gain (1)>=Min_Val)
         and then (Dyn (0)<=0.0 or else Dyn (0)>=Min_Val)
         and then (Dyn (2)<=0.0 or else (Dyn (2)>=Min_Val and then Dyn (3)>=Min_Val))
         and then (if Dyn (0)>0.0 then R.Dot (Slots (Dyn,Gain).Current) in -1.0e100 .. 1.0e100);
   function DC (U : Servo_Input; Length, Speed : Input; Activation : State;
                H : Positive_Real; Dyn, Gain, Bias : Parameters; Actearly : Boolean := False;
                Force_Limited : Boolean := False; Lower, Upper : Input := 0.0) return DC_Result with
     Pre => Gain (0)>=Min_Val
       and then (if U.Has_Position or else U.Has_Velocity or else U.Has_Feedforward then Gain (1)>=Min_Val)
       and then (Dyn (0)<=0.0 or else Dyn (0)>=Min_Val)
       and then (Dyn (2)<=0.0 or else (Dyn (2)>=Min_Val and then Dyn (3)>=Min_Val))
       and then (Dyn (7)<=0.0 or else U.Has_Position)
       and then (not Force_Limited or else Lower<=Upper)
       and then (if Dyn (2)>0.0 then Gain (0)*(1.0+Gain (2)*((Activation (Slots (Dyn,Gain).Temperature)+Dyn (4))-Gain (3)))>=Min_Val);
   pragma Postcondition (Static => (if Dyn (0)>0.0 then DC'Result.Dot (Slots (Dyn,Gain).Current) in -1.0e100 .. 1.0e100)
     and then DC_Law (DC'Result,U,Length,Speed,Activation,H,Dyn,Gain,Bias,Actearly,Force_Limited,Lower,Upper));
   function Muscle_Force (Length, Speed, Range_Lower, Range_Upper, Acceleration,
                          Activation : Input; Gain, Bias : Parameters) return Real;
   pragma Postcondition (Static => Muscle_Force'Result=
     MJ.Actuator_Curves.Model.Muscle_Gain (Length,Speed,Range_Lower,Range_Upper,Acceleration,Gain)*Activation
       +MJ.Actuator_Curves.Model.Muscle_Bias (Length,Range_Lower,Range_Upper,Acceleration,Bias));
   function SO3 (Target : Quaternion; Length, Speed : Vector; Gain, Bias : Parameters;
                 Force_Limited : Boolean := False; Limit : Nonneg_Tier0 := 0.0) return Vector with
     Pre => Bounded (Target,1.0e10) and then Bounded (Length,1.0e10) and then Bounded (Speed,1.0e10);
   function SO3_Expmap (Target, Length, Speed : Vector; Gain, Bias : Parameters;
                       Force_Limited : Boolean := False; Limit : Nonneg_Tier0 := 0.0) return Vector with
     Pre => Bounded (Target,1.0e10) and then Bounded (Length,1.0e10) and then Bounded (Speed,1.0e10);
end MJ.Advanced_Actuators;

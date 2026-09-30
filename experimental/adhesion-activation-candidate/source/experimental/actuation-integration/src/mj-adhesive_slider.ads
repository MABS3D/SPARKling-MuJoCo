with MJ.Types; use MJ.Types;
with MJ.Activation;
with MJ.Contact_Slider;
package MJ.Adhesive_Slider with SPARK_Mode is
   use type MJ.Activation.Dynamics;
   use type MJ.Contact_Slider.Status;
   use type MJ.Contact_Slider.State;
   type Configuration is record
      Motion : MJ.Contact_Slider.Configuration;
      Kind : MJ.Activation.Dynamics := MJ.Activation.None;
      Tau : MJ.Activation.Time_Constant := 1.0;
      Factor : MJ.Activation.Decay_Factor := 0.0;
      Gain : Tier0_Real := 1.0;
      Enabled, Clamp_Control : Boolean := True;
      Early, Control_Limited, Activation_Limited, Force_Limited : Boolean := False;
      Control_Lower, Control_Upper, Activation_Lower, Activation_Upper,
        Force_Lower, Force_Upper : Tier0_Real := 0.0;
   end record;
   type State is record
      Motion : MJ.Contact_Slider.State;
      Act : Tier0_Real := 0.0;
   end record;
   subtype Status is MJ.Contact_Slider.Status;
   type Evaluation is record
      Motion : MJ.Contact_Slider.Evaluation;
      Dot : MJ.Activation.Rate := 0.0;
      Next, Drive, Force, Generalized, Total_Applied : Tier0_Real := 0.0;
      Moment : Real range -1.0 .. 0.0 := 0.0;
      Can_Advance : Boolean := True;
      Result : Status := MJ.Contact_Slider.Success;
   end record;
   function Valid (C : Configuration) return Boolean is
     ((if C.Control_Limited then C.Control_Lower <= C.Control_Upper)
      and then (if C.Activation_Limited then C.Activation_Lower <= C.Activation_Upper)
      and then (if C.Force_Limited then C.Force_Lower <= C.Force_Upper)) with Global => null;
   function Control (C : Configuration; U : Tier0_Real) return Tier0_Real is
     (if C.Clamp_Control and then C.Control_Limited then
        Real'Max (C.Control_Lower, Real'Min (C.Control_Upper, U)) else U)
      with Global => null, Pre => Valid (C);
   function Scalar_Force (C : Configuration; Drive : Tier0_Real) return Real is
     (if not C.Enabled then 0.0
      elsif C.Force_Limited then Real'Max (C.Force_Lower, Real'Min (C.Force_Upper, C.Gain*Drive))
      else C.Gain*Drive) with Global => null, Pre => Valid (C);
   function Contact_Moment (C : MJ.Contact_Slider.Configuration; S : MJ.Contact_Slider.State)
      return Real is
     (if C.Margin+C.Gap > Max_Val then 0.0
      elsif not ((S.Height-C.Plane_Height) > (C.Margin+C.Gap)+C.Radius) then -1.0 else 0.0)
      with Global => null;
   function Expected_Dot (C : Configuration; S : State; U : Tier0_Real) return MJ.Activation.Rate is
     (if C.Enabled then MJ.Activation.Derivative (C.Kind, Control (C,U), S.Act, C.Tau) else 0.0)
      with Global => null, Pre => Valid (C);
   function Expected_Next (C : Configuration; S : State; U : Tier0_Real) return MJ.Activation.Update_Value is
     (if not C.Enabled or else C.Kind = MJ.Activation.None then S.Act
      else MJ.Activation.Next_Value (C.Kind, S.Act, Expected_Dot (C,S,U),
        C.Motion.H,C.Tau,C.Factor,C.Activation_Limited,C.Activation_Lower,C.Activation_Upper))
      with Global => null, Pre => Valid (C);
   function Expected_Drive (C : Configuration; S : State; U : Tier0_Real) return Tier0_Real is
     (if C.Kind = MJ.Activation.None then Control (C,U)
      elsif C.Early and then Expected_Next (C,S,U) in Tier0_Real then Expected_Next (C,S,U) else S.Act)
      with Global => null, Pre => Valid (C);
   package Model with Ghost => Static is
      function Matches (C : Configuration; S : State; U, Applied : Tier0_Real; E : Evaluation)
         return Boolean is
       (E.Dot = Expected_Dot (C,S,U)
        and then E.Can_Advance = (Expected_Next (C,S,U) in Tier0_Real)
        and then E.Next = (if E.Can_Advance then Expected_Next (C,S,U) else S.Act)
        and then E.Drive = Expected_Drive (C,S,U)
        and then (if (C.Kind /= MJ.Activation.None and then C.Early and then not E.Can_Advance)
          or else Scalar_Force (C,E.Drive) not in Tier0_Real
          or else C.Motion.Margin+C.Motion.Gap > Max_Val then
            E.Result = MJ.Contact_Slider.Numeric_Limit
            and then E.Force = 0.0 and then E.Generalized = 0.0 and then E.Total_Applied = 0.0 and then E.Moment = 0.0
         else E.Force = Scalar_Force (C,E.Drive)
           and then E.Moment = Contact_Moment (C.Motion,S.Motion)
           and then E.Generalized = E.Force * E.Moment
           and then (if Applied+E.Generalized not in Tier0_Real then
             E.Result = MJ.Contact_Slider.Numeric_Limit and then E.Total_Applied = 0.0
           else E.Total_Applied = Applied+E.Generalized
             and then MJ.Contact_Slider.Model.Evaluated (C.Motion,S.Motion,E.Total_Applied,E.Motion)
             and then E.Result = E.Motion.Result)))
         with Global => null, Pre => Valid (C), Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Accepted (C : Configuration; S : State; E : Evaluation) return Boolean is
       (E.Result = MJ.Contact_Slider.Success and then E.Can_Advance
        and then MJ.Contact_Slider.Model.Step_Accepted (C.Motion,S.Motion,E.Motion))
         with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   function Moment_For (C : MJ.Contact_Slider.Configuration; S : MJ.Contact_Slider.State)
      return Real with Global => null, Pre => C.Margin+C.Gap <= Max_Val,
      Post => (Static => Moment_For'Result = Contact_Moment (C,S));
   procedure Evaluate (C : Configuration; S : State; U, Applied : Tier0_Real; E : out Evaluation)
      with Global => null, Pre => Valid (C),
      Post => (Static => Model.Matches (C,S,U,Applied,E)
        and then (if E.Result = MJ.Contact_Slider.Success then E.Motion.Result = MJ.Contact_Slider.Success));
   procedure Step (C : Configuration; S : in out State; U, Applied : Tier0_Real;
      E : out Evaluation; Result : out Status) with Global => null, Pre => Valid (C),
      Post => (Static => Model.Matches (C,S'Old,U,Applied,E)
        and then (Result = MJ.Contact_Slider.Success) = Model.Accepted (C,S'Old,E)
        and then (if Result = MJ.Contact_Slider.Success then
          S.Act = E.Next and then S.Motion.Time = S.Motion.Time'Old + C.Motion.H
          and then S.Motion.Velocity = MJ.Contact_Slider.Model.Next_Velocity
            (S.Motion'Old,C.Motion.H,E.Motion.Info.Row.Acceleration)
          and then S.Motion.Height = MJ.Contact_Slider.Model.Next_Height
            (S.Motion'Old,C.Motion.H,S.Motion.Velocity)
          else S = S'Old));
end MJ.Adhesive_Slider;

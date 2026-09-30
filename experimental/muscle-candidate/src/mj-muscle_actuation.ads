--  Scalar muscle actuator. Transmission length/velocity are provided by the caller.
with MJ.Types; use MJ.Types;
with MJ.Muscle_Kernels; use MJ.Muscle_Kernels;
package MJ.Muscle_Actuation with SPARK_Mode is
   subtype Activation_Value is Real range -1.0e50 .. 1.0e50;
   subtype Force_Value is Real range -1.0e220 .. 1.0e220;
   type Configuration is record
      Gain_Parameters : Parameters := Default_Parameters;
      Bias_Parameters : Parameters := Default_Parameters;
      Dynamics : Dynamics_Parameters := Default_Dynamics;
      Range_Of_Length : Length_Range := (0.0, 1.0);
      Acc0 : Tier0_Real := 1.0;
      Control_Limited : Boolean := False;
      Activation_Limited : Boolean := False;
      Force_Limited : Boolean := False;
      Control_Range : Length_Range := (0.0,1.0);
      Activation_Range : Length_Range := (0.0,1.0);
      Force_Range : Length_Range := (-1.0e10,1.0e10);
      Actearly : Boolean := False;
   end record;
   function Valid (P : Configuration) return Boolean is
     ((not P.Control_Limited or else P.Control_Range(0) <= P.Control_Range(1))
      and then (not P.Activation_Limited or else P.Activation_Range(0) <= P.Activation_Range(1))
      and then (not P.Force_Limited or else P.Force_Range(0) <= P.Force_Range(1)));
   type State is record
      Activation : Tier0_Real := 0.0;
   end record;
   type Evaluation is record
      Gain, Bias : Coefficient := 0.0;
      Derivative : Tier1_Real := 0.0;
      Next_Activation : Activation_Value := 0.0;
      Force : Force_Value := 0.0;
   end record;
   type Step_Status is (Success, Numeric_Limit);
   package Model with Ghost => Static is
      function Control (P : Configuration; Ctrl : Tier0_Real) return Tier0_Real is
        (if P.Control_Limited then MJ.Muscle_Kernels.Model.Clip(Ctrl,P.Control_Range(0),P.Control_Range(1)) else Ctrl)
        with Global => null;
      function Next_Activation (P : Configuration; A : Tier0_Real; D : Tier1_Real; H : Nonneg_Tier0) return Activation_Value is
        (declare Next_A : constant Activation_Value := A+D*H;
         begin (if P.Activation_Limited then
           (if Next_A < P.Activation_Range(0) then P.Activation_Range(0) elsif Next_A > P.Activation_Range(1) then P.Activation_Range(1) else Next_A) else Next_A))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Force (P : Configuration; G, B : Coefficient; A : Activation_Value) return Force_Value is
        (declare F : constant Force_Value := G*A+B;
         begin (if P.Force_Limited then (if F < P.Force_Range(0) then P.Force_Range(0) elsif F > P.Force_Range(1) then P.Force_Range(1) else F) else F))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Matches (P : Configuration; S : State; Ctrl, Length, Velocity : Tier0_Real; H : Nonneg_Tier0; E : Evaluation) return Boolean is
        (E.Gain = MJ.Muscle_Kernels.Model.Gain(Length,Velocity,P.Range_Of_Length,P.Acc0,P.Gain_Parameters)
         and then E.Bias = MJ.Muscle_Kernels.Model.Bias(Length,P.Range_Of_Length,P.Acc0,P.Bias_Parameters)
         and then E.Derivative = MJ.Muscle_Kernels.Model.Dynamics(Control(P,Ctrl),S.Activation,P.Dynamics)
         and then E.Next_Activation = Next_Activation(P,S.Activation,E.Derivative,H)
         and then E.Force = Force(P,E.Gain,E.Bias,(if P.Actearly then E.Next_Activation else S.Activation)))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   function Next_Activation (P : Configuration; A : Tier0_Real; D : Tier1_Real; H : Nonneg_Tier0) return Activation_Value with
     Global => null, Inline_Always,
     Post => (Static => Next_Activation'Result = Model.Next_Activation(P,A,D,H)
       and then (if P.Activation_Limited then Next_Activation'Result in Tier0_Real));
   function Force (P : Configuration; G, B : Coefficient; A : Activation_Value) return Force_Value with
     Global => null, Inline_Always,
     Post => (Static => Force'Result = Model.Force(P,G,B,A));
   procedure Evaluate (P : Configuration; S : State; Ctrl, Length, Velocity : Tier0_Real; H : Nonneg_Tier0; E : out Evaluation) with
     Global => null, Inline_Always, Pre => Valid(P),
     Post => (Static => Model.Matches(P,S,Ctrl,Length,Velocity,H,E)
       and then (if P.Activation_Limited then E.Next_Activation in Tier0_Real));
   --  Numeric_Limit preserves the owned state; the evaluation remains available.
   --  This explicit finite-state policy is stricter than unbounded C integration.
   procedure Step (P : Configuration; S : in out State; Ctrl, Length, Velocity : Tier0_Real; H : Nonneg_Tier0; E : out Evaluation; Status : out Step_Status) with
     Global => null, Inline_Always, Pre => Valid(P),
     Post => (Static => Model.Matches(P,S'Old,Ctrl,Length,Velocity,H,E)
       and then (if E.Next_Activation in Tier0_Real then
         Status = Success and then S.Activation = E.Next_Activation
       else Status = Numeric_Limit and then S = S'Old));
end MJ.Muscle_Actuation;

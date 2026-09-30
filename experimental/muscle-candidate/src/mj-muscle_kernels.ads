--  MuJoCo 3.14.0 muscle kernels; no allocation or transmission assumptions.
with MJ.Types; use MJ.Types;
package MJ.Muscle_Kernels with SPARK_Mode is
   type Parameters is array (Natural range 0 .. 8) of Tier0_Real;
   type Dynamics_Parameters is array (Natural range 0 .. 2) of Tier0_Real;
   type Length_Range is array (Natural range 0 .. 1) of Tier0_Real;
   Default_Parameters : constant Parameters := (0.75,1.05,-1.0,200.0,0.5,1.6,1.5,1.3,1.2);
   Default_Dynamics : constant Dynamics_Parameters := (0.01,0.04,0.0);
   subtype Velocity_Offset is Real range -2.0e10 .. 2.0e10;
   subtype Coefficient is Real range -1.0e160 .. 1.0e160;
   subtype Passive_Ratio is Real range -1.0e46 .. 1.0e46;
   subtype Unit_Value is Real range 0.0 .. 1.0;
   subtype Modulation is Real range 0.5 .. 2.0;
   subtype Time_Input is Real range -1.0e11 .. 1.0e11;
   subtype Time_Value is Real range -1.0e14 .. 1.0e14;
   subtype Triple_Unit is Real range 0.0 .. 3.0;
   subtype Linear_Factor is Real range -5.0 .. -3.0;
   subtype Sigmoid_Value is Real range -32.0 .. 32.0;
   --  Conservative sigmoid bounds are safety bounds, not a claim about exact
   --  real monotonicity or positivity of rounded arithmetic.
   package Model with Ghost => Static is
      function Clip (X, Low, High : Tier0_Real) return Tier0_Real is
        (if X < Low then Low elsif X > High then High else X)
        with Global => null, Post => (if Low <= High then Clip'Result in Low .. High),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Optimal_Length (R : Length_Range; P : Parameters) return Tier1_Real is
        ((R(1)-R(0)) / Real'Max (Min_Val, P(1)-P(0)))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Normalized_Length (Length : Tier0_Real; R : Length_Range; P : Parameters) return Tier1_Real is
        (P(0) + (Length-R(0)) / Real'Max (Min_Val, Optimal_Length (R, P)))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Scaled_Force (P : Parameters; Acc0 : Tier0_Real) return Tier1_Real is
        (if P(2) < 0.0 then P(3) / Real'Max (Min_Val, Acc0) else P(2))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Length_Gain (Length : Tier1_Real; Lmin, Lmax : Tier0_Real) return Tier2_Real is
        (if Lmin <= Length and then Length <= Lmax then
         (declare N : constant Tier0_Real := Length;
                  A : constant Tier0_Real := 0.5*(Lmin+1.0);
                  B : constant Tier0_Real := 0.5*(1.0+Lmax);
          begin (if N <= A then
            (declare X : constant Tier1_Real := (N-Lmin)/Real'Max(Min_Val,A-Lmin);
             begin (0.5*X)*X)
          elsif N <= 1.0 then
            (declare X : constant Tier1_Real := (1.0-N)/Real'Max(Min_Val,1.0-A);
             begin 1.0-(0.5*X)*X)
          elsif N <= B then
            (declare X : constant Tier1_Real := (N-1.0)/Real'Max(Min_Val,B-1.0);
             begin 1.0-(0.5*X)*X)
          else
            (declare X : constant Tier1_Real := (Lmax-N)/Real'Max(Min_Val,Lmax-B);
             begin (0.5*X)*X)))
       else 0.0)
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Velocity_Gain (Velocity : Tier1_Real; Fvmax : Tier0_Real) return Tier2_Real is
        (declare Y : constant Velocity_Offset := Fvmax-1.0;
       begin (if Velocity <= -1.0 then 0.0
         elsif Velocity <= 0.0 then (Velocity+1.0)*(Velocity+1.0)
         elsif Velocity <= Y then Fvmax-((Y-Velocity)*(Y-Velocity))/Real'Max(Min_Val,Y)
         else Fvmax))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Gain (Length, Velocity : Tier0_Real; R : Length_Range; Acc0 : Tier0_Real; P : Parameters) return Coefficient is
        (declare F : constant Tier1_Real := Scaled_Force (P, Acc0);
                L0 : constant Tier1_Real := Optimal_Length (R, P);
                L : constant Tier1_Real := Normalized_Length (Length, R, P);
                V : constant Tier1_Real := Velocity/Real'Max(Min_Val,L0*P(6));
                FL : constant Tier2_Real := Length_Gain (L, P(4), P(5));
                FV : constant Tier2_Real := Velocity_Gain (V, P(8));
       begin (-F*FL)*FV)
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Bias (Length : Tier0_Real; R : Length_Range; Acc0 : Tier0_Real; P : Parameters) return Coefficient is
        (declare F : constant Tier1_Real := Scaled_Force (P, Acc0);
                L : constant Tier1_Real := Normalized_Length (Length, R, P);
                B : constant Tier0_Real := 0.5*(1.0+P(5));
       begin (if L <= 1.0 then 0.0
         elsif L <= B then
           (declare X : constant Passive_Ratio := (L-1.0)/Real'Max(Min_Val,B-1.0);
            begin (((-F*P(7))*0.5)*X)*X)
         else
           (declare X : constant Passive_Ratio := (L-B)/Real'Max(Min_Val,B-1.0);
            begin (-F*P(7))*(0.5+X))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Sigmoid (X : Tier1_Real) return Sigmoid_Value is
        (if X <= 0.0 then 0.0 elsif X >= 1.0 then 1.0
       else (declare X2 : constant Unit_Value := X*X;
                     X3 : constant Unit_Value := X2*X;
                     T : constant Triple_Unit := 3.0*X;
                     B : constant Linear_Factor := 2.0*X-5.0;
                     Q : constant Sigmoid_Value := T*B+10.0;
             begin X3*Q))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Timescale (Dctrl, Tau_Act, Tau_Deact : Time_Input; Width : Tier0_Real) return Time_Value is
        (if Width < Min_Val then (if Dctrl > 0.0 then Tau_Act else Tau_Deact)
       else Tau_Deact + (Tau_Act-Tau_Deact)*Sigmoid(Dctrl/Width+0.5))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Excitation (Control, Activation : Tier0_Real) return Time_Input is
        (Clip(Control,0.0,1.0)-Activation)
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Activation_Time (Activation, Base_Time : Tier0_Real) return Time_Input is
        (Base_Time*(0.5+1.5*Clip(Activation,0.0,1.0)))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Deactivation_Time (Activation, Base_Time : Tier0_Real) return Time_Input is
        (Base_Time/(0.5+1.5*Clip(Activation,0.0,1.0)))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Dynamics (Control, Activation : Tier0_Real; P : Dynamics_Parameters) return Tier1_Real is
        (Excitation(Control,Activation) / Real'Max(Min_Val,
          Timescale(Excitation(Control,Activation),Activation_Time(Activation,P(0)),
            Deactivation_Time(Activation,P(1)),P(2))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      procedure Equal_Excitation (C1,C2,Activation : Tier0_Real) with
        Global => null, Pre => C1=C2,
        Post => Excitation(C1,Activation)=Excitation(C2,Activation);
      procedure Equal_Dynamics (C1,C2,Activation : Tier0_Real; P : Dynamics_Parameters) with
        Global => null, Pre => C1=C2,
        Post => Dynamics(C1,Activation,P)=Dynamics(C2,Activation,P);
      --  Opaque floating-point models need explicit value-congruence lemmas
      --  when caller intermediates are related by scalar equality.
      procedure Equal_Length_Gain (A, B : Tier1_Real; Lmin, Lmax : Tier0_Real) with
        Global => null, Pre => A=B,
        Post => Length_Gain(A,Lmin,Lmax)=Length_Gain(B,Lmin,Lmax);
      procedure Equal_Velocity_Gain (A, B : Tier1_Real; Fvmax : Tier0_Real) with
        Global => null, Pre => A=B,
        Post => Velocity_Gain(A,Fvmax)=Velocity_Gain(B,Fvmax);
      procedure Equal_Sigmoid (A, B : Tier1_Real) with
        Global => null, Pre => A=B, Post => Sigmoid(A)=Sigmoid(B);
      procedure Equal_Rate (D1,D2 : Time_Input; T1,T2 : Time_Value) with
        Global => null, Pre => D1=D2 and then T1=T2,
        Post => D1/Real'Max(Min_Val,T1)=D2/Real'Max(Min_Val,T2);
      procedure Equal_Timescale (D1,D2,Ta1,Ta2,Td1,Td2 : Time_Input; W : Tier0_Real) with
        Global => null, Pre => D1=D2 and then Ta1=Ta2 and then Td1=Td2,
        Post => Timescale(D1,Ta1,Td1,W)=Timescale(D2,Ta2,Td2,W);
   end Model;
   function Clip (X, Low, High : Tier0_Real) return Tier0_Real with
     Global => null, Inline_Always,
     Post => (Static => Clip'Result = Model.Clip(X,Low,High)
       and then (if Low <= High then Clip'Result in Low .. High));
   function Optimal_Length (R : Length_Range; P : Parameters) return Tier1_Real with
     Global => null, Inline_Always,
     Post => (Static => Optimal_Length'Result = Model.Optimal_Length (R, P));
   function Normalized_Length (Length : Tier0_Real; R : Length_Range; P : Parameters) return Tier1_Real with
     Global => null, Inline_Always,
     Post => (Static => Normalized_Length'Result = Model.Normalized_Length (Length, R, P));
   function Scaled_Force (P : Parameters; Acc0 : Tier0_Real) return Tier1_Real with
     Global => null, Inline_Always,
     Post => (Static => Scaled_Force'Result = Model.Scaled_Force (P, Acc0));
   function Length_Gain (Length : Tier1_Real; Lmin, Lmax : Tier0_Real) return Tier2_Real with
     Global => null, Inline_Always,
     Post => (Static => Length_Gain'Result = Model.Length_Gain (Length, Lmin, Lmax));
   function Velocity_Gain (Velocity : Tier1_Real; Fvmax : Tier0_Real) return Tier2_Real with
     Global => null, Inline_Always,
     Post => (Static => Velocity_Gain'Result = Model.Velocity_Gain (Velocity, Fvmax));
   function Gain (Length, Velocity : Tier0_Real; R : Length_Range; Acc0 : Tier0_Real; P : Parameters) return Coefficient with
     Global => null, Inline_Always,
     Post => (Static => Gain'Result = Model.Gain (Length, Velocity, R, Acc0, P));
   function Bias (Length : Tier0_Real; R : Length_Range; Acc0 : Tier0_Real; P : Parameters) return Coefficient with
     Global => null, Inline_Always,
     Post => (Static => Bias'Result = Model.Bias (Length, R, Acc0, P));
   function Sigmoid (X : Tier1_Real) return Sigmoid_Value with
     Global => null, Inline_Always,
     Post => (Static => Sigmoid'Result = Model.Sigmoid (X));
   function Timescale (Dctrl, Tau_Act, Tau_Deact : Time_Input; Width : Tier0_Real) return Time_Value with
     Global => null, Inline_Always,
     Post => (Static => Timescale'Result = Model.Timescale (Dctrl, Tau_Act, Tau_Deact, Width));
   function Dynamics (Control, Activation : Tier0_Real; P : Dynamics_Parameters) return Tier1_Real with
     Global => null, Inline_Always,
     Post => (Static => Dynamics'Result = Model.Dynamics (Control, Activation, P));
end MJ.Muscle_Kernels;

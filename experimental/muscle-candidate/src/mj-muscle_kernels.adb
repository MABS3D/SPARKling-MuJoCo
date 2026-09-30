package body MJ.Muscle_Kernels with SPARK_Mode is
   package body Model is
      procedure Equal_Excitation (C1,C2,Activation : Tier0_Real) is
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Excitation);
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Clip);
      begin null; end Equal_Excitation;
      procedure Equal_Dynamics (C1,C2,Activation : Tier0_Real; P : Dynamics_Parameters) is
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Dynamics);
      begin
         Equal_Excitation(C1,C2,Activation);
         Equal_Timescale(Excitation(C1,Activation),Excitation(C2,Activation),
           Activation_Time(Activation,P(0)),Activation_Time(Activation,P(0)),
           Deactivation_Time(Activation,P(1)),Deactivation_Time(Activation,P(1)),P(2));
         Equal_Rate(Excitation(C1,Activation),Excitation(C2,Activation),
           Timescale(Excitation(C1,Activation),Activation_Time(Activation,P(0)),Deactivation_Time(Activation,P(1)),P(2)),
           Timescale(Excitation(C2,Activation),Activation_Time(Activation,P(0)),Deactivation_Time(Activation,P(1)),P(2)));
      end Equal_Dynamics;
      procedure Equal_Length_Gain (A, B : Tier1_Real; Lmin, Lmax : Tier0_Real) is
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Length_Gain);
      begin null; end Equal_Length_Gain;
      procedure Equal_Velocity_Gain (A, B : Tier1_Real; Fvmax : Tier0_Real) is
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Velocity_Gain);
      begin null; end Equal_Velocity_Gain;
      procedure Equal_Sigmoid (A, B : Tier1_Real) is
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Sigmoid);
      begin null; end Equal_Sigmoid;
      procedure Equal_Rate (D1,D2 : Time_Input; T1,T2 : Time_Value) is
      begin
         if T1 <= Min_Val then
            pragma Assert (Real'Max(Min_Val,T1)=Min_Val);
            pragma Assert (Real'Max(Min_Val,T2)=Min_Val);
         else
            pragma Assert (Real'Max(Min_Val,T1)=T1);
            pragma Assert (Real'Max(Min_Val,T2)=T2);
         end if;
      end Equal_Rate;
      procedure Equal_Timescale (D1,D2,Ta1,Ta2,Td1,Td2 : Time_Input; W : Tier0_Real) is
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Timescale);
      begin
         if W >= Min_Val then
            Equal_Sigmoid(D1/W+0.5,D2/W+0.5);
         end if;
      end Equal_Timescale;
   end Model;
   function Clip (X, Low, High : Tier0_Real) return Tier0_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Clip);
   begin
      if X < Low then return Low;
      elsif X > High then return High;
      else return X; end if;
   end Clip;
   function Optimal_Length (R : Length_Range; P : Parameters) return Tier1_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Optimal_Length);
   begin
      return ((R(1)-R(0)) / Real'Max (Min_Val, P(1)-P(0)));
   end Optimal_Length;
   function Normalized_Length (Length : Tier0_Real; R : Length_Range; P : Parameters) return Tier1_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalized_Length);
   begin
      return (P(0) + (Length-R(0)) / Real'Max (Min_Val, Optimal_Length (R, P)));
   end Normalized_Length;
   function Scaled_Force (P : Parameters; Acc0 : Tier0_Real) return Tier1_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Scaled_Force);
   begin
      return (if P(2) < 0.0 then P(3) / Real'Max (Min_Val, Acc0) else P(2));
   end Scaled_Force;
   function Length_Gain (Length : Tier1_Real; Lmin, Lmax : Tier0_Real) return Tier2_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Length_Gain);
   begin
      return (if Lmin <= Length and then Length <= Lmax then
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
       else 0.0);
   end Length_Gain;
   function Velocity_Gain (Velocity : Tier1_Real; Fvmax : Tier0_Real) return Tier2_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Velocity_Gain);
   begin
      return (declare Y : constant Velocity_Offset := Fvmax-1.0;
       begin (if Velocity <= -1.0 then 0.0
         elsif Velocity <= 0.0 then (Velocity+1.0)*(Velocity+1.0)
         elsif Velocity <= Y then Fvmax-((Y-Velocity)*(Y-Velocity))/Real'Max(Min_Val,Y)
         else Fvmax));
   end Velocity_Gain;
   function Gain (Length, Velocity : Tier0_Real; R : Length_Range; Acc0 : Tier0_Real; P : Parameters) return Coefficient is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Gain);
      F : constant Tier1_Real := Scaled_Force(P,Acc0);
      L0 : constant Tier1_Real := Optimal_Length(R,P);
      L : constant Tier1_Real := Normalized_Length(Length,R,P);
      V : constant Tier1_Real := Velocity/Real'Max(Min_Val,L0*P(6));
      FL : constant Tier2_Real := Length_Gain(L,P(4),P(5));
      FV : constant Tier2_Real := Velocity_Gain(V,P(8));
   begin
      Model.Equal_Length_Gain(L,Model.Normalized_Length(Length,R,P),P(4),P(5));
      Model.Equal_Velocity_Gain(V,Velocity/Real'Max(Min_Val,Model.Optimal_Length(R,P)*P(6)),P(8));
      return (-F*FL)*FV;
   end Gain;
   function Bias (Length : Tier0_Real; R : Length_Range; Acc0 : Tier0_Real; P : Parameters) return Coefficient is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Bias);
   begin
      return (declare F : constant Tier1_Real := Scaled_Force (P, Acc0);
                L : constant Tier1_Real := Normalized_Length (Length, R, P);
                B : constant Tier0_Real := 0.5*(1.0+P(5));
       begin (if L <= 1.0 then 0.0
         elsif L <= B then
           (declare X : constant Passive_Ratio := (L-1.0)/Real'Max(Min_Val,B-1.0);
            begin (((-F*P(7))*0.5)*X)*X)
         else
           (declare X : constant Passive_Ratio := (L-B)/Real'Max(Min_Val,B-1.0);
            begin (-F*P(7))*(0.5+X))));
   end Bias;
   function Sigmoid (X : Tier1_Real) return Sigmoid_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Sigmoid);
   begin
      return (if X <= 0.0 then 0.0 elsif X >= 1.0 then 1.0
       else (declare X2 : constant Unit_Value := X*X;
                     X3 : constant Unit_Value := X2*X;
                     T : constant Triple_Unit := 3.0*X;
                     B : constant Linear_Factor := 2.0*X-5.0;
                     Q : constant Sigmoid_Value := T*B+10.0;
             begin X3*Q));
   end Sigmoid;
   function Timescale (Dctrl, Tau_Act, Tau_Deact : Time_Input; Width : Tier0_Real) return Time_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Timescale);
   begin
      return (if Width < Min_Val then (if Dctrl > 0.0 then Tau_Act else Tau_Deact)
       else Tau_Deact + (Tau_Act-Tau_Deact)*Sigmoid(Dctrl/Width+0.5));
   end Timescale;
   function Dynamics (Control, Activation : Tier0_Real; P : Dynamics_Parameters) return Tier1_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Dynamics);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Excitation);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Activation_Time);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Deactivation_Time);
      C : constant Unit_Value := Clip(Control,0.0,1.0);
      A : constant Unit_Value := Clip(Activation,0.0,1.0);
      M : constant Modulation := 0.5+1.5*A;
      Ta : constant Time_Input := P(0)*M;
      Td : constant Time_Input := P(1)/M;
      D : constant Time_Input := C-Activation;
      T : constant Time_Value := Timescale(D,Ta,Td,P(2));
   begin
      Model.Equal_Timescale(D,Model.Excitation(Control,Activation),
        Ta,Model.Activation_Time(Activation,P(0)),
        Td,Model.Deactivation_Time(Activation,P(1)),P(2));
      pragma Assert (Static => D=Model.Excitation(Control,Activation));
      pragma Assert (Static => Ta=Model.Activation_Time(Activation,P(0)));
      pragma Assert (Static => Td=Model.Deactivation_Time(Activation,P(1)));
      pragma Assert (Static => T=Model.Timescale(Model.Excitation(Control,Activation),
        Model.Activation_Time(Activation,P(0)),Model.Deactivation_Time(Activation,P(1)),P(2)));
      Model.Equal_Rate(D,Model.Excitation(Control,Activation),T,
        Model.Timescale(Model.Excitation(Control,Activation),
          Model.Activation_Time(Activation,P(0)),Model.Deactivation_Time(Activation,P(1)),P(2)));
      return D/Real'Max(Min_Val,T);
   end Dynamics;
end MJ.Muscle_Kernels;

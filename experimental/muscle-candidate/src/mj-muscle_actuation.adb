package body MJ.Muscle_Actuation with SPARK_Mode is
   function Next_Activation (P : Configuration; A : Tier0_Real; D : Tier1_Real; H : Nonneg_Tier0) return Activation_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Next_Activation);
      Next_A : constant Activation_Value := A+D*H;
   begin
      if P.Activation_Limited then
         return (if Next_A < P.Activation_Range(0) then P.Activation_Range(0) elsif Next_A > P.Activation_Range(1) then P.Activation_Range(1) else Next_A);
      end if;
      return Next_A;
   end Next_Activation;
   function Force (P : Configuration; G, B : Coefficient; A : Activation_Value) return Force_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Force);
      F : constant Force_Value := G*A+B;
   begin
      if P.Force_Limited then
         return (if F < P.Force_Range(0) then P.Force_Range(0) elsif F > P.Force_Range(1) then P.Force_Range(1) else F);
      end if;
      return F;
   end Force;
   procedure Evaluate (P : Configuration; S : State; Ctrl, Length, Velocity : Tier0_Real; H : Nonneg_Tier0; E : out Evaluation) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Matches);
      C : constant Tier0_Real := (if P.Control_Limited then
         Clip(Ctrl,P.Control_Range(0),P.Control_Range(1)) else Ctrl);
      D : constant Tier1_Real := MJ.Muscle_Kernels.Dynamics(C,S.Activation,P.Dynamics);
      A : constant Activation_Value := Next_Activation(P,S.Activation,D,H);
      G : constant Coefficient := Gain(Length,Velocity,P.Range_Of_Length,P.Acc0,P.Gain_Parameters);
      B : constant Coefficient := Bias(Length,P.Range_Of_Length,P.Acc0,P.Bias_Parameters);
      F : constant Force_Value := Force(P,G,B,(if P.Actearly then A else S.Activation));
   begin
      MJ.Muscle_Kernels.Model.Equal_Dynamics(C,Model.Control(P,Ctrl),S.Activation,P.Dynamics);
      E := (G,B,D,A,F);
      pragma Assert (Static => E.Gain = MJ.Muscle_Kernels.Model.Gain(Length,Velocity,P.Range_Of_Length,P.Acc0,P.Gain_Parameters));
      pragma Assert (Static => E.Bias = MJ.Muscle_Kernels.Model.Bias(Length,P.Range_Of_Length,P.Acc0,P.Bias_Parameters));
      pragma Assert (Static => E.Derivative = MJ.Muscle_Kernels.Model.Dynamics(Model.Control(P,Ctrl),S.Activation,P.Dynamics));
      pragma Assert (Static => E.Next_Activation = Model.Next_Activation(P,S.Activation,E.Derivative,H));
      pragma Assert (Static => E.Force = Model.Force(P,E.Gain,E.Bias,(if P.Actearly then E.Next_Activation else S.Activation)));
   end Evaluate;
   procedure Step (P : Configuration; S : in out State; Ctrl, Length, Velocity : Tier0_Real; H : Nonneg_Tier0; E : out Evaluation; Status : out Step_Status) is
   begin
      Evaluate(P,S,Ctrl,Length,Velocity,H,E);
      if P.Activation_Limited or else E.Next_Activation in Tier0_Real then
         S.Activation := E.Next_Activation;
         Status := Success;
      else
         Status := Numeric_Limit;
      end if;
   end Step;
end MJ.Muscle_Actuation;

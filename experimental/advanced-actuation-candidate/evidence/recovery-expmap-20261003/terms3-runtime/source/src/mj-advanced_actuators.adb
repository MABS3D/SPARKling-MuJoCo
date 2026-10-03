with MJ.Actuator_Curves; use MJ.Actuator_Curves;
with MJ.Actuator_Geometry;
package body MJ.Advanced_Actuators with SPARK_Mode is
   function Slots (Dyn, Gain : Parameters) return DC_Slots is
      R : DC_Slots;
   begin
      if Dyn (7)>0.0 then R.Slew := R.N; R.N := R.N+1; end if;
      if Gain (5)>0.0 then R.Integral := R.N; R.N := R.N+1; end if;
      if Dyn (2)>0.0 then R.Temperature := R.N; R.N := R.N+1; end if;
      if Dyn (5)>0.0 then R.Bristle := R.N; R.N := R.N+1; end if;
      if Dyn (0)>0.0 then R.Current := R.N; R.N := R.N+1; end if;
      return R;
   end Slots;
   function Stribeck (Speed, Coulomb, Static_Force, Transition_Speed : Input) return Real is
      Ratio : constant Real := Speed/Real'Max (Min_Val,Transition_Speed);
   begin return Coulomb+(Static_Force-Coulomb)*Math.Exp ((-Ratio)*Ratio); end Stribeck;
   function Filter_Next (Activation : Input; Derivative : Scalar; H, Tau : Positive_Real) return Real is
   begin return Activation+(Derivative*Tau)*(1.0-Math.Exp (-H/Tau)); end Filter_Next;
   function Bristle_Next (Activation, Speed : Input; H : Positive_Real; Dyn, Bias : Parameters) return Real is
      G : constant Real := Stribeck (Speed,Bias (3),Bias (4),Bias (5));
      A : constant Real := (-Dyn (5)*abs Speed)/Real'Max (Min_Val,G);
      E : constant Real := Math.Exp (A*H);
      I : constant Real := (if abs A>Min_Val then (E-1.0)/A else H);
   begin return E*Activation+I*Speed; end Bristle_Next;
   function PID (U : Servo_Input; Length, Speed, Slew_State, Integral_State : Input;
                 H : Positive_Real; Period : Nonneg_Tier0; Dyn, Gain, Bias : Parameters;
                 Actearly : Boolean := False) return PID_Result is
      R : PID_Result;
      Position : Real := (if U.Has_Position then U.Position else 0.0);
      Ref : Real;
      Integral : Real := Integral_State;
   begin
      if Dyn (1)>0.0 then
         if Period>0.0 then Position := Wrap_Setpoint (Position,Slew_State,Period); end if;
         Position := Real'Min (Slew_State+Dyn (1)*H,Real'Max (Slew_State-Dyn (1)*H,Position));
         R.Slew_Dot := (Position-Slew_State)/H;
      end if;
      R.Effective_Position := Position;
      -- Wrapped and slew-limited controls can leave Tier0 on extreme domains;
      -- formula below avoids narrowing those intermediates.
      R.Integral_Dot := Position-Length;
      if Period>0.0 then R.Integral_Dot := R.Integral_Dot-Period*Real'Rounding (R.Integral_Dot/Period); end if;
      if Gain (0)>0.0 then
         if Dyn (0)>0.0 then
            if Integral>=Dyn (0) then R.Integral_Dot := Real'Min (R.Integral_Dot,0.0);
            elsif Integral<=-Dyn (0) then R.Integral_Dot := Real'Max (R.Integral_Dot,0.0); end if;
         end if;
         R.Next_Integral := Integral+R.Integral_Dot*H;
         -- PID integrals use generic Euler; only DC clamps its integral on advance.
         if Actearly then Integral := R.Next_Integral; end if;
      else R.Integral_Dot := 0.0; R.Next_Integral := Integral; end if;
      Ref := Position;
      if Period>0.0 then Ref := Position-Period*Real'Rounding ((Position-Length)/Period); end if;
      R.Force := (-Bias (1)*Ref-Bias (2)*(if U.Has_Velocity then U.Velocity else 0.0))
         +(if U.Has_Feedforward then U.Feedforward else 0.0);
      if Gain (0)>0.0 then R.Force := R.Force+Gain (0)*Integral; end if;
      R.Force := R.Force+Affine (Bias,Length,Speed);
      return R;
   end PID;
   function DC (U : Servo_Input; Length, Speed : Input; Activation : State;
                H : Positive_Real; Dyn, Gain, Bias : Parameters; Actearly : Boolean := False;
                Force_Limited : Boolean := False; Lower, Upper : Input := 0.0) return DC_Result is
      S : constant DC_Slots := Slots (Dyn,Gain);
      R : DC_Result;
      Position : Real := (if U.Has_Position then U.Position else 0.0);
      Integral, Temperature, Current, Resistance, G, A, Z, Torque, Raw : Real := 0.0;
   begin
      for K in 0 .. 4 loop R.Next (K) := Activation (K); end loop;
      if S.Slew>=0 then
         Position := Real'Min (Activation (S.Slew)+Dyn (7)*H,Real'Max (Activation (S.Slew)-Dyn (7)*H,Position));
         R.Dot (S.Slew) := (Position-Activation (S.Slew))/H;
      end if;
      R.Effective_Position := Position;
      if S.Integral>=0 then
         Integral := Activation (S.Integral);
         R.Dot (S.Integral) := Position-Length;
         if Dyn (8)>0.0 then
            if Integral>=Dyn (8) then R.Dot (S.Integral) := Real'Min (R.Dot (S.Integral),0.0);
            elsif Integral<=-Dyn (8) then R.Dot (S.Integral) := Real'Max (R.Dot (S.Integral),0.0); end if;
         end if;
      end if;
      -- Voltage control uses the old integral for both dynamics and force.
      R.Voltage := (if U.Has_Voltage then U.Voltage else 0.0);
      if U.Has_Position or else U.Has_Velocity or else U.Has_Feedforward then
         Torque := ((Gain (4)*(Position-Length)+Gain (6)*((if U.Has_Velocity then U.Velocity else 0.0)-Speed))+Gain (5)*Integral)
           +(if U.Has_Feedforward then U.Feedforward else 0.0);
         Raw := (Gain (0)/Gain (1))*Torque+Gain (1)*Speed;
         if Gain (7)>0.0 then Raw := Real'Min (Gain (7),Real'Max (-Gain (7),Raw)); end if;
         R.Voltage := Raw+(if U.Has_Voltage then U.Voltage else 0.0);
      end if;
      Resistance := Gain (0);
      if S.Temperature>=0 then
         Temperature := Activation (S.Temperature);
         Resistance := Resistance*(1.0+Gain (2)*((Temperature+Dyn (4))-Gain (3)));
      end if;
      -- C uses raw thermal resistance for derivatives, clamped resistance for gain.
      if Resistance<=0.0 then raise Constraint_Error with "non-positive thermal resistance"; end if;
      Current := (if S.Current>=0 then Activation (S.Current) else (R.Voltage-Gain (1)*Speed)/Resistance);
      if S.Temperature>=0 then
         R.Dot (S.Temperature) := ((Resistance*Current)*Current-Temperature/Dyn (2))/Dyn (3);
      end if;
      if S.Bristle>=0 then
         G := Stribeck (Speed,Bias (3),Bias (4),Bias (5));
         A := (-Dyn (5)*abs Speed)/Real'Max (Min_Val,G);
         Z := Activation (S.Bristle);
         R.Dot (S.Bristle) := A*Z+Speed;
      end if;
      if S.Current>=0 then
         R.Dot (S.Current) := ((R.Voltage/Resistance-(Gain (1)/Resistance)*Speed)-Current)/Dyn (0);
         if Dyn (1)>0.0 then R.Dot (S.Current) := Clamp (R.Dot (S.Current),-Dyn (1),Dyn (1)); end if;
      end if;
      for K in 0 .. Integer (S.N)-1 loop
         if K=S.Current then R.Next (K) := Filter_Next (Activation (K),R.Dot (K),H,Real'Max (Min_Val,Dyn (0)));
         elsif K=S.Bristle then R.Next (K) := Bristle_Next (Activation (K),Speed,H,Dyn,Bias);
         else
            R.Next (K) := Activation (K)+R.Dot (K)*H;
            if K=S.Integral and then Dyn (8)>0.0 then R.Next (K) := Real'Min (Dyn (8),Real'Max (-Dyn (8),R.Next (K))); end if;
         end if;
      end loop;
      R.Resistance := Real'Max (Min_Val,Resistance);
      if S.Current>=0 then
         R.Force := Gain (1)*(if Actearly then R.Next (S.Current) else Current);
      else
         -- C uses the old integral in voltage control; actearly affects current only.
         R.Force := (Gain (1)/R.Resistance)*R.Voltage;
         R.Force := R.Force-((Gain (1)/R.Resistance)*Gain (1))*Speed;
      end if;
      if Force_Limited then R.Force := Real'Min (Upper,Real'Max (Lower,R.Force)); end if;
      if Bias (0)/=0.0 then R.Force := R.Force+Bias (0)*Math.Sin (Bias (1)*Length+Bias (2)); end if;
      if S.Bristle>=0 then R.Force := R.Force-(Dyn (5)*Activation (S.Bristle)+Dyn (6)*R.Dot (S.Bristle)); end if;
      return R;
   end DC;
   function Muscle_Force (Length, Speed, Range_Lower, Range_Upper, Acceleration,
                          Activation : Input; Gain, Bias : Parameters) return Real is
   begin return Muscle_Gain (Length,Speed,Range_Lower,Range_Upper,Acceleration,Gain)*Activation
       +Muscle_Bias (Length,Range_Lower,Range_Upper,Acceleration,Bias); end Muscle_Force;
   function SO3_Core (Target : Quaternion; Length, Speed : Vector; Gain, Bias : Parameters;
                      Force_Limited : Boolean; Limit : Nonneg_Tier0) return Vector
     with Pre => Bounded (Target,1.0e26) and then Bounded (Length,1.0e10) and then Bounded (Speed,1.0e10)
   is
      Error : constant Vector := MJ.Actuator_Geometry.Difference
        (Target,MJ.Actuator_Geometry.Expmap (Length));
      Force : Vector;
   begin
      Force := MJ.Actuator_Geometry.SO3_Force (Error,Speed,Gain (0),Bias (0),Bias (2));
      if Force_Limited then return MJ.Actuator_Geometry.Limit_Norm (Force,Limit); end if;
      return Force;
   end SO3_Core;
   function SO3 (Target : Quaternion; Length, Speed : Vector; Gain, Bias : Parameters;
                 Force_Limited : Boolean := False; Limit : Nonneg_Tier0 := 0.0) return Vector is
   begin
      return SO3_Core (MJ.Actuator_Geometry.Normalize (Target),Length,Speed,Gain,Bias,Force_Limited,Limit);
   end SO3;
   function SO3_Expmap (Target, Length, Speed : Vector; Gain, Bias : Parameters;
                       Force_Limited : Boolean := False; Limit : Nonneg_Tier0 := 0.0) return Vector is
   begin
      return SO3_Core (MJ.Actuator_Geometry.Expmap (Target),Length,Speed,Gain,Bias,Force_Limited,Limit);
   end SO3_Expmap;
end MJ.Advanced_Actuators;

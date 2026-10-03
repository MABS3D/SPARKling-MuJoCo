with Interfaces;
with MJ.Advanced_State;
with MJ.Advanced_Actuators;
with MJ.Actuator_Curves;
with MJ.Actuator_Geometry;
package body MJ.Data.Advanced_Control.Computation with SPARK_Mode is
   package AA renames MJ.Advanced_Actuators;
   package AC renames MJ.Actuator_Curves;
   package AG renames MJ.Actuator_Geometry;
   package T renames MJ.Transmissions;
   use type Interfaces.Unsigned_32;
   function Input (D : Simulation; E : Controller; Index : Natural) return Tier0_Real is
   begin
      return MJ.Advanced_State.Clip (E.Control (Index), E.Control_Lo (Index), E.Control_Hi (Index),
        D.Clamp_Control and then E.Control_Limited (Index));
   end Input;
   function Servo (D : Simulation; E : Controller; C : Configuration) return AA.Servo_Input is
      R : AA.Servo_Input;
      U : Natural := C.Uadr;
   begin
      if C.Spec mod 2 = 1 then R.Has_Position := True; R.Position := Input (D, E, U); U := U+1; end if;
      if (C.Spec/2) mod 2 = 1 then R.Has_Velocity := True; R.Velocity := Input (D, E, U); U := U+1; end if;
      if (C.Spec/4) mod 2 = 1 then R.Has_Feedforward := True; R.Feedforward := Input (D, E, U); U := U+1; end if;
      if (C.Spec/8) mod 2 = 1 then R.Has_Voltage := True; R.Voltage := Input (D, E, U); end if;
      return R;
   end Servo;
   procedure Transmission (D : Simulation; Rows : in out TX.Result; C : Configuration) is
      Q : AM.Quaternion := AM.Identity;
      Nv : constant Natural := D.Nv;
      JR, RR, Empty : TX.Jacobian (0 .. 2, 0 .. Nv-1) := [others => [others => 0.0]];
      Site_Q, Ref_Q, World_Q, World_Ref : Quaternion;
      R, Ref_R : Matrix;
   begin
      if C.Site_SO3 then
         World_Q := D.Kinematic.Bodies (C.Site_Body).Orientation;
         World_Ref := D.Kinematic.Bodies (C.Reference_Body).Orientation;
         --  Match C's local*body quaternion order for expmap lengths, and
         --  body*local site_xmat for the output moment frame.
         Site_Q := Multiply (Quaternion (C.Site_Quat), World_Q);
         Ref_Q := Multiply (Quaternion (C.Reference_Quat), World_Ref);
         R := Rotation (Multiply (World_Q, Quaternion (C.Site_Quat)));
         Ref_R := Rotation (Multiply (World_Ref, Quaternion (C.Reference_Quat)));
         for V in 0 .. D.Nv-1 loop
            for K in Axis loop
               JR (K,V) := D.Kinematic.Angular_Jacobian (3*(C.Site_Body*D.Nv+V)+K);
               RR (K,V) := D.Kinematic.Angular_Jacobian (3*(C.Reference_Body*D.Nv+V)+K);
            end loop;
         end loop;
         declare
            RM, RRM : AM.Matrix;
         begin
         for I in Axis loop
            for J in Axis loop RM (I,J) := R (I,J); RRM (I,J) := Ref_R (I,J); end loop;
         end loop;
         TX.Site (Rows, AM.Zero, AM.Zero, RM, RRM,
           AM.Quaternion (Site_Q), AM.Quaternion (Ref_Q), Empty, JR, Empty, RR,
           C.Common (0 .. D.Nv-1), C.Gear, Has_Reference => True, SO3 => True);
         end;
      else
         if C.Joint_Kind in 0 .. 1 then
            Q := AM.Quaternion (Read_Quaternion (D.State.Qpos.all, C.Qadr+(if C.Joint_Kind = 0 then 3 else 0)));
         end if;
         TX.Joint (Rows, MJ.Types.Joint_Kind'Val (C.Joint_Kind), D.Nv, C.Vadr,
           D.State.Qpos (C.Qadr), Q, C.Gear, C.Trn = 1, C.Trn = 6);
      end if;
   end Transmission;
   procedure Stage (Next_Act : in out Real_Array; Can_Advance : in out Boolean;
                    C : Configuration; Offset : Natural; Value : Real) is
      X : Real := Value;
   begin
      if C.Act_Limited and then C.Dyn_Kind /= 5 then X := Real'Min (C.Act_Hi, Real'Max (C.Act_Lo, X)); end if;
      if X not in Tier0_Real then Can_Advance := False;
      else Next_Act (C.Aadr+Offset) := X; end if;
   end Stage;
   procedure Compute (D : Simulation; E : in out Controller; Result : out Status) is
      F, Drive, G, B, Raw, X : Real;
      U : AA.Servo_Input;
      V : AM.Vector;
      Target : AM.Vector := AM.Zero;
      Q : AM.Quaternion;
      S : AA.State;
      Enabled, Previous_Advance : Boolean;
   begin
      Result := Numeric_Limit; E.Can_Advance := True;
      E.Next_Act (0 .. Integer (E.Na)-1) := E.Act (0 .. Integer (E.Na)-1);
      E.Dot (0 .. Integer (E.Na)-1) := [others => 0.0];
      E.Qforce (0 .. Integer (D.Nv)-1) := [others => 0.0];
      for I in 0 .. Integer (E.Nactuator)-1 loop
         declare
            C : constant Configuration := E.Config (I);
         begin
            Previous_Advance := E.Can_Advance;
            Transmission (D, E.Rows, C);
            if not E.Rows.Accepted then return; end if;
            Enabled := D.Actuation_Enabled and then
              (Interfaces.Unsigned_32 (E.Disabled_Groups) and Interfaces.Shift_Left (1, C.Group)) = 0;
            for K in 0 .. C.No-1 loop
               E.L (C.Oadr+K) := E.Rows.Length (K);
               E.V (C.Oadr+K) := (if D.Actuation_Enabled then T.Velocity
                 (E.Rows.Col (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1),
                  E.Rows.Val (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1), D.State.Qvel.all) else 0.0);
               if E.L (C.Oadr+K) not in Tier0_Real or else E.V (C.Oadr+K) not in Tier0_Real then return; end if;
               E.F (C.Oadr+K) := 0.0;
            end loop;
            if D.Actuation_Enabled then
               if C.Gain_Kind = 5 then
                  U := Servo (D, E, C);
                  declare
                     P : constant AA.PID_Result := AA.PID (U, E.L (C.Oadr), E.V (C.Oadr),
                       (if C.Dyn (1)>0.0 then E.Act (C.Aadr) else 0.0),
                       (if C.Gain (0)>0.0 then E.Act (C.Aadr+C.Na-1) else 0.0),
                       D.Timestep, C.Period, C.Dyn, C.Gain, C.Bias, False);
                  begin
                     if C.Dyn (1)>0.0 then
                        E.Dot (C.Aadr) := P.Slew_Dot; Stage (E.Next_Act, E.Can_Advance, C, 0, P.Effective_Position);
                     end if;
                     if C.Gain (0)>0.0 then
                        E.Dot (C.Aadr+C.Na-1) := P.Integral_Dot; Stage (E.Next_Act, E.Can_Advance, C, C.Na-1, P.Next_Integral);
                     end if;
                     X := P.Effective_Position;
                     if C.Period > 0.0 then X := X-C.Period*Real'Rounding ((X-E.L (C.Oadr))/C.Period); end if;
                     F := ((-C.Bias (1)*X-C.Bias (2)*(if U.Has_Velocity then U.Velocity else 0.0))
                       +(if U.Has_Feedforward then U.Feedforward else 0.0));
                     if C.Gain (0)>0.0 then F := F+C.Gain (0)*(if C.Early then E.Next_Act (C.Aadr+C.Na-1) else E.Act (C.Aadr+C.Na-1)); end if;
                     F := F+AC.Affine (C.Bias, E.L (C.Oadr), E.V (C.Oadr));
                  end;
               elsif C.Gain_Kind = 3 then
                  U := Servo (D, E, C); S := [others => 0.0];
                  for K in 0 .. Integer (C.Na)-1 loop S (K) := E.Act (C.Aadr+K); end loop;
                  if AA.Raw_Resistance (S,C.Dyn,C.Gain)<Min_Val then return; end if;
                  declare
                     P : constant AA.DC_Result := AA.DC (U, E.L (C.Oadr), E.V (C.Oadr), S,
                       D.Timestep, C.Dyn, C.Gain, C.Bias, C.Early, C.Force_Limited, C.Force_Lo, C.Force_Hi);
                  begin
                     F := P.Force;
                     for K in 0 .. Integer (C.Na)-1 loop
                        E.Dot (C.Aadr+K) := P.Dot (K); Stage (E.Next_Act, E.Can_Advance, C, K, P.Next (K));
                     end loop;
                  end;
               elsif C.Gain_Kind = 4 then
                  for K in 0 .. 2 loop V (K) := E.V (C.Oadr+K); end loop;
                  if C.Na > 0 then
                     for K in 0 .. 2 loop
                        E.Dot (C.Aadr+K) := Input (D, E, C.Uadr+K);
                        Stage (E.Next_Act, E.Can_Advance, C, K, MJ.Advanced_State.Next_Value (E.Act (C.Aadr+K), E.Dot (C.Aadr+K), D.Timestep));
                        Target (K) := (if C.Early then E.Next_Act (C.Aadr+K) else E.Act (C.Aadr+K));
                     end loop;
                  elsif C.Spec = 1 then
                     for K in 0 .. 2 loop Target (K) := Input (D, E, C.Uadr+K); end loop;
                  end if;
                  if C.Spec = 2 then
                     for K in 0 .. 3 loop Q (K) := Input (D, E, C.Uadr+K); end loop;
                     V := AA.SO3 (Q, AM.Vector (E.L (C.Oadr .. C.Oadr+2)), V, C.Gain, C.Bias, C.Force_Limited, Real'Max (0.0,C.Force_Hi));
                  else
                     V := AA.SO3_Expmap (Target, AM.Vector (E.L (C.Oadr .. C.Oadr+2)), V, C.Gain, C.Bias, C.Force_Limited, Real'Max (0.0,C.Force_Hi));
                  end if;
                  for K in 0 .. 2 loop E.F (C.Oadr+K) := V (K); end loop;
                  F := 0.0;
               else
                  Drive := Input (D, E, C.Uadr);
                  if C.Na > 0 then
                     case C.Dyn_Kind is
                        when 1 => Raw := Drive;
                        when 2 | 3 => Raw := AC.Filter_Derivative (Drive, E.Act (C.Aadr), C.Dyn (0));
                        when 4 => Raw := AC.Muscle_Derivative (Drive, E.Act (C.Aadr), C.Dyn);
                        when others => return;
                     end case;
                     E.Dot (C.Aadr) := Raw;
                     X := (if C.Dyn_Kind = 3 then AA.Filter_Next (E.Act (C.Aadr), Raw, D.Timestep, Real'Max (Min_Val,C.Dyn (0)))
                       else MJ.Advanced_State.Next_Value (E.Act (C.Aadr), Raw, D.Timestep));
                     Stage (E.Next_Act, E.Can_Advance, C,0,X);
                     Drive := (if C.Early then E.Next_Act (C.Aadr) else E.Act (C.Aadr));
                  elsif C.Period > 0.0 then Drive := Drive-C.Period*Real'Rounding ((Drive-E.L (C.Oadr))/C.Period); end if;
                  G := (if C.Gain_Kind = 0 then C.Gain (0) elsif C.Gain_Kind = 1 then AC.Affine (C.Gain,E.L (C.Oadr),E.V (C.Oadr))
                    else AC.Muscle_Gain (E.L (C.Oadr),E.V (C.Oadr),C.Length_Lo,C.Length_Hi,C.Acc0,C.Gain));
                  B := (if C.Bias_Kind = 0 then 0.0 elsif C.Bias_Kind = 1 then AC.Affine (C.Bias,E.L (C.Oadr),E.V (C.Oadr))
                    else AC.Muscle_Bias (E.L (C.Oadr),C.Length_Lo,C.Length_Hi,C.Acc0,C.Bias));
                  F := G*Drive+B;
               end if;
               if C.Gain_Kind /= 4 then
                  if C.Force_Limited and then C.Gain_Kind /= 3 then F := Real'Min (C.Force_Hi,Real'Max (C.Force_Lo,F)); end if;
                  E.F (C.Oadr) := F;
               end if;
               if Enabled and then C.Early and then not E.Can_Advance then return; end if;
            end if;
            if not Enabled and then D.Actuation_Enabled then
               E.F (C.Oadr .. C.Oadr+C.No-1) := [others => 0.0];
               E.Can_Advance := Previous_Advance;
               for K in 0 .. Integer (C.Na)-1 loop
                  X := E.Act (C.Aadr+K);
                  if C.Dyn_Kind = 5 then
                     declare Slots : constant AA.DC_Slots := AA.Slots (C.Dyn,C.Gain); begin
                        if K = Slots.Bristle then
                           X := AA.Bristle_Next (E.Act (C.Aadr+K),E.V (C.Oadr),D.Timestep,C.Dyn,C.Bias);
                        elsif K = Slots.Integral and then C.Dyn (8)>0.0 then
                           X := Real'Min (C.Dyn (8),Real'Max (-C.Dyn (8),X));
                        end if;
                     end;
                  end if;
                  Stage (E.Next_Act, E.Can_Advance, C,K,X);
               end loop;
            end if;
            for K in 0 .. C.No-1 loop
               if E.F (C.Oadr+K) not in Tier0_Real then return; end if;
               T.Project (E.Rows.Col (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1),
                 E.Rows.Val (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1),
                 E.F (C.Oadr+K), E.Qforce (0 .. D.Nv-1));
            end loop;
         end;
      end loop;
      Result := Success;
   end Compute;
end MJ.Data.Advanced_Control.Computation;

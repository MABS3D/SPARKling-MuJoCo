with Interfaces;
with Ada.Numerics;
with MJ.Models.Validity;
with MJ.Advanced_State;
with MJ.Advanced_Actuators;
with MJ.Actuator_Curves;
with MJ.Actuator_Geometry;
with MJ.Data.Pipeline;
with MJ.Data.Inertia_Phase;
with MJ.Data.Forces_Phase;
with MJ.Data.Euler.Advanced;
package body MJ.Data.Advanced with SPARK_Mode is
   package AA renames MJ.Advanced_Actuators;
   package AC renames MJ.Actuator_Curves;
   package AG renames MJ.Actuator_Geometry;
   package T renames MJ.Transmissions;
   Ada_Pi : constant Real := Ada.Numerics.Pi;
   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_8;
   function Ready (E : Engine) return Boolean is (E.Initialized and then Is_Ready (E.D));
   function State (E : Engine) return Real_Array is (State_Values (E.D) & Activation (E));
   function Inputs (E : Engine) return Real_Array is (E.Control (0 .. Integer (E.Nu)-1) & Input_Values (E.D));
   function Activation (E : Engine) return Real_Array is (E.Act (0 .. Integer (E.Na)-1));
   function Rates (E : Engine) return Real_Array is (E.Dot (0 .. Integer (E.Na)-1));
   function Control_Count (E : Engine) return Natural is (E.Nu);
   function Output_Count (E : Engine) return Natural is (E.No);
   function Position_Count (E : Engine) return Natural is (E.D.Nq);
   function Velocity_Count (E : Engine) return Natural is (E.D.Nv);
   function Lengths (E : Engine) return Real_Array is (E.L (0 .. Integer (E.No)-1));
   function Velocities (E : Engine) return Real_Array is (E.V (0 .. Integer (E.No)-1));
   function Forces (E : Engine) return Real_Array is (E.F (0 .. Integer (E.No)-1));
   function Generalized (E : Engine) return Real_Array is (E.Qforce (0 .. Integer (E.D.Nv)-1));
   function Accelerations (E : Engine) return Real_Array is (E.Acc (0 .. Integer (E.D.Nv)-1));

   procedure Free (E : in out Engine) is
   begin
      MJ.Data.Free (E.D); E.Initialized := False; E.Valid := False;
      E.Nu := 0; E.No := 0; E.Na := 0; E.Nactuator := 0; E.Has_Sites := False;
   end Free;
   procedure Reset (E : in out Engine; Result : out Status) is
   begin
      MJ.Data.Reset (E.D, Result);
      if Result /= Success then return; end if;
      E.Control := [others => 0.0]; E.Act := [others => 0.0];
      E.Dot := [others => 0.0]; E.Next_Act := [others => 0.0];
      E.Valid := False; E.Can_Advance := True;
   end Reset;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        Clock : Nonneg_Tier0; Result : out Status) is
   begin
      MJ.Data.Set_State (E.D, Qpos, Qvel, Clock, Result);
      if Result = Success then E.Valid := False; end if;
   end Set_State;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real;
                          Result : out Status) is
   begin
      if not Ready (E) then Result := Not_Allocated;
      elsif Index >= E.Nu then Result := Invalid_Index;
      else E.Control (Index) := Value; E.Valid := False; Result := Success; end if;
   end Set_Control;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      if Values'Length /= E.Na then Result := Invalid_Size; return; end if;
      for I in 0 .. Integer (E.Na)-1 loop E.Act (I) := Values (Values'First+I); end loop;
      E.Valid := False; Result := Success;
   end Set_Activation;
   procedure Set_Applied (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      MJ.Data.Set_Applied_Force (E.D, Index, Value, Result);
      if Result = Success then E.Valid := False; end if;
   end Set_Applied;

   procedure Create (M : MJ.Models.Model; E : in out Engine; Result : out Status) is
      U, O, A : Natural := 0;
      Id, Ref : Integer;
      Parents : TX.Parent_Array (0 .. Max_Dofs-1) := [others => -1];
      First, Second : Integer;
   begin
      if not Is_Empty (E.D) then Result := Already_Allocated; return; end if;
      Result := Invalid_Model;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      if M.S.Nactuator > Max_Actuators or else M.S.Nu > Max_Controls
        or else M.S.Nout > Max_Outputs or else M.S.Na > Max_Actuators
        or else M.S.Nv > Max_Dofs then Result := Capacity_Exceeded; return; end if;
      E.Nu := M.S.Nu; E.No := M.S.Nout; E.Na := M.S.Na; E.Nactuator := M.S.Nactuator;
      E.Disabled_Groups := M.Opt.Disableactuator; E.Has_Sites := False;
      for V in 0 .. M.S.Nv-1 loop Parents (V) := M.Dofs.Dof_Parentid (V); end loop;
      for I in 0 .. Integer (E.Nu)-1 loop
         E.Control_Limited (I) := M.Actuators.Actuator_Ctrllimited (I) /= 0;
         E.Control_Lo (I) := M.Actuators.Actuator_Ctrlrange (2*I);
         E.Control_Hi (I) := M.Actuators.Actuator_Ctrlrange (2*I+1);
         if E.Control_Lo (I) > E.Control_Hi (I) then return; end if;
      end loop;
      Result := Unsupported_Actuator;
      for I in 0 .. Integer (E.Nactuator)-1 loop
         declare
            C : Configuration;
            Expected : Natural;
         begin
            C.Dyn_Kind := M.Actuators.Actuator_Dyntype (I);
            C.Gain_Kind := M.Actuators.Actuator_Gaintype (I);
            C.Bias_Kind := M.Actuators.Actuator_Biastype (I);
            C.Trn := M.Actuators.Actuator_Trntype (I);
            C.Nu := M.Actuators.Actuator_Ctrlnum (I); C.No := M.Actuators.Actuator_Outnum (I);
            C.Na := M.Actuators.Actuator_Actnum (I); C.Spec := M.Actuators.Actuator_Ctrlspec (I);
            if C.Gain_Kind = 3 and then C.Spec = 16 then C.Spec := 0; end if;
            C.Uadr := U; C.Oadr := O; C.Aadr := A; C.Group := M.Actuators.Actuator_Group (I);
            if C.Group > 30 or else C.Nu > 4 or else C.Na > 5
              or else M.Actuators.Actuator_Outadr (I) /= O
              or else (C.Nu > 0 and then M.Actuators.Actuator_Ctrladr (I) /= U)
              or else (C.Na > 0 and then M.Actuators.Actuator_Actadr (I) /= A)
              or else M.Actuators.Actuator_Delay (I) /= 0.0
              or else M.Actuators.Actuator_Damping (I) /= 0.0
              or else M.Actuators.Actuator_Dampingpoly (2*I) /= 0.0
              or else M.Actuators.Actuator_Dampingpoly (2*I+1) /= 0.0
              or else M.Actuators.Actuator_Armature (I) /= 0.0 then return; end if;
            for K in 0 .. 9 loop
               C.Gain (K) := M.Actuators.Actuator_Gainprm (10*I+K);
               C.Dyn (K) := M.Actuators.Actuator_Dynprm (10*I+K);
               C.Bias (K) := M.Actuators.Actuator_Biasprm (10*I+K);
            end loop;
            for K in 0 .. 5 loop C.Gear (K) := M.Actuators.Actuator_Gear (6*O+K); end loop;
            C.Early := M.Actuators.Actuator_Actearly (I) /= 0;
            C.Force_Limited := M.Actuators.Actuator_Forcelimited (I) /= 0;
            C.Act_Limited := M.Actuators.Actuator_Actlimited (I) /= 0;
            C.Force_Lo := M.Actuators.Actuator_Forcerange (2*I); C.Force_Hi := M.Actuators.Actuator_Forcerange (2*I+1);
            C.Act_Lo := M.Actuators.Actuator_Actrange (2*I); C.Act_Hi := M.Actuators.Actuator_Actrange (2*I+1);
            if C.Force_Lo > C.Force_Hi or else C.Act_Lo > C.Act_Hi then return; end if;
            C.Length_Lo := M.Actuators.Actuator_Lengthrange (2*O);
            C.Length_Hi := M.Actuators.Actuator_Lengthrange (2*O+1);
            C.Acc0 := M.Actuators.Actuator_Acc0 (O);
            Id := M.Actuators.Actuator_Trnid (2*I); Ref := M.Actuators.Actuator_Trnid (2*I+1);
            if C.Trn in 0 .. 1 or else (C.Trn = 6 and then Ref = -1) then
               if Id not in 0 .. M.S.Njnt-1 then return; end if;
               C.Qadr := M.Joints.Jnt_Qposadr (Id); C.Vadr := M.Joints.Jnt_Dofadr (Id);
               C.Joint_Kind := M.Joints.Jnt_Type (Id);
               if C.Trn = 6 and then C.Joint_Kind /= 1 then return; end if;
               if C.Joint_Kind = 1 and then (C.Gain_Kind = 5 or else
                 (C.Gain_Kind = 0 and then C.Bias_Kind = 1 and then C.Bias (1) < 0.0)) then
                  C.Period := (2.0*Ada_Pi)*AM.Math.Sqrt ((C.Gear (0)*C.Gear (0)+C.Gear (1)*C.Gear (1))+C.Gear (2)*C.Gear (2));
               end if;
            elsif C.Trn = 6 and then Ref >= 0 then
               if not MJ.Models.Site_Layout_OK (M.S, M.Sites)
                 or else Id not in 0 .. M.S.Nsite-1 or else Ref not in 0 .. M.S.Nsite-1 then return; end if;
               C.Site_SO3 := True; E.Has_Sites := True;
               C.Site_Body := M.Sites.Site_Bodyid (Id); C.Reference_Body := M.Sites.Site_Bodyid (Ref);
               C.Site_Quat := AM.Quaternion (Read_Quaternion (M.Sites.Site_Quat.all, 4*Id));
               C.Reference_Quat := AM.Quaternion (Read_Quaternion (M.Sites.Site_Quat.all, 4*Ref));
               declare
                  B1 : constant Natural := M.Bodies.Body_Weldid (C.Site_Body);
                  B2 : constant Natural := M.Bodies.Body_Weldid (C.Reference_Body);
               begin
                  First := M.Bodies.Body_Dofadr (B1)+M.Bodies.Body_Dofnum (B1)-1;
                  Second := M.Bodies.Body_Dofadr (B2)+M.Bodies.Body_Dofnum (B2)-1;
               end;
               C.Common (0 .. M.S.Nv-1) := TX.Common_Ancestors (Parents (0 .. M.S.Nv-1), First, Second);
            else return; end if;
            if C.Gain_Kind = 5 and then C.Dyn_Kind in 0 | 6 and then C.Bias_Kind = 1 and then C.No = 1 then
               Expected := MJ.Advanced_State.PID_Count (C.Dyn (1), C.Gain (0));
               if C.Spec > 7 or else (C.Dyn (1)>0.0 and then C.Spec mod 2 = 0) then return; end if;
            elsif C.Gain_Kind = 3 and then C.Dyn_Kind = 5 and then C.Bias_Kind = 3 and then C.No = 1 then
               Expected := AA.Slots (C.Dyn, C.Gain).N;
               if C.Gain (0) < Min_Val or else C.Spec > 15
                 or else (C.Spec mod 8 /= 0 and then C.Gain (1)<Min_Val)
                 or else (C.Dyn (0)>0.0 and then C.Dyn (0)<Min_Val)
                 or else (C.Dyn (2)>0.0 and then (C.Dyn (2)<Min_Val or else C.Dyn (3)<Min_Val))
                 or else (C.Dyn (7)>0.0 and then C.Spec mod 2 = 0) then return; end if;
            elsif C.Gain_Kind = 4 and then C.Trn = 6 and then C.Dyn_Kind in 0 .. 1
              and then C.Bias_Kind = 4 and then C.No = 3 then
               Expected := (if C.Dyn_Kind = 0 then 0 else 3);
               if (C.Spec = 2 and then (C.Nu /= 4 or else C.Na /= 0))
                 or else (C.Spec = 1 and then C.Nu /= 3) or else C.Spec not in 1 .. 2 then return; end if;
            elsif C.Gain_Kind in 0 .. 2 and then C.Dyn_Kind in 0 .. 4 and then C.Bias_Kind in 0 .. 2
              and then C.Trn in 0 .. 1 and then C.No = 1 and then C.Nu = 1 then
               Expected := (if C.Dyn_Kind = 0 then 0 else 1);
            else return; end if;
            if C.Na /= Expected then return; end if;
            if C.Gain_Kind in 3 | 5 then
               Expected := 0;
               for K in 0 .. 3 loop Expected := Expected + (C.Spec / (2**K)) mod 2; end loop;
               if C.Nu /= Expected then return; end if;
            end if;
            if C.Period /= 0.0 and then C.Period < Min_Val then return; end if;
            E.Config (I) := C; U := U+C.Nu; O := O+C.No; A := A+C.Na;
         end;
      end loop;
      if U /= E.Nu or else O /= E.No or else A /= E.Na then Result := Invalid_Model; return; end if;
      Create_Dynamics (M, E.D, Result);
      if Result /= Success then return; end if;
      E.Initialized := True; Reset (E, Result);
   exception
      when Constraint_Error => Free (E); Result := Invalid_Model;
   end Create;

   function Input (E : Engine; Index : Natural) return Tier0_Real is
   begin
      return MJ.Advanced_State.Clip (E.Control (Index), E.Control_Lo (Index), E.Control_Hi (Index),
        E.D.Clamp_Control and then E.Control_Limited (Index));
   end Input;
   function Servo (E : Engine; C : Configuration) return AA.Servo_Input is
      R : AA.Servo_Input;
      U : Natural := C.Uadr;
   begin
      if C.Spec mod 2 = 1 then R.Has_Position := True; R.Position := Input (E, U); U := U+1; end if;
      if (C.Spec/2) mod 2 = 1 then R.Has_Velocity := True; R.Velocity := Input (E, U); U := U+1; end if;
      if (C.Spec/4) mod 2 = 1 then R.Has_Feedforward := True; R.Feedforward := Input (E, U); U := U+1; end if;
      if (C.Spec/8) mod 2 = 1 then R.Has_Voltage := True; R.Voltage := Input (E, U); end if;
      return R;
   end Servo;
   procedure Transmission (E : in out Engine; C : Configuration) is
      Q : AM.Quaternion := AM.Identity;
      Nv : constant Natural := E.D.Nv;
      JR, RR, Empty : TX.Jacobian (0 .. 2, 0 .. Nv-1) := [others => [others => 0.0]];
      Site_Q, Ref_Q, World_Q, World_Ref : Quaternion;
      R, Ref_R : Matrix;
   begin
      if C.Site_SO3 then
         World_Q := E.D.Kinematic.Bodies (C.Site_Body).Orientation;
         World_Ref := E.D.Kinematic.Bodies (C.Reference_Body).Orientation;
         --  Match C's local*body quaternion order for expmap lengths, and
         --  body*local site_xmat for the output moment frame.
         Site_Q := Multiply (Quaternion (C.Site_Quat), World_Q);
         Ref_Q := Multiply (Quaternion (C.Reference_Quat), World_Ref);
         R := Rotation (Multiply (World_Q, Quaternion (C.Site_Quat)));
         Ref_R := Rotation (Multiply (World_Ref, Quaternion (C.Reference_Quat)));
         for V in 0 .. E.D.Nv-1 loop
            for K in Axis loop
               JR (K,V) := E.D.Kinematic.Angular_Jacobian (3*(C.Site_Body*E.D.Nv+V)+K);
               RR (K,V) := E.D.Kinematic.Angular_Jacobian (3*(C.Reference_Body*E.D.Nv+V)+K);
            end loop;
         end loop;
         declare
            RM, RRM : AM.Matrix;
         begin
         for I in Axis loop
            for J in Axis loop RM (I,J) := R (I,J); RRM (I,J) := Ref_R (I,J); end loop;
         end loop;
         TX.Site (E.Rows, AM.Zero, AM.Zero, RM, RRM,
           AM.Quaternion (Site_Q), AM.Quaternion (Ref_Q), Empty, JR, Empty, RR,
           C.Common (0 .. E.D.Nv-1), C.Gear, Has_Reference => True, SO3 => True);
         end;
      else
         if C.Joint_Kind in 0 .. 1 then
            Q := AM.Quaternion (Read_Quaternion (E.D.State.Qpos.all, C.Qadr+(if C.Joint_Kind = 0 then 3 else 0)));
         end if;
         TX.Joint (E.Rows, MJ.Types.Joint_Kind'Val (C.Joint_Kind), E.D.Nv, C.Vadr,
           E.D.State.Qpos (C.Qadr), Q, C.Gear, C.Trn = 1, C.Trn = 6);
      end if;
   end Transmission;
   procedure Stage (E : in out Engine; C : Configuration; Offset : Natural; Value : Real) is
      X : Real := Value;
   begin
      if C.Act_Limited and then C.Dyn_Kind /= 5 then X := Real'Min (C.Act_Hi, Real'Max (C.Act_Lo, X)); end if;
      if X not in Tier0_Real then E.Can_Advance := False;
      else E.Next_Act (C.Aadr+Offset) := X; end if;
   end Stage;
   procedure Compute (E : in out Engine; Result : out Status) is
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
      E.Qforce (0 .. Integer (E.D.Nv)-1) := [others => 0.0];
      for I in 0 .. Integer (E.Nactuator)-1 loop
         declare
            C : constant Configuration := E.Config (I);
         begin
            Previous_Advance := E.Can_Advance;
            Transmission (E, C);
            if not E.Rows.Accepted then return; end if;
            Enabled := E.D.Actuation_Enabled and then
              (Interfaces.Unsigned_32 (E.Disabled_Groups) and Interfaces.Shift_Left (1, C.Group)) = 0;
            for K in 0 .. C.No-1 loop
               E.L (C.Oadr+K) := E.Rows.Length (K);
               E.V (C.Oadr+K) := (if E.D.Actuation_Enabled then T.Velocity
                 (E.Rows.Col (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1),
                  E.Rows.Val (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1), E.D.State.Qvel.all) else 0.0);
               if E.L (C.Oadr+K) not in Tier0_Real or else E.V (C.Oadr+K) not in Tier0_Real then return; end if;
               E.F (C.Oadr+K) := 0.0;
            end loop;
            if E.D.Actuation_Enabled then
               if C.Gain_Kind = 5 then
                  U := Servo (E, C);
                  declare
                     P : constant AA.PID_Result := AA.PID (U, E.L (C.Oadr), E.V (C.Oadr),
                       (if C.Dyn (1)>0.0 then E.Act (C.Aadr) else 0.0),
                       (if C.Gain (0)>0.0 then E.Act (C.Aadr+C.Na-1) else 0.0),
                       E.D.Timestep, C.Period, C.Dyn, C.Gain, C.Bias, False);
                  begin
                     if C.Dyn (1)>0.0 then
                        E.Dot (C.Aadr) := P.Slew_Dot; Stage (E, C, 0, P.Effective_Position);
                     end if;
                     if C.Gain (0)>0.0 then
                        E.Dot (C.Aadr+C.Na-1) := P.Integral_Dot; Stage (E, C, C.Na-1, P.Next_Integral);
                     end if;
                     X := P.Effective_Position;
                     if C.Period > 0.0 then X := X-C.Period*Real'Rounding ((X-E.L (C.Oadr))/C.Period); end if;
                     F := ((-C.Bias (1)*X-C.Bias (2)*(if U.Has_Velocity then U.Velocity else 0.0))
                       +(if U.Has_Feedforward then U.Feedforward else 0.0));
                     if C.Gain (0)>0.0 then F := F+C.Gain (0)*(if C.Early then E.Next_Act (C.Aadr+C.Na-1) else E.Act (C.Aadr+C.Na-1)); end if;
                     F := F+AC.Affine (C.Bias, E.L (C.Oadr), E.V (C.Oadr));
                  end;
               elsif C.Gain_Kind = 3 then
                  U := Servo (E, C); S := [others => 0.0];
                  for K in 0 .. Integer (C.Na)-1 loop S (K) := E.Act (C.Aadr+K); end loop;
                  if AA.Raw_Resistance (S,C.Dyn,C.Gain)<Min_Val then return; end if;
                  declare
                     P : constant AA.DC_Result := AA.DC (U, E.L (C.Oadr), E.V (C.Oadr), S,
                       E.D.Timestep, C.Dyn, C.Gain, C.Bias, C.Early, C.Force_Limited, C.Force_Lo, C.Force_Hi);
                  begin
                     F := P.Force;
                     for K in 0 .. Integer (C.Na)-1 loop
                        E.Dot (C.Aadr+K) := P.Dot (K); Stage (E, C, K, P.Next (K));
                     end loop;
                  end;
               elsif C.Gain_Kind = 4 then
                  for K in 0 .. 2 loop V (K) := E.V (C.Oadr+K); end loop;
                  if C.Na > 0 then
                     for K in 0 .. 2 loop
                        E.Dot (C.Aadr+K) := Input (E, C.Uadr+K);
                        Stage (E, C, K, MJ.Advanced_State.Next_Value (E.Act (C.Aadr+K), E.Dot (C.Aadr+K), E.D.Timestep));
                        Target (K) := (if C.Early then E.Next_Act (C.Aadr+K) else E.Act (C.Aadr+K));
                     end loop;
                  elsif C.Spec = 1 then
                     for K in 0 .. 2 loop Target (K) := Input (E, C.Uadr+K); end loop;
                  end if;
                  if C.Spec = 2 then
                     for K in 0 .. 3 loop Q (K) := Input (E, C.Uadr+K); end loop;
                     V := AA.SO3 (Q, AM.Vector (E.L (C.Oadr .. C.Oadr+2)), V, C.Gain, C.Bias, C.Force_Limited, Real'Max (0.0,C.Force_Hi));
                  else
                     V := AA.SO3_Expmap (Target, AM.Vector (E.L (C.Oadr .. C.Oadr+2)), V, C.Gain, C.Bias, C.Force_Limited, Real'Max (0.0,C.Force_Hi));
                  end if;
                  for K in 0 .. 2 loop E.F (C.Oadr+K) := V (K); end loop;
                  F := 0.0;
               else
                  Drive := Input (E, C.Uadr);
                  if C.Na > 0 then
                     case C.Dyn_Kind is
                        when 1 => Raw := Drive;
                        when 2 | 3 => Raw := AC.Filter_Derivative (Drive, E.Act (C.Aadr), C.Dyn (0));
                        when 4 => Raw := AC.Muscle_Derivative (Drive, E.Act (C.Aadr), C.Dyn);
                        when others => return;
                     end case;
                     E.Dot (C.Aadr) := Raw;
                     X := (if C.Dyn_Kind = 3 then AA.Filter_Next (E.Act (C.Aadr), Raw, E.D.Timestep, Real'Max (Min_Val,C.Dyn (0)))
                       else MJ.Advanced_State.Next_Value (E.Act (C.Aadr), Raw, E.D.Timestep));
                     Stage (E,C,0,X);
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
            if not Enabled and then E.D.Actuation_Enabled then
               E.F (C.Oadr .. C.Oadr+C.No-1) := [others => 0.0];
               E.Can_Advance := Previous_Advance;
               for K in 0 .. Integer (C.Na)-1 loop
                  X := E.Act (C.Aadr+K);
                  if C.Dyn_Kind = 5 then
                     declare Slots : constant AA.DC_Slots := AA.Slots (C.Dyn,C.Gain); begin
                        if K = Slots.Bristle then
                           X := AA.Bristle_Next (E.Act (C.Aadr+K),E.V (C.Oadr),E.D.Timestep,C.Dyn,C.Bias);
                        elsif K = Slots.Integral and then C.Dyn (8)>0.0 then
                           X := Real'Min (C.Dyn (8),Real'Max (-C.Dyn (8),X));
                        end if;
                     end;
                  end if;
                  Stage (E,C,K,X);
               end loop;
            end if;
            for K in 0 .. C.No-1 loop
               if E.F (C.Oadr+K) not in Tier0_Real then return; end if;
               T.Project (E.Rows.Col (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1),
                 E.Rows.Val (E.Rows.Row_Adr (K) .. E.Rows.Row_Adr (K)+Integer (E.Rows.Row_N (K))-1),
                 E.F (C.Oadr+K), E.Qforce (0 .. E.D.Nv-1));
            end loop;
         end;
      end loop;
      if (for some X of E.Qforce (0 .. E.D.Nv-1) => X not in -1.0e50 .. 1.0e50) then return; end if;
      E.D.Dynamics.Actuator.all := E.Qforce (0 .. E.D.Nv-1);
      E.D.Cache.Actuation_Valid := True;
      Result := Success;
   end Compute;
   procedure Evaluate (E : in out Engine; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      E.Valid := False;
      if not Ready (E) then Result := Not_Allocated; return; end if;
      if External'Length /= 0 and then (External'First /= 0 or else External'Length /= E.D.Nb) then Result := Invalid_Size; return; end if;
      E.D.Cache.Actuation_Valid := False; E.D.Cache.Force_Valid := False;
      if not Positions_Current (E.D) then Pipeline.Update_Poses (E.D, Result); if Result /= Success then return; end if; end if;
      if E.Has_Sites then Pipeline.Ensure_Jacobians (E.D, Result); if Result /= Success then return; end if; end if;
      Inertia_Phase.Assemble (E.D, Result); if Result /= Success then return; end if;
      Forces_Phase.Compute (E.D, Result); if Result /= Success then return; end if;
      Compute (E, Result); if Result /= Success then return; end if;
      Inertia_Phase.Solve_Acceleration (E.D, Result, External);
      if Result = Success then E.Acc (0 .. E.D.Nv-1) := E.D.Dynamics.Acceleration.all; E.Valid := True; end if;
   exception
      when Constraint_Error => E.D.Cache.Force_Valid := False; E.D.Cache.Actuation_Valid := False; Result := Numeric_Limit;
   end Evaluate;
   procedure Step (E : in out Engine; Result : out Status;
                  External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      N, Scale : Real;
   begin
      Evaluate (E, Result, External); if Result /= Success then return; end if;
      if not E.Can_Advance then Result := Numeric_Limit; return; end if;
      --  Re-anchor from the evaluated lengths, before publication, as C does.
      if E.D.Actuation_Enabled then
         for I in 0 .. Integer (E.Nactuator)-1 loop
            declare C : constant Configuration := E.Config (I); begin
               if C.Dyn_Kind = 1 and then C.Na > 0 then
                  if C.Period > 0.0 then
                     E.Next_Act (C.Aadr+C.Na-1) := E.Next_Act (C.Aadr+C.Na-1)-C.Period*
                       Real'Rounding ((E.Next_Act (C.Aadr+C.Na-1)-E.L (C.Oadr))/C.Period);
                  elsif C.Gain_Kind = 4 then
                     N := AM.Math.Sqrt ((E.Next_Act (C.Aadr)*E.Next_Act (C.Aadr)+E.Next_Act (C.Aadr+1)*E.Next_Act (C.Aadr+1))
                       +E.Next_Act (C.Aadr+2)*E.Next_Act (C.Aadr+2));
                     if N > Ada_Pi then
                        Scale := (N-(2.0*Ada_Pi)*Real'Rounding (N/(2.0*Ada_Pi)))/N;
                        for K in 0 .. 2 loop E.Next_Act (C.Aadr+K) := E.Next_Act (C.Aadr+K)*Scale; end loop;
                     end if;
                  end if;
               end if;
            end;
         end loop;
      end if;
      if (for some X of E.Next_Act (0 .. Integer (E.Na)-1) => X not in Tier0_Real) then Result := Numeric_Limit; return; end if;
      MJ.Data.Euler.Advanced.Advance (E.D, Result);
      if Result = Success then E.Act (0 .. Integer (E.Na)-1) := E.Next_Act (0 .. Integer (E.Na)-1); end if;
   exception
      when Constraint_Error => Result := Numeric_Limit;
   end Step;
end MJ.Data.Advanced;

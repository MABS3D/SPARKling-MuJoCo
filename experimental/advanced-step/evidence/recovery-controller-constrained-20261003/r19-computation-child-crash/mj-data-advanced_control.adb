with Interfaces;
with Ada.Numerics;
with MJ.Models.Validity;
with MJ.Advanced_State;
with MJ.Advanced_Actuators;
with MJ.Actuator_Curves;
with MJ.Actuator_Geometry;
with MJ.Data.Inertia_Phase;
with MJ.Data.Controller_Forces;
with MJ.Data.Controller_Dynamics;
with MJ.Controller_Array_Kernels;
with MJ.Data.Advanced_Control.Computation;
package body MJ.Data.Advanced_Control with SPARK_Mode is
   package AA renames MJ.Advanced_Actuators;
   package AC renames MJ.Actuator_Curves;
   package AG renames MJ.Actuator_Geometry;
   package T renames MJ.Transmissions;
   Ada_Pi : constant Real := Ada.Numerics.Pi;
   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_8;
   function Ready (E : Controller) return Boolean is (E.Initialized);
   function Inputs (E : Controller) return Real_Array is (E.Control (0 .. Integer (E.Nu)-1));
   function Activation (E : Controller) return Real_Array is (E.Act (0 .. Integer (E.Na)-1));
   function Rates (E : Controller) return Real_Array is (E.Dot (0 .. Integer (E.Na)-1));
   function Control_Count (E : Controller) return Natural is (E.Nu);
   function Output_Count (E : Controller) return Natural is (E.No);
   function Position_Count (E : Controller) return Natural is (E.Nq);
   function Velocity_Count (E : Controller) return Natural is (E.Nv);
   function Lengths (E : Controller) return Real_Array is (E.L (0 .. Integer (E.No)-1));
   function Velocities (E : Controller) return Real_Array is (E.V (0 .. Integer (E.No)-1));
   function Forces (E : Controller) return Real_Array is (E.F (0 .. Integer (E.No)-1));
   function Generalized (E : Controller) return Real_Array is (E.Qforce (0 .. Integer (E.Nv)-1));
   function Accelerations (E : Controller) return Real_Array is (E.Acc (0 .. Integer (E.Nv)-1));

   function Capture_Evaluation (E : Controller) return Evaluation_State is
     ((No => E.No, Na => E.Na, Nv => E.Nv, Valid => E.Valid, Can_Advance => E.Can_Advance,
       Next_Act => E.Next_Act (0 .. Integer (E.Na)-1), Dot => E.Dot (0 .. Integer (E.Na)-1),
       L => E.L (0 .. Integer (E.No)-1), V => E.V (0 .. Integer (E.No)-1), F => E.F (0 .. Integer (E.No)-1),
       Qforce => E.Qforce (0 .. Integer (E.Nv)-1), Acc => E.Acc (0 .. Integer (E.Nv)-1)));
   procedure Restore_Evaluation (E : in out Controller; Saved : Evaluation_State) is
   begin
      E.Valid := Saved.Valid; E.Can_Advance := Saved.Can_Advance;
      E.Next_Act (0 .. Integer (E.Na)-1) := Saved.Next_Act;
      E.Dot (0 .. Integer (E.Na)-1) := Saved.Dot;
      E.L (0 .. Integer (E.No)-1) := Saved.L;
      E.V (0 .. Integer (E.No)-1) := Saved.V;
      E.F (0 .. Integer (E.No)-1) := Saved.F;
      E.Qforce (0 .. Integer (E.Nv)-1) := Saved.Qforce;
      E.Acc (0 .. Integer (E.Nv)-1) := Saved.Acc;
   end Restore_Evaluation;
   procedure Free (E : in out Controller) is
   begin
      E.Initialized := False; E.Valid := False;
      E.Nq := 0; E.Nv := 0; E.Nb := 0;
      E.Nu := 0; E.No := 0; E.Na := 0; E.Nactuator := 0; E.Has_Sites := False;
   end Free;
   procedure Reset (E : in out Controller) is
   begin
      E.Control := [others => 0.0]; E.Act := [others => 0.0];
      E.Dot := [others => 0.0]; E.Next_Act := [others => 0.0];
      E.Valid := False; E.Can_Advance := True;
   end Reset;
   procedure Invalidate (E : in out Controller) is
   begin
      E.Valid := False;
   end Invalidate;
   procedure Set_Control (E : in out Controller; Index : Natural; Value : Tier0_Real;
                          Result : out Status) is
   begin
      if not Ready (E) then Result := Not_Allocated;
      elsif Index >= E.Nu then Result := Invalid_Index;
      else E.Control (Index) := Value; E.Valid := False; Result := Success; end if;
   end Set_Control;
   procedure Set_Activation (E : in out Controller; Values : State_Vector; Result : out Status) is
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      if Int64 (Values'Length) /= Int64 (E.Na) then Result := Invalid_Size; return; end if;
      E.Act (0 .. Integer (E.Na)-1) := As_Reals (Values);
      E.Valid := False; Result := Success;
   end Set_Activation;
   procedure Configure (M : MJ.Models.Model; E : in out Controller; Result : out Status) is
      U, O, A : Natural := 0;
      Id, Ref : Integer;
      Parents : TX.Parent_Array (0 .. Max_Dofs-1) := [others => -1];
      First, Second : Integer;
   begin
      if Ready (E) then Result := Already_Allocated; return; end if;
      Result := Invalid_Model;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      if M.S.Nactuator > Max_Actuators or else M.S.Nu > Max_Controls
        or else M.S.Nout > Max_Outputs or else M.S.Na > Max_Actuators
        or else M.S.Nv > Max_Dofs or else M.S.Nq > Max_Positions
        or else M.S.Nbody > Max_Bodies then Result := Capacity_Exceeded; return; end if;
      E.Nq := M.S.Nq; E.Nv := M.S.Nv; E.Nb := M.S.Nbody;
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
      E.Initialized := True; Reset (E); Result := Success;
   exception
      when Constraint_Error => Free (E); Result := Invalid_Model;
   end Configure;

   procedure Evaluate_Into (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => Output_Count (E) = Output_Count (E)'Old);
   pragma Postcondition (Static => Activation (E)'Length = Activation (E)'Old'Length);
   pragma Postcondition (Static => Velocity_Count (E) = Velocity_Count (E)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Activation (E) = Activation (E)'Old);
   pragma Postcondition (Static => Inputs (E) = Inputs (E)'Old);
   procedure Evaluate_Into (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Array_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
   begin
      E.Valid := False;
      if not Ready (E) or else not Is_Ready (D) then Result := Not_Allocated; return; end if;
      if D.Nq /= E.Nq or else D.Nv /= E.Nv or else D.Nb /= E.Nb then Result := Invalid_Size; return; end if;
      if External'Length /= 0 and then (External'First /= 0 or else Int64 (External'Length) /= Int64 (D.Nb)) then Result := Invalid_Size; return; end if;
      Controller_Dynamics.Prepare (D, E.Has_Sites, Result);
      if Result /= Success then return; end if;
      Computation.Compute (D, E, Result); if Result /= Success then return; end if;
      Controller_Forces.Publish (D, E.Qforce (0 .. D.Nv-1), Result);
      if Result /= Success then return; end if;
      Inertia_Phase.Solve_Acceleration (D, Result, External);
      if Result = Success then E.Acc (0 .. D.Nv-1) := D.Dynamics.Acceleration.all; E.Valid := True; end if;
   exception
      when Constraint_Error => D.Cache.Force_Valid := False; D.Cache.Actuation_Valid := False; Result := Numeric_Limit;
   end Evaluate_Into;
   procedure Evaluate (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      Saved : constant Evaluation_State := Capture_Evaluation (E);
   begin
      Evaluate_Into (D, E, Result, External);
      if Result /= Success then
         Restore_Evaluation (E, Saved);
         D.Cache.Actuation_Valid := False; D.Cache.Force_Valid := False;
      end if;
   end Evaluate;
   procedure Stage_Advance (D : Simulation; E : in out Controller; Result : out Status) is
      N, Scale : Real;
   begin
      if not E.Can_Advance then Result := Numeric_Limit; return; end if;
      --  Re-anchor from the evaluated lengths, before publication, as C does.
      if D.Actuation_Enabled then
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
      Result := Success;
   exception
      when Constraint_Error => Result := Numeric_Limit;
   end Stage_Advance;
   procedure Publish (E : in out Controller) is
   begin
      MJ.Controller_Array_Kernels.Copy_Prefix (E.Act, E.Next_Act, E.Na);
   end Publish;
end MJ.Data.Advanced_Control;

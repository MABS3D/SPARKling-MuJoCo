package body MJ.Smooth_Actuation with SPARK_Mode is
   function Force_For
     (C : Parameters; Q, V, U : Tier0_Real; Enabled, Clamp_Control : Boolean) return Actuator_Force_Real
   is
      F : Actuator_Force_Real;
   begin
      if not Enabled then return 0.0; end if;
      F := Affine_Force (C.Gain,
        Control_Value (U, C.Control_Lower, C.Control_Upper, Clamp_Control and then C.Kind = MJ.Activation.None and then C.Control_Limited),
        C.Bias, Transmission (C.Gear, Q), Transmission (C.Gear, V));
      if C.Force_Limited then
         F := Clamp (F, C.Force_Lower, C.Force_Upper);
      end if;
      return F;
   end Force_For;
   function Accumulate (Acc : Accumulated_Real; Term : Actuator_Torque_Real; Count : Natural) return Accumulated_Real is
   begin
      return Acc + Term;
   end Accumulate;
   procedure Unfold_Forces (C : Parameter_Array; F : Real_Array; Count : Natural) is null;
   procedure Accumulate_At (A : in out Real_Array; Index, Count : Natural; Term : Actuator_Torque_Real) is
   begin
      A (Index) := Accumulate (A (Index), Term, Count);
   end Accumulate_At;
   procedure Project_All (C : Parameter_Array; F : Real_Array; Generalized : out Real_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Reduced_Force);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Force_Law);
   begin
      Generalized := [others => 0.0];
      for A in C'Range loop
         Unfold_Forces (C, F, A);
         Accumulate_At (Generalized, C (A).Joint_Id, A, Project_Force (C (A).Gear, F (A)));
         pragma Loop_Invariant (for all X of Generalized => X in Accumulated_Real
           and then abs X <= Real (A + 1) * Step_Bound);
         pragma Loop_Invariant (Static => (for all J in Generalized'Range =>
           Generalized (J) = Reduced_Force (C, F, J, A + 1)));
      end loop;
   end Project_All;
   procedure Compute
     (C : Parameter_Array; Q, V, U : Real_Array; Enabled, Clamp_Control : Boolean;
      Lengths, Velocities, Forces, Generalized : out Real_Array)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Reduced_Force);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Force_Law);
   begin
      Lengths := [others => 0.0]; Velocities := [others => 0.0];
      Forces := [others => 0.0];
      for A in C'Range loop
         declare
            J : constant Natural := C (A).Joint_Id;
         begin
            Lengths (A) := Transmission (C (A).Gear, Q (J));
            if Enabled then
               Velocities (A) := Transmission (C (A).Gear, V (J));
            end if;
            Forces (A) := Force_For (C (A), Q (J), V (J), U (A), Enabled, Clamp_Control);
         end;
         pragma Loop_Invariant (for all X of Lengths => X in Transmission_Real);
         pragma Loop_Invariant (for all X of Velocities => X in Transmission_Real);
         pragma Loop_Invariant (for all X of Forces => X in Actuator_Force_Real);
         pragma Loop_Invariant (for all I in 0 .. A => Lengths (I) = Transmission (C (I).Gear, Q (C (I).Joint_Id)));
         pragma Loop_Invariant (if Enabled then
           (for all I in 0 .. A => Velocities (I) = Transmission (C (I).Gear, V (C (I).Joint_Id)))
           else (for all X of Velocities => X = 0.0));
         pragma Loop_Invariant (for all I in 0 .. A => Forces (I) =
           Force_For (C (I), Q (C (I).Joint_Id), V (C (I).Joint_Id), U (I), Enabled, Clamp_Control));
      end loop;
      Project_All (C, Forces, Generalized);
   end Compute;
   procedure Compute_Activated
     (C : Parameter_Array; Q, V, U : Real_Array;
      Act : MJ.Activation.Value_Array; H : Nonneg_Tier0;
      Enabled, Clamp_Control : Boolean;
      Next, Drive : in out MJ.Activation.Value_Array;
      Dot : in out MJ.Activation.Rate_Array;
      Lengths, Velocities, Forces, Generalized : in out Real_Array;
      Ok, Advance_Valid : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Reduced_Force);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Force_Law);
   begin
      Ok := True; Advance_Valid := True;
      for I in C'Range loop
         pragma Loop_Invariant (Ok);
         pragma Loop_Invariant (for all K in 0 .. I - 1 => Lengths (K) in Transmission_Real
           and then Velocities (K) in Transmission_Real and then Forces (K) in Actuator_Force_Real);
         pragma Loop_Invariant (for all K in 0 .. I - 1 => Lengths (K) = Transmission (C (K).Gear, Q (C (K).Joint_Id))
           and then Velocities (K) = (if Enabled then Transmission (C (K).Gear, V (C (K).Joint_Id)) else 0.0)
           and then Forces (K) = Force_For (C (K), Q (C (K).Joint_Id), V (C (K).Joint_Id), Drive (K), Enabled, Clamp_Control));
         declare
            P : constant Parameters := C (I);
            Control : Tier0_Real;
         begin
            Drive (I) := U (I);
            if P.Kind /= MJ.Activation.None then
               Control := Control_Value (U (I), P.Control_Lower, P.Control_Upper,
                 Clamp_Control and then P.Control_Limited);
               MJ.Activation.Prepare
                 (P.Kind, Control, Act (P.Activation_Id), H, P.Tau, P.Factor,
                  Enabled, P.Early, P.Activation_Limited, P.Activation_Lower, P.Activation_Upper,
                  Dot (P.Activation_Id), Next (P.Activation_Id), Drive (I), Ok);
               if not Ok then
                  Advance_Valid := False;
                  if P.Early then return; end if;
                  --  Forward uses current activation; defer a future-state
                  --  domain failure until Euler actually attempts the commit.
                  Ok := True;
               end if;
            end if;
            Lengths (I) := Transmission (P.Gear, Q (P.Joint_Id));
            Velocities (I) := (if Enabled then Transmission (P.Gear, V (P.Joint_Id)) else 0.0);
            Forces (I) := Force_For (P, Q (P.Joint_Id), V (P.Joint_Id), Drive (I), Enabled, Clamp_Control);
         end;
      end loop;
      Project_All (C, Forces, Generalized);
   end Compute_Activated;
end MJ.Smooth_Actuation;

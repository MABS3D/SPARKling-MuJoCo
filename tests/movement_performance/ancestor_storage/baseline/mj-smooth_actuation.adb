package body MJ.Smooth_Actuation with SPARK_Mode is
   function Force_For
     (C : Parameters; Q, V, U : Tier0_Real; Enabled, Clamp_Control : Boolean) return Actuator_Force_Real
   is
      F : Actuator_Force_Real;
   begin
      if not Enabled then return 0.0; end if;
      F := Affine_Force (C.Gain,
        Control_Value (U, C.Control_Lower, C.Control_Upper, Clamp_Control and then C.Control_Limited),
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
end MJ.Smooth_Actuation;

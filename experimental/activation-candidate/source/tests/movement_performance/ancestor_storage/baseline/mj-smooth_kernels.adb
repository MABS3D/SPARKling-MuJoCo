package body MJ.Smooth_Kernels with SPARK_Mode is
   function Transmission (Gear, Value : Tier0_Real) return Transmission_Real is (Gear * Value);
   pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Transmission_Model);
   function Control_Value
     (Control, Low, High : Tier0_Real; Clamp_Enabled : Boolean) return Tier0_Real is
     (if Clamp_Enabled then Clamp (Control, Low, High) else Control);
   function Affine_Force
     (Gain, Control : Tier0_Real; Bias : Vector; Length, Velocity : Transmission_Real)
     return Actuator_Force_Real is
      subtype Base_Real is Real range -2.0e20 .. 2.0e20;
      subtype Partial_Real is Real range -2.0e30 .. 2.0e30;
      Base : constant Base_Real := Gain * Control + Bias (0);
      Position_Term : constant Tier1_Real := Bias (1) * Length;
      Velocity_Term : constant Tier1_Real := Bias (2) * Velocity;
      Partial : constant Partial_Real := Base + Position_Term;
   begin
      return Partial + Velocity_Term;
   end Affine_Force;
   function Project_Force (Gear : Tier0_Real; Force : Actuator_Force_Real) return Actuator_Torque_Real is
     (Gear * Force);
   function Passive_Force
     (Qpos, Reference, Qvel : Tier0_Real; Stiffness, Damping : Nonneg_Tier0;
      Spring_Enabled, Damper_Enabled : Boolean) return Tier1_Real is
   begin
      return (if Spring_Enabled then -Stiffness * (Qpos - Reference) else 0.0)
        + (if Damper_Enabled then -Damping * Qvel else 0.0);
   end Passive_Force;
   function Inner_Component (A, B, C, X, Y, Z : Real) return Real is
      subtype Product_Real is Real range -2.0e61 .. 2.0e61;
      subtype Pair_Real is Real range -4.0e61 .. 4.0e61;
      AX : constant Product_Real := A * X;
      BY : constant Product_Real := B * Y;
      CZ : constant Product_Real := C * Z;
      Pair : constant Pair_Real := AX + BY;
   begin
      return Pair + CZ;
   end Inner_Component;
   function Outer_Component (A, B, C, X, Y, Z : Real) return Real is
      subtype Product_Real is Real range -2.0e74 .. 2.0e74;
      subtype Pair_Real is Real range -4.0e74 .. 4.0e74;
      AX : constant Product_Real := A * X;
      BY : constant Product_Real := B * Y;
      CZ : constant Product_Real := C * Z;
      Pair : constant Pair_Real := AX + BY;
   begin
      return Pair + CZ;
   end Outer_Component;
   function Into_Inertial_Frame (R : Matrix; V : Vector) return Vector is
      Reference : constant Vector := Apply_Transpose (R, V) with Ghost => Static;
      subtype Inner_Real is Real range -1.0e62 .. 1.0e62;
      X : constant Inner_Real := Inner_Component (R (0, 0), R (1, 0), R (2, 0), V (0), V (1), V (2));
      Y : constant Inner_Real := Inner_Component (R (0, 1), R (1, 1), R (2, 1), V (0), V (1), V (2));
      Z : constant Inner_Real := Inner_Component (R (0, 2), R (1, 2), R (2, 2), V (0), V (1), V (2));
   begin
      pragma Assert (Static => Reference (0) = X);
      pragma Assert (Static => Reference (1) = Y);
      pragma Assert (Static => Reference (2) = Z);
      return [X, Y, Z];
   end Into_Inertial_Frame;
   function Local_Inertia (R : Matrix; Diagonal, V : Vector) return Vector is
      Rotated : constant Vector := Into_Inertial_Frame (R, V);
      subtype Scaled_Real is Real range -1.0e73 .. 1.0e73;
      X : constant Scaled_Real := Diagonal (0) * Rotated (0);
      Y : constant Scaled_Real := Diagonal (1) * Rotated (1);
      Z : constant Scaled_Real := Diagonal (2) * Rotated (2);
   begin
      return [X, Y, Z];
   end Local_Inertia;
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector is
      Local : constant Vector := Local_Inertia (R, Diagonal, V);
      Reference : constant Vector := Apply (R, Local) with Ghost => Static;
      subtype Outer_Real is Real range -1.0e75 .. 1.0e75;
      X : constant Outer_Real := Outer_Component (R (0, 0), R (0, 1), R (0, 2), Local (0), Local (1), Local (2));
      Y : constant Outer_Real := Outer_Component (R (1, 0), R (1, 1), R (1, 2), Local (0), Local (1), Local (2));
      Z : constant Outer_Real := Outer_Component (R (2, 0), R (2, 1), R (2, 2), Local (0), Local (1), Local (2));
   begin
      pragma Assert (Static => Reference (0) = X);
      pragma Assert (Static => Reference (1) = Y);
      pragma Assert (Static => Reference (2) = Z);
      return [X, Y, Z];
   end Inertia_Times;
   function Euler_Value (Old_Value, Rate : Tier0_Real; Timestep : Nonneg_Tier0) return Tier1_Real is
     (Old_Value + Timestep * Rate);
   function Matrix_Offset (N, Row, Column : Natural) return Natural is (Row * N + Column);
   function Jacobian_Index (Nb, Nv, Body_Id, Velocity_Id : Natural) return Natural is
     (3 * (Body_Id * Nv + Velocity_Id));
   procedure Equal_Transitive (A, B, C : Real_Array) is null;
   procedure Stage_Euler
     (Q, V, Rate : Real_Array; H : Nonneg_Tier0; Next_Q, Next_V : out Real_Array; Ok : out Boolean)
   is
      Value : Tier1_Real;
   begin
      Next_Q := [others => 0.0]; Next_V := [others => 0.0]; Ok := False;
      for I in V'Range loop
         if Rate (I) not in Tier0_Real then return; end if;
         Value := Euler_Value (V (I), Rate (I), H);
         if Value not in Tier0_Real then return; end if;
         Next_V (I) := Value;
         pragma Loop_Invariant (All_Tier0 (Next_V));
         pragma Loop_Invariant (for all K in V'First .. I => Rate (K) in Tier0_Real
           and then Next_V (K) = V (K) + H * Rate (K));
      end loop;
      for I in Q'Range loop
         Value := Euler_Value (Q (I), Next_V (I), H);
         if Value not in Tier0_Real then return; end if;
         Next_Q (I) := Value;
         pragma Loop_Invariant (All_Tier0 (Next_Q));
         pragma Loop_Invariant (for all K in Q'First .. I => Next_Q (K) = Q (K) + H * Next_V (K));
      end loop;
      Ok := True;
   end Stage_Euler;
end MJ.Smooth_Kernels;

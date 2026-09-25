--  Scalar laws used by the unconstrained dynamics. Exact rounded formulas.
with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
package MJ.Smooth_Kernels with SPARK_Mode is
   subtype Transmission_Real is Real range -1.0e20 .. 1.0e20;
   subtype Actuator_Force_Real is Real range -4.0e30 .. 4.0e30;
   subtype Actuator_Torque_Real is Real range -4.0e40 .. 4.0e40;
   function Clamp (Value, Low, High : Real) return Real is
     (Real'Max (Low, Real'Min (High, Value))) with
     Global => null, Pre => Low <= High,
     Post => Clamp'Result in Low .. High
       and then Clamp'Result = (if Value < Low then Low elsif Value > High then High else Value);
   function Transmission_Model (Gear, Value : Tier0_Real) return Transmission_Real is (Gear * Value)
     with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Transmission (Gear, Value : Tier0_Real) return Transmission_Real with
     Global => null, Post => Transmission'Result = Transmission_Model (Gear, Value);
   function Control_Value
     (Control, Low, High : Tier0_Real; Clamp_Enabled : Boolean) return Tier0_Real with
     Global => null, Pre => (if Clamp_Enabled then Low <= High),
     Post => Control_Value'Result = (if Clamp_Enabled then Clamp (Control, Low, High) else Control);
   function Affine_Force
     (Gain, Control : Tier0_Real; Bias : Vector; Length, Velocity : Transmission_Real)
     return Actuator_Force_Real with
     Global => null, Pre => Bounded (Bias, Max_Val),
     Post => Affine_Force'Result = ((Gain * Control + Bias (0)) + Bias (1) * Length) + Bias (2) * Velocity;
   function Project_Force (Gear : Tier0_Real; Force : Actuator_Force_Real) return Actuator_Torque_Real with
     Global => null, Post => Project_Force'Result = Gear * Force;
   function Passive_Force
     (Qpos, Reference, Qvel : Tier0_Real; Stiffness, Damping : Nonneg_Tier0;
      Spring_Enabled, Damper_Enabled : Boolean) return Tier1_Real with
     Global => null,
     Post => Passive_Force'Result =
       (if Spring_Enabled then -Stiffness * (Qpos - Reference) else 0.0)
       + (if Damper_Enabled then -Damping * Qvel else 0.0);
   function Inner_Component (A, B, C, X, Y, Z : Real) return Real with
     Global => null, Pre => A in -16.0 .. 16.0 and then B in -16.0 .. 16.0 and then C in -16.0 .. 16.0
       and then X in -1.0e60 .. 1.0e60 and then Y in -1.0e60 .. 1.0e60 and then Z in -1.0e60 .. 1.0e60,
     Post => Inner_Component'Result in -1.0e62 .. 1.0e62 and then Inner_Component'Result = (A * X + B * Y) + C * Z;
   function Outer_Component (A, B, C, X, Y, Z : Real) return Real with
     Global => null, Pre => A in -16.0 .. 16.0 and then B in -16.0 .. 16.0 and then C in -16.0 .. 16.0
       and then X in -1.0e73 .. 1.0e73 and then Y in -1.0e73 .. 1.0e73 and then Z in -1.0e73 .. 1.0e73,
     Post => Outer_Component'Result in -1.0e75 .. 1.0e75 and then Outer_Component'Result = (A * X + B * Y) + C * Z;
   function Into_Inertial_Frame (R : Matrix; V : Vector) return Vector with
     Global => null, Pre => Bounded (R, 16.0) and then Bounded (V),
     Post => Bounded (Into_Inertial_Frame'Result, 1.0e62)
       and then Into_Inertial_Frame'Result = Apply_Transpose (R, V);
   function Local_Inertia (R : Matrix; Diagonal, V : Vector) return Vector with
     Global => null, Pre => Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val) and then Bounded (V),
     Post => Bounded (Local_Inertia'Result, 1.0e73)
       and then (for all K in Axis => Local_Inertia'Result (K) = Diagonal (K) * Into_Inertial_Frame (R, V) (K));
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector with
     Global => null, Pre => Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val) and then Bounded (V),
     Post => Bounded (Inertia_Times'Result, 1.0e75)
       and then Inertia_Times'Result = Apply (R, Local_Inertia (R, Diagonal, V));
   function Euler_Value (Old_Value, Rate : Tier0_Real; Timestep : Nonneg_Tier0) return Tier1_Real with
     Global => null, Post => Euler_Value'Result = Old_Value + Timestep * Rate;
   function Matrix_Offset (N, Row, Column : Natural) return Natural with
     Global => null, Pre => N <= 1024 and then Row < N and then Column < N,
     Post => Matrix_Offset'Result = Row * N + Column and then Matrix_Offset'Result < N * N;
   function Jacobian_Index (Nb, Nv, Body_Id, Velocity_Id : Natural) return Natural with
     Global => null, Pre => Nb <= 4096 and then Nv <= 256 and then Body_Id < Nb and then Velocity_Id < Nv,
     Post => Jacobian_Index'Result = 3 * (Body_Id * Nv + Velocity_Id)
       and then Jacobian_Index'Result + 2 < 3 * Nb * Nv;
   procedure Equal_Transitive (A, B, C : Real_Array) with Ghost => Static, Global => null,
     Pre => A = B and then B = C, Post => A = C;
   function All_Tier0 (A : Real_Array) return Boolean is
     (for all X of A => X in Tier0_Real) with Global => null;
   function Same_Bounds (A, B : Real_Array) return Boolean is
     (A'First = B'First and then A'Last = B'Last) with Global => null;
   function Euler_Update
     (Q, V, Rate, Next_Q, Next_V : Real_Array; H : Nonneg_Tier0) return Boolean is
     (Same_Bounds (Q, V) and then Same_Bounds (Q, Rate) and then Same_Bounds (Q, Next_Q)
      and then Same_Bounds (Q, Next_V) and then All_Tier0 (Q) and then All_Tier0 (V)
      and then All_Tier0 (Rate) and then All_Tier0 (Next_Q) and then All_Tier0 (Next_V)
      and then (for all I in Q'Range => Next_V (I) = V (I) + H * Rate (I)
        and then Next_Q (I) = Q (I) + H * Next_V (I))) with Ghost => Static, Global => null;
   procedure Stage_Euler
     (Q, V, Rate : Real_Array; H : Nonneg_Tier0; Next_Q, Next_V : out Real_Array; Ok : out Boolean) with
     Global => null,
     Pre => Same_Bounds (Q, V) and then Same_Bounds (Q, Rate)
       and then Q'First = Next_Q'First and then Q'Last = Next_Q'Last
       and then Q'First = Next_V'First and then Q'Last = Next_V'Last
       and then All_Tier0 (Q) and then All_Tier0 (V),
     Post => (if Ok then All_Tier0 (Rate) and then All_Tier0 (Next_Q) and then All_Tier0 (Next_V));
   pragma Postcondition (Static => (if Ok then Euler_Update (Q, V, Rate, Next_Q, Next_V, H)));
end MJ.Smooth_Kernels;

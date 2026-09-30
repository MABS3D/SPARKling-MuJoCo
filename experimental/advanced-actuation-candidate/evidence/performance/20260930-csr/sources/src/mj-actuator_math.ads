with MJ.Types; use MJ.Types;
with Ada.Numerics.Generic_Elementary_Functions;
package MJ.Actuator_Math with SPARK_Mode is
   package Math is new Ada.Numerics.Generic_Elementary_Functions (Real);
   subtype Input is Tier0_Real;
   subtype Scalar is Real range -1.0e200 .. 1.0e200;
   subtype Positive_Real is Real range Min_Val .. 1.0e10;
   subtype Curve_Argument is Real range -1.0e26 .. 1.0e26;
   subtype Curve_Value is Real range -1.0e84 .. 1.0e84;
   subtype Length_Scale is Real range -1.0e26 .. 1.0e26;
   subtype Curve_Ratio is Real range -1.0e42 .. 1.0e42;
   subtype Half_Range is Real range -1.0e10 .. 1.0e10;
   subtype Velocity_Scale is Real range -2.0e10 .. 2.0e10;
   subtype Unit_Fraction is Real range 0.0 .. 1.0;
   subtype Activation_Scale is Real range 0.5 .. 2.0;
   subtype Wrapped_Value is Real range -1.0e27 .. 1.0e27;
   subtype Torque_Value is Real range -1.0e22 .. 1.0e22;
   subtype Voltage_Value is Real range -1.0e49 .. 1.0e49;
   subtype Current_Rate is Real range -1.0e132 .. 1.0e132;
   type Parameters is array (Natural range 0 .. 9) of Input;
   type Vector is array (Natural range 0 .. 2) of Real;
   type Quaternion is array (Natural range 0 .. 3) of Real;
   type Matrix is array (Natural range 0 .. 2, Natural range 0 .. 2) of Input;
   Zero : constant Vector := (others => 0.0);
   Identity : constant Quaternion := (1.0, 0.0, 0.0, 0.0);
   function Bounded (V : Vector; B : Real) return Boolean is
     (B >= 0.0 and then V (0) in -B .. B and then V (1) in -B .. B and then V (2) in -B .. B) with Annotate => (GNATprove, Inline_For_Proof);
   function Bounded (Q : Quaternion; B : Real) return Boolean is
     (B >= 0.0 and then Q (0) in -B .. B and then Q (1) in -B .. B and then Q (2) in -B .. B and then Q (3) in -B .. B) with Annotate => (GNATprove, Inline_For_Proof);
   -- Elementary runtime calls remain the existing Ada runtime trust boundary.
   -- These are algorithm contracts, not real-arithmetic accuracy claims.
end MJ.Actuator_Math;

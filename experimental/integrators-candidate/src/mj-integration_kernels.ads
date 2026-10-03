with MJ.Types; use MJ.Types;
package MJ.Integration_Kernels with SPARK_Mode is
   subtype Operand is Real range -1.0e60 .. 1.0e60;
   subtype Step_Value is Real range 0.0 .. 1.0e10;
   subtype Weight is Real range 0.0 .. 1.0;
   function Symmetric_Entry (Left, Right : Operand) return Operand
     with Global => null, Post => Symmetric_Entry'Result = 0.5 * (Left + Right);
   function Add_Weighted (Sum, Value : Operand; W : Weight) return Real
     with Global => null, Post => Add_Weighted'Result = Sum + W * Value;
   function Advance (Initial, Rate : Operand; H : Step_Value) return Real
     with Global => null, Post => Advance'Result = Initial + H * Rate;
   function Implicit_Cell (Mass, Derivative : Operand; H : Step_Value) return Real
     with Global => null, Post => Implicit_Cell'Result = Mass + (-H) * Derivative;
   function Discrete_Scale (Stiffness, Damping : Step_Value; H : Step_Value) return Real
     with Global => null, Post => Discrete_Scale'Result = (H * H) * Stiffness + H * Damping;
   function Stiffness_Shift (Force, Stiffness, Speed : Operand; H : Step_Value) return Real
     with Global => null, Post => Stiffness_Shift'Result = Force - (H * Stiffness) * Speed;
   function Update_Entry (Original, Factor, Coefficient : Operand) return Real
     with Global => null, Post => Update_Entry'Result = Original - Factor * Coefficient;
end MJ.Integration_Kernels;

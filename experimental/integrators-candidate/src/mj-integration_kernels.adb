package body MJ.Integration_Kernels with SPARK_Mode is
   function Symmetric_Entry (Left, Right : Operand) return Operand is
   begin
      return 0.5 * (Left + Right);
   end Symmetric_Entry;
   function Add_Weighted (Sum, Value : Operand; W : Weight) return Real is
   begin return Sum + W * Value; end Add_Weighted;
   function Advance (Initial, Rate : Operand; H : Step_Value) return Real is
   begin return Initial + H * Rate; end Advance;
   function Implicit_Cell (Mass, Derivative : Operand; H : Step_Value) return Real is
   begin return Mass + (-H) * Derivative; end Implicit_Cell;
   function Discrete_Scale (Stiffness, Damping : Step_Value; H : Step_Value) return Real is
   begin return (H * H) * Stiffness + H * Damping; end Discrete_Scale;
   function Stiffness_Shift (Force, Stiffness, Speed : Operand; H : Step_Value) return Real is
   begin return Force - (H * Stiffness) * Speed; end Stiffness_Shift;
   function Update_Entry (Original, Factor, Coefficient : Operand) return Real is
   begin return Original - Factor * Coefficient; end Update_Entry;
end MJ.Integration_Kernels;

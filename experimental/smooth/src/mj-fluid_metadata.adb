package body MJ.Fluid_Metadata with SPARK_Mode is
   function Inverse_Mass (Mass : Positive_Mass) return Inverse_Value is
   begin
      return 1.0 / Mass;
   end Inverse_Mass;
   function Box_Length (I0, I1, I2 : Tier0_Real; Mass : Positive_Mass) return Real is
      Sum : constant Real := I1 + I2;
      Difference : constant Real := Sum - I0;
      Positive_Inertia : constant Real := Real'Max (Min_Val, Difference);
      Ratio : constant Real := Positive_Inertia / Mass;
   begin
      return Ada.Numerics.Long_Elementary_Functions.Sqrt (Ratio * 6.0);
   end Box_Length;
end MJ.Fluid_Metadata;

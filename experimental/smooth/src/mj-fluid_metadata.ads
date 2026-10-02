with MJ.Types; use MJ.Types;
with Ada.Numerics.Long_Elementary_Functions;
package MJ.Fluid_Metadata with SPARK_Mode is
   subtype Positive_Mass is Real range Min_Val .. Max_Val;
   subtype Inverse_Value is Real range 0.0 .. 2.0e15;
   function Inverse_Mass (Mass : Positive_Mass) return Inverse_Value
     with Global => null, Post => Inverse_Mass'Result = 1.0 / Mass;
   function Box_Length (I0, I1, I2 : Tier0_Real; Mass : Positive_Mass) return Real
     with Global => null,
     Post => Box_Length'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt
       (Real'Max (Min_Val, I1 + I2 - I0) / Mass * 6.0);
end MJ.Fluid_Metadata;

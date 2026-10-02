with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
package MJ.SDF_Provider with SPARK_Mode is
   procedure Unavailable (Key : Natural; X : Vec; Need_Gradient : Boolean;
                          Value : out Real; Gradient : out Vec; Result : out Status)
     with Global => null, Post => Result = Invalid_Input and Value = 0.0 and Gradient = Zero;
end MJ.SDF_Provider;

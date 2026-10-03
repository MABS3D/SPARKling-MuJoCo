package body MJ.Elliptic_Response with SPARK_Mode is
   function First_Tangent (Normal_R, Impratio : Real) return Real is
   begin
      return Normal_R / Real'Max (Min_Val, Impratio);
   end First_Tangent;

   function Other_Tangent (First_R, First_Friction, Component_Friction : Real) return Real is
   begin
      return ((First_R * First_Friction) * First_Friction) /
        (Component_Friction * Component_Friction);
   end Other_Tangent;
end MJ.Elliptic_Response;

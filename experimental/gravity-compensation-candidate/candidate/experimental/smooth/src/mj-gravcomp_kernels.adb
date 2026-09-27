package body MJ.Gravcomp_Kernels with SPARK_Mode is
   function Body_Force (Mass : Nonneg_Tier0; Coefficient : Tier0_Real; Gravity : Vector)
     return Vector is
      Scale : constant Real := -(Mass * Coefficient);
   begin
      pragma Assert (Static => Scale in -1.0e21 .. 1.0e21);
      return [Gravity (0) * Scale, Gravity (1) * Scale, Gravity (2) * Scale];
   end Body_Force;

   function Difference (A, B : Real) return Offset_Value is
   begin
      return A - B;
   end Difference;

   function Cross_Component (A, B : Real; X, Y : Offset_Value) return Column_Value is
   begin
      return A * X - B * Y;
   end Cross_Component;

   function Linear_Column (Hinge : Boolean; Center, Anchor, Direction : Vector)
     return Vector is
   begin
      if not Hinge then return Direction; end if;
      declare
         X : constant Offset_Value := Difference (Center (0), Anchor (0));
         Y : constant Offset_Value := Difference (Center (1), Anchor (1));
         Z : constant Offset_Value := Difference (Center (2), Anchor (2));
      begin
         return [Cross_Component (Direction (1), Direction (2), Z, Y),
                 Cross_Component (Direction (2), Direction (0), X, Z),
                 Cross_Component (Direction (0), Direction (1), Y, X)];
      end;
   end Linear_Column;

end MJ.Gravcomp_Kernels;

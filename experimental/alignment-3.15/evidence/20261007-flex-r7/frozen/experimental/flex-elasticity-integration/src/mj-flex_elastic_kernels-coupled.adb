package body MJ.Flex_Elastic_Kernels.Coupled with SPARK_Mode is
   function Bending_Update
     (Previous : Force_Value; K : Four_Coefficients; X : Four_World;
      Beta : Coefficient; Normal : Real; Curved : Boolean := True) return Real is
      Value : Real := Previous;
   begin
      Value := Value + K (0)*X (0);
      pragma Assert (Static => Value in -1.1e120 .. 1.1e120);
      Value := Value + K (1)*X (1);
      pragma Assert (Static => Value in -1.2e120 .. 1.2e120);
      Value := Value + K (2)*X (2);
      pragma Assert (Static => Value in -1.3e120 .. 1.3e120);
      Value := Value + K (3)*X (3);
      pragma Assert (Static => Value in -1.4e120 .. 1.4e120);
      return (if Curved then Value + Beta*Normal else Value);
   end Bending_Update;
end MJ.Flex_Elastic_Kernels.Coupled;

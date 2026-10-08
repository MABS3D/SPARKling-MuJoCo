package body MJ.Flex_Elastic_Kernels.Coupled with SPARK_Mode is
   function Bending_Update
     (Previous : Force_Value; K : Four_Coefficients; X : Four;
      Beta : Coefficient; Normal : Real; Curved : Boolean := True) return Real is
      Value : Real := Previous;
   begin
      Value := Value + K (0)*X (0);
      Value := Value + K (1)*X (1);
      Value := Value + K (2)*X (2);
      Value := Value + K (3)*X (3);
      return (if Curved then Value + Beta*Normal else Value);
   end Bending_Update;
end MJ.Flex_Elastic_Kernels.Coupled;

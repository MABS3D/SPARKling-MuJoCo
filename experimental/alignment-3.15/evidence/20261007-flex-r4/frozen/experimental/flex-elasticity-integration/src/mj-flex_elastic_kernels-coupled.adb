package body MJ.Flex_Elastic_Kernels.Coupled with SPARK_Mode is
   function Bending_Update
     (Previous : Force_Value; K : Four_Coefficients; X : Four;
      Beta : Coefficient; Normal : Real) return Real is
      Value : Real := Previous;
   begin
      for I in K'Range loop
         Value := Value + K (I)*X (I);
         pragma Loop_Invariant (Value in -1.1e120 .. 1.1e120);
         pragma Loop_Invariant
           (Value = (if I=0 then Previous + K (0)*X (0)
                     elsif I=1 then (Previous + K (0)*X (0)) + K (1)*X (1)
                     elsif I=2 then ((Previous + K (0)*X (0)) + K (1)*X (1)) + K (2)*X (2)
                     else (((Previous + K (0)*X (0)) + K (1)*X (1)) + K (2)*X (2)) + K (3)*X (3)));
      end loop;
      return Value + Beta*Normal;
   end Bending_Update;
end MJ.Flex_Elastic_Kernels.Coupled;

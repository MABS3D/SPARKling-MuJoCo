package body MJ.Trigonometry with SPARK_Mode is
   function Cosine (X : Real) return Real is
   begin
      if abs X < Cosine_Tiny_Threshold then
         return 1.0 - (X*X)/2.0;
      else
         return Ada.Numerics.Long_Elementary_Functions.Cos (X);
      end if;
   end Cosine;
end MJ.Trigonometry;

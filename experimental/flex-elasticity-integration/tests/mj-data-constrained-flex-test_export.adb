package body MJ.Data.Constrained.Flex.Test_Export with SPARK_Mode is
   use type CA.Constraint_Kind;
   function Equality_Ids (E : Engine) return Int_Array is
      Ids : Int_Array (1 .. E.Base.Rows.Ne);
   begin
      for R in Ids'Range loop
         pragma Assert (Static => E.Base.Rows.Descriptors (R).Kind = CA.Equality);
         Ids (R) := E.Base.Rows.Descriptors (R).Id;
      end loop;
      return Ids;
   end Equality_Ids;
end MJ.Data.Constrained.Flex.Test_Export;

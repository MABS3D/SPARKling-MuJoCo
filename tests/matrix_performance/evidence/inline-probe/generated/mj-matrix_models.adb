package body MJ.Matrix_Models with SPARK_Mode is
   function Matrix_Entry (A : Matrix; I, J : Natural) return Tier0_Real is
   begin
      return A (I, J);
   end Matrix_Entry;
   function Weight_Entry (D : Real_Array; I : Natural) return Tier0_Real is
   begin
      return D (I);
   end Weight_Entry;
   procedure Unfold_Sequential (A, B : Real_Array; Count : Size_Type) is null;
   procedure Unfold_Bilinear (A, B : Real_Array; Count : Size_Type) is null;
   procedure Unfold_Weighted (A, B, D : Real_Array; Count : Size_Type) is null;

   procedure Unfold_Product_Entry (A, B : Matrix; I, J : Natural; Count : Size_Type;
                                    Transposed : Boolean) is
   begin
      if Transposed then
         Unfold_Sequential (Column (A, I), Column (B, J), Count);
      else
         Unfold_Sequential (Row (A, I), Column (B, J), Count);
      end if;
   end Unfold_Product_Entry;

   procedure Unfold_Gram_Entry (A : Matrix; D : Real_Array; I, J : Natural; Count : Size_Type) is
   begin
      if D'Length = 0 then
         Unfold_Sequential (Column (A, I), Column (A, J), Count);
      else
         Unfold_Weighted (Column (A, I), Column (A, J), D, Count);
      end if;
   end Unfold_Gram_Entry;

   procedure Unfold_Product_Row (A, B : Matrix; I : Natural; Count : Size_Type;
                                  Transposed : Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Product_Prefix);
   begin
      for J in B'Range (2) loop
         Unfold_Product_Entry (A, B, I, J, Count, Transposed);
         pragma Loop_Invariant (for all L in 0 .. J =>
           Product_Prefix (A, B, I, L, Count + 1, Transposed) =
             (if (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count)) = 0.0 then Product_Prefix (A, B, I, L, Count, Transposed)
              else Product_Prefix (A, B, I, L, Count, Transposed) + Matrix_Entry (B, Count, L) * (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count))));
      end loop;
   end Unfold_Product_Row;

   procedure Unfold_Vector_Entry (A : Matrix; V : Real_Array; J : Natural; Count : Size_Type) is
   begin
      Unfold_Sequential (V, Column (A, J), Count);
   end Unfold_Vector_Entry;

   procedure Unfold_Vector_Row (A : Matrix; V : Real_Array; Count : Size_Type) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Vector_Prefix);
   begin
      for J in A'Range (2) loop
         Unfold_Vector_Entry (A, V, J, Count);
         pragma Loop_Invariant (for all L in 0 .. J => Vector_Prefix (A, V, L, Count + 1) =
       (if Weight_Entry (V, Count) = 0.0 then Vector_Prefix (A, V, L, Count)
        else Vector_Prefix (A, V, L, Count) + Matrix_Entry (A, Count, L) * Weight_Entry (V, Count)));
      end loop;
   end Unfold_Vector_Row;

   procedure Unfold_Gram_Row (A : Matrix; D : Real_Array; I : Natural; Count : Size_Type) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      for J in 0 .. I loop
         Unfold_Gram_Entry (A, D, I, J, Count);
         pragma Loop_Invariant (for all L in 0 .. J => Gram_Prefix (A, D, I, L, Count + 1) =
           (if Matrix_Entry (A, Count, I) = 0.0 or else (D'Length /= 0 and then Weight_Entry (D, Count) = 0.0)
            then Gram_Prefix (A, D, I, L, Count)
            elsif D'Length = 0 then Gram_Prefix (A, D, I, L, Count) + Matrix_Entry (A, Count, L) * Matrix_Entry (A, Count, I)
            else Gram_Prefix (A, D, I, L, Count) + Matrix_Entry (A, Count, L) * (Matrix_Entry (A, Count, I) * Weight_Entry (D, Count))));
      end loop;
   end Unfold_Gram_Row;
end MJ.Matrix_Models;

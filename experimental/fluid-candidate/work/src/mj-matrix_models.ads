--  Ordered floating-point models; all ghost code is removed from executables.
with MJ.Types; use MJ.Types;
with MJ.BLAS; use MJ.BLAS;
with MJ.Vector_Models;
with MJ.Matrix_Types; use MJ.Matrix_Types;
package MJ.Matrix_Models with SPARK_Mode is
   Wide_Step : constant Real := 2.0 ** 136;
   function Wide_Add (Acc, Term : Real; Count : Size_Type) return Tier2_Real is (Acc + Term)
   with Ghost => Static, Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * Wide_Step
       and then abs Term <= 1.0e40,
     Post => Wide_Add'Result = Acc + Term
       and then abs Wide_Add'Result <= Real (Count + 1) * Wide_Step;

   function Sequential (A, B : Real_Array; Count : Size_Type) return Tier1_Real is
     (if Count = 0 then 0.0 else (if A (Count - 1) = 0.0 then Sequential (A, B, Count - 1)
       else MJ.Vector_Models.Model_Add (Sequential (A, B, Count - 1), B (Count - 1) * A (Count - 1), Count - 1)))
   with Ghost => Static, Global => null,
     Pre => A'First = 0 and then B'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then In_Tier0 (A) and then In_Tier0 (B) and then Count <= A'Length,
     Post => abs Sequential'Result <= Real (Count) * MJ.Vector_Models.Step_Bound,
     Subprogram_Variant => (Decreases => Count);

   procedure Unfold_Sequential (A, B : Real_Array; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => A'First = 0 and then B'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then In_Tier0 (A) and then In_Tier0 (B) and then Count < A'Length,
     Post => Sequential (A, B, Count + 1) = (if A (Count) = 0.0 then Sequential (A, B, Count)
       else MJ.Vector_Models.Model_Add (Sequential (A, B, Count), B (Count) * A (Count), Count));

   function Bilinear (A, B : Real_Array; Count : Size_Type) return Tier2_Real is
     (if Count = 0 then 0.0 else Wide_Add (Bilinear (A, B, Count - 1), A (Count - 1) * B (Count - 1), Count - 1))
   with Ghost => Static, Global => null,
     Pre => A'First = 0 and then B'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then In_Tier0 (A) and then In_Tier1 (B) and then Count <= A'Length,
     Post => abs Bilinear'Result <= Real (Count) * Wide_Step,
     Subprogram_Variant => (Decreases => Count);

   procedure Unfold_Bilinear (A, B : Real_Array; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => A'First = 0 and then B'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then In_Tier0 (A) and then In_Tier1 (B) and then Count < A'Length,
     Post => Bilinear (A, B, Count + 1) = Wide_Add (Bilinear (A, B, Count), A (Count) * B (Count), Count);

   function Weighted (A, B, D : Real_Array; Count : Size_Type) return Tier2_Real is
     (if Count = 0 then 0.0 else (if A (Count - 1) = 0.0 or else D (Count - 1) = 0.0 then Weighted (A, B, D, Count - 1)
       else Wide_Add (Weighted (A, B, D, Count - 1),
         B (Count - 1) * (A (Count - 1) * D (Count - 1)), Count - 1)))
   with Ghost => Static, Global => null,
     Pre => A'First = 0 and then B'First = 0 and then D'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then D'Length = A'Length
       and then In_Tier0 (A) and then In_Tier0 (B) and then In_Tier0 (D) and then Count <= A'Length,
     Post => abs Weighted'Result <= Real (Count) * Wide_Step,
     Subprogram_Variant => (Decreases => Count);

   procedure Unfold_Weighted (A, B, D : Real_Array; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => A'First = 0 and then B'First = 0 and then D'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then D'Length = A'Length
       and then In_Tier0 (A) and then In_Tier0 (B) and then In_Tier0 (D) and then Count < A'Length,
     Post => Weighted (A, B, D, Count + 1) = (if A (Count) = 0.0 or else D (Count) = 0.0 then Weighted (A, B, D, Count)
       else Wide_Add (Weighted (A, B, D, Count),
         B (Count) * (A (Count) * D (Count)), Count));

   function Matrix_Entry (A : Matrix; I, J : Natural) return Tier0_Real with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then J in A'Range (2),
     Post => Matrix_Entry'Result = A (I, J);
   function Weight_Entry (D : Real_Array; I : Natural) return Tier0_Real with
     Ghost => Static, Global => null,
     Pre => In_Tier0 (D) and then I in D'Range,
     Post => Weight_Entry'Result = D (I);

   --  Prefixes refer to the existing vector models; only proof code constructs
   --  projections. Runtime row updates traverse the original dense storage.
   function Product_Prefix (A, B : Matrix; I, J : Natural; Count : Size_Type;
                            Transposed : Boolean) return Tier1_Real is
     (Sequential ((if Transposed then Column (A, I) else Row (A, I)), Column (B, J), Count))
     with Ghost => Static, Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then (if Transposed then A'Length (1) = B'Length (1) and then I in A'Range (2)
                 else A'Length (2) = B'Length (1) and then I in A'Range (1)) and then J in B'Range (2) and then Count <= B'Length (1),
     Post => abs Product_Prefix'Result <= Real (Count) * MJ.Vector_Models.Step_Bound;

   procedure Unfold_Product_Entry (A, B : Matrix; I, J : Natural; Count : Size_Type; Transposed : Boolean) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then (if Transposed then A'Length (1) = B'Length (1) and then I in A'Range (2)
                 else A'Length (2) = B'Length (1) and then I in A'Range (1)) and then Count < B'Length (1) and then J in B'Range (2),
     Post => Product_Prefix (A, B, I, J, Count + 1, Transposed) =
         (if (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count)) = 0.0 then Product_Prefix (A, B, I, J, Count, Transposed)
          else Product_Prefix (A, B, I, J, Count, Transposed) + Matrix_Entry (B, Count, J) * (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count)));

   procedure Unfold_Product_Row (A, B : Matrix; I : Natural; Count : Size_Type;
                                  Transposed : Boolean) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then (if Transposed then A'Length (1) = B'Length (1) and then I in A'Range (2)
                 else A'Length (2) = B'Length (1) and then I in A'Range (1)) and then Count < B'Length (1),
     Post => (for all J in B'Range (2) =>
       Product_Prefix (A, B, I, J, Count + 1, Transposed) =
         (if (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count)) = 0.0 then Product_Prefix (A, B, I, J, Count, Transposed)
          else Product_Prefix (A, B, I, J, Count, Transposed) + Matrix_Entry (B, Count, J) * (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count))));

   function Vector_Prefix (A : Matrix; V : Real_Array; J : Natural; Count : Size_Type) return Tier1_Real is
     (Sequential (V, Column (A, J), Count))
     with Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then V'First = 0
       and then V'Length = A'Length (1) and then In_Tier0 (V) and then J in A'Range (2) and then Count <= A'Length (1),
     Post => abs Vector_Prefix'Result <= Real (Count) * MJ.Vector_Models.Step_Bound;

   procedure Unfold_Vector_Entry (A : Matrix; V : Real_Array; J : Natural; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then V'First = 0
       and then V'Length = A'Length (1) and then In_Tier0 (V) and then J in A'Range (2) and then Count < A'Length (1),
     Post => Vector_Prefix (A, V, J, Count + 1) =
       (if Weight_Entry (V, Count) = 0.0 then Vector_Prefix (A, V, J, Count)
        else Vector_Prefix (A, V, J, Count) + Matrix_Entry (A, Count, J) * Weight_Entry (V, Count));

   procedure Unfold_Vector_Row (A : Matrix; V : Real_Array; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then V'First = 0
       and then V'Length = A'Length (1) and then In_Tier0 (V) and then Count < A'Length (1),
     Post => (for all J in A'Range (2) => Vector_Prefix (A, V, J, Count + 1) =
       (if Weight_Entry (V, Count) = 0.0 then Vector_Prefix (A, V, J, Count)
        else Vector_Prefix (A, V, J, Count) + Matrix_Entry (A, Count, J) * Weight_Entry (V, Count)));

   function Gram_Prefix (A : Matrix; D : Real_Array; I, J : Natural;
                        Count : Size_Type) return Tier2_Real is
     (if D'Length = 0 then Sequential (Column (A, I), Column (A, J), Count)
      else Weighted (Column (A, I), Column (A, J), D, Count))
     with Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (2) and then J in A'Range (2)
       and then Count <= A'Length (1)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D))),
     Post => abs Gram_Prefix'Result <= Real (Count) * Wide_Step;

   procedure Unfold_Gram_Entry (A : Matrix; D : Real_Array; I, J : Natural; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (2) and then Count < A'Length (1)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D))) and then J <= I,
     Post => Gram_Prefix (A, D, I, J, Count + 1) =
       (if Matrix_Entry (A, Count, I) = 0.0 or else (D'Length /= 0 and then Weight_Entry (D, Count) = 0.0)
        then Gram_Prefix (A, D, I, J, Count)
        elsif D'Length = 0 then Gram_Prefix (A, D, I, J, Count) + Matrix_Entry (A, Count, J) * Matrix_Entry (A, Count, I)
        else Gram_Prefix (A, D, I, J, Count) + Matrix_Entry (A, Count, J) * (Matrix_Entry (A, Count, I) * Weight_Entry (D, Count)));

   procedure Unfold_Gram_Row (A : Matrix; D : Real_Array; I : Natural; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (2) and then Count < A'Length (1)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D))),
     Post => (for all J in 0 .. I => Gram_Prefix (A, D, I, J, Count + 1) =
       (if Matrix_Entry (A, Count, I) = 0.0 or else (D'Length /= 0 and then Weight_Entry (D, Count) = 0.0)
        then Gram_Prefix (A, D, I, J, Count)
        elsif D'Length = 0 then Gram_Prefix (A, D, I, J, Count) + Matrix_Entry (A, Count, J) * Matrix_Entry (A, Count, I)
        else Gram_Prefix (A, D, I, J, Count) + Matrix_Entry (A, Count, J) * (Matrix_Entry (A, Count, I) * Weight_Entry (D, Count))));
end MJ.Matrix_Models;

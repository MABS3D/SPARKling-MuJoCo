--  Ordered floating-point models; all ghost code is removed from executables.
with MJ.Types; use MJ.Types;
with MJ.BLAS; use MJ.BLAS;
with MJ.Vector_Models;
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
end MJ.Matrix_Models;

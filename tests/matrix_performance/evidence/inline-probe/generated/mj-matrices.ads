--  Dense matrix kernels matching the pinned MuJoCo floating-point algorithms.
with MJ.Types; use MJ.Types;
with MJ.BLAS;
with MJ.Vector_Models;
with MJ.Matrix_Types; use MJ.Matrix_Types;
with MJ.Matrix_Models;
package MJ.Matrices with SPARK_Mode is
   use MJ.BLAS;
   --  Six scalar inputs keep each arithmetic obligation independent of matrix indexing.
   function Dot_3 (A0, A1, A2, B0, B1, B2 : Tier0_Real) return Tier1_Real with
     Global => null,
     Post => Dot_3'Result = ((A0 * B0) + (A1 * B1)) + (A2 * B2);

   function Copy9 (A : Matrix_3) return Matrix_3 with
     Global => null, Post => Copy9'Result = A;

   procedure MulMatVec3 (R : out MJ.BLAS.Vector_3; A : Matrix_3; V : MJ.BLAS.Vector_3) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => In_Tier0 (A) and then MJ.BLAS.In_Tier0 (V),
     Post => MJ.BLAS.In_Tier1 (R)
       and then R (0) = Dot_3 (A (0, 0), A (0, 1), A (0, 2), V (0), V (1), V (2))
       and then R (1) = Dot_3 (A (1, 0), A (1, 1), A (1, 2), V (0), V (1), V (2))
       and then R (2) = Dot_3 (A (2, 0), A (2, 1), A (2, 2), V (0), V (1), V (2));
   pragma Postcondition (Static => R'Initialized);



   procedure MulMatTVec3 (R : out MJ.BLAS.Vector_3; A : Matrix_3; V : MJ.BLAS.Vector_3) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => In_Tier0 (A) and then MJ.BLAS.In_Tier0 (V),
     Post => MJ.BLAS.In_Tier1 (R)
       and then R (0) = Dot_3 (A (0, 0), A (1, 0), A (2, 0), V (0), V (1), V (2))
       and then R (1) = Dot_3 (A (0, 1), A (1, 1), A (2, 1), V (0), V (1), V (2))
       and then R (2) = Dot_3 (A (0, 2), A (1, 2), A (2, 2), V (0), V (1), V (2));
   pragma Postcondition (Static => R'Initialized);



   subtype Axis is Natural range 0 .. 2;
   function Product3_Component (A, B : Matrix_3; I, J : Axis;
                                Transpose_A, Transpose_B : Boolean) return Tier1_Real with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => Product3_Component'Result = Dot_3
       ((if Transpose_A then A (0, I) else A (I, 0)),
        (if Transpose_A then A (1, I) else A (I, 1)),
        (if Transpose_A then A (2, I) else A (I, 2)),
        (if Transpose_B then B (J, 0) else B (0, J)),
        (if Transpose_B then B (J, 1) else B (1, J)),
        (if Transpose_B then B (J, 2) else B (2, J)));

   function MulMatMat3 (A, B : Matrix_3) return Matrix_3 with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (MulMatMat3'Result)
       and then (for all I in Axis => (for all J in Axis =>
         MulMatMat3'Result (I, J) = Product3_Component (A, B, I, J, False, False)));

   function MulMatTMat3 (A, B : Matrix_3) return Matrix_3 with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (MulMatTMat3'Result)
       and then (for all I in Axis => (for all J in Axis =>
         MulMatTMat3'Result (I, J) = Product3_Component (A, B, I, J, True, False)));

   function MulMatMatT3 (A, B : Matrix_3) return Matrix_3 with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (MulMatMatT3'Result)
       and then (for all I in Axis => (for all J in Axis =>
         MulMatMatT3'Result (I, J) = Product3_Component (A, B, I, J, False, True)));

   function Sequential_Dot (A, B : Real_Array) return Tier1_Real with
     Global => null, Pre => A'First = 0 and then B'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then In_Tier0 (A) and then In_Tier0 (B),
     Post => abs Sequential_Dot'Result <= Real (A'Length) * MJ.Vector_Models.Step_Bound;
   pragma Postcondition (Static => Sequential_Dot'Result = MJ.Matrix_Models.Sequential (A, B, A'Length));

   function Bilinear_Dot (A, B : Real_Array) return Tier2_Real with
     Global => null, Pre => A'First = 0 and then B'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then In_Tier0 (A) and then In_Tier1 (B),
     Post => abs Bilinear_Dot'Result <= Real (A'Length) * MJ.Matrix_Models.Wide_Step;
   pragma Postcondition (Static => Bilinear_Dot'Result = MJ.Matrix_Models.Bilinear (A, B, A'Length));

   function Weighted_Dot (A, B, D : Real_Array) return Tier2_Real with
     Global => null, Pre => A'First = 0 and then B'First = 0 and then D'First = 0 and then A'Length <= Max_Size
       and then B'Length = A'Length and then D'Length = A'Length
       and then In_Tier0 (A) and then In_Tier0 (B) and then In_Tier0 (D),
     Post => abs Weighted_Dot'Result <= Real (A'Length) * MJ.Matrix_Models.Wide_Step;
   pragma Postcondition (Static => Weighted_Dot'Result = MJ.Matrix_Models.Weighted (A, B, D, A'Length));

   procedure MulMatVec (R : out Real_Array; A : Matrix; V : Real_Array) with
     Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V)
       and then R'First = 0 and then R'Last = A'Length (1) - 1,
     Post => In_Tier1 (R);
   pragma Postcondition (Static => (for all I in R'Range =>
     R (I) = MJ.Vector_Models.Dot_Value (Row (A, I), V)));

   procedure MulMatTVec (R : out Real_Array; A : Matrix; V : Real_Array) with
     Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then V'First = 0 and then V'Last = A'Length (1) - 1 and then In_Tier0 (V)
       and then R'First = 0 and then R'Last = A'Length (2) - 1,
     Post => In_Tier1 (R);
   pragma Postcondition (Static => (for all J in R'Range =>
     R (J) = MJ.Matrix_Models.Sequential (V, Column (A, J), V'Length)));

   function Row_Dots (A : Matrix; V : Real_Array) return Real_Array with
     Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V),
     Post => Row_Dots'Result'First = 0 and then Row_Dots'Result'Last = A'Length (1) - 1
       and then In_Tier1 (Row_Dots'Result);
   pragma Postcondition (Static => (for all I in Row_Dots'Result'Range =>
     Row_Dots'Result (I) = MJ.Vector_Models.Dot_Value (Row (A, I), V)));

   function MulVecMatVec (U : Real_Array; A : Matrix; V : Real_Array) return Tier2_Real with
     Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then A'Length (1) = A'Length (2)
       and then U'First = 0 and then U'Last = A'Length (1) - 1 and then In_Tier0 (U)
       and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V);
   pragma Postcondition (Static => MulVecMatVec'Result =
     MJ.Matrix_Models.Bilinear (U, Row_Dots (A, V), U'Length));

   procedure Transpose (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null, Pre => Valid (A)
       and then R'First (1) = 0
       and then R'First (2) = 0
       and then R'Length (1) = A'Length (2)
       and then R'Length (2) = A'Length (1);
   pragma Postcondition (Static => R'Initialized);
   pragma Postcondition ((for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) = A (J, I))));

   function Mean_2 (X, Y : Tier0_Real) return Tier0_Real with
     Global => null, Post => Mean_2'Result = 0.5 * (X + Y);

   function Symmetric_Component (A : Matrix; I, J : Natural) return Tier0_Real with
     Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then A'Length (1) = A'Length (2)
       and then I in A'Range (1) and then J in A'Range (2),
     Post => Symmetric_Component'Result = (if I = J then A (I, J) elsif I > J then Mean_2 (A (I, J), A (J, I)) else Mean_2 (A (J, I), A (I, J)));

   procedure Symmetrize (R : out Matrix; A : Matrix) with
     Relaxed_Initialization => R, Global => null, Pre => Valid (A)
       and then A'Length (1) = A'Length (2)
       and then In_Tier0 (A)
       and then R'First (1) = 0
       and then R'First (2) = 0
       and then R'Length (1) = A'Length (1)
       and then R'Length (2) = A'Length (2), Post => In_Tier0 (R);
   pragma Postcondition (Static => R'Initialized);
   pragma Postcondition ((for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) = Symmetric_Component (A, I, J))));

   procedure Eye (R : out Matrix) with
     Global => null, Pre => R'First (1) = 0
       and then R'First (2) = 0
       and then R'Length (1) = R'Length (2)
       and then R'Length (1) <= Max_Size, Post => In_Tier0 (R);
   pragma Postcondition ((for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) = (if I = J then 1.0 else 0.0))));

   function MatMat_Component (A, B : Matrix; I, J : Natural) return Tier1_Real with
     Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then A'Length (2) = B'Length (1) and then I in A'Range (1) and then J in B'Range (2);
   pragma Postcondition (Static => MatMat_Component'Result = MJ.Matrix_Models.Sequential (Row (A, I), Column (B, J), A'Length (2)));

   procedure MulMatMat (R : out Matrix; A, B : Matrix) with
     Global => null, Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
      
       and then A'Length (2) = B'Length (1)
       and then R'First (1) = 0
       and then R'First (2) = 0
       and then R'Length (1) = A'Length (1)
       and then R'Length (2) = B'Length (2), Post => In_Tier1 (R);
   pragma Postcondition (Static => (for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) = MatMat_Component (A, B, I, J))));

   function TMat_Component (A, B : Matrix; I, J : Natural) return Tier1_Real with
     Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then A'Length (1) = B'Length (1) and then I in A'Range (2) and then J in B'Range (2);
   pragma Postcondition (Static => TMat_Component'Result = MJ.Matrix_Models.Sequential (Column (A, I), Column (B, J), A'Length (1)));

   procedure MulMatTMat (R : out Matrix; A, B : Matrix) with
     Global => null, Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
      
       and then A'Length (1) = B'Length (1)
       and then R'First (1) = 0
       and then R'First (2) = 0
       and then R'Length (1) = A'Length (2)
       and then R'Length (2) = B'Length (2), Post => In_Tier1 (R);
   pragma Postcondition (Static => (for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) = TMat_Component (A, B, I, J))));

   function MatT_Component (A, B : Matrix; I, J : Natural) return Tier1_Real with
     Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then A'Length (2) = B'Length (2) and then I in A'Range (1) and then J in B'Range (1);
   pragma Postcondition (Static => MatT_Component'Result = MJ.Vector_Models.Dot_Value (Row (A, I), Row (B, J)));

   procedure MulMatMatT (R : out Matrix; A, B : Matrix) with
     Inline_Always,
     Relaxed_Initialization => R, Global => null, Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
      
       and then A'Length (2) = B'Length (2)
       and then R'First (1) = 0
       and then R'First (2) = 0
       and then R'Length (1) = A'Length (1)
       and then R'Length (2) = B'Length (1), Post => In_Tier1 (R);
   pragma Postcondition (Static => R'Initialized);
   pragma Postcondition (Static => (for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) = MatT_Component (A, B, I, J))));

   function Gram_Value (X, Y, D : Real_Array) return Tier2_Real with
     Global => null,
     Pre => X'First = 0 and then Y'First = 0 and then X'Length <= Max_Size
       and then X'Length = Y'Length and then In_Tier0 (X) and then In_Tier0 (Y)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = X'Length and then In_Tier0 (D)));
   pragma Postcondition (Static => Gram_Value'Result =
     (if D'Length = 0 then MJ.Matrix_Models.Sequential (X, Y, X'Length)
      else MJ.Matrix_Models.Weighted (X, Y, D, X'Length)));

   function Gram_Component (A : Matrix; D : Real_Array; I, J : Natural;
                            Upper : Boolean) return Tier2_Real with
     Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (2) and then J in A'Range (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)));
   pragma Postcondition (Static => Gram_Component'Result = (if I >= J then Gram_Value (Column (A, I), Column (A, J), D)
        elsif Upper then Gram_Value (Column (A, J), Column (A, I), D) else 0.0));

   --  Empty D means the unweighted Gram matrix. Upper=False leaves the upper triangle zero.
   procedure SqrMatTD (R : out Matrix; A : Matrix; D : Real_Array := []; Upper : Boolean := True) with
     Inline_Always, Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D))),
     Post => In_Tier2 (R);
   pragma Postcondition (Static => (for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) =
       Gram_Component (A, D, I, J, Upper))));

   function Selected (Ind : Int_Array; I : Natural; Through : Integer := Integer'Last) return Boolean is
     (for some K in Ind'Range => K <= Through and then Ind (K) = I)
     with Ghost => Static, Global => null;

   --  Copy into the same row positions, preserving every unselected component.
   --  Repeated indices are permitted and have no extra effect.
   procedure CopyRows (R : in out Matrix; A : Matrix; Ind : Int_Array) with
     Global => null,
     Pre => Valid (A) and then Valid (R)
       and then R'Length (1) = A'Length (1) and then R'Length (2) = A'Length (2)
       and then (for all I of Ind => I in A'Range (1));
   pragma Postcondition (Static => (for all I in R'Range (1) =>
     (for all J in R'Range (2) => R (I, J) = (if Selected (Ind, I) then A (I, J) else R'Old (I, J)))));
end MJ.Matrices;

package body MJ.Matrices with SPARK_Mode is
   use MJ.Matrix_Models;
   function Dot_3 (A0, A1, A2, B0, B1, B2 : Tier0_Real) return Tier1_Real is
   begin
      return ((A0 * B0) + (A1 * B1)) + (A2 * B2);
   end Dot_3;
   function Copy9 (A : Matrix_3) return Matrix_3 is (A);

   function MulMatVec3 (A : Matrix_3; V : MJ.BLAS.Vector_3) return MJ.BLAS.Vector_3 is
     ([Dot_3 (A (0, 0), A (0, 1), A (0, 2), V (0), V (1), V (2)),
       Dot_3 (A (1, 0), A (1, 1), A (1, 2), V (0), V (1), V (2)),
       Dot_3 (A (2, 0), A (2, 1), A (2, 2), V (0), V (1), V (2))]);

   function MulMatTVec3 (A : Matrix_3; V : MJ.BLAS.Vector_3) return MJ.BLAS.Vector_3 is
     ([Dot_3 (A (0, 0), A (1, 0), A (2, 0), V (0), V (1), V (2)),
       Dot_3 (A (0, 1), A (1, 1), A (2, 1), V (0), V (1), V (2)),
       Dot_3 (A (0, 2), A (1, 2), A (2, 2), V (0), V (1), V (2))]);

   function Product3_Component (A, B : Matrix_3; I, J : Axis;
                                Transpose_A, Transpose_B : Boolean) return Tier1_Real is
   begin
      return Dot_3
       ((if Transpose_A then A (0, I) else A (I, 0)),
        (if Transpose_A then A (1, I) else A (I, 1)),
        (if Transpose_A then A (2, I) else A (I, 2)),
        (if Transpose_B then B (J, 0) else B (0, J)),
        (if Transpose_B then B (J, 1) else B (1, J)),
        (if Transpose_B then B (J, 2) else B (2, J)));
   end Product3_Component;

   function MulMatMat3 (A, B : Matrix_3) return Matrix_3 is
     ([[Product3_Component (A, B, 0, 0, False, False),
         Product3_Component (A, B, 0, 1, False, False),
         Product3_Component (A, B, 0, 2, False, False)],
       [Product3_Component (A, B, 1, 0, False, False),
         Product3_Component (A, B, 1, 1, False, False),
         Product3_Component (A, B, 1, 2, False, False)],
       [Product3_Component (A, B, 2, 0, False, False),
         Product3_Component (A, B, 2, 1, False, False),
         Product3_Component (A, B, 2, 2, False, False)]]);

   function MulMatTMat3 (A, B : Matrix_3) return Matrix_3 is
     ([[Product3_Component (A, B, 0, 0, True, False),
         Product3_Component (A, B, 0, 1, True, False),
         Product3_Component (A, B, 0, 2, True, False)],
       [Product3_Component (A, B, 1, 0, True, False),
         Product3_Component (A, B, 1, 1, True, False),
         Product3_Component (A, B, 1, 2, True, False)],
       [Product3_Component (A, B, 2, 0, True, False),
         Product3_Component (A, B, 2, 1, True, False),
         Product3_Component (A, B, 2, 2, True, False)]]);

   function MulMatMatT3 (A, B : Matrix_3) return Matrix_3 is
     ([[Product3_Component (A, B, 0, 0, False, True),
         Product3_Component (A, B, 0, 1, False, True),
         Product3_Component (A, B, 0, 2, False, True)],
       [Product3_Component (A, B, 1, 0, False, True),
         Product3_Component (A, B, 1, 1, False, True),
         Product3_Component (A, B, 1, 2, False, True)],
       [Product3_Component (A, B, 2, 0, False, True),
         Product3_Component (A, B, 2, 1, False, True),
         Product3_Component (A, B, 2, 2, False, True)]]);

   function Small_Product (X, Y : Tier0_Real) return Real with
     Global => null, Post => Small_Product'Result = X * Y and then abs Small_Product'Result <= 1.0e20
   is
   begin
      return X * Y;
   end Small_Product;

   function Wide_Product (X : Tier0_Real; Y : Tier1_Real) return Real with
     Global => null, Post => Wide_Product'Result = X * Y and then abs Wide_Product'Result <= 1.0e40
   is
   begin
      return X * Y;
   end Wide_Product;

   function Triple_Product (X, Y, D : Tier0_Real) return Real with
     Global => null, Post => Triple_Product'Result = Y * (X * D) and then abs Triple_Product'Result <= 1.0e40
   is
   begin
      return Y * (X * D);
   end Triple_Product;

   function Small_Add (Acc, Term : Real; Count : Size_Type) return Tier1_Real with
     Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * MJ.Vector_Models.Step_Bound
       and then abs Term <= 1.0e20,
     Post => Small_Add'Result = Acc + Term
       and then abs Small_Add'Result <= Real (Count + 1) * MJ.Vector_Models.Step_Bound
   is
   begin
      return Acc + Term;
   end Small_Add;

   function Large_Add (Acc, Term : Real; Count : Size_Type) return Tier2_Real with
     Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * Wide_Step
       and then abs Term <= 1.0e40,
     Post => Large_Add'Result = Acc + Term
       and then abs Large_Add'Result <= Real (Count + 1) * Wide_Step
   is
   begin
      return Acc + Term;
   end Large_Add;

   function Sequential_Dot (A, B : Real_Array) return Tier1_Real is
      Acc : Tier1_Real := 0.0;
   begin
      for I in A'Range loop
         Unfold_Sequential (A, B, I);
         if A (I) /= 0.0 then
            Acc := Small_Add (Acc, Small_Product (B (I), A (I)), I);
         end if;
         pragma Loop_Invariant (abs Acc <= Real (I + 1) * MJ.Vector_Models.Step_Bound);
         pragma Loop_Invariant (Static => Acc = Sequential (A, B, I + 1));
      end loop;
      return Acc;
   end Sequential_Dot;

   function Bilinear_Dot (A, B : Real_Array) return Tier2_Real is
      Acc : Tier2_Real := 0.0;
   begin
      for I in A'Range loop
         Unfold_Bilinear (A, B, I);
         Acc := Large_Add (Acc, Wide_Product (A (I), B (I)), I);
         pragma Loop_Invariant (abs Acc <= Real (I + 1) * Wide_Step);
         pragma Loop_Invariant (Static => Acc = Bilinear (A, B, I + 1));
      end loop;
      return Acc;
   end Bilinear_Dot;

   function Weighted_Dot (A, B, D : Real_Array) return Tier2_Real is
      Acc : Tier2_Real := 0.0;
   begin
      for I in A'Range loop
         Unfold_Weighted (A, B, D, I);
         if A (I) /= 0.0 and then D (I) /= 0.0 then
            Acc := Large_Add (Acc, Triple_Product (A (I), B (I), D (I)), I);
         end if;
         pragma Loop_Invariant (abs Acc <= Real (I + 1) * Wide_Step);
         pragma Loop_Invariant (Static => Acc = Weighted (A, B, D, I + 1));
      end loop;
      return Acc;
   end Weighted_Dot;

   procedure MulMatVec (R : out Real_Array; A : Matrix; V : Real_Array) is
   begin
      R := [others => 0.0];
      for I in R'Range loop
         R (I) := MJ.BLAS.Dot (Row (A, I), V);
         pragma Loop_Invariant (In_Tier1 (R));
         pragma Loop_Invariant (Static => (for all K in 0 .. I => R (K) = MJ.Vector_Models.Dot_Value (Row (A, K), V)));
      end loop;
   end MulMatVec;

   procedure MulMatTVec (R : out Real_Array; A : Matrix; V : Real_Array) is
   begin
      R := [others => 0.0];
      for J in R'Range loop
         R (J) := Sequential_Dot (V, Column (A, J));
         pragma Loop_Invariant (In_Tier1 (R));
         pragma Loop_Invariant (Static => (for all K in 0 .. J => R (K) = Sequential (V, Column (A, K), V'Length)));
      end loop;
   end MulMatTVec;

   function Row_Dots (A : Matrix; V : Real_Array) return Real_Array is
      R : Real_Array (0 .. A'Length (1) - 1);
   begin
      MulMatVec (R, A, V);
      return R;
   end Row_Dots;
   function MulVecMatVec (U : Real_Array; A : Matrix; V : Real_Array) return Tier2_Real is
     (Bilinear_Dot (U, Row_Dots (A, V)));

   procedure Transpose (R : out Matrix; A : Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := A (J, I);
            pragma Loop_Invariant ((for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then R (K, L) = A (L, K)))));
         end loop;
         pragma Loop_Invariant ((for all K in 0 .. I =>
           (for all L in R'Range (2) => R (K, L) = A (L, K))));
      end loop;
   end Transpose;

   function Mean_2 (X, Y : Tier0_Real) return Tier0_Real is
   begin
      return 0.5 * (X + Y);
   end Mean_2;

   function Symmetric_Component (A : Matrix; I, J : Natural) return Tier0_Real is
   begin
      if I = J then
         return A (I, J);
      elsif I > J then
         return Mean_2 (A (I, J), A (J, I));
      else
         return Mean_2 (A (J, I), A (I, J));
      end if;
   end Symmetric_Component;

   procedure Symmetrize (R : out Matrix; A : Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := Symmetric_Component (A, I, J);
            pragma Loop_Invariant (In_Tier0 (R));
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then R (K, L) = Symmetric_Component (A, K, L)))));
         end loop;
         pragma Loop_Invariant (In_Tier0 (R));
         pragma Loop_Invariant (Static => (for all K in 0 .. I =>
           (for all L in R'Range (2) => R (K, L) = Symmetric_Component (A, K, L))));
      end loop;
   end Symmetrize;

   procedure Eye (R : out Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := (if I = J then 1.0 else 0.0);
            pragma Loop_Invariant (In_Tier0 (R));
            pragma Loop_Invariant ((for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then R (K, L) = (if K = L then 1.0 else 0.0)))));
         end loop;
         pragma Loop_Invariant (In_Tier0 (R));
         pragma Loop_Invariant ((for all K in 0 .. I =>
           (for all L in R'Range (2) => R (K, L) = (if K = L then 1.0 else 0.0))));
      end loop;
   end Eye;

   function MatMat_Component (A, B : Matrix; I, J : Natural) return Tier1_Real is
   begin
      return Sequential_Dot (Row (A, I), Column (B, J));
   end MatMat_Component;

   procedure MulMatMat (R : out Matrix; A, B : Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := MatMat_Component (A, B, I, J);
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then R (K, L) in Tier1_Real and then R (K, L) = MatMat_Component (A, B, K, L)))));
         end loop;
         pragma Loop_Invariant (Static => (for all K in 0 .. I =>
           (for all L in R'Range (2) => R (K, L) in Tier1_Real and then R (K, L) = MatMat_Component (A, B, K, L))));
      end loop;
   end MulMatMat;

   function TMat_Component (A, B : Matrix; I, J : Natural) return Tier1_Real is
   begin
      return Sequential_Dot (Column (A, I), Column (B, J));
   end TMat_Component;

   procedure MulMatTMat (R : out Matrix; A, B : Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := TMat_Component (A, B, I, J);
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then R (K, L) in Tier1_Real and then R (K, L) = TMat_Component (A, B, K, L)))));
         end loop;
         pragma Loop_Invariant (Static => (for all K in 0 .. I =>
           (for all L in R'Range (2) => R (K, L) in Tier1_Real and then R (K, L) = TMat_Component (A, B, K, L))));
      end loop;
   end MulMatTMat;

   function MatT_Component (A, B : Matrix; I, J : Natural) return Tier1_Real is
   begin
      return MJ.BLAS.Dot (Row (A, I), Row (B, J));
   end MatT_Component;

   function MatT_Row (A, B : Matrix; I : Natural) return Real_Array is
      V : Real_Array (0 .. B'Length (1) - 1) := [others => 0.0];
   begin
      for J in V'Range loop
         V (J) := MatT_Component (A, B, I, J);
         pragma Loop_Invariant (In_Tier1 (V));
         pragma Loop_Invariant (Static => (for all L in 0 .. J =>
           V (L) = MatT_Component (A, B, I, L)));
      end loop;
      return V;
   end MatT_Row;

   procedure Fill_MatT_Row (R : in out Matrix; A, B : Matrix; I : Natural) is
      V : constant Real_Array := MatT_Row (A, B, I);
   begin
      for J in R'Range (2) loop
         R (I, J) := V (J);
         pragma Loop_Invariant (for all K in R'Range (1) =>
           (for all L in R'Range (2) => R (K, L) =
             (if K = I and then L <= J then V (L) else R'Loop_Entry (K, L))));
      end loop;
   end Fill_MatT_Row;

   procedure MulMatMatT (R : out Matrix; A, B : Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         Fill_MatT_Row (R, A, B, I);
         pragma Assert (Static => (for all K in 0 .. I - 1 =>
           (for all L in R'Range (2) =>
             R (K, L) = MatT_Component (A, B, K, L))));
         pragma Loop_Invariant (Static => (for all K in 0 .. I =>
           (for all L in R'Range (2) => R (K, L) in Tier1_Real
            and then R (K, L) = MatT_Component (A, B, K, L))));
      end loop;
   end MulMatMatT;

   function Gram_Value (X, Y, D : Real_Array) return Tier2_Real is
     (if D'Length = 0 then Sequential_Dot (X, Y) else Weighted_Dot (X, Y, D));

   function Gram_Component (A : Matrix; D : Real_Array; I, J : Natural;
                            Upper : Boolean) return Tier2_Real is
   begin
      if I >= J then
         return Gram_Value (Column (A, I), Column (A, J), D);
      elsif Upper then
         return Gram_Value (Column (A, J), Column (A, I), D);
      else
         return 0.0;
      end if;
   end Gram_Component;

   procedure SqrMatTD (R : out Matrix; A : Matrix; D : Real_Array := []; Upper : Boolean := True) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := Gram_Component (A, D, I, J, Upper);
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then
                   R (K, L) in Tier2_Real and then R (K, L) = Gram_Component (A, D, K, L, Upper)))));
         end loop;
         pragma Loop_Invariant (Static => (for all K in 0 .. I =>
           (for all L in R'Range (2) => R (K, L) in Tier2_Real and then R (K, L) = Gram_Component (A, D, K, L, Upper))));
      end loop;
   end SqrMatTD;

   procedure Copy_Row (R : in out Matrix; A : Matrix; I : Natural) with
     Global => null,
     Pre => Valid (A) and then Valid (R) and then I in A'Range (1)
       and then R'Length (1) = A'Length (1) and then R'Length (2) = A'Length (2),
     Post => (for all K in R'Range (1) => (for all L in R'Range (2) =>
       R (K, L) = (if K = I then A (K, L) else R'Old (K, L))))
   is
   begin
      for J in R'Range (2) loop
         R (I, J) := A (I, J);
         pragma Loop_Invariant (for all K in R'Range (1) => (for all L in R'Range (2) =>
           R (K, L) = (if K = I and then L <= J then A (K, L) else R'Loop_Entry (K, L))));
      end loop;
   end Copy_Row;

   procedure CopyRows (R : in out Matrix; A : Matrix; Ind : Int_Array) is
   begin
      for N in Ind'Range loop
         Copy_Row (R, A, Ind (N));
         pragma Loop_Invariant (Static => (for all I in R'Range (1) =>
           (for all J in R'Range (2) => R (I, J) =
             (if Selected (Ind, I, N) then A (I, J) else R'Loop_Entry (I, J)))));
      end loop;
   end CopyRows;
end MJ.Matrices;

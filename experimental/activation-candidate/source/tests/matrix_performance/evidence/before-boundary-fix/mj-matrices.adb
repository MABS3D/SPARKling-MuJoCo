package body MJ.Matrices with SPARK_Mode is
   use MJ.Matrix_Models;
   use MJ.Vector_Models;
   function Dot_3 (A0, A1, A2, B0, B1, B2 : Tier0_Real) return Tier1_Real is
   begin
      return ((A0 * B0) + (A1 * B1)) + (A2 * B2);
   end Dot_3;
   function Copy9 (A : Matrix_3) return Matrix_3 is (A);

   procedure MulMatVec3 (R : out MJ.BLAS.Vector_3; A : Matrix_3; V : MJ.BLAS.Vector_3) is
      X0 : constant Tier1_Real := Dot_3 (A (0, 0), A (0, 1), A (0, 2), V (0), V (1), V (2));
      X1 : constant Tier1_Real := Dot_3 (A (1, 0), A (1, 1), A (1, 2), V (0), V (1), V (2));
      X2 : constant Tier1_Real := Dot_3 (A (2, 0), A (2, 1), A (2, 2), V (0), V (1), V (2));
   begin
      R (0) := X0;
      R (1) := X1;
      R (2) := X2;
   end MulMatVec3;


   procedure MulMatTVec3 (R : out MJ.BLAS.Vector_3; A : Matrix_3; V : MJ.BLAS.Vector_3) is
      X0 : constant Tier1_Real := Dot_3 (A (0, 0), A (1, 0), A (2, 0), V (0), V (1), V (2));
      X1 : constant Tier1_Real := Dot_3 (A (0, 1), A (1, 1), A (2, 1), V (0), V (1), V (2));
      X2 : constant Tier1_Real := Dot_3 (A (0, 2), A (1, 2), A (2, 2), V (0), V (1), V (2));
   begin
      R (0) := X0;
      R (1) := X1;
      R (2) := X2;
   end MulMatTVec3;


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
     Inline_Always, Global => null, Post => Small_Product'Result = X * Y and then abs Small_Product'Result <= 1.0e20
   is
   begin
      return X * Y;
   end Small_Product;

   function Wide_Product (X : Tier0_Real; Y : Tier1_Real) return Real with
     Inline_Always, Global => null, Post => Wide_Product'Result = X * Y and then abs Wide_Product'Result <= 1.0e40
   is
   begin
      return X * Y;
   end Wide_Product;

   function Triple_Product (X, Y, D : Tier0_Real) return Real with
     Inline_Always, Global => null, Post => Triple_Product'Result = Y * (X * D) and then abs Triple_Product'Result <= 1.0e40
   is
   begin
      return Y * (X * D);
   end Triple_Product;

   function Small_Add (Acc, Term : Real; Count : Size_Type) return Tier1_Real with
     Inline_Always, Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * MJ.Vector_Models.Step_Bound
       and then abs Term <= 1.0e20,
     Post => Small_Add'Result = Acc + Term
       and then abs Small_Add'Result <= Real (Count + 1) * MJ.Vector_Models.Step_Bound
   is
   begin
      return Acc + Term;
   end Small_Add;

   function Large_Add (Acc, Term : Real; Count : Size_Type) return Tier2_Real with
     Inline_Always, Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * Wide_Step
       and then abs Term <= 1.0e40,
     Post => Large_Add'Result = Acc + Term
       and then abs Large_Add'Result <= Real (Count + 1) * Wide_Step
   is
   begin
      return Acc + Term;
   end Large_Add;

   procedure Accumulate_Row (R : in out Matrix; B : Matrix;
     Target, Source, Columns : Natural; Scale : Tier0_Real; Count : Size_Type) with
     Inline_Always, Global => null,
     Pre => Valid (B) and then In_Tier0 (B) and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Last (1) < Max_Size and then R'Last (2) < Max_Size
       and then Target in R'Range (1) and then Source in B'Range (1)
       and then Columns <= R'Length (2) and then Columns <= B'Length (2)
       and then Count < Max_Size
       and then (for all J in 0 .. Columns - 1 => abs R (Target, J) <= Real (Count) * MJ.Vector_Models.Step_Bound),
     Post => (Static =>
       (for all J in 0 .. Columns - 1 =>
         abs R (Target, J) <= Real (Count + 1) * MJ.Vector_Models.Step_Bound)
       and then (for all J in 0 .. Columns - 1 =>
         R (Target, J) = Small_Add (R'Old (Target, J), Small_Product (B (Source, J), Scale), Count))
       and then (for all I in R'Range (1) => (for all J in R'Range (2) =>
         R (I, J) = (if I = Target and then J < Columns
           then Small_Add (R'Old (I, J), Small_Product (B (Source, J), Scale), Count) else R'Old (I, J)))))
   is
   begin
      for J in 0 .. Columns - 1 loop
         --  Distinct J values write distinct output cells. SPARK forbids
         --  overlap with the read-only input; source accumulation order
         --  is unchanged. See docs/matrix-performance.md.
         pragma Loop_Optimize (Ivdep, Vector);
         R (Target, J) := Small_Add (R (Target, J), Small_Product (B (Source, J), Scale), Count);
         pragma Loop_Invariant (Static => (for all L in 0 .. J =>
           abs R (Target, L) <= Real (Count + 1) * MJ.Vector_Models.Step_Bound));
         pragma Loop_Invariant (Static => (for all I in R'Range (1) =>
           (for all L in R'Range (2) => R (I, L) =
             (if I = Target and then L <= J then Small_Add (R'Loop_Entry (I, L), Small_Product (B (Source, L), Scale), Count)
              else R'Loop_Entry (I, L)))));
      end loop;
   end Accumulate_Row;



   --  Compiler vector representation preserves the four ordered recurrences.
   type Dot_Lanes is array (Lane_Number) of Lane_Real with Alignment => 32;
   pragma Machine_Attribute (Dot_Lanes, "vector_type");

   function Lane_Add (Acc, Term : Real; Count : Size_Type) return Lane_Real with
     Inline_Always, Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * Step_Bound
       and then abs Term <= 1.0e20,
     Post => Lane_Add'Result = Acc + Term
       and then abs Lane_Add'Result <= Real (Count + 1) * Step_Bound
   is
   begin
      return Acc + Term;
   end Lane_Add;

   function Dot_Combine (L : Dot_Lanes; Tail : Tail_Real) return Tier1_Real with
     Inline_Always, Global => null,
     Post => (Static => Dot_Combine'Result = Combine_Lanes (L (0), L (1), L (2), L (3), Tail))
   is
   begin
      return ((L (0) + L (2)) + (L (1) + L (3))) + Tail;
   end Dot_Combine;

   procedure Prove_Dot_Without_Tail (L : Dot_Lanes) with
     Ghost => Static, Global => null,
     Post => (L (0) + L (2)) + (L (1) + L (3)) =
       Combine_Lanes (L (0), L (1), L (2), L (3), 0.0)
   is
   begin
      null;
   end Prove_Dot_Without_Tail;

   procedure Prove_Dot_Short (Tail : Tail_Real) with
     Ghost => Static, Global => null,
     Post => 0.0 + Tail = Combine_Lanes (0.0, 0.0, 0.0, 0.0, Tail)
   is
   begin
      null;
   end Prove_Dot_Short;

   procedure Prove_Row_No_Tail (A : Matrix; I : Natural; V : Real_Array) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V)
       and then A'Length (2) mod 4 = 0,
     Post => Tail_Sum (Row (A, I), V) = 0.0
   is
   begin
      null;
   end Prove_Row_No_Tail;

   procedure Prove_Rows_No_Tail (A : Matrix; I : Natural; B : Matrix; J : Natural) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1) and then A'Length (2) = B'Length (2)
       and then A'Length (2) mod 4 = 0,
     Post => Tail_Sum (Row (A, I), Row (B, J)) = 0.0
   is
   begin
      null;
   end Prove_Rows_No_Tail;

   function Row_Lane (A : Matrix; I : Natural; V : Real_Array; Count : Block_Count;
                         Lane : Lane_Number; Acc : Lane_Real) return Lane_Real with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V)
       and then Count < A'Length (2) / 4 and then Acc = Lane_Sum (Row (A, I), V, Count, Lane)),
     Post => (Static => Row_Lane'Result = Lane_Sum (Row (A, I), V, Count + 1, Lane))
   is
      K : constant Natural := 4 * Count + Lane;
   begin
      Unfold_Lane (Row (A, I), V, Count, Lane);
      return Lane_Add (Acc, Small_Product (A (I, K), V (K)), Count);
   end Row_Lane;

   function Row_First_Lane (A : Matrix; I : Natural; V : Real_Array;
                            Lane : Lane_Number) return Lane_Real with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then In_Tier0 (A) and then I in A'Range (1)
       and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V)
       and then A'Length (2) >= 4),
     Post => (Static => Row_First_Lane'Result = Lane_Sum (Row (A, I), V, 1, Lane))
   is
   begin
      Unfold_Lane (Row (A, I), V, 0, Lane);
      return Small_Product (A (I, Lane), V (Lane));
   end Row_First_Lane;

   procedure Row_Blocks (A : Matrix; I : Natural; V : Real_Array; R : out Dot_Lanes) with
     Inline_Always, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V),
     Post => (Static => (for all L in Lane_Number => R (L) = Lane_Sum (Row (A, I), V, A'Length (2) / 4, L)))
   is
   begin
      R := [others => 0.0];
      if A'Length (2) >= 4 then
         for L in Lane_Number loop
            pragma Loop_Optimize (Vector);
            R (L) := Row_First_Lane (A, I, V, L);
            pragma Loop_Invariant (Static => (for all K in Lane_Number =>
              R (K) = Lane_Sum (Row (A, I), V, (if K <= L then 1 else 0), K)));
         end loop;
      end if;
      for Block in 1 .. A'Length (2) / 4 - 1 loop
         pragma Loop_Optimize (No_Vector);
         for L in Lane_Number loop
            pragma Loop_Optimize (Vector);
            R (L) := Row_Lane (A, I, V, Block, L, R (L));
            pragma Loop_Invariant (Static => (for all K in Lane_Number =>
              R (K) = Lane_Sum (Row (A, I), V, (if K <= L then Block + 1 else Block), K)));
         end loop;
         pragma Loop_Invariant (Static => (for all L in Lane_Number =>
           R (L) = Lane_Sum (Row (A, I), V, Block + 1, L)));
      end loop;
   end Row_Blocks;

   procedure Prove_Row_Tail (A : Matrix; I : Natural; V : Real_Array; Value : Tail_Real) with
     Ghost => Static, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V) and then Value = (case A'Length (2) mod 4 is when 3 => (Small_Product (A (I, A'Length (2) - 3), V (A'Length (2) - 3)) + Small_Product (A (I, A'Length (2) - 2), V (A'Length (2) - 2))) + Small_Product (A (I, A'Length (2) - 1), V (A'Length (2) - 1)), when 2 => Small_Product (A (I, A'Length (2) - 2), V (A'Length (2) - 2)) + Small_Product (A (I, A'Length (2) - 1), V (A'Length (2) - 1)), when 1 => Small_Product (A (I, A'Length (2) - 1), V (A'Length (2) - 1)), when others => 0.0),
     Post => (Static => Value = Tail_Sum (Row (A, I), V))
   is
      N : constant Size_Type := A'Length (2);
      X : constant Real_Array := Row (A, I) with Ghost => Static;
   begin
      pragma Assert (Static => X'Length = N and then (for all K in X'Range => X (K) = A (I, K)));
      case N mod 4 is
         when 3 =>
            pragma Assert (Static => Tail_Sum (X, V) = (Small_Product (A (I, N - 3), V (N - 3))
                           + Small_Product (A (I, N - 2), V (N - 2)))
                           + Small_Product (A (I, N - 1), V (N - 1)));
            null;
         when 2 =>
            pragma Assert (Static => Tail_Sum (X, V) = Small_Product (A (I, N - 2), V (N - 2))
                           + Small_Product (A (I, N - 1), V (N - 1)));
            null;
         when 1 =>
            pragma Assert (Static => Tail_Sum (X, V) = Small_Product (A (I, N - 1), V (N - 1)));
            null;
         when others =>
            pragma Assert (Static => Tail_Sum (X, V) = 0.0);
            null;
      end case;
   end Prove_Row_Tail;

   function Row_Tail (A : Matrix; I : Natural; V : Real_Array) return Tail_Real with
     Inline_Always, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V),
     Post => (Static => Row_Tail'Result = Tail_Sum (Row (A, I), V))
   is
      Value : Tail_Real;
   begin
      case A'Length (2) mod 4 is
         when 3 => Value := (Small_Product (A (I, A'Length (2) - 3), V (A'Length (2) - 3)) + Small_Product (A (I, A'Length (2) - 2), V (A'Length (2) - 2))) + Small_Product (A (I, A'Length (2) - 1), V (A'Length (2) - 1));
         when 2 => Value := Small_Product (A (I, A'Length (2) - 2), V (A'Length (2) - 2)) + Small_Product (A (I, A'Length (2) - 1), V (A'Length (2) - 1));
         when 1 => Value := Small_Product (A (I, A'Length (2) - 1), V (A'Length (2) - 1));
         when others => Value := 0.0;
      end case;
      Prove_Row_Tail (A, I, V, Value);
      return Value;
   end Row_Tail;

   function Row_Dot (A : Matrix; I : Natural; V : Real_Array) return Tier1_Real with
     Inline_Always, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V),
     Post => (Static => Row_Dot'Result = Dot_Value (Row (A, I), V))
   is
      L : Dot_Lanes;
   begin
      Row_Blocks (A, I, V, L);
      Unfold_Dot (Row (A, I), V);
      if A'Length (2) < 4 then
         pragma Assert (Static => (for all K in Lane_Number => L (K) = 0.0));
         declare
            Tail : constant Tail_Real := Row_Tail (A, I, V);
         begin
            Prove_Dot_Short (Tail);
            return 0.0 + Tail;
         end;
      elsif A'Length (2) mod 4 = 0 then
         Prove_Row_No_Tail (A, I, V);
         Prove_Dot_Without_Tail (L);
         return (L (0) + L (2)) + (L (1) + L (3));
      else
         return Dot_Combine (L, Row_Tail (A, I, V));
      end if;
   end Row_Dot;

   procedure Unfold_Rows_Lane (A : Matrix; I : Natural; B : Matrix; J : Natural;
                               Count : Block_Count; Lane : Lane_Number) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1)
       and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1)
       and then A'Length (2) = B'Length (2) and then Count < A'Length (2) / 4,
     Post => Lane_Sum (Row (A, I), Row (B, J), Count + 1, Lane) =
       Model_Add (Lane_Sum (Row (A, I), Row (B, J), Count, Lane),
         Small_Product (Matrix_Entry (A, I, 4 * Count + Lane),
                        Matrix_Entry (B, J, 4 * Count + Lane)), Count)
   is
      X : constant Real_Array := Row (A, I);
      Y : constant Real_Array := Row (B, J);
   begin
      Unfold_Lane (X, Y, Count, Lane);
   end Unfold_Rows_Lane;

   function Rows_Lane (A : Matrix; I : Natural; B : Matrix; J : Natural; Count : Block_Count;
                         Lane : Lane_Number; Acc : Lane_Real) return Lane_Real with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1) and then A'Length (2) = B'Length (2)
       and then Count < A'Length (2) / 4 and then Acc = Lane_Sum (Row (A, I), Row (B, J), Count, Lane)),
     Post => (Static => Rows_Lane'Result = Lane_Sum (Row (A, I), Row (B, J), Count + 1, Lane))
   is
      K : constant Natural := 4 * Count + Lane;
   begin
      Unfold_Rows_Lane (A, I, B, J, Count, Lane);
      return Lane_Add (Acc, Small_Product (A (I, K), B (J, K)), Count);
   end Rows_Lane;

   function Rows_First_Lane (A : Matrix; I : Natural; B : Matrix; J : Natural;
                             Lane : Lane_Number) return Lane_Real with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then In_Tier0 (A) and then I in A'Range (1)
       and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1)
       and then A'Length (2) = B'Length (2) and then A'Length (2) >= 4),
     Post => (Static => Rows_First_Lane'Result = Lane_Sum (Row (A, I), Row (B, J), 1, Lane))
   is
   begin
      Unfold_Rows_Lane (A, I, B, J, 0, Lane);
      return Small_Product (A (I, Lane), B (J, Lane));
   end Rows_First_Lane;

   procedure Rows_Blocks (A : Matrix; I : Natural; B : Matrix; J : Natural; R : out Dot_Lanes) with
     Inline_Always, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1) and then A'Length (2) = B'Length (2),
     Post => (Static => (for all L in Lane_Number => R (L) = Lane_Sum (Row (A, I), Row (B, J), A'Length (2) / 4, L)))
   is
   begin
      R := [others => 0.0];
      if A'Length (2) >= 4 then
         for L in Lane_Number loop
            pragma Loop_Optimize (Vector);
            R (L) := Rows_First_Lane (A, I, B, J, L);
            pragma Loop_Invariant (Static => (for all K in Lane_Number =>
              R (K) = Lane_Sum (Row (A, I), Row (B, J), (if K <= L then 1 else 0), K)));
         end loop;
      end if;
      for Pair in 0 .. (A'Length (2) / 4 - 1) / 2 - 1 loop
         pragma Loop_Optimize (No_Vector);
         declare
            Block : constant Block_Count := 1 + 2 * Pair;
         begin
            for L in Lane_Number loop
               pragma Loop_Optimize (Vector);
               R (L) := Rows_Lane (A, I, B, J, Block, L, R (L));
               R (L) := Rows_Lane (A, I, B, J, Block + 1, L, R (L));
               pragma Loop_Invariant (Static => (for all K in Lane_Number =>
                 R (K) = Lane_Sum (Row (A, I), Row (B, J),
                   (if K <= L then Block + 2 else Block), K)));
            end loop;
         end;
         pragma Loop_Invariant (Static => (for all L in Lane_Number =>
           R (L) = Lane_Sum (Row (A, I), Row (B, J), 3 + 2 * Pair, L)));
      end loop;
      if A'Length (2) / 4 >= 2 and then (A'Length (2) / 4) mod 2 = 0 then
         for L in Lane_Number loop
            pragma Loop_Optimize (Vector);
            R (L) := Rows_Lane (A, I, B, J, A'Length (2) / 4 - 1, L, R (L));
            pragma Loop_Invariant (Static => (for all K in Lane_Number =>
              R (K) = Lane_Sum (Row (A, I), Row (B, J),
                (if K <= L then A'Length (2) / 4 else A'Length (2) / 4 - 1), K)));
         end loop;
      end if;
   end Rows_Blocks;

   procedure Prove_Rows_Tail (A : Matrix; I : Natural; B : Matrix; J : Natural; Value : Tail_Real) with
     Ghost => Static, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1) and then A'Length (2) = B'Length (2) and then Value = (case A'Length (2) mod 4 is when 3 => (Small_Product (A (I, A'Length (2) - 3), B (J, A'Length (2) - 3)) + Small_Product (A (I, A'Length (2) - 2), B (J, A'Length (2) - 2))) + Small_Product (A (I, A'Length (2) - 1), B (J, A'Length (2) - 1)), when 2 => Small_Product (A (I, A'Length (2) - 2), B (J, A'Length (2) - 2)) + Small_Product (A (I, A'Length (2) - 1), B (J, A'Length (2) - 1)), when 1 => Small_Product (A (I, A'Length (2) - 1), B (J, A'Length (2) - 1)), when others => 0.0),
     Post => (Static => Value = Tail_Sum (Row (A, I), Row (B, J)))
   is
      N : constant Size_Type := A'Length (2);
      X : constant Real_Array := Row (A, I) with Ghost => Static;
      Y : constant Real_Array := Row (B, J) with Ghost => Static;
   begin
      pragma Assert (Static => X'Length = N and then (for all K in X'Range => X (K) = A (I, K)));
      pragma Assert (Static => Y'Length = N and then (for all K in Y'Range => Y (K) = B (J, K)));
      case N mod 4 is
         when 3 =>
            pragma Assert (Static => Tail_Sum (X, Y) = (Small_Product (A (I, N - 3), B (J, N - 3))
                           + Small_Product (A (I, N - 2), B (J, N - 2)))
                           + Small_Product (A (I, N - 1), B (J, N - 1)));
            null;
         when 2 =>
            pragma Assert (Static => Tail_Sum (X, Y) = Small_Product (A (I, N - 2), B (J, N - 2))
                           + Small_Product (A (I, N - 1), B (J, N - 1)));
            null;
         when 1 =>
            pragma Assert (Static => Tail_Sum (X, Y) = Small_Product (A (I, N - 1), B (J, N - 1)));
            null;
         when others =>
            pragma Assert (Static => Tail_Sum (X, Y) = 0.0);
            null;
      end case;
   end Prove_Rows_Tail;

   function Rows_Tail (A : Matrix; I : Natural; B : Matrix; J : Natural) return Tail_Real with
     Inline_Always, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1) and then A'Length (2) = B'Length (2),
     Post => (Static => Rows_Tail'Result = Tail_Sum (Row (A, I), Row (B, J)))
   is
      Value : Tail_Real;
   begin
      case A'Length (2) mod 4 is
         when 3 => Value := (Small_Product (A (I, A'Length (2) - 3), B (J, A'Length (2) - 3)) + Small_Product (A (I, A'Length (2) - 2), B (J, A'Length (2) - 2))) + Small_Product (A (I, A'Length (2) - 1), B (J, A'Length (2) - 1));
         when 2 => Value := Small_Product (A (I, A'Length (2) - 2), B (J, A'Length (2) - 2)) + Small_Product (A (I, A'Length (2) - 1), B (J, A'Length (2) - 1));
         when 1 => Value := Small_Product (A (I, A'Length (2) - 1), B (J, A'Length (2) - 1));
         when others => Value := 0.0;
      end case;
      Prove_Rows_Tail (A, I, B, J, Value);
      return Value;
   end Rows_Tail;

   function Rows_Dot_Short (A : Matrix; I : Natural; B : Matrix; J : Natural) return Tier1_Real with
     Inline_Always, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1) and then A'Length (2) = B'Length (2) and then A'Length (2) < 4,
     Post => (Static => Rows_Dot_Short'Result = Dot_Value (Row (A, I), Row (B, J)))
   is
      Tail : constant Tail_Real := Rows_Tail (A, I, B, J);
   begin
      Unfold_Dot (Row (A, I), Row (B, J));
      Prove_Dot_Short (Tail);
      return 0.0 + Tail;
   end Rows_Dot_Short;

   function Rows_Dot (A : Matrix; I : Natural; B : Matrix; J : Natural) return Tier1_Real with
     Inline_Always, Global => null, Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (1) and then Valid (B) and then In_Tier0 (B) and then J in B'Range (1) and then A'Length (2) = B'Length (2),
     Post => (Static => Rows_Dot'Result = Dot_Value (Row (A, I), Row (B, J)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Vector_Models.Dot_Value);
      L : Dot_Lanes;
   begin
      Rows_Blocks (A, I, B, J, L);
      Unfold_Dot (Row (A, I), Row (B, J));
      if A'Length (2) < 4 then
         pragma Assert (Static => (for all K in Lane_Number => L (K) = 0.0));
         declare
            Tail : constant Tail_Real := Rows_Tail (A, I, B, J);
         begin
            Prove_Dot_Short (Tail);
            return 0.0 + Tail;
         end;
      elsif A'Length (2) mod 4 = 0 then
         Prove_Rows_No_Tail (A, I, B, J);
         Prove_Dot_Without_Tail (L);
         return (L (0) + L (2)) + (L (1) + L (3));
      else
         return Dot_Combine (L, Rows_Tail (A, I, B, J));
      end if;
   end Rows_Dot;

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

   procedure MulMatVec_Core (R : out Real_Array; A : Matrix; V : Real_Array) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then R'First = 0 and then R'Last = A'Length (1) - 1
       and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V),
     Post => (Static => R'Initialized and then In_Tier1 (R)
       and then (for all I in R'Range => R (I) = Dot_Value (Row (A, I), V)))
   is
   begin
      for I in R'Range loop
         R (I) := Row_Dot (A, I, V);
         pragma Loop_Invariant (Static => (for all K in 0 .. I => R (K)'Initialized));
         pragma Loop_Invariant (Static => (for all K in 0 .. I =>
           R (K)'Initialized and then R (K) in Tier1_Real
           and then R (K) = Dot_Value (Row (A, K), V)));
      end loop;
   end MulMatVec_Core;

   procedure MulMatVec (R : out Real_Array; A : Matrix; V : Real_Array) is
   begin
      MulMatVec_Core (R, A, V);
   end MulMatVec;

   procedure Accumulate_Vector_Row (R : in out Real_Array; A : Matrix;
                                    Source : Natural; Scale : Tier0_Real; Count : Size_Type) with
     Inline_Always, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then Source in A'Range (1)
       and then R'First = 0 and then R'Length = A'Length (2) and then Count < Max_Size
       and then (for all J in R'Range => abs R (J) <= Real (Count) * Step_Bound),
     Post => (Static =>
       (for all J in R'Range => abs R (J) <= Real (Count + 1) * Step_Bound
         and then R (J) = Small_Add (R'Old (J), Small_Product (A (Source, J), Scale), Count)))
   is
   begin
      for J in R'Range loop
         R (J) := Small_Add (R (J), Small_Product (A (Source, J), Scale), Count);
         pragma Loop_Invariant (Static => (for all L in R'Range =>
           (if L <= J then abs R (L) <= Real (Count + 1) * Step_Bound
             and then R (L) = Small_Add (R'Loop_Entry (L), Small_Product (A (Source, L), Scale), Count)
            else R (L) = R'Loop_Entry (L))));
      end loop;
   end Accumulate_Vector_Row;

   procedure MulMatTVec (R : out Real_Array; A : Matrix; V : Real_Array) is
   begin
      R := [others => 0.0];
      for K in A'Range (1) loop
         Unfold_Vector_Row (A, V, K);
         if V (K) /= 0.0 then
            Accumulate_Vector_Row (R, A, K, V (K), K);
         end if;
         pragma Loop_Invariant (Static => (for all J in R'Range => R (J) = Vector_Prefix (A, V, J, K + 1)));
      end loop;
   end MulMatTVec;

   function Row_Dots (A : Matrix; V : Real_Array) return Real_Array is
      R : Real_Array (0 .. A'Length (1) - 1);
   begin
      MulMatVec (R, A, V);
      return R;
   end Row_Dots;
   function Bilinear_Prefix (U : Real_Array; A : Matrix; V : Real_Array; Count : Size_Type) return Tier2_Real is
     (Bilinear (U, Row_Dots (A, V), Count))
     with Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then A'Length (1) = A'Length (2) and then U'First = 0 and then U'Last = A'Length (1) - 1 and then In_Tier0 (U) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V) and then Count <= U'Length,
     Post => abs Bilinear_Prefix'Result <= Real (Count) * Wide_Step;

   procedure Unfold_Bilinear_Matrix (U : Real_Array; A : Matrix; V : Real_Array; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then A'Length (1) = A'Length (2) and then U'First = 0 and then U'Last = A'Length (1) - 1 and then In_Tier0 (U) and then V'First = 0 and then V'Last = A'Length (2) - 1 and then In_Tier0 (V) and then Count < U'Length,
     Post => Bilinear_Prefix (U, A, V, Count + 1) =
       Wide_Add (Bilinear_Prefix (U, A, V, Count), Wide_Product (Weight_Entry (U, Count), Row_Dot (A, Count, V)), Count)
   is
      Dots : constant Real_Array := Row_Dots (A, V);
   begin
      pragma Assert (Dots (Count) = Row_Dot (A, Count, V));
      Unfold_Bilinear (U, Dots, Count);
   end Unfold_Bilinear_Matrix;

   function MulVecMatVec (U : Real_Array; A : Matrix; V : Real_Array) return Tier2_Real is
      Acc : Tier2_Real := 0.0;
   begin
      for I in U'Range loop
         Unfold_Bilinear_Matrix (U, A, V, I);
         Acc := Large_Add (Acc, Wide_Product (U (I), Row_Dot (A, I, V)), I);
         pragma Loop_Invariant (abs Acc <= Real (I + 1) * Wide_Step);
         pragma Loop_Invariant (Static => Acc = Bilinear_Prefix (U, A, V, I + 1));
      end loop;
      return Acc;
   end MulVecMatVec;

   procedure Transpose_Core (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => Valid (A) and then R'First (1) = 0 and then R'First (2) = 0 and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (1),
     Post => (Static => R'Initialized and then (for all K in R'Range (1) => (for all L in R'Range (2) => R (K, L) = A (L, K))))
   is
   begin
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            R (I, J) := A (J, I);
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) => (if K < I or else (K = I and then L <= J) then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
         end loop;
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
      end loop;
   end Transpose_Core;

   --  Keep this loop distinct from the general core: the Vector hint helps
   --  medium square matrices, but need not help rectangular or larger copies.
   procedure Transpose_Vector_Core (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => Valid (A) and then R'First (1) = 0 and then R'First (2) = 0 and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (1),
     Post => (Static => R'Initialized and then (for all K in R'Range (1) => (for all L in R'Range (2) => R (K, L) = A (L, K))))
   is
   begin
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            pragma Loop_Optimize (Vector);
            R (I, J) := A (J, I);
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) => (if K < I or else (K = I and then L <= J) then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
         end loop;
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
      end loop;
   end Transpose_Vector_Core;

   --  Constant row counts expose fixed output strides before the copy loop.
   --  For two to four rows, avoid the setup cost of a wider loop transform.
   procedure Transpose_1_Row (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => A'Length (1) = 1 and then Valid (A) and then R'First (1) = 0 and then R'First (2) = 0 and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (1),
     Post => (Static => R'Initialized and then (for all K in R'Range (1) => (for all L in R'Range (2) => R (K, L) = A (L, K))))
   is
   begin
      for I in R'Range (1) loop
         R (I, 0) := A (0, I);
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
      end loop;
   end Transpose_1_Row;

   procedure Transpose_2_Rows (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => A'Length (1) = 2 and then Valid (A) and then R'First (1) = 0 and then R'First (2) = 0 and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (1),
     Post => (Static => R'Initialized and then (for all K in R'Range (1) => (for all L in R'Range (2) => R (K, L) = A (L, K))))
   is
   begin
      for I in R'Range (1) loop
         pragma Loop_Optimize (No_Vector);
         R (I, 0) := A (0, I);
         R (I, 1) := A (1, I);
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
      end loop;
   end Transpose_2_Rows;

   procedure Transpose_3_Rows (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => A'Length (1) = 3 and then Valid (A) and then R'First (1) = 0 and then R'First (2) = 0 and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (1),
     Post => (Static => R'Initialized and then (for all K in R'Range (1) => (for all L in R'Range (2) => R (K, L) = A (L, K))))
   is
   begin
      for I in R'Range (1) loop
         pragma Loop_Optimize (No_Vector);
         R (I, 0) := A (0, I);
         R (I, 1) := A (1, I);
         R (I, 2) := A (2, I);
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
      end loop;
   end Transpose_3_Rows;

   procedure Transpose_4_Rows (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => A'Length (1) = 4 and then Valid (A) and then R'First (1) = 0 and then R'First (2) = 0 and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (1),
     Post => (Static => R'Initialized and then (for all K in R'Range (1) => (for all L in R'Range (2) => R (K, L) = A (L, K))))
   is
   begin
      for I in R'Range (1) loop
         pragma Loop_Optimize (No_Vector);
         R (I, 0) := A (0, I);
         R (I, 1) := A (1, I);
         R (I, 2) := A (2, I);
         R (I, 3) := A (3, I);
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
      end loop;
   end Transpose_4_Rows;

   --  Copy a pair per step and then the odd row, preserving every component.
   procedure Transpose_Pairs (R : out Matrix; A : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => Valid (A) and then R'First (1) = 0 and then R'First (2) = 0 and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (1),
     Post => (Static => R'Initialized and then (for all K in R'Range (1) => (for all L in R'Range (2) => R (K, L) = A (L, K))))
   is
   begin
      for I in R'Range (1) loop
         for J in 0 .. R'Length (2) / 2 - 1 loop
            pragma Loop_Optimize (No_Vector);
            R (I, 2 * J) := A (2 * J, I);
            R (I, 2 * J + 1) := A (2 * J + 1, I);
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L < 2 * (J + 1)) then
                  R (K, L)'Initialized and then R (K, L) = A (L, K)))));
         end loop;
         if R'Length (2) mod 2 = 1 then
            R (I, R'Last (2)) := A (R'Last (2), I);
         end if;
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) =>
             (if K <= I then R (K, L)'Initialized and then R (K, L) = A (L, K)))));
      end loop;
   end Transpose_Pairs;

   procedure Transpose (R : out Matrix; A : Matrix) is
   begin
      if A'Length (1) = 0 or else A'Length (2) = 0 then
         return;
      end if;
      --  All paths prove the same relation; these thresholds select code shape
      --  only. Their performance is measured for the supported native build.
      case A'Length (1) is
         when 1 => Transpose_1_Row (R, A);
         when 2 => Transpose_2_Rows (R, A);
         when 3 => Transpose_3_Rows (R, A);
         when 4 => Transpose_4_Rows (R, A);
         when 5 .. 15 => Transpose_Pairs (R, A);
         when 16 .. 64 =>
            if A'Length (1) = A'Length (2) then
               Transpose_Vector_Core (R, A);
            else
               Transpose_Core (R, A);
            end if;
         when others => Transpose_Core (R, A);
      end case;
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
      for I in R'Range (1) loop
         R (I, I) := A (I, I);
         for J in 0 .. I - 1 loop
            R (I, J) := Symmetric_Component (A, I, J);
            R (J, I) := R (I, J);
            pragma Loop_Invariant (Static => R (I, I)'Initialized);
            pragma Loop_Invariant (Static => (for all K in 0 .. I - 1 => (for all L in 0 .. I - 1 => R (K, L)'Initialized)));
            pragma Loop_Invariant (Static => (for all L in 0 .. J => R (I, L)'Initialized and then R (L, I)'Initialized));
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) => (if (K < I and then L < I) or else (K = I and then L <= J) or else (L = I and then K <= J) or else (K = I and then L = I) then R (K, L)'Initialized and then R (K, L) in Tier0_Real and then R (K, L) = Symmetric_Component (A, K, L)))));
         end loop;
         pragma Loop_Invariant (Static => (for all K in 0 .. I => (for all L in 0 .. I => R (K, L)'Initialized)));
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I and then L <= I then R (K, L)'Initialized and then R (K, L) in Tier0_Real and then R (K, L) = Symmetric_Component (A, K, L)))));
      end loop;
   end Symmetrize;

   procedure Eye (R : out Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         R (I, I) := 1.0;
         pragma Loop_Invariant (In_Tier0 (R));
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) =>
             R (K, L) = (if K = L and then K <= I then 1.0 else 0.0))));
      end loop;
   end Eye;

   procedure Prove_Product_Cell (A, B : Matrix; I, J : Natural; Count : Size_Type; Transposed : Boolean; Previous, Current : Real) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B) and then (if Transposed then A'Length (1) = B'Length (1) and then I in A'Range (2) else A'Length (2) = B'Length (1) and then I in A'Range (1)) and then J in B'Range (2) and then Count < B'Length (1)
       and then Previous = Product_Prefix (A, B, I, J, Count, Transposed)
       and then Current = (if (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count)) = 0.0 then Previous
        else Small_Add (Previous, Small_Product (Matrix_Entry (B, Count, J),
          (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count))), Count)),
     Post => Current = Product_Prefix (A, B, I, J, Count + 1, Transposed)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Product_Prefix);
   begin
      Unfold_Product_Entry (A, B, I, J, Count, Transposed);
   end Prove_Product_Cell;

   procedure Product_Step (R : in out Matrix; A, B : Matrix; I : Natural; Count : Size_Type; Transposed : Boolean) with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then (if Transposed then R'Length (1) = A'Length (2) and then A'Length (1) = B'Length (1)
                 else R'Length (1) = A'Length (1) and then A'Length (2) = B'Length (1))
       and then R'Length (2) = B'Length (2) and then I in R'Range (1)
       and then Count < B'Length (1) and then (for all J in R'Range (2) => R (I, J) = Product_Prefix (A, B, I, J, Count, Transposed))
       and then (for all J in R'Range (2) => abs R (I, J) <= Real (Count) * Step_Bound)),
     Post => (Static => (for all J in R'Range (2) => abs R (I, J) <= Real (Count + 1) * Step_Bound)
       and then (for all J in R'Range (2) => R (I, J) = Product_Prefix (A, B, I, J, Count + 1, Transposed))
       and then (for all Row_Index in R'Range (1) => (for all J in R'Range (2) =>
         (if Row_Index /= I then R (Row_Index, J) = R'Old (Row_Index, J)))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Product_Prefix);
      Scale : Tier0_Real;
   begin
      for J in R'Range (2) loop
         Prove_Product_Cell (A, B, I, J, Count, Transposed, R (I, J), (if (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count)) = 0.0 then R (I, J)
        else Small_Add (R (I, J), Small_Product (Matrix_Entry (B, Count, J),
          (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count))), Count)));
         pragma Loop_Invariant (Static => (for all L in 0 .. J =>
           (if (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count)) = 0.0 then R (I, L)
        else Small_Add (R (I, L), Small_Product (Matrix_Entry (B, Count, L),
          (if Transposed then Matrix_Entry (A, Count, I) else Matrix_Entry (A, I, Count))), Count)) = Product_Prefix (A, B, I, L, Count + 1, Transposed)));
      end loop;
      Unfold_Product_Row (A, B, I, Count, Transposed);
      Scale := (if Transposed then A (Count, I) else A (I, Count));
      if Scale /= 0.0 then
         Accumulate_Row (R, B, I, Count, R'Length (2), Scale, Count);
      end if;
   end Product_Step;

   procedure Product_Row (R : in out Matrix; A, B : Matrix; I : Natural;
                          Transposed : Boolean) with
     Inline_Always, Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then (if Transposed then R'Length (1) = A'Length (2) and then A'Length (1) = B'Length (1)
                 else R'Length (1) = A'Length (1) and then A'Length (2) = B'Length (1))
       and then R'Length (2) = B'Length (2) and then I in R'Range (1)
       and then (for all J in R'Range (2) => R (I, J) = 0.0),
     Post => (Static => (for all K in R'Range (1) => (for all J in R'Range (2) =>
       (if K = I then R (K, J) in Tier1_Real and then R (K, J) =
          (if Transposed then TMat_Component (A, B, K, J) else MatMat_Component (A, B, K, J))
        else R (K, J) = R'Old (K, J)))))
   is
   begin
      for K in B'Range (1) loop
         Product_Step (R, A, B, I, K, Transposed);
         pragma Loop_Invariant (Static => (for all J in R'Range (2) => abs R (I, J) <= Real (K + 1) * Step_Bound));
         pragma Loop_Invariant (Static => (for all J in R'Range (2) =>
           R (I, J) = Product_Prefix (A, B, I, J, K + 1, Transposed)));
         pragma Loop_Invariant (Static => (for all Row_Index in R'Range (1) =>
           (for all J in R'Range (2) =>
             (if Row_Index /= I then R (Row_Index, J) = R'Loop_Entry (Row_Index, J)))));
      end loop;
   end Product_Row;

   function MatMat_Component (A, B : Matrix; I, J : Natural) return Tier1_Real is
   begin
      return Sequential_Dot (Row (A, I), Column (B, J));
   end MatMat_Component;

   procedure MulMatMat (R : out Matrix; A, B : Matrix) is
   begin
      R := [others => [others => 0.0]];
      for I in R'Range (1) loop
         Product_Row (R, A, B, I, False);
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all J in R'Range (2) =>
             (if K <= I then R (K, J) in Tier1_Real and then R (K, J) = MatMat_Component (A, B, K, J)
              else R (K, J) = 0.0))));
      end loop;
   end MulMatMat;

   function TMat_Component (A, B : Matrix; I, J : Natural) return Tier1_Real is
   begin
      return Sequential_Dot (Column (A, I), Column (B, J));
   end TMat_Component;

   --  Visit one source row across all output rows. Every cell still
   --  accumulates source indices in ascending order.
   procedure Transposed_Sweep (R : in out Matrix; A, B : Matrix; Count : Size_Type) with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then A'Length (1) = B'Length (1)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = B'Length (2)
       and then Count < B'Length (1) and then (for all I in R'Range (1) => (for all J in R'Range (2) => R (I, J) = Product_Prefix (A, B, I, J, Count, True) and then abs R (I, J) <= Real (Count) * Step_Bound))),
     Post => (Static => (for all I in R'Range (1) => (for all J in R'Range (2) => R (I, J) = Product_Prefix (A, B, I, J, Count + 1, True) and then abs R (I, J) <= Real (Count + 1) * Step_Bound)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Product_Prefix);
   begin
      for Row_Index in R'Range (1) loop
         Product_Step (R, A, B, Row_Index, Count, True);
         pragma Loop_Invariant (Static => (for all I in R'Range (1) => (for all J in R'Range (2) => R (I, J) = Product_Prefix (A, B, I, J, (if I <= Row_Index then Count + 1 else Count), True) and then abs R (I, J) <= Real ((if I <= Row_Index then Count + 1 else Count)) * Step_Bound)));
      end loop;
   end Transposed_Sweep;

   procedure MulMatTMat (R : out Matrix; A, B : Matrix) is
   begin
      R := [others => [others => 0.0]];
      for K in B'Range (1) loop
         Transposed_Sweep (R, A, B, K);
         pragma Loop_Invariant (Static => (for all I in R'Range (1) => (for all J in R'Range (2) => R (I, J) = Product_Prefix (A, B, I, J, K + 1, True) and then abs R (I, J) <= Real (K + 1) * Step_Bound)));
      end loop;
   end MulMatTMat;

   function MatT_Component (A, B : Matrix; I, J : Natural) return Tier1_Real is
   begin
      return Rows_Dot (A, I, B, J);
   end MatT_Component;

   procedure MulMatMatT_Short (R : out Matrix; A, B : Matrix) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => Valid (A) and then Valid (B) and then In_Tier0 (A) and then In_Tier0 (B)
       and then A'Length (2) = B'Length (2) and then A'Length (2) <= 4
       and then R'First (1) = 0
       and then R'First (2) = 0
       and then R'Length (1) = A'Length (1)
       and then R'Length (2) = B'Length (1),
     Post => (Static => R'Initialized and then In_Tier1 (R)
       and then (for all I in R'Range (1) =>
         (for all J in R'Range (2) => R (I, J) = MatT_Component (A, B, I, J))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Vector_Models.Dot_Value);
   begin
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            pragma Loop_Optimize (No_Vector);
            if A'Length (2) = 4 then
               R (I, J) := Rows_Dot (A, I, B, J);
            else
               R (I, J) := Rows_Dot_Short (A, I, B, J);
            end if;
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then R (K, L)'Initialized))));
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) =>
                (if K < I or else (K = I and then L <= J) then R (K, L) in Tier1_Real))));
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) => (if K < I or else (K = I and then L <= J) then R (K, L)'Initialized and then R (K, L) in Tier1_Real and then R (K, L) = MatT_Component (A, B, K, L)))));
         end loop;
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized))));
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L) in Tier1_Real))));
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) in Tier1_Real and then R (K, L) = MatT_Component (A, B, K, L)))));
      end loop;
   end MulMatMatT_Short;

   procedure MulMatMatT (R : out Matrix; A, B : Matrix) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Vector_Models.Dot_Value);
   begin
      --  Empty outputs need no row-stride dispatch or dot-product setup.
      if R'Length (1) = 0 or else R'Length (2) = 0 then
         return;
      end if;
      --  Separate arms let inlining specialize the short row stride and tail
      --  once, before the output loops. The general reduction stays unchanged.
      case A'Length (2) is
         when 0 => MulMatMatT_Short (R, A, B);
         when 1 => MulMatMatT_Short (R, A, B);
         when 2 => MulMatMatT_Short (R, A, B);
         when 3 => MulMatMatT_Short (R, A, B);
         when 4 => MulMatMatT_Short (R, A, B);
         when others =>
            for I in R'Range (1) loop
               for J in R'Range (2) loop
                  R (I, J) := MatT_Component (A, B, I, J);
                  pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
                    (for all L in R'Range (2) => (if K < I or else (K = I and then L <= J) then R (K, L)'Initialized and then R (K, L) in Tier1_Real and then R (K, L) = MatT_Component (A, B, K, L)))));
               end loop;
               pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
                 (for all L in R'Range (2) => (if K <= I then R (K, L)'Initialized and then R (K, L) in Tier1_Real and then R (K, L) = MatT_Component (A, B, K, L)))));
            end loop;
      end case;
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

   --  Expose the scalar arithmetic before connecting it to matrix prefixes.
   procedure Prove_Weighted_Update
     (Left, Right, Weight : Tier0_Real; Count : Size_Type;
      Previous, Current : Real) with
     Ghost => Static, Global => null,
     Pre => Count < Max_Size and then abs Previous <= Real (Count) * Wide_Step
       and then Current = Large_Add
         (Previous, Wide_Product (Right, Small_Product (Left, Weight)), Count),
     Post => Current = Previous + Right * (Left * Weight)
   is
      Scale : constant Tier1_Real := Small_Product (Left, Weight);
      Term : constant Real := Wide_Product (Right, Scale);
      Updated : constant Tier2_Real := Large_Add (Previous, Term, Count);
   begin
      pragma Assert (Scale = Left * Weight);
      pragma Assert (Term = Right * (Left * Weight));
      pragma Assert (Current = Updated);
   end Prove_Weighted_Update;

   procedure Prove_Gram_Cell (A : Matrix; D : Real_Array; I, J : Natural; Count : Size_Type; Previous, Current : Real) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (2) and then J <= I and then Count < A'Length (1) and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then Previous = Gram_Prefix (A, D, I, J, Count)
       and then abs Previous <= Real (Count) * Wide_Step
       and then Current = (if Matrix_Entry (A, Count, I) = 0.0 or else (D'Length /= 0 and then Weight_Entry (D, Count) = 0.0) then Previous
        else Large_Add (Previous, Wide_Product (Matrix_Entry (A, Count, J),
          (if D'Length = 0 then Matrix_Entry (A, Count, I)
           else Small_Product (Matrix_Entry (A, Count, I), Weight_Entry (D, Count)))), Count)),
     Post => Current = Gram_Prefix (A, D, I, J, Count + 1)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      if Matrix_Entry (A, Count, I) = 0.0 or else (D'Length /= 0 and then Weight_Entry (D, Count) = 0.0) then
         pragma Assert (Current = Previous);
         Unfold_Gram_Entry (A, D, I, J, Count);
         pragma Assert (Current = Gram_Prefix (A, D, I, J, Count + 1));
      elsif D'Length = 0 then
         pragma Assert (Current = Previous + Matrix_Entry (A, Count, J) * Matrix_Entry (A, Count, I));
         Unfold_Gram_Entry (A, D, I, J, Count);
         pragma Assert (Current = Gram_Prefix (A, D, I, J, Count + 1));
      else
         Prove_Weighted_Update (Matrix_Entry (A, Count, I), Matrix_Entry (A, Count, J),
           Weight_Entry (D, Count), Count, Previous, Current);
         pragma Assert (Current = Previous + Matrix_Entry (A, Count, J) * (Matrix_Entry (A, Count, I) * Weight_Entry (D, Count)));
         Unfold_Gram_Entry (A, D, I, J, Count);
         pragma Assert (Current = Gram_Prefix (A, D, I, J, Count + 1));
      end if;
   end Prove_Gram_Cell;

   --  Runtime row update is proved independently of the prefix model.
   procedure Advance_Wide_Bound (Value : Real; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => Count < Max_Size and then abs Value <= Real (Count) * Wide_Step,
     Post => abs Value <= Real (Count + 1) * Wide_Step
   is
   begin
      null;
   end Advance_Wide_Bound;

   procedure Gram_Update_Row (R : in out Matrix; A : Matrix; D : Real_Array;
                              I : Natural; Count : Size_Type) with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then I in R'Range (1)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then Count < A'Length (1)
       and then (for all J in 0 .. I => abs R (I, J) <= Real (Count) * Wide_Step))
   is
      pragma Postcondition (Static => (for all J in 0 .. I => abs R (I, J) <= Real (Count + 1) * Wide_Step));
      pragma Postcondition (Static => (for all J in 0 .. I => R (I, J) = (if A (Count, I) = 0.0 or else
           (D'Length /= 0 and then D (Count) = 0.0) then R'Old (I, J)
          else Large_Add (R'Old (I, J), Wide_Product (A (Count, J),
            (if D'Length = 0 then A (Count, I)
             else Small_Product (A (Count, I), D (Count)))), Count))));
      pragma Postcondition (Static => (for all Row_Index in R'Range (1) =>
         (if Row_Index /= I then (for all J in R'Range (2) => R (Row_Index, J) = R'Old (Row_Index, J)))));
      pragma Postcondition (Static => (for all J in I + 1 .. R'Last (2) => R (I, J) = R'Old (I, J)));
      Scale : Tier1_Real;
   begin
      for J in 0 .. I loop
         Advance_Wide_Bound (R (I, J), Count);
         pragma Loop_Invariant (Static => (for all L in 0 .. J =>
           abs R (I, L) <= Real (Count + 1) * Wide_Step));
      end loop;
      if A (Count, I) /= 0.0 and then (D'Length = 0 or else D (Count) /= 0.0) then
         Scale := (if D'Length = 0 then A (Count, I)
                   else Small_Product (A (Count, I), D (Count)));
         for J in 0 .. I loop
            --  Distinct J values write distinct output cells. SPARK forbids
            --  overlap with the read-only input; source accumulation order
            --  is unchanged. See docs/matrix-performance.md.
            pragma Loop_Optimize (Ivdep, Vector);
            R (I, J) := Large_Add (R (I, J), Wide_Product (A (Count, J), Scale), Count);
            pragma Loop_Invariant (Static => (for all L in 0 .. J =>
              abs R (I, L) <= Real (Count + 1) * Wide_Step));
            pragma Loop_Invariant (Static => (for all L in R'Range (2) =>
              R (I, L) = (if L <= J then
                Large_Add (R'Loop_Entry (I, L), Wide_Product (A (Count, L), Scale), Count)
                else R'Loop_Entry (I, L))));
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (if K /= I then (for all L in R'Range (2) => R (K, L) = R'Loop_Entry (K, L)))));
         end loop;
      end if;
      pragma Assert (Static => (for all J in 0 .. I => abs R (I, J) <= Real (Count + 1) * Wide_Step));
   end Gram_Update_Row;

   procedure Gram_Step (R : in out Matrix; A : Matrix; D : Real_Array; I : Natural; Count : Size_Type) with
     Inline_Always, Global => null,
     Pre => (Static => Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then I in R'Range (1)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then Count < A'Length (1) and then (for all J in 0 .. I => R (I, J) = Gram_Prefix (A, D, I, J, Count))
       and then (for all J in 0 .. I => abs R (I, J) <= Real (Count) * Wide_Step)),
     Post => (Static => (for all J in 0 .. I => abs R (I, J) <= Real (Count + 1) * Wide_Step)
       and then (for all J in 0 .. I => R (I, J) = Gram_Prefix (A, D, I, J, Count + 1))
       and then (for all Row_Index in R'Range (1) =>
         (if Row_Index /= I then (for all J in R'Range (2) => R (Row_Index, J) = R'Old (Row_Index, J))))
       and then (for all J in I + 1 .. R'Last (2) => R (I, J) = R'Old (I, J)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      for J in 0 .. I loop
         Prove_Gram_Cell (A, D, I, J, Count, R (I, J), (if Matrix_Entry (A, Count, I) = 0.0 or else (D'Length /= 0 and then Weight_Entry (D, Count) = 0.0) then R (I, J)
        else Large_Add (R (I, J), Wide_Product (Matrix_Entry (A, Count, J),
          (if D'Length = 0 then Matrix_Entry (A, Count, I)
           else Small_Product (Matrix_Entry (A, Count, I), Weight_Entry (D, Count)))), Count)));
         pragma Loop_Invariant (Static => (for all L in 0 .. J =>
           (if Matrix_Entry (A, Count, I) = 0.0 or else (D'Length /= 0 and then Weight_Entry (D, Count) = 0.0) then R (I, L)
        else Large_Add (R (I, L), Wide_Product (Matrix_Entry (A, Count, L),
          (if D'Length = 0 then Matrix_Entry (A, Count, I)
           else Small_Product (Matrix_Entry (A, Count, I), Weight_Entry (D, Count)))), Count)) = Gram_Prefix (A, D, I, L, Count + 1)));
      end loop;
      Gram_Update_Row (R, A, D, I, Count);
   end Gram_Step;

   procedure Prove_Gram_Mirror (A : Matrix; D : Real_Array; I, J : Natural) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (2) and then J < I
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D))),
     Post => Gram_Component (A, D, J, I, True) = Gram_Component (A, D, I, J, False)
   is
   begin
      null;
   end Prove_Gram_Mirror;

   procedure Mirror_Gram (R : in out Matrix; A : Matrix; D : Real_Array) with
     Inline_Always, Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then In_Tier2 (R)
       and then (for all I in R'Range (1) => (for all J in R'Range (2) => R (I, J) = Gram_Component (A, D, I, J, False))),
     Post => (Static => In_Tier2 (R)
       and then (for all I in R'Range (1) => (for all J in R'Range (2) => R (I, J) = Gram_Component (A, D, I, J, True))))
   is
   begin
      for I in R'Range (1) loop
         for J in I + 1 .. R'Last (2) loop
            Prove_Gram_Mirror (A, D, J, I);
            R (I, J) := R (J, I);
            pragma Loop_Invariant (In_Tier2 (R));
            pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
              (for all L in R'Range (2) => R (K, L) = (if K < L and then (K < I or else (K = I and then L <= J))
                then Gram_Component (A, D, K, L, True) else Gram_Component (A, D, K, L, False)))));
         end loop;
         pragma Loop_Invariant (In_Tier2 (R));
         pragma Loop_Invariant (Static => (for all K in R'Range (1) =>
           (for all L in R'Range (2) => R (K, L) = (if K < L and then K <= I then Gram_Component (A, D, K, L, True) else Gram_Component (A, D, K, L, False)))));
      end loop;
   end Mirror_Gram;

   --  A source row contributes to the lower triangle before moving to
   --  the next source row; the per-cell floating-point order is unchanged.
   procedure Gram_Sweep (R : in out Matrix; A : Matrix; D : Real_Array; Count : Size_Type) with
     Inline_Always, Global => null,
     Pre => (Static => In_Tier2 (R) and then Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then Count < A'Length (1) and then (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, Count) and then abs R (I, J) <= Real (Count) * Wide_Step else R (I, J) = 0.0)))),
     Post => (Static => In_Tier2 (R) and then (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, Count + 1) and then abs R (I, J) <= Real (Count + 1) * Wide_Step else R (I, J) = 0.0))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      for Row_Index in R'Range (1) loop
         Gram_Step (R, A, D, Row_Index, Count);
         pragma Loop_Invariant (In_Tier2 (R));
         pragma Loop_Invariant (Static => (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, (if I <= Row_Index then Count + 1 else Count)) and then abs R (I, J) <= Real ((if I <= Row_Index then Count + 1 else Count)) * Wide_Step else R (I, J) = 0.0))));
      end loop;
   end Gram_Sweep;

   --  A zero weight leaves every lower-triangle prefix unchanged.
   --  This proof-only traversal disappears from the generated program.
   procedure Skip_Zero_Weight (R : Matrix; A : Matrix; D : Real_Array; Count : Size_Type) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then Count < A'Length (1) and then D'Length /= 0 and then D (Count) = 0.0
       and then (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, Count) and then abs R (I, J) <= Real (Count) * Wide_Step else R (I, J) = 0.0))),
     Post => (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, Count + 1) and then abs R (I, J) <= Real (Count + 1) * Wide_Step else R (I, J) = 0.0)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      pragma Assert (Weight_Entry (D, Count) = 0.0);
      for I in R'Range (1) loop
         for J in 0 .. I loop
            Prove_Gram_Cell (A, D, I, J, Count, R (I, J), R (I, J));
            Advance_Wide_Bound (R (I, J), Count);
            pragma Loop_Invariant ((for all L in 0 .. J =>
              R (I, L) = Gram_Prefix (A, D, I, L, Count + 1)
              and then abs R (I, L) <= Real (Count + 1) * Wide_Step));
         end loop;
         pragma Loop_Invariant ((for all K in 0 .. I => (for all L in 0 .. K =>
           R (K, L) = Gram_Prefix (A, D, K, L, Count + 1)
           and then abs R (K, L) <= Real (Count + 1) * Wide_Step)));
      end loop;
   end Skip_Zero_Weight;

   procedure Advance_Gram (R : in out Matrix; A : Matrix; D : Real_Array; Count : Size_Type) with
     Inline_Always, Global => null,
     Pre => (Static => In_Tier2 (R) and then Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then Count < A'Length (1) and then (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, Count) and then abs R (I, J) <= Real (Count) * Wide_Step else R (I, J) = 0.0)))),
     Post => (Static => In_Tier2 (R) and then (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, Count + 1) and then abs R (I, J) <= Real (Count + 1) * Wide_Step else R (I, J) = 0.0))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      if D'Length /= 0 and then D (Count) = 0.0 then
         Skip_Zero_Weight (R, A, D, Count);
      else
         Gram_Sweep (R, A, D, Count);
      end if;
   end Advance_Gram;

   --  Keep expansion of the recursive vector models at the two boundaries.
   --  The runtime accumulation composes opaque, separately proved prefixes.
   procedure Initialize_Gram_Prefix (R, A : Matrix; D : Real_Array) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then (for all I in R'Range (1) => (for all J in R'Range (2) => R (I, J) = 0.0)),
     Post => (for all I in R'Range (1) => (for all J in R'Range (2) =>
       (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, 0)
        and then abs R (I, J) <= 0.0 else R (I, J) = 0.0)))
   is
   begin
      null;
   end Initialize_Gram_Prefix;

   procedure Complete_Gram_Cell (A : Matrix; D : Real_Array; I, J : Natural) with
     Ghost => Static, Global => null,
     Pre => Valid (A) and then In_Tier0 (A) and then I in A'Range (2) and then J <= I
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D))),
     Post => Gram_Prefix (A, D, I, J, A'Length (1)) = Gram_Component (A, D, I, J, False)
   is
      X : constant Real_Array := Column (A, I);
      Y : constant Real_Array := Column (A, J);
   begin
      pragma Assert (Gram_Component (A, D, I, J, False) = Gram_Value (X, Y, D));
      pragma Assert (Gram_Prefix (A, D, I, J, A'Length (1)) =
        (if D'Length = 0 then Sequential (X, Y, A'Length (1)) else Weighted (X, Y, D, A'Length (1))));
   end Complete_Gram_Cell;

   procedure Complete_Gram_Prefix (R, A : Matrix; D : Real_Array) with
     Ghost => Static, Global => null,
     Pre => In_Tier2 (R) and then Valid (A) and then In_Tier0 (A)
       and then R'First (1) = 0 and then R'First (2) = 0
       and then R'Length (1) = A'Length (2) and then R'Length (2) = A'Length (2)
       and then (D'Length = 0 or else (D'First = 0 and then D'Length = A'Length (1) and then In_Tier0 (D)))
       and then (for all I in R'Range (1) => (for all J in R'Range (2) =>
         (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, A'Length (1))
          else R (I, J) = 0.0))),
     Post => In_Tier2 (R) and then (for all I in R'Range (1) => (for all J in R'Range (2) =>
       R (I, J) = Gram_Component (A, D, I, J, False)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      for I in R'Range (1) loop
         for J in R'Range (2) loop
            if J <= I then
               Complete_Gram_Cell (A, D, I, J);
            end if;
            pragma Loop_Invariant ((for all L in 0 .. J =>
              R (I, L) = Gram_Component (A, D, I, L, False)));
         end loop;
         pragma Loop_Invariant ((for all K in 0 .. I => (for all L in R'Range (2) =>
           R (K, L) = Gram_Component (A, D, K, L, False))));
      end loop;
   end Complete_Gram_Prefix;

   procedure SqrMatTD (R : out Matrix; A : Matrix; D : Real_Array := []; Upper : Boolean := True) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Gram_Prefix);
   begin
      R := [others => [others => 0.0]];
      Initialize_Gram_Prefix (R, A, D);
      for K in A'Range (1) loop
         Advance_Gram (R, A, D, K);
         pragma Loop_Invariant (In_Tier2 (R));
         pragma Loop_Invariant (Static => (for all I in R'Range (1) => (for all J in R'Range (2) => (if J <= I then R (I, J) = Gram_Prefix (A, D, I, J, K + 1) and then abs R (I, J) <= Real (K + 1) * Wide_Step else R (I, J) = 0.0))));
      end loop;
      Complete_Gram_Prefix (R, A, D);
      if Upper then
         Mirror_Gram (R, A, D);
         pragma Assert_And_Cut (Static => In_Tier2 (R) and then (for all I in R'Range (1) =>
           (for all J in R'Range (2) => R (I, J) = Gram_Component (A, D, I, J, Upper))));
      else
         pragma Assert_And_Cut (Static => In_Tier2 (R) and then (for all I in R'Range (1) =>
           (for all J in R'Range (2) => R (I, J) = Gram_Component (A, D, I, J, Upper))));
      end if;
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

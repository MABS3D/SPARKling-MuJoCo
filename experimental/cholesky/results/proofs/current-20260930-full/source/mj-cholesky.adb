with MJ.Cholesky_Models; use MJ.Cholesky_Models;
with MJ.Cholesky_Steps; use MJ.Cholesky_Steps;

package body MJ.Cholesky with SPARK_Mode is
   subtype Positive_Wide is Wide_Operand range Min_Val .. Wide_Operand'Last;
   procedure Upper_Transitive (A, B, C : Real_Array; N : Dimension) is
   begin
      null;
   end Upper_Transitive;

   procedure Advance_Lane (A, B : Real_Array; A0, B0 : Natural;
                           Block : Block_Count; L : Lane; Acc : in out Lane_Real)
     with Inline_Always,
       Pre => (Static => Block < Block_Count'Last
         and then Valid_Dot (A, B, A0, B0, 4*(Block+1))
         and then Acc = Lane_Sum (A, B, A0, B0, Block, L)
         and then abs Acc <= Real (Block)*Step_Bound),
       Post => (Static => Acc = Lane_Sum (A, B, A0, B0, Block+1, L)
         and then abs Acc <= Real (Block+1)*Step_Bound);

   procedure Advance_Lane (A, B : Real_Array; A0, B0 : Natural;
                           Block : Block_Count; L : Lane; Acc : in out Lane_Real) is
   begin
      Unfold_Lane (A, B, A0, B0, Block, L);
      Acc := Model_Add (Acc, Product (A (A0+4*Block+L), B (B0+4*Block+L)), Block);
   end Advance_Lane;

   --  Four independent lanes and the same tail grouping as mju_dot/AVX.
   function Dot (A, B : Real_Array; A0, B0 : Natural; Count : Dot_Count) return Real
     with Inline_Always, Pre => Valid_Dot (A, B, A0, B0, Count),
       Post => (Static => Dot'Result = Dot_Value (A, B, A0, B0, Count)
                and then abs Dot'Result <= 1.0e207
                and then (if (for all I in B0 .. B0+Count-1 => B (I) = 0.0) then Dot'Result = 0.0))
   is
      Acc_0, Acc_1, Acc_2, Acc_3 : Lane_Real := 0.0;
   begin
      for Block in 0 .. Count / 4 - 1 loop
         pragma Loop_Optimize (No_Vector);
         Prefix_Dot (A, B, A0, B0, Count, 4*(Block+1));
         Advance_Lane (A, B, A0, B0, Block, 0, Acc_0);
         Advance_Lane (A, B, A0, B0, Block, 1, Acc_1);
         Advance_Lane (A, B, A0, B0, Block, 2, Acc_2);
         Advance_Lane (A, B, A0, B0, Block, 3, Acc_3);
         pragma Loop_Invariant
           (Static => Acc_0 = Lane_Sum (A, B, A0, B0, Block+1, 0));
         pragma Loop_Invariant
           (Static => Acc_1 = Lane_Sum (A, B, A0, B0, Block+1, 1));
         pragma Loop_Invariant
           (Static => Acc_2 = Lane_Sum (A, B, A0, B0, Block+1, 2));
         pragma Loop_Invariant
           (Static => Acc_3 = Lane_Sum (A, B, A0, B0, Block+1, 3));
         pragma Loop_Invariant (abs Acc_0 <= Real (Block+1)*Step_Bound);
         pragma Loop_Invariant (abs Acc_1 <= Real (Block+1)*Step_Bound);
         pragma Loop_Invariant (abs Acc_2 <= Real (Block+1)*Step_Bound);
         pragma Loop_Invariant (abs Acc_3 <= Real (Block+1)*Step_Bound);
      end loop;
      Reduction_Model (A, B, A0, B0, Count, Acc_0, Acc_1, Acc_2, Acc_3);
      return Combine (Acc_0, Acc_1, Acc_2, Acc_3, Tail (A, B, A0, B0, Count));
   end Dot;

   procedure Store (A : in out Real_Array; N : Dimension; Row, Col : Natural; V : Operand)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Bounded (A) and then Row < N and then Col <= Row),
     Post => (Static => Bounded (A) and then Same_Upper (A, A'Old, N)
       and then (for all T in A'Range => A (T) = (if T = Cell (N, Row, Col) then V else A'Old (T)))
       and then (for all C in 0 .. N =>
         (if Positive_Prefix (A'Old, N, C) and then (Row /= Col or else Row >= C or else V >= Min_Val)
          then Positive_Prefix (A, N, C))));
   procedure Store (A : in out Real_Array; N : Dimension; Row, Col : Natural; V : Operand) is
   begin
      A (Cell (N, Row, Col)) := V;
   end Store;

   subtype Positive_Operand is Operand range Min_Val .. Operand'Last;
   procedure Store_Diagonal (A : in out Real_Array; N : Dimension; J : Natural; V : Positive_Operand)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Bounded (A) and then J < N and then Positive_Prefix (A, N, J)),
     Post => (Static => Bounded (A) and then Same_Upper (A, A'Old, N) and then Positive_Prefix (A, N, J+1)
       and then A (Cell (N, J, J)) = V);
   procedure Store_Diagonal (A : in out Real_Array; N : Dimension; J : Natural; V : Positive_Operand) is
   begin
      Store (A, N, J, J, V);
   end Store_Diagonal;

   function Row_Dot (A : Real_Array; N : Dimension; I, J, Count : Natural) return Real
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Bounded (A) and then I < N and then J < N and then Count <= N),
     Post => (Static => Row_Dot'Result = Dot_Value (A, A, Cell (N, I, 0), Cell (N, J, 0), Count)
       and then abs Row_Dot'Result <= 1.0e207);
   function Row_Dot (A : Real_Array; N : Dimension; I, J, Count : Natural) return Real is
   begin
      return Dot (A, A, Cell (N, I, 0), Cell (N, J, 0), Count);
   end Row_Dot;

   function Vector_Dot (A, X : Real_Array; N : Dimension; I, Count : Natural) return Real
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Vector_Shape (X, N) and then Bounded (A)
       and then Bounded (X) and then I < N and then Count <= N),
     Post => (Static => Vector_Dot'Result = Dot_Value (A, X, Cell (N, I, 0), 0, Count)
       and then abs Vector_Dot'Result <= 1.0e207
       and then (if Is_Zero (X) then Vector_Dot'Result = 0.0));
   function Vector_Dot (A, X : Real_Array; N : Dimension; I, Count : Natural) return Real is
   begin
      return Dot (A, X, Cell (N, I, 0), 0, Count);
   end Vector_Dot;

   procedure Zero_Column (A : in out Real_Array; N : Dimension; J : Natural)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Bounded (A) and then J < N and then Positive_Prefix (A, N, J+1)),
     Post => (Static => Bounded (A) and then Same_Upper (A, A'Old, N) and then Positive_Prefix (A, N, J+1)
       and then (for all I in J+1 .. N-1 => A (Cell (N, I, J)) = 0.0));
   procedure Zero_Column (A : in out Real_Array; N : Dimension; J : Natural) is
   begin
      for I in J+1 .. N-1 loop
         Store (A, N, I, J, 0.0);
         pragma Loop_Invariant (Bounded (A));
         pragma Loop_Invariant (Static => Same_Upper (A, A'Loop_Entry, N));
         pragma Loop_Invariant (Positive_Prefix (A, N, J+1));
         pragma Loop_Invariant (for all R in J+1 .. I => A (Cell (N, R, J)) = 0.0);
      end loop;
   end Zero_Column;

   procedure Scale_Entry (A : in out Real_Array; N : Dimension; I, J : Natural; Inverse : Operand; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Bounded (A) and then J < I and then I < N
       and then Positive_Prefix (A, N, J+1)),
     Post => (Static => Bounded (A) and then Same_Upper (A, A'Old, N) and then Positive_Prefix (A, N, J+1)
       and then (for all T in A'Range => (if T /= Cell (N, I, J) then A (T) = A'Old (T)))
       and then (if Result = Success then Row_Dot (A'Old, N, I, J, J) in Operand
         and then A (Cell (N, I, J)) = Factor_Entry (A'Old (Cell (N, I, J)), Row_Dot (A'Old, N, I, J, J), Inverse)));
   procedure Scale_Entry (A : in out Real_Array; N : Dimension; I, J : Natural; Inverse : Operand; Result : out Status) is
      Reduced, Next : Real;
   begin
      Result := Numeric_Limit;
      Reduced := Row_Dot (A, N, I, J, J);
      if Reduced not in Operand then return; end if;
      Next := Factor_Entry (A (Cell (N, I, J)), Reduced, Inverse);
      if Next not in Operand then return; end if;
      Store (A, N, I, J, Next);
      Result := Success;
   end Scale_Entry;

   procedure Scale_Column (A : in out Real_Array; N : Dimension; J : Natural; Inverse : Operand; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Bounded (A) and then J < N and then Positive_Prefix (A, N, J+1)),
     Post => (Static => Bounded (A) and then Same_Upper (A, A'Old, N) and then Positive_Prefix (A, N, J+1));
   procedure Scale_Column (A : in out Real_Array; N : Dimension; J : Natural; Inverse : Operand; Result : out Status) is
      Original : constant Real_Array := A with Ghost => Static;
      Before : Real_Array := A with Ghost => Static;
   begin
      Result := Success;
      for I in J+1 .. N-1 loop
         Before := A;
            Scale_Entry (A, N, I, J, Inverse, Result);
            Upper_Transitive (A, Before, Original, N);

         if Result /= Success then return; end if;
         pragma Loop_Invariant (Bounded (A) and then Result = Success);
         pragma Loop_Invariant (Static => Same_Upper (A, Original, N));
         pragma Loop_Invariant (Static => Original = A'Loop_Entry);
         pragma Loop_Invariant (Positive_Prefix (A, N, J+1));
      end loop;
   end Scale_Column;

   procedure Factor_Column (A : in out Real_Array; N : Dimension; J : Natural;
                            Minimum : Threshold; Deficient : out Boolean; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Bounded (A) and then J < N and then Positive_Prefix (A, N, J)),
     Post => (Static => Bounded (A) and then Same_Upper (A, A'Old, N)
       and then (if Result = Success then Positive_Prefix (A, N, J+1)));
   procedure Factor_Column (A : in out Real_Array; N : Dimension; J : Natural;
                            Minimum : Threshold; Deficient : out Boolean; Result : out Status) is
      Pivot : Real := A (Cell (N, J, J));
      Inverse, Next : Real;
      Original : constant Real_Array := A with Ghost => Static;
      Before : Real_Array := A with Ghost => Static;
   begin
      Result := Success;
      if J > 0 then Pivot := Pivot-Row_Dot (A, N, J, J, J); end if;
      Deficient := Pivot < Minimum;
      Next := Root (Pivot, Minimum);
      if Next not in Operand or else Next < Min_Val then Result := Numeric_Limit; return; end if;
      Store_Diagonal (A, N, J, Next);
      Before := A;
      if Deficient then Zero_Column (A, N, J);
      else
         Inverse := 1.0/A (Cell (N, J, J));
         Scale_Column (A, N, J, Inverse, Result);
      end if;
      Upper_Transitive (A, Before, Original, N);
   end Factor_Column;

   procedure Factor (A : in out Real_Array; N : Dimension;
                     Minimum : Threshold; Rank : out Natural; Result : out Status) is
      Deficient : Boolean;
      Original : constant Real_Array := A with Ghost => Static;
      Before : Real_Array := A with Ghost => Static;
   begin
      Rank := N; Result := Success;
      for J in 0 .. N-1 loop
         Before := A;
         Factor_Column (A, N, J, Minimum, Deficient, Result);
         Upper_Transitive (A, Before, Original, N);
         if Deficient then Rank := Rank-1; end if;
         if Result /= Success then return; end if;
         pragma Loop_Invariant (Rank in N-J-1 .. N);
         pragma Loop_Invariant (Bounded (A) and then Result = Success);
         pragma Loop_Invariant (Static => Same_Upper (A, Original, N));
         pragma Loop_Invariant (Static => Original = A'Loop_Entry);
         pragma Loop_Invariant (Positive_Prefix (A, N, J+1));
      end loop;
   end Factor;

   procedure Store_Vector (X : in out Real_Array; N : Dimension; I : Natural; V : Operand)
     with Inline_Always,
     Pre => (Static => Vector_Shape (X, N) and then Bounded (X) and then I < N),
     Post => (Static => Bounded (X) and then
       (for all J in X'Range => X (J) = (if J = I then V else X'Old (J))));
   procedure Store_Vector (X : in out Real_Array; N : Dimension; I : Natural; V : Operand) is
   begin
      X (I) := V;
   end Store_Vector;

   procedure Reduce_RHS (X : in out Operand; Sum : Real; Result : out Status)
     with Inline_Always, Pre => abs Sum <= 1.0e207,
     Post => Result = (if X'Old-Sum in Operand then Success else Numeric_Limit)
       and then X = (if Result = Success then X'Old-Sum else X'Old);
   procedure Reduce_RHS (X : in out Operand; Sum : Real; Result : out Status) is
      Next : constant Real := X-Sum;
   begin
      Result := Numeric_Limit;
      if Next in Operand then X := Next; Result := Success; end if;
   end Reduce_RHS;

   procedure Subtract_RHS (X : in out Operand; A, Y : Operand; Result : out Status)
     with Inline_Always,
     Post => Result = (if X'Old-A*Y in Operand then Success else Numeric_Limit)
       and then X = (if Result = Success then X'Old-A*Y else X'Old);
   procedure Subtract_RHS (X : in out Operand; A, Y : Operand; Result : out Status) is
      Next : constant Real := X-A*Y;
   begin
      Result := Numeric_Limit;
      if Next in Operand then X := Next; Result := Success; end if;
   end Subtract_RHS;

   procedure Divide_RHS (X : in out Operand; Pivot : Operand; Result : out Status)
     with Inline_Always, Pre => Pivot >= Min_Val,
     Post => Result = (if X'Old/Pivot in Operand then Success else Numeric_Limit)
       and then X = (if Result = Success then X'Old/Pivot else X'Old);
   procedure Divide_RHS (X : in out Operand; Pivot : Operand; Result : out Status) is
      Next : constant Real := X/Pivot;
   begin
      Result := Numeric_Limit;
      if Next in Operand then X := Next; Result := Success; end if;
   end Divide_RHS;

   procedure Forward_Step (A : Real_Array; X : in out Real_Array; N : Dimension; I : Natural; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Vector_Shape (X, N) and then Bounded (A)
       and then Bounded (X) and then Positive_Diagonal (A, N) and then I < N),
     Post => (Static => Bounded (X)
       and then (if Is_Zero (X'Old) then X = X'Old and then Result = Success));
   procedure Forward_Step (A : Real_Array; X : in out Real_Array; N : Dimension; I : Natural; Result : out Status) is
      T : Operand := X (I);
   begin
      Result := Success;
      if I > 0 then
         Reduce_RHS (T, Vector_Dot (A, X, N, I, I), Result);
         if Result /= Success then return; end if;
         Store_Vector (X, N, I, T);
      end if;
      Divide_RHS (T, A (Cell (N, I, I)), Result);
      if Result = Success then Store_Vector (X, N, I, T); end if;
   end Forward_Step;

   procedure Backward_Step (A : Real_Array; X : in out Real_Array; N : Dimension; I : Natural; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Vector_Shape (X, N) and then Bounded (A)
       and then Bounded (X) and then Positive_Diagonal (A, N) and then I < N),
     Post => (Static => Bounded (X)
       and then (if Is_Zero (X'Old) then X = X'Old and then Result = Success));
   procedure Backward_Step (A : Real_Array; X : in out Real_Array; N : Dimension; I : Natural; Result : out Status) is
      T : Operand := X (I);
      Original : constant Real_Array := X with Ghost => Static;
   begin
      Result := Success;
      for J in I+1 .. N-1 loop
         Subtract_RHS (T, A (Cell (N, J, I)), X (J), Result);
         if Result /= Success then return; end if;
         Store_Vector (X, N, I, T);
         pragma Loop_Invariant (Bounded (X) and then Result = Success);
         pragma Loop_Invariant (Static => (if Is_Zero (Original) then T = 0.0 and then X = Original));
         pragma Loop_Invariant (Static => Original = X'Loop_Entry);
      end loop;
      Divide_RHS (T, A (Cell (N, I, I)), Result);
      if Result = Success then Store_Vector (X, N, I, T); end if;
   end Backward_Step;

   procedure Solve (A : Real_Array; X : in out Real_Array; N : Dimension; Result : out Status) is
      Original : constant Real_Array := X with Ghost => Static;
   begin
      Result := Success;
      for I in 0 .. N-1 loop
         Forward_Step (A, X, N, I, Result);
         if Result /= Success then return; end if;
         pragma Loop_Invariant (Bounded (X) and then Result = Success);
         pragma Loop_Invariant (Static => (if Is_Zero (Original) then Is_Zero (X)));
      end loop;
      for I in reverse 0 .. N-1 loop
         Backward_Step (A, X, N, I, Result);
         if Result /= Success then return; end if;
         pragma Loop_Invariant (Bounded (X) and then Result = Success);
         pragma Loop_Invariant (Static => (if Is_Zero (Original) then Is_Zero (X)));
      end loop;
   end Solve;

   procedure Store_Wide (A : in out Real_Array; N : Dimension; Row, Col : Natural; V : Wide_Operand)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Wide_Bounded (A) and then Row < N and then Col <= Row),
     Post => (Static => Wide_Bounded (A) and then Same_Upper (A, A'Old, N)
       and then (for all T in A'Range => A (T) = (if T = Cell (N, Row, Col) then V else A'Old (T)))
       and then (if Positive_Diagonal (A'Old, N) and then (Row /= Col or else V >= Min_Val)
         then Positive_Diagonal (A, N)));
   procedure Store_Wide (A : in out Real_Array; N : Dimension; Row, Col : Natural; V : Wide_Operand) is
   begin
      A (Cell (N, Row, Col)) := V;
   end Store_Wide;

   procedure Store_Vector_Wide (X : in out Real_Array; N : Dimension; I : Natural; V : Wide_Operand)
     with Inline_Always,
     Pre => (Static => Vector_Shape (X, N) and then Wide_Bounded (X) and then I < N and then I > 0),
     Post => (Static => Wide_Bounded (X) and then
       (for all J in X'Range => X (J) = (if J = I then V else X'Old (J))) and then X (0) = X'Old (0));
   procedure Store_Vector_Wide (X : in out Real_Array; N : Dimension; I : Natural; V : Wide_Operand) is
   begin
      X (I) := V;
   end Store_Vector_Wide;

   procedure Update_Factors (Diagonal, X : Wide_Operand; Plus : Boolean;
                             R : out Positive_Wide; C, Inverse_C, S : out Real;
                             Deficient : out Boolean; Result : out Status)
     with Inline_Always, Pre => Diagonal >= Min_Val,
     Post => Deficient = (Update_Square (Diagonal, X, Plus) < Min_Val)
       and then (if Result = Success then R = Root (Update_Square (Diagonal, X, Plus), Min_Val)
         and then R >= Min_Val and then C = R/Diagonal and then C >= 1.0e-200
         and then Inverse_C = 1.0/C and then S = X/Diagonal);
   procedure Update_Factors (Diagonal, X : Wide_Operand; Plus : Boolean;
                             R : out Positive_Wide; C, Inverse_C, S : out Real;
                             Deficient : out Boolean; Result : out Status) is
      Square : constant Squared := Update_Square (Diagonal, X, Plus);
      Next : Real;
   begin
      Result := Numeric_Limit; R := Min_Val; C := 0.0; Inverse_C := 0.0; S := 0.0;
      Deficient := Square < Min_Val;
      Next := Root (Square, Min_Val);
      if Next not in Wide_Operand or else Next < Min_Val then return; end if;
      R := Next; C := R/Diagonal;
      if C < 1.0e-200 then return; end if;
      Inverse_C := 1.0/C; S := X/Diagonal; Result := Success;
   end Update_Factors;

   procedure Update_Matrix_Entry (A : in out Real_Array; X : Wide_Operand; N : Dimension;
                                  I, K : Natural; S, Inverse_C : Real; Plus : Boolean; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Wide_Bounded (A) and then K < I and then I < N
       and then Positive_Diagonal (A, N)),
     Post => (Static => Wide_Bounded (A) and then Same_Upper (A, A'Old, N) and then Positive_Diagonal (A, N)
       and then (for all T in A'Range => (if T /= Cell (N, I, K) then A (T) = A'Old (T)))
       and then (if Result = Success then A'Old (Cell (N, I, K)) in Operand and then X in Operand
         and then S in Operand and then Inverse_C in Operand
         and then A (Cell (N, I, K)) = Update_Entry (A'Old (Cell (N, I, K)), S, X, Inverse_C, Plus)));
   procedure Update_Matrix_Entry (A : in out Real_Array; X : Wide_Operand; N : Dimension;
                                  I, K : Natural; S, Inverse_C : Real; Plus : Boolean; Result : out Status) is
      Next : Real;
   begin
      Result := Numeric_Limit;
      if A (Cell (N, I, K)) not in Operand or else X not in Operand or else S not in Operand
        or else Inverse_C not in Operand then return; end if;
      Next := Update_Entry (A (Cell (N, I, K)), S, X, Inverse_C, Plus);
      if Next not in Wide_Operand then return; end if;
      Store_Wide (A, N, I, K, Next); Result := Success;
   end Update_Matrix_Entry;

   procedure Update_Vector_Entry (X : in out Real_Array; N : Dimension; I : Natural;
                                  C, S : Real; New_Entry : Wide_Operand; Result : out Status)
     with Inline_Always,
     Pre => (Static => Vector_Shape (X, N) and then Wide_Bounded (X) and then I > 0 and then I < N),
     Post => (Static => Wide_Bounded (X) and then X (0) = X'Old (0)
       and then (for all J in X'Range => (if J /= I then X (J) = X'Old (J)))
       and then (if Result = Success then C in Wide_Operand and then S in Wide_Operand
         and then X (I) = Update_Vector (C, X'Old (I), S, New_Entry)));
   procedure Update_Vector_Entry (X : in out Real_Array; N : Dimension; I : Natural;
                                  C, S : Real; New_Entry : Wide_Operand; Result : out Status) is
      Next : Real;
   begin
      Result := Numeric_Limit;
      if C not in Wide_Operand or else S not in Wide_Operand then return; end if;
      Next := Update_Vector (C, X (I), S, New_Entry);
      if Next not in Wide_Operand then return; end if;
      Store_Vector_Wide (X, N, I, Next); Result := Success;
   end Update_Vector_Entry;

   procedure Update_Matrix_Column (A : in out Real_Array; X : Real_Array; N : Dimension;
                                   K : Natural; S, Inverse_C : Real; Plus : Boolean; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Vector_Shape (X, N) and then Wide_Bounded (A)
       and then Wide_Bounded (X) and then K < N and then Positive_Diagonal (A, N)),
     Post => (Static => Wide_Bounded (A) and then Same_Upper (A, A'Old, N) and then Positive_Diagonal (A, N));
   procedure Update_Matrix_Column (A : in out Real_Array; X : Real_Array; N : Dimension;
                                   K : Natural; S, Inverse_C : Real; Plus : Boolean; Result : out Status) is
      Original : constant Real_Array := A with Ghost => Static;
      Before : Real_Array := A with Ghost => Static;
   begin
      Result := Success;
      if Plus then
         for I in K+1 .. N-1 loop
            Before := A;
            Update_Matrix_Entry (A, X (I), N, I, K, S, Inverse_C, True, Result);
            Upper_Transitive (A, Before, Original, N);
            if Result /= Success then return; end if;
            pragma Loop_Invariant (Wide_Bounded (A) and then Positive_Diagonal (A, N) and then Result = Success);
            pragma Loop_Invariant (Static => Same_Upper (A, Original, N));
         pragma Loop_Invariant (Static => Original = A'Loop_Entry);
         end loop;
      else
         for I in K+1 .. N-1 loop
            Before := A;
            Update_Matrix_Entry (A, X (I), N, I, K, S, Inverse_C, False, Result);
            Upper_Transitive (A, Before, Original, N);
            if Result /= Success then return; end if;
            pragma Loop_Invariant (Wide_Bounded (A) and then Positive_Diagonal (A, N) and then Result = Success);
            pragma Loop_Invariant (Static => Same_Upper (A, Original, N));
         pragma Loop_Invariant (Static => Original = A'Loop_Entry);
         end loop;
      end if;
   end Update_Matrix_Column;

   procedure Update_Vector_Column (A : Real_Array; X : in out Real_Array; N : Dimension;
                                   K : Natural; C, S : Real; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Vector_Shape (X, N) and then Wide_Bounded (A)
       and then Wide_Bounded (X) and then K < N),
     Post => (Static => Wide_Bounded (X) and then X (0) = X'Old (0));
   procedure Update_Vector_Column (A : Real_Array; X : in out Real_Array; N : Dimension;
                                   K : Natural; C, S : Real; Result : out Status) is
   begin
      Result := Success;
      for I in K+1 .. N-1 loop
         Update_Vector_Entry (X, N, I, C, S, A (Cell (N, I, K)), Result);
         if Result /= Success then return; end if;
         pragma Loop_Invariant (Wide_Bounded (X) and then Result = Success);
         pragma Loop_Invariant (Static => X (0) = X'Loop_Entry (0));
      end loop;
   end Update_Vector_Column;
   procedure Update_Column (A, X : in out Real_Array; N : Dimension; K : Natural;
                            Plus : Boolean; Deficient : out Boolean; Result : out Status)
     with Inline_Always,
     Pre => (Static => Shape (A, N) and then Vector_Shape (X, N) and then Wide_Bounded (A)
       and then Wide_Bounded (X) and then K < N and then Positive_Diagonal (A, N)),
     Post => (Static => Wide_Bounded (A) and then Wide_Bounded (X) and then Positive_Diagonal (A, N)
       and then Same_Upper (A, A'Old, N) and then X (0) = X'Old (0)
       and then (if X'Old (K) = 0.0 then A = A'Old and then X = X'Old and then not Deficient and then Result = Success));
   procedure Update_Column (A, X : in out Real_Array; N : Dimension; K : Natural;
                            Plus : Boolean; Deficient : out Boolean; Result : out Status) is
      Initial_X : constant Wide_Operand := X (K);
      R : Positive_Wide;
      C, Inverse_C, S : Real;
      Original : constant Real_Array := A with Ghost => Static;
      Before : Real_Array := A with Ghost => Static;
   begin
      Result := Success; Deficient := False;
      if Initial_X = 0.0 then return; end if;
      Update_Factors (A (Cell (N, K, K)), Initial_X, Plus, R, C, Inverse_C, S, Deficient, Result);
      if Result /= Success then return; end if;
      Before := A;
      pragma Assert (Static => Positive_Diagonal (A, N));
      Store_Wide (A, N, K, K, R);
      pragma Assert (Static => Positive_Diagonal (A, N));
      Upper_Transitive (A, Before, Original, N);
      Before := A;
      Update_Matrix_Column (A, X, N, K, S, Inverse_C, Plus, Result);
      Upper_Transitive (A, Before, Original, N);
      if Result /= Success then return; end if;
      Update_Vector_Column (A, X, N, K, C, S, Result);
   end Update_Column;

   procedure Update (A, X : in out Real_Array; N : Dimension;
                     Plus : Boolean; Rank : out Natural; Result : out Status) is
      Deficient : Boolean;
      Original : constant Real_Array := A with Ghost => Static;
      Original_X : constant Real_Array := X with Ghost => Static;
      Before : Real_Array := A with Ghost => Static;
   begin
      Rank := N; Result := Success;
      for K in 0 .. N-1 loop
         Before := A;
         Update_Column (A, X, N, K, Plus, Deficient, Result);
         Upper_Transitive (A, Before, Original, N);
         if Deficient then Rank := Rank-1; end if;
         if Result /= Success then return; end if;
         pragma Loop_Invariant (Rank in N-K-1 .. N);
         pragma Loop_Invariant (Wide_Bounded (A) and then Wide_Bounded (X) and then Result = Success);
         pragma Loop_Invariant (Positive_Diagonal (A, N));
         pragma Loop_Invariant (Static => Same_Upper (A, Original, N));
         pragma Loop_Invariant (Static => Original = A'Loop_Entry);
         pragma Loop_Invariant (Static => (if N > 0 then X (0) = Original_X (0)));
         pragma Loop_Invariant (Static => (if (for all I in X'Range => Original_X (I) = 0.0)
           then A = Original and then X = Original_X and then Rank = N));
      end loop;
   end Update;
end MJ.Cholesky;

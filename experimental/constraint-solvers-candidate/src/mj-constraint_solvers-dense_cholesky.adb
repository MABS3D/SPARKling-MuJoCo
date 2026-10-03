with MJ.Constraint_Solvers.Reductions;
package body MJ.Constraint_Solvers.Dense_Cholesky with SPARK_Mode is
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model.Dot_Value);
   function Prefix (L : Matrix; I : Positive; Count : Natural) return Vector is
      V : Vector (1 .. Count) with Relaxed_Initialization;
   begin
      for K in V'Range loop
         V (K) := L (I, K);
         pragma Loop_Invariant (for all Q in 1 .. K => V (Q)'Initialized);
         pragma Loop_Invariant
           (for all Q in 1 .. K => V (Q) = L (I, Q) and then V (Q) in Operand);
      end loop;
      pragma Assert (V'Initialized);
      return V;
   end Prefix;

   procedure Equal_Prefixes (A, B : Matrix; I : Positive; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Square (A) and then Square (B) and then Bounded (A) and then Bounded (B)
       and then A'Length (1) = B'Length (1) and then I in A'Range (1)
       and then Count <= A'Length (1)
       and then (for all K in 1 .. Count => A (I, K) = B (I, K)),
     Post => Prefix (A, I, Count) = Prefix (B, I, Count)
   is
      Left : constant Vector := Prefix (A, I, Count);
      Right : constant Vector := Prefix (B, I, Count);
   begin
      pragma Assert (for all K in 1 .. Count => Left (K) = Right (K));
      pragma Assert (Left = Right);
   end Equal_Prefixes;

   procedure Equal_Final_Residual (M, A, B : Matrix; J : Positive)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (A) and then Square (B)
       and then Bounded (M) and then Bounded (A) and then Bounded (B)
       and then M'Length (1) = A'Length (1) and then M'Length (1) = B'Length (1)
       and then J in M'Range (1)
       and then (for all K in 1 .. J - 1 => A (J, K) = B (J, K)),
     Post => Final_Residual (M, A, J) = Final_Residual (M, B, J)
   is
   begin
      Equal_Prefixes (A, B, J, J - 1);
      Model.Equal_Dots (Prefix (A, J, J - 1), Prefix (A, J, J - 1),
                        Prefix (B, J, J - 1), Prefix (B, J, J - 1));
   end Equal_Final_Residual;

   procedure Equal_Final_Off_Diagonal (M, A, B : Matrix; I, J : Positive; Inv : Real)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (A) and then Square (B)
       and then Bounded (M) and then Bounded (A) and then Bounded (B)
       and then M'Length (1) = A'Length (1) and then M'Length (1) = B'Length (1)
       and then J in M'Range (1) and then I in J + 1 .. M'Last (1)
       and then Inv in 0.0 .. 1.0e15
       and then (for all K in 1 .. J - 1 =>
         A (I, K) = B (I, K) and then A (J, K) = B (J, K)),
     Post => Final_Off_Diagonal (M, A, I, J, Inv) = Final_Off_Diagonal (M, B, I, J, Inv)
   is
   begin
      Equal_Prefixes (A, B, I, J - 1);
      Equal_Prefixes (A, B, J, J - 1);
      Model.Equal_Dots (Prefix (A, I, J - 1), Prefix (A, J, J - 1),
                        Prefix (B, I, J - 1), Prefix (B, J, J - 1));
   end Equal_Final_Off_Diagonal;

   procedure Preserve_Completed_Column (M, Before, After : Matrix; J : Positive; Floor : Pivot)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (Before) and then Square (After)
       and then Bounded (M) and then Bounded (Before) and then Bounded (After)
       and then M'Length (1) = Before'Length (1)
       and then M'Length (1) = After'Length (1) and then J in M'Range (1)
       and then Completed_Column (M, Before, J, Floor)
       and then (for all I in M'Range (1) =>
         (for all K in 1 .. J => Before (I, K) = After (I, K))),
     Post => Completed_Column (M, After, J, Floor)
   is
   begin
      Equal_Final_Residual (M, Before, After, J);
      pragma Assert (After (J, J) in Pivot);
      if Final_Residual (M, Before, J) >= Floor then
         for I in J + 1 .. M'Last (1) loop
            Equal_Final_Off_Diagonal
              (M, Before, After, I, J, Inverse_Pivot (After (J, J)));
            pragma Loop_Invariant (for all K in J + 1 .. I =>
              After (K, J) = Final_Off_Diagonal (M, After, K, J, Inverse_Pivot (After (J, J))));
         end loop;
      end if;
   end Preserve_Completed_Column;

   procedure Establish_Completed_Column
     (M, Before, After : Matrix; J : Positive; Floor : Pivot; Deficient : Boolean)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (Before) and then Square (After)
       and then Bounded (M) and then Bounded (Before) and then Bounded (After)
       and then M'Length (1) = Before'Length (1)
       and then M'Length (1) = After'Length (1) and then J in M'Range (1)
       and then (for all I in J .. M'Last (1) => Before (I, J) = M (I, J))
       and then (for all I in M'Range (1) =>
         (for all K in 1 .. J - 1 => Before (I, K) = After (I, K)))
       and then Deficient = (Diagonal_Residual (Before, J) < Floor)
       and then After (J, J) in Pivot
       and then After (J, J) = Math.Sqrt
         (if Deficient then Floor else Diagonal_Residual (Before, J))
       and then (for all I in J + 1 .. M'Last (1) =>
         After (I, J) = (if Deficient then 0.0 else
           Off_Diagonal (Before, I, J, Inverse_Pivot (After (J, J))))),
     Post => Completed_Column (M, After, J, Floor)
       and then Deficient = (Final_Residual (M, After, J) < Floor)
   is
   begin
      pragma Assert (Diagonal_Residual (Before, J) = Final_Residual (M, Before, J));
      Equal_Final_Residual (M, Before, After, J);
      if not Deficient then
         for I in J + 1 .. M'Last (1) loop
            pragma Assert (Off_Diagonal (Before, I, J, Inverse_Pivot (After (J, J))) =
              Final_Off_Diagonal (M, Before, I, J, Inverse_Pivot (After (J, J))));
            Equal_Final_Off_Diagonal
              (M, Before, After, I, J, Inverse_Pivot (After (J, J)));
            pragma Loop_Invariant (for all K in J + 1 .. I =>
              After (K, J) = Final_Off_Diagonal (M, After, K, J, Inverse_Pivot (After (J, J))));
         end loop;
      end if;
   end Establish_Completed_Column;

   procedure Unfold_Deficiency_Count (M, L : Matrix; Floor : Pivot; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (L) and then Bounded (M) and then Bounded (L)
       and then M'Length (1) = L'Length (1) and then Count <= L'Length (1),
     Post => Deficiency_Count (M, L, Floor, Count) =
       (if Count = 0 then 0 else Deficiency_Count (M, L, Floor, Count - 1)
        + (if Final_Residual (M, L, Count) < Floor then 1 else 0))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Deficiency_Count);
   begin
      null;
   end Unfold_Deficiency_Count;

   procedure Equal_Deficiency_Count (M, Before, After : Matrix; Floor : Pivot; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (Before) and then Square (After)
       and then Bounded (M) and then Bounded (Before) and then Bounded (After)
       and then M'Length (1) = Before'Length (1)
       and then M'Length (1) = After'Length (1) and then Count <= M'Length (1)
       and then (for all I in M'Range (1) =>
         (for all K in 1 .. Count - 1 => Before (I, K) = After (I, K))),
     Post => Deficiency_Count (M, Before, Floor, Count) = Deficiency_Count (M, After, Floor, Count),
     Subprogram_Variant => (Decreases => Count)
   is
   begin
      Unfold_Deficiency_Count (M, Before, Floor, Count);
      Unfold_Deficiency_Count (M, After, Floor, Count);
      if Count > 0 then
         Equal_Deficiency_Count (M, Before, After, Floor, Count - 1);
         Equal_Final_Residual (M, Before, After, Count);
      end if;
   end Equal_Deficiency_Count;

   function Scaled_Residual (Value : Operand; Product : Model.Dot_Real; Inv : Real)
      return Real is
   begin
      return (Value - Product) * Inv;
   end Scaled_Residual;

   procedure Prepare_Column
     (L : Matrix; J : Positive; Floor : Pivot; Values : out Vector;
      Deficient : out Boolean; Result : out Status)
     with Global => null,
     Pre => Square (L) and then Bounded (L) and then J in L'Range (1)
       and then Values'First = J and then Values'Last = L'Last (1),
     Post => (Static => (for all V of Values => V in Operand)
       and then Deficient = (Diagonal_Residual (L, J) < Floor)
       and then (if Result = Success then Values (J) in Pivot
         and then Values (J) = Math.Sqrt
           (if Deficient then Floor else Diagonal_Residual (L, J))
         and then (for all I in J + 1 .. L'Last (1) =>
           Values (I) = (if Deficient then 0.0 else
             Off_Diagonal (L, I, J, Inverse_Pivot (Values (J)))))))
   is
      A : constant Vector := Prefix (L, J, J - 1);
      S, Root, Inv, Value : Real;
   begin
      Values := (others => 0.0);
      Result := Numeric_Limit;
      S := L (J, J);
      if J > 1 then S := S - Reductions.Dot (A, A); end if;
      pragma Assert (Static => S = Diagonal_Residual (L, J));
      Deficient := S < Floor;
      if Deficient then S := Floor; end if;
      Root := Math.Sqrt (S);
      if Root not in Pivot then return; end if;
      Values (J) := Root;
      if not Deficient then
         Inv := Inverse_Pivot (Root);
         for I in J + 1 .. L'Last (1) loop
            Value := Scaled_Residual (L (I, J), Reductions.Dot (Prefix (L, I, J - 1), A), Inv);
            pragma Assert (Static => Value = Off_Diagonal (L, I, J, Inv));
            if Value not in Operand then return; end if;
            Values (I) := Value;
            pragma Loop_Invariant (for all K in Values'Range => Values (K) in Operand);
            pragma Loop_Invariant (Values (J) = Root);
            pragma Loop_Invariant (Static => (for all K in J + 1 .. I =>
              Values (K) = Off_Diagonal (L, K, J, Inv)));
         end loop;
      end if;
      Result := Success;
   end Prepare_Column;

   procedure Store_Column (L : in out Matrix; J : Positive; Values : Vector)
     with Global => null,
     Pre => Square (L) and then Bounded (L) and then J in L'Range (1)
       and then Values'First = J and then Values'Last = L'Last (1)
       and then (for all V of Values => V in Operand),
     Post => Bounded (L)
       and then (for all I in J .. L'Last (1) => L (I, J) = Values (I))
       and then (for all I in L'Range (1) => (for all K in L'Range (2) =>
         (if K /= J or else I < J then L (I, K) = L'Old (I, K))))
   is
   begin
      for I in Values'Range loop
         L (I, J) := Values (I);
         pragma Loop_Invariant (Bounded (L));
         pragma Loop_Invariant (for all K in J .. I => L (K, J) = Values (K));
         pragma Loop_Invariant (for all P in L'Range (1) => (for all Q in L'Range (2) =>
           (if Q /= J or else P < J or else P > I then L (P, Q) = L'Loop_Entry (P, Q))));
      end loop;
   end Store_Column;

   procedure Factor_Column
     (L : in out Matrix; J : Positive; Floor : Pivot;
      Deficient : out Boolean; Result : out Status)
   is
      Values : Vector (J .. L'Last (1));
   begin
      Prepare_Column (L, J, Floor, Values, Deficient, Result);
      if Result /= Success then return; end if;
      Store_Column (L, J, Values);
   end Factor_Column;

   procedure Factor
     (M : Matrix; L : out Matrix; Rank : out Natural; Result : out Status;
      Floor : Pivot := 1.0e-15)
   is
      Deficient : Boolean;
   begin
      L := M;
      Rank := M'Length (1);
      for J in L'Range (1) loop
         Factor_Column (L, J, Floor, Deficient, Result);
         if Result /= Success then return; end if;
         if Deficient then Rank := Rank - 1; end if;
         pragma Loop_Invariant (Bounded (L));
         pragma Loop_Invariant (Rank in L'Length (1) - J .. L'Length (1));
         pragma Loop_Invariant (for all I in 1 .. J => L (I, I) in Pivot);
         pragma Loop_Invariant (for all I in L'Range (1) => (for all K in L'Range (2) =>
           (if K > I then L (I, K) = M (I, K))));
      end loop;
      Result := Success;
   end Factor;
   function Subtract_Term (Acc : Real; A, B : Operand; Count : Positive) return Real is
   begin
      return Acc - A * B;
   end Subtract_Term;

   procedure Unfold_Backward_Sum (L : Matrix; X : Vector; I : Positive; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Square (L) and then Bounded (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand)
       and then I in X'Range and then Count <= X'Length - I,
     Post => Backward_Sum (L, X, I, Count) =
       (if Count = 0 then X (I) else
         Subtract_Term (Backward_Sum (L, X, I, Count - 1),
                        L (I + Count, I), X (I + Count), Count))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Backward_Sum);
   begin
      null;
   end Unfold_Backward_Sum;

   procedure Forward_Row (L : Matrix; X : in out Vector; I : Positive; Result : out Status) is
      S, Value : Real;
   begin
      Result := Numeric_Limit;
      S := X (I);
      if I > 1 then S := S - Reductions.Dot (Prefix (L, I, I - 1), X (1 .. I - 1)); end if;
      Value := S / L (I, I);
      if Value not in Operand then return; end if;
      X (I) := Value;
      Result := Success;
   end Forward_Row;

   procedure Backward_Row (L : Matrix; X : in out Vector; I : Positive; Result : out Status) is
      Before : constant Vector := X with Ghost => Static;
      S : Real := X (I);
      Value : Real;
   begin
      Result := Numeric_Limit;
      Unfold_Backward_Sum (L, Before, I, 0);
      for Count in 1 .. X'Length - I loop
         pragma Loop_Invariant (Static => S = Backward_Sum (L, Before, I, Count - 1));
         pragma Loop_Invariant (abs S <= Real (Count) * Model.Step_Bound);
         S := Subtract_Term (S, L (I + Count, I), X (I + Count), Count);
         Unfold_Backward_Sum (L, Before, I, Count);
         pragma Assert (Static => S = Backward_Sum (L, Before, I, Count));
      end loop;
      pragma Assert (Static => S = Backward_Sum (L, Before, I, X'Length - I));
      Value := S / L (I, I);
      if Value not in Operand then return; end if;
      X (I) := Value;
      Result := Success;
   end Backward_Row;

   procedure Backsolve (L : Matrix; B : Vector; X : out Vector; Result : out Status) is
   begin
      X := B;
      for I in X'Range loop
         Forward_Row (L, X, I, Result);
         pragma Assert (for all V of X => V in Operand);
         if Result /= Success then return; end if;
         pragma Loop_Invariant (for all V of X => V in Operand);
      end loop;
      for I in reverse X'Range loop
         Backward_Row (L, X, I, Result);
         pragma Assert (for all V of X => V in Operand);
         if Result /= Success then return; end if;
         pragma Loop_Invariant (for all V of X => V in Operand);
      end loop;
      pragma Assert (for all V of X => V in Operand);
      Result := Success;
   end Backsolve;
end MJ.Constraint_Solvers.Dense_Cholesky;

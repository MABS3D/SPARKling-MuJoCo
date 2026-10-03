package body MJ.Constraint_Solvers.Cholesky with SPARK_Mode is
   package Math renames MJ.Quaternion_Math;

   function Start (Value : Real) return Sum_Result is
   begin
      if Value not in Accumulator then return (0.0, False); end if;
      return (Value, True);
   end Start;

   function Subtract (S : Accumulator; A, B : Real) return Sum_Result is
      Value : constant Real := S - A * B;
   begin
      return Start (Value);
   end Subtract;

   procedure Store (L : in out Matrix; I, K : Positive; Value : Real)
     with Global => null, Inline_Always,
     Pre => (Static => Square (L) and then Bounded (L) and then Triangular (L)
       and then I in L'Range (1) and then K in 1 .. I and then Value in Operand),
     Post => (Static => Bounded (L) and then Triangular (L)
       and then L (I, K) = Value
       and then (for all P in L'Range (1) => (for all Q in L'Range (2) =>
         (if P /= I or else Q /= K then L (P, Q) = L'Old (P, Q)))))
   is
   begin
      L (I, K) := Value;
   end Store;

   procedure Unfold_Factor_Sum
     (M, L : Matrix; I, K : Positive; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (L)
       and then M'Length (1) = L'Length (1) and then Bounded (L)
       and then I in M'Range (1) and then K in 1 .. I and then Count < K,
     Post => Factor_Sum (M, L, I, K, Count) =
       (if Count = 0 then Start (M (I, K)) else
        Extend (Factor_Sum (M, L, I, K, Count - 1), L (I, Count), L (K, Count)))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Factor_Sum);
   begin
      null;
   end Unfold_Factor_Sum;

   procedure Equal_Extensions
     (S, T : Sum_Result; A, B, C, D : Operand)
     with Ghost => Static, Global => null,
     Pre => S = T and then A = C and then B = D,
     Post => Extend (S, A, B) = Extend (T, C, D)
   is
   begin
      null;
   end Equal_Extensions;

   --  Later cell writes cannot change an already accumulated prefix. This
   --  induction is the bridge from Factor_Cell's old-workspace contract to
   --  the final factor's global ordered floating-point relation.
   procedure Preserve_Factor_Sum
     (M, Before, After : Matrix; I, K : Positive; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (Before) and then Square (After)
       and then M'Length (1) = Before'Length (1)
       and then M'Length (1) = After'Length (1)
       and then Bounded (Before) and then Bounded (After)
       and then I in M'Range (1) and then K in 1 .. I and then Count < K
       and then (for all T in 1 .. Count =>
         Before (I, T) = After (I, T) and then Before (K, T) = After (K, T)),
     Post => Factor_Sum (M, Before, I, K, Count) =
       Factor_Sum (M, After, I, K, Count),
     Subprogram_Variant => (Decreases => Count)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Extend);
   begin
      Unfold_Factor_Sum (M, Before, I, K, Count);
      Unfold_Factor_Sum (M, After, I, K, Count);
      if Count > 0 then
         Preserve_Factor_Sum (M, Before, After, I, K, Count - 1);
         pragma Assert (Before (I, Count) = After (I, Count));
         pragma Assert (Before (K, Count) = After (K, Count));
         pragma Assert (Factor_Sum (M, Before, I, K, Count - 1) =
           Factor_Sum (M, After, I, K, Count - 1));
         Equal_Extensions
           (Factor_Sum (M, Before, I, K, Count - 1),
            Factor_Sum (M, After, I, K, Count - 1),
            Before (I, Count), Before (K, Count),
            After (I, Count), After (K, Count));
      end if;
   end Preserve_Factor_Sum;

   procedure Factor_Cell
     (M : Matrix; L : in out Matrix; I, K : Positive; Floor : Pivot;
      Result : out Status)
     with Global => null, Inline,
     Pre => (Static => Square (M) and then Square (L)
       and then M'Length (1) = L'Length (1) and then Bounded (L)
       and then Triangular (L) and then I in M'Range (1) and then K in 1 .. I
       and then (for all P in 1 .. I - 1 => L (P, P) in Pivot)),
     Post => (Static => Bounded (L) and then Triangular (L)
       and then (for all P in 1 .. I - 1 => L (P, P) in Pivot)
       and then (for all P in L'Range (1) => (for all Q in L'Range (2) =>
          (if P /= I or else Q /= K then L (P, Q) = L'Old (P, Q))))
       and then (if Result /= Success then L = L'Old)
       and then (if Result = Success then
         Factor_Sum (M, L'Old, I, K, K - 1).OK and then
         (if I = K then L (I, K) in Pivot
           and then Factor_Sum (M, L'Old, I, K, K - 1).Value >= Floor
           and then L (I, K) = Math.Sqrt (Factor_Sum (M, L'Old, I, K, K - 1).Value)
          else L (I, K) = Divide (Factor_Sum (M, L'Old, I, K, K - 1).Value,
                                 L'Old (K, K)))))
   is
      S : Sum_Result := Start (M (I, K));
      Root : Real;
      Value : Real;
   begin
      Result := Numeric_Limit;
      Unfold_Factor_Sum (M, L, I, K, 0);
      if not S.OK then return; end if;
      for T in 1 .. K - 1 loop
         pragma Loop_Invariant (Static => S.OK and then
           S = Factor_Sum (M, L, I, K, T - 1));
         S := Subtract (S.Value, L (I, T), L (K, T));
         if not S.OK then return; end if;
         Unfold_Factor_Sum (M, L, I, K, T);
         pragma Assert (Static => S = Factor_Sum (M, L, I, K, T));
      end loop;
      pragma Assert (Static => S = Factor_Sum (M, L, I, K, K - 1));
      if I = K then
         if S.Value < Floor then Result := Not_Positive_Definite; return; end if;
         Root := Math.Sqrt (S.Value);
         --  Keep the existing runtime sqrt boundary explicit. Its contract
         --  does not provide an upper bound; no accuracy axiom is added.
         if Root not in Pivot then return; end if;
         Value := Root;
      else
         Value := Divide (S.Value, L (K, K));
      end if;
      Store (L, I, K, Value);
      pragma Assert (Static => Bounded (L));
      pragma Assert (Static => Triangular (L));
      pragma Assert (Static => (for all P in 1 .. I - 1 => L (P, P) in Pivot));
      Result := Success;
   end Factor_Cell;

   procedure Factor (M : Matrix; L : out Matrix; Result : out Status;
                     Floor : Pivot := 1.0e-15) is
   begin
      L := (others => (others => 0.0));
      for I in M'Range (1) loop
         for K in 1 .. I loop
            declare
            begin
               Factor_Cell (M, L, I, K, Floor, Result);
               pragma Assert_And_Cut (Static => Bounded (L) and then Triangular (L)
                 and then (for all P in 1 .. I - 1 => L (P, P) in Pivot)
                 and then (if Result = Success and then K = I then L (I, I) in Pivot));
               if Result /= Success then return; end if;
            end;
            pragma Loop_Invariant (Static => Bounded (L) and then Triangular (L));
            pragma Loop_Invariant (Static => (for all P in 1 .. I - 1 => L (P, P) in Pivot));
            pragma Loop_Invariant (Static => (if K = I then L (I, I) in Pivot));
         end loop;
         pragma Loop_Invariant (Static => Bounded (L) and then Triangular (L));
         pragma Loop_Invariant (Static => (for all P in 1 .. I => L (P, P) in Pivot));
      end loop;
      pragma Assert (Static => Bounded (L));
      pragma Assert (Static => Triangular (L));
      pragma Assert (Static => Positive_Diagonal (L));
      Result := Success;
   end Factor;

   procedure Unfold_Substitution_Sum
     (L : Matrix; X : Vector; RHS : Real; I, First : Positive;
      Count : Natural; Transposed : Boolean)
     with Ghost => Static, Global => null,
     Pre => Square (L) and then Bounded (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand)
       and then I in X'Range and then First <= X'Length + 1
       and then Count <= (X'Length + 1) - First,
     Post => Substitution_Sum (L, X, RHS, I, First, Count, Transposed) =
       (if Count = 0 then Start (RHS) else
        Extend (Substitution_Sum (L, X, RHS, I, First, Count - 1, Transposed),
          (if Transposed then L ((First + Count) - 1, I)
           else L (I, (First + Count) - 1)), X ((First + Count) - 1)))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Substitution_Sum);
   begin
      null;
   end Unfold_Substitution_Sum;

   procedure Substitute_Row
     (L : Matrix; RHS : Real; X : in out Vector; I : Positive;
      Transposed : Boolean; Result : out Status)
     with Global => null,
     Pre => (Static => Square (L) and then Bounded (L) and then Positive_Diagonal (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand) and then I in X'Range),
     Post => (Static => (for all V of X => V in Operand)
       and then Result in Success | Numeric_Limit
       and then (for all K in X'Range => (if K /= I then X (K) = X'Old (K)))
       and then (if Result /= Success then X = X'Old)
       and then (if Result = Success then
         Substitution_Sum (L, X'Old, RHS, I, (if Transposed then I + 1 else 1),
           (if Transposed then X'Length - I else I - 1), Transposed).OK
         and then X (I) = Divide
           (Substitution_Sum (L, X'Old, RHS, I, (if Transposed then I + 1 else 1),
              (if Transposed then X'Length - I else I - 1), Transposed).Value,
            L (I, I)))
       and then (if RHS = 0.0 and then (for all V of X'Old => V = 0.0)
                 then Result = Success and then (for all V of X => V = 0.0)))
   is
      First : constant Positive := (if Transposed then I + 1 else 1);
      Count : constant Natural := (if Transposed then X'Length - I else I - 1);
      S : Sum_Result := Start (RHS);
   begin
      Result := Numeric_Limit;
      Unfold_Substitution_Sum (L, X, RHS, I, First, 0, Transposed);
      if not S.OK then return; end if;
      for T in 1 .. Count loop
         pragma Loop_Invariant (Static => S.OK and then
           S = Substitution_Sum (L, X, RHS, I, First, T - 1, Transposed));
         pragma Loop_Invariant (Static =>
           (if RHS = 0.0 and then (for all V of X => V = 0.0)
            then S.Value = 0.0));
         S := Subtract (S.Value,
           (if Transposed then L ((First + T) - 1, I) else L (I, (First + T) - 1)),
           X ((First + T) - 1));
         if not S.OK then return; end if;
         Unfold_Substitution_Sum (L, X, RHS, I, First, T, Transposed);
         pragma Assert (Static =>
           S = Substitution_Sum (L, X, RHS, I, First, T, Transposed));
      end loop;
      pragma Assert (Static =>
        S = Substitution_Sum (L, X, RHS, I, First, Count, Transposed));
      X (I) := Divide (S.Value, L (I, I));
      Result := Success;
   end Substitute_Row;

   procedure Backsolve (L : Matrix; B : Vector; X : out Vector;
                        Result : out Status) is
   begin
      X := (others => 0.0);
      for I in B'Range loop
         pragma Loop_Invariant (Static => (for all V of X => V in Operand));
         pragma Loop_Invariant (Static =>
           (if (for all V of B => V = 0.0) then (for all V of X => V = 0.0)));
         declare
         begin
            Substitute_Row (L, B (I), X, I, False, Result);
            pragma Assert_And_Cut (Static => Result in Success | Numeric_Limit
              and then (for all V of X => V in Operand)
              and then (if (for all V of B => V = 0.0)
                then Result = Success and then (for all V of X => V = 0.0)));
            if Result /= Success then return; end if;
         end;
      end loop;
      for I in reverse B'Range loop
         pragma Loop_Invariant (Static => (for all V of X => V in Operand));
         pragma Loop_Invariant (Static =>
           (if (for all V of B => V = 0.0) then (for all V of X => V = 0.0)));
         declare
         begin
            Substitute_Row (L, X (I), X, I, True, Result);
            pragma Assert_And_Cut (Static => Result in Success | Numeric_Limit
              and then (for all V of X => V in Operand)
              and then (if (for all V of B => V = 0.0)
                then Result = Success and then (for all V of X => V = 0.0)));
            if Result /= Success then return; end if;
         end;
      end loop;
      Result := Success;
   end Backsolve;
end MJ.Constraint_Solvers.Cholesky;

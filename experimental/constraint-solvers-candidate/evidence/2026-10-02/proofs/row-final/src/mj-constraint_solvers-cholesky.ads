with MJ.Quaternion_Math;

--  Proof boundary for the candidate's existing row-ordered factorization.
--  Numeric growth is reported before storing an invalid accumulator. This
--  preserves the solver's rejection policy, not C's pivot-clamping policy.
package MJ.Constraint_Solvers.Cholesky with SPARK_Mode is
   subtype Accumulator is Real range -1.0e100 .. 1.0e100;
   subtype Operand is Real range -1.0e120 .. 1.0e120;
   subtype Pivot is Real range 1.0e-15 .. 1.0e100;
   type Status is (Success, Not_Positive_Definite, Numeric_Limit);
   type Sum_Result is record
      Value : Accumulator := 0.0;
      OK : Boolean := False;
   end record;

   function Square (L : Matrix) return Boolean is
     (L'First (1) = 1 and then L'First (2) = 1
      and then L'Length (1) in 1 .. Max_Dofs
      and then L'Length (2) = L'Length (1)) with Ghost => Static;
   function Bounded (L : Matrix) return Boolean is
     (for all I in L'Range (1) =>
        (for all K in L'Range (2) => L (I, K) in Operand))
     with Ghost => Static;
   function Triangular (L : Matrix) return Boolean is
     (for all I in L'Range (1) =>
        (for all K in L'Range (2) => (if K > I then L (I, K) = 0.0)))
     with Ghost => Static;
   function Positive_Diagonal (L : Matrix) return Boolean is
     (for all I in L'Range (1) => L (I, I) in Pivot)
     with Ghost => Static, Pre => Square (L);

   function Start (Value : Real) return Sum_Result
     with Global => null, Inline_Always,
     Post => (Start'Result.OK = (Value in Accumulator)
       and then (if Start'Result.OK then Start'Result.Value = Value));

   function Subtract (S : Accumulator; A, B : Operand) return Sum_Result
     with Global => null, Inline_Always,
     Post => (Subtract'Result.OK = (S - A * B in Accumulator)
       and then (if Subtract'Result.OK then Subtract'Result.Value = S - A * B));

   function Divide (S : Accumulator; D : Pivot) return Operand is (S / D)
     with Global => null, Inline_Always, Post => Divide'Result = S / D;

   function Extend (S : Sum_Result; A, B : Operand) return Sum_Result is
     (if S.OK then Subtract (S.Value, A, B) else S)
     with Ghost => Static, Global => null;

   --  Ordered binary64 subtraction, with the same accumulator range as the
   --  original solver. A rejected prefix remains rejected in the model.
   function Factor_Sum
     (M, L : Matrix; I, K : Positive; Count : Natural) return Sum_Result is
     (if Count = 0 then Start (M (I, K)) else
        Extend (Factor_Sum (M, L, I, K, Count - 1), L (I, Count), L (K, Count)))
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (L)
       and then M'Length (1) = L'Length (1) and then Bounded (L)
       and then I in M'Range (1) and then K in 1 .. I and then Count < K,
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   function Substitution_Sum
     (L : Matrix; X : Vector; RHS : Real; I, First : Positive;
      Count : Natural; Transposed : Boolean) return Sum_Result is
     (if Count = 0 then Start (RHS) else
       Extend (Substitution_Sum (L, X, RHS, I, First, Count - 1, Transposed),
         (if Transposed then L ((First + Count) - 1, I)
          else L (I, (First + Count) - 1)), X ((First + Count) - 1)))
     with Ghost => Static, Global => null,
     Pre => Square (L) and then Bounded (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand)
       and then I in X'Range and then First <= X'Length + 1
       and then Count <= (X'Length + 1) - First,
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   procedure Factor (M : Matrix; L : out Matrix; Result : out Status;
                     Floor : Pivot := 1.0e-15)
     with Global => null,
     Pre => (Static => Square (M) and then L'First (1) = 1 and then L'First (2) = 1
       and then L'Length (1) = M'Length (1) and then L'Length (2) = M'Length (1)),
     Post => (Static => Bounded (L) and then Triangular (L)
       and then (if Result = Success then Positive_Diagonal (L)));

   --  The workspace is private to Solve. A failure publishes a bounded partial
   --  workspace; the outer solver preserves the user's A and Force vectors.
   procedure Backsolve (L : Matrix; B : Vector; X : out Vector;
                        Result : out Status)
     with Global => null,
     Pre => (Static => Square (L) and then Bounded (L) and then Positive_Diagonal (L)
       and then B'First = 1 and then B'Length = L'Length (1)
       and then X'First = 1 and then X'Length = B'Length),
     Post => (Static => Result in Success | Numeric_Limit
       and then (for all V of X => V in Operand)
       and then (if (for all V of B => V = 0.0)
                 then Result = Success and then (for all V of X => V = 0.0)));
end MJ.Constraint_Solvers.Cholesky;

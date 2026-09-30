with MJ.Types; use MJ.Types;
with MJ.Cholesky_Steps;

--  Zero-based row-major storage, matching mju_cholFactor/Solve/Update.
--  Only the lower triangle is read and changed. No allocation or hidden copy.
--  Numeric growth outside Operand is reported explicitly. On Numeric_Limit
--  the arrays contain a bounded partial result; no overflowing step is stored.
package MJ.Cholesky with SPARK_Mode is
   subtype Dimension is Natural range 0 .. 11_585;
   subtype Threshold is MJ.Cholesky_Steps.Threshold;
   subtype Position is Natural range 0 .. Max_Size-1;
   function Cell (N : Dimension; Row, Col : Natural) return Position is
     (Row*N+Col) with Global => null, Inline_Always,
     Pre => Row < N and then Col < N,
     Post => Cell'Result = Row*N+Col and then Cell'Result < N*N
       and then Cell'Result+(N-Col) <= N*N
       and then Cell'Result/N = Row and then Cell'Result mod N = Col;
   type Status is (Success, Numeric_Limit);
   function Bounded (A : Real_Array) return Boolean is
     (for all V of A => V in MJ.Cholesky_Steps.Operand) with Global => null;
   function Is_Zero (A : Real_Array) return Boolean is
     (for all V of A => V = 0.0) with Ghost => Static, Global => null;
   function Wide_Bounded (A : Real_Array) return Boolean is
     (for all V of A => V in MJ.Cholesky_Steps.Wide_Operand) with Global => null;

   function Shape (A : Real_Array; N : Dimension) return Boolean is
     (A'First = 0 and then A'Last = N*N-1) with Global => null;
   function Vector_Shape (X : Real_Array; N : Dimension) return Boolean is
     (X'First = 0 and then X'Last = N-1) with Global => null;
   function Positive_Prefix (A : Real_Array; N : Dimension; Count : Natural) return Boolean is
     (for all I in 0 .. Count-1 => A (Cell (N, I, I)) >= Min_Val)
     with Global => null, Pre => Shape (A, N) and then Count <= N;
   function Positive_Diagonal (A : Real_Array; N : Dimension) return Boolean is
     (Positive_Prefix (A, N, N)) with Global => null, Pre => Shape (A, N);
   function Same_Upper (A, B : Real_Array; N : Dimension) return Boolean is
     (for all T in A'Range =>
        (if N > 0 and then T/N < T mod N then A (T) = B (T)))
     with Ghost => Static, Global => null, Pre => Shape (A, N) and then Shape (B, N);
   procedure Upper_Transitive (A, B, C : Real_Array; N : Dimension)
     with Ghost => Static, Global => null,
     Pre => Shape (A, N) and then Shape (B, N) and then Shape (C, N)
       and then Same_Upper (A, B, N) and then Same_Upper (B, C, N),
     Post => Same_Upper (A, C, N);

   --  Rank counts unclamped pivots, not the exact mathematical matrix rank.
   --  A deficient column is decoupled exactly as in MuJoCo 3.14.0.
   procedure Factor (A : in out Real_Array; N : Dimension;
                     Minimum : Threshold; Rank : out Natural; Result : out Status)
     with Global => null, Pre => Shape (A, N) and then Bounded (A),
     Post => (Static => Bounded (A) and then Rank <= N and then Same_Upper (A, A'Old, N)
       and then (if Result = Success then Positive_Diagonal (A, N)));

   --  In-place RHS: solves L L' X = RHS. A is unchanged.
   procedure Solve (A : Real_Array; X : in out Real_Array; N : Dimension; Result : out Status)
     with Global => null,
     Pre => Shape (A, N) and then Vector_Shape (X, N)
       and then Bounded (A) and then Bounded (X) and then Positive_Diagonal (A, N),
     Post => (Static => Bounded (X) and then (if Is_Zero (X'Old) then Is_Zero (X) and then Result = Success));

   --  L L' +/- X X'. X is destructive workspace, like the C API.
   --  Downdates clamp pivots below mjMINVAL and continue, returning the rank.
   procedure Update (A, X : in out Real_Array; N : Dimension;
                     Plus : Boolean; Rank : out Natural; Result : out Status)
     with Global => null,
     Pre => Shape (A, N) and then Vector_Shape (X, N)
       and then Wide_Bounded (A) and then Wide_Bounded (X) and then Positive_Diagonal (A, N),
     Post => (Static => Wide_Bounded (A) and then Wide_Bounded (X)
       and then Rank <= N and then Same_Upper (A, A'Old, N)
       and then (if N > 0 then X (0) = X'Old (0))
       and then (if (for all I in X'Range => X'Old (I) = 0.0)
                 then A = A'Old and then X = X'Old and then Rank = N and then Result = Success)
       and then (if Result = Success then Positive_Diagonal (A, N)));
end MJ.Cholesky;

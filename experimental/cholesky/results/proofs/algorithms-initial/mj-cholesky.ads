with MJ.Types; use MJ.Types;
with MJ.Cholesky_Steps;

--  Zero-based row-major storage, matching mju_cholFactor/Solve/Update.
--  Only the lower triangle is read and changed. No allocation or hidden copy.
--  The scalar equations are proved separately. Composition of numeric bounds
--  for these iterative routines is pending; see verification.md.
package MJ.Cholesky with SPARK_Mode is
   subtype Dimension is Natural range 0 .. 11_585;
   subtype Threshold is MJ.Cholesky_Steps.Threshold;

   function Shape (A : Real_Array; N : Dimension) return Boolean is
     (A'First = 0 and then A'Length = N * N) with Global => null;
   function Vector_Shape (X : Real_Array; N : Dimension) return Boolean is
     (X'First = 0 and then X'Length = N) with Global => null;
   function Positive_Diagonal (A : Real_Array; N : Dimension) return Boolean is
     (for all I in 0 .. N - 1 => A (I * N + I) > 0.0)
     with Global => null, Pre => Shape (A, N);
   function Same_Upper (A, B : Real_Array; N : Dimension) return Boolean is
     (for all I in 0 .. N - 1 =>
        (for all J in I + 1 .. N - 1 => A (I * N + J) = B (I * N + J)))
     with Ghost, Global => null, Pre => Shape (A, N) and then Shape (B, N);

   --  Rank counts unclamped pivots, not the exact mathematical matrix rank.
   --  A deficient column is decoupled exactly as in MuJoCo 3.14.0.
   procedure Factor (A : in out Real_Array; N : Dimension;
                     Minimum : Threshold; Rank : out Natural)
     with Global => null, Pre => Shape (A, N),
     Post => Rank <= N and then Same_Upper (A, A'Old, N);

   --  In-place RHS: solves L L' X = RHS. A is unchanged.
   procedure Solve (A : Real_Array; X : in out Real_Array; N : Dimension)
     with Global => null,
     Pre => Shape (A, N) and then Vector_Shape (X, N)
       and then Positive_Diagonal (A, N);

   --  L L' +/- X X'. X is destructive workspace, like the C API.
   --  Downdates clamp pivots below mjMINVAL and continue, returning the rank.
   procedure Update (A, X : in out Real_Array; N : Dimension;
                     Plus : Boolean; Rank : out Natural)
     with Global => null,
     Pre => Shape (A, N) and then Vector_Shape (X, N)
       and then Positive_Diagonal (A, N),
     Post => Rank <= N and then Same_Upper (A, A'Old, N)
       and then (if N > 0 then X (0) = X'Old (0))
       and then (if (for all I in X'Range => X'Old (I) = 0.0)
                 then A = A'Old and then X = X'Old and then Rank = N);
end MJ.Cholesky;

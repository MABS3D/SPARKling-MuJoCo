with MJ.Constraint_Solvers.Dense_Cholesky;

--  MuJoCo 3.14 symbolic/numeric reverse Cholesky, H = L' L.
--  Structural zero entries are retained: their order affects sparse dots.
package MJ.Constraint_Solvers.Sparse_Cholesky with SPARK_Mode is
   package Dense renames MJ.Constraint_Solvers.Dense_Cholesky;
   subtype Operand is Dense.Operand;
   subtype Pivot is Dense.Pivot;
   type Status is (Success, Invalid_Pattern, Numeric_Limit);
   subtype Mask is Structural_Matrix;
   type Counts is array (Positive range <>) of Natural;
   type Indices is array (Positive range <>, Positive range <>) of Natural;
   type Pattern (N : Positive) is record
      Length, Transpose_Length : Counts (1 .. N);
      Column, Transpose_Row, Transpose_Position : Indices (1 .. N, 1 .. N);
   end record;

   function Valid (P : Pattern) return Boolean is
     (P.N <= Max_Dofs
      and then (for all R in 1 .. P.N =>
        P.Length (R) in 1 .. R and then P.Transpose_Length (R) in 1 .. P.N-R+1
        and then P.Column (R, P.Length (R)) = R
        and then P.Transpose_Row (R, 1) = R
        and then P.Transpose_Position (R, 1) = P.Length (R)
        and then (for all I in 1 .. P.Length (R) =>
          P.Column (R, I) in 1 .. R
          and then (if I > 1 then P.Column (R, I-1) < P.Column (R, I)))
        and then (for all K in 2 .. P.Transpose_Length (R) =>
          P.Transpose_Row (R, K) in R+1 .. P.N
          and then P.Transpose_Position (R, K) in 1 .. P.Length (P.Transpose_Row (R, K))
          and then P.Column (P.Transpose_Row (R, K), P.Transpose_Position (R, K)) = R)));

   --  Read the upper triangle. The two symbolic traversals retain C's CSC
   --  update order, which need not be sorted by row number.
   procedure Symbolic (H : Mask; P : out Pattern; Result : out Status) with
     Global => null,
     Pre => P.N <= Max_Dofs and then H'First (1) = 1 and then H'First (2) = 1
       and then H'Length (1) = P.N and then H'Length (2) = P.N,
     Post => (if Result = Success then Valid (P));

   subtype Residual is Real range -1.0e245 .. 1.0e245;
   function Update (Value : Residual; A, B : Operand) return Real with
     Global => null, Inline_Always,
     Post => Update'Result = Value - A * B and then abs Update'Result <= 2.0e245;
   function Scale (Value : Residual; Inverse : Real) return Real with
     Global => null, Inline_Always, Pre => Inverse in 0.0 .. 1.0e15,
     Post => Scale'Result = Value * Inverse and then abs Scale'Result <= 1.0e260;

   procedure Factor (H : Matrix; P : Pattern; L : out Matrix;
                     Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) with
     Global => null,
     Pre => Valid (P) and then Dense.Square (H) and then Dense.Bounded (H)
       and then H'Length (1) = P.N and then L'First (1) = 1 and then L'First (2) = 1
       and then L'Length (1) = P.N and then L'Length (2) = P.N,
     Post => Rank <= P.N and then (if Result = Success then
       Dense.Bounded (L) and then Dense.Positive_Diagonal (L));

   procedure Backsolve (L : Matrix; P : Pattern; B : Vector; X : out Vector;
                        Result : out Status) with
     Global => null,
     Pre => Valid (P) and then Dense.Square (L) and then Dense.Bounded (L)
       and then Dense.Positive_Diagonal (L) and then L'Length (1) = P.N
       and then B'First = 1 and then B'Length = P.N
       and then X'First = 1 and then X'Length = P.N
       and then (for all V of B => V in Operand),
     Post => (if Result = Success then (for all V of X => V in Operand));
end MJ.Constraint_Solvers.Sparse_Cholesky;

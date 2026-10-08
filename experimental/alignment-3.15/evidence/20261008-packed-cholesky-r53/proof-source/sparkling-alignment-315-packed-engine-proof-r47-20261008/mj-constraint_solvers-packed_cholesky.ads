with MJ.Constraint_Solvers.Sparse_Cholesky;

--  Contiguous numeric rows for C's reverse sparse Cholesky. Symbolic CSC
--  traversal retains its established order; offsets are zero based.
package MJ.Constraint_Solvers.Packed_Cholesky with SPARK_Mode is
   package Sparse renames MJ.Constraint_Solvers.Sparse_Cholesky;
   package Dense renames Sparse.Dense;
   use type Sparse.Status;
   subtype Status is Sparse.Status;
   subtype Pattern is Sparse.Pattern;
   subtype Offsets is Sparse.Counts;
   subtype Operand is Sparse.Operand;
   subtype Pivot is Sparse.Pivot;

   function Valid_Offsets (P : Pattern; Address : Offsets) return Boolean is
     (Sparse.Valid (P) and then Address'First = 1 and then Address'Length = P.N
       and then Address (1) = 0
       and then (for all R in 1 .. P.N =>
         Address (R) <= R*(R-1)/2
         and then (if R > 1 then Address (R) = Address (R-1)+P.Length (R-1))))
     with Ghost => Static, Global => null;

   procedure Build_Offsets (P : Pattern; Address : out Offsets) with
     Global => null,
     Pre => (Static => Sparse.Valid (P) and then Address'First = 1 and then Address'Length = P.N),
     Post => (Static => Valid_Offsets (P, Address));

   function Slot (P : Pattern; Address : Offsets; R, K : Positive) return Positive is
     (Address (R)+K) with Global => null, Inline_Always,
     Pre => (Static => Valid_Offsets (P, Address) and then R <= P.N and then K <= P.Length (R)),
     Post => Slot'Result = Address (R)+K and then Slot'Result <= P.N*(P.N+1)/2;

   function Bounded (L : Vector) return Boolean is
     (for all V of L => V in Operand) with Ghost => Static, Global => null;
   function Diagonal (L : Vector; P : Pattern; Address : Offsets) return Boolean is
     (for all R in 1 .. P.N => L (Slot (P, Address, R, P.Length (R))) in Pivot)
     with Ghost => Static, Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then L'First = 1
       and then L'Length = P.N*(P.N+1)/2);

   procedure Pack_Row (L : Matrix; P : Pattern; Address : Offsets;
                       R : Positive; Values : in out Vector) with
     Global => null, Inline_Always,
     Pre => (Static => Valid_Offsets (P, Address) and then R <= P.N
       and then Dense.Square (L) and then Dense.Bounded (L) and then L'Length (1) = P.N
       and then Values'First = 1 and then Values'Length = P.N*(P.N+1)/2 and then Bounded (Values)),
     Post => (Static => Bounded (Values)
       and then (for all K in 1 .. P.Length (R) =>
         Values (Slot (P, Address, R, K)) = L (R, P.Column (R, K)))
       and then (for all S in Values'Range =>
         (if S <= Address (R) or else S > Address (R)+P.Length (R) then Values (S) = Values'Old (S))));

   procedure Pack (L : Matrix; P : Pattern; Address : Offsets; Values : out Vector) with
     Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then Dense.Square (L)
       and then Dense.Bounded (L) and then L'Length (1) = P.N
       and then Values'First = 1 and then Values'Length = P.N*(P.N+1)/2),
     Post => (Static => Bounded (Values) and then
       (for all R in 1 .. P.N => (for all K in 1 .. P.Length (R) =>
         Values (Slot (P, Address, R, K)) = L (R, P.Column (R, K)))));

   procedure Expand (Values : Vector; P : Pattern; Address : Offsets; L : out Matrix) with
     Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then Values'First = 1
       and then Values'Length = P.N*(P.N+1)/2 and then Bounded (Values)
       and then Dense.Square (L) and then L'Length (1) = P.N),
     Post => (Static => Dense.Bounded (L) and then
       (for all R in 1 .. P.N => (for all K in 1 .. P.Length (R) =>
         L (R, P.Column (R, K)) = Values (Slot (P, Address, R, K)))));

   procedure Factor (H : Matrix; P : Pattern; Address : Offsets; L : out Vector;
                     Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) with
     Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then Dense.Square (H) and then Dense.Bounded (H)
       and then H'Length (1) = P.N and then L'First = 1 and then L'Length = P.N*(P.N+1)/2),
     Post => (Static => Rank <= P.N and then (if Result = Sparse.Success then
       Bounded (L) and then Diagonal (L, P, Address)));

   procedure Backsolve (L : Vector; P : Pattern; Address : Offsets; B : Vector; X : out Vector;
                        Result : out Status) with
     Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then L'First = 1
       and then L'Length = P.N*(P.N+1)/2 and then Bounded (L) and then Diagonal (L, P, Address)
       and then B'First = 1 and then B'Length = P.N and then Bounded (B)
       and then X'First = 1 and then X'Length = P.N),
     Post => (Static => (if Result = Sparse.Success then Bounded (X)));
end MJ.Constraint_Solvers.Packed_Cholesky;

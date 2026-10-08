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

   subtype Dof_Index is Positive range 1 .. Max_Dofs;
   type Dof_List is array (Positive range <>) of Dof_Index;
   type Flat_Pattern (N, Stored : Positive) is record
      Length, Address, Transpose_Length, Transpose_Address : Offsets (1 .. N);
      Column, Transpose_Row : Dof_List (1 .. Stored);
      Transpose_Slot : Offsets (1 .. Stored);
   end record;

   type Symbolic_Plan (N : Positive) is record
      Length, Address, Transpose_Length, Transpose_Address : Offsets (1 .. N);
      Stored : Natural := 0;
   end record;

   function Valid_Plan (P : Symbolic_Plan) return Boolean is
     (P.N <= Max_Dofs and then P.Stored in P.N .. P.N*(P.N+1)/2
       and then P.Address (1) = 0 and then P.Transpose_Address (1) = 0
       and then (for all R in 1 .. P.N =>
         P.Length (R) in 1 .. R and then P.Transpose_Length (R) in 1 .. P.N-R+1
         and then P.Address (R) <= P.Stored-P.Length (R)
         and then P.Transpose_Address (R) <= P.Stored-P.Transpose_Length (R)
         and then P.Address (R) <= R*(R-1)/2)
       and then (for all R in 2 .. P.N =>
         P.Address (R) = P.Address (R-1)+P.Length (R-1)
         and then P.Transpose_Address (R) = P.Transpose_Address (R-1)+P.Transpose_Length (R-1))
       and then P.Address (P.N)+P.Length (P.N) = P.Stored
       and then P.Transpose_Address (P.N)+P.Transpose_Length (P.N) = P.Stored)
     with Ghost => Static, Global => null;

   function Symbolic_Mask (H : Sparse.Mask) return Sparse.Mask with
     Ghost => Static, Global => null,
     Pre => H'First (1) = 1 and then H'First (2) = 1
       and then H'Length (1) in 1 .. Max_Dofs and then H'Length (2) = H'Length (1),
     Post => Symbolic_Mask'Result'First (1) = 1 and then Symbolic_Mask'Result'First (2) = 1
       and then Symbolic_Mask'Result'Length (1) = H'Length (1)
       and then Symbolic_Mask'Result'Length (2) = H'Length (2);
   function Row_Nonzeros (H : Sparse.Mask; R : Positive) return Natural with
     Ghost => Static, Global => null,
     Pre => H'First (1) = 1 and then H'First (2) = 1
       and then H'Length (1) in 1 .. Max_Dofs and then H'Length (2) = H'Length (1)
       and then R <= H'Length (1),
     Post => Row_Nonzeros'Result <= R;
   function Column_Nonzeros (H : Sparse.Mask; R : Positive) return Natural with
     Ghost => Static, Global => null,
     Pre => H'First (1) = 1 and then H'First (2) = 1
       and then H'Length (1) in 1 .. Max_Dofs and then H'Length (2) = H'Length (1)
       and then R <= H'Length (1),
     Post => Column_Nonzeros'Result <= H'Length (1)-R+1;
   function Matches_Symbolic_Counts (H : Sparse.Mask; P : Symbolic_Plan) return Boolean with
     Ghost => Static, Global => null,
     Pre => H'First (1) = 1 and then H'First (2) = 1
       and then P.N <= Max_Dofs and then H'Length (1) = P.N and then H'Length (2) = P.N;
   procedure Count_Symbolic (H : Sparse.Mask; P : out Symbolic_Plan; Result : out Status) with
     Global => null,
     Pre => (Static => P.N <= Max_Dofs and then H'First (1) = 1 and then H'First (2) = 1
       and then H'Length (1) = P.N and then H'Length (2) = P.N),
     Post => (Static => Result = Sparse.Success and then Valid_Plan (P) and then Matches_Symbolic_Counts (H, P));

   function Flat_Bounds (F : Flat_Pattern) return Boolean is
     (F.N <= Max_Dofs and then F.Stored in F.N .. F.N*(F.N+1)/2
       and then F.Address (1) = 0 and then F.Transpose_Address (1) = 0
       and then (for all R in 1 .. F.N =>
         F.Length (R) in 1 .. R and then F.Transpose_Length (R) in 1 .. F.N-R+1
         and then F.Address (R) <= R*(R-1)/2
         and then F.Address (R) <= F.Stored-F.Length (R)
         and then F.Transpose_Address (R) <= F.Stored-F.Transpose_Length (R))
       and then (for all R in 2 .. F.N =>
         F.Address (R) = F.Address (R-1)+F.Length (R-1)
         and then F.Transpose_Address (R) = F.Transpose_Address (R-1)+F.Transpose_Length (R-1)))
     with Ghost => Static, Global => null;

   function Flat_Entry_Valid (F : Flat_Pattern; R, K : Positive) return Boolean is
     (F.Transpose_Row (F.Transpose_Address (R)+K) in R+1 .. F.N
       and then F.Transpose_Slot (F.Transpose_Address (R)+K) in
         F.Address (F.Transpose_Row (F.Transpose_Address (R)+K))+1 ..
         F.Address (F.Transpose_Row (F.Transpose_Address (R)+K))+
           F.Length (F.Transpose_Row (F.Transpose_Address (R)+K))
       and then F.Column (F.Transpose_Slot (F.Transpose_Address (R)+K)) = R)
     with Ghost => Static, Global => null,
     Pre => Flat_Bounds (F) and then R <= F.N and then K in 2 .. F.Transpose_Length (R);

   function Flat_Row_Valid (F : Flat_Pattern; R : Positive) return Boolean is
     (F.Column (F.Address (R)+F.Length (R)) = R
       and then (for all K in 1 .. F.Length (R) => F.Column (F.Address (R)+K) <= R
         and then (if K > 1 then F.Column (F.Address (R)+K-1) < F.Column (F.Address (R)+K)))
       and then F.Transpose_Row (F.Transpose_Address (R)+1) = R
       and then F.Transpose_Slot (F.Transpose_Address (R)+1) = F.Address (R)+F.Length (R)
       and then (for all K in 2 .. F.Transpose_Length (R) => Flat_Entry_Valid (F, R, K)))
     with Ghost => Static, Global => null,
     Pre => Flat_Bounds (F) and then R <= F.N;

   function Valid_Flat (F : Flat_Pattern) return Boolean is
     (Flat_Bounds (F)
       --  Expose the row bounds/order directly to clients of the flat layout.
       --  These clauses are already required by Flat_Row_Valid.
       and then (for all R in 1 .. F.N =>
         (for all K in 1 .. F.Length (R) => F.Column (F.Address (R)+K) <= R
           and then (if K > 1 then F.Column (F.Address (R)+K-1) < F.Column (F.Address (R)+K))))
       and then (for all R in 1 .. F.N => Flat_Row_Valid (F, R)))
     with Ghost => Static, Global => null;

   function Symbolic_Support (H : Sparse.Mask; F : Flat_Pattern) return Boolean with
     Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then H'First (1) = 1 and then H'First (2) = 1
       and then H'Length (1) = F.N and then H'Length (2) = F.N;
   procedure Fill_Symbolic (H : Sparse.Mask; P : Symbolic_Plan;
                            F : out Flat_Pattern; Result : out Status) with
     Global => null,
     Pre => (Static => Valid_Plan (P) and then P.N = F.N and then F.Stored = P.Stored
       and then H'First (1) = 1 and then H'First (2) = 1
       and then H'Length (1) = P.N and then H'Length (2) = P.N
       and then Matches_Symbolic_Counts (H, P)),
     Post => (Static => Result = Sparse.Success and then Valid_Flat (F) and then Symbolic_Support (H, F));




   function Matches_Flat (P : Pattern; F : Flat_Pattern) return Boolean is
     (Sparse.Valid (P) and then P.N = F.N and then Valid_Flat (F)
       and then (for all R in 1 .. P.N =>
         F.Length (R) = P.Length (R) and then F.Transpose_Length (R) = P.Transpose_Length (R)
         and then (for all K in 1 .. P.Length (R) => F.Column (F.Address (R)+K) = P.Column (R, K))
         and then (for all K in 1 .. P.Transpose_Length (R) =>
           F.Transpose_Row (F.Transpose_Address (R)+K) = P.Transpose_Row (R, K)
           and then F.Transpose_Slot (F.Transpose_Address (R)+K) =
             F.Address (P.Transpose_Row (R, K))+P.Transpose_Position (R, K))))
     with Ghost => Static, Global => null;

   procedure Legacy_Pattern (F : Flat_Pattern; P : out Pattern) with
     Global => null,
     Pre => (Static => Valid_Flat (F) and then P.N = F.N),
     Post => (Static => Sparse.Valid (P) and then Matches_Flat (P, F));

   procedure Build_Flat (P : Pattern; F : out Flat_Pattern) with
     Global => null,
     Pre => (Static => Sparse.Valid (P) and then P.N = F.N and then F.Stored = P.N*(P.N+1)/2),
     Post => (Static => Matches_Flat (P, F));

   function Flat_Diagonal (L : Vector; F : Flat_Pattern) return Boolean is
     (for all R in 1 .. F.N => L (F.Address (R)+F.Length (R)) in Pivot)
     with Ghost => Static, Global => null,
     Pre => (Static => Valid_Flat (F) and then L'First = 1 and then L'Length = F.Stored);

   procedure Factor_Flat (H : Matrix; F : Flat_Pattern; L : in out Vector;
                          Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) with
     Global => null,
     Pre => (Static => Valid_Flat (F) and then Dense.Square (H) and then Dense.Bounded (H)
       and then H'Length (1) = F.N and then L'First = 1 and then L'Length = F.Stored
       and then (for all V of L => V in Operand)),
     Post => (Static => Rank <= F.N and then (if Result = Sparse.Success then
       (for all V of L => V in Operand) and then Flat_Diagonal (L, F)));

   procedure Backsolve_Flat (L : Vector; F : Flat_Pattern; B : Vector; X : out Vector;
                             Result : out Status) with
     Global => null,
     Pre => (Static => Valid_Flat (F) and then L'First = 1 and then L'Length = F.Stored
       and then (for all V of L => V in Operand) and then Flat_Diagonal (L, F)
       and then B'First = 1 and then B'Length = F.N and then (for all V of B => V in Operand)
       and then X'First = 1 and then X'Length = F.N),
     Post => (Static => (if Result = Sparse.Success then (for all V of X => V in Operand)));

   procedure Expand_Flat (Values : Vector; F : Flat_Pattern; L : out Matrix) with
     Global => null,
     Pre => (Static => Valid_Flat (F) and then Values'First = 1 and then Values'Length = F.Stored
       and then (for all V of Values => V in Operand)
       and then L'First (1) = 1 and then L'First (2) = 1
       and then L'Length (1) = F.N and then L'Length (2) = F.N),
     Post => (Static => Dense.Bounded (L) and then (for all R in 1 .. F.N =>
       (for all K in 1 .. F.Length (R) => L (R, F.Column (F.Address (R)+K)) = Values (F.Address (R)+K))));
   procedure Pack_Flat (L : Matrix; F : Flat_Pattern; Values : out Vector) with
     Global => null,
     Pre => (Static => Valid_Flat (F) and then Dense.Square (L) and then Dense.Bounded (L)
       and then L'Length (1) = F.N and then Values'First = 1 and then Values'Length = F.Stored),
     Post => (Static => (for all V of Values => V in Operand) and then (for all R in 1 .. F.N =>
       (for all K in 1 .. F.Length (R) => Values (F.Address (R)+K) = L (R, F.Column (F.Address (R)+K)))));
   procedure Add_Mass_Flat (H : in out Matrix; M : Matrix; F : Flat_Pattern) with
     Global => null,
     Pre => (Static => Valid_Flat (F) and then Dense.Square (H) and then Dense.Square (M)
       and then H'Length (1) = F.N and then M'Length (1) = F.N
       and then (for all I in H'Range (1) => (for all J in H'Range (2) => H (I, J) in -1.0e100 .. 1.0e100))
       and then (for all I in M'Range (1) => (for all J in M'Range (2) => M (I, J) in -1.0e100 .. 1.0e100))),
     Post => (Static => (for all I in H'Range (1) => (for all J in H'Range (2) =>
       H (I, J) in -2.0e100 .. 2.0e100 and then H (I, J) =
         (if (for some K in 1 .. F.Length (I) => F.Column (F.Address (I)+K) = J)
          then H'Old (I, J)+M (I, J) else H'Old (I, J)))));

   function Valid_Offsets (P : Pattern; Address : Offsets) return Boolean is
     (Sparse.Valid (P) and then Address'First = 1 and then Address'Length = P.N
       and then Address (1) = 0
       and then (for all R in 1 .. P.N =>
         Address (R) <= R*(R-1)/2
         and then (if R > 1 then Address (R-1) <= (R-1)*(R-2)/2
           and then Address (R) = Address (R-1)+P.Length (R-1))))
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
       and then L'First (1) = 1 and then L'First (2) = 1
       and then L'Length (1) = P.N and then L'Length (2) = P.N),
     Post => (Static => Dense.Bounded (L) and then
       (for all R in 1 .. P.N => (for all K in 1 .. P.Length (R) =>
         L (R, P.Column (R, K)) = Values (Slot (P, Address, R, K)))));

   procedure Factor (H : Matrix; P : Pattern; Address : Offsets; L : in out Vector;
                     Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) with
     Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then Dense.Square (H) and then Dense.Bounded (H)
       and then H'Length (1) = P.N and then L'First = 1 and then L'Length = P.N*(P.N+1)/2
       and then Bounded (L)),
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

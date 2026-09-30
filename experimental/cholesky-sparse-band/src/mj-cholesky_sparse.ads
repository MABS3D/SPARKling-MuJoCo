with MJ.Cholesky_Arithmetic;
package MJ.Cholesky_Sparse with SPARK_Mode is
   use MJ.Cholesky_Arithmetic;
   --  CSR with sorted unique columns, independent row capacities, zero base.
   --  Lower rows include their diagonal as the last entry.
   function CSR_Valid (N : Size; Count, Adr, Col : Indices;
                       Capacity : Offset; Lower : Boolean) return Boolean is
     (Count'First = 0 and then Count'Length = N
      and then Adr'First = 0 and then Adr'Length = N
      and then Col'First = 0 and then Col'Length >= Capacity
      and then (for all R in 0 .. Integer (N) - 1 =>
        Count (R) <= N and then Adr (R) <= Capacity
        and then Count (R) <= Capacity - Adr (R)
        and then (if R < N - 1 then Adr (R + 1) >= Adr (R) + Count (R))
        and then (if Lower then Count (R) > 0
          and then Col (Adr (R) + Count (R) - 1) = R)
        and then (for all K in 0 .. Integer (Count (R)) - 1 =>
          Col (Adr (R) + K) < N
          and then (if Lower then Col (Adr (R) + K) <= R)
          and then (if K > 0 then Col (Adr (R) + K - 1) < Col (Adr (R) + K)))));
   function Transpose_Valid (N : Size; Count, Adr, Col, TCount, TAdr,
                             TCol, Map : Indices) return Boolean;
   function Lower_Source_Valid (N : Size; Count, Adr, Col : Indices;
                                Capacity : Offset) return Boolean is
     (CSR_Valid (N, Count, Adr, Col, Capacity, False)
      and then (for all R in 0 .. Integer (N) - 1 =>
        (for all K in 0 .. Integer (Count (R)) - 1 => Col (Adr (R) + K) <= R)));
   function Factor_Valid (A : Values; N : Size; Count, Adr, Col : Indices)
                         return Boolean is
     (A'First = 0 and then A'Length <= Offset'Last
      and then CSR_Valid (N, Count, Adr, Col, A'Length, True)
      and then (for all R in 0 .. Integer (N) - 1 =>
                  A (Adr (R) + Count (R) - 1) >= Min_Diag));

   --  Two passes, like mju_cholFactorSymbolic: first determine capacity,
   --  then build lower L and transpose with a direct map into L's values.
   --  H's UPPER pattern is read. No dense N*N scratch matrix is used.
   procedure Symbolic_Count (N : Size; HCount, HAdr, HCol : Indices;
                             Count, Adr, TCount, TAdr : out Indices;
                             NNZ : out Offset)
     with Pre => CSR_Valid (N, HCount, HAdr, HCol, HCol'Length, False)
       and then Count'First = 0 and then Count'Length = N
       and then Adr'First = 0 and then Adr'Length = N
       and then TCount'First = 0 and then TCount'Length = N
       and then TAdr'First = 0 and then TAdr'Length = N;
   procedure Symbolic_Fill (N : Size; HCount, HAdr, HCol : Indices;
                            Count, Adr, TCount, TAdr : Indices;
                            Col, TCol, Map : out Indices; Status : out Outcome)
     with Pre => CSR_Valid (N, HCount, HAdr, HCol, HCol'Length, False)
       and then Count'First = 0 and then Count'Length = N
       and then Adr'First = 0 and then Adr'Length = N
       and then TCount'First = 0 and then TCount'Length = N
       and then TAdr'First = 0 and then TAdr'Length = N
       and then Col'First = 0 and then Col'Length <= Offset'Last
       and then TCol'First = 0 and then TCol'Length <= Offset'Last
       and then Map'First = 0 and then Map'Length = TCol'Length,
       Post => (if Status = Success then
                  CSR_Valid (N, Count, Adr, Col, Col'Length, True)
                  and then Transpose_Valid (N, Count, Adr, Col, TCount, TAdr, TCol, Map));

   --  Reverse Cholesky: A = L^T L. Factor can add structural entries in
   --  preallocated rows. On a clamped pivot it keeps scaled off-diagonals,
   --  as mju_cholFactorSparse does. Rank counts unclamped pivots.
   procedure Factor (A : in out Values; N : Size; Count : in out Indices;
                     Adr : Indices; Col : in out Indices; Minimum : Scalar;
                     Rank : out Size; Status : out Outcome)
     with Pre => A'First = 0 and then A'Length <= Offset'Last
       and then CSR_Valid (N, Count, Adr, Col, A'Length, True)
       and then Minimum >= Min_Diag,
       Post => Rank <= N and then
         (if Status = Success then Factor_Valid (A, N, Count, Adr, Col));

   --  Reuse a symbolic pattern. Source H is lower CSR. Workspace is
   --  initialized here; its initial contents are immaterial. Missing closure
   --  is detected rather than silently discarding fill. Unlike Factor, C's
   --  numeric routine zeros off-diagonals when the pivot is clamped.
   procedure Numeric (H : Values; N : Size; HCount, HAdr, HCol : Indices;
                      Count, Adr, Col, TCount, TAdr, TCol, Map : Indices;
                      Minimum : Scalar; A : in out Values;
                      Workspace : in out Values; Rank : out Size;
                      Status : out Outcome)
     with Pre => H'First = 0 and then H'Length <= Offset'Last
       and then Lower_Source_Valid (N, HCount, HAdr, HCol, H'Length)
       and then A'First = 0 and then A'Length <= Offset'Last
       and then CSR_Valid (N, Count, Adr, Col, A'Length, True)
       and then Transpose_Valid (N, Count, Adr, Col, TCount, TAdr, TCol, Map)
       and then Workspace'First = 0 and then Workspace'Length = N
       and then Minimum >= Min_Diag,
       Post => Rank <= N and then
         (if Status = Success then Factor_Valid (A, N, Count, Adr, Col)
           and then (for all K in Workspace'Range => Workspace (K) = 0.0));
   procedure Solve (A, RHS : Values; N : Size; Count, Adr, Col : Indices;
                    X : out Values; Status : out Outcome)
     with Pre => Factor_Valid (A, N, Count, Adr, Col)
       and then RHS'First = 0 and then RHS'Length = N
       and then X'First = 0 and then X'Length = N;
   function Update_Closed (N : Size; Count, Adr, Col, XCol : Indices)
                          return Boolean;
   --  Rank-one update/downdate; fixed pattern must accommodate the fill.
   --  X and XCol stay unchanged. Empty X leaves A and Workspace unchanged.
   procedure Update (A : in out Values; N : Size; Count, Adr, Col : Indices;
                     X : Values; XCol : Indices; Plus : Boolean;
                     Workspace : in out Values; Rank : out Size;
                     Status : out Outcome)
     with Pre => Factor_Valid (A, N, Count, Adr, Col)
       and then X'First = 0 and then XCol'First = 0
       and then X'Length = XCol'Length and then X'Length <= N
       and then (for all K in XCol'Range => XCol (K) < N)
       and then (for all K in XCol'Range =>
                   (if K > 0 then XCol (K - 1) < XCol (K)))
       and then Update_Closed (N, Count, Adr, Col, XCol)
       and then Workspace'First = 0 and then Workspace'Length = N,
       Post => Rank <= N and then
         (if Status = Success then Factor_Valid (A, N, Count, Adr, Col))
         and then (if X'Length = 0 then A = A'Old and then Workspace = Workspace'Old);
end MJ.Cholesky_Sparse;

with MJ.Cholesky_Arithmetic;
package MJ.Cholesky_Band with SPARK_Mode is
   use MJ.Cholesky_Arithmetic;
   function Layout_Valid (N, Band, Dense : Size) return Boolean is
     (Dense <= N and then (Dense = N or else Band > 0));
   function Storage_Length (N, Band, Dense : Size) return Offset is
     ((N - Dense) * Band + Dense * N)
     with Pre => Layout_Valid (N, Band, Dense);
   function Diagonal (Row : Size; N, Band, Dense : Size) return Offset is
     (if Row < N - Dense then (Row + 1) * Band - 1
      else (N - Dense) * Band + (Row - (N - Dense)) * N + Row)
     with Pre => Layout_Valid (N, Band, Dense) and then Row < N,
       Post => Diagonal'Result < Storage_Length (N, Band, Dense);
   function Stored (K : Offset; N, Band, Dense : Size) return Boolean is
     (if K >= Storage_Length (N, Band, Dense) then False
      elsif K < (N - Dense) * Band then
         K mod Band >= Band - 1 - Natural'Min (K / Band, Band - 1)
      else (K - (N - Dense) * Band) mod N
             <= N - Dense + (K - (N - Dense) * Band) / N)
     with Pre => Layout_Valid (N, Band, Dense),
       Post => (if Stored'Result then N > 0 and then K < Storage_Length (N, Band, Dense));
   function Storage_Row (K : Offset; N, Band, Dense : Size) return Size is
     (if K < (N - Dense) * Band then K / Band
      else N - Dense + (K - (N - Dense) * Band) / N)
     with Pre => Layout_Valid (N, Band, Dense) and then Stored (K, N, Band, Dense),
       Post => Storage_Row'Result < N;
   function Storage_Column (K : Offset; N, Band, Dense : Size) return Size is
     (if K < (N - Dense) * Band then K / Band - (Band - 1 - K mod Band)
      else (K - (N - Dense) * Band) mod N)
     with Pre => Layout_Valid (N, Band, Dense) and then Stored (K, N, Band, Dense),
       Post => Storage_Column'Result <= Storage_Row (K, N, Band, Dense);
   function Shape (A : Values; N, Band, Dense : Size) return Boolean is
     (Layout_Valid (N, Band, Dense) and then A'First = 0
      and then A'Length = Storage_Length (N, Band, Dense));
   function Factor_Valid (A : Values; N, Band, Dense : Size) return Boolean is
     (Shape (A, N, Band, Dense)
      and then (for all I in 0 .. Integer (N) - 1 =>
                  A (Diagonal (I, N, Band, Dense)) >= Min_Diag));
   --  Pointwise model for the represented matrix; padding is not data.
   function Element (A : Values; N, Band, Dense, Row, Col : Size;
                     Symmetric : Boolean) return Scalar is
     (if Col > Row then
         (if not Symmetric or else (Col < N - Dense and then Col - Row >= Band) then 0.0
          else A (Diagonal (Col, N, Band, Dense) - (Col - Row)))
      elsif Row < N - Dense and then Row - Col >= Band then 0.0
      else A (Diagonal (Row, N, Band, Dense) - (Row - Col)))
     with Pre => Shape (A, N, Band, Dense) and then Row < N and then Col < N;

   --  A = L L^T; Dense final rows have full width. Min_Pivot is the
   --  minimum Schur pivot BEFORE square root, as in mju_cholFactorBand.
   --  Failure leaves the already computed prefix; no silent regularization.
   procedure Factor (A : in out Values; N, Band, Dense : Size;
                     Diag_Add, Diag_Mul : Scalar;
                     Min_Pivot : out Scalar; Status : out Outcome)
     with Pre => Shape (A, N, Band, Dense),
       Post => (if Status = Success then Factor_Valid (A, N, Band, Dense))
       and then (for all K in A'Range =>
                   (if not Stored (K, N, Band, Dense) then A (K) = A'Old (K)));
   procedure Solve (A : Values; RHS : Values; N, Band, Dense : Size;
                    X : out Values; Status : out Outcome)
     with Pre => Factor_Valid (A, N, Band, Dense)
       and then RHS'First = 0 and then RHS'Length = N
       and then X'First = 0 and then X'Length = N;
   procedure To_Dense (A : Values; N, Band, Dense : Size; Symmetric : Boolean;
                       Matrix : out Values)
     with Pre => Shape (A, N, Band, Dense)
       and then Matrix'First = 0 and then Matrix'Length = N * N,
       Post => (for all R in 0 .. Integer (N) - 1 =>
                  (for all C in 0 .. Integer (N) - 1 =>
                     Matrix (R * N + C) = Element (A, N, Band, Dense, R, C, Symmetric)));
   procedure From_Dense (Matrix : Values; N, Band, Dense : Size; A : in out Values)
     with Pre => Shape (A, N, Band, Dense)
       and then Matrix'First = 0 and then Matrix'Length = N * N,
       Post => (for all K in A'Range =>
                   (if Stored (K, N, Band, Dense) then
                      A (K) = Matrix (Storage_Row (K, N, Band, Dense) * N
                                      + Storage_Column (K, N, Band, Dense))
                    else A (K) = A'Old (K)));
   procedure Multiply (A, V : Values; N, Band, Dense : Size;
                       Vectors : Size; Symmetric : Boolean;
                       R : out Values; Status : out Outcome)
     with Pre => Shape (A, N, Band, Dense)
       and then V'First = 0 and then V'Length = N * Vectors
       and then R'First = 0 and then R'Length = N * Vectors;
end MJ.Cholesky_Band;

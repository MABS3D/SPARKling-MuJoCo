with MJ.Types; use MJ.Types;
package MJ.LU with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   Max_Order : constant := 4096;
   subtype Order is Natural range 0 .. Max_Order;
   subtype Position is Natural range 0 .. Max_Order*Max_Order-1;
   function Cell (N : Order; Row, Col : Natural) return Position is (Row*N+Col)
     with Global => null, Inline_Always, Pre => Row < N and then Col < N,
     Post => Cell'Result = Row*N+Col and then Cell'Result < N*N
       and then Cell'Result+(N-Col) <= N*N
       and then Cell'Result/N = Row and then Cell'Result mod N = Col;
   subtype Value is Real range -1.0e100 .. 1.0e100;
   type Status is (Success, Singular, Invalid_Structure, Fill_Required, Numeric_Limit);
   function Bounded (A : Real_Array) return Boolean is
     (for all X of A => X in Value) with Global => null;
   function Is_Zero (A : Real_Array) return Boolean is
     (for all V of A => V = 0.0) with Global => null;
   function Dense_Shape (A : Real_Array; N : Order) return Boolean is
     (A'First = 0 and then A'Last = N*N-1) with Global => null;
   function Vector_Shape (A : Real_Array; N : Order) return Boolean is
     (A'First = 0 and then A'Last = N-1) with Global => null;
   function Index_Shape (A : Int_Array; N : Order) return Boolean is
     (A'First = 0 and then A'Last = N-1) with Global => null;
   function Pivots_Valid (P : Int_Array; N : Order) return Boolean is
     (Index_Shape (P, N) and then (for all I in P'Range => P (I) in I .. N-1))
     with Global => null;
   function Prefix_Good (A : Real_Array; N : Order; Count : Natural) return Boolean is
     (for all R in 0 .. Count-1 => abs A (Cell (N, R, R)) >= Min_Val)
     with Global => null, Pre => Dense_Shape (A, N) and then Count <= N;
   function Stage_Bounded (A : Real_Array; Limit : Value) return Boolean is
     (for all V of A => abs V <= Limit) with Global => null;
   -- Canonical zero-based CSR: sorted unique columns, no overlapping rows.
   function CSR_Valid (N : Order; Row_Start, Column, Diagonal : Int_Array) return Boolean is
     (Row_Start'First = 0 and then Row_Start'Last = N
      and then Column'First = 0 and then Column'Last < Max_Size
      and then Index_Shape (Diagonal, N) and then Row_Start (0) = 0
      and then Row_Start (N) = Column'Length
      and then (for all I in 0 .. N-1 =>
        Row_Start (I) >= 0 and then Row_Start (I+1) > Row_Start (I)
        and then Row_Start (I+1) <= Column'Length
        and then Diagonal (I) in Row_Start (I) .. Row_Start (I+1)-1
        and then Column (Diagonal (I)) = I
        and then (for all K in Row_Start (I) .. Row_Start (I+1)-1 =>
          Column (K) in 0 .. N-1
          and then (if K > Row_Start (I) then Column (K) > Column (K-1)))))
     with Global => null;
   procedure Analyze (N : Order; Row_Start, Column : Int_Array;
                      Diagonal : out Int_Array; Result : out Status)
     with Global => null, Pre => Diagonal'First = 0 and then Diagonal'Last = N-1,
     Post => (if Result = Success then CSR_Valid (N, Row_Start, Column, Diagonal));
   -- Local arithmetic: unchanged output when the result exceeds Value.
   procedure Subtract_Product (X : in out Value; A, B : Value; Result : out Status)
     with Global => null,
     Post => Result = (if X'Old-A*B in Value then Success else Numeric_Limit)
       and then (if Result = Success then X = X'Old - A*B else X = X'Old)
       and then (if X'Old = 0.0 and then (A = 0.0 or else B = 0.0) then X = 0.0 and then Result = Success);
   procedure Multiply (X : in out Value; A : Value; Result : out Status)
     with Global => null,
     Post => Result = (if X'Old*A in Value then Success else Numeric_Limit)
       and then (if Result = Success then X = X'Old*A else X = X'Old);
   procedure Divide (X : in out Value; Pivot : Value; Result : out Status)
     with Global => null, Pre => abs Pivot >= Min_Val,
     Post => Result = (if X'Old/Pivot in Value then Success else Numeric_Limit)
       and then (if Result = Success then X = X'Old/Pivot else X = X'Old)
       and then (if X'Old = 0.0 then X = 0.0 and then Result = Success);
   pragma Inline_Always (Subtract_Product);
   pragma Inline_Always (Multiply);
   pragma Inline_Always (Divide);
   function Clamped (Pivot : Value) return Value
     with Global => null,
     Post => Clamped'Result =
       (if abs Pivot >= Min_Val then Pivot elsif Pivot < 0.0 then -Min_Val else Min_Val)
       and then abs Clamped'Result >= Min_Val;
   procedure Swap_Entries (A : in out Real_Array; I, J : Natural)
     with Global => null, Pre => Bounded (A) and then I in A'Range and then J in A'Range,
     Post => Bounded (A) and then (for all K in A'Range => A (K) =
       (if K=I then A'Old (J) elsif K=J then A'Old (I) else A'Old (K)))
       and then (if Is_Zero (A'Old) then Is_Zero (A));
   pragma Inline_Always (Swap_Entries);
   procedure Swap_Cells (A : in out Real_Array; N : Order; I, J, C : Natural)
     with Global => null,
     Pre => (Static => Dense_Shape (A, N) and then Bounded (A)
       and then I < N and then J < N and then I /= J and then C < N),
     Post => (Static => Bounded (A) and then (for all V in A'Range => A (V) =
       (if V/N = I and then V mod N = C then A'Old (Cell (N, J, C))
        elsif V/N = J and then V mod N = C then A'Old (Cell (N, I, C)) else A'Old (V))));
   pragma Inline_Always (Swap_Cells);
   procedure Store (A : in out Real_Array; N : Order; I, J : Natural; V : Value)
     with Global => null,
     Pre => (Static => Dense_Shape (A, N) and then Bounded (A) and then I < N and then J < N),
     Post => (Static => Bounded (A) and then (for all T in A'Range => A (T) =
       (if T/N = I and then T mod N = J then V else A'Old (T))));
   pragma Inline_Always (Store);

   procedure Row_Separation (N : Order; I : Natural)
     with Ghost => Static, Global => null, Pre => I < N,
     Post => (for all R in 0 .. N-1 =>
       (if R < I then R*N+N <= I*N
        elsif R > I then I*N+N <= R*N));
   procedure Swap_Rows (A : in out Real_Array; N : Order; I, J : Natural; Limit : Value := Value'Last)
     with Global => null, Pre => Dense_Shape (A, N) and then Bounded (A)
       and then I < N and then J < N and then Stage_Bounded (A, Limit),
     Post => Bounded (A) and then Stage_Bounded (A, Limit) and then
       (for all T in A'Range => A (T) =
         (if T/N = I then A'Old (Cell (N, J, T mod N))
          elsif T/N = J then A'Old (Cell (N, I, T mod N)) else A'Old (T)));
   subtype Small_Value is Real range -1.0e98 .. 1.0e98;
   subtype Multiplier_Value is Real range -2.0 .. 2.0;
   function Fast_Subtract (X, Y : Small_Value; M : Multiplier_Value;
                           Limit : Small_Value := Small_Value'Last) return Value
     with Global => null,
     Pre => Limit >= 2.0 and then abs X <= Limit and then abs Y <= Limit,
     Post => Fast_Subtract'Result = X-M*Y
       and then abs Fast_Subtract'Result <= 4.0 * Limit;
   pragma Inline_Always (Fast_Subtract);
   function Model_Subtract (X, M, Y : Value) return Real
     with Ghost => Static, Global => null,
     Post => Model_Subtract'Result = X-M*Y and then abs Model_Subtract'Result <= 1.1e200;


   function Magnitude (A : Real_Array) return Value
     with Global => null, Pre => Bounded (A),
     Post => Magnitude'Result in 2.0 .. Value'Last
       and then (for all X of A => abs X <= Magnitude'Result);
   function Find_Pivot (A : Real_Array; N : Order; K : Natural) return Natural
     with Global => null, Pre => Dense_Shape (A, N) and then Bounded (A) and then K < N,
     Post => Find_Pivot'Result in K .. N-1
       and then (for all I in K .. N-1 => abs A (Cell (N, I, K)) <= abs A (Cell (N, Find_Pivot'Result, K)));
   procedure Fast_Entry (A : in out Real_Array; N : Order; I, K, J : Natural;
                         M : Multiplier_Value; Limit : Small_Value)
     with Global => null,
     Pre => (Static => Dense_Shape (A, N) and then Bounded (A) and then K < I and then I < N
       and then K < J and then J < N and then Limit >= 2.0
       and then abs A (Cell (N, I, J)) <= Limit and then abs A (Cell (N, K, J)) <= Limit),
     Post => (Static => Bounded (A) and then abs A (Cell (N, I, J)) <= 4.0*Limit
       and then A (Cell (N, I, J)) = Model_Subtract (A'Old (Cell (N, I, J)), M, A'Old (Cell (N, K, J)))
       and then (for all V in A'Range => (if V /= Cell (N, I, J) then A (V) = A'Old (V)))
       and then (for all C in 0 .. N-1 =>
         (if C /= J then A (Cell (N, I, C)) = A'Old (Cell (N, I, C))))
       and then (for all C in 0 .. N-1 => A (Cell (N, K, C)) = A'Old (Cell (N, K, C)))
       and then (for all V in A'Range => (if V/N /= I then A (V) = A'Old (V))));
   procedure Checked_Entry (A : in out Real_Array; N : Order; I, K, J : Natural;
                            M : Value; Result : out Status)
     with Global => null,
     Pre => (Static => Dense_Shape (A, N) and then Bounded (A) and then K < I and then I < N
       and then K < J and then J < N),
     Post => (Static => Bounded (A) and then Result in Success | Numeric_Limit
       and then (if Result = Success then
         A (Cell (N, I, J)) = Model_Subtract (A'Old (Cell (N, I, J)), M, A'Old (Cell (N, K, J)))
         else A = A'Old)
       and then (for all V in A'Range => (if V /= Cell (N, I, J) then A (V) = A'Old (V)))
       and then (for all C in 0 .. N-1 =>
         (if C /= J then A (Cell (N, I, C)) = A'Old (Cell (N, I, C))))
       and then (for all C in 0 .. N-1 => A (Cell (N, K, C)) = A'Old (Cell (N, K, C)))
       and then (for all V in A'Range => (if V/N /= I then A (V) = A'Old (V))));
   pragma Inline_Always (Fast_Entry);
   pragma Inline_Always (Checked_Entry);
   procedure Update_Row_Fast (A : in out Real_Array; N : Order; K, I : Natural;
                              M : Multiplier_Value; Limit : Small_Value)
     with Global => null,
     Pre => Dense_Shape (A, N) and then Bounded (A) and then K < I and then I < N
       and then Limit >= 2.0
       and then (for all C in 0 .. N-1 => abs A (Cell (N, I, C)) <= Limit and then abs A (Cell (N, K, C)) <= Limit),
     Post => (Static => Bounded (A)
       and then (for all V in A'Range => A (V) =
         (if V/N = I and then V mod N > K then
           Model_Subtract (A'Old (V), M, A'Old (Cell (N, K, V mod N))) else A'Old (V)))
       and then (for all C in 0 .. N-1 => abs A (Cell (N, I, C)) <= 4.0*Limit));
   procedure Update_Row_Checked (A : in out Real_Array; N : Order; K, I : Natural;
                                 M : Value; Result : out Status)
     with Global => null,
     Pre => Dense_Shape (A, N) and then Bounded (A) and then K < I and then I < N,
     Post => (Static => Bounded (A) and then Result in Success | Numeric_Limit
       and then (for all V in A'Range =>
         (if V/N /= I or else V mod N <= K then A (V) = A'Old (V)))
       and then (if Result = Success then
         (for all C in K+1 .. N-1 => A (Cell (N, I, C)) = Model_Subtract (A'Old (Cell (N, I, C)), M, A'Old (Cell (N, K, C))))));
   pragma Inline_Always (Update_Row_Fast);
   pragma Inline_Always (Update_Row_Checked);
   procedure Eliminate_Row (A : in out Real_Array; N : Order; K, I : Natural;
                            Reciprocal : Value; Result : out Status; Input_Limit : Value := Value'Last)
     with Global => null, Pre => Dense_Shape (A, N) and then Bounded (A)
       and then K < I and then I < N and then Input_Limit >= 2.0
       and then (for all J in 0 .. N-1 => abs A (Cell (N, I, J)) <= Input_Limit
         and then abs A (Cell (N, K, J)) <= Input_Limit),
     Post => (Static => Bounded (A) and then Result in Success | Numeric_Limit
       and then (for all T in A'Range =>
         (if T/N /= I or else T mod N < K then A (T) = A'Old (T)))
       and then (if Result = Success then A (Cell (N, I, K)) = A'Old (Cell (N, I, K))*Reciprocal
         and then (for all J in K+1 .. N-1 =>
           A (Cell (N, I, J)) = Model_Subtract (A'Old (Cell (N, I, J)), A (Cell (N, I, K)), A'Old (Cell (N, K, J)))))
       and then (if Result = Success and then Input_Limit <= 1.0e98 then
         (for all J in 0 .. N-1 => abs A (Cell (N, I, J)) <= 4.0 * Input_Limit)));
   procedure Separate_Rows (N : Order; Row_Start, Column, Diagonal : Int_Array;
                            I, J : Natural)
     with Ghost => Static, Global => null,
     Pre => CSR_Valid (N, Row_Start, Column, Diagonal) and then I < J and then J < N,
     Post => Row_Start (I + 1) <= Row_Start (J);
   procedure Separate_From_Later (N : Order; Row_Start, Column, Diagonal : Int_Array;
                                  I : Natural)
     with Ghost => Static, Global => null,
     Pre => CSR_Valid (N, Row_Start, Column, Diagonal) and then I < N,
     Post => (for all J in I + 1 .. N - 1 => Row_Start (I + 1) <= Diagonal (J));
   -- Packed L (unit diagonal implicit) and U. P records sequential row swaps.
   -- Singular/Numeric_Limit leave a bounded, partially modified factorization.
   procedure Factor_Dense (A : in out Real_Array; N : Order;
                           P : out Int_Array; Result : out Status)
     with Global => null,
     Pre => Dense_Shape (A, N) and then Bounded (A) and then P'First = 0 and then P'Last = N-1,
     Post => Bounded (A) and then Pivots_Valid (P, N)
       and then Result in Success | Singular | Numeric_Limit
       and then (if Result = Success then (for all I in 0 .. N-1 => abs A (Cell (N, I, I)) >= Min_Val));
   procedure Solve_Dense (A : Real_Array; N : Order; P : Int_Array;
                          B : Real_Array; X : out Real_Array; Result : out Status)
     with Global => null,
     Pre => Dense_Shape (A, N) and then Bounded (A) and then Pivots_Valid (P, N)
       and then (for all I in 0 .. N-1 => abs A (Cell (N, I, I)) >= Min_Val)
       and then Vector_Shape (B, N) and then Bounded (B) and then X'First = 0 and then X'Last = N-1,
     Post => (Static => Bounded (X) and then Result in Success | Numeric_Limit
       and then (if Is_Zero (B) then Is_Zero (X) and then Result = Success));
   -- Reverse elimination, A=(I+U)*L. No pivot permutations or fill allocation.
   -- Remaining is caller-owned scratch, length N. First_Clamped is the first
   -- row visited in reverse order whose pivot was clamped, or -1.
   procedure Factor_Sparse
     (A : in out Real_Array; N : Order; Row_Start, Column, Diagonal : Int_Array;
      Remaining : out Int_Array; First_Clamped : out Integer; Result : out Status)
     with Global => null,
     Pre => CSR_Valid (N, Row_Start, Column, Diagonal)
       and then A'First = 0 and then A'Last = Column'Last and then Bounded (A)
       and then Remaining'First = 0 and then Remaining'Last = N-1,
     Post => Bounded (A) and then First_Clamped in -1 .. N-1
       and then Result in Success | Fill_Required | Invalid_Structure | Numeric_Limit
       and then (if Result = Success then
         (for all I in 0 .. N-1 => abs A (Diagonal (I)) >= Min_Val
           and then Remaining (I) = Diagonal (I)-Row_Start (I)));
   procedure Solve_Sparse
     (A : Real_Array; N : Order; Row_Start, Column, Diagonal : Int_Array;
      B : Real_Array; X : out Real_Array; Result : out Status)
     with Global => null,
     Pre => CSR_Valid (N, Row_Start, Column, Diagonal)
       and then A'First = 0 and then A'Last = Column'Last and then Bounded (A)
       and then (for all I in 0 .. N-1 => abs A (Diagonal (I)) >= Min_Val)
       and then Vector_Shape (B, N) and then Bounded (B) and then X'First = 0 and then X'Last = N-1,
     Post => (Static => Bounded (X) and then Result in Success | Numeric_Limit
       and then (if Is_Zero (B) then Is_Zero (X) and then Result = Success));
   pragma Inline_Always (Find_Pivot);
   pragma Inline_Always (Magnitude);
   pragma Inline_Always (Eliminate_Row);
   pragma Inline_Always (Swap_Rows);
end MJ.LU;

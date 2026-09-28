with MJ.Types; use MJ.Types;
package MJ.LU with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   Max_Order : constant := 4096;
   subtype Order is Natural range 0 .. Max_Order;
   subtype Value is Real range -1.0e100 .. 1.0e100;
   type Status is (Success, Singular, Invalid_Structure, Fill_Required, Numeric_Limit);
   function Bounded (A : Real_Array) return Boolean is
     (for all X of A => X in Value) with Global => null;
   function Dense_Shape (A : Real_Array; N : Order) return Boolean is
     (A'First = 0 and then A'Last = N*N-1) with Global => null;
   function Vector_Shape (A : Real_Array; N : Order) return Boolean is
     (A'First = 0 and then A'Last = N-1) with Global => null;
   function Index_Shape (A : Int_Array; N : Order) return Boolean is
     (A'First = 0 and then A'Last = N-1) with Global => null;
   function Pivots_Valid (P : Int_Array; N : Order) return Boolean is
     (Index_Shape (P, N) and then (for all I in P'Range => P (I) in I .. N-1))
     with Global => null;
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
     Post => Result in Success | Numeric_Limit and then
       (if Result = Success then X = X'Old - A*B else X = X'Old);
   procedure Multiply (X : in out Value; A : Value; Result : out Status)
     with Global => null,
     Post => Result in Success | Numeric_Limit and then
       (if Result = Success then X = X'Old*A else X = X'Old);
   procedure Divide (X : in out Value; Pivot : Value; Result : out Status)
     with Global => null, Pre => abs Pivot >= Min_Val,
     Post => Result in Success | Numeric_Limit and then
       (if Result = Success then X = X'Old/Pivot else X = X'Old);
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
       (if K=I then A'Old (J) elsif K=J then A'Old (I) else A'Old (K)));
   pragma Inline_Always (Swap_Entries);
   procedure Swap_Rows (A : in out Real_Array; N : Order; I, J : Natural)
     with Global => null, Pre => Dense_Shape (A, N) and then Bounded (A)
       and then I < N and then J < N,
     Post => Bounded (A) and then
       (for all T in A'Range => A (T) =
         (if T in I*N .. I*N+N-1 then A'Old (J*N+(T-I*N))
          elsif T in J*N .. J*N+N-1 then A'Old (I*N+(T-J*N)) else A'Old (T)));
   subtype Small_Value is Real range -1.0e98 .. 1.0e98;
   subtype Multiplier_Value is Real range -2.0 .. 2.0;
   function Fast_Subtract (X, Y : Small_Value; M : Multiplier_Value) return Value
     with Global => null, Post => Fast_Subtract'Result = X-M*Y;
   pragma Inline_Always (Fast_Subtract);
   function Magnitude (A : Real_Array) return Value
     with Global => null, Pre => Bounded (A),
     Post => Magnitude'Result in 2.0 .. Value'Last
       and then (for all X of A => abs X <= Magnitude'Result);
   function Find_Pivot (A : Real_Array; N : Order; K : Natural) return Natural
     with Global => null, Pre => Dense_Shape (A, N) and then Bounded (A) and then K < N,
     Post => Find_Pivot'Result in K .. N-1
       and then (for all I in K .. N-1 => abs A (I*N+K) <= abs A (Find_Pivot'Result*N+K));
   procedure Eliminate_Row (A : in out Real_Array; N : Order; K, I : Natural;
                            Reciprocal : Value; Result : out Status; Input_Limit : Value := Value'Last)
     with Global => null, Pre => Dense_Shape (A, N) and then Bounded (A)
       and then K < I and then I < N and then Input_Limit >= 2.0
       and then (for all J in 0 .. N-1 => abs A (I*N+J) <= Input_Limit
         and then abs A (K*N+J) <= Input_Limit),
     Post => Bounded (A) and then Result in Success | Numeric_Limit
       and then (for all T in A'Range =>
         (if T not in I*N+K .. I*N+N-1 then A (T) = A'Old (T)))
       and then (if Result = Success then A (I*N+K) = A'Old (I*N+K)*Reciprocal
         and then (for all J in K+1 .. N-1 =>
           A (I*N+J) = A'Old (I*N+J) - A (I*N+K)*A'Old (K*N+J)));
   -- Packed L (unit diagonal implicit) and U. P records sequential row swaps.
   -- Singular/Numeric_Limit leave a bounded, partially modified factorization.
   procedure Factor_Dense (A : in out Real_Array; N : Order;
                           P : out Int_Array; Result : out Status)
     with Global => null,
     Pre => Dense_Shape (A, N) and then Bounded (A) and then P'First = 0 and then P'Last = N-1,
     Post => Bounded (A) and then Pivots_Valid (P, N)
       and then Result in Success | Singular | Numeric_Limit
       and then (if Result = Success then (for all I in 0 .. N-1 => abs A (I*N+I) >= Min_Val));
   procedure Solve_Dense (A : Real_Array; N : Order; P : Int_Array;
                          B : Real_Array; X : out Real_Array; Result : out Status)
     with Global => null,
     Pre => Dense_Shape (A, N) and then Bounded (A) and then Pivots_Valid (P, N)
       and then (for all I in 0 .. N-1 => abs A (I*N+I) >= Min_Val)
       and then Vector_Shape (B, N) and then Bounded (B) and then X'First = 0 and then X'Last = N-1,
     Post => Bounded (X) and then Result in Success | Numeric_Limit;
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
         (for all I in 0 .. N-1 => abs A (Diagonal (I)) >= Min_Val));
   procedure Solve_Sparse
     (A : Real_Array; N : Order; Row_Start, Column, Diagonal : Int_Array;
      B : Real_Array; X : out Real_Array; Result : out Status)
     with Global => null,
     Pre => CSR_Valid (N, Row_Start, Column, Diagonal)
       and then A'First = 0 and then A'Last = Column'Last and then Bounded (A)
       and then (for all I in 0 .. N-1 => abs A (Diagonal (I)) >= Min_Val)
       and then Vector_Shape (B, N) and then Bounded (B) and then X'First = 0 and then X'Last = N-1,
     Post => Bounded (X) and then Result in Success | Numeric_Limit;
   pragma Inline_Always (Find_Pivot);
   pragma Inline_Always (Magnitude);
   pragma Inline_Always (Eliminate_Row);
   pragma Inline_Always (Swap_Rows);
end MJ.LU;

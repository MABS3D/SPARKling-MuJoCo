package body MJ.LU with SPARK_Mode is
   procedure Analyze (N : Order; Row_Start, Column : Int_Array;
                      Diagonal : out Int_Array; Result : out Status) is
   begin
      Diagonal := [others => -1]; Result := Invalid_Structure;
      if Row_Start'First /= 0 or else Row_Start'Last /= N
        or else Column'First /= 0 or else Column'Last >= Max_Size
        or else Row_Start (0) /= 0 or else Row_Start (N) /= Column'Length then return; end if;
      for I in 0 .. N-1 loop
         if Row_Start (I) < 0 or else Row_Start (I+1) <= Row_Start (I)
           or else Row_Start (I+1) > Column'Length then return; end if;
         for K in Row_Start (I) .. Row_Start (I+1)-1 loop
            if Column (K) = I then Diagonal (I) := K; end if;
         end loop;
      end loop;
      if CSR_Valid (N, Row_Start, Column, Diagonal) then Result := Success; end if;
   end Analyze;

   procedure Subtract_Product (X : in out Value; A, B : Value; Result : out Status) is
      Product : constant Real := A*B;
      Next : constant Real := X-Product;
   begin
      Result := Numeric_Limit;
      if Next in Value then X := Next; Result := Success; end if;
   end Subtract_Product;
   procedure Multiply (X : in out Value; A : Value; Result : out Status) is
      Next : constant Real := X*A;
   begin
      Result := Numeric_Limit;
      if Next in Value then X := Next; Result := Success; end if;
   end Multiply;
   procedure Divide (X : in out Value; Pivot : Value; Result : out Status) is
      Next : constant Real := X/Pivot;
   begin
      Result := Numeric_Limit;
      if Next in Value then X := Next; Result := Success; end if;
   end Divide;
   function Clamped (Pivot : Value) return Value is
   begin
      return (if abs Pivot >= Min_Val then Pivot elsif Pivot < 0.0 then -Min_Val else Min_Val);
   end Clamped;

   procedure Swap_Entries (A : in out Real_Array; I, J : Natural) is
      Temp : constant Real := A (I);
   begin
      A (I) := A (J); A (J) := Temp;
   end Swap_Entries;

   procedure Swap_Rows (A : in out Real_Array; N : Order; I, J : Natural) is
      BI : constant Natural := I*N;
      BJ : constant Natural := J*N;
   begin
      if I = J then return; end if;
      pragma Assert (Static => BI+N <= BJ or else BJ+N <= BI);
      for C in 0 .. N-1 loop
         Swap_Entries (A, BI+C, BJ+C);
         pragma Loop_Invariant (Bounded (A));
         pragma Loop_Invariant (for all K in A'Range => A (K) =
           (if K in BI .. BI+C then A'Loop_Entry (BJ+(K-BI))
            elsif K in BJ .. BJ+C then A'Loop_Entry (BI+(K-BJ)) else A'Loop_Entry (K)));
      end loop;
   end Swap_Rows;

   function Fast_Subtract (X, Y : Small_Value; M : Multiplier_Value) return Value is
   begin
      return X-M*Y;
   end Fast_Subtract;

   function Magnitude (A : Real_Array) return Value is
      Bound : Value := 2.0;
   begin
      for I in A'Range loop
         Bound := Real'Max (Bound, abs A (I));
         pragma Loop_Invariant (Bound >= 2.0);
         pragma Loop_Invariant (for all J in A'First .. I => abs A (J) <= Bound);
      end loop;
      return Bound;
   end Magnitude;

   function Find_Pivot (A : Real_Array; N : Order; K : Natural) return Natural is
      Best : Natural := K;
   begin
      for I in K+1 .. N-1 loop
         if abs A (I*N+K) > abs A (Best*N+K) then Best := I; end if;
         pragma Loop_Invariant (Best in K .. I);
         pragma Loop_Invariant (for all J in K .. I => abs A (J*N+K) <= abs A (Best*N+K));
      end loop;
      return Best;
   end Find_Pivot;

   procedure Eliminate_Row (A : in out Real_Array; N : Order; K, I : Natural;
                            Reciprocal : Value; Result : out Status; Input_Limit : Value := Value'Last) is
      T : Value := A (I*N+K);
   begin
      Multiply (T, Reciprocal, Result);
      if Result /= Success then return; end if;
      A (I*N+K) := T;
      if Input_Limit <= 1.0e98 then
         if abs T > 2.0 then Result := Numeric_Limit; return; end if;
         -- The stage bound provides 100x headroom; this loop has no data-dependent
         -- exits and can be vectorized without contracting multiply/subtract.
         for J in K+1 .. N-1 loop
            A (I*N+J) := Fast_Subtract (A (I*N+J), A (K*N+J), T);
         end loop;
         return;
      end if;
      for J in K+1 .. N-1 loop
         T := A (I*N+J); Subtract_Product (T, A (I*N+K), A (K*N+J), Result);
         if Result /= Success then return; end if;
         A (I*N+J) := T;
         pragma Loop_Invariant (Bounded (A) and then Result = Success);
         pragma Loop_Invariant (A (I*N+K) = A'Loop_Entry (I*N+K));
         pragma Loop_Invariant (for all V in A'Range => A (V) =
           (if V in I*N+K+1 .. I*N+J then A'Loop_Entry (V) - A (I*N+K)*A'Loop_Entry (K*N+(V-I*N))
            else A'Loop_Entry (V)));
      end loop;
   end Eliminate_Row;

   procedure Factor_Dense (A : in out Real_Array; N : Order;
                           P : out Int_Array; Result : out Status) is
      Max_Row : Natural;
      Reciprocal : Value;
      Stage_Limit : Value := Magnitude (A);
   begin
      P := [for I in P'Range => I]; Result := Success;
      for K in 0 .. N-1 loop
         pragma Loop_Invariant (Bounded (A) and then Pivots_Valid (P, N) and then Result = Success);
         pragma Loop_Invariant (for all I in 0 .. K-1 => abs A (I*N+I) >= Min_Val);
         if Stage_Limit > 1.0e98 then Stage_Limit := Magnitude (A); end if;
         Max_Row := Find_Pivot (A, N, K);
         if abs A (Max_Row*N+K) < Min_Val then Result := Singular; return; end if;
         P (K) := Max_Row;
         if Max_Row /= K then Swap_Rows (A, N, K, Max_Row); end if;
         Reciprocal := 1.0/A (K*N+K);
         for I in K+1 .. N-1 loop
            Eliminate_Row (A, N, K, I, Reciprocal, Result, Stage_Limit);
            if Result /= Success then return; end if;
            pragma Loop_Invariant (Bounded (A) and then Result = Success);
            pragma Loop_Invariant (for all J in 0 .. K => abs A (J*N+J) >= Min_Val);
         end loop;
         -- Partial pivoting bounds multipliers near one. Use a factor four
         -- to leave rounding margin, and refresh before the bound gets large.
         if Stage_Limit <= 1.0e98 then Stage_Limit := 4.0*Stage_Limit; end if;
      end loop;
   end Factor_Dense;

   procedure Solve_Dense (A : Real_Array; N : Order; P : Int_Array;
                          B : Real_Array; X : out Real_Array; Result : out Status) is
      T : Value;
   begin
      X := B; Result := Success;
      for I in 0 .. N-1 loop
         T := X (I); X (I) := X (P (I)); X (P (I)) := T;
         T := X (I);
         for J in 0 .. I-1 loop
            Subtract_Product (T, A (I*N+J), X (J), Result);
            if Result /= Success then return; end if;
         end loop;
         X (I) := T;
         pragma Loop_Invariant (Bounded (X) and then Result = Success);
      end loop;
      for I in reverse 0 .. N-1 loop
         T := X (I);
         for J in I+1 .. N-1 loop
            Subtract_Product (T, A (I*N+J), X (J), Result);
            if Result /= Success then return; end if;
         end loop;
         Divide (T, A (I*N+I), Result);
         if Result /= Success then return; end if;
         X (I) := T;
         pragma Loop_Invariant (Bounded (X) and then Result = Success);
      end loop;
   end Solve_Dense;

   procedure Factor_Sparse
     (A : in out Real_Array; N : Order; Row_Start, Column, Diagonal : Int_Array;
      Remaining : out Int_Array; First_Clamped : out Integer; Result : out Status) is
      II, JI, IC, JC : Integer;
      T, Multiplier : Value;
   begin
      Remaining := [for I in Remaining'Range => Row_Start (I+1)-Row_Start (I)];
      First_Clamped := -1; Result := Success;
      for I in reverse 0 .. N-1 loop
         pragma Loop_Invariant (Bounded (A) and then Result = Success);
         pragma Loop_Invariant (First_Clamped in -1 .. N-1);
         pragma Loop_Invariant (for all R in 0 .. N-1 => Remaining (R) in 0 .. Row_Start (R+1)-Row_Start (R));
         II := Row_Start (I)+Remaining (I)-1;
         if Remaining (I) <= 0 or else II /= Diagonal (I) then Result := Invalid_Structure; return; end if;
         Remaining (I) := Remaining (I)-1;
         if abs A (II) < Min_Val then
            A (II) := Clamped (A (II));
            if First_Clamped = -1 then First_Clamped := I; end if;
         end if;
         for J in reverse 0 .. I-1 loop
         pragma Loop_Invariant (Bounded (A) and then Result = Success);
         pragma Loop_Invariant (First_Clamped in -1 .. N-1);
         pragma Loop_Invariant (for all R in 0 .. N-1 => Remaining (R) in 0 .. Row_Start (R+1)-Row_Start (R));
            if Remaining (J) > 0 then
               JI := Row_Start (J)+Remaining (J)-1;
               if Column (JI) = I then
                  Remaining (J) := Remaining (J)-1;
                  T := A (JI); Divide (T, A (II), Result);
                  if Result /= Success then return; end if;
                  A (JI) := T; Multiplier := T;
                  IC := Row_Start (I); JC := Row_Start (J);
                  while JC < Row_Start (J)+Remaining (J) loop
                     pragma Loop_Invariant (Bounded (A) and then Result = Success);
                     pragma Loop_Invariant (JC in Row_Start (J) .. Row_Start (J)+Remaining (J));
                     pragma Loop_Invariant (IC in Row_Start (I) .. Row_Start (I)+Remaining (I));
                     -- Unlike C, never read past the remaining part of row I.
                     if IC >= Row_Start (I)+Remaining (I) then exit; end if;
                     if Column (IC) = Column (JC) then
                        T := A (JC); Subtract_Product (T, A (IC), Multiplier, Result);
                        if Result /= Success then return; end if;
                        A (JC) := T; IC := IC+1; JC := JC+1;
                     elsif Column (IC) > Column (JC) then JC := JC+1;
                     else Result := Fill_Required; return;
                     end if;
                  end loop;
                  if IC /= Row_Start (I)+Remaining (I) then Result := Fill_Required; return; end if;
               end if;
            end if;
         end loop;
      end loop;
   end Factor_Sparse;

   procedure Solve_Sparse
     (A : Real_Array; N : Order; Row_Start, Column, Diagonal : Int_Array;
      B : Real_Array; X : out Real_Array; Result : out Status) is
      T : Value;
   begin
      X := B; Result := Success;
      -- Ordered scalar reductions; C's SIMD dot may round differently.
      for I in reverse 0 .. N-1 loop
         pragma Loop_Invariant (Bounded (X));
         T := X (I);
         for K in Diagonal (I)+1 .. Row_Start (I+1)-1 loop
            Subtract_Product (T, A (K), X (Column (K)), Result);
            if Result /= Success then return; end if;
         end loop;
         X (I) := T;
      end loop;
      for I in 0 .. N-1 loop
         pragma Loop_Invariant (Bounded (X));
         T := X (I);
         for K in Row_Start (I) .. Diagonal (I)-1 loop
            Subtract_Product (T, A (K), X (Column (K)), Result);
            if Result /= Success then return; end if;
         end loop;
         Divide (T, A (Diagonal (I)), Result);
         if Result /= Success then return; end if;
         X (I) := T;
      end loop;
   end Solve_Sparse;
end MJ.LU;

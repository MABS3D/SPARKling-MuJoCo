package body MJ.Constraint_Solvers.Cholesky_Updates with SPARK_Mode is
   function Pivot_Change (Diagonal : Pivot; X : Operand; Plus : Boolean) return Real is
     (Diagonal*Diagonal + (if Plus then X*X else -X*X));
   function Root (Value : Real) return Real is
     (MJ.Quaternion_Math.Sqrt (Real'Max (1.0e-15, Value)));
   function Positive_Ratio (Numerator, Denominator : Pivot) return Positive_Coefficient is
     (Numerator/Denominator);
   function Signed_Ratio (Numerator : Operand; Denominator : Pivot) return Coefficient is
     (Numerator/Denominator);
   function Inverse (Value : Positive_Coefficient) return Coefficient is (1.0/Value);
   function Dense_Numerator (L, X : Operand; S : Coefficient; Plus : Boolean) return Wide is
     (if Plus then L+S*X else L-S*X);
   function Dense_Residual (C : Positive_Coefficient; X : Operand;
                            S : Coefficient; L : Operand) return Wide is (C*X-S*L);
   function Sparse_Combine (A, B : Coefficient; X, Y : Operand) return Wide is (A*X+B*Y);
   function Scale (Value : Wide; Multiplier : Coefficient) return Operand is (Value*Multiplier);

   procedure Store_Diagonal (L : in out Matrix; Row : Positive; Value : Pivot) is
   begin
      L (Row, Row) := Value;
   end Store_Diagonal;

   procedure Store_Lower (L : in out Matrix; Row, Col : Positive; Value : Operand) is
   begin
      L (Row, Col) := Value;
   end Store_Lower;

   procedure Dense_Column (L : in out Matrix; X : Vector; K : Positive;
                           S, Inv : Coefficient; Plus : Boolean; Result : out Status) is
      Value : Wide;
   begin
      Result := Numeric_Limit;
      for I in K+1 .. X'Last loop
         pragma Loop_Invariant (Dense.Bounded (L) and then Dense.Positive_Diagonal (L));
         pragma Loop_Invariant (for all R in L'Range (1) => (for all J in L'Range (2) =>
           (if J /= K or else R <= K or else R >= I then L (R, J) = L'Loop_Entry (R, J))));
         pragma Loop_Invariant (Dense.Bounded (L'Loop_Entry));
         pragma Loop_Invariant (for all R in K+1 .. I-1 =>
           Can_Scale (Dense_Numerator (L'Loop_Entry (R, K), X (R), S, Plus), Inv)
           and then L (R, K) = Scale (Dense_Numerator (L'Loop_Entry (R, K), X (R), S, Plus), Inv));
         Value := Dense_Numerator (L (I, K), X (I), S, Plus);
         if not Can_Scale (Value, Inv) then return; end if;
         Store_Lower (L, I, K, Scale (Value, Inv));
      end loop;
      Result := Success;
   end Dense_Column;

   procedure Dense_Vector (L : Matrix; X : in out Vector; K : Positive;
                           C : Positive_Coefficient; S : Coefficient; Result : out Status) is
      Value : Wide;
   begin
      Result := Numeric_Limit;
      for I in K+1 .. X'Last loop
         Value := Dense_Residual (C, X (I), S, L (I, K));
         if Value not in Operand then return; end if;
         X (I) := Value;
         pragma Loop_Invariant (for all V of X => V in Operand);
         pragma Loop_Invariant (for all J in X'Range =>
           (if J <= K or else J > I then X (J) = X'Loop_Entry (J)));
         pragma Loop_Invariant (for all J in K+1 .. I =>
           X (J) = Dense_Residual (C, X'Loop_Entry (J), S, L (J, K)));
      end loop;
      Result := Success;
   end Dense_Vector;

   procedure Update_Dense (L : in out Matrix; X : in out Vector;
                           Plus : Boolean; Rank : out Natural; Result : out Status) is
      D, R, Change : Real;
      C : Positive_Coefficient;
      Inv, S : Coefficient;
   begin
      Result := Numeric_Limit; Rank := X'Length;
      for K in X'Range loop
         Result := Numeric_Limit;
         if X (K) /= 0.0 then
            D := L (K, K); Change := Pivot_Change (D, X (K), Plus);
            if Change < 1.0e-15 then Rank := Rank-1; end if;
            R := Root (Change);
            if R not in Pivot then return; end if;
            C := Positive_Ratio (R, D); Inv := Inverse (C); S := Signed_Ratio (X (K), D);
            Store_Diagonal (L, K, R);
            Dense_Column (L, X, K, S, Inv, Plus, Result);
            if Result /= Success then return; end if;
            Dense_Vector (L, X, K, C, S, Result);
            if Result /= Success then return; end if;
         end if;
         pragma Loop_Invariant (Dense.Bounded (L) and then Dense.Positive_Diagonal (L));
         pragma Loop_Invariant (for all V of X => V in Operand);
         pragma Loop_Invariant (Rank in X'Length-K .. X'Length);
         pragma Loop_Invariant (for all I in L'Range (1) => (for all J in L'Range (2) =>
           (if J > I then L (I, J) = L'Loop_Entry (I, J))));
      end loop;
      Result := Success;
   end Update_Dense;

   procedure Columns_Ordered (P : Sparse.Pattern; R, First, Last : Positive)
     with Ghost => Static, Global => null,
     Pre => Sparse.Valid (P) and then R <= P.N
       and then First <= Last and then Last <= P.Length (R),
     Post => P.Column (R, First) <= P.Column (R, Last)
       and then (if First < Last then P.Column (R, First) < P.Column (R, Last)),
     Subprogram_Variant => (Decreases => Last)
   is
   begin
      if First < Last then Columns_Ordered (P, R, First, Last-1); end if;
   end Columns_Ordered;

   procedure Separate_Column (P : Sparse.Pattern; R, Position : Positive)
     with Ghost => Static, Global => null,
     Pre => Sparse.Valid (P) and then R <= P.N and then Position <= P.Length (R),
     Post => (for all K in 1 .. P.Length (R) =>
       (if K /= Position then P.Column (R, K) /= P.Column (R, Position)))
   is
   begin
      for K in 1 .. P.Length (R) loop
         if K < Position then Columns_Ordered (P, R, K, Position);
         elsif K > Position then Columns_Ordered (P, R, Position, K);
         end if;
         pragma Loop_Invariant (for all Q in 1 .. K =>
           (if Q /= Position then P.Column (R, Q) /= P.Column (R, Position)));
      end loop;
   end Separate_Column;

   procedure Sparse_Row (L : in out Matrix; P : Sparse.Pattern; X : in out Vector;
                         Row : Positive; C : Positive_Coefficient; S, Signed_S : Coefficient;
                         Result : out Status) is
      Old_L, Old_X : Operand;
      Value, Residual : Wide;
   begin
      Result := Numeric_Limit;
      for I in 1 .. P.Length (Row)-1 loop
         pragma Loop_Invariant (Dense.Bounded (L) and then Dense.Positive_Diagonal (L));
         pragma Loop_Invariant (for all V of X => V in Operand);
         pragma Loop_Invariant (for all R in L'Range (1) => (for all J in L'Range (2) =>
           (if R /= Row or else J >= Row
            or else (for all K in 1 .. I-1 => P.Column (Row, K) /= J)
            then L (R, J) = L'Loop_Entry (R, J))));
         pragma Loop_Invariant (for all J in X'Range =>
           (if (for all K in 1 .. I-1 => P.Column (Row, K) /= J) then X (J) = X'Loop_Entry (J)));
         pragma Loop_Invariant (Dense.Bounded (L'Loop_Entry));
         pragma Loop_Invariant (for all V of X'Loop_Entry => V in Operand);
         pragma Loop_Invariant (for all K in 1 .. I-1 =>
           L (Row, P.Column (Row, K)) = Sparse_Combine
             (C, Signed_S, L'Loop_Entry (Row, P.Column (Row, K)), X'Loop_Entry (P.Column (Row, K)))
           and then X (P.Column (Row, K)) = Sparse_Combine
             (S, C, L'Loop_Entry (Row, P.Column (Row, K)), X'Loop_Entry (P.Column (Row, K))));
         Separate_Column (P, Row, I);
         declare J : constant Positive := P.Column (Row, I); begin
            Old_L := L (Row, J); Old_X := X (J);
            Value := Sparse_Combine (C, Signed_S, Old_L, Old_X);
            Residual := Sparse_Combine (S, C, Old_L, Old_X);
            if Value not in Operand or else Residual not in Operand then return; end if;
            Store_Lower (L, Row, J, Value); X (J) := Residual;
         end;
      end loop;
      Result := Success;
   end Sparse_Row;

   procedure Update_Sparse (L : in out Matrix; P : Sparse.Pattern;
                            X : in out Vector; Start : Natural; Plus : Boolean;
                            Rank : out Natural; Result : out Status) is
      D, R, Change : Real;
      C : Positive_Coefficient;
      S, Signed_S : Coefficient;
   begin
      Result := Numeric_Limit; Rank := X'Length;
      for Row in reverse 1 .. Start loop
         Result := Numeric_Limit;
         if X (Row) /= 0.0 then
            D := L (Row, Row); Change := Pivot_Change (D, X (Row), Plus);
            if Change < 1.0e-15 then Rank := Rank-1; end if;
            R := Root (Change);
            if R not in Pivot then return; end if;
            Store_Diagonal (L, Row, R);
            C := Positive_Ratio (D, R); S := Signed_Ratio (-X (Row), R);
            Signed_S := (if Plus then -S else S);
            Sparse_Row (L, P, X, Row, C, S, Signed_S, Result);
            if Result /= Success then return; end if;
         end if;
         pragma Loop_Invariant (Dense.Bounded (L) and then Dense.Positive_Diagonal (L));
         pragma Loop_Invariant (for all V of X => V in Operand);
         pragma Loop_Invariant (Rank in X'Length-(Start-Row+1) .. X'Length);
         pragma Loop_Invariant (for all I in L'Range (1) => (for all J in L'Range (2) =>
           (if J > I or else I > Start then L (I, J) = L'Loop_Entry (I, J))));
      end loop;
      Result := Success;
   end Update_Sparse;
end MJ.Constraint_Solvers.Cholesky_Updates;

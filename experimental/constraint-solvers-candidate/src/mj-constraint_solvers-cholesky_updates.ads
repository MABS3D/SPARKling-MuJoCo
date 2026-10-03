with MJ.Constraint_Solvers.Dense_Cholesky;
with MJ.Constraint_Solvers.Sparse_Cholesky;
with MJ.Quaternion_Math;

--  Ordered rank-one Cholesky updates/downdates from MuJoCo 3.14.
--  Scalar relations are separate from the pending composed factor model.
package MJ.Constraint_Solvers.Cholesky_Updates with SPARK_Mode is
   package Dense renames MJ.Constraint_Solvers.Dense_Cholesky;
   package Sparse renames MJ.Constraint_Solvers.Sparse_Cholesky;
   subtype Operand is Dense.Operand;
   subtype Pivot is Dense.Pivot;
   subtype Coefficient is Real range -2.0e135 .. 2.0e135;
   subtype Positive_Coefficient is Coefficient range 5.0e-136 .. 2.0e135;
   subtype Wide is Real range -5.0e255 .. 5.0e255;
   type Status is (Success, Numeric_Limit);

   function Pivot_Change (Diagonal : Pivot; X : Operand; Plus : Boolean) return Real with
     Global => null, Inline_Always,
     Post => Pivot_Change'Result = Diagonal*Diagonal + (if Plus then X*X else -X*X)
       and then Pivot_Change'Result in -3.0e240 .. 3.0e240;
   function Root (Value : Real) return Real with Global => null, Inline_Always,
     Pre => Value in -3.0e240 .. 3.0e240,
     Post => Root'Result = MJ.Quaternion_Math.Sqrt (Real'Max (1.0e-15, Value));
   function Positive_Ratio (Numerator, Denominator : Pivot) return Positive_Coefficient with
     Global => null, Inline_Always,
     Post => Positive_Ratio'Result = Numerator/Denominator;
   function Signed_Ratio (Numerator : Operand; Denominator : Pivot) return Coefficient with
     Global => null, Inline_Always,
     Post => Signed_Ratio'Result = Numerator/Denominator;
   function Inverse (Value : Positive_Coefficient) return Coefficient with
     Global => null, Inline_Always,
     Post => Inverse'Result = 1.0/Value and then Inverse'Result > 0.0;
   function Dense_Numerator (L, X : Operand; S : Coefficient; Plus : Boolean) return Wide with
     Global => null, Inline_Always,
     Post => Dense_Numerator'Result = (if Plus then L+S*X else L-S*X);
   function Dense_Residual (C : Positive_Coefficient; X : Operand;
                            S : Coefficient; L : Operand) return Wide with
     Global => null, Inline_Always,
     Post => Dense_Residual'Result = C*X-S*L;
   function Sparse_Combine (A, B : Coefficient; X, Y : Operand) return Wide with
     Global => null, Inline_Always,
     Post => Sparse_Combine'Result = A*X+B*Y;

   --  The first test only rejects products whose magnitude already exceeds
   --  Operand. It permits a large numerator with a small multiplier, while
   --  keeping the admission test itself within Real's finite range.
   function Can_Scale (Value : Wide; Multiplier : Coefficient) return Boolean is
     ((abs Value <= 1.0e160 or else abs Multiplier <= 1.0)
      and then Value*Multiplier in Operand) with Global => null;
   function Scale (Value : Wide; Multiplier : Coefficient) return Operand with
     Global => null, Inline_Always, Pre => Can_Scale (Value, Multiplier),
     Post => Scale'Result = Value*Multiplier;

   procedure Store_Diagonal (L : in out Matrix; Row : Positive; Value : Pivot) with
     Global => null, Inline_Always,
     Pre => Dense.Square (L) and then Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then Row in L'Range (1),
     Post => Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then L (Row, Row) = Value
       and then (for all I in L'Range (1) => (for all J in L'Range (2) =>
         (if I /= Row or else J /= Row then L (I, J) = L'Old (I, J))));

   procedure Store_Lower (L : in out Matrix; Row, Col : Positive; Value : Operand) with
     Global => null, Inline_Always,
     Pre => Dense.Square (L) and then Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then Row in L'Range (1) and then Col in 1 .. Row-1,
     Post => Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then L (Row, Col) = Value
       and then (for all I in L'Range (1) => (for all J in L'Range (2) =>
         (if I /= Row or else J /= Col then L (I, J) = L'Old (I, J))));

   procedure Dense_Column (L : in out Matrix; X : Vector; K : Positive;
                           S, Inv : Coefficient; Plus : Boolean; Result : out Status) with
     Global => null,
     Pre => Dense.Square (L) and then Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then K in X'Range and then (for all V of X => V in Operand),
     Post => Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then (for all I in L'Range (1) => (for all J in L'Range (2) =>
         (if J /= K or else I <= K then L (I, J) = L'Old (I, J))))
       and then (if Result = Success then (for all I in K+1 .. X'Last =>
         Can_Scale (Dense_Numerator (L'Old (I, K), X (I), S, Plus), Inv)
         and then L (I, K) = Scale (Dense_Numerator (L'Old (I, K), X (I), S, Plus), Inv)));

   procedure Dense_Vector (L : Matrix; X : in out Vector; K : Positive;
                           C : Positive_Coefficient; S : Coefficient; Result : out Status) with
     Global => null,
     Pre => Dense.Square (L) and then Dense.Bounded (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then K in X'Range and then (for all V of X => V in Operand),
     Post => (for all V of X => V in Operand)
       and then (for all I in 1 .. K => X (I) = X'Old (I))
       and then (if Result = Success then (for all I in K+1 .. X'Last =>
         X (I) = Dense_Residual (C, X'Old (I), S, L (I, K))));

   procedure Update_Dense (L : in out Matrix; X : in out Vector;
                           Plus : Boolean; Rank : out Natural; Result : out Status) with
     Global => null,
     Pre => Dense.Square (L) and then Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand),
     Post => Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then (for all V of X => V in Operand) and then Rank <= X'Length
       and then (for all I in L'Range (1) => (for all J in L'Range (2) =>
         (if J > I then L (I, J) = L'Old (I, J))));

   procedure Sparse_Row (L : in out Matrix; P : Sparse.Pattern; X : in out Vector;
                         Row : Positive; C : Positive_Coefficient; S, Signed_S : Coefficient;
                         Result : out Status) with
     Global => null,
     Pre => Sparse.Valid (P) and then Dense.Square (L) and then Dense.Bounded (L)
       and then Dense.Positive_Diagonal (L) and then L'Length (1) = P.N
       and then X'First = 1 and then X'Length = P.N and then Row in 1 .. P.N
       and then (for all V of X => V in Operand),
     Post => Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then (for all V of X => V in Operand)
       and then (for all I in L'Range (1) => (for all J in L'Range (2) =>
         (if I /= Row or else J >= Row
          or else (for all K in 1 .. P.Length (Row)-1 => P.Column (Row, K) /= J)
          then L (I, J) = L'Old (I, J))))
       and then (for all I in X'Range =>
         (if (for all K in 1 .. P.Length (Row)-1 => P.Column (Row, K) /= I)
          then X (I) = X'Old (I)))
       and then (if Result = Success then (for all K in 1 .. P.Length (Row)-1 =>
         L (Row, P.Column (Row, K)) = Sparse_Combine
           (C, Signed_S, L'Old (Row, P.Column (Row, K)), X'Old (P.Column (Row, K)))
         and then X (P.Column (Row, K)) = Sparse_Combine
           (S, C, L'Old (Row, P.Column (Row, K)), X'Old (P.Column (Row, K)))));

   procedure Update_Sparse (L : in out Matrix; P : Sparse.Pattern;
                            X : in out Vector; Start : Natural; Plus : Boolean;
                            Rank : out Natural; Result : out Status) with
     Global => null,
     Pre => Sparse.Valid (P) and then Dense.Square (L) and then Dense.Bounded (L)
       and then Dense.Positive_Diagonal (L) and then L'Length (1) = P.N
       and then X'First = 1 and then X'Length = P.N and then Start <= P.N
       and then (for all V of X => V in Operand),
     Post => Dense.Bounded (L) and then Dense.Positive_Diagonal (L)
       and then (for all V of X => V in Operand) and then Rank <= X'Length
       and then (for all I in L'Range (1) => (for all J in L'Range (2) =>
         (if J > I or else I > Start then L (I, J) = L'Old (I, J))));
end MJ.Constraint_Solvers.Cholesky_Updates;

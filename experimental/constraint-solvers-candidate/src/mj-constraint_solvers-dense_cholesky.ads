with MJ.Constraint_Solvers.Reduction_Models;
with MJ.Quaternion_Math;

--  C 3.14 dense LL' column order, including deficient-pivot clamping.
--  The sparse reverse L'L algorithm has a separate arithmetic order.
package MJ.Constraint_Solvers.Dense_Cholesky with SPARK_Mode is
   package Model renames MJ.Constraint_Solvers.Reduction_Models;
   package Math renames MJ.Quaternion_Math;
   subtype Operand is Model.Operand;
   subtype Pivot is Real range 1.0e-15 .. 1.0e120;
   type Status is (Success, Numeric_Limit);
   function Square (L : Matrix) return Boolean is
     (L'First (1) = 1 and then L'First (2) = 1
      and then L'Length (1) in 1 .. Max_Dofs
      and then L'Length (2) = L'Length (1));
   function Bounded (L : Matrix) return Boolean is
     (for all I in L'Range (1) =>
        (for all K in L'Range (2) => L (I, K) in Operand));
   function Positive_Diagonal (L : Matrix) return Boolean is
     (for all I in L'Range (1) => L (I, I) in Pivot)
     with Pre => Square (L);
   function Prefix (L : Matrix; I : Positive; Count : Natural) return Vector
     with Global => null,
     Pre => Square (L) and then Bounded (L)
       and then I in L'Range (1) and then Count <= L'Length (1),
     Post => Prefix'Result'First = 1 and then Prefix'Result'Last = Count
       and then Prefix'Result'Length = Count
       and then (for all K in 1 .. Count => Prefix'Result (K) = L (I, K))
       and then (for all X of Prefix'Result => X in Operand);
   function Diagonal_Residual (L : Matrix; J : Positive) return Real is
     (if J = 1 then L (J, J) else L (J, J) - Model.Dot_Value
        (Prefix (L, J, J - 1), Prefix (L, J, J - 1)))
     with Ghost => Static, Global => null,
     Pre => Square (L) and then Bounded (L) and then J in L'Range (1),
     Post => abs Diagonal_Residual'Result <= 2.0e245;
   function Inverse_Pivot (Value : Pivot) return Real is (1.0 / Value)
     with Global => null, Inline_Always,
     Post => Inverse_Pivot'Result in 0.0 .. 1.0e15
       and then Inverse_Pivot'Result = 1.0 / Value;

   function Scaled_Residual (Value : Operand; Product : Model.Dot_Real; Inv : Real)
      return Real with Global => null, Inline_Always,
     Pre => Inv in 0.0 .. 1.0e15,
     Post => Scaled_Residual'Result = (Value - Product) * Inv
       and then abs Scaled_Residual'Result <= 2.0e260;

   function Off_Diagonal (L : Matrix; I, J : Positive; Inv : Real) return Real is
     (Scaled_Residual (L (I, J), Model.Dot_Value
       (Prefix (L, I, J - 1), Prefix (L, J, J - 1)), Inv))
     with Ghost => Static, Global => null,
     Pre => Square (L) and then Bounded (L) and then J in L'Range (1)
       and then I in J + 1 .. L'Last (1) and then Inv in 0.0 .. 1.0e15,
     Post => abs Off_Diagonal'Result <= 2.0e260;

   --  Final-factor relations read original entries from M and the completed
   --  prefix from L. Later columns cannot change these ordered expressions.
   function Final_Residual (M, L : Matrix; J : Positive) return Real is
     (if J = 1 then M (J, J) else M (J, J) - Model.Dot_Value
        (Prefix (L, J, J - 1), Prefix (L, J, J - 1)))
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (L) and then Bounded (M) and then Bounded (L)
       and then M'Length (1) = L'Length (1) and then J in L'Range (1),
     Post => abs Final_Residual'Result <= 2.0e245;

   function Final_Off_Diagonal (M, L : Matrix; I, J : Positive; Inv : Real) return Real is
     (Scaled_Residual (M (I, J), Model.Dot_Value
       (Prefix (L, I, J - 1), Prefix (L, J, J - 1)), Inv))
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (L) and then Bounded (M) and then Bounded (L)
       and then M'Length (1) = L'Length (1) and then J in L'Range (1)
       and then I in J + 1 .. L'Last (1) and then Inv in 0.0 .. 1.0e15,
     Post => abs Final_Off_Diagonal'Result <= 2.0e260;

   function Completed_Column (M, L : Matrix; J : Positive; Floor : Pivot) return Boolean is
     (L (J, J) in Pivot and then L (J, J) = Math.Sqrt
        (if Final_Residual (M, L, J) < Floor then Floor else Final_Residual (M, L, J))
      and then (for all I in J + 1 .. L'Last (1) =>
        L (I, J) = (if Final_Residual (M, L, J) < Floor then 0.0 else
          Final_Off_Diagonal (M, L, I, J, Inverse_Pivot (L (J, J))))))
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (L) and then Bounded (M) and then Bounded (L)
       and then M'Length (1) = L'Length (1) and then J in L'Range (1);

   function Deficiency_Count (M, L : Matrix; Floor : Pivot; Count : Natural) return Natural is
     (if Count = 0 then 0 else Deficiency_Count (M, L, Floor, Count - 1)
        + (if Final_Residual (M, L, Count) < Floor then 1 else 0))
     with Ghost => Static, Global => null,
     Pre => Square (M) and then Square (L) and then Bounded (M) and then Bounded (L)
       and then M'Length (1) = L'Length (1) and then Count <= L'Length (1),
     Post => Deficiency_Count'Result <= Count,
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   procedure Factor_Column
     (L : in out Matrix; J : Positive; Floor : Pivot;
      Deficient : out Boolean; Result : out Status)
     with Global => null,
     Pre => Square (L) and then Bounded (L) and then J in L'Range (1),
     Post => (Static => Bounded (L)
       and then (if Result /= Success then L = L'Old)
       and then Deficient = (Diagonal_Residual (L'Old, J) < Floor)
       and then (for all I in L'Range (1) => (for all K in L'Range (2) =>
          (if K /= J or else I < J then L (I, K) = L'Old (I, K))))
       and then (if Result = Success then L (J, J) in Pivot
         and then L (J, J) = Math.Sqrt
           (if Deficient then Floor else Diagonal_Residual (L'Old, J))
         and then (for all I in J + 1 .. L'Last (1) =>
           L (I, J) = (if Deficient then 0.0 else
             Off_Diagonal (L'Old, I, J, Inverse_Pivot (L (J, J)))))));

   procedure Factor
     (M : Matrix; L : out Matrix; Rank : out Natural; Result : out Status;
      Floor : Pivot := 1.0e-15)
     with Global => null,
     Pre => Square (M) and then Bounded (M)
       and then L'First (1) = 1 and then L'First (2) = 1
       and then L'Length (1) = M'Length (1) and then L'Length (2) = M'Length (2),
     Post => Bounded (L) and then Rank <= M'Length (1)
       and then (if Result = Success then Positive_Diagonal (L))
       and then (for all I in L'Range (1) => (for all K in L'Range (2) =>
          (if K > I then L (I, K) = M (I, K))));
   function Subtract_Term (Acc : Real; A, B : Operand; Count : Positive) return Real
     with Global => null,
     Pre => Count <= Max_Dofs and then abs Acc <= Real (Count) * Model.Step_Bound,
     Post => Subtract_Term'Result = Acc - A * B
       and then abs Subtract_Term'Result <= Real (Count + 1) * Model.Step_Bound;

   function Backward_Sum (L : Matrix; X : Vector; I : Positive; Count : Natural)
      return Real is
     (if Count = 0 then X (I) else
       Subtract_Term (Backward_Sum (L, X, I, Count - 1),
                      L (I + Count, I), X (I + Count), Count))
     with Ghost => Static, Global => null,
     Pre => Square (L) and then Bounded (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand)
       and then I in X'Range and then Count <= X'Length - I,
     Post => abs Backward_Sum'Result <= Real (Count + 1) * Model.Step_Bound,
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   procedure Forward_Row (L : Matrix; X : in out Vector; I : Positive; Result : out Status)
     with Global => null,
     Pre => Square (L) and then Bounded (L) and then Positive_Diagonal (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand) and then I in X'Range,
     Post => (Static => (for all V of X => V in Operand)
       and then (if Result /= Success then X = X'Old)
       and then (for all K in X'Range => (if K /= I then X (K) = X'Old (K)))
       and then (if Result = Success then X (I) =
         (if I = 1 then X'Old (I) else X'Old (I) - Model.Dot_Value
           (Prefix (L, I, I - 1), X'Old (1 .. I - 1))) / L (I, I)));

   procedure Backward_Row (L : Matrix; X : in out Vector; I : Positive; Result : out Status)
     with Global => null,
     Pre => Square (L) and then Bounded (L) and then Positive_Diagonal (L)
       and then X'First = 1 and then X'Length = L'Length (1)
       and then (for all V of X => V in Operand) and then I in X'Range,
     Post => (Static => (for all V of X => V in Operand)
       and then (if Result /= Success then X = X'Old)
       and then (for all K in X'Range => (if K /= I then X (K) = X'Old (K)))
       and then (if Result = Success then
         X (I) = Backward_Sum (L, X'Old, I, X'Length - I) / L (I, I)));

   procedure Backsolve (L : Matrix; B : Vector; X : out Vector; Result : out Status)
     with Global => null,
     Pre => Square (L) and then Bounded (L) and then Positive_Diagonal (L)
       and then B'First = 1 and then B'Length = L'Length (1)
       and then X'First = 1 and then X'Length = B'Length
       and then (for all V of B => V in Operand),
     Post => (for all V of X => V in Operand);
end MJ.Constraint_Solvers.Dense_Cholesky;

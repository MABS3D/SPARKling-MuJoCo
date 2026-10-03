with MJ.Constraint_Solvers.Jacobians;

--  Single-RHS mj_solveLD, MuJoCo 3.14.0 engine_core_smooth.c.
--  Values are supplied by the Ada mass factorization. The CSR contains the
--  strict lower triangle, retaining explicit zeros and ascending columns.
package MJ.Constraint_Solvers.Native_Inertia with SPARK_Mode is
   subtype Operand is Real range -1.0e100 .. 1.0e100;
   subtype Inverse_Value is Real range 1.0e-100 .. 1.0e16;
   type Status is (Success, Invalid_Input, Numeric_Limit);

   function Bounded (X : Vector) return Boolean is
     (for all V of X => V in Operand) with Global => null;
   function Lower_Valid (L : Sparse_Jacobian) return Boolean is
     (L.Row_Count in 1 .. Max_Dofs
      and then Jacobians.Valid (L, L.Row_Count)
      and then (for all V of L.Values => V in Operand)
      and then (for all R in 1 .. L.Row_Count =>
        (for all S in L.Offsets (R)+1 .. L.Offsets (R)+L.Widths (R) =>
          L.Columns (S) < R
          and then (if S > L.Offsets (R)+1 then L.Columns (S-1) < L.Columns (S)))))
     with Global => null;
   function Inverse_Valid (Inverse : Vector; N : Natural) return Boolean is
     (Inverse'First = 1 and then Inverse'Length = N
      and then (for all V of Inverse => V in Inverse_Value)) with Global => null;
   function Ready (L : Sparse_Jacobian; X : Vector) return Boolean is
     (Lower_Valid (L) and then X'First = 1 and then X'Length = L.Row_Count
      and then Bounded (X)) with Global => null;

   function Subtract_Product (Previous, Factor, Xi : Real) return Real with
     Global => null, Inline_Always,
     Pre => (Static => Previous in Operand and then Factor in Operand and then Xi in Operand),
     Post => Subtract_Product'Result = Previous-Factor*Xi
       and then Subtract_Product'Result in -2.0e200 .. 2.0e200;
   function Scale_Value (Value, Inverse : Real) return Real with
     Global => null, Inline_Always,
     Pre => (Static => Value in Operand and then Inverse in Inverse_Value),
     Post => Scale_Value'Result = Value*Inverse
       and then Scale_Value'Result in -2.0e116 .. 2.0e116;
   function Reciprocal (Diagonal : Real) return Real with
     Global => null, Inline_Always,
     Pre => (Static => Diagonal in 1.0e-15 .. 1.0e60),
     Post => Reciprocal'Result = 1.0/Diagonal
       and then Reciprocal'Result in 1.0e-61 .. 1.0e16;
   function Subtract_Dot (Previous, Dot : Real) return Real with
     Global => null, Inline_Always,
     Pre => (Static => Previous in Operand and then Dot in Jacobians.Sum_Value),
     Post => Subtract_Dot'Result = Previous-Dot
       and then Subtract_Dot'Result in -2.0e250 .. 2.0e250;

   procedure Store (X : in out Vector; Index : Positive; Value : Real) with
     Global => null, Inline_Always,
     Pre => (Static => Index in X'Range and then Bounded (X) and then Value in Operand),
     Post => Bounded (X) and then X (Index) = Value
       and then (for all P in X'Range => (if P /= Index then X (P) = X'Old (P)));

   procedure Distinct_Prefix (L : Sparse_Jacobian; Row, Slot : Positive) with
     Ghost => Static, Global => null,
     Pre => Lower_Valid (L) and then Row <= L.Row_Count
       and then Slot in L.Offsets (Row)+1 .. L.Offsets (Row)+L.Widths (Row),
     Post => (for all T in L.Offsets (Row)+1 .. Slot-1 =>
       L.Columns (T) < L.Columns (Slot));

   procedure Scatter_Row (L : Sparse_Jacobian; X : in out Vector;
                          Row : Positive; Accepted : out Boolean) with
     Global => null,
     Pre => Ready (L, X) and then Row <= L.Row_Count,
     Post => Bounded (X)
       and then (for all P in X'Range =>
         (if (for all S in L.Offsets (Row)+1 .. L.Offsets (Row)+L.Widths (Row) =>
                  L.Columns (S) /= P) then X (P) = X'Old (P)))
       and then (if Accepted then
         (for all S in L.Offsets (Row)+1 .. L.Offsets (Row)+L.Widths (Row) =>
           X (L.Columns (S)) = (if X'Old (Row) = 0.0 then X'Old (L.Columns (S))
             else Subtract_Product (X'Old (L.Columns (S)), L.Values (S), X'Old (Row)))));

   procedure Scale_Vector (Inverse : Vector; X : in out Vector;
                           Accepted : out Boolean) with
     Global => null,
     Pre => X'First = 1 and then Bounded (X) and then Inverse_Valid (Inverse, X'Length),
     Post => Bounded (X) and then (if Accepted then
       (for all P in X'Range => X (P) = Scale_Value (X'Old (P), Inverse (P))));

   procedure Forward_Row (L : Sparse_Jacobian; X : in out Vector;
                          Row : Positive; Accepted : out Boolean) with
     Global => null,
     Pre => Ready (L, X) and then Row <= L.Row_Count,
     Post => (Static => Bounded (X)
       and then (for all P in X'Range => (if P /= Row then X (P) = X'Old (P)))
       and then (if Accepted then X (Row) =
         (if L.Widths (Row) = 0 then X'Old (Row)
          else Subtract_Dot (X'Old (Row), Jacobians.Row_Value (L, X'Old, Row)))));

   --  Atomic public boundary. Stage contracts above specify ordered FP
   --  arithmetic and frames; their whole-solve composition remains pending.
   --  A caller that has admitted immutable structure once may use Apply on
   --  disposable solver workspace without repeating the structural scan.
   procedure Apply (L : Sparse_Jacobian; Inverse, RHS : Vector;
                    X : out Vector; Accepted : out Boolean) with Global => null,
     Pre => (Static => Ready (L, RHS) and then Inverse_Valid (Inverse, L.Row_Count)
       and then X'First = 1 and then X'Length = L.Row_Count),
     Post => Bounded (X);
   procedure Solve (L : Sparse_Jacobian; Inverse, RHS : Vector;
                    X : in out Vector; Result : out Status) with Global => null,
     Post => (if Result /= Success then X = X'Old else Bounded (X));
end MJ.Constraint_Solvers.Native_Inertia;

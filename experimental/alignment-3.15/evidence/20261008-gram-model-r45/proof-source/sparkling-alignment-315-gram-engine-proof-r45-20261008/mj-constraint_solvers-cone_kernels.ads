--  Ordered local Lc' * Jc from C 3.15 HessianConeFolded.
with MJ.Constraint_Solvers.Dense_Cholesky;
package MJ.Constraint_Solvers.Cone_Kernels with SPARK_Mode is
   package Dense renames MJ.Constraint_Solvers.Dense_Cholesky;
   type Column_Matrix is array (Positive range <>, Positive range <>) of Positive;
   subtype Component is Positive range 1 .. 6;
   subtype Local_Vector is Vector (1 .. 6);
   subtype Local_Matrix is Matrix (1 .. 6, 1 .. 6);
   subtype Jacobian_Value is Real range -1.0e10 .. 1.0e10;
   subtype Factor_Value is Real range -1.0e120 .. 1.0e120;
   Step_Bound : constant Real := 2.0 ** 437;
   subtype Folded_Value is Real range -6.0 * Step_Bound .. 6.0 * Step_Bound;

   function Add_Scaled (Acc : Folded_Value; Value : Jacobian_Value;
                        Scale : Factor_Value; Count : Natural) return Folded_Value is
     (Acc + Value * Scale)
     with Global => null, Inline_Always,
     Pre => Count < 6 and then abs Acc <= Real (Count) * Step_Bound,
     Post => Add_Scaled'Result = Acc + Value * Scale
       and then abs Add_Scaled'Result <= Real (Count + 1) * Step_Bound;

   function Fold_Value (L : Local_Matrix; J : Local_Vector;
                        Col : Component; Count : Natural) return Folded_Value is
     (case Count is
        when 0 => 0.0,
        when 1 => Add_Scaled (0.0, J (Col), L (Col, Col), 0),
        when 2 => Add_Scaled (Add_Scaled (0.0, J (Col), L (Col, Col), 0), J (Col + 1), L (Col + 1, Col), 1),
        when 3 => Add_Scaled (Add_Scaled (Add_Scaled (0.0, J (Col), L (Col, Col), 0), J (Col + 1), L (Col + 1, Col), 1), J (Col + 2), L (Col + 2, Col), 2),
        when 4 => Add_Scaled (Add_Scaled (Add_Scaled (Add_Scaled (0.0, J (Col), L (Col, Col), 0), J (Col + 1), L (Col + 1, Col), 1), J (Col + 2), L (Col + 2, Col), 2), J (Col + 3), L (Col + 3, Col), 3),
        when 5 => Add_Scaled (Add_Scaled (Add_Scaled (Add_Scaled (Add_Scaled (0.0, J (Col), L (Col, Col), 0), J (Col + 1), L (Col + 1, Col), 1), J (Col + 2), L (Col + 2, Col), 2), J (Col + 3), L (Col + 3, Col), 3), J (Col + 4), L (Col + 4, Col), 4),
        when 6 => Add_Scaled (Add_Scaled (Add_Scaled (Add_Scaled (Add_Scaled (Add_Scaled (0.0, J (Col), L (Col, Col), 0), J (Col + 1), L (Col + 1, Col), 1), J (Col + 2), L (Col + 2, Col), 2), J (Col + 3), L (Col + 3, Col), 3), J (Col + 4), L (Col + 4, Col), 4), J (Col + 5), L (Col + 5, Col), 5),
        when others => 0.0)
     with Ghost => Static, Global => null,
     Pre => Count <= 7 - Col
       and then (for all V of J => V in Jacobian_Value)
       and then (for all R in Component =>
         (for all C in Component => L (R, C) in Factor_Value)),
     Post => abs Fold_Value'Result <= Real (Count) * Step_Bound,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   procedure Unfold_Fold (L : Local_Matrix; J : Local_Vector;
                          Col : Component; Count : Positive)
     with Ghost => Static, Global => null,
     Pre => Count <= 7 - Col
       and then (for all V of J => V in Jacobian_Value)
       and then (for all R in Component =>
         (for all C in Component => L (R, C) in Factor_Value)),
     Post => Fold_Value (L, J, Col, Count) = Add_Scaled
       (Fold_Value (L, J, Col, Count - 1), J (Col + Count - 1),
        L (Col + Count - 1, Col), Count - 1);

   procedure Fold_Column (L : Local_Matrix; J : Local_Vector;
                          Dim : Component; Output : out Local_Vector)
     with Global => null, Inline_Always,
     Pre => (for all V of J => V in Jacobian_Value)
       and then (for all R in Component =>
         (for all C in Component => L (R, C) in Factor_Value)),
     Post => (Static => (for all C in Component => Output (C) =
       (if C <= Dim then Fold_Value (L, J, C, Dim - C + 1) else 0.0))
       and then (for all V of Output => V in Folded_Value));

   --  The folded Gram update follows sparse C's (D * left) * right.
   function Gram_Update (Previous : Real; Left, Right : Folded_Value;
                         Weight : Real) return Real
     with Global => null, Inline_Always,
     Pre => (Static => Previous in -1.0e120 .. 1.0e120
       and then Weight in 0.0 .. 1.0e15),
     Post => Gram_Update'Result = Previous + (Weight * Left) * Right
       and then Gram_Update'Result in -2.0e280 .. 2.0e280;

   --  Match mju_sqrMatTDSparseNumeric's cached scale and zero branch.
   --  Real parameters avoid repeating conversions to Folded_Value; the
   --  accepted finite domain is expressed by static contracts instead.
   function Gram_Scale (Left, Weight : Real) return Real
     with Global => null, Inline_Always,
     Pre => (Static => Left in Folded_Value and then Weight in 0.0 .. 1.0e15),
     Post => Gram_Scale'Result = Weight*Left
       and then Gram_Scale'Result in -3.0e147 .. 3.0e147;

   function Gram_Scaled (Previous, Scale, Right : Real) return Real
     with Global => null, Inline_Always,
     Pre => (Static => Previous in -1.0e120 .. 1.0e120
       and then Scale in -3.0e147 .. 3.0e147 and then Right in Folded_Value),
     Post => Gram_Scaled'Result =
       (if Scale = 0.0 then Previous else Previous + Scale*Right)
       and then Gram_Scaled'Result in -2.0e280 .. 2.0e280;

   procedure Gram_From_Scaled (Previous, Left, Right, Weight : Real)
     with Ghost => Static, Global => null,
     Pre => Previous in -1.0e120 .. 1.0e120 and then Left in Folded_Value
       and then Right in Folded_Value and then Weight in 0.0 .. 1.0e15,
     Post => (if Gram_Scale (Left, Weight) /= 0.0 then
       Gram_Scaled (Previous, Gram_Scale (Left, Weight), Right) =
         Gram_Update (Previous, Left, Right, Weight));

   function Gram_Source (Values : Matrix; Columns : Column_Matrix;
                         Source_Row, Index_Row, Slot : Positive; Packed : Boolean) return Real
     with Global => null, Inline_Always,
     Pre => (Static => Source_Row in Values'Range (1) and then Index_Row in Columns'Range (1)
       and then Slot in Columns'Range (2)
       and then (if Packed then Slot in Values'Range (2)
         else Columns (Index_Row, Slot) in Values'Range (2))
       and then (for all I in Values'Range (1) =>
         (for all J in Values'Range (2) => Values (I, J) in Folded_Value))),
     Post => Gram_Source'Result in Folded_Value and then Gram_Source'Result =
       Values (Source_Row, (if Packed then Slot else Columns (Index_Row, Slot)));

   function Gram_Support (Columns : Column_Matrix; Index_Row : Positive;
                          Width : Natural; N : Positive) return Boolean is
     (Index_Row in Columns'Range (1) and then Columns'First (2) = 1
       and then Width <= Columns'Length (2)
       and then (for all K in 1 .. Width => Columns (Index_Row, K) <= N
         and then (if K > 1 then Columns (Index_Row, K-1) < Columns (Index_Row, K))))
     with Ghost => Static, Global => null;

   --  These models name the exact ordered prefix and its unchanged cells.
   --  They include no real-arithmetic identity or approximation.
   function Gram_Ordered_Prefix
     (Original, After, Values : Matrix; Columns : Column_Matrix;
      Source_Row, Index_Row : Positive; Width, Count : Natural;
      Weight : Real; Packed : Boolean) return Boolean is
     (for all I in 1 .. Count => (for all J in 1 .. I =>
       After (Columns (Index_Row, I), Columns (Index_Row, J)) = Gram_Scaled
         (Original (Columns (Index_Row, I), Columns (Index_Row, J)),
          Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, I, Packed), Weight),
          Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed))))
     with Ghost => Static, Global => null,
     Pre => (Static => Dense.Square (Original) and then Dense.Bounded (Original)
       and then Dense.Square (After) and then After'Length (1) = Original'Length (1)
       and then Source_Row in Values'Range (1) and then Values'First (2) = 1
       and then Gram_Support (Columns, Index_Row, Width, Original'Length (1)) and then Count <= Width
       and then (if Packed then Width <= Values'Length (2) else Original'Length (1) <= Values'Length (2))
       and then Weight in 0.0 .. 1.0e15
       and then (for all R in Values'Range (1) => (for all C in Values'Range (2) => Values (R, C) in Folded_Value)));

   function Gram_Unchanged
     (Original, After : Matrix; Columns : Column_Matrix;
      Index_Row : Positive; Width, Count : Natural) return Boolean is
     (for all R in Original'Range (1) => (for all C in Original'Range (2) =>
       (if (for all I in 1 .. Count => Columns (Index_Row, I) /= R or else
         (for all J in 1 .. I => Columns (Index_Row, J) /= C)) then After (R, C) = Original (R, C))))
     with Ghost => Static, Global => null,
     Pre => (Static => Dense.Square (Original) and then Dense.Square (After)
       and then After'Length (1) = Original'Length (1)
       and then Gram_Support (Columns, Index_Row, Width, Original'Length (1)) and then Count <= Width);

   --  One ordered weighted outer product, with the same cached scale and
   --  zero skip as C. Packed selects folded local rows; dense selects J.
   procedure Gram_Row (H : in out Matrix; Values : Matrix; Columns : Column_Matrix;
                       Source_Row, Index_Row : Positive; Width : Natural;
                       Weight : Real; Packed : Boolean; Accepted : out Boolean)
     with Global => null, Inline_Always,
     Pre => (Static => Dense.Square (H) and then Dense.Bounded (H)
       and then Source_Row in Values'Range (1) and then Values'First (2) = 1
       and then Gram_Support (Columns, Index_Row, Width, H'Length (1))
       and then (if Packed then Width <= Values'Length (2)
         else H'Length (1) <= Values'Length (2))
       and then Weight in 0.0 .. 1.0e15
       and then (for all I in Values'Range (1) =>
         (for all J in Values'Range (2) => Values (I, J) in Folded_Value))),
     Post => (Static => (if Accepted then Dense.Bounded (H)
       and then Gram_Ordered_Prefix (H'Old, H, Values, Columns,
         Source_Row, Index_Row, Width, Width, Weight, Packed)
       and then Gram_Unchanged (H'Old, H, Columns, Index_Row, Width, Width)));
end MJ.Constraint_Solvers.Cone_Kernels;

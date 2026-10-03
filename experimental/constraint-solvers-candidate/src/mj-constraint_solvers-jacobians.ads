--  Native ordered Jacobian reductions; MuJoCo 3.14.0 mju_dotSparse/mju_dot.
with MJ.Constraint_Solvers.Reduction_Models;
package MJ.Constraint_Solvers.Jacobians with SPARK_Mode is
   subtype Operand is Real range -1.0e120 .. 1.0e120;
   subtype Lane_Value is Real range -1.0e248 .. 1.0e248;
   subtype Combined_Value is Real range -1.0e249 .. 1.0e249;
   subtype Sum_Value is Real range -1.0e250 .. 1.0e250;
   Step_Bound : constant Real := 2.0 ** 801;
   subtype Lane_Number is Natural range 0 .. 3;
   function Valid (J : Sparse_Jacobian; N : Positive) return Boolean is
     (J.Row_Count <= Max_Rows and then J.Stored <= Max_Jacobian_Entries
      and then (for all R in 1 .. J.Row_Count =>
        J.Offsets (R) <= J.Stored and then J.Widths (R) <= J.Stored-J.Offsets (R))
      and then (for all C of J.Columns => C <= N)
      and then (for all V of J.Values => V in Operand)) with Global => null;
   function Bounded (X : Vector) return Boolean is
     (for all V of X => V in Operand) with Global => null;

   function Product (A, B : Operand) return Real with
     Global => null, Inline_Always,
     Post => Product'Result = A*B and then abs Product'Result <= 1.0e240;
   function Add (Acc, Term : Real; Count : Entry_Count) return Lane_Value with
     Global => null, Inline_Always,
     Pre => Count < Max_Jacobian_Entries
       and then abs Acc <= Real (Count)*Step_Bound and then abs Term <= 1.0e240,
     Post => Add'Result = Acc+Term
       and then abs Add'Result <= Real (Count+1)*Step_Bound;

   function Lane_Sum (J : Sparse_Jacobian; X : Vector; R : Positive;
                      Count : Entry_Count; Lane : Lane_Number) return Lane_Value is
     (if Count = 0 then 0.0
      elsif Count = 1 then Product (J.Values (J.Offsets (R)+Lane+1),
                                    X (J.Columns (J.Offsets (R)+Lane+1)))
      else Add (Lane_Sum (J, X, R, Count-1, Lane),
       Product (J.Values (J.Offsets (R)+4*(Count-1)+Lane+1),
                X (J.Columns (J.Offsets (R)+4*(Count-1)+Lane+1))), Count-1))
     with Ghost => Static, Global => null,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count and then Count <= J.Widths (R)/4,
     Post => abs Lane_Sum'Result <= Real (Count)*Step_Bound,
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Combine_Value (A, B, C, D : Lane_Value) return Combined_Value is
     ((A+C)+(B+D)) with Ghost => Static, Global => null;
   function Combine (A, B, C, D : Lane_Value) return Combined_Value with
     Global => null, Inline_Always,
     Post => (Static => Combine'Result = Combine_Value (A, B, C, D)
       and then Combine'Result = (A+C)+(B+D));
   function Tail_Value (J : Sparse_Jacobian; X : Vector; R : Positive; S : Combined_Value)
     return Sum_Value is
     (case J.Widths (R) mod 4 is
        when 3 => ((S + Product (J.Values (J.Offsets (R)+J.Widths (R)-2),
                                X (J.Columns (J.Offsets (R)+J.Widths (R)-2))))
                       + Product (J.Values (J.Offsets (R)+J.Widths (R)-1),
                                  X (J.Columns (J.Offsets (R)+J.Widths (R)-1))))
                       + Product (J.Values (J.Offsets (R)+J.Widths (R)),
                                  X (J.Columns (J.Offsets (R)+J.Widths (R)))),
        when 2 => (S + Product (J.Values (J.Offsets (R)+J.Widths (R)-1),
                                X (J.Columns (J.Offsets (R)+J.Widths (R)-1))))
                     + Product (J.Values (J.Offsets (R)+J.Widths (R)),
                                X (J.Columns (J.Offsets (R)+J.Widths (R)))),
        when 1 => S + Product (J.Values (J.Offsets (R)+J.Widths (R)),
                               X (J.Columns (J.Offsets (R)+J.Widths (R)))),
        when others => S)
     with Ghost => Static, Global => null,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Tail (J : Sparse_Jacobian; X : Vector; R : Positive; S : Combined_Value)
     return Sum_Value with Global => null, Inline_Always,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count,
     Post => (Static => Tail'Result = Tail_Value (J, X, R, S));
   function Row_Value (J : Sparse_Jacobian; X : Vector; R : Positive) return Sum_Value is
     (Tail_Value (J, X, R, Combine_Value (Lane_Sum (J, X, R, J.Widths (R)/4, 0),
                             Lane_Sum (J, X, R, J.Widths (R)/4, 1),
                             Lane_Sum (J, X, R, J.Widths (R)/4, 2),
                             Lane_Sum (J, X, R, J.Widths (R)/4, 3))))
     with Ghost => Static, Global => null,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count,
     Post => Row_Value'Result = Tail_Value (J, X, R,
       Combine_Value (Lane_Sum (J, X, R, J.Widths (R)/4, 0),
                Lane_Sum (J, X, R, J.Widths (R)/4, 1),
                Lane_Sum (J, X, R, J.Widths (R)/4, 2),
                Lane_Sum (J, X, R, J.Widths (R)/4, 3)));
   function Sparse_Row (J : Sparse_Jacobian; X : Vector; R : Positive) return Sum_Value with
     Global => null,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count,
     Post => (Static => Sparse_Row'Result = Row_Value (J, X, R));
   function Dense_Values (J : Matrix; R : Positive) return Vector is
     ([for C in J'Range (2) => J (R, C)]) with Ghost => Static, Global => null,
     Pre => J'First (1) = 1 and then J'First (2) = 1 and then R <= J'Last (1)
       and then J'Length (2) <= Max_Dofs
       and then (for all C in J'Range (2) => J (R, C) in Operand),
     Post => Dense_Values'Result'First = 1
       and then Dense_Values'Result'Length = J'Length (2)
       and then Dense_Values'Result'Last = (if J'Length (2) = 0 then 0 else J'Last (2))
       and then (for all C in J'Range (2) => Dense_Values'Result (C) = J (R, C))
       and then Bounded (Dense_Values'Result);
   function Dense_Row (J : Matrix; X : Vector; R : Positive) return Sum_Value with
     Global => null,
     Pre => J'First (1) = 1 and then J'First (2) = 1 and then X'First = 1
       and then J'Length (2) = X'Length and then X'Length <= Max_Dofs
       and then R <= J'Last (1) and then Bounded (X)
       and then (for all C in J'Range (2) => J (R, C) in Operand),
     Post => (Static => (if X'Length = 0 then Dense_Row'Result = 0.0
       else Dense_Row'Result = Reduction_Models.Dot_Value (Dense_Values (J, R), X)));
end MJ.Constraint_Solvers.Jacobians;

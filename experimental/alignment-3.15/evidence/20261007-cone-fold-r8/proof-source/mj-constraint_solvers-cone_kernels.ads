--  Ordered local Lc' * Jc from C 3.15 HessianConeFolded.
package MJ.Constraint_Solvers.Cone_Kernels with SPARK_Mode is
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
end MJ.Constraint_Solvers.Cone_Kernels;

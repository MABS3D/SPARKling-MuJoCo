package body MJ.Constraint_Solvers.Cone_Kernels with SPARK_Mode is
   procedure Unfold_Fold (L : Local_Matrix; J : Local_Vector;
                          Col : Component; Count : Positive) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Fold_Value);
   begin
      case Count is
         when 1 =>
            pragma Assert (Static => Fold_Value (L, J, Col, Count) = Add_Scaled
              (Fold_Value (L, J, Col, Count - 1), J (Col), L (Col, Col), 0));
         when 2 =>
            pragma Assert (Static => Fold_Value (L, J, Col, Count) = Add_Scaled
              (Fold_Value (L, J, Col, Count - 1), J (Col + 1), L (Col + 1, Col), 1));
         when 3 =>
            pragma Assert (Static => Fold_Value (L, J, Col, Count) = Add_Scaled
              (Fold_Value (L, J, Col, Count - 1), J (Col + 2), L (Col + 2, Col), 2));
         when 4 =>
            pragma Assert (Static => Fold_Value (L, J, Col, Count) = Add_Scaled
              (Fold_Value (L, J, Col, Count - 1), J (Col + 3), L (Col + 3, Col), 3));
         when 5 =>
            pragma Assert (Static => Fold_Value (L, J, Col, Count) = Add_Scaled
              (Fold_Value (L, J, Col, Count - 1), J (Col + 4), L (Col + 4, Col), 4));
         when 6 =>
            pragma Assert (Static => Fold_Value (L, J, Col, Count) = Add_Scaled
              (Fold_Value (L, J, Col, Count - 1), J (Col + 5), L (Col + 5, Col), 5));
         when others => pragma Assert (Static => False);
      end case;
   end Unfold_Fold;

   procedure Fold_Column (L : Local_Matrix; J : Local_Vector;
                          Dim : Component; Output : out Local_Vector) is
      Acc : Folded_Value;
   begin
      Output := (others => 0.0);
      for C in 1 .. Dim loop
         Acc := 0.0;
         for K in 1 .. Dim - C + 1 loop
            pragma Loop_Invariant (Static => Acc = Fold_Value (L, J, C, K - 1));
            pragma Loop_Invariant (abs Acc <= Real (K - 1) * Step_Bound);
            Unfold_Fold (L, J, C, K);
            Acc := Add_Scaled (Acc, J (C + K - 1), L (C + K - 1, C), K - 1);
            pragma Assert (Static => Acc = Fold_Value (L, J, C, K));
         end loop;
         Output (C) := Acc;
         pragma Loop_Invariant (Static => (for all P in 1 .. C =>
           Output (P) = Fold_Value (L, J, P, Dim - P + 1)));
         pragma Loop_Invariant (for all P in C + 1 .. 6 => Output (P) = 0.0);
         pragma Loop_Invariant (for all V of Output => V in Folded_Value);
      end loop;
   end Fold_Column;

   function Gram_Update (Previous : Real; Left, Right : Folded_Value;
                         Weight : Real) return Real is
   begin
      return Previous + (Weight * Left) * Right;
   end Gram_Update;
end MJ.Constraint_Solvers.Cone_Kernels;

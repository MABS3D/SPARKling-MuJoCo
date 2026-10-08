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

   function Gram_Scale (Left, Weight : Real) return Real is (Weight*Left);

   function Gram_Scaled (Previous, Scale, Right : Real) return Real is
     (if Scale = 0.0 then Previous else Previous + Scale*Right);

   procedure Gram_From_Scaled (Previous, Left, Right, Weight : Real) is
   begin
      null;
   end Gram_From_Scaled;

   function Gram_Source (Values : Matrix; Columns : Column_Matrix;
                         Source_Row, Index_Row, Slot : Positive; Packed : Boolean) return Real is
     (Values (Source_Row, (if Packed then Slot else Columns (Index_Row, Slot))));

   procedure Gram_Row (H : in out Matrix; Values : Matrix; Columns : Column_Matrix;
                       Source_Row, Index_Row : Positive; Width : Natural;
                       Weight : Real; Packed : Boolean; Accepted : out Boolean) is
      Before : constant Matrix := H with Ghost => Static;
      P, Q : Positive;
      Scale : Real;
   begin
      Accepted := False;
      for Pi in 1 .. Width loop
         P := Columns (Index_Row, Pi);
         Scale := Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, Pi, Packed), Weight);
         if Scale /= 0.0 then
            for Qi in 1 .. Pi loop
               Q := Columns (Index_Row, Qi);
               H (P, Q) := Gram_Scaled (H (P, Q), Scale,
                 Gram_Source (Values, Columns, Source_Row, Index_Row, Qi, Packed));
               if H (P, Q) not in Dense.Operand then return; end if;
               pragma Loop_Invariant (Dense.Bounded (H));
               pragma Loop_Invariant (Static => (for all J in 1 .. Qi =>
                 H (P, Columns (Index_Row, J)) = Gram_Scaled
                   (Before (P, Columns (Index_Row, J)), Scale,
                    Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed))));
               pragma Loop_Invariant (Static => (for all J in Qi+1 .. Pi =>
                 H (P, Columns (Index_Row, J)) = Before (P, Columns (Index_Row, J))));
               pragma Loop_Invariant (Static => (for all I in 1 .. Pi-1 =>
                 (for all J in 1 .. I => H (Columns (Index_Row, I), Columns (Index_Row, J)) =
                   Gram_Scaled (Before (Columns (Index_Row, I), Columns (Index_Row, J)),
                     Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, I, Packed), Weight),
                     Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))));
               pragma Loop_Invariant (Static => (for all R in H'Range (1) =>
                 (for all C in H'Range (2) =>
                   (if (for all I in 1 .. Pi-1 => (for all J in 1 .. I =>
                     Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C))
                     and then (for all J in 1 .. Qi => P /= R or else Columns (Index_Row, J) /= C)
                    then H (R, C) = Before (R, C)))));
            end loop;
         end if;
         pragma Loop_Invariant (Dense.Bounded (H));
         pragma Loop_Invariant (Static => (for all I in 1 .. Pi =>
           (for all J in 1 .. I => H (Columns (Index_Row, I), Columns (Index_Row, J)) =
             Gram_Scaled (Before (Columns (Index_Row, I), Columns (Index_Row, J)),
               Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, I, Packed), Weight),
               Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))));
         pragma Loop_Invariant (Static => (for all R in H'Range (1) =>
           (for all C in H'Range (2) =>
             (if (for all I in 1 .. Pi => (for all J in 1 .. I =>
               Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C))
              then H (R, C) = Before (R, C)))));
      end loop;
      Accepted := True;
   end Gram_Row;
end MJ.Constraint_Solvers.Cone_Kernels;

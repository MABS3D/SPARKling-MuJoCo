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

   procedure Gram_Columns_Ordered (Columns : Column_Matrix; Index_Row : Positive;
                                   Width : Natural; N, First, Last : Positive)
     with Ghost => Static, Global => null,
     Pre => Gram_Support (Columns, Index_Row, Width, N)
       and then First <= Last and then Last <= Width,
     Post => Columns (Index_Row, First) <= Columns (Index_Row, Last)
       and then (if First < Last then Columns (Index_Row, First) < Columns (Index_Row, Last)),
     Subprogram_Variant => (Decreases => Last)
   is
   begin
      if First < Last then Gram_Columns_Ordered (Columns, Index_Row, Width, N, First, Last-1); end if;
   end Gram_Columns_Ordered;

   procedure Gram_Separate_Column (Columns : Column_Matrix; Index_Row : Positive;
                                   Width : Natural; N, Position : Positive)
     with Ghost => Static, Global => null,
     Pre => Gram_Support (Columns, Index_Row, Width, N) and then Position <= Width,
     Post => (for all K in 1 .. Width =>
       (if K /= Position then Columns (Index_Row, K) /= Columns (Index_Row, Position)))
   is
   begin
      for K in 1 .. Width loop
         if K < Position then Gram_Columns_Ordered (Columns, Index_Row, Width, N, K, Position);
         elsif K > Position then Gram_Columns_Ordered (Columns, Index_Row, Width, N, Position, K);
         end if;
         pragma Loop_Invariant (for all Q in 1 .. K =>
           (if Q /= Position then Columns (Index_Row, Q) /= Columns (Index_Row, Position)));
      end loop;
   end Gram_Separate_Column;

   procedure Gram_Prefix (H : in out Matrix; Values : Matrix; Columns : Column_Matrix;
                         Source_Row, Index_Row : Positive; Width : Natural;
                         Position : Positive; Scale : Real; Packed : Boolean;
                         Accepted : out Boolean)
     with Global => null, Inline_Always,
     Pre => (Static => Dense.Square (H) and then Dense.Bounded (H)
       and then Source_Row in Values'Range (1) and then Values'First (2) = 1
       and then Gram_Support (Columns, Index_Row, Width, H'Length (1))
       and then Position <= Width
       and then (if Packed then Width <= Values'Length (2) else H'Length (1) <= Values'Length (2))
       and then Scale in -3.0e147 .. 3.0e147
       and then (for all I in Values'Range (1) =>
         (for all J in Values'Range (2) => Values (I, J) in Folded_Value))),
     Post => (Static =>
       (for all R in H'Range (1) => (if R /= Columns (Index_Row, Position) then
         (for all C in H'Range (2) => H (R, C) = H'Old (R, C))))
       and then (for all C in H'Range (2) =>
         (if (for all J in 1 .. Position => Columns (Index_Row, J) /= C)
          then H (Columns (Index_Row, Position), C) = H'Old (Columns (Index_Row, Position), C)))
       and then (if Accepted then Dense.Bounded (H)
         and then (for all J in 1 .. Position =>
           H (Columns (Index_Row, Position), Columns (Index_Row, J)) = Gram_Scaled
             (H'Old (Columns (Index_Row, Position), Columns (Index_Row, J)), Scale,
              Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))))
   is
      Before : constant Matrix := H with Ghost => Static;
      P : constant Positive := Columns (Index_Row, Position);
      Q : Positive;
   begin
      Accepted := False;
      if Scale = 0.0 then Accepted := True; return; end if;
      for Qi in 1 .. Position loop
         Gram_Separate_Column (Columns, Index_Row, Width, H'Length (1), Qi);
         Q := Columns (Index_Row, Qi);
         H (P, Q) := Gram_Scaled (H (P, Q), Scale,
           Gram_Source (Values, Columns, Source_Row, Index_Row, Qi, Packed));
         if H (P, Q) not in Dense.Operand then return; end if;
         pragma Loop_Invariant (Dense.Bounded (H));
         pragma Loop_Invariant (Static => (for all J in 1 .. Qi =>
           H (P, Columns (Index_Row, J)) = Gram_Scaled
             (Before (P, Columns (Index_Row, J)), Scale,
              Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed))));
         pragma Loop_Invariant (Static => (for all J in Qi+1 .. Position =>
           H (P, Columns (Index_Row, J)) = Before (P, Columns (Index_Row, J))));
         pragma Loop_Invariant (Static => (for all R in H'Range (1) =>
           (if R /= P then (for all C in H'Range (2) => H (R, C) = Before (R, C)))));
         pragma Loop_Invariant (Static => (for all C in H'Range (2) =>
           (if (for all J in 1 .. Qi => Columns (Index_Row, J) /= C)
            then H (P, C) = Before (P, C))));
      end loop;
      Accepted := True;
   end Gram_Prefix;

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
         Gram_Separate_Column (Columns, Index_Row, Width, H'Length (1), Pi);
         Gram_Prefix (H, Values, Columns, Source_Row, Index_Row, Width, Pi, Scale, Packed, Accepted);
         if not Accepted then return; end if;
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

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

   --  One ordered update, including the existing numeric-limit failure write.
   procedure Gram_Element (H : in out Matrix; P, Q : Positive;
                           Scale, Right : Real; Accepted : out Boolean)
     with Global => null, Inline_Always,
     Pre => (Static => Dense.Square (H) and then Dense.Bounded (H)
       and then P in H'Range (1) and then Q in H'Range (2)
       and then Scale in -3.0e147 .. 3.0e147 and then Right in Folded_Value),
     Post => (Static => H (P, Q) = Gram_Scaled (H'Old (P, Q), Scale, Right)
       and then Accepted = (H (P, Q) in Dense.Operand)
       and then (if Accepted then Dense.Bounded (H))
       and then (for all C in H'Range (2) => (if C /= Q then H (P, C) = H'Old (P, C)))
       and then (for all R in H'Range (1) => (if R /= P then
         (for all C in H'Range (2) => H (R, C) = H'Old (R, C)))))
   is
   begin
      H (P, Q) := Gram_Scaled (H (P, Q), Scale, Right);
      Accepted := H (P, Q) in Dense.Operand;
   end Gram_Element;

   procedure Gram_Prefix_Progress (Original, Before, After, Values : Matrix;
                                  Columns : Column_Matrix;
                                  Source_Row, Index_Row : Positive; Width : Natural;
                                  Position, Step : Positive; Scale : Real; Packed : Boolean)
     with Ghost => Static, Global => null,
     Pre => Dense.Square (Original) and then Dense.Bounded (Original)
       and then Before'First (1) = 1 and then Before'First (2) = 1
       and then Before'Length (1) = Original'Length (1) and then Before'Length (2) = Original'Length (2)
       and then After'First (1) = 1 and then After'First (2) = 1
       and then After'Length (1) = Original'Length (1) and then After'Length (2) = Original'Length (2)
       and then Source_Row in Values'Range (1) and then Values'First (2) = 1
       and then Gram_Support (Columns, Index_Row, Width, Original'Length (1))
       and then Step <= Position and then Position <= Width
       and then (if Packed then Width <= Values'Length (2) else Original'Length (1) <= Values'Length (2))
       and then Scale in -3.0e147 .. 3.0e147
       and then (for all I in Values'Range (1) => (for all J in Values'Range (2) => Values (I, J) in Folded_Value))
       and then Before (Columns (Index_Row, Position), Columns (Index_Row, Step)) =
         Original (Columns (Index_Row, Position), Columns (Index_Row, Step))
       and then After (Columns (Index_Row, Position), Columns (Index_Row, Step)) = Gram_Scaled
         (Original (Columns (Index_Row, Position), Columns (Index_Row, Step)), Scale,
          Gram_Source (Values, Columns, Source_Row, Index_Row, Step, Packed))
       and then (for all J in 1 .. Step => (if J < Step then
         Before (Columns (Index_Row, Position), Columns (Index_Row, J)) = Gram_Scaled
           (Original (Columns (Index_Row, Position), Columns (Index_Row, J)), Scale,
            Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed))))
       and then (for all C in Original'Range (2) =>
         (if C /= Columns (Index_Row, Step) then
           After (Columns (Index_Row, Position), C) = Before (Columns (Index_Row, Position), C))),
     Post => (for all J in 1 .. Step =>
       After (Columns (Index_Row, Position), Columns (Index_Row, J)) = Gram_Scaled
         (Original (Columns (Index_Row, Position), Columns (Index_Row, J)), Scale,
          Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))
   is
   begin
      Gram_Separate_Column (Columns, Index_Row, Width, Original'Length (1), Step);
      for J in 1 .. Step loop
         if J < Step then
            pragma Assert (After (Columns (Index_Row, Position), Columns (Index_Row, J)) =
              Before (Columns (Index_Row, Position), Columns (Index_Row, J)));
         end if;
         pragma Loop_Invariant (for all K in 1 .. J =>
           After (Columns (Index_Row, Position), Columns (Index_Row, K)) = Gram_Scaled
             (Original (Columns (Index_Row, Position), Columns (Index_Row, K)), Scale,
              Gram_Source (Values, Columns, Source_Row, Index_Row, K, Packed)));
      end loop;
   end Gram_Prefix_Progress;

   procedure Gram_Frame_Transitive (Original, Before, After : Matrix; P : Positive)
     with Ghost => Static, Global => null,
     Pre => Dense.Square (Original) and then Dense.Square (Before) and then Dense.Square (After)
       and then Original'Length (1) = Before'Length (1)
       and then Original'Length (1) = After'Length (1) and then P <= Original'Length (1)
       and then (for all R in Before'Range (1) => (if R /= P then
         (for all C in Before'Range (2) => Before (R, C) = Original (R, C))))
       and then (for all R in After'Range (1) => (if R /= P then
         (for all C in After'Range (2) => After (R, C) = Before (R, C)))),
     Post => (for all R in After'Range (1) => (if R /= P then
       (for all C in After'Range (2) => After (R, C) = Original (R, C))))
   is
   begin
      for R in After'Range (1) loop
         if R /= P then
            for C in After'Range (2) loop
               pragma Assert (After (R, C) = Original (R, C));
               pragma Loop_Invariant (for all K in After'First (2) .. C => After (R, K) = Original (R, K));
            end loop;
         end if;
         pragma Loop_Invariant (for all I in After'First (1) .. R => (if I /= P then
           (for all C in After'Range (2) => After (I, C) = Original (I, C))));
      end loop;
   end Gram_Frame_Transitive;

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
      Iteration_Before : Matrix (H'Range (1), H'Range (2)) with Ghost => Static;
      P : constant Positive := Columns (Index_Row, Position);
      Q : Positive;
   begin
      Accepted := False;
      if Scale = 0.0 then Accepted := True; return; end if;
      for Qi in 1 .. Position loop
         Gram_Separate_Column (Columns, Index_Row, Width, H'Length (1), Qi);
         Q := Columns (Index_Row, Qi);
         Iteration_Before := H;
         pragma Assert (Static => H (P, Q) = Before (P, Q));
         Gram_Element (H, P, Q, Scale,
           Gram_Source (Values, Columns, Source_Row, Index_Row, Qi, Packed), Accepted);
         Gram_Frame_Transitive (Before, Iteration_Before, H, P);
         if not Accepted then return; end if;
         Gram_Prefix_Progress (Before, Iteration_Before, H, Values, Columns,
           Source_Row, Index_Row, Width, Position, Qi, Scale, Packed);
         pragma Loop_Invariant (Dense.Bounded (H));
         pragma Loop_Invariant (Static => (for all J in 1 .. Qi =>
           H (P, Columns (Index_Row, J)) = Gram_Scaled
             (Before (P, Columns (Index_Row, J)), Scale,
              Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed))));
         pragma Loop_Invariant (Static => (for all J in 1 .. Position =>
           (if J > Qi then H (P, Columns (Index_Row, J)) = Before (P, Columns (Index_Row, J)))));
         pragma Loop_Invariant (Static => (for all R in H'Range (1) =>
           (if R /= P then (for all C in H'Range (2) => H (R, C) = Before (R, C)))));
         pragma Loop_Invariant (Static => (for all C in H'Range (2) =>
           (if (for all J in 1 .. Qi => Columns (Index_Row, J) /= C)
            then H (P, C) = Before (P, C))));
      end loop;
      Accepted := True;
   end Gram_Prefix;

   procedure Gram_Row_Progress (Original, Before, After, Values : Matrix;
                               Columns : Column_Matrix; Source_Row, Index_Row : Positive;
                               Width : Natural; Step : Positive; Weight : Real; Packed : Boolean)
     with Ghost => Static, Global => null,
     Pre => Dense.Square (Original) and then Dense.Bounded (Original)
       and then Dense.Square (Before) and then Dense.Square (After)
       and then Before'Length (1) = Original'Length (1) and then After'Length (1) = Original'Length (1)
       and then Source_Row in Values'Range (1) and then Values'First (2) = 1
       and then Gram_Support (Columns, Index_Row, Width, Original'Length (1)) and then Step <= Width
       and then (if Packed then Width <= Values'Length (2) else Original'Length (1) <= Values'Length (2))
       and then Weight in 0.0 .. 1.0e15
       and then (for all R in Values'Range (1) => (for all C in Values'Range (2) => Values (R, C) in Folded_Value))
       and then (for all I in 1 .. Width => (if I >= Step then
         (for all C in Original'Range (2) => Before (Columns (Index_Row, I), C) = Original (Columns (Index_Row, I), C))))
       and then (for all I in 1 .. Step => (if I < Step then (for all J in 1 .. I =>
         Before (Columns (Index_Row, I), Columns (Index_Row, J)) = Gram_Scaled
           (Original (Columns (Index_Row, I), Columns (Index_Row, J)),
            Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, I, Packed), Weight),
            Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))))
       and then (for all J in 1 .. Step => After (Columns (Index_Row, Step), Columns (Index_Row, J)) = Gram_Scaled
         (Original (Columns (Index_Row, Step), Columns (Index_Row, J)),
          Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, Step, Packed), Weight),
          Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))
       and then (for all R in Original'Range (1) => (if R /= Columns (Index_Row, Step) then
         (for all C in Original'Range (2) => After (R, C) = Before (R, C)))),
     Post => (for all I in 1 .. Width => (if I > Step then
       (for all C in Original'Range (2) => After (Columns (Index_Row, I), C) = Original (Columns (Index_Row, I), C))))
       and then (for all I in 1 .. Step => (for all J in 1 .. I =>
         After (Columns (Index_Row, I), Columns (Index_Row, J)) = Gram_Scaled
           (Original (Columns (Index_Row, I), Columns (Index_Row, J)),
            Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, I, Packed), Weight),
            Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed))))
   is
   begin
      Gram_Separate_Column (Columns, Index_Row, Width, Original'Length (1), Step);
      for I in 1 .. Width loop
         if I /= Step then
            pragma Assert (for all C in Original'Range (2) =>
              After (Columns (Index_Row, I), C) = Before (Columns (Index_Row, I), C));
         end if;
         pragma Loop_Invariant (for all K in 1 .. I => (if K > Step then
           (for all C in Original'Range (2) => After (Columns (Index_Row, K), C) = Original (Columns (Index_Row, K), C))));
         pragma Loop_Invariant (for all K in 1 .. I => (if K <= Step then (for all J in 1 .. K =>
           After (Columns (Index_Row, K), Columns (Index_Row, J)) = Gram_Scaled
             (Original (Columns (Index_Row, K), Columns (Index_Row, J)),
              Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, K, Packed), Weight),
              Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))));
      end loop;
   end Gram_Row_Progress;

   procedure Gram_Row_Frame (Original, Before, After : Matrix; Columns : Column_Matrix;
                             Index_Row : Positive; Width : Natural; Step : Positive)
     with Ghost => Static, Global => null,
     Pre => Dense.Square (Original) and then Dense.Square (Before) and then Dense.Square (After)
       and then Before'Length (1) = Original'Length (1) and then After'Length (1) = Original'Length (1)
       and then Gram_Support (Columns, Index_Row, Width, Original'Length (1)) and then Step <= Width
       and then (for all R in Original'Range (1) => (if R /= Columns (Index_Row, Step) then
         (for all C in Original'Range (2) => After (R, C) = Before (R, C))))
       and then (for all C in Original'Range (2) =>
         (if (for all J in 1 .. Step => Columns (Index_Row, J) /= C) then
           After (Columns (Index_Row, Step), C) = Before (Columns (Index_Row, Step), C)))
       and then (for all R in Original'Range (1) => (for all C in Original'Range (2) =>
         (if (for all I in 1 .. Step-1 => (for all J in 1 .. I =>
           Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C))
          then Before (R, C) = Original (R, C)))),
     Post => (for all R in Original'Range (1) => (for all C in Original'Range (2) =>
       (if (for all I in 1 .. Step => (for all J in 1 .. I =>
         Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C)) then After (R, C) = Original (R, C))))
   is
      P : constant Positive := Columns (Index_Row, Step);
   begin
      for R in Original'Range (1) loop
         for C in Original'Range (2) loop
            if (for all I in 1 .. Step => (for all J in 1 .. I =>
              Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C)) then
               if R = P then
                  pragma Assert (for all J in 1 .. Step => Columns (Index_Row, J) /= C);
               end if;
               pragma Assert (Before (R, C) = Original (R, C));
               pragma Assert (After (R, C) = Before (R, C));
            end if;
            pragma Loop_Invariant (for all Q in Original'First (2) .. C =>
              (if (for all I in 1 .. Step => (for all J in 1 .. I =>
                Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= Q)) then After (R, Q) = Original (R, Q)));
         end loop;
         pragma Loop_Invariant (for all K in Original'First (1) .. R => (for all C in Original'Range (2) =>
           (if (for all I in 1 .. Step => (for all J in 1 .. I =>
             Columns (Index_Row, I) /= K or else Columns (Index_Row, J) /= C)) then After (K, C) = Original (K, C))));
      end loop;
   end Gram_Row_Frame;

   procedure Gram_Row (H : in out Matrix; Values : Matrix; Columns : Column_Matrix;
                       Source_Row, Index_Row : Positive; Width : Natural;
                       Weight : Real; Packed : Boolean; Accepted : out Boolean) is
      Before : constant Matrix := H with Ghost => Static;
      P : Positive;
      Scale : Real;
   begin
      Accepted := False;
      for Pi in 1 .. Width loop
         pragma Loop_Invariant (Dense.Bounded (H));
         pragma Loop_Invariant (Static => Dense.Bounded (Before));
         pragma Loop_Invariant (Static => (for all I in 1 .. Width => (if I >= Pi then
           (for all C in H'Range (2) => H (Columns (Index_Row, I), C) = Before (Columns (Index_Row, I), C)))));
         pragma Loop_Invariant (Static => (for all I in 1 .. Pi-1 =>
           (for all J in 1 .. I => H (Columns (Index_Row, I), Columns (Index_Row, J)) =
             Gram_Scaled (Before (Columns (Index_Row, I), Columns (Index_Row, J)),
               Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, I, Packed), Weight),
               Gram_Source (Values, Columns, Source_Row, Index_Row, J, Packed)))));
         pragma Loop_Invariant (Static => (for all R in H'Range (1) =>
           (for all C in H'Range (2) =>
             (if (for all I in 1 .. Pi-1 => (for all J in 1 .. I =>
               Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C))
              then H (R, C) = Before (R, C)))));
         P := Columns (Index_Row, Pi);
         pragma Assert (Static => (for all C in H'Range (2) => H (P, C) = Before (P, C)));
         Scale := Gram_Scale (Gram_Source (Values, Columns, Source_Row, Index_Row, Pi, Packed), Weight);
         Gram_Separate_Column (Columns, Index_Row, Width, H'Length (1), Pi);
         declare
            Iteration_Before : constant Matrix := H with Ghost => Static;
         begin
         pragma Assert (Static => (for all R in H'Range (1) => (for all C in H'Range (2) =>
           (if (for all I in 1 .. Pi-1 => (for all J in 1 .. I =>
             Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C))
            then Iteration_Before (R, C) = Before (R, C)))));
         Gram_Prefix (H, Values, Columns, Source_Row, Index_Row, Width, Pi, Scale, Packed, Accepted);
         if not Accepted then return; end if;
         pragma Assert (Static => (for all R in H'Range (1) => (if R /= P then
           (for all C in H'Range (2) => H (R, C) = Iteration_Before (R, C)))));
         pragma Assert (Static => (for all C in H'Range (2) =>
           (if (for all J in 1 .. Pi => Columns (Index_Row, J) /= C) then H (P, C) = Iteration_Before (P, C))));
         Gram_Row_Frame (Before, Iteration_Before, H, Columns, Index_Row, Width, Pi);
         pragma Assert (Static => (for all R in H'Range (1) => (for all C in H'Range (2) =>
           (if (for all I in 1 .. Pi => (for all J in 1 .. I =>
             Columns (Index_Row, I) /= R or else Columns (Index_Row, J) /= C))
            then H (R, C) = Before (R, C)))));
         Gram_Row_Progress (Before, Iteration_Before, H, Values, Columns,
           Source_Row, Index_Row, Width, Pi, Weight, Packed);
         end;
      end loop;
      Accepted := True;
   end Gram_Row;
end MJ.Constraint_Solvers.Cone_Kernels;

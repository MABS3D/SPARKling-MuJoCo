package body MJ.Constraint_Solvers.Jacobians with SPARK_Mode is
   function Product (A, B : Operand) return Real is (A*B);
   function Add (Acc, Term : Real; Count : Entry_Count) return Lane_Value is (Acc+Term);
   function Combine (A, B, C, D : Lane_Value) return Combined_Value is ((A+C)+(B+D));

   procedure Unfold_Lane (J : Sparse_Jacobian; X : Vector; R : Positive;
                          Count : Entry_Count; Lane : Lane_Number) with
     Ghost => Static, Global => null,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count and then Count < J.Widths (R)/4,
     Post => Lane_Sum (J, X, R, Count+1, Lane) =
       (if Count = 0 then Product (J.Values (J.Offsets (R)+Lane+1),
                                  X (J.Columns (J.Offsets (R)+Lane+1)))
        else Add (Lane_Sum (J, X, R, Count, Lane),
          Product (J.Values (J.Offsets (R)+4*Count+Lane+1),
                   X (J.Columns (J.Offsets (R)+4*Count+Lane+1))), Count))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Lane_Sum);
   begin
      null;
   end Unfold_Lane;

   function Advance_Lane (J : Sparse_Jacobian; X : Vector; R : Positive;
                         Count : Entry_Count; Lane : Lane_Number; Acc : Lane_Value)
      return Lane_Value with Global => null, Inline_Always,
     Pre => (Static => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count and then Count < J.Widths (R)/4
       and then Acc = Lane_Sum (J, X, R, Count, Lane)),
     Post => (Static => Advance_Lane'Result = Lane_Sum (J, X, R, Count+1, Lane)
       and then abs Advance_Lane'Result <= Real (Count+1)*Step_Bound)
   is
      I : constant Positive := J.Offsets (R)+4*Count+Lane+1;
   begin
      Unfold_Lane (J, X, R, Count, Lane);
      if Count = 0 then
         --  The normal SIMD C path seeds its lanes with the first products,
         --  preserving negative zero when all products in a lane are -0.
         return Product (J.Values (I), X (J.Columns (I)));
      end if;
      return Add (Acc, Product (J.Values (I), X (J.Columns (I))), Count);
   end Advance_Lane;

   procedure Blocks (J : Sparse_Jacobian; X : Vector; R : Positive;
                     A, B, C, D : out Lane_Value) with Global => null,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count,
     Post => (Static => A = Lane_Sum (J, X, R, J.Widths (R)/4, 0)
       and then B = Lane_Sum (J, X, R, J.Widths (R)/4, 1)
       and then C = Lane_Sum (J, X, R, J.Widths (R)/4, 2)
       and then D = Lane_Sum (J, X, R, J.Widths (R)/4, 3))
   is
   begin
      A := 0.0; B := 0.0; C := 0.0; D := 0.0;
      for I in 0 .. J.Widths (R)/4-1 loop
         A := Advance_Lane (J, X, R, I, 0, A);
         B := Advance_Lane (J, X, R, I, 1, B);
         C := Advance_Lane (J, X, R, I, 2, C);
         D := Advance_Lane (J, X, R, I, 3, D);
         pragma Loop_Invariant (Static => A = Lane_Sum (J, X, R, I+1, 0)
           and then B = Lane_Sum (J, X, R, I+1, 1)
           and then C = Lane_Sum (J, X, R, I+1, 2)
           and then D = Lane_Sum (J, X, R, I+1, 3));
      end loop;
   end Blocks;

   function Tail (J : Sparse_Jacobian; X : Vector; R : Positive; S : Combined_Value)
     return Sum_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Tail_Value);
      Last : constant Entry_Count := J.Offsets (R)+J.Widths (R);
   begin
      case J.Widths (R) mod 4 is
         when 3 => return ((S + Product (J.Values (Last-2), X (J.Columns (Last-2))))
                              + Product (J.Values (Last-1), X (J.Columns (Last-1))))
                              + Product (J.Values (Last), X (J.Columns (Last)));
         when 2 => return (S + Product (J.Values (Last-1), X (J.Columns (Last-1))))
                             + Product (J.Values (Last), X (J.Columns (Last)));
         when 1 => return S + Product (J.Values (Last), X (J.Columns (Last)));
         when others => return S;
      end case;
   end Tail;

   procedure Equal_Tails (J : Sparse_Jacobian; X : Vector; R : Positive;
                          A, B : Combined_Value) with Ghost => Static, Global => null,
     Pre => X'First = 1 and then X'Length > 0 and then Valid (J, X'Length)
       and then Bounded (X) and then R <= J.Row_Count and then A = B,
     Post => Tail_Value (J, X, R, A) = Tail_Value (J, X, R, B)
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Tail_Value);
   begin
      null;
   end Equal_Tails;

   function Sparse_Row (J : Sparse_Jacobian; X : Vector; R : Positive) return Sum_Value is
      A, B, C, D : Lane_Value;
      Expected : constant Sum_Value := Row_Value (J, X, R) with Ghost => Static;
      Expected_Sum : constant Combined_Value := Combine_Value
        (Lane_Sum (J, X, R, J.Widths (R)/4, 0), Lane_Sum (J, X, R, J.Widths (R)/4, 1),
         Lane_Sum (J, X, R, J.Widths (R)/4, 2), Lane_Sum (J, X, R, J.Widths (R)/4, 3))
        with Ghost => Static;
      S : Combined_Value;
      Value : Sum_Value;
   begin
      Blocks (J, X, R, A, B, C, D);
      S := Combine (A, B, C, D);
      pragma Assert (Static => S = Expected_Sum);
      Value := Tail (J, X, R, S);
      Equal_Tails (J, X, R, S, Expected_Sum);
      pragma Assert (Static => Value = Tail_Value (J, X, R, Expected_Sum));
      pragma Assert (Static => Expected = Tail_Value (J, X, R, Expected_Sum));
      pragma Assert (Static => Value = Expected);
      return Value;
   end Sparse_Row;

   procedure Equal_Products (A, B, C : Operand) with Ghost => Static,
     Global => null, Pre => A = B, Post => A*C = B*C
   is
   begin
      null;
   end Equal_Products;

   procedure Dense_Lane_Updated
     (A, B : Vector; Count : Reduction_Models.Block_Count;
      Lane : Reduction_Models.Lane_Number; Previous, Term, Updated : Real)
     with Ghost => Static, Global => null,
     Pre => A'First = 1 and then A'Length <= Max_Rows
       and then B'First = 1 and then B'Last = A'Last
       and then Bounded (A) and then Bounded (B) and then Count < A'Length/4
       and then Previous = Reduction_Models.Lane_Sum (A, B, Count, Lane)
       and then Term = A (4*Count+Lane+1)*B (4*Count+Lane+1)
       and then Updated = (if Count = 0 then Term else Previous+Term),
     Post => Updated = Reduction_Models.Lane_Sum (A, B, Count+1, Lane)
   is
   begin
      Reduction_Models.Unfold_Lane (A, B, Count, Lane);
   end Dense_Lane_Updated;

   function Dense_Row (J : Matrix; X : Vector; R : Positive) return Sum_Value is
      Values : constant Vector := Dense_Values (J, R) with Ghost => Static;
      A, B, C, D : Lane_Value := 0.0;
      Count : constant Natural := X'Length;
      Offset : constant Natural := 4*(Count/4);
      S : Combined_Value;
      subtype Product_Number is Real range -1.0e240 .. 1.0e240;
      function Term (Col : Positive) return Product_Number
        with Pre => (Static => Col in X'Range and then R in J'Range (1)
               and then Col in J'Range (2) and then Col in Values'Range
               and then X (Col) in Operand and then J (R, Col) in Operand
               and then Values (Col) = J (R, Col)),
             Post => (Static => Term'Result = J (R, Col)*X (Col)
               and then Term'Result = Values (Col)*X (Col)
               and then abs Term'Result <= 1.0e240)
      is
      begin
         Equal_Products (J (R, Col), Values (Col), X (Col));
         return Product (J (R, Col), X (Col));
      end Term;
   begin
      if Count = 0 then return 0.0; end if;
      for I in 0 .. Count/4-1 loop
         pragma Loop_Invariant (Static => A = Reduction_Models.Lane_Sum (Values, X, I, 0)
           and then B = Reduction_Models.Lane_Sum (Values, X, I, 1)
           and then C = Reduction_Models.Lane_Sum (Values, X, I, 2)
           and then D = Reduction_Models.Lane_Sum (Values, X, I, 3));
         pragma Loop_Invariant (abs A <= Real (I)*Step_Bound
           and then abs B <= Real (I)*Step_Bound
           and then abs C <= Real (I)*Step_Bound
           and then abs D <= Real (I)*Step_Bound);
         declare
            Previous_A : constant Lane_Value := A with Ghost => Static;
            Previous_B : constant Lane_Value := B with Ghost => Static;
            Previous_C : constant Lane_Value := C with Ghost => Static;
            Previous_D : constant Lane_Value := D with Ghost => Static;
            T0 : constant Real := Term (4*I+1);
            T1 : constant Real := Term (4*I+2);
            T2 : constant Real := Term (4*I+3);
            T3 : constant Real := Term (4*I+4);
         begin
            if I = 0 then
               A := T0; B := T1; C := T2; D := T3;
            else
               A := Add (A, T0, I); B := Add (B, T1, I);
               C := Add (C, T2, I); D := Add (D, T3, I);
            end if;
            Dense_Lane_Updated (Values, X, I, 0, Previous_A, T0, A);
            Dense_Lane_Updated (Values, X, I, 1, Previous_B, T1, B);
            Dense_Lane_Updated (Values, X, I, 2, Previous_C, T2, C);
            Dense_Lane_Updated (Values, X, I, 3, Previous_D, T3, D);
         end;
      end loop;
      S := Combine (A, B, C, D);
      Reduction_Models.Unfold_Dot (Values, X);
      --  Dense groups the remainder before adding it to the lane sum.
      case Count-Offset is
         when 3 => return S + ((Term (Offset+1)+Term (Offset+2))+Term (Offset+3));
         when 2 => return S + (Term (Offset+1)+Term (Offset+2));
         when 1 => return S + Term (Offset+1);
         when others => return S;
      end case;
   end Dense_Row;
end MJ.Constraint_Solvers.Jacobians;

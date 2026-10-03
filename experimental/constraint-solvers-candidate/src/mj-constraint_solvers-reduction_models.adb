package body MJ.Constraint_Solvers.Reduction_Models with SPARK_Mode is
   --  A proved unfolding step; the null body must establish the recurrence.
   procedure Unfold_Lane (A, B : Vector; Count : Block_Count; Lane : Lane_Number) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Lane_Sum);
   begin
      null;
   end Unfold_Lane;

   procedure Unfold_Dot (A, B : Vector) is
   begin
      null;
   end Unfold_Dot;

   procedure Zero_Lane (A, B : Vector; Lane : Lane_Number) with
     Ghost => Static, Global => null,
     Pre => A'First = 1 and then A'Length <= Max_Rows
       and then B'First = 1 and then B'Last = A'Last
       and then (for all X of A => X in Operand) and then (for all X of B => X in Operand),
     Post => Lane_Sum (A, B, 0, Lane) = 0.0
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Lane_Sum);
   begin
      null;
   end Zero_Lane;

   procedure Equal_Lanes (A, B, C, D : Vector; Count : Block_Count; Lane : Lane_Number) with
     Ghost => Static, Global => null,
     Pre => A'First = 1 and then A'Length <= Max_Rows
       and then B'First = 1 and then C'First = 1 and then D'First = 1
       and then B'Last = A'Last and then C'Last = A'Last and then D'Last = A'Last
       and then (for all X of A => X in Operand) and then (for all X of B => X in Operand)
       and then (for all X of C => X in Operand) and then (for all X of D => X in Operand)
       and then A = C and then B = D and then Count <= A'Length / 4,
     Post => Lane_Sum (A, B, Count, Lane) = Lane_Sum (C, D, Count, Lane),
     Subprogram_Variant => (Decreases => Count)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Add);
   begin
      if Count = 0 then
         Zero_Lane (A, B, Lane);
         Zero_Lane (C, D, Lane);
      else
         Equal_Lanes (A, B, C, D, Count - 1, Lane);
         Unfold_Lane (A, B, Count - 1, Lane);
         Unfold_Lane (C, D, Count - 1, Lane);
         pragma Assert (A (1 + (4 * (Count - 1) + Lane)) = C (1 + (4 * (Count - 1) + Lane)));
         pragma Assert (B (1 + (4 * (Count - 1) + Lane)) = D (1 + (4 * (Count - 1) + Lane)));
      end if;
   end Equal_Lanes;

   procedure Equal_Combinations
     (A0, A1, A2, A3, B0, B1, B2, B3 : Lane_Real; Tail_A, Tail_B : Tail_Real) with
     Ghost => Static, Global => null,
     Pre => A0 = B0 and then A1 = B1 and then A2 = B2 and then A3 = B3 and then Tail_A = Tail_B,
     Post => Combine_Lanes (A0, A1, A2, A3, Tail_A) = Combine_Lanes (B0, B1, B2, B3, Tail_B)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Combine_Lanes);
   begin
      null;
   end Equal_Combinations;

   procedure Equal_Dots (A, B, C, D : Vector) is
   begin
      Unfold_Dot (A, B);
      Unfold_Dot (C, D);
      for Lane in Lane_Number loop
         Equal_Lanes (A, B, C, D, A'Length / 4, Lane);
         pragma Loop_Invariant (for all K in 0 .. Lane =>
           Lane_Sum (A, B, A'Length / 4, K) = Lane_Sum (C, D, C'Length / 4, K));
      end loop;
      pragma Assert (Tail_Sum (A, B) = Tail_Sum (C, D));
      Equal_Combinations
        (Lane_Sum (A, B, A'Length / 4, 0), Lane_Sum (A, B, A'Length / 4, 1),
         Lane_Sum (A, B, A'Length / 4, 2), Lane_Sum (A, B, A'Length / 4, 3),
         Lane_Sum (C, D, C'Length / 4, 0), Lane_Sum (C, D, C'Length / 4, 1),
         Lane_Sum (C, D, C'Length / 4, 2), Lane_Sum (C, D, C'Length / 4, 3),
         Tail_Sum (A, B), Tail_Sum (C, D));
   end Equal_Dots;
end MJ.Constraint_Solvers.Reduction_Models;

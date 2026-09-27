package body MJ.Solver_Reductions with SPARK_Mode is
   function Product (P : AR.Pattern; Row, Offset : Natural;
                     Factor, Values : Real_Array) return Product_Real is
     (Factor (AR.Start (P, Row) + Offset)
      * Values ((if AR.Length (P, Row) = Row + 1 then Offset else AR.Column (P, Row, Offset))));

   function Accumulate (Acc : Lane_Real; Term : Product_Real; Count : Block_Count)
     return Lane_Real is (Acc + Term);

   function Merge_Values (R0, R1, R2, R3 : Lane_Real) return Merged_Real is
     ((R0 + R2) + (R1 + R3));
   function Add_Tail (Acc : Reduction_Real; Term : Product_Real; Count : Lane_Number)
     return Reduction_Real is (Acc + Term);

   procedure Dot_Blocks
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
      R0, R1, R2, R3 : out Lane_Real; Rejected : out Natural)
   is
      N : constant Natural := AR.Length (P, Row) - 1;
      Blocks : constant Natural := N / 4;
      T0, T1, T2, T3 : Product_Real;
   begin
      R0 := 0.0; R1 := 0.0; R2 := 0.0; R3 := 0.0;
      Rejected := 0;
      pragma Assert (Static => Row < AR.Size (P));
      pragma Assert (Static => N <= AR.Max_Dofs - 1);
      pragma Assert (Static => Work_Array (Factor));
      pragma Assert (Static => Work_Array (Values));
      pragma Assert (Static => Rejections (P, Row, Factor, Values, 0) = 0);
      if Blocks > 0 then
         Initialize_Lanes (P, Row, Factor, Values);
         R0 := Product (P, Row, 0, Factor, Values);
         R1 := Product (P, Row, 1, Factor, Values);
         R2 := Product (P, Row, 2, Factor, Values);
         R3 := Product (P, Row, 3, Factor, Values);
         Rejected := Boolean'Pos (abs R0 > Fast_Product_Limit)
           + Boolean'Pos (abs R1 > Fast_Product_Limit)
           + Boolean'Pos (abs R2 > Fast_Product_Limit)
           + Boolean'Pos (abs R3 > Fast_Product_Limit);
         Prove_Initial_Rejections (P, Row, Factor, Values, Rejected);
         pragma Assert (Static => R0 = Lane_Sum (P, Row, Factor, Values, 1, 0));
         pragma Assert (Static => R1 = Lane_Sum (P, Row, Factor, Values, 1, 1));
         pragma Assert (Static => R2 = Lane_Sum (P, Row, Factor, Values, 1, 2));
         pragma Assert (Static => R3 = Lane_Sum (P, Row, Factor, Values, 1, 3));
      end if;
      for B in 1 .. Blocks - 1 loop
         pragma Assert (Static => R0 = Lane_Sum (P, Row, Factor, Values, B, 0));
         pragma Assert (Static => R1 = Lane_Sum (P, Row, Factor, Values, B, 1));
         pragma Assert (Static => R2 = Lane_Sum (P, Row, Factor, Values, B, 2));
         pragma Assert (Static => R3 = Lane_Sum (P, Row, Factor, Values, B, 3));
         Unfold_Rejection_Four (P, Row, Factor, Values, 4 * B);
         T0 := Product (P, Row, 4 * B, Factor, Values);
         T1 := Product (P, Row, 4 * B + 1, Factor, Values);
         T2 := Product (P, Row, 4 * B + 2, Factor, Values);
         T3 := Product (P, Row, 4 * B + 3, Factor, Values);
         R0 := Advance_Lane (P, Row, Factor, Values, B, 0, R0, T0);
         R1 := Advance_Lane (P, Row, Factor, Values, B, 1, R1, T1);
         R2 := Advance_Lane (P, Row, Factor, Values, B, 2, R2, T2);
         R3 := Advance_Lane (P, Row, Factor, Values, B, 3, R3, T3);
         Rejected := Rejected + Boolean'Pos (abs T0 > Fast_Product_Limit)
           + Boolean'Pos (abs T1 > Fast_Product_Limit)
           + Boolean'Pos (abs T2 > Fast_Product_Limit)
           + Boolean'Pos (abs T3 > Fast_Product_Limit);
         pragma Loop_Invariant (Static => Valid (P, Row, Factor, Values));
         pragma Loop_Invariant (Static => Blocks <= AR.Max_Dofs / 4);
         pragma Loop_Invariant (Static => Rejected <= 4 * (B + 1));
         pragma Loop_Invariant (Static => Rejected = Rejections (P, Row, Factor, Values, 4 * (B + 1)));
         pragma Loop_Invariant (Static => R0 = Lane_Sum (P, Row, Factor, Values, B + 1, 0));
         pragma Loop_Invariant (Static => R1 = Lane_Sum (P, Row, Factor, Values, B + 1, 1));
         pragma Loop_Invariant (Static => R2 = Lane_Sum (P, Row, Factor, Values, B + 1, 2));
         pragma Loop_Invariant (Static => R3 = Lane_Sum (P, Row, Factor, Values, B + 1, 3));
      end loop;
      pragma Assert (Static => R0 = Lane_Sum (P, Row, Factor, Values, Blocks, 0));
      pragma Assert (Static => R1 = Lane_Sum (P, Row, Factor, Values, Blocks, 1));
      pragma Assert (Static => R2 = Lane_Sum (P, Row, Factor, Values, Blocks, 2));
      pragma Assert (Static => R3 = Lane_Sum (P, Row, Factor, Values, Blocks, 3));
      pragma Assert (Static => Rejected = Rejections (P, Row, Factor, Values, 4 * Blocks));
      pragma Assert_And_Cut (Static => Valid (P, Row, Factor, Values)
        and then N = AR.Length (P, Row) - 1 and then Blocks = N / 4 and then 4 * Blocks <= N
        and then R0 = Lane_Sum (P, Row, Factor, Values, Blocks, 0)
        and then R1 = Lane_Sum (P, Row, Factor, Values, Blocks, 1)
        and then R2 = Lane_Sum (P, Row, Factor, Values, Blocks, 2)
        and then R3 = Lane_Sum (P, Row, Factor, Values, Blocks, 3)
        and then Rejected <= 4 * Blocks
        and then Rejected = Rejections (P, Row, Factor, Values, 4 * Blocks));
      Prove_Rejections_Prefix (P, Row, Factor, Values, 4 * Blocks);
   end Dot_Blocks;

   procedure Dot_Four (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                       Sum : out Reduction_Real; Fast : out Boolean)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Lane_Sum);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Rejections);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Tail_Sum);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Merged_Sum);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Fast_Product_Prefix);
      N : constant Natural := AR.Length (P, Row) - 1;
      Blocks : constant Natural := N / 4;
      R0, R1, R2, R3 : Lane_Real;
      T0, T1, T2 : Product_Real;
      Rejected : Natural;
   begin
      Dot_Blocks (P, Row, Factor, Values, R0, R1, R2, R3, Rejected);
      Sum := Merge_Values (R0, R1, R2, R3);
      pragma Assert (Static => abs Sum <= 5.0e125);
      pragma Assert (Static => Sum = Merged_Sum (P, Row, Factor, Values));
      Tail_Base (P, Row, Factor, Values);
      if N mod 4 >= 1 then
         Unfold_Tail (P, Row, Factor, Values, 0);
         Unfold_Rejection_One (P, Row, Factor, Values, 4 * Blocks);
         T0 := Product (P, Row, 4 * Blocks, Factor, Values);
         Sum := Add_Tail (Sum, T0, 0);
         pragma Assert (Static => Sum = Tail_Sum (P, Row, Factor, Values, 1));
         Rejected := Rejected + Boolean'Pos (abs T0 > Fast_Product_Limit);
      end if;
      pragma Assert_And_Cut (Static => Valid (P, Row, Factor, Values)
        and then N = AR.Length (P, Row) - 1 and then Blocks = N / 4
        and then Sum = Tail_Sum (P, Row, Factor, Values, (if N mod 4 >= 1 then 1 else 0))
        and then Rejected = Rejections (P, Row, Factor, Values, 4 * Blocks + (if N mod 4 >= 1 then 1 else 0))
        and then Rejected <= 4 * Blocks + (if N mod 4 >= 1 then 1 else 0));
      if N mod 4 >= 2 then
         Unfold_Tail (P, Row, Factor, Values, 1);
         Unfold_Rejection_One (P, Row, Factor, Values, 4 * Blocks + 1);
         T1 := Product (P, Row, 4 * Blocks + 1, Factor, Values);
         Sum := Add_Tail (Sum, T1, 1);
         pragma Assert (Static => Sum = Tail_Sum (P, Row, Factor, Values, 2));
         Rejected := Rejected + Boolean'Pos (abs T1 > Fast_Product_Limit);
      end if;
      pragma Assert_And_Cut (Static => Valid (P, Row, Factor, Values)
        and then N = AR.Length (P, Row) - 1 and then Blocks = N / 4
        and then Sum = Tail_Sum (P, Row, Factor, Values, (if N mod 4 >= 2 then 2 else N mod 4))
        and then Rejected = Rejections (P, Row, Factor, Values, 4 * Blocks + (if N mod 4 >= 2 then 2 else N mod 4))
        and then Rejected <= 4 * Blocks + (if N mod 4 >= 2 then 2 else N mod 4));
      if N mod 4 >= 3 then
         Unfold_Tail (P, Row, Factor, Values, 2);
         Unfold_Rejection_One (P, Row, Factor, Values, 4 * Blocks + 2);
         T2 := Product (P, Row, 4 * Blocks + 2, Factor, Values);
         Sum := Add_Tail (Sum, T2, 2);
         pragma Assert (Static => Sum = Tail_Sum (P, Row, Factor, Values, 3));
         Rejected := Rejected + Boolean'Pos (abs T2 > Fast_Product_Limit);
      end if;
      pragma Assert_And_Cut (Static => Valid (P, Row, Factor, Values)
        and then N = AR.Length (P, Row) - 1
        and then Sum = Tail_Sum (P, Row, Factor, Values, N mod 4)
        and then Rejected = Rejections (P, Row, Factor, Values, N));
      Prove_Rejections_Prefix (P, Row, Factor, Values, N);
      Fast := Rejected = 0;
   end Dot_Four;

   procedure Unfold_Rejection_One (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                   Count : Term_Count) is
   begin
      null;
   end Unfold_Rejection_One;

   procedure Unfold_Rejection_Four (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                    Count : Term_Count) is
   begin
      Unfold_Rejection_One (P, Row, Factor, Values, Count);
      Unfold_Rejection_One (P, Row, Factor, Values, Count + 1);
      Unfold_Rejection_One (P, Row, Factor, Values, Count + 2);
      Unfold_Rejection_One (P, Row, Factor, Values, Count + 3);
   end Unfold_Rejection_Four;

   procedure Prove_Rejections_Prefix (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                     Count : Term_Count) is
   begin
      if Count > 0 then
         Prove_Rejections_Prefix (P, Row, Factor, Values, Count - 1);
         Unfold_Rejection_One (P, Row, Factor, Values, Count - 1);
         Unfold_Fast_One (P, Row, Factor, Values, Count - 1);
      end if;
   end Prove_Rejections_Prefix;

   procedure Prove_Initial_Rejections
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array; Rejected : Natural) is
   begin
      Unfold_Rejection_Four (P, Row, Factor, Values, 0);
      pragma Assert (Rejections (P, Row, Factor, Values, 0) = 0);
   end Prove_Initial_Rejections;

   procedure Unfold_Tail (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                          Count : Lane_Number) is
   begin
      null;
   end Unfold_Tail;

   procedure Tail_Base (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array) is
   begin
      null;
   end Tail_Base;

   procedure Unfold_Lane (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                          Blocks : Block_Count; Lane : Lane_Number) is
   begin
      null;
   end Unfold_Lane;

   procedure Initialize_Lanes (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array) is
   begin
      null;
   end Initialize_Lanes;

   function Advance_Lane
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
      Blocks : Block_Count; Lane : Lane_Number; Acc : Lane_Real; Term : Product_Real)
      return Lane_Real is
   begin
      Unfold_Lane (P, Row, Factor, Values, Blocks, Lane);
      return Accumulate (Acc, Term, Blocks);
   end Advance_Lane;

   procedure Dot_Ordered (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                          Sum : out Work_Real; Ok : out Boolean)
   is
      N : constant Natural := AR.Length (P, Row) - 1;
      Next : Reduction_Real;
   begin
      Sum := 0.0;
      Ok := False;
      for A in 0 .. N - 1 loop
         pragma Assert (Static => Sum = Ordered_Sum (P, Row, Factor, Values, A));
         Unfold_Ordered (P, Row, Factor, Values, A);
         Next := Sum + Product (P, Row, A, Factor, Values);
         pragma Assert (Static => Next = Ordered_Sum (P, Row, Factor, Values, A + 1));
         if Next not in Work_Real then
            pragma Assert (Static => not Ordered_Accepted (P, Row, Factor, Values));
            return;
         end if;
         Sum := Next;
         Extend_Ordered_Prefix (P, Row, Factor, Values, A);
         pragma Loop_Invariant (Static => Valid (P, Row, Factor, Values));
         pragma Loop_Invariant (Static => N <= AR.Max_Dofs - 1);
         pragma Loop_Invariant (Static => Sum = Ordered_Sum (P, Row, Factor, Values, A + 1));
         pragma Loop_Invariant (Static => (for all K in 0 .. A + 1 =>
           Ordered_Sum (P, Row, Factor, Values, K) in Work_Real));
      end loop;
      Ok := True;
   end Dot_Ordered;

   procedure Unfold_Fast_Four (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                              Count : Term_Count) is
   begin
      null;
   end Unfold_Fast_Four;

   procedure Unfold_Fast_One (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                             Count : Term_Count) is
   begin
      null;
   end Unfold_Fast_One;

   procedure Extend_Ordered_Prefix (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                    Count : Term_Count) is
   begin
      null;
   end Extend_Ordered_Prefix;

   procedure Unfold_Ordered (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                             Count : Term_Count) is
   begin
      null;
   end Unfold_Ordered;

   function Fast_Prefix (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                         Count : Term_Count) return Reduction_Real
   is
      Previous : Reduction_Real;
   begin
      if Count = 0 then return 0.0; end if;
      Previous := Fast_Prefix (P, Row, Factor, Values, Count - 1);
      Unfold_Ordered (P, Row, Factor, Values, Count - 1);
      return Fast_Add (Previous, Product (P, Row, Count - 1, Factor, Values), Count - 1);
   end Fast_Prefix;

   procedure Prove_Fast_Domain
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array; Previous : Work_Real)
   is
      Prefix : Reduction_Real;
      N : constant Natural := AR.Length (P, Row) - 1;
   begin
      for K in 0 .. N loop
         Prefix := Fast_Prefix (P, Row, Factor, Values, K);
         pragma Assert (Prefix in Work_Real);
         pragma Loop_Invariant (for all J in 0 .. K => Ordered_Sum (P, Row, Factor, Values, J) in Work_Real);
      end loop;
      Prefix := Fast_Prefix (P, Row, Factor, Values, N);
      pragma Assert (Previous - Prefix in Work_Real);
   end Prove_Fast_Domain;

   procedure Prove_Two_Terms (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array) is
   begin
      pragma Assert (Merged_Sum (P, Row, Factor, Values) = 0.0);
      pragma Assert (Four_Sum (P, Row, Factor, Values) = Tail_Sum (P, Row, Factor, Values, 2));
      pragma Assert (Tail_Sum (P, Row, Factor, Values, 2)
        = (Merged_Sum (P, Row, Factor, Values) + Product (P, Row, 0, Factor, Values))
          + Product (P, Row, 1, Factor, Values));
   end Prove_Two_Terms;

   procedure Prove_Small_Row
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array; Previous : Work_Real)
   is
      N : constant Natural := AR.Length (P, Row) - 1;
   begin
      pragma Assert (N in 0 .. 3);
      pragma Assert (N / 4 = 0);
      pragma Assert (Lane_Sum (P, Row, Factor, Values, 0, 0) = 0.0);
      pragma Assert (Lane_Sum (P, Row, Factor, Values, 0, 1) = 0.0);
      pragma Assert (Lane_Sum (P, Row, Factor, Values, 0, 2) = 0.0);
      pragma Assert (Lane_Sum (P, Row, Factor, Values, 0, 3) = 0.0);
      pragma Assert (Merged_Sum (P, Row, Factor, Values) = 0.0);
      if N >= 1 then Unfold_Ordered (P, Row, Factor, Values, 0); end if;
      if N >= 2 then Unfold_Ordered (P, Row, Factor, Values, 1); end if;
      if N >= 3 then Unfold_Ordered (P, Row, Factor, Values, 2); end if;
      case N is
         when 0 =>
            pragma Assert (Four_Sum (P, Row, Factor, Values) = 0.0);
            pragma Assert (Ordered_Sum (P, Row, Factor, Values, N) = 0.0);
         when 1 =>
            pragma Assert (Four_Sum (P, Row, Factor, Values)
              = 0.0 + Product (P, Row, 0, Factor, Values));
            pragma Assert (Ordered_Sum (P, Row, Factor, Values, N)
              = 0.0 + Product (P, Row, 0, Factor, Values));
         when 2 =>
            Prove_Two_Terms (P, Row, Factor, Values);
            pragma Assert (Four_Sum (P, Row, Factor, Values)
              = (0.0 + Product (P, Row, 0, Factor, Values)) + Product (P, Row, 1, Factor, Values));
            pragma Assert (Ordered_Sum (P, Row, Factor, Values, N)
              = (0.0 + Product (P, Row, 0, Factor, Values)) + Product (P, Row, 1, Factor, Values));
         when others =>
            pragma Assert (Four_Sum (P, Row, Factor, Values)
              = ((0.0 + Product (P, Row, 0, Factor, Values)) + Product (P, Row, 1, Factor, Values))
                + Product (P, Row, 2, Factor, Values));
            pragma Assert (Ordered_Sum (P, Row, Factor, Values, N)
              = ((0.0 + Product (P, Row, 0, Factor, Values)) + Product (P, Row, 1, Factor, Values))
                + Product (P, Row, 2, Factor, Values));
      end case;
      pragma Assert (Four_Sum (P, Row, Factor, Values) = Ordered_Sum (P, Row, Factor, Values, N));
      if abs Previous <= Fast_Previous_Limit and then Fast_Products (P, Row, Factor, Values) then
         Prove_Fast_Domain (P, Row, Factor, Values, Previous);
      end if;
   end Prove_Small_Row;

   procedure Forward_Value
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
      Previous : Work_Real; Value : out Work_Real; Ok : out Boolean)
   is
      Wide : Reduction_Real;
      Ordered : Work_Real;
      Fast, Accepted : Boolean;
   begin
      Value := 0.0;
      Ok := False;
      if AR.Length (P, Row) <= 4 then
         --  C has no vector block here. Keep its scalar order, and avoid
         --  preparing four lanes or checking a SIMD domain for short rows.
         Prove_Small_Row (P, Row, Factor, Values, Previous);
         if AR.Length (P, Row) = 1 then
            Value := Previous;
            Ok := True;
            pragma Assert (Static => Four_Sum (P, Row, Factor, Values) = 0.0);
            pragma Assert (Static => Value = Previous - Four_Sum (P, Row, Factor, Values));
            return;
         end if;
         Dot_Ordered (P, Row, Factor, Values, Ordered, Accepted);
         if not Accepted or else Previous - Ordered not in Work_Real then return; end if;
         Value := Previous - Ordered;
         Ok := True;
         pragma Assert (Static => Value = Previous - Four_Sum (P, Row, Factor, Values));
         return;
      end if;
      Dot_Four (P, Row, Factor, Values, Wide, Fast);
      if abs Previous <= Fast_Previous_Limit and then Fast
        and then Previous - Wide in Work_Real
      then
         Prove_Fast_Domain (P, Row, Factor, Values, Previous);
         Value := Previous - Wide;
      else
         Dot_Ordered (P, Row, Factor, Values, Ordered, Accepted);
         if not Accepted or else Previous - Ordered not in Work_Real then return; end if;
         Value := Previous - Ordered;
      end if;
      Ok := True;
   end Forward_Value;
end MJ.Solver_Reductions;

with MJ.Types; use MJ.Types;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;
with MJ.Ancestor_Rows;

--  Four independent accumulators, C/AVX lane merge, then an ordered tail.
--  All wider intermediate values remain finite. A conservative fast domain
--  keeps every prefix of the former ordered algorithm inside Work_Real;
--  outside it the original ordered checks and result are retained.
package MJ.Solver_Reductions with SPARK_Mode is
   package AR renames MJ.Ancestor_Rows;
   subtype Lane_Number is Natural range 0 .. 3;
   subtype Term_Count is Natural range 0 .. AR.Max_Dofs;
   subtype Block_Count is Natural range 0 .. AR.Max_Dofs / 4;
   subtype Product_Real is Real range -1.0e121 .. 1.0e121;
   subtype Lane_Real is Real range -1.0e125 .. 1.0e125;
   subtype Merged_Real is Real range -4.5e125 .. 4.5e125;
   subtype Reduction_Real is Real range -1.0e126 .. 1.0e126;
   Step_Bound : constant Real := 2.0 ** 408;
   Fast_Product_Limit : constant Real := 2.0 ** 176;
   Fast_Previous_Limit : constant Real := 2.0 ** 196;

   function Valid (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array)
     return Boolean is
     (Row < AR.Size (P) and then Factor'First = 0
      and then Factor'Last = AR.Count (P) - 1
      and then Values'First = 0 and then Values'Last = AR.Size (P) - 1
      and then Work_Array (Factor) and then Work_Array (Values));

   function Product (P : AR.Pattern; Row, Offset : Natural;
                     Factor, Values : Real_Array) return Product_Real with
     Global => null,
     Pre => (Static => Valid (P, Row, Factor, Values) and then Offset < AR.Length (P, Row) - 1),
     Post => Product'Result = Factor (AR.Start (P, Row) + Offset)
       * Values (AR.Column (P, Row, Offset));
   pragma Inline (Product);

   function Accumulate (Acc : Lane_Real; Term : Product_Real; Count : Block_Count)
     return Lane_Real with Global => null,
     Pre => (Static => Count < AR.Max_Dofs / 4
       and then abs Acc <= Real (Count) * Step_Bound),
     Post => (Static => Accumulate'Result = Acc + Term
       and then abs Accumulate'Result <= Real (Count + 1) * Step_Bound);
   pragma Inline (Accumulate);

   function Merge_Values (R0, R1, R2, R3 : Lane_Real) return Merged_Real with
     Global => null, Post => Merge_Values'Result = (R0 + R2) + (R1 + R3);
   pragma Inline (Merge_Values);

   function Add_Tail (Acc : Reduction_Real; Term : Product_Real; Count : Lane_Number)
     return Reduction_Real with Global => null,
     Pre => (Static => Count <= 2 and then abs Acc <= Real (5 + Count) * 1.0e125),
     Post => (Static => Add_Tail'Result = Acc + Term
       and then abs Add_Tail'Result <= Real (6 + Count) * 1.0e125);
   pragma Inline (Add_Tail);

   function Model_Add (Acc : Reduction_Real; Term : Product_Real; Count : Term_Count)
     return Reduction_Real is (Acc + Term) with
     Ghost => Static, Global => null,
     Pre => Count < AR.Max_Dofs and then abs Acc <= Real (Count) * Step_Bound,
     Post => abs Model_Add'Result <= Real (Count + 1) * Step_Bound;

   function Lane_Sum (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                      Blocks : Block_Count; Lane : Lane_Number) return Lane_Real is
     (if Blocks = 0 then 0.0
      elsif Blocks = 1 then Product (P, Row, Lane, Factor, Values)
      else Model_Add (Lane_Sum (P, Row, Factor, Values, Blocks - 1, Lane),
        Product (P, Row, 4 * (Blocks - 1) + Lane, Factor, Values), Blocks - 1)) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Blocks <= (AR.Length (P, Row) - 1) / 4,
     Post => abs Lane_Sum'Result <= Real (Blocks) * Step_Bound,
     Subprogram_Variant => (Decreases => Blocks);

   procedure Unfold_Lane (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                          Blocks : Block_Count; Lane : Lane_Number) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values)
       and then Blocks in 1 .. (AR.Length (P, Row) - 1) / 4 - 1,
     Post => Lane_Sum (P, Row, Factor, Values, Blocks + 1, Lane)
       = Lane_Sum (P, Row, Factor, Values, Blocks, Lane)
         + Product (P, Row, 4 * Blocks + Lane, Factor, Values);

   procedure Initialize_Lanes (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then AR.Length (P, Row) >= 5,
     Post => (for all Lane in Lane_Number => Lane_Sum (P, Row, Factor, Values, 1, Lane)
       = Product (P, Row, Lane, Factor, Values));

   function Advance_Lane
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
      Blocks : Block_Count; Lane : Lane_Number; Acc : Lane_Real; Term : Product_Real)
      return Lane_Real with Global => null,
     Pre => (Static => Valid (P, Row, Factor, Values)
       and then Blocks in 1 .. (AR.Length (P, Row) - 1) / 4 - 1
       and then Acc = Lane_Sum (P, Row, Factor, Values, Blocks, Lane)
       and then Term = Product (P, Row, 4 * Blocks + Lane, Factor, Values)),
     Post => (Static => Advance_Lane'Result = Acc + Term
       and then Advance_Lane'Result = Lane_Sum (P, Row, Factor, Values, Blocks + 1, Lane));
   pragma Inline (Advance_Lane);

   function Merged_Sum (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array)
     return Merged_Real is
     ((Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 0)
       + Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 2))
      + (Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 1)
         + Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 3))) with
     Ghost => Static, Global => null, Pre => Valid (P, Row, Factor, Values),
     Post => Merged_Sum'Result = Merge_Values
       (Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 0),
        Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 1),
        Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 2),
        Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 3));

   function Tail_Sum (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                      Tail : Lane_Number) return Reduction_Real is
     (case Tail is
      when 0 => Merged_Sum (P, Row, Factor, Values),
      when 1 => Merged_Sum (P, Row, Factor, Values)
        + Product (P, Row, 4 * ((AR.Length (P, Row) - 1) / 4), Factor, Values),
      when 2 => (Merged_Sum (P, Row, Factor, Values)
        + Product (P, Row, 4 * ((AR.Length (P, Row) - 1) / 4), Factor, Values))
        + Product (P, Row, 4 * ((AR.Length (P, Row) - 1) / 4) + 1, Factor, Values),
      when 3 => ((Merged_Sum (P, Row, Factor, Values)
        + Product (P, Row, 4 * ((AR.Length (P, Row) - 1) / 4), Factor, Values))
        + Product (P, Row, 4 * ((AR.Length (P, Row) - 1) / 4) + 1, Factor, Values))
        + Product (P, Row, 4 * ((AR.Length (P, Row) - 1) / 4) + 2, Factor, Values)) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Tail <= (AR.Length (P, Row) - 1) mod 4,
     Post => abs Tail_Sum'Result <= 5.0e125;

   function Four_Sum (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array)
     return Reduction_Real is (Tail_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) mod 4)) with
     Ghost => Static, Global => null, Pre => Valid (P, Row, Factor, Values);

   function Ordered_Sum (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                         Count : Term_Count) return Reduction_Real is
     (if Count = 0 then 0.0 else Model_Add
       (Ordered_Sum (P, Row, Factor, Values, Count - 1),
        Product (P, Row, Count - 1, Factor, Values), Count - 1)) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count < AR.Length (P, Row),
     Post => abs Ordered_Sum'Result <= Real (Count) * Step_Bound,
     Subprogram_Variant => (Decreases => Count);

   function Fast_Product_Prefix (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                 Count : Term_Count) return Boolean is
     (for all A in 0 .. Count - 1 =>
        abs Product (P, Row, A, Factor, Values) <= Fast_Product_Limit) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count < AR.Length (P, Row);
   function Fast_Products (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array)
     return Boolean is
     (Fast_Product_Prefix (P, Row, Factor, Values, AR.Length (P, Row) - 1)) with
     Ghost => Static, Global => null, Pre => Valid (P, Row, Factor, Values);

   function Rejections (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                        Count : Term_Count) return Term_Count is
     (if Count = 0 then 0 else Rejections (P, Row, Factor, Values, Count - 1)
       + Boolean'Pos (abs Product (P, Row, Count - 1, Factor, Values) > Fast_Product_Limit)) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count < AR.Length (P, Row),
     Post => Rejections'Result <= Count,
     Subprogram_Variant => (Decreases => Count);

   procedure Unfold_Rejection_One (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                   Count : Term_Count) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count + 1 < AR.Length (P, Row),
     Post => Rejections (P, Row, Factor, Values, Count + 1) =
       Rejections (P, Row, Factor, Values, Count)
       + Boolean'Pos (abs Product (P, Row, Count, Factor, Values) > Fast_Product_Limit);
   procedure Unfold_Rejection_Four (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                    Count : Term_Count) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count + 4 < AR.Length (P, Row),
     Post => Rejections (P, Row, Factor, Values, Count + 4) =
       Rejections (P, Row, Factor, Values, Count)
       + Boolean'Pos (abs Product (P, Row, Count, Factor, Values) > Fast_Product_Limit)
       + Boolean'Pos (abs Product (P, Row, Count + 1, Factor, Values) > Fast_Product_Limit)
       + Boolean'Pos (abs Product (P, Row, Count + 2, Factor, Values) > Fast_Product_Limit)
       + Boolean'Pos (abs Product (P, Row, Count + 3, Factor, Values) > Fast_Product_Limit);
   procedure Prove_Rejections_Prefix (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                     Count : Term_Count) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count < AR.Length (P, Row),
     Post => (Rejections (P, Row, Factor, Values, Count) = 0)
       = Fast_Product_Prefix (P, Row, Factor, Values, Count),
     Subprogram_Variant => (Decreases => Count);
   procedure Prove_Initial_Rejections
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array; Rejected : Natural) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then AR.Length (P, Row) >= 5
       and then Rejected =
         Boolean'Pos (abs Product (P, Row, 0, Factor, Values) > Fast_Product_Limit)
         + Boolean'Pos (abs Product (P, Row, 1, Factor, Values) > Fast_Product_Limit)
         + Boolean'Pos (abs Product (P, Row, 2, Factor, Values) > Fast_Product_Limit)
         + Boolean'Pos (abs Product (P, Row, 3, Factor, Values) > Fast_Product_Limit),
     Post => Rejected = Rejections (P, Row, Factor, Values, 4);

   procedure Unfold_Tail (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                          Count : Lane_Number) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count < (AR.Length (P, Row) - 1) mod 4,
     Post => Tail_Sum (P, Row, Factor, Values, Count + 1)
       = Tail_Sum (P, Row, Factor, Values, Count)
         + Product (P, Row, 4 * ((AR.Length (P, Row) - 1) / 4) + Count, Factor, Values);
   procedure Tail_Base (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array) with
     Ghost => Static, Global => null, Pre => Valid (P, Row, Factor, Values),
     Post => Tail_Sum (P, Row, Factor, Values, 0) = Merged_Sum (P, Row, Factor, Values);

   procedure Unfold_Fast_Four (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                              Count : Term_Count) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count + 4 < AR.Length (P, Row),
     Post => Fast_Product_Prefix (P, Row, Factor, Values, Count + 4) =
       (Fast_Product_Prefix (P, Row, Factor, Values, Count)
        and then abs Product (P, Row, Count, Factor, Values) <= Fast_Product_Limit
        and then abs Product (P, Row, Count + 1, Factor, Values) <= Fast_Product_Limit
        and then abs Product (P, Row, Count + 2, Factor, Values) <= Fast_Product_Limit
        and then abs Product (P, Row, Count + 3, Factor, Values) <= Fast_Product_Limit);
   procedure Unfold_Fast_One (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                             Count : Term_Count) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count + 1 < AR.Length (P, Row),
     Post => Fast_Product_Prefix (P, Row, Factor, Values, Count + 1) =
       (Fast_Product_Prefix (P, Row, Factor, Values, Count)
        and then abs Product (P, Row, Count, Factor, Values) <= Fast_Product_Limit);

   procedure Extend_Ordered_Prefix (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                                    Count : Term_Count) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count + 1 < AR.Length (P, Row)
       and then (for all K in 0 .. Count => Ordered_Sum (P, Row, Factor, Values, K) in Work_Real)
       and then Ordered_Sum (P, Row, Factor, Values, Count + 1) in Work_Real,
     Post => (for all K in 0 .. Count + 1 => Ordered_Sum (P, Row, Factor, Values, K) in Work_Real);

   function Ordered_Accepted (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array)
     return Boolean is
     (for all K in 0 .. AR.Length (P, Row) - 1 =>
        Ordered_Sum (P, Row, Factor, Values, K) in Work_Real) with
     Ghost => Static, Global => null, Pre => Valid (P, Row, Factor, Values);

   --  This smaller bound proves that choosing the SIMD order cannot turn an
   --  old Numeric_Limit rejection into success in the fast domain.
   Fast_Step_Bound : constant Real := 2.0 ** 178;
   function Fast_Add (Acc, Term : Real; Count : Term_Count) return Reduction_Real is
     (Acc + Term) with Ghost => Static, Global => null,
     Pre => Count < AR.Max_Dofs and then abs Acc <= Real (Count) * Fast_Step_Bound
       and then abs Term <= Fast_Product_Limit,
     Post => abs Fast_Add'Result <= Real (Count + 1) * Fast_Step_Bound;
   function Fast_Prefix (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                         Count : Term_Count) return Reduction_Real with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Fast_Products (P, Row, Factor, Values)
       and then Count < AR.Length (P, Row),
     Post => Fast_Prefix'Result = Ordered_Sum (P, Row, Factor, Values, Count)
       and then abs Fast_Prefix'Result <= Real (Count) * Fast_Step_Bound,
     Subprogram_Variant => (Decreases => Count);

   procedure Unfold_Ordered (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                             Count : Term_Count) with Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Count < AR.Length (P, Row) - 1,
     Post => Ordered_Sum (P, Row, Factor, Values, Count + 1)
       = Ordered_Sum (P, Row, Factor, Values, Count) + Product (P, Row, Count, Factor, Values);

   procedure Prove_Fast_Domain
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array; Previous : Work_Real) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then Fast_Products (P, Row, Factor, Values)
       and then abs Previous <= Fast_Previous_Limit,
     Post => Ordered_Accepted (P, Row, Factor, Values)
       and then Previous - Ordered_Sum (P, Row, Factor, Values, AR.Length (P, Row) - 1) in Work_Real;

   procedure Prove_Small_Row
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array; Previous : Work_Real) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then AR.Length (P, Row) <= 4,
     Post => Four_Sum (P, Row, Factor, Values)
       = Ordered_Sum (P, Row, Factor, Values, AR.Length (P, Row) - 1)
       and then (if abs Previous <= Fast_Previous_Limit and then Fast_Products (P, Row, Factor, Values)
         then Ordered_Accepted (P, Row, Factor, Values)
           and then Previous - Ordered_Sum (P, Row, Factor, Values, AR.Length (P, Row) - 1) in Work_Real);

   procedure Prove_Two_Terms (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array) with
     Ghost => Static, Global => null,
     Pre => Valid (P, Row, Factor, Values) and then AR.Length (P, Row) = 3,
     Post => Four_Sum (P, Row, Factor, Values)
       = (0.0 + Product (P, Row, 0, Factor, Values)) + Product (P, Row, 1, Factor, Values);

   procedure Dot_Four (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                       Sum : out Reduction_Real; Fast : out Boolean) with
     Global => null, Pre => Valid (P, Row, Factor, Values),
     Post => (Static => Sum = Four_Sum (P, Row, Factor, Values)
       and then Fast = Fast_Products (P, Row, Factor, Values));

   procedure Dot_Blocks
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
      R0, R1, R2, R3 : out Lane_Real; Rejected : out Natural) with
     Global => null, Pre => Valid (P, Row, Factor, Values),
     Post => (Static =>
       R0 = Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 0)
       and then R1 = Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 1)
       and then R2 = Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 2)
       and then R3 = Lane_Sum (P, Row, Factor, Values, (AR.Length (P, Row) - 1) / 4, 3)
       and then Rejected <= 4 * ((AR.Length (P, Row) - 1) / 4)
       and then Rejected = Rejections (P, Row, Factor, Values, 4 * ((AR.Length (P, Row) - 1) / 4))
       and then (Rejected = 0) = Fast_Product_Prefix
         (P, Row, Factor, Values, 4 * ((AR.Length (P, Row) - 1) / 4)));
   pragma Inline (Dot_Blocks);

   procedure Dot_Ordered (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
                          Sum : out Work_Real; Ok : out Boolean) with
     Global => null, Pre => Valid (P, Row, Factor, Values),
     Post => (Static => Ok = Ordered_Accepted (P, Row, Factor, Values)
       and then (if Ok then Sum = Ordered_Sum (P, Row, Factor, Values, AR.Length (P, Row) - 1)));
   pragma Inline (Dot_Ordered);

   procedure Forward_Value
     (P : AR.Pattern; Row : Natural; Factor, Values : Real_Array;
      Previous : Work_Real; Value : out Work_Real; Ok : out Boolean) with
     Global => null, Pre => Valid (P, Row, Factor, Values),
     Post => (Static =>
       (if abs Previous <= Fast_Previous_Limit and then Fast_Products (P, Row, Factor, Values)
           and then Previous - Four_Sum (P, Row, Factor, Values) in Work_Real
        then Ok and then Value = Previous - Four_Sum (P, Row, Factor, Values)
        else Ok = (Ordered_Accepted (P, Row, Factor, Values)
              and then Previous - Ordered_Sum (P, Row, Factor, Values, AR.Length (P, Row) - 1) in Work_Real)
          and then (if Ok then Value = Previous
            - Ordered_Sum (P, Row, Factor, Values, AR.Length (P, Row) - 1)))
       and then Ok = (Ordered_Accepted (P, Row, Factor, Values)
         and then Previous - Ordered_Sum (P, Row, Factor, Values, AR.Length (P, Row) - 1) in Work_Real)
       and then (if not Ok then Value = 0.0));
   pragma Inline (Forward_Value);
end MJ.Solver_Reductions;

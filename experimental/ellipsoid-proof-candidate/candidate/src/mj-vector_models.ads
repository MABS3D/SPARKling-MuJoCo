--  Proof-only floating-point recurrences. Static ghost code is never executed.
with MJ.Types; use MJ.Types;

package MJ.Vector_Models with SPARK_Mode is
   Step_Bound : constant Real := 2.0 ** 68;
   subtype Lane_Number is Natural range 0 .. 3;
   subtype Block_Count is Natural range 0 .. Max_Size / 4;
   subtype Lane_Real is Real range -1.0e29 .. 1.0e29;
   subtype Tail_Real is Real range -4.0e20 .. 4.0e20;

   function Model_Add (Acc, Term : Real; Count : Size_Type) return Real is (Acc + Term)
   with Ghost => Static, Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * Step_Bound
       and then abs Term <= 1.0e20,
     Post => Model_Add'Result = Acc + Term
       and then abs Model_Add'Result <= Real (Count + 1) * Step_Bound
       and then (if Acc >= 0.0 and then Term >= 0.0 then Model_Add'Result >= 0.0);

   function Prefix_Sum (A : Real_Array; Count : Size_Type; Absolute : Boolean) return Real is
     (if Count = 0 then 0.0
      else Prefix_Sum (A, Count - 1, Absolute)
        + (if Absolute then abs A (A'First + (Count - 1)) else A (A'First + (Count - 1))))
   with Ghost => Static, Global => null,
     Pre => A'Length <= Max_Size and then Count <= A'Length
       and then (for all X of A => X in Tier0_Real),
     Post => abs Prefix_Sum'Result <= Real (Count) * Step_Bound
       and then (if Absolute then Prefix_Sum'Result >= 0.0),
     Subprogram_Variant => (Decreases => Count);

   function Lane_Sum (A, B : Real_Array; Count : Block_Count; Lane : Lane_Number) return Lane_Real is
     (if Count = 0 then 0.0
      else Model_Add (Lane_Sum (A, B, Count - 1, Lane),
        A (A'First + (4 * (Count - 1) + Lane))
          * B (A'First + (4 * (Count - 1) + Lane)), Count - 1))
   with Ghost => Static, Global => null,
     Pre => A'Length <= Max_Size and then Count <= A'Length / 4
       and then A'First = B'First and then A'Last = B'Last
       and then (for all X of A => X in Tier0_Real)
       and then (for all X of B => X in Tier0_Real),
     Post => abs Lane_Sum'Result <= Real (Count) * Step_Bound
       and then (if A = B then Lane_Sum'Result >= 0.0),
     Subprogram_Variant => (Decreases => Count);

   procedure Unfold_Lane (A, B : Real_Array; Count : Block_Count; Lane : Lane_Number) with
     Ghost => Static, Global => null,
     Pre => A'Length <= Max_Size and then Count < A'Length / 4
       and then A'First = B'First and then A'Last = B'Last
       and then (for all X of A => X in Tier0_Real)
       and then (for all X of B => X in Tier0_Real),
     Post => Lane_Sum (A, B, Count + 1, Lane)
       = Model_Add (Lane_Sum (A, B, Count, Lane),
                    A (A'First + (4 * Count + Lane)) * B (A'First + (4 * Count + Lane)), Count);

   function Tail_Sum (A, B : Real_Array) return Tail_Real is
     (case A'Length mod 4 is
        when 3 => ((A (A'Last - 2) * B (A'Last - 2)) + (A (A'Last - 1) * B (A'Last - 1)))
                    + (A (A'Last) * B (A'Last)),
        when 2 => (A (A'Last - 1) * B (A'Last - 1)) + (A (A'Last) * B (A'Last)),
        when 1 => A (A'Last) * B (A'Last),
        when others => 0.0)
   with Ghost => Static, Global => null,
     Pre => A'Length <= Max_Size and then A'First = B'First and then A'Last = B'Last
       and then (for all X of A => X in Tier0_Real)
       and then (for all X of B => X in Tier0_Real),
     Post => Tail_Sum'Result in -4.0e20 .. 4.0e20
       and then (if A = B then Tail_Sum'Result >= 0.0);

   function Combine_Lanes (R0, R1, R2, R3 : Lane_Real; Tail : Tail_Real) return Tier1_Real is
     (((R0 + R2) + (R1 + R3)) + Tail)
   with Ghost => Static, Global => null,
     Post => (if R0 >= 0.0 and then R1 >= 0.0 and then R2 >= 0.0
              and then R3 >= 0.0 and then Tail >= 0.0 then Combine_Lanes'Result >= 0.0);

   function Normalized_Component (X : Tier0_Real; Length : Real) return Tier1_Real is
     (X * (1.0 / Length))
   with Ghost => Static, Global => null, Pre => Length >= Min_Val;

   function Dot_Value (A, B : Real_Array) return Real is
     (Combine_Lanes (Lane_Sum (A, B, A'Length / 4, 0), Lane_Sum (A, B, A'Length / 4, 1),
                     Lane_Sum (A, B, A'Length / 4, 2), Lane_Sum (A, B, A'Length / 4, 3),
                     Tail_Sum (A, B)))
   with Ghost => Static, Global => null,
     Pre => A'Length <= Max_Size and then A'First = B'First and then A'Last = B'Last
       and then (for all X of A => X in Tier0_Real)
       and then (for all X of B => X in Tier0_Real),
     Post => Dot_Value'Result in Tier1_Real
       and then (if A = B then Dot_Value'Result >= 0.0);

   procedure Unfold_Dot (A, B : Real_Array) with
     Ghost => Static, Global => null,
     Pre => A'Length <= Max_Size and then A'First = B'First and then A'Last = B'Last
       and then (for all X of A => X in Tier0_Real)
       and then (for all X of B => X in Tier0_Real),
     Post => Dot_Value (A, B)
       = Combine_Lanes
           (Lane_Sum (A, B, A'Length / 4, 0), Lane_Sum (A, B, A'Length / 4, 1),
            Lane_Sum (A, B, A'Length / 4, 2), Lane_Sum (A, B, A'Length / 4, 3), Tail_Sum (A, B));
end MJ.Vector_Models;

with MJ.Types; use MJ.Types;
with MJ.Cholesky_Steps; use MJ.Cholesky_Steps;
package MJ.Cholesky_Models with SPARK_Mode is
   subtype Dot_Count is Natural range 0 .. 11_585;
   subtype Block_Count is Natural range 0 .. Dot_Count'Last / 4;
   subtype Lane is Natural range 0 .. 3;
   subtype Lane_Real is Real range -1.0e206 .. 1.0e206;
   subtype Tail_Real is Real range -4.0e200 .. 4.0e200;
   Step_Bound : constant Real := 2.0 ** 668;
   function Valid_Dot (A, B : Real_Array; A0, B0 : Natural; Count : Dot_Count)
     return Boolean is
     (A'First = 0 and then B'First = 0
      and then A'Length <= Max_Size and then B'Length <= Max_Size
      and then A0 <= A'Length and then B0 <= B'Length
      and then Count <= A'Length - A0 and then Count <= B'Length - B0
      and then (for all I in 0 .. Count - 1 =>
        A (A0 + I) in -1.0e100 .. 1.0e100
        and then B (B0 + I) in -1.0e100 .. 1.0e100))
     with Global => null;

   function Model_Add (Acc, Term : Real; Count : Dot_Count) return Real is
     (Acc + Term) with Ghost => Static, Global => null,
     Pre => Count < Dot_Count'Last
       and then abs Acc <= Real (Count) * Step_Bound
       and then abs Term <= 1.1e200,
     Post => Model_Add'Result = Acc + Term and then abs Model_Add'Result <= Real (Count + 1) * Step_Bound;

   function Lane_Sum (A, B : Real_Array; A0, B0 : Natural;
                      Count : Block_Count; L : Lane) return Lane_Real is
     (if Count = 0 then 0.0 else
        Model_Add (Lane_Sum (A, B, A0, B0, Count - 1, L),
                   Product (A (A0 + 4 * (Count - 1) + L),
                            B (B0 + 4 * (Count - 1) + L)), Count - 1))
     with Ghost => Static, Global => null,
     Pre => Valid_Dot (A, B, A0, B0, 4 * Count),
     Post => abs Lane_Sum'Result <= Real (Count) * Step_Bound,
     Subprogram_Variant => (Decreases => Count);

   procedure Unfold_Lane (A, B : Real_Array; A0, B0 : Natural;
                         Count : Block_Count; L : Lane)
     with Ghost => Static, Global => null,
     Pre => Count < Block_Count'Last
       and then Valid_Dot (A, B, A0, B0, 4 * (Count + 1)),
     Post => Lane_Sum (A, B, A0, B0, Count + 1, L) =
       Lane_Sum (A, B, A0, B0, Count, L)
       + Product (A (A0 + 4 * Count + L), B (B0 + 4 * Count + L));

   function Tail (A, B : Real_Array; A0, B0 : Natural; Count : Dot_Count)
     return Tail_Real is
     (case Count mod 4 is
        when 3 => (Product (A (A0 + Count - 3), B (B0 + Count - 3))
                   + Product (A (A0 + Count - 2), B (B0 + Count - 2)))
                   + Product (A (A0 + Count - 1), B (B0 + Count - 1)),
        when 2 => Product (A (A0 + Count - 2), B (B0 + Count - 2))
                   + Product (A (A0 + Count - 1), B (B0 + Count - 1)),
        when 1 => Product (A (A0 + Count - 1), B (B0 + Count - 1)),
        when others => 0.0)
     with Ghost => Static, Global => null,
     Pre => Valid_Dot (A, B, A0, B0, Count),
     Post => abs Tail'Result <= 4.0e200;

   function Dot_Value (A, B : Real_Array; A0, B0 : Natural; Count : Dot_Count)
     return Real is
     (((Lane_Sum (A, B, A0, B0, Count / 4, 0)
       + Lane_Sum (A, B, A0, B0, Count / 4, 2))
       + (Lane_Sum (A, B, A0, B0, Count / 4, 1)
       + Lane_Sum (A, B, A0, B0, Count / 4, 3)))
       + Tail (A, B, A0, B0, Count))
     with Ghost => Static, Global => null,
     Pre => Valid_Dot (A, B, A0, B0, Count),
     Post => abs Dot_Value'Result <= 1.0e207;
end MJ.Cholesky_Models;

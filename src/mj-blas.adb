with Ada.Numerics.Long_Elementary_Functions;
use Ada.Numerics.Long_Elementary_Functions;

package body MJ.BLAS with SPARK_Mode is
   use MJ.Vector_Models;
   function Zero3 return Vector_3 is ([0.0, 0.0, 0.0]);
   function Zero4 return Vector_4 is ([0.0, 0.0, 0.0, 0.0]);
   function Unit4 return Vector_4 is ([1.0, 0.0, 0.0, 0.0]);
   function Copy3 (A : Vector_3) return Vector_3 is (A);
   function Copy4 (A : Vector_4) return Vector_4 is (A);
   function Equal3 (A, B : Vector_3) return Boolean is
     (for all I in A'Range => abs (A (I) - B (I)) < Min_Val);

   function Add3 (A, B : Vector_3) return Vector_3 is
     ([A (0) + B (0), A (1) + B (1), A (2) + B (2)]);

   function Sub3 (A, B : Vector_3) return Vector_3 is
     ([A (0) - B (0), A (1) - B (1), A (2) - B (2)]);

   function Scl3 (A : Vector_3; Scale : Tier0_Real) return Vector_3 is
     ([A (0) * Scale, A (1) * Scale, A (2) * Scale]);

   function Scaled_Add (X, Y, Scale : Tier0_Real) return Tier1_Real is
   begin
      return X + (Y * Scale);
   end Scaled_Add;

   function AddScl3 (A, B : Vector_3; Scale : Tier0_Real) return Vector_3 is
     ([Scaled_Add (A (0), B (0), Scale), Scaled_Add (A (1), B (1), Scale), Scaled_Add (A (2), B (2), Scale)]);

   procedure AddTo3 (R : in out Vector_3; A : Vector_3) is
   begin
      R := Add3 (R, A);
   end AddTo3;

   procedure SubFrom3 (R : in out Vector_3; A : Vector_3) is
   begin
      R := Sub3 (R, A);
   end SubFrom3;

   procedure AddToScl3 (R : in out Vector_3; A : Vector_3; Scale : Tier0_Real) is
   begin
      R := AddScl3 (R, A, Scale);
   end AddToScl3;

   function Dot3 (A, B : Vector_3) return Tier1_Real is
     (((A (0) * B (0)) + (A (1) * B (1))) + (A (2) * B (2)));

   function Det2 (A, B, C, D : Tier0_Real) return Tier1_Real is
   begin
      return (A * D) - (B * C);
   end Det2;

   function Cross3 (A, B : Vector_3) return Vector_3 is
     ([Det2 (A (1), A (2), B (1), B (2)),
       Det2 (A (2), A (0), B (2), B (0)),
       Det2 (A (0), A (1), B (0), B (1))]);

   function Norm3 (A : Vector_3) return Nonnegative_Real is
     (Sqrt (((A (0) * A (0)) + (A (1) * A (1))) + (A (2) * A (2))));

   function Norm4 (A : Vector_4) return Nonnegative_Real is
     (Sqrt ((((A (0) * A (0)) + (A (1) * A (1))) + (A (2) * A (2))) + (A (3) * A (3))));

   function Dist3 (A, B : Vector_3) return Nonnegative_Real is
     (Norm3 (Sub3 (A, B)));

   function Inverse_Length (Length : Real) return Real with
     Global => null, Pre => Length >= Min_Val,
     Post => Inverse_Length'Result in 0.0 .. 1.0e15
       and then Inverse_Length'Result = 1.0 / Length
   is
   begin
      return 1.0 / Length;
   end Inverse_Length;

   function Multiply_By_Inverse (X : Tier0_Real; Inv : Real) return Tier1_Real with
     Global => null, Pre => Inv in 0.0 .. 1.0e15,
     Post => Multiply_By_Inverse'Result = X * Inv
   is
   begin
      return X * Inv;
   end Multiply_By_Inverse;

   procedure Scale_By_Inverse (A : in out Real_Array; Inv : Real) with
     Global => null, Pre => In_Tier0 (A) and then Inv in 0.0 .. 1.0e15,
     Post => In_Tier1 (A)
       and then (for all I in A'Range => A (I) = A'Old (I) * Inv)
   is
   begin
      for I in A'Range loop
         A (I) := Multiply_By_Inverse (A (I), Inv);
         pragma Loop_Invariant
           (for all K in A'First .. I => A (K) in Tier1_Real
            and then A (K) = A'Loop_Entry (K) * Inv);
      end loop;
   end Scale_By_Inverse;

   procedure Normalize3 (A : in out Vector_3; Length : out Nonnegative_Real) is
   begin
      pragma Assert (In_Tier1 (A));
      Length := Norm3 (A);
      if Length < Min_Val then
         A := [1.0, 0.0, 0.0];
      else
         Scale_By_Inverse (A, Inverse_Length (Length));
      end if;
   end Normalize3;

   procedure Normalize4 (A : in out Vector_4; Length : out Nonnegative_Real) is
   begin
      pragma Assert (In_Tier1 (A));
      Length := Norm4 (A);
      if Length < Min_Val then
         A := [1.0, 0.0, 0.0, 0.0];
      elsif abs (Length - 1.0) > Min_Val then
         Scale_By_Inverse (A, Inverse_Length (Length));
      end if;
   end Normalize4;

   procedure Zero (R : out Real_Array) is
   begin
      R := [others => 0.0];
   end Zero;

   procedure Fill (R : out Real_Array; Value : Real) is
   begin
      R := [others => Value];
   end Fill;

   procedure Copy (R : out Real_Array; A : Real_Array) is
   begin
      R := A;
   end Copy;

   procedure Scl (R : out Real_Array; A : Real_Array; Scale : Tier0_Real) is
   begin
      for I in R'Range loop
         R (I) := A (I) * Scale;
         pragma Loop_Invariant (for all K in R'First .. I => R (K)'Initialized);
         pragma Loop_Invariant
           (for all K in R'First .. I => R (K) in Tier1_Real and then R (K) = A (K) * Scale);
      end loop;
   end Scl;

   procedure Add (R : out Real_Array; A, B : Real_Array) is
   begin
      for I in R'Range loop
         R (I) := A (I) + B (I);
         pragma Loop_Invariant (for all K in R'First .. I => R (K)'Initialized);
         pragma Loop_Invariant
           (for all K in R'First .. I => R (K) in Tier1_Real and then R (K) = A (K) + B (K));
      end loop;
   end Add;

   procedure Sub (R : out Real_Array; A, B : Real_Array) is
   begin
      for I in R'Range loop
         R (I) := A (I) - B (I);
         pragma Loop_Invariant (for all K in R'First .. I => R (K)'Initialized);
         pragma Loop_Invariant
           (for all K in R'First .. I => R (K) in Tier1_Real and then R (K) = A (K) - B (K));
      end loop;
   end Sub;

   procedure AddScl (R : out Real_Array; A, B : Real_Array; Scale : Tier0_Real) is
   begin
      for I in R'Range loop
         R (I) := Scaled_Add (A (I), B (I), Scale);
         pragma Loop_Invariant (for all K in R'First .. I => R (K)'Initialized);
         pragma Loop_Invariant
           (for all K in R'First .. I => R (K) in Tier1_Real and then R (K) = Scaled_Add (A (K), B (K), Scale));
      end loop;
   end AddScl;

   procedure AddTo (R : in out Real_Array; A : Real_Array) is
   begin
      for I in R'Range loop
         R (I) := R (I) + A (I);
         pragma Loop_Invariant
           (for all K in R'First .. I => R (K) in Tier1_Real and then R (K) = R'Loop_Entry (K) + A (K));
      end loop;
   end AddTo;

   procedure SubFrom (R : in out Real_Array; A : Real_Array) is
   begin
      for I in R'Range loop
         R (I) := R (I) - A (I);
         pragma Loop_Invariant
           (for all K in R'First .. I => R (K) in Tier1_Real and then R (K) = R'Loop_Entry (K) - A (K));
      end loop;
   end SubFrom;

   procedure AddToScl (R : in out Real_Array; A : Real_Array; Scale : Tier0_Real) is
   begin
      for I in R'Range loop
         R (I) := Scaled_Add (R (I), A (I), Scale);
         pragma Loop_Invariant
           (for all K in R'First .. I => R (K) in Tier1_Real and then R (K) = Scaled_Add (R'Loop_Entry (K), A (K), Scale));
      end loop;
   end AddToScl;

   --  A power-of-two allowance keeps count*allowance exact for all Size_Type
   --  values and leaves headroom over a Tier0 product (1e20), including rounding.
   function Accumulate (Acc, Term : Real; Count : Size_Type) return Lane_Real with
     Global => null,
     Pre => Count < Max_Size and then abs Acc <= Real (Count) * Step_Bound
       and then abs Term <= 1.0e20,
     Post => Accumulate'Result = Acc + Term
       and then abs Accumulate'Result <= Real (Count + 1) * Step_Bound
       and then (if Acc >= 0.0 and then Term >= 0.0 then Accumulate'Result >= 0.0)
   is
   begin
      return Acc + Term;
   end Accumulate;

   function Sum (A : Real_Array) return Tier1_Real is
      Acc : Real := 0.0;
   begin
      for I in A'Range loop
         Acc := Accumulate (Acc, A (I), I - A'First);
         pragma Loop_Invariant (abs Acc <= Real ((I - A'First) + 1) * Step_Bound);
         pragma Loop_Invariant (Static => Acc = Prefix_Sum (A, (I - A'First) + 1, False));
      end loop;
      return Acc;
   end Sum;

   function L1 (A : Real_Array) return Nonnegative_Real is
      Acc : Real := 0.0;
   begin
      for I in A'Range loop
         Acc := Accumulate (Acc, abs A (I), I - A'First);
         pragma Loop_Invariant (Acc in 0.0 .. Real ((I - A'First) + 1) * Step_Bound);
         pragma Loop_Invariant (Static => Acc = Prefix_Sum (A, (I - A'First) + 1, True));
      end loop;
      return Acc;
   end L1;

   function Product (X, Y : Tier0_Real) return Real with
     Global => null,
     Post => Product'Result = X * Y and then abs Product'Result <= 1.0e20
       and then (if X = Y then Product'Result >= 0.0)
   is
   begin
      return X * Y;
   end Product;

   function Accumulate_Lane
     (A, B : Real_Array; Count : Block_Count; Lane : Lane_Number; Acc : Lane_Real)
      return Lane_Real with
     Global => null,
     Pre => (Static => A'Length <= Max_Size and then Same_Bounds (A, B)
       and then In_Tier0 (A) and then In_Tier0 (B)
       and then Count < A'Length / 4 and then Acc = Lane_Sum (A, B, Count, Lane)),
     Post => (Static => Accumulate_Lane'Result = Lane_Sum (A, B, Count + 1, Lane)
       and then abs Accumulate_Lane'Result <= Real (Count + 1) * Step_Bound
       and then (if A = B then Accumulate_Lane'Result >= 0.0))
   is
      I : constant Natural := A'First + (4 * Count + Lane);
   begin
      Unfold_Lane (A, B, Count, Lane);
      return Accumulate (Acc, Product (A (I), B (I)), Count);
   end Accumulate_Lane;

   procedure Dot_Blocks (A, B : Real_Array; R0, R1, R2, R3 : out Lane_Real) with
     Global => null,
     Pre => A'Length <= Max_Size and then Same_Bounds (A, B)
       and then In_Tier0 (A) and then In_Tier0 (B),
     Post => (Static => R0 = Lane_Sum (A, B, A'Length / 4, 0)
       and then R1 = Lane_Sum (A, B, A'Length / 4, 1)
       and then R2 = Lane_Sum (A, B, A'Length / 4, 2)
       and then R3 = Lane_Sum (A, B, A'Length / 4, 3)
       and then (if A = B then R0 >= 0.0 and then R1 >= 0.0 and then R2 >= 0.0 and then R3 >= 0.0))
   is
      N : constant Size_Type := A'Length;
   begin
      R0 := 0.0; R1 := 0.0; R2 := 0.0; R3 := 0.0;
      for Block in 0 .. (N / 4) - 1 loop
         R0 := Accumulate_Lane (A, B, Block, 0, R0);
         R1 := Accumulate_Lane (A, B, Block, 1, R1);
         R2 := Accumulate_Lane (A, B, Block, 2, R2);
         R3 := Accumulate_Lane (A, B, Block, 3, R3);
         pragma Loop_Invariant
           (Static => R0 = Lane_Sum (A, B, Block + 1, 0)
            and then R1 = Lane_Sum (A, B, Block + 1, 1)
            and then R2 = Lane_Sum (A, B, Block + 1, 2)
            and then R3 = Lane_Sum (A, B, Block + 1, 3));
         pragma Loop_Invariant
           (abs R0 <= Real (Block + 1) * Step_Bound
            and then abs R1 <= Real (Block + 1) * Step_Bound
            and then abs R2 <= Real (Block + 1) * Step_Bound
            and then abs R3 <= Real (Block + 1) * Step_Bound);
         pragma Loop_Invariant
           (if A = B then R0 >= 0.0 and then R1 >= 0.0 and then R2 >= 0.0 and then R3 >= 0.0);
      end loop;
   end Dot_Blocks;

   function Dot_Tail (A, B : Real_Array) return Tail_Real with
     Global => null,
     Pre => A'Length <= Max_Size and then Same_Bounds (A, B)
       and then In_Tier0 (A) and then In_Tier0 (B),
     Post => (Static => Dot_Tail'Result = Tail_Sum (A, B)
       and then (if A = B then Dot_Tail'Result >= 0.0))
   is
   begin
      case A'Length mod 4 is
         when 3 =>
            return (Product (A (A'Last - 2), B (A'Last - 2))
                    + Product (A (A'Last - 1), B (A'Last - 1)))
                   + Product (A (A'Last), B (A'Last));
         when 2 =>
            return Product (A (A'Last - 1), B (A'Last - 1))
                   + Product (A (A'Last), B (A'Last));
         when 1 =>
            return Product (A (A'Last), B (A'Last));
         when others =>
            return 0.0;
      end case;
   end Dot_Tail;

   function Combine (R0, R1, R2, R3 : Lane_Real; Tail : Tail_Real) return Tier1_Real with
     Global => null,
     Post => (Static => Combine'Result = Combine_Lanes (R0, R1, R2, R3, Tail)
       and then Combine'Result = ((R0 + R2) + (R1 + R3)) + Tail
       and then (if R0 >= 0.0 and then R1 >= 0.0 and then R2 >= 0.0
                 and then R3 >= 0.0 and then Tail >= 0.0 then Combine'Result >= 0.0))
   is
   begin
      return ((R0 + R2) + (R1 + R3)) + Tail;
   end Combine;

   function Dot (A, B : Real_Array) return Tier1_Real is
      R0, R1, R2, R3 : Lane_Real;
   begin
      Dot_Blocks (A, B, R0, R1, R2, R3);
      Unfold_Dot (A, B);
      return Combine (R0, R1, R2, R3, Dot_Tail (A, B));
   end Dot;

   function Norm (A : Real_Array) return Nonnegative_Real is
     (Sqrt (Dot (A, A)));

   procedure Normalize (A : in out Real_Array; Length : out Nonnegative_Real) is
   begin
      pragma Assert (In_Tier1 (A));
      Length := Norm (A);
      if Length < Min_Val then
         A := [others => 0.0];
         A (A'First) := 1.0;
      else
         Scale_By_Inverse (A, Inverse_Length (Length));
      end if;
   end Normalize;
end MJ.BLAS;

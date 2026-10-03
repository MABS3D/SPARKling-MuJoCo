package body MJ.Constraint_Solvers.Reductions with SPARK_Mode is
   use Models;
   function Accumulate (Acc, Term : Real; Count : Natural) return Lane_Real with
     Global => null,
     Pre => Count < Max_Rows and then abs Acc <= Real (Count) * Step_Bound
       and then abs Term <= 1.0e240,
     Post => Accumulate'Result = Acc + Term
       and then abs Accumulate'Result <= Real (Count + 1) * Step_Bound
       and then (if Acc >= 0.0 and then Term >= 0.0 then Accumulate'Result >= 0.0)
   is
   begin
      return Acc + Term;
   end Accumulate;

   function Product (X, Y : Operand) return Real with
     Global => null,
     Post => Product'Result = X * Y and then abs Product'Result <= 1.0e240
       and then (if X = Y then Product'Result >= 0.0)
   is
   begin
      return X * Y;
   end Product;

   function Accumulate_Lane
     (A, B : Vector; Count : Block_Count; Lane : Lane_Number; Acc : Lane_Real)
      return Lane_Real with
     Global => null,
     Pre => (Static => A'First = 1 and then A'Length <= Max_Rows and then Same_Bounds (A, B)
       and then In_Operand (A) and then In_Operand (B)
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

   procedure Dot_Blocks (A, B : Vector; R0, R1, R2, R3 : out Lane_Real) with
     Global => null,
     Pre => A'First = 1 and then A'Length <= Max_Rows and then Same_Bounds (A, B)
       and then In_Operand (A) and then In_Operand (B),
     Post => (Static => R0 = Lane_Sum (A, B, A'Length / 4, 0)
       and then R1 = Lane_Sum (A, B, A'Length / 4, 1)
       and then R2 = Lane_Sum (A, B, A'Length / 4, 2)
       and then R3 = Lane_Sum (A, B, A'Length / 4, 3)
       and then (if A = B then R0 >= 0.0 and then R1 >= 0.0 and then R2 >= 0.0 and then R3 >= 0.0))
   is
      N : constant Natural := A'Length;
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

   function Dot_Tail (A, B : Vector) return Tail_Real with
     Global => null,
     Pre => A'First = 1 and then A'Length <= Max_Rows and then Same_Bounds (A, B)
       and then In_Operand (A) and then In_Operand (B),
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

   function Combine (R0, R1, R2, R3 : Lane_Real; Tail : Tail_Real) return Dot_Real with
     Global => null,
     Post => (Static => Combine'Result = Combine_Lanes (R0, R1, R2, R3, Tail)
       and then Combine'Result = ((R0 + R2) + (R1 + R3)) + Tail
       and then (if R0 >= 0.0 and then R1 >= 0.0 and then R2 >= 0.0
                 and then R3 >= 0.0 and then Tail >= 0.0 then Combine'Result >= 0.0))
   is
   begin
      return ((R0 + R2) + (R1 + R3)) + Tail;
   end Combine;

   function Dot (A, B : Vector) return Dot_Real is
      R0, R1, R2, R3 : Lane_Real;
   begin
      Dot_Blocks (A, B, R0, R1, R2, R3);
      Unfold_Dot (A, B);
      return Combine (R0, R1, R2, R3, Dot_Tail (A, B));
   end Dot;

end MJ.Constraint_Solvers.Reductions;

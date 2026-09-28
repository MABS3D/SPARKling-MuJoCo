with MJ.Cholesky_Models; use MJ.Cholesky_Models;
with MJ.Cholesky_Steps; use MJ.Cholesky_Steps;

package body MJ.Cholesky with SPARK_Mode is
   --  Four independent lanes and the same tail grouping as mju_dot/AVX.
   function Dot (A, B : Real_Array; A0, B0 : Natural; Count : Dot_Count) return Real
     with Inline_Always, Pre => Valid_Dot (A, B, A0, B0, Count),
       Post => (Static => Dot'Result = Dot_Value (A, B, A0, B0, Count)
                and then abs Dot'Result <= 1.0e207)
   is
      type Lanes is array (Lane) of Real;
      Acc : Lanes := [others => 0.0];
      Result : Real;
      K : Natural := 0;
   begin
      for Block in 0 .. Count / 4 - 1 loop
         pragma Loop_Optimize (No_Vector);
         for L in Lane loop
            pragma Loop_Optimize (Vector);
            Unfold_Lane (A, B, A0, B0, Block, L);
            Acc (L) := Acc (L) + Product (A (A0 + 4 * Block + L), B (B0 + 4 * Block + L));
            pragma Loop_Invariant
              (Static => (for all J in Lane => Acc (J) =
                Lane_Sum (A, B, A0, B0, (if J <= L then Block + 1 else Block), J)));
            pragma Loop_Invariant
              (for all J in Lane => abs Acc (J) <=
                Real (if J <= L then Block + 1 else Block) * Step_Bound);
         end loop;
         pragma Loop_Invariant
           (Static => (for all L in Lane =>
              Acc (L) = Lane_Sum (A, B, A0, B0, Block + 1, L)));
         pragma Loop_Invariant
           (for all L in Lane => abs Acc (L) <= Real (Block + 1) * Step_Bound);
      end loop;
      K := 4 * (Count / 4);
      Result := (Acc (0) + Acc (2)) + (Acc (1) + Acc (3));
      case Count - K is
         when 3 => Result := Result +
           ((Product (A (A0 + K), B (B0 + K)) + Product (A (A0 + K + 1), B (B0 + K + 1)))
            + Product (A (A0 + K + 2), B (B0 + K + 2)));
         when 2 => Result := Result +
           (Product (A (A0 + K), B (B0 + K)) + Product (A (A0 + K + 1), B (B0 + K + 1)));
         when 1 => Result := Result + Product (A (A0 + K), B (B0 + K));
         when others => null;
      end case;
      return Result;
   end Dot;

   procedure Factor (A : in out Real_Array; N : Dimension;
                     Minimum : Threshold; Rank : out Natural) is
      Pivot, Inverse : Real;
      Deficient : Boolean;
   begin
      Rank := N;
      for J in 0 .. N - 1 loop
         pragma Loop_Invariant (Rank in N - J .. N);
         pragma Loop_Invariant (Same_Upper (A, A'Loop_Entry, N));
         Pivot := A (J * N + J);
         if J > 0 then
            Pivot := Pivot - Dot (A, A, J * N, J * N, J);
         end if;
         Deficient := Pivot < Minimum;
         if Deficient then
            Rank := Rank - 1;
         end if;
         A (J * N + J) := Root (Pivot, Minimum);
         if Deficient then
            for I in J + 1 .. N - 1 loop
               A (I * N + J) := 0.0;
            end loop;
         else
            Inverse := 1.0 / A (J * N + J);
            for I in J + 1 .. N - 1 loop
               A (I * N + J) := Factor_Entry
                 (A (I * N + J), Dot (A, A, I * N, J * N, J), Inverse);
            end loop;
         end if;
      end loop;
   end Factor;

   procedure Solve (A : Real_Array; X : in out Real_Array; N : Dimension) is
   begin
      for I in 0 .. N - 1 loop
         if I > 0 then
            X (I) := X (I) - Dot (A, X, I * N, 0, I);
         end if;
         X (I) := X (I) / A (I * N + I);
      end loop;
      for I in reverse 0 .. N - 1 loop
         for J in I + 1 .. N - 1 loop
            X (I) := X (I) - A (J * N + I) * X (J);
         end loop;
         X (I) := X (I) / A (I * N + I);
      end loop;
   end Solve;

   procedure Update (A, X : in out Real_Array; N : Dimension;
                     Plus : Boolean; Rank : out Natural) is
      Diagonal, Square, R, C, Inverse_C, S : Real;
   begin
      Rank := N;
      for K in 0 .. N - 1 loop
         pragma Loop_Invariant (Rank in N - K .. N);
         pragma Loop_Invariant (Same_Upper (A, A'Loop_Entry, N));
         if X (K) /= 0.0 then
            Diagonal := A (K * N + K);
            Square := Update_Square (Diagonal, X (K), Plus);
            if Square < Min_Val then
               Rank := Rank - 1;
            end if;
            R := Root (Square, Min_Val);
            C := R / Diagonal;
            Inverse_C := 1.0 / C;
            S := X (K) / Diagonal;
            A (K * N + K) := R;
            --  Hoist the sign branch outside the column loop, like C.
            if Plus then
               for I in K + 1 .. N - 1 loop
                  A (I * N + K) := Update_Entry
                    (A (I * N + K), S, X (I), Inverse_C, True);
               end loop;
            else
               for I in K + 1 .. N - 1 loop
                  A (I * N + K) := Update_Entry
                    (A (I * N + K), S, X (I), Inverse_C, False);
               end loop;
            end if;
            for I in K + 1 .. N - 1 loop
               X (I) := Update_Vector (C, X (I), S, A (I * N + K));
            end loop;
         end if;
      end loop;
   end Update;
end MJ.Cholesky;

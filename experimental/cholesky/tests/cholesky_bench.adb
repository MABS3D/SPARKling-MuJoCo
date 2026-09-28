with Ada.Command_Line; use Ada.Command_Line;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C;
with System;
with MJ.Types; use MJ.Types;
with MJ.Cholesky;
procedure Cholesky_Bench is
   function C_Factor (A : System.Address; N : Interfaces.C.int; Minimum : Real)
     return Interfaces.C.int with Import, Convention => C, External_Name => "mju_cholFactor";
   procedure C_Solve (X, A, B : System.Address; N : Interfaces.C.int)
     with Import, Convention => C, External_Name => "mju_cholSolve";
   function C_Update (A, X : System.Address; N, Plus : Interfaces.C.int)
     return Interfaces.C.int with Import, Convention => C, External_Name => "mju_cholUpdate";
   N : constant Positive := Positive'Value (Argument (1));
   Op : constant Natural := Natural'Value (Argument (2));
   Use_C : constant Boolean := Argument (3) = "c";
   Batches : constant Positive := Positive'Value (Argument (4));
   Batch : constant Positive := Positive'Max (4, Positive'Min (128, 65_536 / (N * N)));
   type Matrices is array (1 .. Batch) of Real_Array (0 .. N * N - 1);
   type Vectors is array (1 .. Batch) of Real_Array (0 .. N - 1);
   Seed_A, A : Matrices;
   Seed_X, X : Vectors;
   Rank : Natural;
   C_Rank : Interfaces.C.int;
   Start : Time;
   Elapsed : Duration := 0.0;
   Checksum : Real := 0.0;
   procedure Factor (M : in out Real_Array) is
   begin
      if Use_C then C_Rank := C_Factor (M'Address, Interfaces.C.int (N), Min_Val);
      else MJ.Cholesky.Factor (M, N, Min_Val, Rank); end if;
   end Factor;
   procedure Solve (M : Real_Array; V : in out Real_Array) is
   begin
      if Use_C then C_Solve (V'Address, M'Address, V'Address, Interfaces.C.int (N));
      else MJ.Cholesky.Solve (M, V, N); end if;
   end Solve;
   procedure Update (M, V : in out Real_Array; Plus : Boolean) is
   begin
      if Use_C then C_Rank := C_Update (M'Address, V'Address, Interfaces.C.int (N), Boolean'Pos (Plus));
      else MJ.Cholesky.Update (M, V, N, Plus, Rank); end if;
   end Update;
begin
   for B in 1 .. Batch loop
      for I in 0 .. N - 1 loop
         for J in 0 .. N - 1 loop
            Seed_A (B) (I * N + J) :=
              (if I = J then Real (N) + 1.0 + Real (B) * 0.001
               else 0.1 / Real (1 + abs (I - J)));
         end loop;
         Seed_X (B) (I) := Real ((I + B) mod 7 - 3) * 0.01;
      end loop;
      if Op in 1 .. 3 then Factor (Seed_A (B)); end if;
   end loop;
   --  Warm up code/data. Every measured batch uses fresh prepared inputs.
   for Run in 0 .. Batches loop
      A := Seed_A; X := Seed_X;
      Start := Clock;
      case Op is
         when 0 =>
            for B in 1 .. Batch loop Factor (A (B)); end loop;
         when 1 =>
            for B in 1 .. Batch loop Solve (A (B), X (B)); end loop;
         when 2 | 3 =>
            for B in 1 .. Batch loop Update (A (B), X (B), Op = 2); end loop;
         when 4 =>
            for B in 1 .. Batch loop
               Factor (A (B)); Solve (A (B), X (B));
               Update (A (B), X (B), True); Solve (A (B), X (B));
            end loop;
         when others => raise Constraint_Error;
      end case;
      if Run > 0 then Elapsed := Elapsed + To_Duration (Clock - Start); end if;
      --  Observe all modified arrays outside the timed interval.
      for B in 1 .. Batch loop
         for V of A (B) loop Checksum := Checksum + V; end loop;
         for V of X (B) loop Checksum := Checksum + V; end loop;
      end loop;
   end loop;
   Put_Line (Duration'Image (Elapsed));
   Put_Line (Integer'Image (Batch * Batches));
   Put_Line (Real'Image (Checksum));
end Cholesky_Bench;

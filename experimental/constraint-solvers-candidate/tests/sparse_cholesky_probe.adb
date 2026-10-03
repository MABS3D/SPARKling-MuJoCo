with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Sparse_Cholesky;
procedure Sparse_Cholesky_Probe is
   package C renames MJ.Constraint_Solvers.Sparse_Cholesky;
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, Bit : Integer;
   Floor : C.Pivot;
   Rank : Natural;
   Result : C.Status;
   use type C.Status;
   procedure Put (V : Real) is
   begin IO.Put (V, Fore => 1, Aft => 17, Exp => 3); Put (' '); end Put;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); IO.Get (Floor);
      declare
         P : C.Pattern (N);
         Mask : C.Mask (1 .. N, 1 .. N);
         H, L : Matrix (1 .. N, 1 .. N);
         B, X : Vector (1 .. N);
      begin
         for I in 1 .. N loop for J in 1 .. N loop
            Ada.Integer_Text_IO.Get (Bit); Mask (I, J) := Bit /= 0;
         end loop; end loop;
         for Row in 1 .. N loop for Col in 1 .. N loop IO.Get (H (Row, Col)); end loop; end loop;
         for V of B loop IO.Get (V); end loop;
         C.Symbolic (Mask, P, Result); Put (C.Status'Image (Result));
         if Result /= C.Success then raise Program_Error; end if;
         for I in 1 .. N loop
            Put (Natural'Image (P.Length (I)));
            for K in 1 .. P.Length (I) loop Put (Natural'Image (P.Column (I, K))); end loop;
            Put (Natural'Image (P.Transpose_Length (I)));
            for K in 1 .. P.Transpose_Length (I) loop
               Put (Natural'Image (P.Transpose_Row (I, K)));
               Put (Natural'Image (P.Transpose_Position (I, K)));
            end loop;
         end loop;
         New_Line;
         C.Factor (H, P, L, Rank, Result, Floor);
         Put (C.Status'Image (Result)); Put (Natural'Image (Rank)); Put (' ');
         for I in 1 .. N loop for J in 1 .. N loop Put (L (I, J)); end loop; end loop;
         C.Backsolve (L, P, B, X, Result); Put (C.Status'Image (Result)); Put (' ');
         for V of X loop Put (V); end loop;
         New_Line;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Sparse_Cholesky_Probe;

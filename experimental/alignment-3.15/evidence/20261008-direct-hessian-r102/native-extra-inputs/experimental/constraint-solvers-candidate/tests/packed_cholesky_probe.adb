with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Sparse_Cholesky;
with MJ.Constraint_Solvers.Packed_Cholesky;
procedure Packed_Cholesky_Probe is
   package C renames MJ.Constraint_Solvers.Sparse_Cholesky;
   package Packed renames MJ.Constraint_Solvers.Packed_Cholesky;
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, Bit : Integer;
   Floor : C.Pivot;
   Rank : Natural;
   Result : C.Status;
   use type C.Status;
   procedure Put (V : Real) is
   begin IO.Put (V, Fore => 1, Aft => 17, Exp => 3); Put (' '); end Put;
begin
   declare
      --  The first CSC row refers to a malformed later row. Validation must
      --  reject it before indexing beyond the second dimension of Column.
      Bad : C.Pattern (2);
   begin
      Bad.Length := (1, 3); Bad.Transpose_Length := (2, 1);
      Bad.Column := (others => (others => 0)); Bad.Column (1, 1) := 1;
      Bad.Transpose_Row := (others => (others => 0));
      Bad.Transpose_Position := (others => (others => 0));
      Bad.Transpose_Row (1, 1) := 1; Bad.Transpose_Position (1, 1) := 1;
      Bad.Transpose_Row (1, 2) := 2; Bad.Transpose_Position (1, 2) := 3;
      if C.Valid (Bad) then raise Program_Error with "malformed CSC accepted"; end if;
   end;
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); IO.Get (Floor);
      declare
         Plan : Packed.Symbolic_Plan (N);
         Mask : C.Mask (1 .. N, 1 .. N);
         H, L : Matrix (1 .. N, 1 .. N);
         B, X : Vector (1 .. N);
      begin
         for I in 1 .. N loop for J in 1 .. N loop
            Ada.Integer_Text_IO.Get (Bit); Mask (I, J) := Bit /= 0;
         end loop; end loop;
         for Row in 1 .. N loop for Col in 1 .. N loop IO.Get (H (Row, Col)); end loop; end loop;
         for V of B loop IO.Get (V); end loop;
         Packed.Count_Symbolic (Mask, Plan, Result); Put (C.Status'Image (Result));
         if Result /= C.Success then raise Program_Error; end if;
         declare
            Flat : Packed.Flat_Pattern (N, Plan.Stored);
            --  Poison every allocated slot, including sparse gaps in H.
            Values : Vector (1 .. Plan.Stored) := (others => 1.0e120);
         begin
            Packed.Fill_Symbolic (Mask, Plan, Flat, Result);
            if Result /= C.Success then raise Program_Error with "symbolic fill failed"; end if;
         for I in 1 .. N loop
            Put (Natural'Image (Flat.Length (I)));
            for K in 1 .. Flat.Length (I) loop Put (Natural'Image (Flat.Column (Flat.Address (I)+K))); end loop;
            Put (Natural'Image (Flat.Transpose_Length (I)));
            for K in 1 .. Flat.Transpose_Length (I) loop
               Put (Natural'Image (Flat.Transpose_Row (Flat.Transpose_Address (I)+K)));
               Put (Natural'Image (Flat.Transpose_Slot (Flat.Transpose_Address (I)+K)-
                 Flat.Address (Flat.Transpose_Row (Flat.Transpose_Address (I)+K))));
            end loop;
         end loop;
         New_Line;
         Packed.Factor_Flat (H, Flat, Values, Rank, Result, Floor);
         Packed.Expand_Flat (Values, Flat, L);
         Put (C.Status'Image (Result)); Put (Natural'Image (Rank)); Put (' ');
         for I in 1 .. N loop for J in 1 .. N loop Put (L (I, J)); end loop; end loop;
         Packed.Backsolve_Flat (Values, Flat, B, X, Result); Put (C.Status'Image (Result)); Put (' ');
         for V of X loop Put (V); end loop;
         New_Line;
         end;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Packed_Cholesky_Probe;

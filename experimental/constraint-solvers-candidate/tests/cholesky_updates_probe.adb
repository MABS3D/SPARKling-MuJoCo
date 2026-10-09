with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Cholesky_Updates;
procedure Cholesky_Updates_Probe is
   package U renames MJ.Constraint_Solvers.Cholesky_Updates;
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, Mode, Start, Plus, Bit : Integer;
   Rank, Stored : Natural;
   Result : U.Status;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (Mode);
      Ada.Integer_Text_IO.Get (Start); Ada.Integer_Text_IO.Get (Plus);
      if N not in 1 .. Max_Dofs then raise Constraint_Error; end if;
      declare
         P : U.Sparse.Pattern (N);
         L : Matrix (1 .. N, 1 .. N);
         X : Vector (1 .. N);
      begin
         Stored := 0;
         P.Length := (others => 0); P.Transpose_Length := (others => 0);
         P.Column := (others => (others => 0));
         P.Transpose_Row := (others => (others => 0));
         P.Transpose_Position := (others => (others => 0));
         for I in 1 .. N loop
            for J in 1 .. N loop
               Ada.Integer_Text_IO.Get (Bit);
               if Bit /= 0 then
                  Stored := Stored+1;
                  P.Length (I) := P.Length (I)+1;
                  P.Column (I, P.Length (I)) := J;
                  P.Transpose_Length (J) := P.Transpose_Length (J)+1;
                  P.Transpose_Row (J, P.Transpose_Length (J)) := I;
                  P.Transpose_Position (J, P.Transpose_Length (J)) := P.Length (I);
               end if;
            end loop;
         end loop;
         for I in 1 .. N loop
            for J in 1 .. N loop IO.Get (L (I, J)); end loop;
         end loop;
         for V of X loop IO.Get (V); end loop;
         if Mode = 0 then U.Update_Dense (L, X, Plus /= 0, Rank, Result);
         elsif Mode = 1 then U.Update_Sparse (L, P, X, Start, Plus /= 0, Rank, Result);
         else
            declare
               F : U.Packed.Flat_Pattern (N, Stored);
               Values : Vector (1 .. Stored);
               Cursor : Natural := 0;
            begin
               F.Length := P.Length; F.Transpose_Length := P.Transpose_Length;
               for I in 1 .. N loop
                  F.Address (I) := Cursor;
                  for K in 1 .. P.Length (I) loop
                     Cursor := Cursor+1;
                     F.Column (Cursor) := P.Column (I, K);
                     Values (Cursor) := L (I, P.Column (I, K));
                  end loop;
               end loop;
               Cursor := 0;
               for I in 1 .. N loop
                  F.Transpose_Address (I) := Cursor;
                  for K in 1 .. P.Transpose_Length (I) loop
                     Cursor := Cursor+1;
                     F.Transpose_Row (Cursor) := P.Transpose_Row (I, K);
                     F.Transpose_Slot (Cursor) := F.Address (P.Transpose_Row (I, K))+
                       P.Transpose_Position (I, K);
                  end loop;
               end loop;
               U.Update_Flat (Values, F, X, Start, Plus /= 0, Rank, Result);
               for I in 1 .. N loop
                  for K in 1 .. F.Length (I) loop
                     L (I, F.Column (F.Address (I)+K)) := Values (F.Address (I)+K);
                  end loop;
               end loop;
            end;
         end if;
         Put (U.Status'Image (Result)); Put (Natural'Image (Rank));
         for I in 1 .. N loop
            for J in 1 .. N loop
               Put (' '); IO.Put (L (I, J), Fore => 1, Aft => 17, Exp => 3);
            end loop;
         end loop;
         for V of X loop Put (' '); IO.Put (V, Fore => 1, Aft => 17, Exp => 3); end loop;
         New_Line;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Cholesky_Updates_Probe;

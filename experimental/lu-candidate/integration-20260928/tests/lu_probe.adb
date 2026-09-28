with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.LU; use MJ.LU;
procedure LU_Probe is
   package Floats is new Ada.Text_IO.Float_IO (Real);
   Mode : Character;
   Size, Count : Integer;
   Result : Status;
   First : Integer;
   procedure Emit (A : Real_Array) is
   begin
      for X of A loop Floats.Put (X, Fore => 1, Aft => 17, Exp => 3); Put (' '); end loop;
      New_Line;
   end Emit;
   procedure Emit (A : Int_Array) is
   begin
      for X of A loop Put (X, Width => 0); Put (' '); end loop;
      New_Line;
   end Emit;
begin
   while not End_Of_File loop
      Get (Mode); Get (Size);
      if Mode = 'D' then
         declare
            N : constant Order := Size;
            A : Real_Array (0 .. N*N-1);
            B, X : Real_Array (0 .. N-1);
            P : Int_Array (0 .. N-1);
         begin
            for V of A loop Floats.Get (V); end loop;
            for V of B loop Floats.Get (V); end loop;
            Factor_Dense (A, N, P, Result); Put_Line (Result'Image);
            Emit (A); Emit (P);
            if Result = Success then Solve_Dense (A, N, P, B, X, Result); else X := [others => 0.0]; end if;
            Put_Line (Result'Image); Emit (X);
         end;
      elsif Mode = 'S' then
         Get (Count);
         declare
            N : constant Order := Size;
            A : Real_Array (0 .. Count-1);
            B, X : Real_Array (0 .. N-1);
            Row_Start : Int_Array (0 .. N);
            Column : Int_Array (0 .. Count-1);
            Diagonal, Scratch : Int_Array (0 .. N-1);
         begin
            for V of Row_Start loop Get (V); end loop;
            for V of Column loop Get (V); end loop;
            for V of A loop Floats.Get (V); end loop;
            for V of B loop Floats.Get (V); end loop;
            Analyze (N, Row_Start, Column, Diagonal, Result);
            First := -1;
            if Result = Success then Factor_Sparse (A,N,Row_Start,Column,Diagonal,Scratch,First,Result); end if;
            Put_Line (Result'Image); Emit (A); Put (First, Width => 0); New_Line;
            if Result = Success then Solve_Sparse (A,N,Row_Start,Column,Diagonal,B,X,Result);
            else X := [others => 0.0]; end if;
            Put_Line (Result'Image); Emit (X);
         end;
      else raise Program_Error with "bad mode";
      end if;
      Skip_Line;
   end loop;
end LU_Probe;

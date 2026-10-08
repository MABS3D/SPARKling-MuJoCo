with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Dense_Cholesky;
procedure Dense_Cholesky_Probe is
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   package CS renames MJ.Constraint_Solvers;
   package DC renames CS.Dense_Cholesky;
   use type DC.Status;
   N : Integer;
   Floor : Real;
   Rank : Natural;
   Result : DC.Status;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N);
      Numbers.Get (Floor);
      if N not in 1 .. CS.Max_Dofs then raise Constraint_Error; end if;
      declare
         M, L : CS.Matrix (1 .. N, 1 .. N);
         B, X : CS.Vector (1 .. N);
      begin
         for I in 1 .. N loop
            for J in 1 .. N loop Numbers.Get (M (I, J)); end loop;
         end loop;
         for V of B loop Numbers.Get (V); end loop;
         DC.Factor (M, L, Rank, Result, Floor);
         Put (DC.Status'Image (Result));
         Ada.Integer_Text_IO.Put (Rank);
         for I in 1 .. N loop
            for J in 1 .. N loop
               Put (' '); Numbers.Put (L (I, J), Fore => 1, Aft => 17, Exp => 3);
            end loop;
         end loop;
         if Result = DC.Success then
            DC.Backsolve (L, B, X, Result);
         else
            X := (others => 0.0);
         end if;
         Put (' '); Put (DC.Status'Image (Result));
         for V of X loop
            Put (' '); Numbers.Put (V, Fore => 1, Aft => 17, Exp => 3);
         end loop;
         New_Line;
      end;
      Skip_Line;
   end loop;
end Dense_Cholesky_Probe;

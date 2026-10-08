with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Native_Inertia;
procedure Native_Inertia_Probe is
   package NI renames MJ.Constraint_Solvers.Native_Inertia;
   use type NI.Status;
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, Count, V : Integer;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (Count);
      declare
         L : Sparse_Jacobian (N, Count);
         Inverse, RHS : Vector (1 .. N);
         X : Vector (1 .. N) := (others => 0.375);
         Bad_X : Vector (2 .. N+1) := (others => 0.625);
         Result, Bad : NI.Status;
      begin
         for Row in 1 .. N loop
            Ada.Integer_Text_IO.Get (V); L.Offsets (Row) := V;
            Ada.Integer_Text_IO.Get (V); L.Widths (Row) := V;
         end loop;
         for C of L.Columns loop Ada.Integer_Text_IO.Get (V); C := V; end loop;
         for A of L.Values loop IO.Get (A); end loop;
         for A of Inverse loop IO.Get (A); end loop;
         for A of RHS loop IO.Get (A); end loop;
         NI.Solve (L, Inverse, RHS, X, Result);
         if Result /= NI.Success and then (for some A of X => A /= 0.375) then
            raise Program_Error with "native inertia rejection modified output";
         end if;
         NI.Solve (L, Inverse, RHS, Bad_X, Bad);
         if Bad /= NI.Invalid_Input or else (for some A of Bad_X => A /= 0.625) then
            raise Program_Error with "native inertia output origin was not rejected atomically";
         end if;
         Put (NI.Status'Image (Result)); Put (' ');
         for A of X loop IO.Put (A, Fore => 1, Aft => 17, Exp => 3); Put (' '); end loop;
         New_Line;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Native_Inertia_Probe;

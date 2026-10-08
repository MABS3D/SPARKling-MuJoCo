with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Jacobians;
procedure Jacobians_Probe is
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, K, Stored, V : Integer;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (K);
      Ada.Integer_Text_IO.Get (Stored);
      declare
         J : Sparse_Jacobian (K, Stored);
         Dense : Matrix (1 .. K, 1 .. N) := (others => (others => 0.0));
         X : Vector (1 .. N);
      begin
         for R in 1 .. K loop
            Ada.Integer_Text_IO.Get (V); J.Offsets (R) := V;
            Ada.Integer_Text_IO.Get (V); J.Widths (R) := V;
         end loop;
         for C of J.Columns loop Ada.Integer_Text_IO.Get (V); C := V; end loop;
         for E of J.Values loop IO.Get (E); end loop;
         for E of X loop IO.Get (E); end loop;
         if not Jacobians.Valid (J, N) then
            Put_Line ("INVALID");
         else
            for R in 1 .. K loop
               for I in J.Offsets (R)+1 .. J.Offsets (R)+J.Widths (R) loop
                  Dense (R, J.Columns (I)) := Dense (R, J.Columns (I)) + J.Values (I);
               end loop;
               IO.Put (Jacobians.Sparse_Row (J, X, R), Fore => 1, Aft => 17, Exp => 3); Put (' ');
               IO.Put (Jacobians.Dense_Row (Dense, X, R), Fore => 1, Aft => 17, Exp => 3); Put (' ');
            end loop;
            New_Line;
         end if;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Jacobians_Probe;

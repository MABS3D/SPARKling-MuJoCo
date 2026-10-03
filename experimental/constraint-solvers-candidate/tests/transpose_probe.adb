with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Jacobians;
with MJ.Constraint_Solvers.Jacobian_Transpose;
procedure Transpose_Probe is
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, K, Stored, V : Integer;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (K);
      Ada.Integer_Text_IO.Get (Stored);
      declare
         J : Sparse_Jacobian (K, Stored);
         F : Vector (1 .. K);
      begin
         for R in 1 .. K loop
            Ada.Integer_Text_IO.Get (V); J.Offsets (R) := V;
            Ada.Integer_Text_IO.Get (V); J.Widths (R) := V;
         end loop;
         for C of J.Columns loop Ada.Integer_Text_IO.Get (V); C := V; end loop;
         for E of J.Values loop IO.Get (E); end loop;
         for E of F loop IO.Get (E); end loop;
         if not Jacobians.Valid (J, N) or else K = 0
           or else Jacobian_Transpose.Total_Width (J) > Max_Jacobian_Entries
         then Put_Line ("INVALID");
         else
            declare
               T : Sparse_Jacobian (N, Jacobian_Transpose.Total_Width (J));
            begin
               Jacobian_Transpose.Build (J, T);
               for C in 1 .. N loop Put (Natural'Image (T.Offsets (C))); Put (Natural'Image (T.Widths (C))); end loop;
               for C of T.Columns loop Put (Positive'Image (C)); end loop; Put (' ');
               for E of T.Values loop IO.Put (E, Fore => 1, Aft => 17, Exp => 3); Put (' '); end loop;
               for C in 1 .. N loop IO.Put (Jacobians.Sparse_Row (T, F, C), Fore => 1, Aft => 17, Exp => 3); Put (' '); end loop;
               New_Line;
            end;
         end if;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Transpose_Probe;

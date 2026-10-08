with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Reductions;

procedure Reductions_Probe is
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   package CS renames MJ.Constraint_Solvers;
   N : Integer;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N);
      if N not in 0 .. CS.Max_Rows then raise Constraint_Error; end if;
      declare
         A, B : CS.Vector (1 .. N);
      begin
         for X of A loop Numbers.Get (X); end loop;
         for X of B loop Numbers.Get (X); end loop;
         Numbers.Put (CS.Reductions.Dot (A, B), Fore => 1, Aft => 17, Exp => 3);
         New_Line;
      end;
      Skip_Line;
   end loop;
end Reductions_Probe;

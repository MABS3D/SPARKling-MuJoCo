with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Sparse_Cholesky;
with MJ.Constraint_Solvers.Packed_Cholesky;
procedure Mass_Addition_Probe is
   package S renames MJ.Constraint_Solvers.Sparse_Cholesky;
   package P renames MJ.Constraint_Solvers.Packed_Cholesky;
   package IO is new Ada.Text_IO.Float_IO (Real);
   use type S.Status;
   N, Bit : Integer;
   Result : S.Status;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N);
      declare
         Mask : S.Mask (1 .. N, 1 .. N);
         H, M : Matrix (1 .. N, 1 .. N);
         Plan : P.Symbolic_Plan (N);
      begin
         for R in 1 .. N loop for C in 1 .. N loop
            Ada.Integer_Text_IO.Get (Bit); Mask (R, C) := Bit /= 0;
         end loop; end loop;
         for R in 1 .. N loop for C in 1 .. N loop IO.Get (H (R, C)); end loop; end loop;
         for R in 1 .. N loop for C in 1 .. N loop IO.Get (M (R, C)); end loop; end loop;
         P.Count_Symbolic (Mask, Plan, Result);
         if Result /= S.Success then raise Program_Error with "count failed"; end if;
         declare
            Flat : P.Flat_Pattern (N, Plan.Stored);
         begin
            P.Fill_Symbolic (Mask, Plan, Flat, Result);
            if Result /= S.Success then raise Program_Error with "fill failed"; end if;
            P.Add_Mass_Flat (H, M, Flat);
         end;
         Put (Natural'Image (Plan.Stored));
         for R in 1 .. N loop for C in 1 .. N loop
            Put (' '); IO.Put (H (R, C), Fore => 1, Aft => 17, Exp => 3);
         end loop; end loop;
         New_Line;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Mass_Addition_Probe;

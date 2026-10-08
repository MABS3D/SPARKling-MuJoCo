with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Cone_Kernels;
with MJ.Constraint_Solvers.Packed_Cholesky;
with MJ.Constraint_Solvers.Sparse_Cholesky;
procedure Flat_Gram_Probe is
   package Flat renames MJ.Constraint_Solvers.Packed_Cholesky;
   package Sparse renames MJ.Constraint_Solvers.Sparse_Cholesky;
   use type Sparse.Status;
   package Gram renames MJ.Constraint_Solvers.Cone_Kernels;
   package IO is new Ada.Text_IO.Float_IO (Real);
   Cases, N, Width, Packed_Flag : Integer;
   Weight, Previous : Real;
   Accepted : Boolean;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Case_Number in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (N);
      Ada.Integer_Text_IO.Get (Width);
      Ada.Integer_Text_IO.Get (Packed_Flag);
      IO.Get (Weight); IO.Get (Previous);
      declare
         H : Matrix (1 .. N, 1 .. N) := (others => (others => Previous));
         Values : Matrix (1 .. 1, 1 .. (if Packed_Flag = 1 then Width else N));
         Columns : Gram.Column_Matrix (1 .. 1, 1 .. N) := (others => (others => 1));
      begin
         for K in 1 .. Width loop Ada.Integer_Text_IO.Get (Columns (1, K)); end loop;
         for K in Values'Range (2) loop IO.Get (Values (1, K)); end loop;
         declare
            Mask : Sparse.Mask (1 .. N, 1 .. N) := (others => (others => False));
            Plan : Flat.Symbolic_Plan (N);
            Status : Sparse.Status;
         begin
            for R in 1 .. N loop
               Mask (R, R) := True;
               if R > 1 then Mask (R-1, R) := True; end if;
            end loop;
            for I in 1 .. Width loop
               for J in I .. Width loop Mask (Columns (1, I), Columns (1, J)) := True; end loop;
            end loop;
            Flat.Count_Symbolic (Mask, Plan, Status);
            if Status /= Sparse.Success then raise Program_Error; end if;
            declare
               F : Flat.Flat_Pattern (N, Plan.Stored);
               Compact : Vector (1 .. Plan.Stored) := (others => Previous);
            begin
               Flat.Fill_Symbolic (Mask, Plan, F, Status);
               if Status /= Sparse.Success then raise Program_Error; end if;
               Gram.Gram_Row_Flat (Compact, F, Values, Columns, 1, 1, Width, Weight, Packed_Flag = 1, Accepted);
               for R in 1 .. N loop
                  for S in F.Address (R)+1 .. F.Address (R)+F.Length (R) loop H (R, F.Column (S)) := Compact (S); end loop;
               end loop;
            end;
         end;
         Put (if Accepted then "1 " else "0 ");
         for I in H'Range (1) loop
            for J in H'Range (2) loop IO.Put (H (I, J), Fore => 1, Aft => 17, Exp => 3); Put (' '); end loop;
         end loop;
         New_Line;
      end;
   end loop;
end Flat_Gram_Probe;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Hessian_Assembly;
with MJ.Constraint_Solvers.Packed_Cholesky;
with MJ.Constraint_Solvers.Sparse_Cholesky;
procedure Row_Gram_Probe is
   package Assembly renames MJ.Constraint_Solvers.Hessian_Assembly;
   package Flat renames MJ.Constraint_Solvers.Packed_Cholesky;
   package Sparse renames MJ.Constraint_Solvers.Sparse_Cholesky;
   package IO is new Ada.Text_IO.Float_IO (Real);
   use type Sparse.Status;
   N, Rows, Stored, Bit, Width : Integer;
   procedure Put (Value : Real) is
   begin IO.Put (Value, Fore => 1, Aft => 17, Exp => 3); Put (' '); end Put;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (Rows); Ada.Integer_Text_IO.Get (Stored);
      declare
         P : Assembly.Pattern (N, Rows, Stored);
         Values : Vector (1 .. Stored);
         Weight : Vector (1 .. Rows);
         Mask : Sparse.Mask (1 .. N, 1 .. N);
         Plan : Flat.Symbolic_Plan (N);
         Status : Sparse.Status;
         Next : Natural := 0;
         Accepted : Boolean;
      begin
         for R in 1 .. Rows loop
            Ada.Integer_Text_IO.Get (Width); P.Address (R) := Next; P.Width (R) := Width;
            IO.Get (Weight (R));
            for K in 1 .. Width loop Ada.Integer_Text_IO.Get (P.Column (Next+K)); end loop;
            for K in 1 .. Width loop IO.Get (Values (Next+K)); end loop;
            Next := Next+Width;
         end loop;
         if Next /= Stored then raise Program_Error with "input slot count"; end if;
         for R in 1 .. N loop for C in 1 .. N loop
            Ada.Integer_Text_IO.Get (Bit); Mask (R, C) := Bit /= 0;
         end loop; end loop;
         Assembly.Build_Transpose (P);
         for C in 1 .. N loop
            Put (Natural'Image (P.T_Width (C))); Put (' ');
            for S in P.T_Address (C)+1 .. P.T_Address (C)+P.T_Width (C) loop
               Put (Positive'Image (P.T_Row (S))); Put (' '); Put (Natural'Image (P.T_Source (S))); Put (' ');
            end loop;
         end loop;
         New_Line;
         Flat.Count_Symbolic (Mask, Plan, Status);
         if Status /= Sparse.Success then raise Program_Error; end if;
         declare
            F : Flat.Flat_Pattern (N, Plan.Stored);
            H : Vector (1 .. Plan.Stored);
            Dense : Matrix (1 .. N, 1 .. N) := (others => (others => 0.0));
         begin
            Flat.Fill_Symbolic (Mask, Plan, F, Status);
            if Status /= Sparse.Success then raise Program_Error; end if;
            Assembly.Build_Gram (P, Values, Weight, F, H, Accepted);
            for R in 1 .. N loop for K in 1 .. F.Length (R) loop
               Dense (R, F.Column (F.Address (R)+K)) := H (F.Address (R)+K);
            end loop; end loop;
            Put (if Accepted then "1 " else "0 "); Put (Positive'Image (Plan.Stored)); Put (' ');
            for R in 1 .. N loop for C in 1 .. N loop Put (Dense (R, C)); end loop; end loop;
            New_Line;
         end;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Row_Gram_Probe;

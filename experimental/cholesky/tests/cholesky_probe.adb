with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Cholesky;
procedure Cholesky_Probe is
   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   Op, N, Sign, Rank : Integer;
   Minimum : Real;
   Result : MJ.Cholesky.Status;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (Op);
      Ada.Integer_Text_IO.Get (N);
      Ada.Integer_Text_IO.Get (Sign);
      Real_IO.Get (Minimum);
      declare
         A : Real_Array (0 .. N * N - 1);
         X : Real_Array (0 .. N - 1);
      begin
         for V of A loop Real_IO.Get (V); end loop;
         for V of X loop Real_IO.Get (V); end loop;
         Rank := N;
         case Op is
            when 0 => MJ.Cholesky.Factor (A, N, Minimum, Rank, Result);
            when 1 => MJ.Cholesky.Solve (A, X, N, Result);
            when 2 => MJ.Cholesky.Update (A, X, N, Sign /= 0, Rank, Result);
            when others => raise Constraint_Error;
         end case;
         Put_Line (Result'Image);
         Ada.Integer_Text_IO.Put (Rank, Width => 0); New_Line;
         for V of A loop Real_IO.Put (V, Fore => 0, Aft => 17, Exp => 3); New_Line; end loop;
         for V of X loop Real_IO.Put (V, Fore => 0, Aft => 17, Exp => 3); New_Line; end loop;
      end;
   end loop;
end Cholesky_Probe;

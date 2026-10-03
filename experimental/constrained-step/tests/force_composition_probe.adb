with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Force_Composition;
procedure Force_Composition_Probe is
   package FC renames MJ.Force_Composition;
   package IO is new Ada.Text_IO.Float_IO (Real);
   N : Integer;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N);
      if N not in 0 .. 256 then raise Program_Error; end if;
      declare
         P, B, A, U, Total : Real_Array (0 .. N-1);
         Accepted : Boolean;
      begin
         for X of P loop IO.Get (X); end loop;
         for X of B loop IO.Get (X); end loop;
         for X of A loop IO.Get (X); end loop;
         for X of U loop IO.Get (X); end loop;
         FC.Compose (P, B, A, U, Total, Accepted);
         Put (Boolean'Image (Accepted));
         if Accepted then
            for X of Total loop Put (' '); IO.Put (X, Fore => 1, Aft => 17, Exp => 3); end loop;
         end if;
         New_Line;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Force_Composition_Probe;

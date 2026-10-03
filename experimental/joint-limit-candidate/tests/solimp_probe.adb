with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Joint_Limit_Response;
procedure Solimp_Probe is
   package IO is new Float_IO (Real);
   package R renames MJ.Joint_Limit_Response;
   P : R.Parameters;
   Position, Margin, I, IP : Real;
   procedure Put (X : Real) is
   begin IO.Put (X, Fore => 1, Aft => 17, Exp => 3); Put (" "); end Put;
begin
   while not End_Of_File loop
      IO.Get (P.D0); IO.Get (P.D_Width); IO.Get (P.Width);
      IO.Get (P.Midpoint); IO.Get (P.Power); IO.Get (Position); IO.Get (Margin);
      begin
         declare E : constant R.Effective_Parameters := R.Sanitize (P, 0.002); begin
            I := R.Impedance (E, Position, Margin);
            IP := R.Impedance_Derivative (E, Position, Margin);
         end;
         if I = 0.0 then Put_Line ("numeric");
         else Put ("ok "); Put (I); Put (IP); New_Line; end if;
      exception
         when Constraint_Error => Put_Line ("numeric");
      end;
   end loop;
end Solimp_Probe;

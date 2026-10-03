with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Equality_Scalar;
procedure Scalar_Probe is
   package S renames MJ.Equality_Scalar;
   package IO is new Ada.Text_IO.Float_IO (Real);
   Cases, Width, Second : Integer;
   P0, R0, P1, R1, J0, J1 : Real;
   C : S.Coefficients;
   G : S.Geometry;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for K in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Width);
      Ada.Integer_Text_IO.Get (Second);
      IO.Get (P0); IO.Get (R0); IO.Get (P1); IO.Get (R1);
      for I in C'Range loop IO.Get (C (I)); end loop;
      G := S.Evaluate (P0, R0, P1, R1, C, Second /= 0);
      IO.Put (G.Position, Fore => 1, Aft => 17, Exp => 3); Put (' ');
      IO.Put (G.Derivative, Fore => 1, Aft => 17, Exp => 3); Put (' ');
      for I in 1 .. Width loop
         IO.Get (J0); IO.Get (J1);
         IO.Put ((if Second /= 0 then S.Jacobian (J0, J1, G.Derivative) else J0),
                 Fore => 1, Aft => 17, Exp => 3);
         Put (' ');
      end loop;
      New_Line;
   end loop;
end Scalar_Probe;

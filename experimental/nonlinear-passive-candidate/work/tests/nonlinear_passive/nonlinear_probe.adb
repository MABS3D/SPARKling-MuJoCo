with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Nonlinear_Passive;
procedure Nonlinear_Probe is
   package FIO is new Ada.Text_IO.Float_IO (Real);
   N, S, D : Integer;
   Q, R, V, K, B, K2, K3, B2, B3 : Real;
   procedure Emit (X : Real) is
   begin
      FIO.Put (X, Fore => 1, Aft => 17, Exp => 3); Put (' ');
   end Emit;
begin
   Ada.Integer_Text_IO.Get (N);
   for I in 1 .. N loop
      FIO.Get (Q); FIO.Get (R); FIO.Get (V); FIO.Get (K); FIO.Get (B);
      FIO.Get (K2); FIO.Get (K3); FIO.Get (B2); FIO.Get (B3);
      Ada.Integer_Text_IO.Get (S); Ada.Integer_Text_IO.Get (D);
      Emit (MJ.Nonlinear_Passive.Passive_Force
        (Q, R, V, K, B, K2, K3, B2, B3, S /= 0, D /= 0));
      Emit (MJ.Nonlinear_Passive.Damping_Derivative (B, B2, B3, V));
      New_Line;
   end loop;
end Nonlinear_Probe;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Equality_Geometry;
with MJ.Constraint_Assembly;
procedure Equality_Probe is
   package G renames MJ.Equality_Geometry;
   package CA renames MJ.Constraint_Assembly;
   package IO is new Ada.Text_IO.Float_IO (Real);
   Cases, Kind, Width, Site : Integer;
   Torque : Real;
   P0, P1, T0, T1, L0, L1 : G.Vector;
   R0, R1 : G.Rotation;
   Q0, Q1, Local0, Local1, A, B : G.Quaternion;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for K in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Kind); Ada.Integer_Text_IO.Get (Width);
      Ada.Integer_Text_IO.Get (Site); IO.Get (Torque);
      for I in G.Axis loop for J in G.Axis loop IO.Get (R0 (I, J)); end loop; end loop;
      for I in G.Axis loop IO.Get (T0 (I)); end loop;
      for I in G.Axis loop IO.Get (L0 (I)); end loop;
      for I in G.Axis loop for J in G.Axis loop IO.Get (R1 (I, J)); end loop; end loop;
      for I in G.Axis loop IO.Get (T1 (I)); end loop;
      for I in G.Axis loop IO.Get (L1 (I)); end loop;
      for I in G.Component loop IO.Get (Q0 (I)); end loop;
      for I in G.Component loop IO.Get (Q1 (I)); end loop;
      for I in G.Component loop IO.Get (Local0 (I)); end loop;
      for I in G.Component loop IO.Get (Local1 (I)); end loop;
      P0 := G.Anchor (R0, L0, T0); P1 := G.Anchor (R1, L1, T1);
      A := G.Multiply (Q0, Local0);
      B := (if Site /= 0 then G.Multiply (Q1, Local1) else Q1);
      declare
         Rows : constant Positive := (if Kind = 0 then 3 else 6);
         J0, J1, J : CA.Matrix (1 .. Rows, 1 .. Width);
         Pos : CA.Parameter_Array (1 .. Rows);
      begin
         for R in 1 .. Rows loop for C in 1 .. Width loop IO.Get (J0 (R, C)); end loop; end loop;
         for R in 1 .. Rows loop for C in 1 .. Width loop IO.Get (J1 (R, C)); end loop; end loop;
         if Kind = 0 then G.Connect (P0, P1, J0, J1, J, Pos);
         else G.Weld (P0, P1, A, B, Torque, J0, J1, J, Pos); end if;
         for R in 1 .. Rows loop IO.Put (Pos (R).Position, Fore => 1, Aft => 17, Exp => 3); Put (' '); end loop;
         for R in 1 .. Rows loop for C in 1 .. Width loop IO.Put (J (R, C), Fore => 1, Aft => 17, Exp => 3); Put (' '); end loop; end loop;
         New_Line;
      end;
   end loop;
end Equality_Probe;

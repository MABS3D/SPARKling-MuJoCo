with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with MJ.Types; use MJ.Types;
with MJ.NoSlip;
procedure NoSlip_Probe is
   package NS renames MJ.NoSlip;
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   N, Count, Kind, Dim : Integer;
   Settings : NS.Options;
   Result : NS.Report;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (Count);
      Settings.Iterations := Count;
      Numbers.Get (Settings.Tolerance); Numbers.Get (Settings.Scale);
      declare
         AR : NS.Matrix (1 .. N, 1 .. N);
         B, Force : NS.Vector (1 .. N);
         Rows : NS.Rows (1 .. N);
      begin
         for I in 1 .. N loop for J in 1 .. N loop Numbers.Get (AR (I, J)); end loop; end loop;
         for V of B loop Numbers.Get (V); end loop;
         for V of Force loop Numbers.Get (V); end loop;
         for R of Rows loop
            Ada.Integer_Text_IO.Get (Kind); Ada.Integer_Text_IO.Get (Dim);
            R.Form := NS.Kind'Val (Kind); R.Dimension := Dim;
            Numbers.Get (R.R); Numbers.Get (R.Bound);
            for V of R.Friction loop Numbers.Get (V); end loop;
         end loop;
         NS.Solve (AR, B, Rows, Settings, Force, Result);
         Put (Result.Outcome'Image & " " & Result.Iterations'Image & " " & Result.Restored_Blocks'Image & " ");
         Numbers.Put (Result.Improvement, Fore => 1, Aft => 17, Exp => 3);
         for V of Force loop Put (' '); Numbers.Put (V, Fore => 1, Aft => 17, Exp => 3); end loop;
         New_Line;
      end;
   end loop;
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end NoSlip_Probe;

with Ada.Command_Line;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO;
with Ada.Long_Float_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.BVH;
procedure Union_Bench is
   Size : constant Positive := Positive'Value (Ada.Command_Line.Argument (1));
   Steps : constant Positive := Positive'Value (Ada.Command_Line.Argument (2));
   A, B : MJ.BVH.Box_Array (0 .. Size - 1);
   R : MJ.BVH.Box;
   Index : Natural;
   Centers, Halves : Real := 0.0;
   Started, Finished : Time;
   procedure Put (X : Real) is
   begin Ada.Long_Float_Text_IO.Put (X, Fore => 1, Aft => 17, Exp => 3); end Put;
begin
   for I in A'Range loop
      for K in Axis loop
         A (I).Center (K) := Real ((I * 47 + K * 19) mod 1021) * 0.007 - 3.0;
         B (I).Center (K) := Real ((I * 31 + K * 17) mod 1013) * 0.007 - 3.0;
         A (I).Half (K) := Real ((I + K * 3) mod 37) * 0.003;
         B (I).Half (K) := Real ((I + K * 5) mod 41) * 0.003;
      end loop;
   end loop;
   Started := Clock;
   for Step in 1 .. Steps loop
      Index := Step mod Size;
      A (Index).Center (0) := A (Index).Center (0) + 1.0e-9;
      R := MJ.BVH.Union_Box (A (Index), B (Index));
      Centers := ((Centers + R.Center (0)) + R.Center (1)) + R.Center (2);
      Halves := ((Halves + R.Half (0)) + R.Half (1)) + R.Half (2);
   end loop;
   Finished := Clock;
   Put (Real (To_Duration (Finished - Started)));
   Ada.Text_IO.Put (" "); Put (Centers); Ada.Text_IO.Put (" "); Put (Halves);
   Ada.Text_IO.New_Line;
end Union_Bench;

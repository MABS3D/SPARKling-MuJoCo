with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Tendon_Geometry; use MJ.Tendon_Geometry;

procedure Wrap_Benchmark is
   package FIO is new Ada.Text_IO.Float_IO (Real);
   type Input is record
      Kind : Geometry_Kind;
      Radius : Real;
      Has_Side : Boolean;
      A, B, Center, Side : Vector;
      Rotation : Matrix;
   end record;
   Count, Repeats, K : Integer;
begin
   Ada.Integer_Text_IO.Get (Count);
   Ada.Integer_Text_IO.Get (Repeats);
   declare
      Cases : array (1 .. Count) of Input;
      Total : Real := 0.0;
      W : Wrap_Result;
      Started : Time;
      Elapsed : Duration;
   begin
      for C of Cases loop
         Ada.Integer_Text_IO.Get (K); C.Kind := Geometry_Kind'Val (K);
         FIO.Get (C.Radius);
         Ada.Integer_Text_IO.Get (K); C.Has_Side := K /= 0;
         for X of C.A loop FIO.Get (X); end loop;
         for X of C.B loop FIO.Get (X); end loop;
         for X of C.Center loop FIO.Get (X); end loop;
         for I in 1 .. 3 loop
            for J in 1 .. 3 loop FIO.Get (C.Rotation (I, J)); end loop;
         end loop;
         for X of C.Side loop FIO.Get (X); end loop;
      end loop;
      Started := Clock;
      for Iter in 1 .. Repeats loop
         for C of Cases loop
            W := Wrap (C.A, C.B, C.Center, C.Rotation, C.Radius, C.Kind, C.Has_Side, C.Side);
            Total := Total + (case W.Status is
               when Wrapped => W.Arc_Length, when No_Wrap => -1.0, when Numeric_Limit => -2.0);
            if W.Status = Wrapped then
               for X of W.First loop Total := Total + X; end loop;
               for X of W.Last loop Total := Total + X; end loop;
            end if;
         end loop;
      end loop;
      Elapsed := To_Duration (Clock - Started);
      FIO.Put (Real (Elapsed), Fore => 1, Aft => 17, Exp => 3);
      Put (" ");
      FIO.Put (Total, Fore => 1, Aft => 17, Exp => 3);
      New_Line;
   end;
end Wrap_Benchmark;

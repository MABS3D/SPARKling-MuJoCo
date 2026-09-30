with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Execution_Time;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Fields;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Euler;

procedure Step_Benchmark is
   use type Ada.Execution_Time.CPU_Time;
   package FIO is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   D : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Batches : constant Positive := Positive'Value (Ada.Command_Line.Argument (2));
   Steps : constant Positive := 64;
   Durations, CPU_Durations : Real_Array (0 .. Batches - 1);
   Checksum : Real := 0.0;
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with "MJB load"; end if;
   Create (M, D, Result); Check;
   MJ.Models.Free (M);
   declare
      N : constant Natural := Velocity_Count (D);
      Q, V : State_Vector (0 .. N - 1);
      Out_Q, Out_V : Real_Array (0 .. N - 1);
      Clock_Value : Real;
      Started : Ada.Real_Time.Time;
      CPU_Started : Ada.Execution_Time.CPU_Time;
   begin
      for B in Durations'Range loop
         Reset (D, Result); Check;
         for K in Q'Range loop
            Q (K) := (Real (B mod 17 - 8) * 0.003) * Real (K + 1);
            V (K) := (Real (B mod 11 - 5) * 0.005) * Real (K + 1);
         end loop;
         Set_State (D, Q, V, 0.0, Result); Check;
         Started := Clock;
         CPU_Started := Ada.Execution_Time.Clock;
         for S in 1 .. Steps loop MJ.Data.Euler.Step (D, Result); Check; end loop;
         CPU_Durations (B) := Real (To_Duration (Ada.Execution_Time.Clock - CPU_Started));
         Durations (B) := Real (To_Duration (Clock - Started));
         Get_State (D, Out_Q, Out_V, Clock_Value, Result); Check;
         for K in Out_Q'Range loop
            Checksum := (Checksum + Out_Q (K)) + Out_V (K);
         end loop;
      end loop;
   end;
   FIO.Put (Checksum, Fore => 1, Aft => 17, Exp => 3); New_Line;
   for X of Durations loop FIO.Put (X, Fore => 1, Aft => 17, Exp => 3); New_Line; end loop;
   for X of CPU_Durations loop FIO.Put (X, Fore => 1, Aft => 17, Exp => 3); New_Line; end loop;
   Free (D);
end Step_Benchmark;

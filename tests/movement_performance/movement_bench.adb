with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Euler;

--  Benchmark boundary only; no whole-simulation formal assurance claim.
procedure Movement_Bench is
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   D : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Steps : constant Positive := Positive'Value (Ada.Command_Line.Argument (2));
   Samples : constant Positive := Positive'Value (Ada.Command_Line.Argument (3));
   Warmups : constant Natural := Natural'Value (Ada.Command_Line.Argument (4));
   Timings : array (1 .. Samples) of Duration;
   Started : Ada.Real_Time.Time;

   procedure Check is
   begin
      if Result /= Success then
         raise Program_Error with Result'Image;
      end if;
   end Check;

   procedure Read_Values (A : out State_Vector) is
      Value : Real;
   begin
      for I in A'Range loop
         Numbers.Get (Value);
         A (I) := Value;
      end loop;
   end Read_Values;

   procedure Emit (Name : String; A : Real_Array) is
   begin
      Put (Name);
      for X of A loop
         Put (' ');
         Numbers.Put (X, Fore => 1, Aft => 17, Exp => 3);
      end loop;
      New_Line;
   end Emit;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then
      raise Program_Error with "load: " & Loaded.Status'Image;
   end if;
   Create (M, D, Result); Check;
   MJ.Models.Free (M);
   declare
      N : constant Natural := Velocity_Count (D);
      U : constant Natural := Control_Count (D);
      Q, V, Applied : State_Vector (0 .. Integer (N) - 1);
      Controls : State_Vector (0 .. Integer (U) - 1);
      Qout, Vout : Real_Array (Q'Range);
      Final_Time : Real;
      --  Save every trajectory's result outside the timed interval.
      type Outputs is array (1 .. Samples) of Real_Array (Q'Range);
      Positions, Velocities : Outputs;
      Times : Real_Array (1 .. Samples);
   begin
      Read_Values (Q); Read_Values (V);
      Read_Values (Controls); Read_Values (Applied);
      for Run in 1 .. Warmups + Samples loop
         Reset (D, Result); Check;
         Set_State (D, Q, V, 0.125, Result); Check;
         for I in Controls'Range loop
            Set_Control (D, I, Controls (I), Result); Check;
         end loop;
         for I in Applied'Range loop
            Set_Applied_Force (D, I, Applied (I), Result); Check;
         end loop;
         Started := Clock;
         for Step in 1 .. Steps loop
            MJ.Data.Euler.Step (D, Result); Check;
         end loop;
         declare
            Elapsed : constant Duration := To_Duration (Clock - Started);
         begin
            Get_State (D, Qout, Vout, Final_Time, Result); Check;
            if Run > Warmups then
               Timings (Run - Warmups) := Elapsed;
               Positions (Run - Warmups) := Qout;
               Velocities (Run - Warmups) := Vout;
               Times (Run - Warmups) := Final_Time;
            end if;
         end;
      end loop;
      for I in Timings'Range loop
         Emit ("sample", [Real (Timings (I))]);
         Emit ("qpos", Positions (I)); Emit ("qvel", Velocities (I));
         Emit ("time", [Times (I)]);
      end loop;
   end;
   Free (D);
end Movement_Bench;

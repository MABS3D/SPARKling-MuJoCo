with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Execution_Time;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Fields;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Advanced;
procedure Advanced_Bench is
   package A renames MJ.Data.Advanced;
   use type Ada.Execution_Time.CPU_Time;
   package FIO is new Ada.Text_IO.Float_IO (Real);
   type Engine_Access is access A.Engine;
   E : Engine_Access := new A.Engine;
   M : MJ.Models.Model;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Batches : constant Positive := Positive'Value (Ada.Command_Line.Argument (2));
   Steps : constant Positive := 128;
   Durations, CPU_Durations : Real_Array (0 .. Batches-1);
   Checksum : Real := 0.0;
   procedure Check is
   begin if Result /= Success then raise Program_Error with Result'Image; end if; end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap=>0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with "load"; end if;
   A.Create (M,E.all,Result); Check; MJ.Models.Free (M);
   declare
      Initial : constant Real_Array := A.State (E.all);
      Nq : constant Natural := A.Position_Count (E.all);
      Nv : constant Natural := A.Velocity_Count (E.all);
      Q : State_Vector (0 .. Nq-1);
      V : State_Vector (0 .. Nv-1);
      Started : Ada.Real_Time.Time;
      CPU_Started : Ada.Execution_Time.CPU_Time;
   begin
      for K in Q'Range loop Q (K) := Initial (K); end loop;
      for B in Durations'Range loop
         A.Reset (E.all,Result); Check;
         for K in V'Range loop V (K) := Real (K mod 5-2)*0.005; end loop;
         A.Set_State (E.all,Q,V,0.0,Result); Check;
         for K in 0 .. Integer (A.Control_Count (E.all))-1 loop
            A.Set_Control (E.all,K,Real (K mod 3-1)*0.01,Result); Check;
         end loop;
         Started := Clock; CPU_Started := Ada.Execution_Time.Clock;
         for S in 1 .. Steps loop A.Step (E.all,Result); Check; end loop;
         CPU_Durations (B) := Real (To_Duration (Ada.Execution_Time.Clock-CPU_Started));
         Durations (B) := Real (To_Duration (Clock-Started));
         for X of A.State (E.all) loop Checksum := Checksum+X; end loop;
      end loop;
   end;
   FIO.Put (Checksum,Fore=>1,Aft=>17,Exp=>3); New_Line;
   for X of Durations loop FIO.Put (X,Fore=>1,Aft=>17,Exp=>3); New_Line; end loop;
   for X of CPU_Durations loop FIO.Put (X,Fore=>1,Aft=>17,Exp=>3); New_Line; end loop;
   A.Free (E.all);
end Advanced_Bench;

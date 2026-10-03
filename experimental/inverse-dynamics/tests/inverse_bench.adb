with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions;
with Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Inverse;

procedure Inverse_Bench is
   use Ada.Real_Time;
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   D : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Count : constant Positive := Positive'Value (Ada.Command_Line.Argument (2));
   Cold : constant Boolean := Ada.Command_Line.Argument_Count > 2
     and then Ada.Command_Line.Argument (3) = "cold";
   Checksum : Real := 0.0;
   Start, Stop : Ada.Real_Time.Time;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with "load"; end if;
   Create (M, D, Result);
   if Result /= Success then raise Program_Error with Result'Image; end if;
   MJ.Models.Free (M);
   declare
      N : constant Natural := Velocity_Count (D);
      Q : State_Vector (0 .. Integer (Position_Count (D)) - 1);
      Vel, Acc : State_Vector (0 .. Integer (N) - 1) := [others => 0.0];
      Qout : Real_Array (Q'Range);
      Vout, Force : Real_Array (Vel'Range) := [others => 0.0];
      T : Real;
   begin
      Get_State (D, Qout, Vout, T, Result);
      for I in Q'Range loop Q (I) := Qout (I); end loop;
      for I in Vel'Range loop Vel (I) := 0.01 * Real (I mod 5); end loop;
      Set_State (D, Q, Vel, 0.0, Result);
      MJ.Data.Inverse.Evaluate (D, Acc, Force, Result);
      if Result /= Success then raise Program_Error with Result'Image; end if;
      Start := Clock;
      for I in 1 .. Count loop
         if N > 0 then Acc (0) := 0.01 * Real (I mod 100); end if;
         if Cold then
            Set_State (D, Q, Vel, 0.0, Result);
            if Result /= Success then raise Program_Error with Result'Image; end if;
            MJ.Data.Inverse.Evaluate (D, Acc, Force, Result);
         else
            MJ.Data.Inverse.Current (D, Acc, Force, Result);
         end if;
         if Result /= Success then raise Program_Error with Result'Image; end if;
         if N > 0 then Checksum := Checksum + Force (0); end if;
      end loop;
      Stop := Clock;
   end;
   Numbers.Put (Real (To_Duration (Stop - Start)), Fore => 1, Aft => 17, Exp => 3);
   Put (' '); Numbers.Put (Checksum, Fore => 1, Aft => 17, Exp => 3); New_Line;
   Free (D);
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Inverse_Bench;

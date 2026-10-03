with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Integer_Text_IO;
with Ada.Exceptions;
with Ada.Unchecked_Deallocation;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.File_IO;
with MJ.Models;
with MJ.MJB;
with MJ.Data;
with MJ.Plugin_Protocol; use MJ.Plugin_Protocol;
with Test_Engine;
procedure Plugin_Probe is
   use type MJ.Data.Status;
   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   procedure Release is new Ada.Unchecked_Deallocation (Byte_Array, Byte_Array_Access);
   M : MJ.Models.Model;
   B : Byte_Array_Access;
   Loaded : MJ.Fields.Load_Result;
   Ok : Boolean;
   E : Test_Engine.Engine;
   Result : MJ.Data.Status;
   Steps, Mask, Needed : Integer;
   X : Real;
   procedure Expect is
   begin if Result /= MJ.Data.Success then raise Program_Error with Result'Image; end if; end Expect;
   procedure Print (A : Real_Array) is
   begin
      for V of A loop Real_IO.Put (V, Fore => 1, Aft => 17, Exp => 3); Put (" "); end loop; New_Line;
   end Print;
begin
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1), B, Ok);
   if not Ok then raise Program_Error with "read"; end if;
   MJ.MJB.Parse_Raw (B.all, M, Loaded); Release (B);
   if Loaded.Status /= MJ.Types.OK then raise Program_Error with "raw load " & Loaded.Status'Image; end if;
   declare
      Config : Configurations (0 .. Integer (M.S.Nplugin) - 1);
      Q : MJ.Data.State_Vector (0 .. Integer (M.S.Nq) - 1);
      V : MJ.Data.State_Vector (0 .. Integer (M.S.Nv) - 1);
      A : MJ.Data.State_Vector (0 .. Integer (M.S.Na) - 1);
      Nu : constant Natural := M.S.Nu;
   begin
      Ada.Integer_Text_IO.Get (Steps);
      for I in Config'Range loop
         Config (I).Slot := M.Plugins.Plugin (I); Config (I).State_Count := M.Plugins.Plugin_Statenum (I);
         Ada.Integer_Text_IO.Get (Mask); Ada.Integer_Text_IO.Get (Needed);
         Config (I).Capabilities := Mask; Config (I).Need_Stage := Stage'Val (Needed);
         Config (I).Has_Advance := True;
         for K in Config (I).Parameters'Range loop Real_IO.Get (X); Config (I).Parameters (K) := X; end loop;
      end loop;
      for I in 0 .. Integer (M.S.Nactuator) - 1 loop
         if M.Actuators.Actuator_Plugin (I) >= 0 and then M.Actuators.Actuator_Actnum (I) = 1 then
            Config (M.Actuators.Actuator_Plugin (I)).Has_Act_Dot := True;
         end if;
      end loop;
      Test_Engine.Create (M, Config, E, Result); Expect;
      MJ.Models.Free (M);
      for X of Q loop Real_IO.Get (X); end loop; for X of V loop Real_IO.Get (X); end loop;
      Test_Engine.Set_State (E, Q, V, 0.0, Result); Expect;
      for I in 0 .. Nu - 1 loop Real_IO.Get (X); Test_Engine.Set_Control (E, I, X, Result); Expect; end loop;
      for X of A loop Real_IO.Get (X); end loop; Test_Engine.Set_Activation (E, A, Result); Expect;
      for I in V'Range loop Real_IO.Get (X); Test_Engine.Set_Applied_Force (E, I, X, Result); Expect; end loop;
      Test_Engine.Evaluate (E, Result); Expect; Print (Test_Engine.Acceleration (E));
      for I in 1 .. Steps loop Test_Engine.Step (E, Result); Expect; end loop;
      Print (Test_Engine.State (E)); Print (Test_Engine.Activation (E));
      Print ([for V of Test_Engine.Diagnostics (E).Sensor => Real (V)]);
      Print ([for V of Test_Engine.Diagnostics (E).Force => Real (V)]);
      for I in Config'Range loop Print ([for V of Test_Engine.Plugin_State (E, I) => Real (V)]); end loop;
      Test_Engine.Free (E, Result); Expect; Test_Engine.Free (E, Result); Expect;
   end;
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X)); Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Plugin_Probe;

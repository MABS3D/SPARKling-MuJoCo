with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Forward;
with MJ.Data.Inverse;
with MJ.Data.Constrained;
with MJ.Data.Constrained.Inverse;
with MJ.External_Forces;

procedure Inverse_Probe is
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   package C renames MJ.Data.Constrained;
   use type C.Trace;
   M : MJ.Models.Model;
   D : Simulation;
   type Engine_Access is access C.Engine;
   E : Engine_Access;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Constrained : constant Boolean := Ada.Command_Line.Argument_Count > 1
     and then Ada.Command_Line.Argument (2) = "constraints";
   Nv, Nq, Nu, Na, Nb, Cases : Natural;

   procedure Check (Expected : Status := Success) is
   begin
      if Result /= Expected then raise Program_Error with "expected " & Expected'Image & " got " & Result'Image; end if;
   end Check;
   procedure Read (A : out State_Vector) is
      X : Real;
   begin
      for V of A loop Numbers.Get (X); V := X; end loop;
   end Read;
   procedure Emit (Name : String; A : Real_Array) is
   begin
      Put (Name);
      for X of A loop Put (' '); Numbers.Put (X, Fore => 1, Aft => 17, Exp => 3); end loop;
      New_Line;
   end Emit;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with "load"; end if;
   Nv := M.S.Nv; Nq := M.S.Nq; Nu := M.S.Nu; Na := M.S.Na; Nb := M.S.Nbody;
   if Constrained then
      E := new C.Engine; C.Create (M, E.all, Result);
   else Create (M, D, Result); end if;
   Put_Line ("create " & Result'Image);
   if Result /= Success then MJ.Models.Free (M); return; end if;
   MJ.Models.Free (M);
   Ada.Integer_Text_IO.Get (Cases);
   for Sample in 1 .. Cases loop
      declare
         Q : State_Vector (3 .. Nq + 2);
         V, Acc : State_Vector (3 .. Nv + 2);
         Ctrl : State_Vector (0 .. Integer (Nu) - 1);
         Applied : State_Vector (0 .. Integer (Nv) - 1);
         Act : State_Vector (0 .. Integer (Na) - 1);
         Force, Roundtrip : Real_Array (7 .. Nv + 6) := [others => 123.0];
         Bad : State_Vector (0 .. Nv) := [others => 0.0];
         Loads : MJ.External_Forces.Wrench_Array (0 .. Nb - 1);
         X : Real;
      begin
         Read (Q); Read (V); Read (Acc); Read (Ctrl); Read (Applied); Read (Act);
         for W of Loads loop
            for A of W.Force loop Numbers.Get (X); A := X; end loop;
            for A of W.Torque loop Numbers.Get (X); A := X; end loop;
         end loop;
         if Constrained then
            C.Set_State (E.all, Q, V, 0.0, Result); Check;
            C.Set_Activation (E.all, Act, Result); Check;
            for I in Ctrl'Range loop C.Set_Control (E.all, I, Ctrl (I), Result); Check; end loop;
            for I in Applied'Range loop C.Set_Applied_Force (E.all, I, Applied (I), Result); Check; end loop;
            C.Evaluate (E.all, Result, Loads); Check;
            declare
               Before : constant Real_Array := C.Complete_State (E.all);
               T : constant C.Trace := C.Diagnostics (E.all);
               Row_Force : Real_Array (5 .. T.Nrow + 4) := [others => 321.0];
            begin
               C.Inverse.Current (E.all, Bad, Force, Row_Force, Result); Check (Invalid_Size);
               if (for some F of Force => F /= 123.0) or else (for some F of Row_Force => F /= 321.0) then
                  raise Program_Error with "invalid shape publication"; end if;
               C.Inverse.Current (E.all, Acc, Force, Row_Force, Result); Check;
               if C.Complete_State (E.all) /= Before or else C.Diagnostics (E.all) /= T then
                  raise Program_Error with "inverse changed forward data"; end if;
               Emit ("inverse", Force); Emit ("rows", Row_Force);
               declare
                  Forward_Acc : State_Vector (0 .. Integer (Nv) - 1);
               begin
                  for I in Forward_Acc'Range loop Forward_Acc (I) := T.Acceleration (I + 1); end loop;
                  C.Inverse.Current (E.all, Forward_Acc, Roundtrip, Row_Force, Result); Check;
               end;
               Emit ("roundtrip", Roundtrip);
            end;
         else
            Set_State (D, Q, V, 0.0, Result); Check;
            Set_Activation (D, Act, Result); Check;
            for I in Ctrl'Range loop Set_Control (D, I, Ctrl (I), Result); Check; end loop;
            for I in Applied'Range loop Set_Applied_Force (D, I, Applied (I), Result); Check; end loop;
            MJ.Data.Inverse.Current (D, Acc, Force, Result); Check (Stale_Results);
            if (for some F of Force => F /= 123.0) then raise Program_Error with "stale publication"; end if;
            MJ.Data.Inverse.Evaluate (D, Bad, Force, Result); Check (Invalid_Size);
            declare
               Before : constant Real_Array := Complete_State_Values (D);
               Inputs : constant Real_Array := Input_Values (D);
            begin
               MJ.Data.Inverse.Evaluate (D, Acc, Force, Result); Check;
               if Complete_State_Values (D) /= Before or else Input_Values (D) /= Inputs
                 or else Forces_Current (D) or else Actuation_Current (D)
               then raise Program_Error with "inverse ran forward or changed state"; end if;
            end;
            Emit ("inverse", Force);
            MJ.Data.Forward.Evaluate (D, Result, Loads); Check;
            declare
               Forward_Acc : State_Vector (0 .. Integer (Nv) - 1);
               Before : constant Real_Array := Complete_State_Values (D);
               Inputs : constant Real_Array := Input_Values (D);
               Old_Acc : Real_Array (0 .. Integer (Nv) - 1);
               New_Acc : Real_Array (Old_Acc'Range);
            begin
               Get_Acceleration (D, Old_Acc, Result); Check;
               for I in Forward_Acc'Range loop Forward_Acc (I) := Old_Acc (I); end loop;
               MJ.Data.Inverse.Current (D, Forward_Acc, Roundtrip, Result); Check;
               Get_Acceleration (D, New_Acc, Result); Check;
               if New_Acc /= Old_Acc or else Complete_State_Values (D) /= Before or else Input_Values (D) /= Inputs then
                  raise Program_Error with "current inverse changed forward results"; end if;
            end;
            Emit ("roundtrip", Roundtrip);
         end if;
      end;
   end loop;
   if Constrained then C.Free (E.all, Result); Check; else Free (D); end if;
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Inverse_Probe;

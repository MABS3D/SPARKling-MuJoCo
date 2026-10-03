with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.MJB;
with MJ.Models;
with MJ.Data; use MJ.Data;
with MJ.Data.Sensors;
with MJ.Data.Constrained;
with MJ.Data.Constrained.Sensors;
procedure Sensor_Probe is
   package DS renames MJ.Data.Sensors;
   package CS renames MJ.Data.Constrained.Sensors;
   package IO is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   D : Simulation;
   type Engine_Access is access MJ.Data.Constrained.Engine;
   E : Engine_Access;
   S : DS.Context;
   Load : MJ.Fields.Load_Result;
   R : Status;
   Steps, Nq, Nv : Natural;
   Constrained : constant Boolean := Ada.Command_Line.Argument_Count > 1;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Load);
   if Load.Status /= OK then raise Program_Error with "load"; end if;
   Nq := M.S.Nq; Nv := M.S.Nv;
   if Constrained then E := new MJ.Data.Constrained.Engine; CS.Create (M, E.all, S, R);
   else DS.Create (M, D, S, R); end if;
   if R /= Success then Put_Line ("CREATE " & R'Image); Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure); return; end if;
   MJ.Models.Free (M);
   declare
      Q : State_Vector (0 .. Nq - 1); V : State_Vector (0 .. Nv - 1);
      X : Real;
   begin
      declare T : Real; begin IO.Get (T); Steps := Natural (T); end;
      for A in Q'Range loop IO.Get (X); Q (A) := Tier0_Real (X); end loop;
      for A in V'Range loop IO.Get (X); V (A) := Tier0_Real (X); end loop;
      if Constrained then MJ.Data.Constrained.Set_State (E.all, Q, V, 0.0, R);
      else Set_State (D, Q, V, 0.0, R); end if;
      for Step in 0 .. Steps loop
         if Constrained then CS.Evaluate (E.all, S, R); else DS.Evaluate (D, S, R); end if;
         if R /= Success then raise Program_Error with "sample " & R'Image; end if;
         Put ("S "); for Y of DS.Values (S) loop IO.Put (Y, Aft => 17, Exp => 3); Put (' '); end loop; New_Line;
         if Step < Steps then
            if Constrained then CS.Step (E.all, S, R); else DS.Step (D, S, R); end if;
            if R /= Success then raise Program_Error with "step " & R'Image; end if;
         end if;
      end loop;
   end;
   DS.Free (S);
   if Constrained then MJ.Data.Constrained.Free (E.all, R); else MJ.Data.Free (D); end if;
exception when X : others => Put_Line (Ada.Exceptions.Exception_Information (X)); Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Sensor_Probe;

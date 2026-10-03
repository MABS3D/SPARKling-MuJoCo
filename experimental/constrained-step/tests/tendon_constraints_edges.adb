with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained;
procedure Tendon_Constraints_Edges is
   package C renames MJ.Data.Constrained;
   M : MJ.Models.Model;
   type Engine_Access is access C.Engine;
   E : Engine_Access := new C.Engine;
   Load : MJ.Fields.Load_Result;
   Result : Status;
   Mode : constant String := Ada.Command_Line.Argument (2);
   Flags : Integer;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Load);
   if Mode = "load" then
      if Load.Status /= Invalid_Parameter then
         raise Program_Error with "expected loader policy rejection";
      end if;
      MJ.Models.Free (M);
      Put_Line ("loader policy PASS"); return;
   end if;
   if Load.Status /= OK then raise Program_Error with "load"; end if;
   Flags := M.Opt.Disableflags;
   C.Create (M, E.all, Result);
   if M.Opt.Disableflags /= Flags then raise Program_Error with "flags"; end if;
   if Mode = "create" then
      if Result /= Unsupported_Feature or else C.Ready (E.all) then
         raise Program_Error with "expected explicit unsupported feature";
      end if;
      MJ.Models.Free (M); Put_Line ("creation rejection PASS"); return;
   end if;
   if Result /= Success then raise Program_Error with Result'Image; end if;
   MJ.Models.Free (M);
   declare
      Before : constant Real_Array := C.Complete_State (E.all);
      Expected : constant Status := (if Mode = "capacity" then Capacity_Exceeded else Numeric_Limit);
   begin
      for Attempt in 1 .. 2 loop
         C.Step (E.all, Result);
         if Result /= Expected or else C.Complete_State (E.all) /= Before
           or else C.Diagnostics (E.all).Valid then
            raise Program_Error with "rejection not atomic: " & Result'Image;
         end if;
      end loop;
   end;
   C.Free (E.all, Result); C.Free (E.all, Result);
   if Result /= Success or else C.Ready (E.all) then raise Program_Error with "free"; end if;
   Put_Line ("tendon rejection atomicity PASS");
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Tendon_Constraints_Edges;

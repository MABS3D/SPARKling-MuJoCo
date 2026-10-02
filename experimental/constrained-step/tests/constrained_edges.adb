with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained;
procedure Constrained_Edges is
   package C renames MJ.Data.Constrained;
   M : MJ.Models.Model;
   type Engine_Access is access C.Engine;
   E : Engine_Access := new C.Engine;
   Load : MJ.Fields.Load_Result;
   Result : Status;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Load);
   if Load.Status /= OK then raise Program_Error with "load"; end if;
   C.Create (M, E.all, Result);
   if Result /= Success then raise Program_Error with Result'Image; end if;
   declare
      Before : constant Real_Array := C.State (E.all);
   begin
      C.Step (E.all, Result);
      if Result /= Capacity_Exceeded or else C.State (E.all) /= Before
        or else C.Diagnostics (E.all).Valid then
         raise Program_Error with "capacity rejection not atomic: " & Result'Image;
      end if;
   end;
   C.Free (E.all, Result);
   C.Free (E.all, Result);
   if Result /= Success or else C.Ready (E.all) then raise Program_Error with "free"; end if;
   Put_Line ("capacity atomicity PASS");
   MJ.Models.Free (M);
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Constrained_Edges;

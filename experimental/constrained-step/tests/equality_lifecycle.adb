with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained;
procedure Equality_Lifecycle is
   package C renames MJ.Data.Constrained;
   M : MJ.Models.Model;
   type Engine_Access is access C.Engine;
   E : Engine_Access := new C.Engine;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Expected : Natural;
   procedure Check (Condition : Boolean; Message : String) is
   begin
      if not Condition then raise Program_Error with Message; end if;
   end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   Check (Loaded.Status = OK, "load");
   Expected := M.S.Neq;
   C.Create (M, E.all, Result);
   Check (Result = Success and then C.Equality_Count (E.all) = Expected, "create");
   MJ.Models.Free (M);
   declare
      Before : constant Real_Array := C.Complete_State (E.all);
   begin
      C.Set_Equality_Active (E.all, Expected, True, Result);
      Check (Result = Invalid_Index and then C.Complete_State (E.all) = Before, "invalid index atomicity");
      for I in 0 .. Expected-1 loop
         C.Set_Equality_Active (E.all, I, False, Result);
         Check (Result = Success and then not C.Equality_Active (E.all, I), "deactivate");
      end loop;
      C.Evaluate (E.all, Result);
      Check (Result = Success and then C.Diagnostics (E.all).Nrow = 0
        and then C.Complete_State (E.all) = Before, "inactive evaluation");
      for I in 0 .. Expected-1 loop
         C.Set_Equality_Active (E.all, I, True, Result);
         Check (Result = Success and then C.Equality_Active (E.all, I), "activate");
      end loop;
      C.Evaluate (E.all, Result);
      if Ada.Command_Line.Argument_Count > 1 then
         Check (Result = Capacity_Exceeded and then C.Complete_State (E.all) = Before, "capacity evaluate atomicity");
         C.Step (E.all, Result);
         Check (Result = Capacity_Exceeded and then C.Complete_State (E.all) = Before, "capacity step atomicity");
         -- Recovery must not require recreating the engine or model.
         for I in 0 .. Expected-1 loop C.Set_Equality_Active (E.all, I, False, Result); end loop;
         C.Step (E.all, Result); Check (Result = Success, "capacity recovery");
      else
         Check (Result = Success and then C.Diagnostics (E.all).Nrow > 0
           and then C.Complete_State (E.all) = Before, "active evaluation");
         C.Step (E.all, Result); Check (Result = Success, "active step");
      end if;
   end;
   C.Free (E.all, Result);
   Check (Result = Success and then C.Equality_Count (E.all) = 0, "free");
   C.Set_Equality_Active (E.all, 0, True, Result);
   Check (Result = Not_Allocated, "setter after free");
   C.Free (E.all, Result); Check (Result = Success, "double free");
   Put_Line ("equality lifecycle and atomicity PASS");
exception
   when Error : others =>
      Put_Line (Ada.Exceptions.Exception_Information (Error));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Equality_Lifecycle;

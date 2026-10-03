with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained;

procedure Constrained_Activation_Edges is
   use type Interfaces.Unsigned_8;
   package C renames MJ.Data.Constrained;
   M : MJ.Models.Model;
   type Engine_Access is access C.Engine;
   E : Engine_Access := new C.Engine;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Early : Boolean;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with "load"; end if;
   Early := M.Actuators.Actuator_Actearly (0) /= 0;
   C.Create (M, E.all, Result);
   if Result /= Success or else C.Activation_Count (E.all) /= 1 then
      raise Program_Error with "activation create: " & Result'Image;
   end if;
   MJ.Models.Free (M);
   declare
      Before : constant Real_Array := C.Complete_State (E.all);
   begin
      C.Set_Activation (E.all, State_Vector'(1 .. 0 => 0.0), Result);
      if Result /= Invalid_Size or else C.Complete_State (E.all) /= Before then
         raise Program_Error with "invalid activation size not atomic";
      end if;
   end;
   C.Set_Activation (E.all, [Max_Val], Result);
   if Result /= Success then raise Program_Error with "activation setter"; end if;
   C.Set_Control (E.all, 0, Max_Val, Result);
   if Result /= Success then raise Program_Error with "control setter"; end if;
   declare
      Before : constant Real_Array := C.Complete_State (E.all);
   begin
      C.Evaluate (E.all, Result);
      if Result /= (if Early then Numeric_Limit else Success)
        or else C.Complete_State (E.all) /= Before then
         raise Program_Error with "actearly rejection/preservation: " & Result'Image;
      end if;
      C.Step (E.all, Result);
      if Result /= Numeric_Limit or else C.Complete_State (E.all) /= Before then
         raise Program_Error with "activation transition not atomic: " & Result'Image;
      end if;
   end;
   C.Set_Activation (E.all, [0.0], Result);
   if Result /= Success then raise Program_Error with "reset activation"; end if;
   C.Set_Control (E.all, 0, 0.0, Result);
   if Result /= Success then raise Program_Error with "reset control"; end if;
   C.Step (E.all, Result);
   if Result /= Success or else C.Activation_Values (E.all) /= Real_Array'(0 => 0.0) then
      raise Program_Error with "recovery after rejection: " & Result'Image;
   end if;
   C.Free (E.all, Result);
   if Result /= Success then raise Program_Error with "free"; end if;
   Put_Line ("activation atomicity PASS");
exception
   when Error : others =>
      Put_Line (Ada.Exceptions.Exception_Information (Error));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Constrained_Activation_Edges;

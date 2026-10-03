with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with MJ.Fields;
with MJ.MJB;
with MJ.Models;
with MJ.Types; use MJ.Types;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained.Advanced;
with MJ.Data.Constrained.Advanced.Test_Export;
with MJ.Data.Advanced_Control;
with MJ.External_Forces;
procedure Constrained_Advanced_Edges is
   package A renames MJ.Data.Constrained.Advanced;
   package X renames MJ.Data.Constrained.Advanced.Test_Export;
   use type MJ.Data.Advanced_Control.Evaluation_State;
   type Engine_Access is access A.Engine;
   E : Engine_Access := new A.Engine;
   M : MJ.Models.Model;
   Load : MJ.Fields.Load_Result;
   R : Status;
   Bad_Loads : MJ.External_Forces.Wrench_Array (1 .. 1) := [others => <>];
   procedure Check is
   begin
      if R /= Success then raise Program_Error with R'Image; end if;
   end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 128), M, Load);
   if Load.Status /= OK then raise Program_Error with "load"; end if;
   A.Create (M, E.all, R); Check; MJ.Models.Free (M);
   if A.Control_Count (E.all) /= 1 or else A.Activation (E.all)'Length /= 1 then
      raise Program_Error with "edge fixture shape";
   end if;
   for Direction in 0 .. 1 loop
      declare Sign : constant Tier0_Real := (if Direction = 0 then 1.0 else -1.0); begin
         A.Reset (E.all, R); Check;
         A.Set_Control (E.all, 0, Sign, R); Check;
         A.Set_Activation (E.all, State_Vector'(3 => Sign*Max_Val), R); Check;
         A.Evaluate (E.all, R); Check;
         declare
            Before : constant Real_Array := A.State (E.all);
            Inputs : constant Real_Array := A.Inputs (E.all);
            Saved : constant MJ.Data.Advanced_Control.Evaluation_State := X.Capture (E.all);
         begin
            A.Step (E.all, R);
            if R /= Numeric_Limit or else A.State (E.all) /= Before
              or else A.Inputs (E.all) /= Inputs or else X.Capture (E.all) /= Saved then
               raise Program_Error with "stage rejection atomicity";
            end if;
            A.Evaluate (E.all, R, Bad_Loads);
            if R /= Invalid_Size or else A.State (E.all) /= Before
              or else X.Capture (E.all) /= Saved then raise Program_Error with "evaluate size atomicity"; end if;
            A.Step (E.all, R, Bad_Loads);
            if R /= Invalid_Size or else A.State (E.all) /= Before
              or else X.Capture (E.all) /= Saved then raise Program_Error with "step size atomicity"; end if;
         end;
         A.Set_Activation (E.all, State_Vector'(3 => 0.0), R); Check;
         A.Step (E.all, R); Check;
         declare Retried : constant Real_Array := A.State (E.all); begin
            A.Reset (E.all, R); Check; A.Set_Control (E.all, 0, Sign, R); Check;
            A.Step (E.all, R); Check;
            if A.State (E.all) /= Retried then raise Program_Error with "retry differs from fresh step"; end if;
         end;
      end;
   end loop;
   A.Free (E.all); A.Free (E.all);
   Put_Line ("stage rejection, size rejection, controller frame and retry PASS");
end Constrained_Advanced_Edges;

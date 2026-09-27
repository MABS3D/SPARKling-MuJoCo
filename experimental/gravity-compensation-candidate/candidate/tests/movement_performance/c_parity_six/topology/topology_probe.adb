with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Topology_Checks;

procedure Topology_Probe is
   M : MJ.Models.Model;
   Original, Stale : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Phase : Natural := 0;
   procedure Require_Success is
   begin
      if Result /= Success then raise Program_Error with "create phase" & Phase'Image & ": " & Result'Image; end if;
   end Require_Success;
begin
   for File in 1 .. Ada.Command_Line.Argument_Count loop
      MJ.MJB.Load (Ada.Command_Line.Argument (File), (Contact_Cap => 0), M, Loaded);
      if Loaded.Status /= OK then raise Program_Error with "load: " & Loaded.Status'Image; end if;
      for P in Inertia_Policy loop
         Phase := 1;
         Create (M, Original, Result, P); Require_Success;
         MJ.Data.Topology_Checks.Check (M, Original, True);
         declare
            Saved : constant Real_Array := M.Dofs.Dof_M0.all;
         begin
            M.Dofs.Dof_M0.all := [others => 1234.0];
            Phase := 2;
            Create (M, Stale, Result, P); Require_Success;
            MJ.Data.Topology_Checks.Same (Original, Stale);
            M.Dofs.Dof_M0.all := Saved;
         end;
         Free (Original); Free (Stale);
      end loop;
      --  An imported positive DOF flag alone is not enough: an independently
      --  validated body must satisfy the exact physical shortcut conditions.
      declare
         Saved : constant Byte_Array := M.Bodies.Body_Simple.all;
      begin
         M.Bodies.Body_Simple.all := [others => 0];
         Phase := 4;
         Create (M, Stale, Result); Require_Success;
         MJ.Data.Topology_Checks.General_Only (Stale);
         Free (Stale);
         M.Bodies.Body_Simple.all := Saved;
      end;
      --  Lifecycle/ownership: caller model storage is no longer needed.
      Phase := 3;
      Create (M, Original, Result); Require_Success;
      Create (M, Stale, Result); Require_Success;
      MJ.Models.Free (M);
      MJ.Data.Topology_Checks.Same (Original, Stale);
      Free (Original); Free (Stale);
      if not Is_Empty (Original) or else not Is_Empty (Stale) then
         raise Program_Error with "cache lifecycle";
      end if;
      Put_Line ("PASS " & Ada.Command_Line.Argument (File));
   end loop;
end Topology_Probe;

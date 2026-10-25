with MJ.Data.Composite_Checks;
with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data;
with MJ.Data.Forward;
with MJ.Data.Native_Mass;
with MJ.Dynamics_Derivatives;
procedure Native_Mass_Probe is
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   use type MJ.Data.Status;
   M : MJ.Models.Model;
   Loaded : MJ.Fields.Load_Result;
   D : MJ.Data.Simulation;
   Pattern : MJ.Data.Native_Mass.Pattern;
   Result : MJ.Data.Status;
   Cases : Integer;
   X : Real;
   procedure Check is
   begin
      if Result /= MJ.Data.Success then raise Program_Error with Result'Image; end if;
   end Check;
begin
   if Ada.Command_Line.Argument_Count = 1
     and then Ada.Command_Line.Argument (1) = "composite-bounds"
   then
      MJ.Data.Composite_Checks.Run;
      Put_Line ("composite_checks 5"); return;
   end if;
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with Loaded.Status'Image; end if;
   if Ada.Command_Line.Argument_Count > 1
     and then Ada.Command_Line.Argument (2) = "invalid-inputs"
   then
      declare
         type Workspace_Access is access MJ.Dynamics_Derivatives.Workspace;
         W : Workspace_Access := new MJ.Dynamics_Derivatives.Workspace;
         Empty : MJ.Models.Model;
         Saved : constant Real_Array_Access := M.Dofs.Dof_M0;
         Count : constant Natural := M.S.Nc;
         procedure Rejected (Item : in out MJ.Models.Model) is
            Flags : constant Integer := Item.Opt.Disableflags;
            Adhesion : constant Boolean := Item.Flg_Adhesion;
         begin
            MJ.Data.Native_Mass.Capture (Item, Pattern, Result);
            if Result /= MJ.Data.Invalid_Model then raise Program_Error with "capture invalid model"; end if;
            MJ.Dynamics_Derivatives.Create (Item, W.all, MJ.Dynamics_Derivatives.Smooth, Result);
            if Result /= MJ.Data.Invalid_Model or else MJ.Dynamics_Derivatives.Ready (W.all)
              or else Item.Opt.Disableflags /= Flags or else Item.Flg_Adhesion /= Adhesion
            then raise Program_Error with "workspace invalid model"; end if;
         end Rejected;
      begin
         Rejected (Empty);
         Empty.S.Nbody := 1; Empty.S.Nv := 1; Empty.S.Nq := 1;
         Rejected (Empty);
         M.Dofs.Dof_M0 := null; Rejected (M); M.Dofs.Dof_M0 := Saved;
         M.S.Nc := Count + 1; Rejected (M); M.S.Nc := Count;
         MJ.Dynamics_Derivatives.Free (W.all);
         MJ.Models.Free (M);
         Put_Line ("invalid_input_checks 4"); return;
      end;
   end if;
   if Ada.Command_Line.Argument_Count > 1
     and then Ada.Command_Line.Argument (2) = "reader-shapes"
   then
      MJ.Data.Native_Mass.Capture (M, Pattern, Result); Check;
      if MJ.Data.Native_Mass.Has_Shared_Slots (Pattern) then
         raise Program_Error with "shape fixture must have disjoint rows";
      end if;
      MJ.Data.Create (M, D, Result); Check;
      MJ.Data.Forward.Evaluate (D, Result); Check;
      declare
         Count : constant Natural := M.S.Nc;
         Empty : MJ.Data.Native_Mass.Pattern;
         Correct : Real_Array (0 .. Count - 1) := [others => 42.0];
         Shifted : Real_Array (1 .. Count) := [others => 42.0];
         Short : Real_Array (0 .. Count - 2) := [others => 42.0];
         Long : Real_Array (0 .. Count) := [others => 42.0];
         procedure Rejected (P : MJ.Data.Native_Mass.Pattern; A : in out Real_Array) is
         begin
            MJ.Data.Native_Mass.Evaluate (D, P, A, Result);
            if Result /= MJ.Data.Invalid_Size or else (for some Y of A => Y /= 0.0)
              or else not MJ.Data.Is_Ready (D) or else not MJ.Data.Mass_Current (D)
            then raise Program_Error with "reader shape rejection"; end if;
         end Rejected;
      begin
         MJ.Models.Free (M);
         Rejected (Empty, Correct);
         Rejected (Pattern, Shifted);
         Rejected (Pattern, Short);
         Rejected (Pattern, Long);
         MJ.Data.Native_Mass.Evaluate (D, Pattern, Correct, Result); Check;
         if not MJ.Data.Is_Ready (D) or else not MJ.Data.Mass_Current (D)
           or else (for all Y of Correct => Y = 0.0)
         then raise Program_Error with "reader current cache"; end if;
      end;
      MJ.Data.Free (D);
      Put_Line ("reader_shape_checks 5"); return;
   end if;
   if Ada.Command_Line.Argument_Count > 1 then
      declare
         type Workspace_Access is access MJ.Dynamics_Derivatives.Workspace;
         W : Workspace_Access := new MJ.Dynamics_Derivatives.Workspace;
      begin
         MJ.Dynamics_Derivatives.Create (M, W.all, MJ.Dynamics_Derivatives.Smooth, Result);
         Put_Line (Result'Image);
         MJ.Dynamics_Derivatives.Free (W.all); MJ.Models.Free (M); return;
      end;
   end if;
   MJ.Data.Native_Mass.Capture (M, Pattern, Result); Check;
   MJ.Data.Create (M, D, Result); Check;
   declare
      Q : MJ.Data.State_Vector (0 .. M.S.Nq - 1);
      V : MJ.Data.State_Vector (0 .. M.S.Nv - 1);
      Mass : Real_Array (0 .. M.S.Nc - 1);
   begin
      MJ.Models.Free (M);
      Ada.Integer_Text_IO.Get (Cases);
      for Sample in 1 .. Cases loop
         for Y of Q loop Numbers.Get (X); Y := X; end loop;
         for Y of V loop Numbers.Get (X); Y := X; end loop;
         MJ.Data.Set_State (D, Q, V, 0.0, Result); Check;
         MJ.Data.Forward.Evaluate (D, Result); Check;
         MJ.Data.Native_Mass.Evaluate (D, Pattern, Mass, Result); Check;
         Put ("M");
         for Value of Mass loop
            Put (' '); Numbers.Put (Value, Fore => 1, Aft => 17, Exp => 3);
         end loop;
         New_Line;
      end loop;
   end;
   MJ.Data.Free (D);
end Native_Mass_Probe;

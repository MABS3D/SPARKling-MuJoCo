with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
procedure Fluid_Lifecycle_Probe is
   M : MJ.Models.Model;
   D : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Saved : Real;
   procedure Check (Expected : Status) is
   begin
      if Result /= Expected then
         raise Program_Error with Result'Image & " expected " & Expected'Image;
      end if;
   end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with "load"; end if;
   for I in 1 .. 100 loop
      Create (M, D, Result); Check (Success);
      Create (M, D, Result); Check (Already_Allocated);
      Free (D); Free (D);
      if not Is_Empty (D) then raise Program_Error with "free"; end if;
      Saved := M.Opt.Density;
      M.Opt.Density := -1.0;
      Create (M, D, Result); Check (Invalid_Model);
      if not Is_Empty (D) then raise Program_Error with "invalid options cleanup"; end if;
      M.Opt.Density := Saved;
      -- Reject a copied ellipsoid coefficient, then recreate with the same D.
      if M.S.Ngeom > 0 then
         declare
            G : constant Natural := M.S.Ngeom-1;
            A : constant Natural := 12*G;
            Interaction : constant Real := M.Geoms.Geom_Fluid (A);
            Coefficient : constant Real := M.Geoms.Geom_Fluid (A+1);
         begin
            M.Geoms.Geom_Fluid (A) := 1.0;
            M.Geoms.Geom_Fluid (A+1) := -1.0;
            Create (M, D, Result); Check (Invalid_Model);
            if not Is_Empty (D) then raise Program_Error with "invalid element cleanup"; end if;
            M.Geoms.Geom_Fluid (A) := Interaction;
            M.Geoms.Geom_Fluid (A+1) := Coefficient;
         end;
      end if;
      Create (M, D, Result); Check (Success);
      Free (D);
   end loop;
   MJ.Models.Free (M);
   Put_Line ("PASS: 100 create/reject/recreate cycles; repeated free; invalid options and element metadata");
end Fluid_Lifecycle_Probe;

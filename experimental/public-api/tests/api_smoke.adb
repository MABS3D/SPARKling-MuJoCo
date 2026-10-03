with MJ.API.rotations;
with MJ.API.kinematics;
with MJ.API.forces;
with MJ.API.materials;
with MJ.API.actuation;
with MJ.API.constrained;
with MJ.API.quaternions;
with MJ.API.simulation;
with MJ.API.inertia;
with MJ.API.euler;
with MJ.API.mjb;
with MJ.API.forward;
with MJ.API.poses;
with MJ.API.matrices;
with MJ.API.models;
with MJ.API.runtime;
with MJ.API.vectors;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with MJ.API.Names;
with MJ.API;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.API.State;
with MJ.API.Model_Info;
procedure API_Smoke is
   M : MJ.API.Models.Model;
   Load : MJ.Fields.Load_Result;
   D : MJ.API.Runtime.Data;
   Result : MJ.API.Runtime.Data_Status;
   use type MJ.API.Runtime.Data_Status;
begin
   if MJ.API.Version /= 3014000 or else MJ.API.Version_String /= "3.14.0" then raise Program_Error; end if;
   for K in Obj_Kind loop
      declare N : constant String := MJ.API.Model_Info.Type_Name (K);
      begin
         if N'Length > 0 and then MJ.API.Model_Info.Name_Type (N) /= K then raise Program_Error; end if;
      end;
   end loop;
   if Ada.Command_Line.Argument_Count > 0 then
      MJ.API.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Load);
      if Load.Status /= OK then raise Program_Error with "load"; end if;
      MJ.API.Runtime.Make_Data (M, D, Result);
      if Result /= MJ.API.Simulation.Success then raise Program_Error with Result'Image; end if;
      MJ.API.Models.Free (M);
      MJ.API.Runtime.Forward (D, Result);
      if Result /= MJ.API.Simulation.Success then raise Program_Error with Result'Image; end if;
      for I in 1 .. 100 loop
         MJ.API.Runtime.Step (D, Result);
         if Result /= MJ.API.Simulation.Success then raise Program_Error with Result'Image; end if;
      end loop;
      if MJ.API.Simulation.Time (D) <= 0.0 then raise Program_Error; end if;
      MJ.API.Runtime.Reset_Data (D, Result);
      if Result /= MJ.API.Simulation.Success or else not MJ.API.Simulation.At_Reset_State (D) then raise Program_Error; end if;
      MJ.API.Runtime.Delete_Data (D);
      MJ.API.Runtime.Delete_Data (D);
   end if;
   Put_Line ("API smoke PASS");
end API_Smoke;

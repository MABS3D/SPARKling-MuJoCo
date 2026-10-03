with Ada.Command_Line;
with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.MJB;
with MJ.Models;
with MJ.Data;
with MJ.Data.Kinematics;
with MJ.Data.Rays;
with MJ.Rays; use MJ.Rays;
with MJ.Ray_Kernels; use MJ.Ray_Kernels;
procedure Ray_Edges is
   use type MJ.Data.Status;
   type Scene_Access is access Scene;
   S : Scene_Access:=new Scene;
   M : MJ.Models.Model;
   D : MJ.Data.Simulation;
   L : MJ.Fields.Load_Result; DS : MJ.Data.Status; RS : Status; H : Result;
begin
   Cast (S.all,Zero,[0.0,0.0,1.0],H,RS);
   if RS/=Not_Ready then raise Program_Error; end if;
   MJ.MJB.Load (Ada.Command_Line.Argument (1),(Contact_Cap=>0),M,L);
   Initialize (M,S.all,RS);
   if RS/=Success then raise Program_Error with RS'Image; end if;
   Cast (S.all,Zero,[0.0,0.0,1.0],H,RS);
   if RS/=Not_Ready then raise Program_Error with "unposed scene"; end if;
   Initialize (M,S.all,RS);
   if RS/=Already_Ready then raise Program_Error; end if;
   MJ.Data.Create (M,D,DS); MJ.Models.Free (M);
   MJ.Data.Rays.Synchronize (D,S.all,DS);
   if DS/=MJ.Data.Stale_Results then raise Program_Error with "stale data"; end if;
   MJ.Data.Kinematics.Update (D,DS); MJ.Data.Rays.Synchronize (D,S.all,DS);
   if DS/=MJ.Data.Success then raise Program_Error; end if;
   Cast (S.all,Zero,Zero,H,RS);
   if RS/=Invalid_Ray or else H/=Result'(others=><>) then raise Program_Error; end if;
   declare
      Rays : Directions (3 .. 4):=[[0.0,0.0,1.0],Zero];
      Hits : Results (7 .. 8);
   begin
      Cast_Many (S.all,Zero,Rays,Hits,RS);
      if RS/=Success or else Hits (8)/=Result'(others=><>) then raise Program_Error with "batch zero ray"; end if;
      Rays (4):=[3.0e10,0.0,0.0];
      Cast_Many (S.all,Zero,Rays,Hits,RS);
      if RS/=Invalid_Ray or else (for some X of Hits => X/=Result'(others=><>)) then raise Program_Error; end if;
   end;
   MJ.Data.Free (D); Clear (S.all); Clear (S.all);
   if Ready (S.all) then raise Program_Error; end if;
   Ada.Text_IO.Put_Line ("lifecycle, stale poses, invalid ray, atomic batch: PASS");
end Ray_Edges;

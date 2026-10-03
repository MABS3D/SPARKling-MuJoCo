with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data;
with MJ.Data.Kinematics;
with MJ.Data.Rays;
with MJ.Rays;
with MJ.Ray_Kernels; use MJ.Ray_Kernels;
with MJ.Ray_Geometry;
procedure Ray_Probe is
   use type MJ.Data.Status;
   use type MJ.Rays.Status;
   package IO renames Ada.Text_IO;
   package FIO is new IO.Float_IO (Real);
   package IIO is new IO.Integer_IO (Integer);
   M : MJ.Models.Model;
   D : MJ.Data.Simulation;
   type Scene_Access is access MJ.Rays.Scene;
   S : Scene_Access := new MJ.Rays.Scene;
   Load : MJ.Fields.Load_Result;
   DS : MJ.Data.Status;
   RS : MJ.Rays.Status;
   H : MJ.Rays.Result;
   Opt : MJ.Rays.Options;
   Count, Frames, Repeats, Static, Group_Filter, K : Integer;
   P,V,Size,Position : Vector;
   R : Matrix;
   GH : MJ.Ray_Geometry.Hit;
   function Int return Integer is X : Integer; begin IIO.Get (X); return X; end;
   function Num return Real is X : Real; begin FIO.Get (X); return X; end;
   function Vec return Vector is X : Vector; begin for I in Axis loop X (I):=Num; end loop; return X; end;
   procedure Print (State : String; Id : Integer; Dist : Real; Normal : Vector) is
   begin
      IO.Put (State & " " & Id'Image & " "); FIO.Put (Dist,Fore=>1,Aft=>17,Exp=>3);
      for X of Normal loop IO.Put (" "); FIO.Put (X,Fore=>1,Aft=>17,Exp=>3); end loop;
      IO.New_Line;
   end Print;
begin
   if Ada.Command_Line.Argument (1)="primitive" then
      Count:=Int;
      for Test in 1 .. Count loop
         K:=Int; Position:=Vec;
         for I in Axis loop for J in Axis loop R (I,J):=Num; end loop; end loop;
         Size:=Vec; P:=Vec; V:=Vec;
         GH:=MJ.Ray_Geometry.Intersect (MJ.Ray_Geometry.Kind'Val (K),Position,R,Size,P,V);
         Print ("SUCCESS",K,GH.Distance,GH.Normal);
      end loop;
      return;
   end if;
   MJ.MJB.Load (Ada.Command_Line.Argument (1),(Contact_Cap=>0),M,Load);
   if Load.Status/=OK then raise Program_Error with "load " & Load.Status'Image; end if;
   MJ.Rays.Initialize (M,S.all,RS);
   if RS/=MJ.Rays.Success then IO.Put_Line ("create ray " & RS'Image); Ada.Command_Line.Set_Exit_Status (1); return; end if;
   MJ.Data.Create (M,D,DS);
   if DS/=MJ.Data.Success then IO.Put_Line ("create data " & DS'Image); Ada.Command_Line.Set_Exit_Status (1); return; end if;
   MJ.Models.Free (M);
   Frames:=Int; Count:=Int; Repeats:=Int;
   declare
      Q : MJ.Data.State_Vector (0 .. MJ.Data.Position_Count (D)-1);
      QV : MJ.Data.State_Vector (0 .. MJ.Data.Velocity_Count (D)-1):=[others=>0.0];
   begin
      for Frame in 1 .. Frames loop
         for I in Q'Range loop Q (I):=Num; end loop;
         MJ.Data.Set_State (D,Q,QV,0.0,DS);
         MJ.Data.Kinematics.Update (D,DS);
         if DS/=MJ.Data.Success then raise Program_Error with "kinematics " & DS'Image; end if;
         MJ.Data.Rays.Synchronize (D,S.all,DS);
         if DS/=MJ.Data.Success then raise Program_Error with "sync " & DS'Image; end if;
         for Query in 1 .. Count loop
            P:=Vec; V:=Vec; Static:=Int; Opt.Excluded_Body:=Int; Group_Filter:=Int;
            Opt.Include_Static:=Static/=0; Opt.Filter_Groups:=Group_Filter/=0;
            for I in Opt.Mask'Range loop Opt.Mask (I):=Int/=0; end loop;
            for Repeat in 1 .. Repeats loop MJ.Rays.Cast (S.all,P,V,H,RS,Opt); end loop;
            Print (RS'Image,H.Geometry_Id,H.Distance,H.Normal);
         end loop;
      end loop;
   end;
   MJ.Data.Free (D); MJ.Rays.Clear (S.all);
exception
   when X : others => IO.Put_Line (Ada.Exceptions.Exception_Information (X)); Ada.Command_Line.Set_Exit_Status (1);
end Ray_Probe;

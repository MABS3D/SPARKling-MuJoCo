with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data;
with MJ.Data.Kinematics;
with MJ.Data.Rays;
with MJ.Rays;
with MJ.Ray_Kernels; use MJ.Ray_Kernels;
procedure Ray_Bench is
   use type MJ.Data.Status;
   use type MJ.Rays.Status;
   package FIO is new Ada.Text_IO.Float_IO (Real);
   package IIO is new Ada.Text_IO.Integer_IO (Integer);
   type Query is record P,V : Vector; Filter : MJ.Rays.Options; end record;
   Inputs : array (0 .. 255) of Query;
   type Scene_Access is access MJ.Rays.Scene;
   S : Scene_Access:=new MJ.Rays.Scene;
   M : MJ.Models.Model; D : MJ.Data.Simulation;
   L : MJ.Fields.Load_Result; DS : MJ.Data.Status; RS : MJ.Rays.Status;
   H : MJ.Rays.Result; N,Repeats,X : Integer;
   Start : Time; Seconds,Checksum : Real:=0.0;
   function Int return Integer is V : Integer; begin IIO.Get (V); return V; end;
   function Num return Real is V : Real; begin FIO.Get (V); return V; end;
   function Vec return Vector is V : Vector; begin for I in Axis loop V (I):=Num; end loop; return V; end;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1),(Contact_Cap=>0),M,L);
   if L.Status/=OK then raise Program_Error with "model load"; end if;
   MJ.Rays.Initialize (M,S.all,RS); if RS/=MJ.Rays.Success then raise Program_Error with RS'Image; end if;
   MJ.Data.Create (M,D,DS); MJ.Models.Free (M);
   if DS/=MJ.Data.Success then raise Program_Error with DS'Image; end if;
   MJ.Data.Kinematics.Update (D,DS); MJ.Data.Rays.Synchronize (D,S.all,DS);
   if DS/=MJ.Data.Success then raise Program_Error with DS'Image; end if;
   N:=Int; Repeats:=Int;
   for I in 0 .. N-1 loop
      Inputs (I).P:=Vec; Inputs (I).V:=Vec;
      X:=Int; Inputs (I).Filter.Include_Static:=X/=0;
      Inputs (I).Filter.Excluded_Body:=Int; X:=Int; Inputs (I).Filter.Filter_Groups:=X/=0;
      for J in 0 .. 5 loop X:=Int; Inputs (I).Filter.Mask (J):=X/=0; end loop;
   end loop;
   Start:=Clock;
   for Repeat in 1 .. Repeats loop
      for I in 0 .. N-1 loop
         MJ.Rays.Cast (S.all,Inputs (I).P,Inputs (I).V,H,RS,Inputs (I).Filter);
         if RS/=MJ.Rays.Success then raise Program_Error with RS'Image; end if;
         Checksum:=Checksum+(H.Distance+Real (H.Geometry_Id));
      end loop;
   end loop;
   Seconds:=Real (To_Duration (Clock-Start));
   FIO.Put (Seconds,Fore=>1,Aft=>17,Exp=>3); Ada.Text_IO.Put (" ");
   FIO.Put (Checksum,Fore=>1,Aft=>17,Exp=>3); Ada.Text_IO.New_Line;
   MJ.Data.Free (D); MJ.Rays.Clear (S.all);
end Ray_Bench;

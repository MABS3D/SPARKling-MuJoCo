with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Exceptions;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.File_IO;
with MJ.Data; use MJ.Data;
with MJ.Data.Kinematics;
with MJ.Data.Flex_Adapter;
with MJ.Flex_State;
with MJ.Rigid_Geometry;
procedure Flex_State_Probe is
   use type MJ.Flex_State.Status;
   use type MJ.Rigid_Geometry.Vec;
   package F renames MJ.Flex_State;
   package R renames MJ.Rigid_Geometry;
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   M, Core : MJ.Models.Model;
   Bytes : Byte_Array_Access;
   Read_OK : Boolean;
   Load : MJ.Fields.Load_Result;
   type State_Access is access F.State;
   S : State_Access := new F.State;
   D : Simulation;
   Result : F.Status;
   Core_Result : Status;
   Count : Integer;
   Capacity : constant Natural := (if Ada.Command_Line.Argument_Count >= 3 then
     Natural'Value (Ada.Command_Line.Argument (3)) else F.Max_Contacts);
   Contacts : F.Contact_List (Capacity);
   procedure Check is
   begin
      if Core_Result /= Success then raise Program_Error with Core_Result'Image; end if;
   end Check;
   procedure Number (X : Real) is
   begin Put (' '); Numbers.Put (X,Fore=>1,Aft=>17,Exp=>3); end Number;
   procedure Integer_Value (X : Integer) is
   begin Put (' '); Put (Integer'Image (X)); end Integer_Value;
begin
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1),Bytes,Read_OK);
   if not Read_OK then raise Program_Error with "file"; end if;
   MJ.MJB.Parse_Raw (Bytes.all,M,Load); Free_Byte (Bytes);
   if Load.Status /= OK then raise Program_Error with "raw model"; end if;
   if Ada.Command_Line.Argument_Count >= 4 then
      declare Mode : constant String := Ada.Command_Line.Argument (4); begin
         if Mode="interp" then M.Flexes.Flex_Interp (0) := 1;
         elsif Mode="vertexbody" then M.Flexes.Flex_Vertbodyid (0) := M.S.Nbody;
         elsif Mode="element" then M.Flexes.Flex_Elem (0) := M.Flexes.Flex_Vertnum (0);
         elsif Mode="radius" then M.Flexes.Flex_Radius (0) := -1.0;
         elsif Mode="dimension" then M.Flexes.Flex_Dim (0) := 4;
         else raise Program_Error with "unknown rejection mode"; end if;
      end;
   end if;
   F.Create (M,S.all,Result);
   if Result /= F.Success then Put_Line ("create " & Result'Image); MJ.Models.Free (M); return; end if;
   F.Create (M,S.all,Result);
   if Result /= F.Already_Allocated then raise Program_Error with "double create"; end if;
   MJ.Models.Free (M);
   F.Detect (S.all,Contacts,Result);
   if Result /= F.Stale_State or Contacts.Length /= 0 then raise Program_Error with "stale"; end if;
   MJ.MJB.Load (Ada.Command_Line.Argument (2),(Contact_Cap=>0),Core,Load);
   if Load.Status /= OK then raise Program_Error with "core model"; end if;
   MJ.Data.Create (Core,D,Core_Result); Check;
   declare
      Q : State_Vector (0 .. Core.S.Nq-1);
      V : State_Vector (0 .. Core.S.Nv-1);
      X : Real;
   begin
      MJ.Models.Free (Core);
      Ada.Integer_Text_IO.Get (Count);
      for I in 1 .. Count loop
         for J in Q'Range loop Numbers.Get (X); Q (J) := X; end loop;
         for J in V'Range loop Numbers.Get (X); V (J) := X; end loop;
         MJ.Data.Set_State (D,Q,V,0.0,Core_Result); Check;
         MJ.Data.Kinematics.Update (D,Core_Result); Check;
         MJ.Data.Flex_Adapter.Update (D,S.all,Result);
         if Result /= F.Success then raise Program_Error with "update " & Result'Image; end if;
         Put_Line ("sample");
         for Flex in 0 .. F.Flex_Count (S.all)-1 loop
            for Vertex in 0 .. F.Vertex_Count (S.all,Flex)-1 loop
               Put ("v"); Integer_Value (Flex); Integer_Value (Vertex);
               for X of F.Position (S.all,Flex,Vertex) loop Number (X); end loop; New_Line;
            end loop;
         end loop;
         F.Detect (S.all,Contacts,Result);
         Put_Line ("detect " & Result'Image & " " & Natural'Image (Contacts.Length));
         for J in 1 .. Contacts.Length loop
            declare C : F.Contact renames Contacts.Items (J); begin
               Put ("c"); Integer_Value (C.Geom); Integer_Value (C.Flex_First); Integer_Value (C.Flex_Second);
               Integer_Value (C.Elem_First); Integer_Value (C.Elem_Second);
               Integer_Value (C.Vert_First); Integer_Value (C.Vert_Second);
               Number (C.Geometry.Distance);
               for X of C.Geometry.Position loop Number (X); end loop;
               for X of C.Geometry.Normal loop Number (X); end loop;
               Integer_Value (C.Parameters.Dim);
               for X of C.Parameters.Ref loop Number (X); end loop;
               for X of C.Parameters.Imp loop Number (X); end loop;
               for X of C.Parameters.Fri loop Number (X); end loop;
               Number (C.Parameters.Include_Margin); Number (C.Parameters.Detection_Margin); New_Line;
            end;
         end loop;
         declare
            Previous : constant R.Vec := F.Position (S.all,0,0);
            Invalid : R.Pose_Array (1 .. 0);
         begin
            F.Update (S.all,Invalid,Result);
            if Result /= F.Invalid_Input or F.Current (S.all)
              or F.Position (S.all,0,0) /= Previous then raise Program_Error with "update atomicity"; end if;
            F.Detect (S.all,Contacts,Result);
            if Result /= F.Stale_State or Contacts.Length /= 0 then raise Program_Error with "stale after reject"; end if;
         end;
         Put_Line ("end");
      end loop;
   end;
   F.Free (S.all); F.Free (S.all); MJ.Data.Free (D);
   if F.Ready (S.all) or F.Current (S.all) then raise Program_Error with "free"; end if;
exception
   when E : others => Put_Line (Ada.Exceptions.Exception_Information (E));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Flex_State_Probe;

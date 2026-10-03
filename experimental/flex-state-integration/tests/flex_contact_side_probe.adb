with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.File_IO;
with MJ.Rigid_Geometry;
with MJ.Flex_State;
with MJ.Flex_State.Response_Contacts;
procedure Flex_Contact_Side_Probe is
   package F renames MJ.Flex_State;
   package R renames MJ.Rigid_Geometry;
   package RC renames F.Response_Contacts;
   use type F.Status;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   package UIO is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   M : MJ.Models.Model;
   Bytes : Byte_Array_Access;
   OK : Boolean;
   Load : MJ.Fields.Load_Result;
   type State_Access is access F.State;
   S : State_Access := new F.State;
   Value : RC.SW.Endpoint;
   Result : F.Status;
   Cases, Flex, Negative : Natural;
   Element, Vertex, Opposite : Integer;
   Point : R.Vec := [others => 0.0];
   X : Real;
begin
   RC.Side (S.all,0,-1,0,-1,Point,False,Value,Result);
   if Result /= F.Not_Allocated or Value.Count /= 0 then raise Program_Error with "unallocated"; end if;
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1),Bytes,OK);
   if not OK then raise Program_Error with "file"; end if;
   MJ.MJB.Parse_Raw (Bytes.all,M,Load); Free_Byte (Bytes);
   if Load.Status /= MJ.Types.OK then raise Program_Error with "parse"; end if;
   F.Create (M,S.all,Result); MJ.Models.Free (M);
   if Result /= F.Success then raise Program_Error with "create" & Result'Image; end if;
   RC.Side (S.all,0,-1,0,-1,Point,False,Value,Result);
   if Result /= F.Stale_State or Value.Count /= 0 then raise Program_Error with "stale"; end if;
   declare Poses : R.Pose_Array (0 .. F.Body_Count (S.all)-1); begin
      for B in Poses'Range loop
         for K in R.Axis loop RIO.Get (X); Poses (B).Position (K) := X; end loop;
         for K in R.Matrix'Range loop RIO.Get (X); Poses (B).Rotation (K) := X; end loop;
      end loop;
      F.Update (S.all,Poses,Result);
      if Result /= F.Success then raise Program_Error with "update" & Result'Image; end if;
   end;
   for Flex in 0 .. F.Flex_Count (S.all)-1 loop
      for V in 0 .. F.Vertex_Count (S.all,Flex)-1 loop
         Put ("vertex"); Put (Natural'Image (Flex)); Put (Natural'Image (V));
         for X of F.Position (S.all,Flex,V) loop Put (' '); UIO.Put (Bits (X),Width=>0); end loop;
         New_Line;
      end loop;
   end loop;
   Ada.Integer_Text_IO.Get (Cases);
   for I in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Flex); Ada.Integer_Text_IO.Get (Element);
      Ada.Integer_Text_IO.Get (Vertex); Ada.Integer_Text_IO.Get (Opposite);
      Ada.Integer_Text_IO.Get (Negative);
      for K in R.Axis loop RIO.Get (X); Point (K) := X; end loop;
      Value := (Count=>729, Items=>[others=>(Body_Id=>Natural'Last,Weight=>7.0)]);
      RC.Side (S.all,Flex,Element,Vertex,Opposite,Point,Negative/=0,Value,Result);
      Put_Line ("case " & Result'Image);
      Put ("bodies");
      for K in 0 .. Integer (Value.Count)-1 loop
         Put (' '); Ada.Integer_Text_IO.Put (Value.Items (K).Body_Id,Width=>0);
      end loop;
      New_Line; Put ("bits");
      for K in 0 .. Integer (Value.Count)-1 loop
         Put (' '); UIO.Put (Bits (Value.Items (K).Weight),Width=>0);
      end loop;
      New_Line;
   end loop;
   declare Invalid : R.Pose_Array (1 .. 0); begin
      F.Update (S.all,Invalid,Result);
      RC.Side (S.all,0,-1,0,-1,Point,False,Value,Result);
      if Result /= F.Stale_State or Value.Count /= 0 then raise Program_Error with "invalidated"; end if;
   end;
   F.Free (S.all);
   RC.Side (S.all,0,-1,0,-1,Point,False,Value,Result);
   if Result /= F.Not_Allocated or Value.Count /= 0 then raise Program_Error with "freed"; end if;
exception
   when others => F.Free (S.all); MJ.Models.Free (M); raise;
end Flex_Contact_Side_Probe;

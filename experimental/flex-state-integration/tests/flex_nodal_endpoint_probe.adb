with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.File_IO;
with MJ.Flex_State;
with MJ.Flex_State.Nodal_Contacts;
procedure Flex_Nodal_Endpoint_Probe is
   package F renames MJ.Flex_State;
   package N renames F.Nodal_Contacts;
   use type F.Status;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   Bytes : Byte_Array_Access;
   OK : Boolean;
   Load : MJ.Fields.Load_Result;
   type State_Access is access F.State;
   S : State_Access := new F.State;
   Ids : N.Vertex_Ids := [others => 0];
   Coeff : N.NW.Vertex_Weights := [others => 0.0];
   E : N.NW.Endpoint;
   Result : F.Status;
   Cases, Flex, Count : Natural;
begin
   N.Weights (S.all, 0, Ids, Coeff, 0, E, Result);
   if Result /= F.Not_Allocated or E.Count /= 0 then
      raise Program_Error with "unallocated endpoint";
   end if;
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1), Bytes, OK);
   if not OK then raise Program_Error with "file"; end if;
   MJ.MJB.Parse_Raw (Bytes.all, M, Load); Free_Byte (Bytes);
   if Load.Status /= MJ.Types.OK then raise Program_Error with "parse"; end if;
   F.Create (M, S.all, Result);
   MJ.Models.Free (M);
   if Result /= F.Success then raise Program_Error with "create " & Result'Image; end if;
   Ada.Integer_Text_IO.Get (Cases);
   for I in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Flex); Ada.Integer_Text_IO.Get (Count);
      for V of Ids loop Ada.Integer_Text_IO.Get (V); end loop;
      for W of Coeff loop RIO.Get (W); end loop;
      E := (Count => 27, Items => [others => (Body_Id => Natural'Last, Weight => 7.0)]);
      N.Weights (S.all, Flex, Ids, Coeff, Count, E, Result);
      Put_Line ("case " & Result'Image);
      Put ("bodies");
      for J in 0 .. Integer (E.Count) - 1 loop
         Put (' '); Ada.Integer_Text_IO.Put (E.Items (J).Body_Id, Width => 0);
      end loop;
      New_Line; Put ("weights");
      for J in 0 .. Integer (E.Count) - 1 loop
         Put (' '); RIO.Put (E.Items (J).Weight, Fore => 1, Aft => 17, Exp => 3);
      end loop;
      New_Line;
   end loop;
   F.Free (S.all);
   N.Weights (S.all, 0, Ids, Coeff, 0, E, Result);
   if Result /= F.Not_Allocated or E.Count /= 0 then
      raise Program_Error with "freed endpoint";
   end if;
exception
   when others => F.Free (S.all); MJ.Models.Free (M); raise;
end Flex_Nodal_Endpoint_Probe;

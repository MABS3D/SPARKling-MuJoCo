with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.API;
with MJ.API.State;
with MJ.API.Model_Info;
procedure API_Probe is
   package S renames MJ.API.State;
   use type S.Signature;
   Op, Srcmask, Dstmask, Ns, Nd : Integer;
   L : S.Layout;
   Result : MJ.API.Status;
begin
   loop
      exit when End_Of_File;
      Ada.Integer_Text_IO.Get (Op);
      if Op = 9 then
         declare N, J, C, Solver, Noslip : Integer; Sizes : MJ.Models.Sizes;
         begin
            Ada.Integer_Text_IO.Get (N); Sizes.Nv := N;
            Ada.Integer_Text_IO.Get (J); Ada.Integer_Text_IO.Get (C);
            Ada.Integer_Text_IO.Get (Solver); Ada.Integer_Text_IO.Get (Noslip);
            Put_Line (Boolean'Image (MJ.API.Model_Info.Is_Sparse (Sizes, J)) & " " &
                      Boolean'Image (MJ.API.Model_Info.Is_Pyramidal (C)) & " " &
                      Boolean'Image (MJ.API.Model_Info.Is_Dual (Solver, Noslip)));
         end;
      elsif Op = 8 then
         declare V : Integer;
         begin
            Ada.Integer_Text_IO.Get (V);
            declare Name : constant String := MJ.API.Model_Info.Type_Name (Obj_Kind'Enum_Val (V));
            begin Put_Line ("TYPE " & (if Name'Length = 0 then "(none)" else Name)); end;
         end;
      else
         Ada.Integer_Text_IO.Get (Srcmask); Ada.Integer_Text_IO.Get (Dstmask);
         for E in S.Element loop Ada.Integer_Text_IO.Get (L (E)); end loop;
         Ada.Integer_Text_IO.Get (Ns); Ada.Integer_Text_IO.Get (Nd);
         declare Source : Real_Array (0 .. Ns - 1); Target : Real_Array (0 .. Nd - 1);
         begin
            for X of Source loop Ada.Long_Float_Text_IO.Get (X); end loop;
            for X of Target loop Ada.Long_Float_Text_IO.Get (X); end loop;
            case Op is
               when 1 => S.Extract_State (L, Source, S.Signature (Srcmask), Target, S.Signature (Dstmask), Result);
               when 2 => S.Set_State (L, Target, S.Signature (Srcmask), Source, Result);
               when 3 => S.Copy_State (L, Source, Target, S.Signature (Srcmask), Result);
               when 4 => S.Get_State (L, Source, S.Signature (Dstmask), Target, Result);
               when others => raise Program_Error;
            end case;
            Put (MJ.API.Status'Image (Result));
            for X of Target loop
               Put (" "); Ada.Long_Float_Text_IO.Put (X, Fore => 0, Aft => 17, Exp => 3);
            end loop;
            New_Line;
         end;
      end if;
   end loop;
end API_Probe;

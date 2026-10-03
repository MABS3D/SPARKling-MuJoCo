with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Strings; with Ada.Strings.Fixed;
with MJ.API.Names;
with MJ.Models;
with MJ.MJB;
with MJ.Fields;
with MJ.Types; use MJ.Types;
procedure API_Names_Probe is
   M : MJ.Models.Model;
   Loaded : MJ.Fields.Load_Result;
   Op, Kind : Integer;
   Hex : constant String := "0123456789abcdef";
   function Digit (C : Character) return Natural is
     (if C in '0' .. '9' then Character'Pos (C) - Character'Pos ('0')
      else Character'Pos (C) - Character'Pos ('a') + 10);
   function Decode (S : String) return String is
      R : String (1 .. S'Length / 2);
   begin
      for I in R'Range loop
         R (I) := Character'Val (16 * Digit (S (S'First + 2 * I - 2)) + Digit (S (S'First + 2 * I - 1)));
      end loop;
      return R;
   end Decode;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with "load"; end if;
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (Op); Ada.Integer_Text_IO.Get (Kind);
      declare
         Arg : constant String := Ada.Strings.Fixed.Trim (Get_Line, Ada.Strings.Both);
         K : constant Obj_Kind := Obj_Kind'Enum_Val (Kind);
      begin
         if Op = 1 then
            Put_Line (Integer'Image (MJ.API.Names.Name2id (M, K, Decode (Arg))));
         else
            declare N : constant String := MJ.API.Names.Id2name (M, K, Integer'Value (Arg));
            begin
               if N'Length = 0 then Put ('-'); end if;
               for C of N loop Put (Hex (Character'Pos (C) / 16 + 1)); Put (Hex (Character'Pos (C) mod 16 + 1)); end loop;
               New_Line;
            end;
         end if;
      end;
   end loop;
   MJ.Models.Free (M);
end API_Names_Probe;

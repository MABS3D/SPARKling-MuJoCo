with Ada.Text_IO; use Ada.Text_IO;
procedure Null_Array_Witness is
   type Values is array (Natural range <>) of Long_Float;
   Canonical : Values (0 .. -1);
   Other : Values (0 .. -2);
begin
   pragma Assert (Canonical'First = 0 and then Other'First = 0);
   pragma Assert (Canonical'Length = 0 and then Other'Length = 0);
   pragma Assert (Canonical'Last = -1 and then Other'Last = -2);
   Put_Line ("Both arrays: First=0, Length=0; Last differs (-1 versus -2).");
end Null_Array_Witness;

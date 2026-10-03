with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Equality_Flex;
procedure Flex_Probe is
   package IO is new Ada.Text_IO.Float_IO (Real);
   package Int_IO is new Ada.Text_IO.Integer_IO (Integer);
   function Read_Real return Real is
      Value : Real;
   begin
      IO.Get (Value); return Value;
   end Read_Real;
   Kind : Integer;
   Value : Real;
   Length, Rest : Nonneg_Tier0;
   J0, J1, J2, D0, D1, D2 : Tier1_Real;
begin
   while not Ada.Text_IO.End_Of_File loop
      Int_IO.Get (Kind);
      if Kind = 0 then
         Length := Read_Real; Rest := Read_Real;
         Value := MJ.Equality_Flex.Edge_Residual (Length, Rest);
      else
         J0 := Read_Real; J1 := Read_Real; J2 := Read_Real;
         D0 := Read_Real; D1 := Read_Real; D2 := Read_Real;
         Value := MJ.Equality_Flex.Edge_Projection (J0, J1, J2, D0, D1, D2);
      end if;
      IO.Put (Value, Fore => 1, Aft => 17, Exp => 3);
      Ada.Text_IO.New_Line;
   end loop;
end Flex_Probe;

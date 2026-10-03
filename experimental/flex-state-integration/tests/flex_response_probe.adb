with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Flex_Response_Kernels;
procedure Flex_Response_Probe is
   package K renames MJ.Flex_Response_Kernels;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   package UIO is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   Terms : K.Contributions;
   Value : K.Accumulator;
   Cases, Kind, Count, Seed, Present : Natural;
   X, Y, Z, A, B, C, Projected : Real;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Case_Id in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Kind);
      if Kind = 0 then
         Ada.Integer_Text_IO.Get (Count); Ada.Integer_Text_IO.Get (Seed);
         Terms := [others => <>];
         for I in 0 .. Integer (Count) - 1 loop
            Ada.Integer_Text_IO.Get (Present);
            RIO.Get (X); RIO.Get (Y);
            Terms (I) := (Present /= 0, X, Y);
         end loop;
         K.Combine (Terms, Count, Seed /= 0, Value);
         Ada.Integer_Text_IO.Put (Boolean'Pos (Value.Present), Width => 0);
         Put (' '); UIO.Put (Bits (Value.Value), Width => 0); New_Line;
      else
         RIO.Get (X); RIO.Get (Y); RIO.Get (Z);
         RIO.Get (A); RIO.Get (B); RIO.Get (C);
         Projected := K.Project (X, Y, Z, A, B, C);
         Put ("1 "); UIO.Put (Bits (Projected), Width => 0); New_Line;
      end if;
   end loop;
end Flex_Response_Probe;

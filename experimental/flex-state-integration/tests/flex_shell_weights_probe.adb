with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Flex_Shell_Weights;
procedure Flex_Shell_Weights_Probe is
   package S renames MJ.Flex_Shell_Weights;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   package UIO is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   use type Interfaces.Unsigned_64;
   Cases, Calls, Initial, Visited : Natural;
   G : S.Grid;
   P : S.Grid_Point;
   Weight : S.Weight_Value;
   E : S.Endpoint;
   Terms : S.Term_Array;
   Tail_OK : Boolean;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Sample in 1 .. Cases loop
      for X of G loop Ada.Integer_Text_IO.Get (X); end loop;
      Ada.Integer_Text_IO.Get (Calls);
      Ada.Integer_Text_IO.Get (Initial);
      E := (Count => Initial, Items => [others => (Body_Id => 9999, Weight => 0.0)]);
      for J in 0 .. Integer (Initial) - 1 loop
         Ada.Integer_Text_IO.Get (E.Items (J).Body_Id);
         RIO.Get (E.Items (J).Weight);
      end loop;
      declare Bodies : S.Node_Bodies (0 .. Natural (S.Total_Nodes (G)) - 1); begin
         for B of Bodies loop Ada.Integer_Text_IO.Get (B); end loop;
         Visited := Initial;
         for Call in 1 .. Calls loop
            for X of P loop Ada.Integer_Text_IO.Get (X); end loop;
            RIO.Get (Weight);
            S.Generate (G, P, Bodies, Weight, Terms);
            S.Accumulate (E, Terms, Visited);
            Visited := Visited + 26;
         end loop;
      end;
      Put_Line ("case");
      Put ("bodies");
      for J in 0 .. Integer (E.Count) - 1 loop
         Put (' '); Ada.Integer_Text_IO.Put (E.Items (J).Body_Id, Width => 0);
      end loop;
      New_Line; Put ("weights");
      for J in 0 .. Integer (E.Count) - 1 loop
         Put (' '); RIO.Put (E.Items (J).Weight, Fore => 1, Aft => 17, Exp => 3);
      end loop;
      New_Line;
      Put ("bits");
      for J in 0 .. Integer (E.Count) - 1 loop
         Put (' '); UIO.Put (Bits (E.Items (J).Weight), Width => 0);
      end loop;
      New_Line;
      Tail_OK := (for all J in E.Count .. 728 =>
        E.Items (J).Body_Id = 9999 and then Bits (E.Items (J).Weight) = 0);
      Put_Line ("tail " & Boolean'Image (Tail_OK));
   end loop;
end Flex_Shell_Weights_Probe;

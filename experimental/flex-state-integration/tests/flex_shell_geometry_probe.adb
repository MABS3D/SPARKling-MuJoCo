with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Contact_Geometry;
with MJ.Flex_Shell_Weights;
with MJ.Flex_Shell_Geometry;
procedure Flex_Shell_Geometry_Probe is
   package W renames MJ.Flex_Shell_Weights;
   package G renames MJ.Flex_Shell_Geometry;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   package UIO is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   Cases : Natural;
   Grid : W.Grid;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Sample in 1 .. Cases loop
      for X of Grid loop Ada.Integer_Text_IO.Get (X); end loop;
      declare
         Nodes, Result : MJ.Contact_Geometry.Vertex_Array (0 .. Natural (W.Total_Nodes (Grid)) - 1);
      begin
         for X of Nodes loop
            for Y of X loop RIO.Get (Y); end loop;
         end loop;
         Result := Nodes;
         for I in 1 .. Grid (0) - 2 loop
            for J in 1 .. Grid (1) - 2 loop
               for K in 1 .. Grid (2) - 2 loop
                  G.Reconstruct (Grid, [I, J, K], Nodes,
                    Result (W.Flat (Grid, [I, J, K])));
               end loop;
            end loop;
         end loop;
         Put ("bits");
         for X of Result loop
            for Y of X loop Put (' '); UIO.Put (Bits (Y), Width => 0); end loop;
         end loop;
         New_Line;
      end;
   end loop;
end Flex_Shell_Geometry_Probe;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry;
with MJ.Flex_Interpolation;
procedure Flex_Interpolation_Probe is
   package F renames MJ.Flex_Interpolation;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   Cases, Degree, N : Integer;
   Cells : F.Grid;
   Coord, Local, Result : Vec;
   Indices : F.Node_Indices;
   Weights : F.Basis_Array;
   procedure Put_Real (X : Real) is
   begin Put (' '); RIO.Put (X, Fore => 1, Aft => 17, Exp => 3); end Put_Real;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Sample in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Degree);
      for K in Axis loop Ada.Integer_Text_IO.Get (Cells (K)); end loop;
      for K in Axis loop RIO.Get (Coord (K)); end loop;
      N := Integer (F.Node_Count (Cells, Degree));
      declare Nodes : MJ.Contact_Geometry.Vertex_Array (0 .. N - 1); begin
         for J in Nodes'Range loop
            for K in Axis loop RIO.Get (Nodes (J) (K)); end loop;
         end loop;
         F.Lookup (Coord, Cells, Degree, Local, Indices);
         F.Basis (Local, Degree, Weights);
         F.Interpolate (Local, Degree, Nodes, Indices, Result);
      end;
      Put_Line ("case");
      Put ("indices");
      for J in 0 .. F.Nodes_Per_Cell (Degree) - 1 loop
         Put (' '); Ada.Integer_Text_IO.Put (Indices (J), Width => 0);
      end loop;
      New_Line; Put ("local"); for X of Local loop Put_Real (X); end loop;
      New_Line; Put ("basis");
      for J in 0 .. F.Nodes_Per_Cell (Degree) - 1 loop Put_Real (Weights (J)); end loop;
      New_Line; Put ("result"); for X of Result loop Put_Real (X); end loop;
      New_Line;
   end loop;
end Flex_Interpolation_Probe;

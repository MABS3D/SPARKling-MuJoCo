with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Flex_Interpolation;
with MJ.Flex_Node_Weights;
with MJ.Flex_Shell_Weights;
with MJ.Flex_Shell_Node_Weights;
with Ada.Unchecked_Conversion;
with Interfaces;
procedure Flex_Shell_Node_Weights_Probe is
   package F renames MJ.Flex_Interpolation;
   package N renames MJ.Flex_Node_Weights;
   package W renames MJ.Flex_Shell_Weights;
   package SN renames MJ.Flex_Shell_Node_Weights;
   package UIO is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   package RIO is new Ada.Text_IO.Float_IO (Real);
   Cases, Degree, Count, Total : Integer;
   Cells : F.Grid;
   Vertices : N.Coordinates;
   Weights : N.Vertex_Weights;
   Coord, Local : Vec;
   Indices : F.Node_Indices;
   Basis : F.Basis_Array;
   Grid : W.Grid;
   Result : W.Endpoint;
   procedure Put_Real (X : Real) is
   begin Put (' '); RIO.Put (X, Fore => 1, Aft => 17, Exp => 3); end Put_Real;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Sample in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Degree);
      Degree := abs Degree;
      for K in Axis loop Ada.Integer_Text_IO.Get (Cells (K)); end loop;
      Ada.Integer_Text_IO.Get (Count);
      for V of Vertices loop for X of V loop RIO.Get (X); end loop; end loop;
      for W of Weights loop RIO.Get (W); end loop;
      Total := Integer (F.Node_Count (Cells, Degree));
      Grid := [for K in Axis => Cells (K) * Degree + 1];
      declare
         All_Bodies : W.Node_Bodies (0 .. Total - 1);
      begin
         for B of All_Bodies loop Ada.Integer_Text_IO.Get (B); end loop;
         for K in Axis loop Coord (K) := N.Coordinate (Vertices, Weights, Count, K); end loop;
         Result := (others => <>);
         if Count > 0 then
            F.Lookup (Coord, Cells, Degree, Local, Indices);
            F.Basis (Local, Degree, Basis);
            SN.Build (Grid, All_Bodies, Indices, Basis, N.Sign (Weights),
              F.Nodes_Per_Cell (Degree), Result);
         end if;
      end;
      Put_Line ("case");
      Put ("coord"); for X of Coord loop Put_Real (X); end loop;
      New_Line; Put ("bodies");
      for J in 0 .. Integer (Result.Count) - 1 loop
         Put (' '); Ada.Integer_Text_IO.Put (Result.Items (J).Body_Id, Width => 0);
      end loop;
      New_Line; Put ("weights");
      for J in 0 .. Integer (Result.Count) - 1 loop Put_Real (Result.Items (J).Weight); end loop;
      New_Line; Put ("bits");
      for J in 0 .. Integer (Result.Count) - 1 loop
         Put (' '); UIO.Put (Bits (Result.Items (J).Weight), Width => 0);
      end loop;
      New_Line;
   end loop;
end Flex_Shell_Node_Weights_Probe;

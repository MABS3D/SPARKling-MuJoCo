with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Flex_Interpolation;
with MJ.Flex_Node_Weights;
procedure Flex_Node_Weights_Probe is
   package F renames MJ.Flex_Interpolation;
   package N renames MJ.Flex_Node_Weights;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   Cases, Degree, Count, Total : Integer;
   Cells : F.Grid;
   Vertices : N.Coordinates;
   Weights : N.Vertex_Weights;
   Coord, Local : Vec;
   Indices : F.Node_Indices;
   Basis : F.Basis_Array;
   Bodies : N.Cell_Bodies;
   Result : N.Endpoint;
   procedure Put_Real (X : Real) is
   begin Put (' '); RIO.Put (X, Fore => 1, Aft => 17, Exp => 3); end Put_Real;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Sample in 1 .. Cases loop
      Ada.Integer_Text_IO.Get (Degree);
      for K in Axis loop Ada.Integer_Text_IO.Get (Cells (K)); end loop;
      Ada.Integer_Text_IO.Get (Count);
      for V of Vertices loop for X of V loop RIO.Get (X); end loop; end loop;
      for W of Weights loop RIO.Get (W); end loop;
      Total := Integer (F.Node_Count (Cells, Degree));
      declare
         All_Bodies : array (0 .. Total - 1) of Natural;
      begin
         for B of All_Bodies loop Ada.Integer_Text_IO.Get (B); end loop;
         for K in Axis loop Coord (K) := N.Coordinate (Vertices, Weights, Count, K); end loop;
         Result := (others => <>);
         if Count > 0 then
            F.Lookup (Coord, Cells, Degree, Local, Indices);
            Bodies := [others => 0];
            for J in 0 .. F.Nodes_Per_Cell (Degree) - 1 loop
               Bodies (J) := All_Bodies (Indices (J));
            end loop;
            F.Basis (Local, Degree, Basis);
            N.Build (Basis, F.Nodes_Per_Cell (Degree), Bodies, N.Sign (Weights), Result);
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
      New_Line;
   end loop;
end Flex_Node_Weights_Probe;

with MJ.Rigid_Geometry;
package body MJ.Flex_Shell_Update with SPARK_Mode is
   use type MJ.Rigid_Geometry.Vec;
   procedure Interior_Not_Boundary (Grid : W.Grid; P : W.Grid_Point) is
      N : constant Natural := W.Flat (Grid,P);
   begin
      pragma Assert (Static => Int64 (N) =
        (Int64 (P (0)) * Int64 (Grid (1)) + Int64 (P (1))) * Int64 (Grid (2)) + Int64 (P (2)));
      pragma Assert (Static => N mod Grid (2) = P (2));
      pragma Assert (Static => N / Grid (2) = P (0) * Grid (1) + P (1));
      pragma Assert (Static => (N / Grid (2)) mod Grid (1) = P (1));
      pragma Assert (Static => N / (Grid (1) * Grid (2)) = P (0));
   end Interior_Not_Boundary;
   procedure Rebuild (Grid : W.Grid; Nodes : in out CG.Vertex_Array; Success : out Boolean) is
      Original : constant CG.Vertex_Array := Nodes with Ghost => Static;
      Point : MJ.Rigid_Geometry.Vec;
   begin
      Success := False;
      for I in 1 .. Grid (0)-2 loop
         for J in 1 .. Grid (1)-2 loop
            for K in 1 .. Grid (2)-2 loop
               Interior_Not_Boundary (Grid,[I,J,K]);
               G.Reconstruct (Grid,[I,J,K],Nodes,Point);
               if (for some X of Point => X not in G.Position_Value) then return; end if;
               Nodes (W.Flat (Grid,[I,J,K])) := Point;
               pragma Loop_Invariant (Static => G.Valid_Nodes (Grid,Nodes));
               pragma Loop_Invariant (Static => Same_Boundary (Grid,Nodes,Original));
            end loop;
            pragma Loop_Invariant (Static => G.Valid_Nodes (Grid,Nodes));
            pragma Loop_Invariant (Static => Same_Boundary (Grid,Nodes,Original));
         end loop;
         pragma Loop_Invariant (Static => G.Valid_Nodes (Grid,Nodes));
         pragma Loop_Invariant (Static => Same_Boundary (Grid,Nodes,Original));
      end loop;
      Success := True;
   end Rebuild;
end MJ.Flex_Shell_Update;

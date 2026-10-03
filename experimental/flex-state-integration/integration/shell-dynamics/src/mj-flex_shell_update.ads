with MJ.Types; use MJ.Types;
with MJ.Contact_Geometry;
with MJ.Flex_Shell_Weights;
with MJ.Flex_Shell_Geometry;
package MJ.Flex_Shell_Update with SPARK_Mode is
   package W renames MJ.Flex_Shell_Weights;
   package G renames MJ.Flex_Shell_Geometry;
   package CG renames MJ.Contact_Geometry;
   function Boundary (Grid : W.Grid; Index : Natural) return Boolean is
     (Index / (Grid (1) * Grid (2)) = 0
      or else Index / (Grid (1) * Grid (2)) = Grid (0)-1
      or else (Index / Grid (2)) mod Grid (1) = 0
      or else (Index / Grid (2)) mod Grid (1) = Grid (1)-1
      or else Index mod Grid (2) = 0 or else Index mod Grid (2) = Grid (2)-1)
     with Ghost => Static, Global => null;
   function Same_Boundary (Grid : W.Grid; A, B : CG.Vertex_Array) return Boolean is
     (A'First = B'First and then A'Last = B'Last
      and then (for all K in A'Range => (if Boundary (Grid,K) then A (K) = B (K))))
     with Ghost => Static, Global => null;
   procedure Interior_Not_Boundary (Grid : W.Grid; P : W.Grid_Point)
     with Ghost => Static, Global => null,
       Pre => W.Total_Nodes (Grid) <= Int64 (Natural'Last) and then W.Inside (Grid,P),
       Post => not Boundary (Grid,W.Flat (Grid,P));
   -- Mutates candidate scratch only. On rejection, earlier interior nodes
   -- may have changed, but all boundary positions and numeric bounds remain.
   procedure Rebuild (Grid : W.Grid; Nodes : in out CG.Vertex_Array; Success : out Boolean)
     with Global => null, Pre => G.Valid_Nodes (Grid,Nodes),
       Post => (Static => G.Valid_Nodes (Grid,Nodes) and then Same_Boundary (Grid,Nodes,Nodes'Old));
end MJ.Flex_Shell_Update;

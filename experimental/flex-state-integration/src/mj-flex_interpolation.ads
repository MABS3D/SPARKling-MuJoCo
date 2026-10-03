with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry;

--  MuJoCo 3.14.0 cell lookup and nodal position interpolation. This package
--  does not construct contact body weights: that path has a different cutoff
--  and shell expansion and must not reuse normalized vertex weights.
package MJ.Flex_Interpolation with SPARK_Mode is
   subtype Order is Positive range 1 .. 2;
   subtype Cell_Count is Positive range 1 .. 4096;
   type Grid is array (Axis) of Cell_Count;
   type Cell_Index is array (Axis) of Natural;
   subtype Parametric is Real range -4.0 .. 4.0;
   subtype Local_Value is Real range 0.0 .. 1.0;
   subtype Shape_Value is Real range -4.0 .. 4.0;
   subtype Basis_Value is Real range -64.0 .. 64.0;
   subtype Prefix_Count is Natural range 0 .. 27;
   type Node_Indices is array (Natural range 0 .. 26) of Natural;
   type Basis_Array is array (Natural range 0 .. 26) of Basis_Value;

   function Nodes_Per_Cell (Degree : Order) return Positive is
     (if Degree = 1 then 8 else 27);
   function Node_Count (Cells : Grid; Degree : Order) return Int64 is
     ((Int64 (Cells (0)) * Int64 (Degree) + 1) *
      (Int64 (Cells (1)) * Int64 (Degree) + 1) *
      (Int64 (Cells (2)) * Int64 (Degree) + 1));

   function Phi (X : Local_Value; I : Natural; Degree : Order)
     return Shape_Value
     with Global => null, Pre => I <= Degree,
       Post => Phi'Result =
         (if Degree = 1 then (if I = 0 then 1.0 - X else X)
          elsif I = 0 then (2.0 * X) * X - 3.0 * X + 1.0
          elsif I = 1 then 4.0 * (X - X * X)
          else (2.0 * X) * X - X);

   function Basis_At (Local : Vec; Degree : Order; J : Natural)
     return Basis_Value
     with Global => null,
       Pre => (for all X of Local => X in Local_Value)
         and then J < Nodes_Per_Cell (Degree),
       Post => Basis_At'Result =
         (Phi (Local (0), J / ((Degree + 1) * (Degree + 1)), Degree) *
          Phi (Local (1), (J / (Degree + 1)) mod (Degree + 1), Degree)) *
          Phi (Local (2), J mod (Degree + 1), Degree);

   procedure Basis (Local : Vec; Degree : Order; Values : out Basis_Array)
     with Global => null,
       Pre => (for all X of Local => X in Local_Value),
       Post => (for all J in Values'Range => Values (J) =
         (if J < Nodes_Per_Cell (Degree) then Basis_At (Local, Degree, J) else 0.0));

   function Cell_Of (X : Parametric; N : Cell_Count) return Natural
     with Global => null,
       Post => Cell_Of'Result < N
         and then Cell_Of'Result = Natural'Max (0, Integer'Min
           (Integer (Real'Floor (X * Real (N))), N - 1));

   function Local_Of (X : Parametric; N : Cell_Count) return Local_Value
     with Global => null,
       Post => Local_Of'Result =
         (if X * Real (N) - Real (Cell_Of (X, N)) < 0.0 then 0.0
          elsif X * Real (N) - Real (Cell_Of (X, N)) > 1.0 then 1.0
          else X * Real (N) - Real (Cell_Of (X, N)));

   function Cell_For (Coord : Vec; Cells : Grid) return Cell_Index
     with Global => null, Pre => (for all X of Coord => X in Parametric),
       Post => (for all K in Axis => Cell_For'Result (K) = Cell_Of (Coord (K), Cells (K))
         and then Cell_For'Result (K) < Cells (K));

   function Index_Of (Cells : Grid; Degree : Order; Cell : Cell_Index;
                      J : Natural) return Natural
     with Global => null,
       Pre => Node_Count (Cells, Degree) <= Int64 (Natural'Last)
         and then (for all K in Axis => Cell (K) < Cells (K))
         and then J < Nodes_Per_Cell (Degree),
       Post => Int64 (Index_Of'Result) < Node_Count (Cells, Degree)
         and then Int64 (Index_Of'Result) =
           ((Int64 (Cell (0) * Degree + J / ((Degree + 1) * (Degree + 1))) *
             Int64 (Cells (1) * Degree + 1) * Int64 (Cells (2) * Degree + 1)) +
            Int64 (Cell (1) * Degree + (J / (Degree + 1)) mod (Degree + 1)) *
             Int64 (Cells (2) * Degree + 1)) +
            Int64 (Cell (2) * Degree + J mod (Degree + 1));

   procedure Lookup (Coord : Vec; Cells : Grid; Degree : Order;
                     Local : out Vec; Indices : out Node_Indices)
     with Global => null,
       Pre => (for all X of Coord => X in Parametric)
         and then Node_Count (Cells, Degree) <= Int64 (Natural'Last),
       Post => (for all K in Axis => Local (K) = Local_Of (Coord (K), Cells (K)))
         and then (for all J in 0 .. Nodes_Per_Cell (Degree) - 1 =>
           Indices (J) = Index_Of (Cells, Degree, Cell_For (Coord, Cells), J))
         and then (for all J in Nodes_Per_Cell (Degree) .. Indices'Last => Indices (J) = 0);

   --  Exact floating-point accumulation, preserving the C node order.
   function Add_Node (Acc, Value : Real; Weight : Basis_Value) return Real
     with Global => null,
       Pre => Acc in -1.0e16 .. 1.0e16 and then Value in -1.0e11 .. 1.0e11,
       Post => Add_Node'Result = Acc + Value * Weight
         and then Add_Node'Result in -1.1e16 .. 1.1e16;

   function Ordered_Component (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Count : Prefix_Count; K : Axis) return Real
     with Ghost => Static, Global => null,
       Subprogram_Variant => (Decreases => Count),
       Pre => (for all X of Local => X in Local_Value)
         and then Count <= Nodes_Per_Cell (Degree)
         and then (for all J in 0 .. Nodes_Per_Cell (Degree) - 1 =>
           Indices (J) in Nodes'Range
           and then Nodes (Indices (J)) (K) in -1.0e11 .. 1.0e11),
       Post => (Static => Ordered_Component'Result in
         -Real (Count) * 7.0e12 .. Real (Count) * 7.0e12
         and then Ordered_Component'Result =
           (if Count = 0 then 0.0 else
             Ordered_Component (Local, Degree, Nodes, Indices, Count - 1, K) +
             Nodes (Indices (Count - 1)) (K) * Basis_At (Local, Degree, Count - 1)));

   procedure Interpolate (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Result : out Vec)
     with Global => null,
       Pre => (for all X of Local => X in Local_Value)
         and then (for all J in 0 .. Nodes_Per_Cell (Degree) - 1 =>
           Indices (J) in Nodes'Range
           and then (for all K in Axis => Nodes (Indices (J)) (K) in -1.0e11 .. 1.0e11)),
       Post => (Static =>
         (for all X of Result => X in -2.0e14 .. 2.0e14)
         and then Result (0) = Ordered_Component
           (Local, Degree, Nodes, Indices, Nodes_Per_Cell (Degree), 0)
         and then Result (1) = Ordered_Component
           (Local, Degree, Nodes, Indices, Nodes_Per_Cell (Degree), 1)
         and then Result (2) = Ordered_Component
           (Local, Degree, Nodes, Indices, Nodes_Per_Cell (Degree), 2));
end MJ.Flex_Interpolation;

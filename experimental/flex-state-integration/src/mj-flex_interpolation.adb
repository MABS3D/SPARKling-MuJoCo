package body MJ.Flex_Interpolation with SPARK_Mode is
   procedure Flat_Bound (I, Limit, Stride, J : Int64)
     with Ghost => Static, Global => null,
       Pre => Limit in 1 .. 100_000_000 and then I in 0 .. Limit - 1
         and then Stride in 1 .. 10_000 and then J in 0 .. Stride - 1,
       Post => I * Stride + J < Limit * Stride;
   procedure Flat_Bound (I, Limit, Stride, J : Int64) is
   begin
      pragma Assert (Static => I * Stride <= (Limit - 1) * Stride);
      pragma Assert (Static => I * Stride + J < (I + 1) * Stride);
   end Flat_Bound;

   function Phi (X : Local_Value; I : Natural; Degree : Order)
     return Shape_Value is
   begin
      if Degree = 1 then
         return (if I = 0 then 1.0 - X else X);
      elsif I = 0 then
         return (2.0 * X) * X - 3.0 * X + 1.0;
      elsif I = 1 then
         return 4.0 * (X - X * X);
      else
         return (2.0 * X) * X - X;
      end if;
   end Phi;

   function Basis_At (Local : Vec; Degree : Order; J : Natural)
     return Basis_Value is
      N : constant Positive := Degree + 1;
   begin
      return (Phi (Local (0), J / (N * N), Degree) *
              Phi (Local (1), (J / N) mod N, Degree)) *
              Phi (Local (2), J mod N, Degree);
   end Basis_At;

   procedure Basis (Local : Vec; Degree : Order; Values : out Basis_Array) is
   begin
      Values := [others => 0.0];
      for J in 0 .. Nodes_Per_Cell (Degree) - 1 loop
         Values (J) := Basis_At (Local, Degree, J);
         pragma Loop_Invariant (Static => (for all K in 0 .. J =>
           Values (K) = Basis_At (Local, Degree, K)));
         pragma Loop_Invariant (Static => (for all K in J + 1 .. Values'Last => Values (K) = 0.0));
      end loop;
   end Basis;

   function Cell_Of (X : Parametric; N : Cell_Count) return Natural is
      I : Integer := Integer (Real'Floor (X * Real (N)));
   begin
      I := Integer'Min (I, N - 1);
      return Integer'Max (I, 0);
   end Cell_Of;

   function Local_Of (X : Parametric; N : Cell_Count) return Local_Value is
      Y : constant Real := X * Real (N) - Real (Cell_Of (X, N));
   begin
      --  mju_clip retains the input at equality, including negative zero.
      if Y < 0.0 then return 0.0;
      elsif Y > 1.0 then return 1.0;
      else return Y;
      end if;
   end Local_Of;

   function Cell_For (Coord : Vec; Cells : Grid) return Cell_Index is
   begin
      return [Cell_Of (Coord (0), Cells (0)),
              Cell_Of (Coord (1), Cells (1)),
              Cell_Of (Coord (2), Cells (2))];
   end Cell_For;

   function Index_Of (Cells : Grid; Degree : Order; Cell : Cell_Index;
                      J : Natural) return Natural is
      N : constant Positive := Degree + 1;
      I0 : constant Int64 := Int64 (Cell (0) * Degree + J / (N * N));
      I1 : constant Int64 := Int64 (Cell (1) * Degree + (J / N) mod N);
      I2 : constant Int64 := Int64 (Cell (2) * Degree + J mod N);
      Nx : constant Int64 := Int64 (Cells (0) * Degree + 1);
      Ny : constant Int64 := Int64 (Cells (1) * Degree + 1);
      Nz : constant Int64 := Int64 (Cells (2) * Degree + 1);
      Row, Offset : Int64;
   begin
      pragma Assert (Static => I0 in 0 .. 8192 and I1 in 0 .. 8192 and I2 in 0 .. 8192);
      pragma Assert (Static => I0 < Nx and I1 < Ny and I2 < Nz);
      Row := I0 * Ny + I1;
      pragma Assert (Static => Row in 0 .. 100_000_000);
      Flat_Bound (I0, Nx, Ny, I1);
      pragma Assert (Static => Row < Nx * Ny);
      Offset := Row * Nz + I2;
      pragma Assert (Static => Offset in 0 .. 1_000_000_000_000);
      Flat_Bound (Row, Nx * Ny, Nz, I2);
      pragma Assert (Static => Offset < (Nx * Ny) * Nz);
      return Natural (Offset);
   end Index_Of;

   procedure Lookup (Coord : Vec; Cells : Grid; Degree : Order;
                     Local : out Vec; Indices : out Node_Indices) is
      Cell : constant Cell_Index := Cell_For (Coord, Cells);
   begin
      Local := [Local_Of (Coord (0), Cells (0)),
                Local_Of (Coord (1), Cells (1)),
                Local_Of (Coord (2), Cells (2))];
      Indices := [others => 0];
      for J in 0 .. Nodes_Per_Cell (Degree) - 1 loop
         Indices (J) := Index_Of (Cells, Degree, Cell, J);
         pragma Loop_Invariant (Static => (for all K in 0 .. J =>
           Indices (K) = Index_Of (Cells, Degree, Cell, K)));
         pragma Loop_Invariant (Static => (for all K in J + 1 .. Indices'Last => Indices (K) = 0));
      end loop;
   end Lookup;

   function Add_Node (Acc, Value : Real; Weight : Basis_Value) return Real is
   begin
      return Acc + Value * Weight;
   end Add_Node;

   function Add_Bounded (Acc, Value : Real; Weight : Basis_Value;
                         Count : Prefix_Count) return Real
     with Global => null,
       Pre => Count > 0
         and then Acc in -Real (Count - 1) * 7.0e12 .. Real (Count - 1) * 7.0e12
         and then Value in -1.0e11 .. 1.0e11,
       Post => Add_Bounded'Result in -2.0e14 .. 2.0e14
         and then Add_Bounded'Result in -Real (Count) * 7.0e12 .. Real (Count) * 7.0e12
         and then Add_Bounded'Result = Acc + Value * Weight;
   function Add_Bounded (Acc, Value : Real; Weight : Basis_Value;
                         Count : Prefix_Count) return Real is
   begin
      return Add_Node (Acc, Value, Weight);
   end Add_Bounded;

   function Ordered_Component (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Count : Prefix_Count; K : Axis) return Real is
   begin
      if Count = 0 then return 0.0; end if;
      return Add_Bounded
        (Ordered_Component (Local, Degree, Nodes, Indices, Count - 1, K),
         Nodes (Indices (Count - 1)) (K), Basis_At (Local, Degree, Count - 1), Count);
   end Ordered_Component;

   --  Isolate floating-point congruence from the recursive prefix model.
   procedure Same_Add (Acc, Previous, Value : Real; Weight, Prior_Weight : Basis_Value;
                       Next : Real)
     with Ghost => Static, Global => null,
       Pre => Acc in -2.0e14 .. 2.0e14 and then Previous = Acc
         and then Value in -1.0e11 .. 1.0e11
         and then Weight = Prior_Weight
         and then Next = Previous + Value * Prior_Weight,
       Post => Acc + Value * Weight = Next;
   procedure Same_Add (Acc, Previous, Value : Real; Weight, Prior_Weight : Basis_Value;
                       Next : Real) is
   begin
      null;
   end Same_Add;

   procedure Sum_Step (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Count : Prefix_Count; K : Axis; Acc : Real; Weight : Basis_Value)
     with Ghost => Static, Global => null,
       Pre => (for all X of Local => X in Local_Value)
         and then Count < Nodes_Per_Cell (Degree)
         and then Acc in -2.0e14 .. 2.0e14
         and then (for all J in 0 .. Nodes_Per_Cell (Degree) - 1 =>
           Indices (J) in Nodes'Range
           and then Nodes (Indices (J)) (K) in -1.0e11 .. 1.0e11)
         and then Acc = Ordered_Component (Local, Degree, Nodes, Indices, Count, K)
         and then Weight = Basis_At (Local, Degree, Count),
       Post => Acc + Nodes (Indices (Count)) (K) * Weight =
         Ordered_Component (Local, Degree, Nodes, Indices, Count + 1, K);
   procedure Sum_Step (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Count : Prefix_Count; K : Axis; Acc : Real; Weight : Basis_Value) is
      Next : constant Real := Ordered_Component (Local, Degree, Nodes, Indices, Count + 1, K);
   begin
      pragma Assert (Static => Next =
        Ordered_Component (Local, Degree, Nodes, Indices, Count, K) +
        Nodes (Indices (Count)) (K) * Basis_At (Local, Degree, Count));
      Same_Add (Acc, Ordered_Component (Local, Degree, Nodes, Indices, Count, K),
                Nodes (Indices (Count)) (K), Weight, Basis_At (Local, Degree, Count), Next);
   end Sum_Step;

   procedure Advance_Node (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Count : Prefix_Count; Weight : Basis_Value; Result : in out Vec)
     with Inline, Global => null,
       Pre => (Static => (for all X of Local => X in Local_Value)
         and then Count < Nodes_Per_Cell (Degree)
         and then (for all J in 0 .. Nodes_Per_Cell (Degree) - 1 =>
           Indices (J) in Nodes'Range
           and then (for all K in Axis => Nodes (Indices (J)) (K) in -1.0e11 .. 1.0e11))
         and then Weight = Basis_At (Local, Degree, Count)
         and then (for all X of Result => X in -2.0e14 .. 2.0e14
           and then X in -Real (Count) * 7.0e12 .. Real (Count) * 7.0e12)
         and then Result (0) = Ordered_Component (Local, Degree, Nodes, Indices, Count, 0)
         and then Result (1) = Ordered_Component (Local, Degree, Nodes, Indices, Count, 1)
         and then Result (2) = Ordered_Component (Local, Degree, Nodes, Indices, Count, 2)),
       Post => (Static => (for all X of Result => X in -2.0e14 .. 2.0e14
           and then X in -Real (Count + 1) * 7.0e12 .. Real (Count + 1) * 7.0e12)
         and then Result (0) = Ordered_Component (Local, Degree, Nodes, Indices, Count + 1, 0)
         and then Result (1) = Ordered_Component (Local, Degree, Nodes, Indices, Count + 1, 1)
         and then Result (2) = Ordered_Component (Local, Degree, Nodes, Indices, Count + 1, 2));
   procedure Advance_Node (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Count : Prefix_Count; Weight : Basis_Value; Result : in out Vec) is
   begin
      for K in Axis loop
         Sum_Step (Local, Degree, Nodes, Indices, Count, K, Result (K), Weight);
         Result (K) := Add_Bounded (Result (K), Nodes (Indices (Count)) (K), Weight, Count + 1);
      end loop;
   end Advance_Node;

   procedure Interpolate (Local : Vec; Degree : Order;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Indices : Node_Indices;
     Result : out Vec) is
      Weights : Basis_Array;
   begin
      Basis (Local, Degree, Weights);
      Result := Zero;
      pragma Assert (Static => Ordered_Component (Local, Degree, Nodes, Indices, 0, 0) = 0.0);
      pragma Assert (Static => Ordered_Component (Local, Degree, Nodes, Indices, 0, 1) = 0.0);
      pragma Assert (Static => Ordered_Component (Local, Degree, Nodes, Indices, 0, 2) = 0.0);
      for J in 0 .. Nodes_Per_Cell (Degree) - 1 loop
         Advance_Node (Local, Degree, Nodes, Indices, J, Weights (J), Result);
         pragma Loop_Invariant (for all X of Result =>
           X in -Real (J + 1) * 7.0e12 .. Real (J + 1) * 7.0e12);
         pragma Loop_Invariant (for all X of Result => X in -2.0e14 .. 2.0e14);
         pragma Loop_Invariant (Static => Result (0) =
           Ordered_Component (Local, Degree, Nodes, Indices, J + 1, 0));
         pragma Loop_Invariant (Static => Result (1) =
           Ordered_Component (Local, Degree, Nodes, Indices, J + 1, 1));
         pragma Loop_Invariant (Static => Result (2) =
           Ordered_Component (Local, Degree, Nodes, Indices, J + 1, 2));
      end loop;
   end Interpolate;
end MJ.Flex_Interpolation;

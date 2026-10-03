with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry;
with MJ.Flex_Interpolation;
with MJ.Flex_Node_Weights;
with MJ.Flex_Shell_Weights;

--  Negative-order contact basis composition. Each accepted interior basis node
--  expands to 26 signed terms before the next basis node is considered.
package MJ.Flex_Shell_Node_Weights with SPARK_Mode is
   package FI renames MJ.Flex_Interpolation;
   package NW renames MJ.Flex_Node_Weights;
   package SW renames MJ.Flex_Shell_Weights;
   use type SW.Endpoint;
   use type SW.Term_Array;
   use type SW.Body_Weight;
   function Unflat (G : SW.Grid; Index : Natural) return SW.Grid_Point
     with Global => null,
       Pre => SW.Total_Nodes (G) <= Int64 (Natural'Last)
         and then Int64 (Index) < SW.Total_Nodes (G),
       Post => (for all K in MJ.Rigid_Geometry.Axis => Unflat'Result (K) < G (K))
         and then SW.Flat (G, Unflat'Result) = Index;
   function Valid_Layout (G : SW.Grid; Bodies : SW.Node_Bodies;
     Indices : FI.Node_Indices) return Boolean is
     (Bodies'First = 0 and then SW.Total_Nodes (G) = Int64 (Bodies'Length)
      and then SW.Total_Nodes (G) <= Int64 (Natural'Last)
      and then (for all I of Indices => I in Bodies'Range));
   procedure Widen (E : SW.Endpoint; Before, After : SW.Prefix_Count)
     with Ghost => Static, Global => null,
       Pre => Before <= After and then SW.Bounded (E, Before),
       Post => SW.Bounded (E, After);
   function Signed (Weight : FI.Basis_Value; Sgn : NW.Sign_Value) return SW.Weight_Value
     with Global => null, Pre => Sgn /= 0,
       Post => Signed'Result = Real (Sgn) * Weight;
   function Bounded_Terms (G : SW.Grid; P : SW.Grid_Point;
     Bodies : SW.Node_Bodies; Weight : SW.Weight_Value) return SW.Term_Array
     with Ghost => Static, Global => null,
       Pre => SW.Inside (G, P) and then Bodies'First = 0
         and then SW.Total_Nodes (G) = Int64 (Bodies'Length)
         and then SW.Total_Nodes (G) <= Int64 (Natural'Last),
       Post => (Static => (for all X of Bounded_Terms'Result => X.Weight in SW.Weight_Value)
         and then Bounded_Terms'Result = SW.Model_Terms (G, P, Bodies, Weight));
   function After_Node (E : SW.Endpoint; G : SW.Grid; Bodies : SW.Node_Bodies;
     Index : Natural; Weight : FI.Basis_Value; Sgn : NW.Sign_Value;
     Visited : SW.Prefix_Count) return SW.Endpoint
     with Global => null,
       Pre => Bodies'First = 0 and then SW.Total_Nodes (G) = Int64 (Bodies'Length)
         and then SW.Total_Nodes (G) <= Int64 (Natural'Last)
         and then Index in Bodies'Range and then Sgn /= 0
         and then Visited <= 676 and then SW.Bounded (E, Visited),
       Post => (Static => SW.Bounded (After_Node'Result, Visited + 26)
         and then (if Weight < 1.0e-5 then After_Node'Result = E)
         and then (if Weight >= 1.0e-5 and then SW.Inside (G, Unflat (G, Index)) then
           After_Node'Result = SW.Fold (E,
             Bounded_Terms (G, Unflat (G, Index), Bodies, Signed (Weight, Sgn)), 26, Visited))
         and then (if Weight >= 1.0e-5 and then not SW.Inside (G, Unflat (G, Index)) then
           After_Node'Result.Count = (if SW.Find (E, Bodies (Index)) < E.Count
             then E.Count else E.Count + 1)
           and then (for all J in E.Items'Range =>
             (if J = SW.Find (E, Bodies (Index)) then
               After_Node'Result.Items (J).Body_Id = Bodies (Index)
               and then After_Node'Result.Items (J).Weight =
                 (if J < E.Count then E.Items (J).Weight + Signed (Weight, Sgn)
                  else Signed (Weight, Sgn))
              else After_Node'Result.Items (J) = E.Items (J)))));
   function Fold (G : SW.Grid; Bodies : SW.Node_Bodies; Indices : FI.Node_Indices;
     Values : FI.Basis_Array; Sgn : NW.Sign_Value; Count : FI.Prefix_Count) return SW.Endpoint
     with Ghost => Static, Global => null, Subprogram_Variant => (Decreases => Count),
       Pre => Valid_Layout (G, Bodies, Indices) and then Sgn /= 0,
       Post => (Static => SW.Bounded (Fold'Result, Count * 26)
         and then Fold'Result = (if Count = 0 then SW.Endpoint'(others => <>) else
           After_Node (Fold (G, Bodies, Indices, Values, Sgn, Count - 1),
             G, Bodies, Indices (Count - 1), Values (Count - 1), Sgn, (Count - 1) * 26)));
   procedure Build (G : SW.Grid; Bodies : SW.Node_Bodies; Indices : FI.Node_Indices;
     Values : FI.Basis_Array; Sgn : NW.Sign_Value; Count : FI.Prefix_Count;
     Result : out SW.Endpoint)
     with Global => null, Pre => Valid_Layout (G, Bodies, Indices) and then Sgn /= 0,
       Post => (Static => SW.Bounded (Result, Count * 26)
         and then Result = Fold (G, Bodies, Indices, Values, Sgn, Count));
end MJ.Flex_Shell_Node_Weights;

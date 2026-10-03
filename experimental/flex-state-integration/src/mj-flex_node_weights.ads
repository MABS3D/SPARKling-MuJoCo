with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Flex_Interpolation;

--  Positive-order branch of MuJoCo 3.14.0 mj_vertBodyWeight. The four
--  coefficients describe contact vertices, never the output body capacity.
package MJ.Flex_Node_Weights with SPARK_Mode is
   package FI renames MJ.Flex_Interpolation;
   subtype Vertex_Count is Natural range 0 .. 4;
   subtype Vertex_Index is Natural range 0 .. 3;
   type Coordinates is array (Vertex_Index) of Vec;
   subtype Vertex_Weight is Real range -1.0 .. 1.0;
   type Vertex_Weights is array (Vertex_Index) of Vertex_Weight;
   type Cell_Bodies is array (Natural range 0 .. 26) of Natural;
   type Body_Weight is record
      Body_Id : Natural := 0;
      Weight : Real := 0.0;
   end record;
   type Body_Weights is array (Natural range 0 .. 26) of Body_Weight;
   type Endpoint is record
      Count : FI.Prefix_Count := 0;
      Items : Body_Weights := [others => <>];
   end record;
   subtype Sign_Value is Integer range -1 .. 1;

   function Sign (Weights : Vertex_Weights) return Sign_Value is
     (if Weights (0) < 0.0 then -1 else 1);

   function Term (Value : FI.Parametric; Weight : Vertex_Weight)
     return FI.Parametric
     with Global => null, Inline,
       Post => Term'Result = Value * abs Weight;

   function Coordinate (Vertices : Coordinates; Weights : Vertex_Weights;
     Count : Vertex_Count; K : Axis) return Real
     with Global => null,
       Pre => (for all V of Vertices =>
         (for all X of V => X in FI.Parametric)),
       Post => Coordinate'Result in -16.0 .. 16.0
         and then Coordinate'Result =
         (if Count = 0 then 0.0
          elsif Count = 1 then 0.0 + Vertices (0) (K) * abs Weights (0)
          elsif Count = 2 then
            (0.0 + Vertices (0) (K) * abs Weights (0)) + Vertices (1) (K) * abs Weights (1)
          elsif Count = 3 then
            ((0.0 + Vertices (0) (K) * abs Weights (0)) + Vertices (1) (K) * abs Weights (1)) +
             Vertices (2) (K) * abs Weights (2)
          else (((0.0 + Vertices (0) (K) * abs Weights (0)) + Vertices (1) (K) * abs Weights (1)) +
             Vertices (2) (K) * abs Weights (2)) + Vertices (3) (K) * abs Weights (3));

   function Bounded (E : Endpoint; Visited : FI.Prefix_Count) return Boolean is
     (E.Count <= Visited and then
       (for all X of E.Items => X.Weight in
          -Real (Visited) * 65.0 .. Real (Visited) * 65.0));

   --  Count is the sentinel; an existing body is selected at its first index.
   function Find (E : Endpoint; Body_Id : Natural) return FI.Prefix_Count
     with Global => null,
       Post => Find'Result <= E.Count
         and then (if Find'Result < E.Count then
           E.Items (Find'Result).Body_Id = Body_Id)
         and then (for all J in 0 .. Integer (Find'Result) - 1 =>
           E.Items (J).Body_Id /= Body_Id);

   procedure Merge (E : in out Endpoint; Body_Id : Natural;
     Weight : FI.Basis_Value; Visited : FI.Prefix_Count)
     with Global => null,
       Pre => Visited < 27 and then Bounded (E, Visited),
       Post => (Static => Bounded (E, Visited + 1)
         and then E.Count = (if Find (E'Old, Body_Id) < E'Old.Count
           then E'Old.Count else E'Old.Count + 1)
         and then (for all J in E.Items'Range =>
           (if J = Find (E'Old, Body_Id) then
              E.Items (J).Body_Id = Body_Id and then E.Items (J).Weight =
                (if J < E'Old.Count then E'Old.Items (J).Weight + Weight else Weight)
            else E.Items (J) = E'Old.Items (J))));

   function After_Node (E : Endpoint; Body_Id : Natural;
     Weight : FI.Basis_Value; Sgn : Sign_Value; Visited : FI.Prefix_Count)
     return Endpoint
     with Global => null, Inline,
       Pre => Visited < 27 and then Bounded (E, Visited) and then Sgn /= 0,
       Post => (Static => Bounded (After_Node'Result, Visited + 1)
         and then (if Weight < 1.0e-5 then After_Node'Result = E
           else After_Node'Result.Count =
             (if Find (E, Body_Id) < E.Count then E.Count else E.Count + 1)
           and then (for all J in E.Items'Range =>
             (if J = Find (E, Body_Id) then
                After_Node'Result.Items (J).Body_Id = Body_Id
                and then After_Node'Result.Items (J).Weight =
                  (if J < E.Count then E.Items (J).Weight + Real (Sgn) * Weight
                   else Real (Sgn) * Weight)
              else After_Node'Result.Items (J) = E.Items (J)))));

   --  Exact ordered fold, including cutoff, duplicate accumulation and the
   --  unused-array frame. No sum-to-one or renormalization is asserted.
   function Fold (Values : FI.Basis_Array; Bodies : Cell_Bodies;
     Sgn : Sign_Value; Count : FI.Prefix_Count) return Endpoint
     with Ghost => Static, Global => null,
       Subprogram_Variant => (Decreases => Count),
       Pre => Sgn /= 0,
       Post => (Static => Bounded (Fold'Result, Count)
         and then Fold'Result = (if Count = 0 then Endpoint'(others => <>)
           else After_Node (Fold (Values, Bodies, Sgn, Count - 1),
             Bodies (Count - 1), Values (Count - 1), Sgn, Count - 1)));

   procedure Build (Values : FI.Basis_Array; Count : FI.Prefix_Count; Bodies : Cell_Bodies;
     Sgn : Sign_Value; Result : out Endpoint)
     with Global => null,
       Pre => Sgn /= 0,
       Post => (Static => Bounded (Result, Count)
         and then Result = Fold (Values, Bodies, Sgn, Count));
end MJ.Flex_Node_Weights;

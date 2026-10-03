package body MJ.Flex_Node_Weights with SPARK_Mode is
   function Term (Value : FI.Parametric; Weight : Vertex_Weight)
     return FI.Parametric is
   begin
      return Value * abs Weight;
   end Term;

   function Coordinate (Vertices : Coordinates; Weights : Vertex_Weights;
     Count : Vertex_Count; K : Axis) return Real is
      R : Real := 0.0;
   begin
      if Count >= 1 then R := R + Term (Vertices (0) (K), Weights (0)); end if;
      pragma Assert (Static => R in -4.0 .. 4.0);
      if Count >= 2 then R := R + Term (Vertices (1) (K), Weights (1)); end if;
      pragma Assert (Static => R in -8.0 .. 8.0);
      if Count >= 3 then R := R + Term (Vertices (2) (K), Weights (2)); end if;
      pragma Assert (Static => R in -12.0 .. 12.0);
      if Count >= 4 then R := R + Term (Vertices (3) (K), Weights (3)); end if;
      return R;
   end Coordinate;

   function Find (E : Endpoint; Body_Id : Natural) return FI.Prefix_Count is
   begin
      for J in 0 .. Integer (E.Count) - 1 loop
         if E.Items (J).Body_Id = Body_Id then return J; end if;
         pragma Loop_Invariant
           (for all K in 0 .. J => E.Items (K).Body_Id /= Body_Id);
      end loop;
      return E.Count;
   end Find;

   procedure Merge (E : in out Endpoint; Body_Id : Natural;
     Weight : FI.Basis_Value; Visited : FI.Prefix_Count) is
      J : constant FI.Prefix_Count := Find (E, Body_Id);
   begin
      if J < E.Count then
         E.Items (J).Weight := E.Items (J).Weight + Weight;
      else
         E.Items (J) := (Body_Id, Weight);
         E.Count := E.Count + 1;
      end if;
   end Merge;

   function After_Node (E : Endpoint; Body_Id : Natural;
     Weight : FI.Basis_Value; Sgn : Sign_Value; Visited : FI.Prefix_Count)
     return Endpoint is
      R : Endpoint := E;
   begin
      if Weight >= 1.0e-5 then
         Merge (R, Body_Id, Real (Sgn) * Weight, Visited);
      end if;
      return R;
   end After_Node;

   function Fold (Values : FI.Basis_Array; Bodies : Cell_Bodies;
     Sgn : Sign_Value; Count : FI.Prefix_Count) return Endpoint is
      E : Endpoint;
   begin
      if Count > 0 then
         E := After_Node (Fold (Values, Bodies, Sgn, Count - 1),
           Bodies (Count - 1), Values (Count - 1), Sgn, Count - 1);
      end if;
      return E;
   end Fold;

   procedure Same_After (E, Prev, Next : Endpoint; Body_Id : Natural;
     Weight : FI.Basis_Value; Sgn : Sign_Value; Count : FI.Prefix_Count)
     with Ghost => Static, Global => null,
       Pre => Count < 27 and then Sgn /= 0 and then Bounded (E, Count)
         and then Bounded (Prev, Count) and then E = Prev
         and then Next = After_Node (Prev, Body_Id, Weight, Sgn, Count),
       Post => After_Node (E, Body_Id, Weight, Sgn, Count) = Next;
   procedure Same_After (E, Prev, Next : Endpoint; Body_Id : Natural;
     Weight : FI.Basis_Value; Sgn : Sign_Value; Count : FI.Prefix_Count) is
   begin
      null;
   end Same_After;

   procedure Fold_Step (Values : FI.Basis_Array; Bodies : Cell_Bodies;
     Sgn : Sign_Value; Count : FI.Prefix_Count; E : Endpoint)
     with Ghost => Static, Global => null,
       Pre => Sgn /= 0 and then Count < 27 and then Bounded (E, Count)
         and then E = Fold (Values, Bodies, Sgn, Count),
       Post => After_Node (E, Bodies (Count), Values (Count), Sgn, Count) =
         Fold (Values, Bodies, Sgn, Count + 1);
   procedure Fold_Step (Values : FI.Basis_Array; Bodies : Cell_Bodies;
     Sgn : Sign_Value; Count : FI.Prefix_Count; E : Endpoint) is
      Prev : constant Endpoint := Fold (Values, Bodies, Sgn, Count);
      Next : constant Endpoint := Fold (Values, Bodies, Sgn, Count + 1);
   begin
      pragma Assert (E = Prev);
      pragma Assert (Next = After_Node (Prev, Bodies (Count), Values (Count), Sgn, Count));
      Same_After (E, Prev, Next, Bodies (Count), Values (Count), Sgn, Count);
   end Fold_Step;

   procedure Build (Values : FI.Basis_Array; Count : FI.Prefix_Count; Bodies : Cell_Bodies;
     Sgn : Sign_Value; Result : out Endpoint) is
   begin
      Result := (others => <>);
      for J in 0 .. Integer (Count) - 1 loop
         pragma Loop_Invariant (Static => Bounded (Result, J));
         pragma Loop_Invariant (Static => Result = Fold (Values, Bodies, Sgn, J));
         Fold_Step (Values, Bodies, Sgn, J, Result);
         Result := After_Node (Result, Bodies (J), Values (J), Sgn, J);
         pragma Assert (Static => Result = Fold (Values, Bodies, Sgn, J + 1));
      end loop;
   end Build;
end MJ.Flex_Node_Weights;

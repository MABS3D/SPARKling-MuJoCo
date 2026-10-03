with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry;
with MJ.Flex_Shell_Weights;

--  Ordered floating-point position reconstruction from mju_shellTrackInterior.
--  The three face pairs are grouped before accumulation, unlike contact weights.
package MJ.Flex_Shell_Geometry with SPARK_Mode is
   package W renames MJ.Flex_Shell_Weights;
   subtype Position_Value is Real range -1.0e11 .. 1.0e11;
   subtype Unit_Value is W.Unit_Value;
   subtype Correction_Index is W.Term_Index range 6 .. 25;
   subtype Step_Index is Natural range 0 .. 22;
   subtype Step_Count is Natural range 0 .. 23;
   type Row is array (W.Term_Index) of Position_Value;
   type Stencil is array (Axis) of Row;

   function Product (Value : Position_Value; Weight : Unit_Value) return Position_Value
     with Global => null, Inline, Post => Product'Result = Weight * Value;
   function Add_Term (Acc, Value : Real; Index : Step_Index) return Real
     with Global => null, Inline,
       Pre => Acc in -Real (Index) * 3.0e11 .. Real (Index) * 3.0e11
         and then Value in -2.0e11 .. 2.0e11,
       Post => Add_Term'Result = Acc + Value and then Add_Term'Result in
         -Real (Index + 1) * 3.0e11 .. Real (Index + 1) * 3.0e11;
   function Subtract_Term (Acc : Real; Value : Position_Value; Index : Step_Index) return Real
     with Global => null, Inline,
       Pre => Acc in -Real (Index) * 3.0e11 .. Real (Index) * 3.0e11,
       Post => Subtract_Term'Result = Acc - Value and then Subtract_Term'Result in
         -Real (Index + 1) * 3.0e11 .. Real (Index + 1) * 3.0e11;

   function Face_Pair (A, B : Position_Value; T : Unit_Value) return Real
     with Global => null,
       Post => Face_Pair'Result = (1.0 - T) * A + T * B
         and then Face_Pair'Result in -2.0e11 .. 2.0e11;
   function Coefficient (S, U, V : Unit_Value; T : Correction_Index) return Unit_Value
     with Global => null,
       Contract_Cases =>
         (T = 6 => Coefficient'Result = (1.0 - U) * (1.0 - V),
          T = 7 => Coefficient'Result = (1.0 - U) * V,
          T = 8 => Coefficient'Result = U * (1.0 - V),
          T = 9 => Coefficient'Result = U * V,
          T = 10 => Coefficient'Result = (1.0 - S) * (1.0 - V),
          T = 11 => Coefficient'Result = (1.0 - S) * V,
          T = 12 => Coefficient'Result = S * (1.0 - V),
          T = 13 => Coefficient'Result = S * V,
          T = 14 => Coefficient'Result = (1.0 - S) * (1.0 - U),
          T = 15 => Coefficient'Result = (1.0 - S) * U,
          T = 16 => Coefficient'Result = S * (1.0 - U),
          T = 17 => Coefficient'Result = S * U,
          T = 18 => Coefficient'Result = ((1.0 - S) * (1.0 - U)) * (1.0 - V),
          T = 19 => Coefficient'Result = ((1.0 - S) * (1.0 - U)) * V,
          T = 20 => Coefficient'Result = ((1.0 - S) * U) * (1.0 - V),
          T = 21 => Coefficient'Result = ((1.0 - S) * U) * V,
          T = 22 => Coefficient'Result = (S * (1.0 - U)) * (1.0 - V),
          T = 23 => Coefficient'Result = (S * (1.0 - U)) * V,
          T = 24 => Coefficient'Result = (S * U) * (1.0 - V),
          T = 25 => Coefficient'Result = (S * U) * V);
   function Advance (Acc : Real; Values : Row; S, U, V : Unit_Value;
     Index : Step_Index) return Real
     with Global => null,
       Pre => Acc in -Real (Index) * 3.0e11 .. Real (Index) * 3.0e11,
       Post => Advance'Result in -Real (Index + 1) * 3.0e11 .. Real (Index + 1) * 3.0e11
         and then Advance'Result =
           (if Index = 0 then Acc + Face_Pair (Values (0), Values (1), S)
            elsif Index = 1 then Acc + Face_Pair (Values (2), Values (3), U)
            elsif Index = 2 then Acc + Face_Pair (Values (4), Values (5), V)
            elsif Index < 15 then Acc - Coefficient (S, U, V, Index + 3) * Values (Index + 3)
            else Acc + Coefficient (S, U, V, Index + 3) * Values (Index + 3));
   function Ordered (Values : Row; S, U, V : Unit_Value; Count : Step_Count) return Real
     with Ghost => Static, Global => null, Subprogram_Variant => (Decreases => Count),
       Post => (Static => Ordered'Result in -Real (Count) * 3.0e11 .. Real (Count) * 3.0e11
         and then Ordered'Result = (if Count = 0 then 0.0 else
           Advance (Ordered (Values, S, U, V, Count - 1), Values, S, U, V, Count - 1)));
   function Component (Values : Row; S, U, V : Unit_Value) return Real
     with Global => null,
       Post => (Static => Component'Result in -6.9e12 .. 6.9e12
         and then Component'Result = Ordered (Values, S, U, V, 23));
   procedure Model_Step (Acc : Real; Values : Row; S, U, V : Unit_Value; Index : Step_Index)
     with Ghost => Static, Global => null,
       Pre => Acc in -Real (Index) * 3.0e11 .. Real (Index) * 3.0e11
         and then Acc = Ordered (Values, S, U, V, Index),
       Post => Advance (Acc, Values, S, U, V, Index) = Ordered (Values, S, U, V, Index + 1);

   function Valid_Nodes (G : W.Grid; Nodes : MJ.Contact_Geometry.Vertex_Array) return Boolean is
     (Nodes'First = 0 and then W.Total_Nodes (G) = Int64 (Nodes'Length)
      and then W.Total_Nodes (G) <= Int64 (Natural'Last)
      and then (for all X of Nodes => (for all Y of X => Y in Position_Value)));
   function Gather (G : W.Grid; P : W.Grid_Point;
     Nodes : MJ.Contact_Geometry.Vertex_Array) return Stencil
     with Global => null, Pre => W.Inside (G, P) and then Valid_Nodes (G, Nodes),
       Post => (Static => (for all K in Axis => (for all T in W.Term_Index =>
         Gather'Result (K) (T) = Nodes (W.Flat (G, W.Term_Point (G, P, T))) (K))));
   procedure Reconstruct (G : W.Grid; P : W.Grid_Point;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Result : out Vec)
     with Global => null, Pre => W.Inside (G, P) and then Valid_Nodes (G, Nodes),
       Post => (Static => (for all K in Axis =>
         Result (K) in -6.9e12 .. 6.9e12 and then Result (K) =
           Ordered (Gather (G, P, Nodes) (K), W.Local (P (0), G (0)),
             W.Local (P (1), G (1)), W.Local (P (2), G (2)), 23)));
end MJ.Flex_Shell_Geometry;

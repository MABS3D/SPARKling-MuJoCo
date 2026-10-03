package body MJ.Flex_Shell_Geometry with SPARK_Mode is
   function Product (Value : Position_Value; Weight : Unit_Value) return Position_Value is
     (Weight * Value);
   function Add_Term (Acc, Value : Real; Index : Step_Index) return Real is (Acc + Value);
   function Subtract_Term (Acc : Real; Value : Position_Value; Index : Step_Index) return Real is
     (Acc - Value);

   function Face_Pair (A, B : Position_Value; T : Unit_Value) return Real is
     ((1.0 - T) * A + T * B);

   function Coefficient (S, U, V : Unit_Value; T : Correction_Index) return Unit_Value is
   begin
      case T is
         when 6 => return (1.0 - U) * (1.0 - V);
         when 7 => return (1.0 - U) * V;
         when 8 => return U * (1.0 - V);
         when 9 => return U * V;
         when 10 => return (1.0 - S) * (1.0 - V);
         when 11 => return (1.0 - S) * V;
         when 12 => return S * (1.0 - V);
         when 13 => return S * V;
         when 14 => return (1.0 - S) * (1.0 - U);
         when 15 => return (1.0 - S) * U;
         when 16 => return S * (1.0 - U);
         when 17 => return S * U;
         when 18 => return ((1.0 - S) * (1.0 - U)) * (1.0 - V);
         when 19 => return ((1.0 - S) * (1.0 - U)) * V;
         when 20 => return ((1.0 - S) * U) * (1.0 - V);
         when 21 => return ((1.0 - S) * U) * V;
         when 22 => return (S * (1.0 - U)) * (1.0 - V);
         when 23 => return (S * (1.0 - U)) * V;
         when 24 => return (S * U) * (1.0 - V);
         when 25 => return (S * U) * V;
      end case;
   end Coefficient;

   function Advance (Acc : Real; Values : Row; S, U, V : Unit_Value;
     Index : Step_Index) return Real is
   begin
      if Index = 0 then return Add_Term (Acc, Face_Pair (Values (0), Values (1), S), Index);
      elsif Index = 1 then return Add_Term (Acc, Face_Pair (Values (2), Values (3), U), Index);
      elsif Index = 2 then return Add_Term (Acc, Face_Pair (Values (4), Values (5), V), Index);
      elsif Index < 15 then return Subtract_Term
        (Acc, Product (Values (Index + 3), Coefficient (S, U, V, Index + 3)), Index);
      else return Add_Term
        (Acc, Product (Values (Index + 3), Coefficient (S, U, V, Index + 3)), Index);
      end if;
   end Advance;

   function Ordered (Values : Row; S, U, V : Unit_Value; Count : Step_Count) return Real is
   begin
      if Count = 0 then return 0.0; end if;
      return Advance (Ordered (Values, S, U, V, Count - 1), Values, S, U, V, Count - 1);
   end Ordered;

   procedure Model_Step (Acc : Real; Values : Row; S, U, V : Unit_Value; Index : Step_Index) is
      Next : constant Real := Ordered (Values, S, U, V, Index + 1);
   begin
      pragma Assert (Static => Next =
        Advance (Ordered (Values, S, U, V, Index), Values, S, U, V, Index));
   end Model_Step;

   function Component (Values : Row; S, U, V : Unit_Value) return Real is
      Acc : Real := 0.0;
   begin
      for J in Step_Index loop
         pragma Loop_Invariant (Static => Acc in -Real (J) * 3.0e11 .. Real (J) * 3.0e11);
         pragma Loop_Invariant (Static => Acc = Ordered (Values, S, U, V, J));
         Model_Step (Acc, Values, S, U, V, J);
         Acc := Advance (Acc, Values, S, U, V, J);
      end loop;
      return Acc;
   end Component;

   function Gather (G : W.Grid; P : W.Grid_Point;
     Nodes : MJ.Contact_Geometry.Vertex_Array) return Stencil is
     [for K in Axis => [for T in W.Term_Index =>
       Nodes (W.Flat (G, W.Term_Point (G, P, T))) (K)]];

   procedure Reconstruct (G : W.Grid; P : W.Grid_Point;
     Nodes : MJ.Contact_Geometry.Vertex_Array; Result : out Vec) is
      Values : constant Stencil := Gather (G, P, Nodes);
      S : constant Unit_Value := W.Local (P (0), G (0));
      U : constant Unit_Value := W.Local (P (1), G (1));
      V : constant Unit_Value := W.Local (P (2), G (2));
   begin
      Result := [Component (Values (0), S, U, V), Component (Values (1), S, U, V),
                 Component (Values (2), S, U, V)];
   end Reconstruct;
end MJ.Flex_Shell_Geometry;

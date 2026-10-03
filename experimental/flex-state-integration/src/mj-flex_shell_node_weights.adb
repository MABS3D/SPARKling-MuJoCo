package body MJ.Flex_Shell_Node_Weights with SPARK_Mode is
   function Unflat (G : SW.Grid; Index : Natural) return SW.Grid_Point is
      Rest : constant Natural := Index / G (2);
   begin
      return [Rest / G (1), Rest mod G (1), Index mod G (2)];
   end Unflat;

   procedure Widen (E : SW.Endpoint; Before, After : SW.Prefix_Count) is
   begin
      pragma Assert (Static => Real (Before) * 65.0 <= Real (After) * 65.0);
      pragma Assert (Static => -Real (After) * 65.0 <= -Real (Before) * 65.0);
   end Widen;

   function Signed (Weight : FI.Basis_Value; Sgn : NW.Sign_Value) return SW.Weight_Value is
     (Real (Sgn) * Weight);

   function Bounded_Terms (G : SW.Grid; P : SW.Grid_Point;
     Bodies : SW.Node_Bodies; Weight : SW.Weight_Value) return SW.Term_Array is
      R : constant SW.Term_Array := SW.Model_Terms (G, P, Bodies, Weight);
   begin
      for T in SW.Term_Index loop
         declare
            Expected : constant SW.Weight_Value := SW.Term_Weight
              (SW.Local (P (0), G (0)), SW.Local (P (1), G (1)),
               SW.Local (P (2), G (2)), Weight, T);
         begin
            pragma Assert (Static => R (T).Weight = Expected);
         end;
         pragma Loop_Invariant (Static =>
           (for all K in 0 .. T => R (K).Weight in SW.Weight_Value));
      end loop;
      return R;
   end Bounded_Terms;

   procedure Same_Find (Left, Right : SW.Endpoint; Id : Natural)
     with Ghost => Static, Global => null, Pre => Left = Right,
       Post => SW.Find (Left, Id) = SW.Find (Right, Id);
   procedure Same_Find (Left, Right : SW.Endpoint; Id : Natural) is
      L : constant SW.Prefix_Count := SW.Find (Left, Id);
      R : constant SW.Prefix_Count := SW.Find (Right, Id);
   begin
      if L < R then
         pragma Assert (Static => Left.Items (L).Body_Id = Id);
         pragma Assert (Static => Right.Items (L).Body_Id /= Id);
         pragma Assert (Static => Left.Items (L).Body_Id = Right.Items (L).Body_Id);
      elsif R < L then
         pragma Assert (Static => Right.Items (R).Body_Id = Id);
         pragma Assert (Static => Left.Items (R).Body_Id /= Id);
         pragma Assert (Static => Right.Items (R).Body_Id = Left.Items (R).Body_Id);
      end if;
   end Same_Find;

   procedure Same_Add (A, B : Real; X, Y : SW.Weight_Value)
     with Ghost => Static, Global => null,
       Pre => A in -50_000.0 .. 50_000.0 and then A = B and then X = Y,
       Post => A + X = B + Y;
   procedure Same_Add (A, B : Real; X, Y : SW.Weight_Value) is
   begin
      null;
   end Same_Add;

   procedure Same_Term (Left, Right : SW.Endpoint; X, Y : SW.Body_Weight;
     Visited : SW.Prefix_Count)
     with Ghost => Static, Global => null,
       Pre => Visited < 729 and then SW.Bounded (Left, Visited)
         and then SW.Bounded (Right, Visited) and then Left = Right and then X = Y
         and then X.Weight in SW.Weight_Value and then Y.Weight in SW.Weight_Value,
       Post => SW.After (Left, X, Visited) = SW.After (Right, Y, Visited);
   procedure Same_Term (Left, Right : SW.Endpoint; X, Y : SW.Body_Weight;
     Visited : SW.Prefix_Count) is
      L : constant SW.Endpoint := SW.After (Left, X, Visited);
      R : constant SW.Endpoint := SW.After (Right, Y, Visited);
      J : constant SW.Prefix_Count := SW.Find (Left, X.Body_Id);
   begin
      Same_Find (Left, Right, X.Body_Id);
      pragma Assert (Static => L.Count = R.Count);
      for I in SW.Body_Weights'Range loop
         if I = J and then I < Left.Count then
            Same_Add (Left.Items (I).Weight, Right.Items (I).Weight, X.Weight, Y.Weight);
         end if;
         pragma Assert (Static => L.Items (I).Body_Id = R.Items (I).Body_Id);
         pragma Assert (Static => L.Items (I).Weight = R.Items (I).Weight);
         pragma Loop_Invariant (Static => (for all K in 0 .. I => L.Items (K) = R.Items (K)));
      end loop;
   end Same_Term;

   procedure Same_Expansion (Left, Right : SW.Endpoint; X, Y : SW.Term_Array;
     Count : SW.Term_Count; Visited : SW.Prefix_Count)
     with Ghost => Static, Global => null, Subprogram_Variant => (Decreases => Count),
       Pre => Visited <= 676 and then SW.Bounded (Left, Visited)
         and then SW.Bounded (Right, Visited) and then Left = Right and then X = Y
         and then (for all T of X => T.Weight in SW.Weight_Value)
         and then (for all T of Y => T.Weight in SW.Weight_Value),
       Post => SW.Fold (Left, X, Count, Visited) = SW.Fold (Right, Y, Count, Visited);
   procedure Same_Expansion (Left, Right : SW.Endpoint; X, Y : SW.Term_Array;
     Count : SW.Term_Count; Visited : SW.Prefix_Count) is
   begin
      if Count = 0 then return; end if;
      Same_Expansion (Left, Right, X, Y, Count - 1, Visited);
      Same_Term (SW.Fold (Left, X, Count - 1, Visited),
                 SW.Fold (Right, Y, Count - 1, Visited),
                 X (Count - 1), Y (Count - 1), (Visited + Count) - 1);
   end Same_Expansion;

   procedure Same_Fold (E, Value : SW.Endpoint; Terms, Expected : SW.Term_Array;
     Visited : SW.Prefix_Count)
     with Ghost => Static, Global => null,
       Pre => Visited <= 676 and then SW.Bounded (E, Visited)
         and then (for all X of Terms => X.Weight in SW.Weight_Value)
         and then (for all X of Expected => X.Weight in SW.Weight_Value)
         and then Terms = Expected and then Value = SW.Fold (E, Terms, 26, Visited),
       Post => Value = SW.Fold (E, Expected, 26, Visited);
   procedure Same_Fold (E, Value : SW.Endpoint; Terms, Expected : SW.Term_Array;
     Visited : SW.Prefix_Count) is
   begin
      Same_Expansion (E, E, Terms, Expected, 26, Visited);
   end Same_Fold;

   function After_Node (E : SW.Endpoint; G : SW.Grid; Bodies : SW.Node_Bodies;
     Index : Natural; Weight : FI.Basis_Value; Sgn : NW.Sign_Value;
     Visited : SW.Prefix_Count) return SW.Endpoint is
      R : SW.Endpoint := E;
      P : constant SW.Grid_Point := Unflat (G, Index);
      Terms : SW.Term_Array;
   begin
      if Weight < 1.0e-5 then
         Widen (R, Visited, Visited + 26);
      elsif SW.Inside (G, P) then
         declare
            Expected : constant SW.Term_Array := Bounded_Terms
              (G, P, Bodies, Signed (Weight, Sgn)) with Ghost => Static;
         begin
            SW.Generate (G, P, Bodies, Signed (Weight, Sgn), Terms);
            pragma Assert (Static => Terms = Expected);
            pragma Assert (Static => (for all X of Terms => X.Weight in SW.Weight_Value));
            SW.Accumulate (R, Terms, Visited);
            pragma Assert (Static => R = SW.Fold (E, Terms, 26, Visited));
            Same_Fold (E, R, Terms, Expected, Visited);
         end;
      else
         SW.Merge (R, Bodies (Index), Signed (Weight, Sgn), Visited);
         Widen (R, Visited + 1, Visited + 26);
      end if;
      return R;
   end After_Node;

   function Fold (G : SW.Grid; Bodies : SW.Node_Bodies; Indices : FI.Node_Indices;
     Values : FI.Basis_Array; Sgn : NW.Sign_Value; Count : FI.Prefix_Count) return SW.Endpoint is
   begin
      if Count = 0 then return (others => <>); end if;
      return After_Node (Fold (G, Bodies, Indices, Values, Sgn, Count - 1),
        G, Bodies, Indices (Count - 1), Values (Count - 1), Sgn, (Count - 1) * 26);
   end Fold;

   procedure Same_After (E, Prev, Next : SW.Endpoint; G : SW.Grid;
     Bodies : SW.Node_Bodies; Index : Natural; Weight : FI.Basis_Value;
     Sgn : NW.Sign_Value; Visited : SW.Prefix_Count)
     with Ghost => Static, Global => null,
       Pre => Bodies'First = 0 and then SW.Total_Nodes (G) = Int64 (Bodies'Length)
         and then SW.Total_Nodes (G) <= Int64 (Natural'Last)
         and then Index in Bodies'Range and then Sgn /= 0 and then Visited <= 676
         and then SW.Bounded (E, Visited) and then SW.Bounded (Prev, Visited)
         and then E = Prev
         and then Next = After_Node (Prev, G, Bodies, Index, Weight, Sgn, Visited),
       Post => After_Node (E, G, Bodies, Index, Weight, Sgn, Visited) = Next;
   procedure Same_After (E, Prev, Next : SW.Endpoint; G : SW.Grid;
     Bodies : SW.Node_Bodies; Index : Natural; Weight : FI.Basis_Value;
     Sgn : NW.Sign_Value; Visited : SW.Prefix_Count) is
      L : constant SW.Endpoint := After_Node (E, G, Bodies, Index, Weight, Sgn, Visited);
      R : constant SW.Endpoint := After_Node (Prev, G, Bodies, Index, Weight, Sgn, Visited);
      P : constant SW.Grid_Point := Unflat (G, Index);
   begin
      if Weight < 1.0e-5 then
         pragma Assert (Static => L = R);
         pragma Assert (Static => R = Next);
         return;
      end if;
      if SW.Inside (G, P) then
         declare Terms : constant SW.Term_Array := Bounded_Terms (G, P, Bodies, Signed (Weight, Sgn)); begin
            pragma Assert (Static => L = SW.Fold (E, Terms, 26, Visited));
            pragma Assert (Static => R = SW.Fold (Prev, Terms, 26, Visited));
            Same_Expansion (E, Prev, Terms, Terms, 26, Visited);
            pragma Assert (Static => L = R);
         end;
      else
         Same_Find (E, Prev, Bodies (Index));
         pragma Assert (Static => L.Count = R.Count);
         for I in SW.Body_Weights'Range loop
            if I = SW.Find (E, Bodies (Index)) and then I < E.Count then
               Same_Add (E.Items (I).Weight, Prev.Items (I).Weight,
                 Signed (Weight, Sgn), Signed (Weight, Sgn));
            end if;
            pragma Assert (Static => L.Items (I).Body_Id = R.Items (I).Body_Id);
            pragma Assert (Static => L.Items (I).Weight = R.Items (I).Weight);
            pragma Loop_Invariant (Static => (for all K in 0 .. I => L.Items (K) = R.Items (K)));
         end loop;
      end if;
      pragma Assert (Static => L = R);
      pragma Assert (Static => R = Next);
   end Same_After;

   procedure Fold_Step (G : SW.Grid; Bodies : SW.Node_Bodies; Indices : FI.Node_Indices;
     Values : FI.Basis_Array; Sgn : NW.Sign_Value; Count : FI.Prefix_Count; E : SW.Endpoint)
     with Ghost => Static, Global => null,
       Pre => Valid_Layout (G, Bodies, Indices) and then Sgn /= 0 and then Count < 27
         and then SW.Bounded (E, Count * 26)
         and then E = Fold (G, Bodies, Indices, Values, Sgn, Count),
       Post => After_Node (E, G, Bodies, Indices (Count), Values (Count), Sgn, Count * 26) =
         Fold (G, Bodies, Indices, Values, Sgn, Count + 1);
   procedure Fold_Step (G : SW.Grid; Bodies : SW.Node_Bodies; Indices : FI.Node_Indices;
     Values : FI.Basis_Array; Sgn : NW.Sign_Value; Count : FI.Prefix_Count; E : SW.Endpoint) is
      Prev : constant SW.Endpoint := Fold (G, Bodies, Indices, Values, Sgn, Count);
      Next : constant SW.Endpoint := Fold (G, Bodies, Indices, Values, Sgn, Count + 1);
   begin
      pragma Assert (Static => E = Prev);
      pragma Assert (Static => Next = After_Node
        (Prev, G, Bodies, Indices (Count), Values (Count), Sgn, Count * 26));
      Same_After (E, Prev, Next, G, Bodies, Indices (Count), Values (Count), Sgn, Count * 26);
   end Fold_Step;

   procedure Build (G : SW.Grid; Bodies : SW.Node_Bodies; Indices : FI.Node_Indices;
     Values : FI.Basis_Array; Sgn : NW.Sign_Value; Count : FI.Prefix_Count;
     Result : out SW.Endpoint) is
   begin
      Result := (others => <>);
      for J in 0 .. Integer (Count) - 1 loop
         pragma Loop_Invariant (Static => SW.Bounded (Result, J * 26));
         pragma Loop_Invariant (Static => Result = Fold (G, Bodies, Indices, Values, Sgn, J));
         Fold_Step (G, Bodies, Indices, Values, Sgn, J, Result);
         Result := After_Node (Result, G, Bodies, Indices (J), Values (J), Sgn, J * 26);
         pragma Assert (Static => Result = Fold (G, Bodies, Indices, Values, Sgn, J + 1));
      end loop;
   end Build;
end MJ.Flex_Shell_Node_Weights;

package body MJ.Flex_Shell_Weights with SPARK_Mode is
   function Flat (G : Grid; P : Grid_Point) return Natural is
     (Natural ((Int64 (P (0)) * Int64 (G (1)) + Int64 (P (1))) * Int64 (G (2)) + Int64 (P (2))));
   function Ratio (Numerator, Denominator : Real) return Unit_Value is
     (Numerator / Denominator);
   function Local (Index : Natural; Nodes : Node_Count) return Unit_Value is
   begin
      pragma Assert (Static => Index <= Nodes - 1);
      pragma Assert (Static => Real (Index) <= Real (Nodes - 1));
      return Ratio (Real (Index), Real (Nodes - 1));
   end Local;
   function Scale (Weight : Weight_Value; Factor : Unit_Value) return Weight_Value is
     (Weight * Factor);

   function Term_Weight (S, U, V : Unit_Value; W : Weight_Value; T : Term_Index)
     return Weight_Value is
   begin
      case T is
         when 0 => return Scale (W, 1.0 - S); when 1 => return Scale (W, S);
         when 2 => return Scale (W, 1.0 - U); when 3 => return Scale (W, U);
         when 4 => return Scale (W, 1.0 - V); when 5 => return Scale (W, V);
         when 6 => return Scale (Scale (-W, 1.0 - U), 1.0 - V);
         when 7 => return Scale (Scale (-W, 1.0 - U), V);
         when 8 => return Scale (Scale (-W, U), 1.0 - V);
         when 9 => return Scale (Scale (-W, U), V);
         when 10 => return Scale (Scale (-W, 1.0 - S), 1.0 - V);
         when 11 => return Scale (Scale (-W, 1.0 - S), V);
         when 12 => return Scale (Scale (-W, S), 1.0 - V);
         when 13 => return Scale (Scale (-W, S), V);
         when 14 => return Scale (Scale (-W, 1.0 - S), 1.0 - U);
         when 15 => return Scale (Scale (-W, 1.0 - S), U);
         when 16 => return Scale (Scale (-W, S), 1.0 - U);
         when 17 => return Scale (Scale (-W, S), U);
         when 18 => return Scale (Scale (Scale (W, 1.0 - S), 1.0 - U), 1.0 - V);
         when 19 => return Scale (Scale (Scale (W, 1.0 - S), 1.0 - U), V);
         when 20 => return Scale (Scale (Scale (W, 1.0 - S), U), 1.0 - V);
         when 21 => return Scale (Scale (Scale (W, 1.0 - S), U), V);
         when 22 => return Scale (Scale (Scale (W, S), 1.0 - U), 1.0 - V);
         when 23 => return Scale (Scale (Scale (W, S), 1.0 - U), V);
         when 24 => return Scale (Scale (Scale (W, S), U), 1.0 - V);
         when 25 => return Scale (Scale (Scale (W, S), U), V);
      end case;
   end Term_Weight;

   function Model_Terms (G : Grid; P : Grid_Point; Bodies : Node_Bodies;
     W : Weight_Value) return Term_Array is
     [for T in Term_Index =>
       (Bodies (Flat (G, Term_Point (G, P, T))),
        Term_Weight (Local (P (0), G (0)), Local (P (1), G (1)), Local (P (2), G (2)), W, T))];

   procedure Generate (G : Grid; P : Grid_Point; Bodies : Node_Bodies;
     W : Weight_Value; Terms : out Term_Array) is
      S : constant Unit_Value := Local (P (0), G (0));
      U : constant Unit_Value := Local (P (1), G (1));
      V : constant Unit_Value := Local (P (2), G (2));
   begin
      Terms := [for T in Term_Index =>
        (Bodies (Flat (G, Term_Point (G, P, T))), Term_Weight (S, U, V, W, T))];
   end Generate;

   function Find (E : Endpoint; Body_Id : Natural) return Prefix_Count is
   begin
      for J in 0 .. Integer (E.Count) - 1 loop
         if E.Items (J).Body_Id = Body_Id then return J; end if;
         pragma Loop_Invariant (for all K in 0 .. J => E.Items (K).Body_Id /= Body_Id);
      end loop;
      return E.Count;
   end Find;

   function Add_Weight (Value : Real; Weight : Weight_Value; Visited : Prefix_Count) return Real is
     (Value + Weight);

   procedure Merge (E : in out Endpoint; Body_Id : Natural;
     Weight : Weight_Value; Visited : Prefix_Count) is
      J : constant Prefix_Count := Find (E, Body_Id);
   begin
      pragma Assert (Static => Real (Visited) * 65.0 <= Real (Visited + 1) * 65.0);
      pragma Assert (Static => -Real (Visited + 1) * 65.0 <= -Real (Visited) * 65.0);
      pragma Assert (Static => (for all X of E.Items =>
        X.Weight in -Real (Visited + 1) * 65.0 .. Real (Visited + 1) * 65.0));
      if J < E.Count then
         E.Items (J).Weight := Add_Weight (E.Items (J).Weight, Weight, Visited);
      else
         E.Items (J) := (Body_Id, Weight);
         E.Count := E.Count + 1;
      end if;
   end Merge;

   function After (E : Endpoint; Term : Body_Weight; Visited : Prefix_Count) return Endpoint is
      R : Endpoint := E;
   begin
      Merge (R, Term.Body_Id, Term.Weight, Visited);
      return R;
   end After;

   function Fold (E : Endpoint; Terms : Term_Array; Count : Term_Count;
     Visited : Prefix_Count) return Endpoint is
   begin
      if Count = 0 then return E; end if;
      return After (Fold (E, Terms, Count - 1, Visited), Terms (Count - 1), Visited + Count - 1);
   end Fold;

   procedure Accumulate (E : in out Endpoint; Terms : Term_Array; Visited : Prefix_Count) is
      Initial : constant Endpoint := E with Ghost => Static;
   begin
      for T in Term_Index loop
         pragma Loop_Invariant (Static => Bounded (E, Visited + T));
         pragma Loop_Invariant (Static => E = Fold (Initial, Terms, T, Visited));
         Merge (E, Terms (T).Body_Id, Terms (T).Weight, Visited + T);
      end loop;
   end Accumulate;
end MJ.Flex_Shell_Weights;

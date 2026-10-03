with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

--  MuJoCo 3.14.0 mju_shellTFIWeights. Shell terms retain their signs and
--  zero coefficients; the caller applies the basis cutoff before expansion.
--  This separate capacity must not be substituted for the 27-node endpoint.
package MJ.Flex_Shell_Weights with SPARK_Mode is
   subtype Node_Count is Positive range 2 .. 8193;
   type Grid is array (Axis) of Node_Count;
   type Grid_Point is array (Axis) of Natural;
   type Node_Bodies is array (Natural range <>) of Natural;
   subtype Term_Index is Natural range 0 .. 25;
   subtype Term_Count is Natural range 0 .. 26;
   subtype Unit_Value is Real range 0.0 .. 1.0;
   subtype Weight_Value is Real range -64.0 .. 64.0;
   subtype Prefix_Count is Natural range 0 .. 729;
   type Body_Weight is record
      Body_Id : Natural := 0;
      Weight : Real := 0.0;
   end record;
   type Term_Array is array (Term_Index) of Body_Weight;
   type Body_Weights is array (Natural range 0 .. 728) of Body_Weight;
   type Endpoint is record
      Count : Prefix_Count := 0;
      Items : Body_Weights := [others => <>];
   end record;

   function Total_Nodes (G : Grid) return Int64 is
     (Int64 (G (0)) * Int64 (G (1)) * Int64 (G (2)));
   function Inside (G : Grid; P : Grid_Point) return Boolean is
     (for all K in Axis => P (K) > 0 and then P (K) < G (K) - 1);
   function Flat (G : Grid; P : Grid_Point) return Natural
     with Global => null,
       Pre => Total_Nodes (G) <= Int64 (Natural'Last)
         and then (for all K in Axis => P (K) < G (K)),
       Post => Int64 (Flat'Result) < Total_Nodes (G)
         and then Int64 (Flat'Result) =
           (Int64 (P (0)) * Int64 (G (1)) + Int64 (P (1))) * Int64 (G (2)) + Int64 (P (2));
   function Local (Index : Natural; Nodes : Node_Count) return Unit_Value
     with Global => null, Pre => Index < Nodes,
       Post => Local'Result = Real (Index) / Real (Nodes - 1);
   function Ratio (Numerator, Denominator : Real) return Unit_Value
     with Global => null, Inline,
       Pre => Numerator in 0.0 .. 8192.0 and then Denominator in 1.0 .. 8192.0
         and then Numerator <= Denominator,
       Post => Ratio'Result = Numerator / Denominator;
   function Scale (Weight : Weight_Value; Factor : Unit_Value) return Weight_Value
     with Global => null, Inline, Post => Scale'Result = Weight * Factor;

   function Term_Point (G : Grid; P : Grid_Point; T : Term_Index) return Grid_Point is
     (case T is
        when 0 => [0, P (1), P (2)], when 1 => [G (0) - 1, P (1), P (2)],
        when 2 => [P (0), 0, P (2)], when 3 => [P (0), G (1) - 1, P (2)],
        when 4 => [P (0), P (1), 0], when 5 => [P (0), P (1), G (2) - 1],
        when 6 => [P (0), 0, 0], when 7 => [P (0), 0, G (2) - 1],
        when 8 => [P (0), G (1) - 1, 0], when 9 => [P (0), G (1) - 1, G (2) - 1],
        when 10 => [0, P (1), 0], when 11 => [0, P (1), G (2) - 1],
        when 12 => [G (0) - 1, P (1), 0], when 13 => [G (0) - 1, P (1), G (2) - 1],
        when 14 => [0, 0, P (2)], when 15 => [0, G (1) - 1, P (2)],
        when 16 => [G (0) - 1, 0, P (2)], when 17 => [G (0) - 1, G (1) - 1, P (2)],
        when 18 => [0, 0, 0], when 19 => [0, 0, G (2) - 1],
        when 20 => [0, G (1) - 1, 0], when 21 => [0, G (1) - 1, G (2) - 1],
        when 22 => [G (0) - 1, 0, 0], when 23 => [G (0) - 1, 0, G (2) - 1],
        when 24 => [G (0) - 1, G (1) - 1, 0],
        when 25 => [G (0) - 1, G (1) - 1, G (2) - 1])
     with Global => null, Pre => Inside (G, P),
       Post => (for all K in Axis => Term_Point'Result (K) < G (K));

   function Term_Weight (S, U, V : Unit_Value; W : Weight_Value; T : Term_Index)
     return Weight_Value
     with Global => null,
       Contract_Cases =>
         (T = 0 => Term_Weight'Result = W * (1.0 - S),
          T = 1 => Term_Weight'Result = W * S,
          T = 2 => Term_Weight'Result = W * (1.0 - U),
          T = 3 => Term_Weight'Result = W * U,
          T = 4 => Term_Weight'Result = W * (1.0 - V),
          T = 5 => Term_Weight'Result = W * V,
          T = 6 => Term_Weight'Result = (-W * (1.0 - U)) * (1.0 - V),
          T = 7 => Term_Weight'Result = (-W * (1.0 - U)) * V,
          T = 8 => Term_Weight'Result = (-W * U) * (1.0 - V),
          T = 9 => Term_Weight'Result = (-W * U) * V,
          T = 10 => Term_Weight'Result = (-W * (1.0 - S)) * (1.0 - V),
          T = 11 => Term_Weight'Result = (-W * (1.0 - S)) * V,
          T = 12 => Term_Weight'Result = (-W * S) * (1.0 - V),
          T = 13 => Term_Weight'Result = (-W * S) * V,
          T = 14 => Term_Weight'Result = (-W * (1.0 - S)) * (1.0 - U),
          T = 15 => Term_Weight'Result = (-W * (1.0 - S)) * U,
          T = 16 => Term_Weight'Result = (-W * S) * (1.0 - U),
          T = 17 => Term_Weight'Result = (-W * S) * U,
          T = 18 => Term_Weight'Result = ((W * (1.0 - S)) * (1.0 - U)) * (1.0 - V),
          T = 19 => Term_Weight'Result = ((W * (1.0 - S)) * (1.0 - U)) * V,
          T = 20 => Term_Weight'Result = ((W * (1.0 - S)) * U) * (1.0 - V),
          T = 21 => Term_Weight'Result = ((W * (1.0 - S)) * U) * V,
          T = 22 => Term_Weight'Result = ((W * S) * (1.0 - U)) * (1.0 - V),
          T = 23 => Term_Weight'Result = ((W * S) * (1.0 - U)) * V,
          T = 24 => Term_Weight'Result = ((W * S) * U) * (1.0 - V),
          T = 25 => Term_Weight'Result = ((W * S) * U) * V);

   function Model_Terms (G : Grid; P : Grid_Point; Bodies : Node_Bodies;
     W : Weight_Value) return Term_Array
     with Ghost => Static, Global => null,
       Pre => Inside (G, P) and then Bodies'First = 0
         and then Total_Nodes (G) = Int64 (Bodies'Length)
         and then Total_Nodes (G) <= Int64 (Natural'Last),
       Post => (Static => (for all T in Term_Index =>
         Model_Terms'Result (T).Body_Id = Bodies (Flat (G, Term_Point (G, P, T)))
         and then Model_Terms'Result (T).Weight = Term_Weight
           (Local (P (0), G (0)), Local (P (1), G (1)), Local (P (2), G (2)), W, T)));
   procedure Generate (G : Grid; P : Grid_Point; Bodies : Node_Bodies;
     W : Weight_Value; Terms : out Term_Array)
     with Global => null, Relaxed_Initialization => Terms,
       Pre => Inside (G, P) and then Bodies'First = 0
         and then Total_Nodes (G) = Int64 (Bodies'Length)
         and then Total_Nodes (G) <= Int64 (Natural'Last),
       Post => (Static => Terms'Initialized and then Terms = Model_Terms (G, P, Bodies, W));

   function Bounded (E : Endpoint; Visited : Prefix_Count) return Boolean is
     (E.Count <= Visited and then (for all X of E.Items =>
       X.Weight in -Real (Visited) * 65.0 .. Real (Visited) * 65.0));
   function Find (E : Endpoint; Body_Id : Natural) return Prefix_Count
     with Global => null,
       Post => Find'Result <= E.Count
         and then (if Find'Result < E.Count then E.Items (Find'Result).Body_Id = Body_Id)
         and then (for all J in 0 .. Integer (Find'Result) - 1 => E.Items (J).Body_Id /= Body_Id);
   function Add_Weight (Value : Real; Weight : Weight_Value; Visited : Prefix_Count) return Real
     with Global => null, Inline,
       Pre => Visited < 729
         and then Value in -Real (Visited) * 65.0 .. Real (Visited) * 65.0,
       Post => Add_Weight'Result = Value + Weight
         and then Add_Weight'Result in -Real (Visited + 1) * 65.0 .. Real (Visited + 1) * 65.0;
   procedure Merge (E : in out Endpoint; Body_Id : Natural;
     Weight : Weight_Value; Visited : Prefix_Count)
     with Global => null,
       Pre => Visited < 729 and then Bounded (E, Visited),
       Post => (Static => Bounded (E, Visited + 1)
         and then E.Count = (if Find (E'Old, Body_Id) < E'Old.Count
           then E'Old.Count else E'Old.Count + 1)
         and then (for all J in E.Items'Range =>
           (if J = Find (E'Old, Body_Id) then
              E.Items (J).Body_Id = Body_Id and then E.Items (J).Weight =
                (if J < E'Old.Count then E'Old.Items (J).Weight + Weight else Weight)
            else E.Items (J) = E'Old.Items (J))));

   function After (E : Endpoint; Term : Body_Weight; Visited : Prefix_Count) return Endpoint
     with Ghost => Static, Global => null,
       Pre => (Static => Visited < 729 and then Bounded (E, Visited)
         and then Term.Weight in Weight_Value),
       Post => (Static => Bounded (After'Result, Visited + 1)
         and then After'Result.Count = (if Find (E, Term.Body_Id) < E.Count
           then E.Count else E.Count + 1)
         and then (for all J in E.Items'Range =>
           (if J = Find (E, Term.Body_Id) then
              After'Result.Items (J).Body_Id = Term.Body_Id
              and then After'Result.Items (J).Weight =
                (if J < E.Count then E.Items (J).Weight + Term.Weight else Term.Weight)
            else After'Result.Items (J) = E.Items (J))));
   function Fold (E : Endpoint; Terms : Term_Array; Count : Term_Count;
     Visited : Prefix_Count) return Endpoint
     with Ghost => Static, Global => null, Subprogram_Variant => (Decreases => Count),
       Pre => (Static => Visited <= 703 and then Bounded (E, Visited)
         and then (for all X of Terms => X.Weight in Weight_Value)),
       Post => (Static => Bounded (Fold'Result, Visited + Count)
         and then Fold'Result = (if Count = 0 then E else
           After (Fold (E, Terms, Count - 1, Visited), Terms (Count - 1), Visited + Count - 1)));
   procedure Accumulate (E : in out Endpoint; Terms : Term_Array; Visited : Prefix_Count)
     with Global => null,
       Pre => Visited <= 703 and then Bounded (E, Visited)
         and then (for all X of Terms => X.Weight in Weight_Value),
       Post => (Static => Bounded (E, Visited + 26)
         and then E = Fold (E'Old, Terms, 26, Visited));
end MJ.Flex_Shell_Weights;

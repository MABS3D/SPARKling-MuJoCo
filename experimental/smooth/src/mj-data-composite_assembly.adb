with MJ.Composite_Bounds;
with MJ.Composite_Weights;
with MJ.Spatial_Storage;
package body MJ.Data.Composite_Assembly with SPARK_Mode is
   use type SK.Inertia;
   package CB renames MJ.Composite_Bounds;
   package CW renames MJ.Composite_Weights;
   procedure Reveal_Accumulation_Model
     (Bodies : Body_Parameter_Array; Initial : Composite_Array; Steps : Natural)
     with Ghost => Static, Global => null,
       Pre => Composite_Layout (Bodies, Initial) and then Steps <= Initial'Last
         and then (for all X of Initial => SK.Bounded (X, 1.0e40)),
       Post => (if Steps = 0 then Accumulation_Model (Bodies, Initial, Steps) =
         Composite_State'(Last => Initial'Last, Values => Initial, Ok => True)
         else Accumulation_Model (Bodies, Initial, Steps) =
           Model_Step (Accumulation_Model (Bodies, Initial, Steps - 1),
             Initial'Last - Steps + 1, Bodies (Initial'Last - Steps + 1).Parent))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Step);
   begin
      null;
   end Reveal_Accumulation_Model;

   procedure Initialize_Accumulation_Model
     (Bodies : Body_Parameter_Array; Initial : Composite_Array)
     with Ghost => Static, Global => null,
       Pre => Composite_Layout (Bodies, Initial)
         and then (for all X of Initial => SK.Bounded (X, 1.0e40)),
       Post => Accumulation_Model (Bodies, Initial, 0).Ok
         and then Accumulation_Model (Bodies, Initial, 0).Values = Initial
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Step);
   begin
      null;
   end Initialize_Accumulation_Model;

   procedure Prove_Model_Step_Component
     (Before : Composite_State; B, P, K : Natural; J : Natural)
     with Ghost => Static, Global => null,
       Pre => Before.Ok and then B <= Before.Last and then P < B
         and then K <= Before.Last and then J in SK.Inertia'Range
         and then (for all X of Before.Values => SK.Bounded (X, 1.0e40))
         and then (if P > 0 then SK.Bounded
           (SK.Add (Before.Values (P), Before.Values (B)), 1.0e40)),
       Post => Model_Step (Before, B, P).Ok
         and then Model_Step (Before, B, P).Values (K) (J) =
         (if P > 0 and then K = P
          then SK.Add (Before.Values (P), Before.Values (B)) (J)
          else Before.Values (K) (J))
   is
   begin
      null;
   end Prove_Model_Step_Component;

   procedure Equal_Composites (Left, Right : Composite_Array)
     with Ghost => Static, Global => null,
       Pre => Left'First = Right'First and then Left'Last = Right'Last
         and then (for all K in Left'Range =>
           (for all J in SK.Inertia'Range => Left (K) (J) = Right (K) (J))),
       Post => Left = Right
   is
   begin
      null;
   end Equal_Composites;

   procedure Extend_Composite_Equality
     (Left, Right : Composite_Array; Last : Natural)
     with Ghost => Static, Global => null,
       Pre => Left'First = Right'First and then Left'Last = Right'Last
         and then Last in Left'Range
         and then (for all I in Left'First .. Last - 1 =>
           (for all J in SK.Inertia'Range => Left (I) (J) = Right (I) (J)))
         and then (for all J in SK.Inertia'Range => Left (Last) (J) = Right (Last) (J)),
       Post => (for all I in Left'First .. Last =>
         (for all J in SK.Inertia'Range => Left (I) (J) = Right (I) (J)))
   is
   begin
      null;
   end Extend_Composite_Equality;

   procedure Prove_Model_Step_Update
     (Before : Composite_State; After : Composite_Array; B, P : Natural)
     with Ghost => Static, Global => null,
       Pre => Before.Ok and then B <= Before.Last and then P < B
         and then (for all X of Before.Values => SK.Bounded (X, 1.0e40))
         and then After'First = 0 and then After'Last = Before.Last
         and then (if P > 0 then SK.Bounded
           (SK.Add (Before.Values (P), Before.Values (B)), 1.0e40))
         and then (for all K in After'Range => (for all J in SK.Inertia'Range =>
           After (K) (J) = (if P > 0 and then K = P
             then SK.Add (Before.Values (P), Before.Values (B)) (J)
             else Before.Values (K) (J)))),
       Post => Model_Step (Before, B, P).Ok
         and then After = Model_Step (Before, B, P).Values
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", SK.Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Step);
   begin
      Prove_Model_Step_Component (Before, B, P, After'First, SK.Inertia'First);
      for K in After'Range loop
         for J in SK.Inertia'Range loop
            Prove_Model_Step_Component (Before, B, P, K, J);
            pragma Loop_Invariant (for all I in After'First .. K - 1 =>
              (for all H in SK.Inertia'Range =>
                After (I) (H) = Model_Step (Before, B, P).Values (I) (H)));
            pragma Loop_Invariant (for all H in SK.Inertia'First .. J =>
              After (K) (H) = Model_Step (Before, B, P).Values (K) (H));
         end loop;
         Extend_Composite_Equality (After, Model_Step (Before, B, P).Values, K);
         pragma Loop_Invariant (for all I in After'First .. K =>
           (for all H in SK.Inertia'Range =>
             After (I) (H) = Model_Step (Before, B, P).Values (I) (H)));
      end loop;
      Equal_Composites (After, Model_Step (Before, B, P).Values);
   end Prove_Model_Step_Update;

   procedure Prove_Composite_Row_Equal
     (Left, Right : Composite_Array; I : Natural)
     with Ghost => Static, Global => null,
       Pre => Left'First = Right'First and then Left'Last = Right'Last
         and then I in Left'Range and then Left = Right,
       Post => Left (I) = Right (I)
   is
   begin
      null;
   end Prove_Composite_Row_Equal;

   procedure Prove_Inertia_Entry_Sum_Equal
     (A, B, C, D : SK.Inertia; J : Natural)
     with Ghost => Static, Global => null,
       Pre => J in SK.Inertia'Range
         and then A (J) = C (J) and then B (J) = D (J)
         and then SK.Bounded (A, 1.0e40) and then SK.Bounded (B, 1.0e40)
         and then SK.Bounded (C, 1.0e40) and then SK.Bounded (D, 1.0e40),
       Post => SK.Add (A, B) (J) = SK.Add (C, D) (J)
   is
   begin
      case J is
         when 0 => null;
         when 1 => null;
         when 2 => null;
         when 3 => null;
         when 4 => null;
         when 5 => null;
         when 6 => null;
         when 7 => null;
         when 8 => null;
         when 9 => null;
         when others => null;
      end case;
   end Prove_Inertia_Entry_Sum_Equal;

   procedure Equal_Inertia_Bounds (Left, Right : SK.Inertia; Limit : Real) with
     Ghost => Static, Global => null,
     Pre => Limit >= 0.0 and then Left = Right,
     Post => SK.Bounded (Left, Limit) = SK.Bounded (Right, Limit)
   is
   begin
      null;
   end Equal_Inertia_Bounds;

   procedure Prove_Inertia_Sums_Equal (A, B, C, D : SK.Inertia)
     with Ghost => Static, Global => null,
       Pre => A = C and then B = D
         and then SK.Bounded (A, 1.0e40) and then SK.Bounded (B, 1.0e40)
         and then SK.Bounded (C, 1.0e40) and then SK.Bounded (D, 1.0e40),
       Post => SK.Add (A, B) = SK.Add (C, D)
         and then SK.Bounded (SK.Add (A, B), 1.0e40) =
           SK.Bounded (SK.Add (C, D), 1.0e40)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", SK.Bounded);
   begin
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 0);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 1);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 2);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 3);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 4);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 5);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 6);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 7);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 8);
      Prove_Inertia_Entry_Sum_Equal (A, B, C, D, 9);
      pragma Assert (Static => SK.Add (A, B) = SK.Add (C, D));
      Equal_Inertia_Bounds (SK.Add (A, B), SK.Add (C, D), 1.0e40);
   end Prove_Inertia_Sums_Equal;

   procedure Transfer_Inertia_Bound (Left, Right : SK.Inertia; Limit : Real)
     with Ghost => Static, Global => null,
       Pre => Limit >= 0.0 and then Left = Right and then SK.Bounded (Left, Limit),
       Post => SK.Bounded (Right, Limit)
   is
   begin
      null;
   end Transfer_Inertia_Bound;

   procedure Preserve_Weighted_Prefix
     (Before, After : Composite_Array; Old_Weights, New_Weights : CW.Weight_Array;
      B, P : Natural)
     with Ghost => Static, Global => null,
       Pre => Before'First = 0 and then After'First = 0
         and then After'Last = Before'Last
         and then Old_Weights'First = 0 and then Old_Weights'Last = Before'Last
         and then New_Weights'First = 0 and then New_Weights'Last = Before'Last
         and then P < B and then B <= Before'Last
         and then (for all K in 0 .. B => Old_Weights (K) > 0
           and then SK.Bounded (Before (K), CB.Budget (Old_Weights (K))))
         and then (if P > 0 then New_Weights (P) > 0
           and then SK.Bounded (After (P), CB.Budget (New_Weights (P))))
         and then (for all K in 0 .. B - 1 =>
           (if P = 0 or else K /= P then
              New_Weights (K) = Old_Weights (K) and then After (K) = Before (K))),
       Post => (for all K in 0 .. B - 1 => New_Weights (K) > 0
         and then SK.Bounded (After (K), CB.Budget (New_Weights (K))))
   is
   begin
      for K in 0 .. B - 1 loop
         if P = 0 or else K /= P then
            Transfer_Inertia_Bound (Before (K), After (K), CB.Budget (Old_Weights (K)));
         end if;
         pragma Loop_Invariant (for all I in 0 .. K => New_Weights (I) > 0
           and then SK.Bounded (After (I), CB.Budget (New_Weights (I))));
      end loop;
   end Preserve_Weighted_Prefix;

   procedure Equal_Composite_Transitive (A, B, C : Composite_Array)
     with Ghost => Static, Global => null,
       Pre => A'First = B'First and then A'Last = B'Last
         and then A'First = C'First and then A'Last = C'Last
         and then A = B and then B = C,
       Post => A = C
   is
   begin
      null;
   end Equal_Composite_Transitive;

   procedure Reveal_Accumulation_Values
     (Bodies : Body_Parameter_Array; Initial : Composite_Array; Steps : Natural)
     with Ghost => Static, Global => null,
       Pre => Composite_Layout (Bodies, Initial) and then Steps in 1 .. Initial'Last
         and then (for all X of Initial => SK.Bounded (X, 1.0e40)),
       Post => Accumulation_Model (Bodies, Initial, Steps).Values =
         Model_Step (Accumulation_Model (Bodies, Initial, Steps - 1),
           Initial'Last - Steps + 1, Bodies (Initial'Last - Steps + 1).Parent).Values
         and then Accumulation_Model (Bodies, Initial, Steps).Ok =
         Model_Step (Accumulation_Model (Bodies, Initial, Steps - 1),
           Initial'Last - Steps + 1, Bodies (Initial'Last - Steps + 1).Parent).Ok
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Step);
   begin
      null;
   end Reveal_Accumulation_Values;

   procedure Advance_Accumulation_Model
     (Bodies : Body_Parameter_Array; Initial, After : Composite_Array; Steps : Natural)
     with Ghost => Static, Global => null,
       Pre => Composite_Layout (Bodies, Initial) and then Steps < Initial'Last
         and then After'First = 0 and then After'Last = Initial'Last
         and then (for all X of Initial => SK.Bounded (X, 1.0e40))
         and then Model_Step (Accumulation_Model (Bodies, Initial, Steps),
           Initial'Last - Steps, Bodies (Initial'Last - Steps).Parent).Ok
         and then After = Model_Step (Accumulation_Model (Bodies, Initial, Steps),
           Initial'Last - Steps, Bodies (Initial'Last - Steps).Parent).Values,
       Post => Accumulation_Model (Bodies, Initial, Steps + 1).Ok
         and then After = Accumulation_Model (Bodies, Initial, Steps + 1).Values
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Step);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Accumulation_Model);
   begin
      Reveal_Accumulation_Values (Bodies, Initial, Steps + 1);
      Equal_Composite_Transitive
        (After, Model_Step (Accumulation_Model (Bodies, Initial, Steps),
           Initial'Last - Steps, Bodies (Initial'Last - Steps).Parent).Values,
         Accumulation_Model (Bodies, Initial, Steps + 1).Values);
   end Advance_Accumulation_Model;

   procedure Retire_Weight (W : in out CW.Weight_Array; B, P : Natural)
     with Ghost => Static, Global => null,
       Pre => CW.Layout (W) and then P < B and then B in W'Range
         and then CW.Prefix_Sum (W, W'Length) <= W'Length
         and then (for all K in W'Range => (if K <= B then W (K) > 0 else W (K) = 0)),
       Post => CW.Prefix_Sum (W, W'Length) <= W'Length
         and then (for all K in W'Range => (if K < B then W (K) > 0 else W (K) = 0))
         and then W (B) = 0
         and then (if P > 0 then W (P) = W'Old (P) + W'Old (B))
         and then (for all K in W'Range =>
           (if K /= B and then (P = 0 or else K /= P) then W (K) = W'Old (K)))
   is
   begin
      if P > 0 then CW.Transfer (W, B, P);
      else CW.Discard (W, B); end if;
   end Retire_Weight;

   procedure Expose_Inertia_Equality (Left, Right : SK.Inertia)
     with Ghost => Static, Global => null,
       Pre => Left = Right,
       Post => (for all J in SK.Inertia'Range => Left (J) = Right (J))
   is
   begin
      null;
   end Expose_Inertia_Equality;

   procedure Describe_Model_Update
     (Before : Composite_State; Old_Values, After : Composite_Array; B, P : Natural)
     with Ghost => Static, Global => null,
       Pre => B <= Before.Last and then P < B
         and then Old_Values'First = 0 and then Old_Values'Last = Before.Last
         and then After'First = 0 and then After'Last = Before.Last
         and then Old_Values = Before.Values
         and then (for all X of Before.Values => SK.Bounded (X, 1.0e40))
         and then (if P > 0 then After (P) = SK.Add (Before.Values (P), Before.Values (B)))
         and then (for all K in After'Range =>
           (if P = 0 or else K /= P then After (K) = Old_Values (K))),
       Post => (for all K in After'Range => (for all J in SK.Inertia'Range =>
         After (K) (J) = (if P > 0 and then K = P
           then SK.Add (Before.Values (P), Before.Values (B)) (J)
           else Before.Values (K) (J))))
   is
   begin
      for K in After'Range loop
         if P > 0 and then K = P then
            Expose_Inertia_Equality (After (K), SK.Add (Before.Values (P), Before.Values (B)));
         else
            Prove_Composite_Row_Equal (Old_Values, Before.Values, K);
            Expose_Inertia_Equality (After (K), Before.Values (K));
         end if;
         pragma Loop_Invariant (for all I in After'First .. K =>
           (for all J in SK.Inertia'Range => After (I) (J) =
             (if P > 0 and then I = P then SK.Add (Before.Values (P), Before.Values (B)) (J)
              else Before.Values (I) (J))));
      end loop;
   end Describe_Model_Update;

   procedure Widen_Inertia_Bound (Value : SK.Inertia; Small, Large : Real) with
     Ghost => Static, Global => null,
     Pre => Small >= 0.0 and then Large >= Small and then SK.Bounded (Value, Small),
     Post => SK.Bounded (Value, Large)
   is
   begin
      null;
   end Widen_Inertia_Bound;

   procedure Initialize_Composite_Bounds (Initial : Composite_Array) with
     Ghost => Static, Global => null,
     Pre => Initial'First = 0 and then Initial'Length in 1 .. Max_Bodies
       and then (for all X of Initial => SK.Bounded (X, 1.0e36)),
     Post => (for all X of Initial => SK.Bounded (X, 1.0e40)
       and then SK.Bounded (X, CB.Budget (1)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", SK.Bounded);
   begin
      CB.Budget_Bounds (1);
      for I in Initial'Range loop
         Widen_Inertia_Bound (Initial (I), 1.0e36, 1.0e40);
         Widen_Inertia_Bound (Initial (I), 1.0e36, CB.Budget (1));
         pragma Loop_Invariant (for all K in Initial'First .. I =>
           SK.Bounded (Initial (K), 1.0e40)
           and then SK.Bounded (Initial (K), CB.Budget (1)));
      end loop;
   end Initialize_Composite_Bounds;

   procedure Accumulate_Composite (Bodies : Body_Parameter_Array; Composite : in out Composite_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", SK.Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Accumulation_Model);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Step);
      Weights : CW.Weight_Array (Composite'Range) with Ghost => Static;
      Initial : constant Composite_Array := Composite with Ghost => Static;
   begin
      CW.Initialize (Weights);
      Initialize_Composite_Bounds (Initial);
      pragma Assert (Static => (for all X of Initial => SK.Bounded (X, 1.0e40)));
      Initialize_Accumulation_Model (Bodies, Initial);
      pragma Assert (Static => Composite = Initial);
      pragma Assert (Static => Accumulation_Model (Bodies, Initial, 0).Values = Initial);
      pragma Assert (Static => Composite = Accumulation_Model (Bodies, Initial, 0).Values);
      for B in reverse 1 .. Composite'Last loop
         pragma Loop_Invariant (for all X of Composite => SK.Bounded (X, 1.0e40));
         pragma Loop_Invariant (Static => CW.Prefix_Sum (Weights, Weights'Length) <= Composite'Length);
         pragma Loop_Invariant (Static => (for all K in Weights'Range =>
           (if K <= B then Weights (K) > 0 else Weights (K) = 0)));
         pragma Loop_Invariant (Static => (for all K in 0 .. B =>
           Weights (K) > 0 and then SK.Bounded (Composite (K), CB.Budget (Weights (K)))));
         pragma Loop_Invariant (Static => Accumulation_Model (Bodies, Initial, Composite'Last - B).Ok);
         pragma Loop_Invariant (Static => Composite = Accumulation_Model (Bodies, Initial, Composite'Last - B).Values);
         declare
            P : constant Natural := Bodies (B).Parent;
            Before : constant Composite_State :=
              Accumulation_Model (Bodies, Initial, Composite'Last - B) with Ghost => Static;
            Old_Values : constant Composite_Array := Composite with Ghost => Static;
            Old_Weights : constant CW.Weight_Array := Weights with Ghost => Static;
            Sum : SK.Inertia;
         begin
            if P > 0 then
               Prove_Composite_Row_Equal (Composite, Before.Values, P);
               Prove_Composite_Row_Equal (Composite, Before.Values, B);
               Prove_Inertia_Sums_Equal
                 (Composite (P), Composite (B), Before.Values (P), Before.Values (B));
               CW.Pair_Bound (Weights, Weights'Length, P, B);
               CB.Bound_Inertia_Sum (Composite (P), Composite (B), Weights (P), Weights (B));
               CB.Budget_Bounds (Weights (P) + Weights (B));
               Widen_Inertia_Bound (SK.Add (Composite (P), Composite (B)),
                 CB.Budget (Weights (P) + Weights (B)), 1.0e40);
               Sum := SK.Add (Composite (P), Composite (B));
               pragma Assert (Static => SK.Bounded (Sum, 1.0e40));
               pragma Assert (Static => SK.Bounded
                 (Sum, CB.Budget (Weights (P) + Weights (B))));
               Composite (P) := Sum;
            end if;
            Describe_Model_Update (Before, Old_Values, Composite, B, P);
            Prove_Model_Step_Update (Before, Composite, B, P);
            Retire_Weight (Weights, B, P);
            pragma Assert (Static => (if P > 0 then
              SK.Bounded (Composite (P), CB.Budget (Weights (P)))));
            Preserve_Weighted_Prefix (Old_Values, Composite, Old_Weights, Weights, B, P);
            pragma Assert (Static => Model_Step (Before, B, P).Ok);
            pragma Assert (Static => Composite = Model_Step (Before, B, P).Values);
            Advance_Accumulation_Model (Bodies, Initial, Composite, Composite'Last - B);
         end;
      end loop;
   end Accumulate_Composite;

   procedure Load_Composite (Source : Real_Array; Composite : out Composite_Array) is
   begin
      for B in Composite'Range loop
         Composite (B) := MJ.Spatial_Storage.Load_Inertia (Source, 10 * B);
         pragma Loop_Invariant (for all I in Composite'First .. B => Composite (I)'Initialized);
         pragma Loop_Invariant (for all I in Composite'First .. B =>
           (for all K in SK.Inertia'Range => Composite (I) (K) = Source (10 * I + K)));
      end loop;
   end Load_Composite;
end MJ.Data.Composite_Assembly;

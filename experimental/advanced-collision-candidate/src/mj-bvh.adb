with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.BVH with SPARK_Mode is
   --  Same finite-value selection and first-operand ties as mju_min/mju_max.
   --  Callers prove these bounds; no extra runtime admission scan is needed.
   function Minimum (X, Y : Real) return Real is (if X <= Y then X else Y)
     with Inline, Global => null,
       Pre => X in -1.0e12 .. 1.0e12 and Y in -1.0e12 .. 1.0e12,
       Post => Minimum'Result = Real'Min (X, Y)
         and then Minimum'Result in -1.0e12 .. 1.0e12;
   function Maximum (X, Y : Real) return Real is (if X >= Y then X else Y)
     with Inline, Global => null,
       Pre => X in -1.0e12 .. 1.0e12 and Y in -1.0e12 .. 1.0e12,
       Post => Maximum'Result = Real'Max (X, Y)
         and then Maximum'Result in -1.0e12 .. 1.0e12;

   --  The padding bounds the roundoff of subtraction, inflation and the
   --  reconstructed endpoint. These ghost lemmas have proved bodies; they
   --  introduce no assumptions and disappear from the release executable.
   procedure Lemma_Lower (C, L, M : Real) with Ghost,
     Global => null,
     Pre => M in 1.0 .. 2.0e10 and then abs C <= 3.0 * M and then abs L <= M,
     Post => C - ((C - L) + 32.0 * Real'Model_Epsilon * M) <= L
   is
   begin
      null;
   end Lemma_Lower;

   procedure Lemma_Upper (C, H, M : Real) with Ghost,
     Global => null,
     Pre => M in 1.0 .. 2.0e10 and then abs C <= 3.0 * M and then abs H <= M,
     Post => C + ((H - C) + 32.0 * Real'Model_Epsilon * M) >= H
   is
   begin
      null;
   end Lemma_Upper;

   procedure Lemma_Monotonic (X, Y, Z : Real) with Ghost,
     Global => null,
     Pre => X in -1.0e12 .. 1.0e12 and Y in -1.0e12 .. 1.0e12
       and Z in -1.0e12 .. 1.0e12 and X <= Y,
     Post => X + Z <= Y + Z and then Z - Y <= Z - X
   is
   begin
      null;
   end Lemma_Monotonic;

   procedure Lemma_Transitive (X, Y, Z : Real) with Ghost,
     Global => null,
     Pre => X in -1.0e12 .. 1.0e12 and Y in -1.0e12 .. 1.0e12
       and Z in -1.0e12 .. 1.0e12 and X <= Y and Y <= Z,
     Post => X <= Z
   is
   begin
      null;
   end Lemma_Transitive;

   procedure Enclose (Lo, Hi : Real; Center, Half : out Real) with
     Inline,
     Global => null,
     Pre => Lo in -2.0e10 .. 2.0e10 and Hi in -2.0e10 .. 2.0e10 and Lo <= Hi,
     Post => Center in -6.0e10 .. 6.0e10 and then Half in 0.0 .. 1.0e11
       and then Center - Half <= Lo and then Center + Half >= Hi
   is
      Scale : constant Real := Maximum (1.0, Maximum (abs Lo, abs Hi));
      Span : constant Real := Hi - Lo;
      Pad : constant Real := 32.0 * Real'Model_Epsilon * Scale;
      Radius : Real;
   begin
      pragma Assert (Span in 0.0 .. 4.0e10);
      Center := Lo + Span * 0.5;
      pragma Assert (Center in -6.0e10 .. 6.0e10);
      Radius := Maximum (Center - Lo, Hi - Center);
      Half := Radius + Pad;
      pragma Assert (Half in 0.0 .. 1.0e11);
      pragma Assert (abs Center <= 3.0 * Scale);
      Lemma_Lower (Center, Lo, Scale);
      pragma Assert (Center - ((Center - Lo) + Pad) <= Lo);
      Lemma_Upper (Center, Hi, Scale);
      Lemma_Monotonic (Center - Lo, Radius, Pad);
      Lemma_Monotonic (Hi - Center, Radius, Pad);
      pragma Assert (Half >= (Center - Lo) + Pad);
      pragma Assert (Half >= (Hi - Center) + Pad);
      Lemma_Monotonic ((Center - Lo) + Pad, Half, Center);
      pragma Assert (Center - Half <= Center - ((Center - Lo) + Pad));
      Lemma_Monotonic ((Hi - Center) + Pad, Half, Center);
      Lemma_Transitive (Center - Half, Center - ((Center - Lo) + Pad), Lo);
      pragma Assert (Center - Half <= Lo);
      pragma Assert (Center + Half >= Hi);
   end Enclose;

   procedure Union_Axis (AC, AH, BC, BH : Real; Center, Half : out Real) with
     Inline, Global => null,
     Pre => AC in -1.0e10 .. 1.0e10 and BC in -1.0e10 .. 1.0e10
       and AH in 0.0 .. 1.0e10 and BH in 0.0 .. 1.0e10,
     Post => Center in -6.0e10 .. 6.0e10 and then Half in 0.0 .. 1.0e11
       and then Center - Half <= AC - AH and then Center - Half <= BC - BH
       and then Center + Half >= AC + AH and then Center + Half >= BC + BH
   is
      Lo : constant Real := Minimum (AC - AH, BC - BH);
      Hi : constant Real := Maximum (AC + AH, BC + BH);
   begin
      Lemma_Monotonic (-AH, AH, AC);
      pragma Assert (AC - AH <= AC + AH);
      Enclose (Lo, Hi, Center, Half);
   end Union_Axis;

   function Union_Box (A, B : Box) return Box is
      R : Box;
   begin
      for K in Axis loop
         Union_Axis (A.Center (K), A.Half (K), B.Center (K), B.Half (K),
                     R.Center (K), R.Half (K));
      end loop;
      return R;
   end Union_Box;

   function Topology_Valid (T : Tree) return Boolean is
      Seen : array (Natural range 0 .. Max_Nodes - 1) of Boolean := [others => False];
      IDs : array (Natural range 0 .. Max_Leaves - 1) of Boolean := [others => False];
      L, R : Integer;
      Ends : array (Natural range 0 .. Max_Nodes-1) of Natural := [others=>0];
   begin
      if T.Length = 0 then return True; end if;
      Seen (0) := True;
      for I in 0 .. T.Length - 1 loop
         pragma Loop_Invariant (for all J in 0 .. I - 1 => Node_Shaped (T, J));
         pragma Loop_Invariant (for all J in 0 .. I - 1 =>
           (if T.Nodes (J).Left = -1 then IDs (T.Nodes (J).Item)));
         pragma Loop_Invariant (for all J in 0 .. I - 1 =>
           (for all K in 0 .. J - 1 =>
             (if T.Nodes (J).Left = -1 and then T.Nodes (K).Left = -1 then
                T.Nodes (J).Item /= T.Nodes (K).Item)));
         if not Seen (I) then return False; end if;
         L := T.Nodes (I).Left; R := T.Nodes (I).Right;
         if L = -1 and R = -1 then
            if T.Nodes (I).Item < 0 or else IDs (T.Nodes (I).Item) then return False; end if;
            IDs (T.Nodes (I).Item) := True;
         else
            if T.Nodes (I).Item /= -1 or else L <= I or else R <= I
              or else L >= T.Length or else R >= T.Length or else L = R
              or else Seen (L) or else Seen (R)
            then return False; end if;
            Seen (L) := True; Seen (R) := True;
         end if;
      end loop;
      --  C's self-pair pruning assumes contiguous subtrees in preorder.
      for I in reverse 0 .. T.Length-1 loop
         pragma Loop_Invariant (Shaped (T) and then Unique_Leaves (T));
         pragma Loop_Invariant (for all J in I + 1 .. T.Length - 1 =>
           Ends (J) in J .. T.Length - 1);
         if T.Nodes (I).Left = -1 then Ends (I):=I;
         else
            L:=T.Nodes (I).Left; R:=T.Nodes (I).Right;
            if L/=I+1 or else R/=Ends (L)+1 then return False; end if;
            Ends (I):=Ends (R);
         end if;
      end loop;
      return Ends (0)=T.Length-1;
   end Topology_Valid;

   function Valid (T : Tree) return Boolean is
   begin
      if not Topology_Valid (T) then return False; end if;
      for I in 0 .. T.Length - 1 loop
         pragma Loop_Invariant (Shaped (T) and then Unique_Leaves (T));
         pragma Loop_Invariant (for all J in 0 .. I - 1 => Valid (T.Nodes (J).Bounds));
         if not Valid (T.Nodes (I).Bounds) then return False; end if;
         if T.Nodes (I).Left >= 0 and then
           (not Valid (T.Nodes (T.Nodes (I).Left).Bounds)
            or else not Valid (T.Nodes (T.Nodes (I).Right).Bounds)
            or else not Contains (T.Nodes (I).Bounds, T.Nodes (T.Nodes (I).Left).Bounds)
            or else not Contains (T.Nodes (I).Bounds, T.Nodes (T.Nodes (I).Right).Bounds))
         then return False; end if;
      end loop;
      return True;
   end Valid;

   procedure Set_Bounds (T : in out Tree; I : Natural; Value : Box)
     with Global => null, Inline, Pre => I < T.Length and then Shaped (T)
       and then Bounded (Value)
       and then (for all J in I + 1 .. T.Length - 1 => Valid (T.Nodes (J).Bounds))
       and then (for all J in I + 1 .. T.Length - 1 =>
         (if T.Nodes (J).Left >= 0 then
           Contains (T.Nodes (J).Bounds, T.Nodes (T.Nodes (J).Left).Bounds)
           and then Contains (T.Nodes (J).Bounds, T.Nodes (T.Nodes (J).Right).Bounds)))
       and then (if T.Nodes (I).Left >= 0 then
         Contains (Value, T.Nodes (T.Nodes (I).Left).Bounds)
         and then Contains (Value, T.Nodes (T.Nodes (I).Right).Bounds)),
       Post => T.Length = T.Length'Old and then Shaped (T)
         and then T.Nodes (I).Bounds = Value
         and then T.Nodes (I).Left = T.Nodes'Old (I).Left
         and then T.Nodes (I).Right = T.Nodes'Old (I).Right
         and then T.Nodes (I).Item = T.Nodes'Old (I).Item
         and then (for all J in 0 .. Max_Nodes - 1 =>
           (if J /= I then T.Nodes (J) = T.Nodes'Old (J)))
         and then (for all J in I + 1 .. T.Length - 1 => Valid (T.Nodes (J).Bounds))
         and then (for all J in I .. T.Length - 1 =>
           (if T.Nodes (J).Left >= 0 then
             Contains (T.Nodes (J).Bounds, T.Nodes (T.Nodes (J).Left).Bounds)
             and then Contains (T.Nodes (J).Bounds, T.Nodes (T.Nodes (J).Right).Bounds)))
   is
   begin
      T.Nodes (I).Bounds := Value;
   end Set_Bounds;

   --  Refit needs forward, in-range children; uniqueness and reachability are
   --  orthogonal to its box updates. Keep the public imported-tree precondition
   --  and use this smaller proved boundary while constructing a new tree.
   procedure Refit_Shaped (B : Box_Array; T : in out Tree; Result : out Status)
     with Global => null, Pre => Shaped (T),
       Post => T.Length in 0 | T.Length'Old
         and then (for all I in 0 .. T.Length'Old - 1 =>
           T.Nodes (I).Left = T.Nodes'Old (I).Left
           and then T.Nodes (I).Right = T.Nodes'Old (I).Right
           and then T.Nodes (I).Item = T.Nodes'Old (I).Item)
         and then (if Result /= Success then T.Length = 0 else
           T.Length = T.Length'Old and then Shaped (T) and then Boxes_Valid (T)
           and then Enclosing (T) and then Leaves_Match (B, T))
   is
      V : Integer;
      Initial_Length : constant Natural := T.Length;
      Remaining : Natural := T.Length;
   begin
      Result := Invalid_Input;
      if (for some X of B => not Valid (X)) then T.Length := 0; return; end if;
      while Remaining > 0 loop
         --  State the frame before the update: early numeric/input failures
         --  must preserve topology just as a successful refit does.
         pragma Loop_Invariant (T.Length = Initial_Length and then Shaped (T));
         pragma Loop_Invariant (Remaining <= T.Length);
         pragma Loop_Invariant (for all J in 0 .. Initial_Length - 1 =>
           T.Nodes (J).Left = T.Nodes'Loop_Entry (J).Left);
         pragma Loop_Invariant (for all J in 0 .. Initial_Length - 1 =>
           T.Nodes (J).Right = T.Nodes'Loop_Entry (J).Right);
         pragma Loop_Invariant (for all J in 0 .. Initial_Length - 1 =>
           T.Nodes (J).Item = T.Nodes'Loop_Entry (J).Item);
         pragma Loop_Invariant (for all J in Remaining .. T.Length - 1 =>
           Valid (T.Nodes (J).Bounds));
         pragma Loop_Invariant (for all J in Remaining .. T.Length - 1 =>
           (if T.Nodes (J).Left = -1 then
             T.Nodes (J).Item in B'Range and then T.Nodes (J).Bounds = B (T.Nodes (J).Item)));
         pragma Loop_Invariant (for all J in Remaining .. T.Length - 1 =>
           (if T.Nodes (J).Left >= 0 then
             Valid (T.Nodes (T.Nodes (J).Left).Bounds)
             and then Contains (T.Nodes (J).Bounds, T.Nodes (T.Nodes (J).Left).Bounds)));
         pragma Loop_Invariant (for all J in Remaining .. T.Length - 1 =>
           (if T.Nodes (J).Right >= 0 then
             Valid (T.Nodes (T.Nodes (J).Right).Bounds)
             and then Contains (T.Nodes (J).Bounds, T.Nodes (T.Nodes (J).Right).Bounds)));
         declare
            I : constant Natural := Remaining - 1;
         begin
            if T.Nodes (I).Left < 0 then
               V := T.Nodes (I).Item;
               if V not in B'Range then T.Length := 0; return; end if;
               Set_Bounds (T, I, B (V));
            else
               Set_Bounds (T, I, Union_Box
                 (T.Nodes (T.Nodes (I).Left).Bounds,
                  T.Nodes (T.Nodes (I).Right).Bounds));
            end if;
            if not Valid (T.Nodes (I).Bounds) then T.Length := 0; Result := Numeric_Limit; return; end if;
         end;
         Remaining := Remaining - 1;
      end loop;
      pragma Assert (Remaining = 0);
      pragma Assert (Boxes_Valid (T));
      Result := Success;
   end Refit_Shaped;
   pragma Inline (Refit_Shaped);

   type Node_Addresses is array (Natural range 0 .. Max_Nodes - 1) of Natural;
   function Work_Fits (First, Last : Node_Addresses; Cursor, Length, Leaves : Natural)
     return Boolean is
     (for all V in Cursor .. Length - 1 =>
        First (V) <= Last (V) and then Last (V) < Leaves
        and then V + 2 * (Last (V) - First (V)) < Length)
     with Ghost, Pre => Cursor <= Length and then Length <= Max_Nodes
       and then Leaves in 1 .. Max_Leaves;

   procedure Schedule (First, Last : in out Node_Addresses;
                       Cursor, Length, Leaves, I, J : Natural;
                       Mid, Left, Right : out Natural)
     with Inline, Global => null,
       Pre => Cursor < Length and then Length <= Max_Nodes
         and then Leaves in 1 .. Max_Leaves
         and then Work_Fits (First, Last, Cursor, Length, Leaves)
         and then I = First (Cursor) and then J = Last (Cursor) and then I < J,
       Post => Mid in I .. J - 1 and then Left = Cursor + 1
         and then Right = Cursor + 2 * (Mid - I + 1)
         and then Left < Right and then Right < Length
         and then Work_Fits (First, Last, Cursor + 1, Length, Leaves)
         and then First (Left) = I and then Last (Left) = Mid
         and then First (Right) = Mid + 1 and then Last (Right) = J
   is
   begin
      Mid := I + (J - I) / 2;
      Left := Cursor + 1; Right := Cursor + 2 * (Mid - I + 1);
      pragma Assert (Mid in I .. J - 1);
      pragma Assert (Right + 2 * (J - (Mid + 1)) = Cursor + 2 * (J - I));
      First (Left) := I; Last (Left) := Mid;
      First (Right) := Mid + 1; Last (Right) := J;
   end Schedule;

   procedure Build (B : Box_Array; T : in out Tree; Result : out Status) is
      Order : array (Natural range 0 .. Max_Leaves - 1) of Natural := [others => 0];
      Start, Last : Node_Addresses := [others => 0];
      N, Mid, I, J, Key : Natural;
      Left, Right : Natural;
      K : Axis;
      Bounds : Box;
   begin
      T.Length := 0; Result := Invalid_Input;
      if B'Length > Max_Leaves or else B'First /= 0
        or else (for some X of B => not Valid (X)) then return; end if;
      if B'Length = 0 then Result := Success; return; end if;
      for V in 0 .. B'Length - 1 loop
         pragma Loop_Invariant (for all X in 0 .. V - 1 => Order (X) = X);
         Order (V) := V;
      end loop;
      T.Length := 2*B'Length-1; Last (0) := B'Length - 1; N := 0;
      while N < T.Length loop
         pragma Loop_Invariant (T.Length = 2 * B'Length - 1);
         pragma Loop_Invariant (for all V in 0 .. N - 1 => Node_Shaped (T, V));
         pragma Loop_Invariant (for all V in 0 .. B'Length - 1 => Order (V) in B'Range);
         pragma Loop_Invariant (Work_Fits (Start, Last, N, T.Length, B'Length));
         pragma Loop_Variant (Increases => N);
         I := Start (N); J := Last (N);
         if I = J then
            T.Nodes (N) := (Bounds => B (Order (I)), Item => Order (I), others => <>);
         else
            Bounds := B (Order (I));
            for V in I + 1 .. J loop
               pragma Loop_Invariant (Valid (Bounds));
               Bounds := Union_Box (Bounds, B (Order (V)));
               if not Valid (Bounds) then T.Length := 0; Result := Numeric_Limit; return; end if;
            end loop;
            K := 0;
            if Bounds.Half (1) > Bounds.Half (K) then K := 1; end if;
            if Bounds.Half (2) > Bounds.Half (K) then K := 2; end if;
            --  Deterministic median split, preparation outside the simulation step.
            for V in I + 1 .. J loop
               pragma Loop_Invariant (for all X in 0 .. B'Length - 1 => Order (X) in B'Range);
               Key := Order (V); Mid := V;
               while Mid > I and then B (Order (Mid - 1)).Center (K) > B (Key).Center (K) loop
                  pragma Loop_Invariant (Mid in I + 1 .. V);
                  pragma Loop_Invariant (Key in B'Range);
                  pragma Loop_Invariant (for all X in 0 .. B'Length - 1 => Order (X) in B'Range);
                  pragma Loop_Variant (Decreases => Mid);
                  Order (Mid) := Order (Mid - 1); Mid := Mid - 1;
               end loop;
               Order (Mid) := Key;
               pragma Assert (for all X in 0 .. B'Length - 1 => Order (X) in B'Range);
            end loop;
            Schedule (Start, Last, N, T.Length, B'Length, I, J, Mid, Left, Right);
            T.Nodes (N) := (Bounds => Bounds, Left => Left, Right => Right, Item => -1);
         end if;
         N := N + 1;
      end loop;
      --  Refit from children makes the imported containment invariant explicit.
      Refit_Shaped (B, T, Result);
   end Build;

   procedure Refit (B : Box_Array; T : in out Tree; Result : out Status) is
   begin
      Refit_Shaped (B, T, Result);
   end Refit;

   function Frame_Product (A, B : Matrix; K, L : Axis) return Real is
     ((A (L) * B (K) + A (3 + L) * B (3 + K)) + A (6 + L) * B (6 + K))
     with Inline, Global => null,
       Pre => (for all X of A => X in -4.0 .. 4.0)
         and then (for all X of B => X in -4.0 .. 4.0),
       Post => Frame_Product'Result in -1.0e2 .. 1.0e2
         and then Frame_Product'Result =
           ((A (L) * B (K) + A (3 + L) * B (3 + K)) + A (6 + L) * B (6 + K));
   function Frame_Offset (P : Vec; R : Matrix; K : Axis) return Real is
     ((P (0) * R (K) + P (1) * R (3 + K)) + P (2) * R (6 + K))
     with Inline, Global => null,
       Pre => (for all X of P => X in Coordinate)
         and then (for all X of R => X in -4.0 .. 4.0),
       Post => Frame_Offset'Result in -1.0e12 .. 1.0e12
         and then Frame_Offset'Result =
           ((P (0) * R (K) + P (1) * R (3 + K)) + P (2) * R (6 + K));

   procedure Prepare (PA, PB : Pose; Cache : out Frame_Cache) is
      type Pose_Array is array (Natural range 0 .. 1) of Pose;
      P : constant Pose_Array := [PA, PB];
   begin
      for I in 0 .. 1 loop
         for J in 0 .. 1 loop
            for K in Axis loop
               for L in Axis loop
                  Cache.Product (I, J, K, L) := Frame_Product
                    (P (I).Rotation, P (J).Rotation, K, L);
               end loop;
               Cache.Offset (I, J, K) := Frame_Offset
                 ((if I = 0 then PA.Position else PB.Position), P (J).Rotation, K);
            end loop;
         end loop;
      end loop;
   end Prepare;

   function Projection (B : Box; X, Y, Z, Offset : Real) return Real is
     (((B.Center (0) * X + B.Center (1) * Y) + B.Center (2) * Z) + Offset)
     with Inline, Global => null,
       Pre => Valid (B) and then X in -1.0e2 .. 1.0e2
         and then Y in -1.0e2 .. 1.0e2 and then Z in -1.0e2 .. 1.0e2
         and then Offset in -1.0e12 .. 1.0e12,
       Post => Projection'Result in -1.0e14 .. 1.0e14
         and then Projection'Result =
           (((B.Center (0) * X + B.Center (1) * Y) + B.Center (2) * Z) + Offset);
   function Projected_Radius (B : Box; X, Y, Z : Real) return Real is
     ((abs (B.Half (0) * X) + abs (B.Half (1) * Y)) + abs (B.Half (2) * Z))
     with Inline, Global => null,
       Pre => Valid (B) and then X in -1.0e2 .. 1.0e2
         and then Y in -1.0e2 .. 1.0e2 and then Z in -1.0e2 .. 1.0e2,
       Post => Projected_Radius'Result in 0.0 .. 1.0e14
         and then Projected_Radius'Result =
           ((abs (B.Half (0) * X) + abs (B.Half (1) * Y)) + abs (B.Half (2) * Z));

   function Oriented_Overlap (A, B : Box; Cache : Frame_Cache; Margin : Real) return Boolean is
      Boxes : constant array (Natural range 0 .. 1) of Box := [A, B];
      Proj, Radius : array (Natural range 0 .. 1) of Real;
      Inf : array (Natural range 0 .. 1) of Boolean := [others=>False];
   begin
      for I in 0 .. 1 loop
         if (for all X of Boxes (I).Half => X >= Max_Val) then return True; end if;
         Inf (I) := (for some X of Boxes (I).Half => X >= Max_Val);
      end loop;
      for J in 0 .. 1 loop
         if not Inf (1 - J) then
            for K in Axis loop
               for I in 0 .. 1 loop
                  pragma Loop_Invariant (for all V in 0 .. I - 1 =>
                    Proj (V) in -1.0e14 .. 1.0e14 and then Radius (V) in 0.0 .. 1.0e14);
                  pragma Assert (Valid (Boxes (I)));
                  pragma Assert (Cache.Offset (I, J, K) in -1.0e12 .. 1.0e12);
                  pragma Assert (for all L in Axis => Cache.Product (I, J, K, L) in -1.0e2 .. 1.0e2);
                  Proj (I) := Projection (Boxes (I), Cache.Product (I, J, K, 0),
                    Cache.Product (I, J, K, 1), Cache.Product (I, J, K, 2), Cache.Offset (I, J, K));
                  Radius (I) := Projected_Radius (Boxes (I), Cache.Product (I, J, K, 0),
                    Cache.Product (I, J, K, 1), Cache.Product (I, J, K, 2));
               end loop;
               if Radius (0) + Radius (1) + Margin < abs (Proj (1) - Proj (0)) then return False; end if;
            end loop;
         end if;
      end loop;
      return True;
   end Oriented_Overlap;

   function Area_Sum (X, Y, Z : Real) return Real is
     ((X * Y + Y * Z) + Z * X)
     with Inline, Global => null,
       Pre => X in -2.0e10 .. 2.0e10 and then Y in -2.0e10 .. 2.0e10
         and then Z in -2.0e10 .. 2.0e10,
       Post => Area_Sum'Result in -1.0e23 .. 1.0e23
         and then Area_Sum'Result = ((X * Y + Y * Z) + Z * X);
   function Area (B : Box) return Real with Global => null,
     Pre => Valid (B), Post => Area'Result in -1.0e23 .. 1.0e23
   is
      X : constant Real := B.Half (0) - B.Center (0);
      Y : constant Real := B.Half (1) - B.Center (1);
      Z : constant Real := B.Half (2) - B.Center (2);
   begin
      pragma Assert (X in -2.0e10 .. 2.0e10);
      pragma Assert (Y in -2.0e10 .. 2.0e10);
      pragma Assert (Z in -2.0e10 .. 2.0e10);
      return Area_Sum (X, Y, Z);
   end Area;

   procedure Traverse (A, B : Tree; PA, PB : Pose; Margin : Real;
                       Self : Boolean; Oriented : Boolean;
                       Pairs : out Pair_Array; Count : out Natural; Result : out Status) is
      type Node_Pair is record First, Second : Natural; end record;
      type Stack_Array is array (Natural range 0 .. 2*Max_Nodes-1) of Node_Pair with Relaxed_Initialization;
      Stack : Stack_Array;
      Top : Natural := 0;
      C : Node_Pair;
      Cache : Frame_Cache;
      LA, LB, Hit : Boolean;
      procedure Push (I, J : Natural) with
        Global => (Proof_In => (A, B), In_Out => (Stack, Top, Result)),
        Pre => I < A.Length and then J < B.Length and then Top <= Stack'Length
          and then (for all Q in 0 .. Top - 1 => Stack (Q)'Initialized
            and then Stack (Q).First < A.Length and then Stack (Q).Second < B.Length),
        Post => Top = (if Top'Old = Stack'Length then Top'Old else Top'Old + 1)
          and then Result = (if Top'Old = Stack'Length then Capacity_Limit else Result'Old)
          and then (for all Q in 0 .. Top - 1 => Stack (Q)'Initialized
            and then Stack (Q).First < A.Length and then Stack (Q).Second < B.Length)
          and then (for all Q in 0 .. Top'Old - 1 => Stack (Q) = Stack'Old (Q))
          and then (if Top'Old < Stack'Length then Stack (Top'Old) = Node_Pair'(I, J))
      is
      begin
         if Top = Stack'Length then Result := Capacity_Limit;
         else Stack (Top) := (I, J); Top := Top + 1; end if;
      end Push;
      procedure Emit (Value : Pair) with
        Global => (Proof_In => (A, B, Self), In_Out => (Pairs, Count), Output => Result),
        Pre => Int64 (Count) <= Int64 (Pairs'Length)
          and then Leaf_Item (A, Value.First) and then Leaf_Item (B, Value.Second)
          and then (if Self then Value.First /= Value.Second)
          and then (if Count > 0 then Pairs (Pairs'First .. Pairs'First + (Count - 1))'Initialized)
          and then (for all I in Pairs'First .. Pairs'First + (Count - 1) => Leaf_Item (A, Pairs (I).First)
            and then Leaf_Item (B, Pairs (I).Second)
            and then (if Self then Pairs (I).First /= Pairs (I).Second)),
        Post => Int64 (Count) <= Int64 (Pairs'Length)
          and then (if Int64 (Count'Old) = Int64 (Pairs'Length) or else Count'Old = Natural'Last then
            Count = 0 and then Result = Capacity_Limit
          else Count = Count'Old + 1 and then Result = Success
            and then Pairs (Pairs'First + Count'Old) = Value)
          and then (if Count > 0 then Pairs (Pairs'First .. Pairs'First + (Count - 1))'Initialized)
          and then (for all I in Pairs'First .. Pairs'First + (Count - 1) => Leaf_Item (A, Pairs (I).First)
            and then Leaf_Item (B, Pairs (I).Second)
            and then (if Self then Pairs (I).First /= Pairs (I).Second))
      is
      begin
         if Int64 (Count) = Int64 (Pairs'Length) or else Count = Natural'Last then
            Result := Capacity_Limit; Count := 0; return;
         end if;
         Pairs (Pairs'First + Count) := Value;
         Count := Count + 1; Result := Success;
      end Emit;
   begin
      Count := 0; Result := Success;
      if A.Length = 0 or B.Length = 0 then return; end if;
      Prepare (PA, PB, Cache); Push (0, 0);
      while Top > 0 loop
         pragma Loop_Invariant (Top <= Stack'Length);
         pragma Loop_Invariant (Result = Success);
         pragma Loop_Invariant (Shaped (A) and then Shaped (B)
           and then Unique_Leaves (A) and then Unique_Leaves (B)
           and then Boxes_Valid (A) and then Boxes_Valid (B) and then Prepared (Cache));
         pragma Loop_Invariant (for all I in 0 .. Top-1 => Stack (I)'Initialized
           and then Stack (I).First < A.Length and then Stack (I).Second < B.Length);
         pragma Loop_Invariant (Int64 (Count) <= Int64 (Pairs'Length));
         pragma Loop_Invariant (if Count > 0 then Pairs (Pairs'First .. Pairs'First + (Count - 1))'Initialized);
         pragma Loop_Invariant (for all I in Pairs'First .. Pairs'First + (Count - 1) =>
           Leaf_Item (A, Pairs (I).First)
           and then Leaf_Item (B, Pairs (I).Second)
           and then (if Self then Pairs (I).First /= Pairs (I).Second));
         Top := Top - 1; C := Stack (Top);
         if not Self or else C.First <= C.Second then
            LA := A.Nodes (C.First).Left = -1; LB := B.Nodes (C.Second).Left = -1;
            if Oriented then
               Hit := Oriented_Overlap (A.Nodes (C.First).Bounds, B.Nodes (C.Second).Bounds, Cache, Margin);
            else Hit := Overlap (A.Nodes (C.First).Bounds, B.Nodes (C.Second).Bounds, Margin); end if;
            if Hit then
               if LA and LB then
                  if not Self or else C.First /= C.Second then
                     pragma Assert (Leaf_Item (A, A.Nodes (C.First).Item));
                     pragma Assert (Leaf_Item (B, B.Nodes (C.Second).Item));
                     pragma Assert (if Self then A.Nodes (C.Second) = B.Nodes (C.Second));
                     pragma Assert (if Self then A.Nodes (C.First).Item /= B.Nodes (C.Second).Item);
                     Emit ((A.Nodes (C.First).Item, B.Nodes (C.Second).Item));
                     if Result /= Success then return; end if;
                  end if;
               elsif LB or else (not LA and then Area (A.Nodes (C.First).Bounds) > Area (B.Nodes (C.Second).Bounds)) then
                  Push (A.Nodes (C.First).Left, C.Second); Push (A.Nodes (C.First).Right, C.Second);
               else
                  Push (C.First, B.Nodes (C.Second).Left); Push (C.First, B.Nodes (C.Second).Right);
               end if;
               if Result /= Success then Count := 0; return; end if;
            end if;
         end if;
      end loop;
   end Traverse;
end MJ.BVH;

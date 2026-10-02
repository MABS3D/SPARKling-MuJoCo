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
         if not Valid (T.Nodes (I).Bounds) then return False; end if;
         if T.Nodes (I).Left >= 0 and then
           (not Contains (T.Nodes (I).Bounds, T.Nodes (T.Nodes (I).Left).Bounds)
            or else not Contains (T.Nodes (I).Bounds, T.Nodes (T.Nodes (I).Right).Bounds))
         then return False; end if;
      end loop;
      return True;
   end Valid;

   procedure Build (B : Box_Array; T : in out Tree; Result : out Status) is
      Order : array (Natural range 0 .. Max_Leaves - 1) of Natural := [others => 0];
      Start, Last : array (Natural range 0 .. Max_Nodes - 1) of Natural := [others => 0];
      N, Mid, I, J, Key : Natural;
      K : Axis;
      Bounds : Box;
   begin
      T.Length := 0; Result := Invalid_Input;
      if B'Length > Max_Leaves or else B'First /= 0
        or else (for some X of B => not Valid (X)) then return; end if;
      if B'Length = 0 then Result := Success; return; end if;
      for V in 0 .. B'Length - 1 loop Order (V) := V; end loop;
      T.Length := 2*B'Length-1; Last (0) := B'Length - 1; N := 0;
      while N < T.Length loop
         I := Start (N); J := Last (N);
         if I = J then
            T.Nodes (N) := (Bounds => B (Order (I)), Item => Order (I), others => <>);
         else
            Bounds := B (Order (I));
            for V in I + 1 .. J loop
               Bounds := Union_Box (Bounds, B (Order (V)));
               if not Valid (Bounds) then T.Length := 0; Result := Numeric_Limit; return; end if;
            end loop;
            K := 0;
            if Bounds.Half (1) > Bounds.Half (K) then K := 1; end if;
            if Bounds.Half (2) > Bounds.Half (K) then K := 2; end if;
            --  Deterministic median split, preparation outside the simulation step.
            for V in I + 1 .. J loop
               Key := Order (V); Mid := V;
               while Mid > I and then B (Order (Mid - 1)).Center (K) > B (Key).Center (K) loop
                  Order (Mid) := Order (Mid - 1); Mid := Mid - 1;
               end loop;
               Order (Mid) := Key;
            end loop;
            Mid := I + (J - I) / 2;
            T.Nodes (N) := (Bounds => Bounds, Left => N+1,
                           Right => N+2*(Mid-I+1), Item => -1);
            Start (N+1) := I; Last (N+1) := Mid;
            Start (N+2*(Mid-I+1)) := Mid+1; Last (N+2*(Mid-I+1)) := J;
         end if;
         N := N + 1;
      end loop;
      --  Refit from children makes the imported containment invariant explicit.
      Refit (B, T, Result);
   end Build;

   procedure Refit (B : Box_Array; T : in out Tree; Result : out Status) is
      V : Integer;
   begin
      Result := Invalid_Input;
      if (for some X of B => not Valid (X)) then T.Length := 0; return; end if;
      for I in reverse 0 .. T.Length - 1 loop
         if T.Nodes (I).Left < 0 then
            V := T.Nodes (I).Item;
            if V not in B'Range then T.Length := 0; return; end if;
            T.Nodes (I).Bounds := B (V);
         else
            T.Nodes (I).Bounds := Union_Box
              (T.Nodes (T.Nodes (I).Left).Bounds, T.Nodes (T.Nodes (I).Right).Bounds);
         end if;
         if not Valid (T.Nodes (I).Bounds) then T.Length := 0; Result := Numeric_Limit; return; end if;
      end loop;
      Result := Success;
   end Refit;

   procedure Prepare (PA, PB : Pose; Cache : out Frame_Cache) is
      type Pose_Array is array (Natural range 0 .. 1) of Pose;
      P : constant Pose_Array := [PA, PB];
   begin
      for I in 0 .. 1 loop
         for J in 0 .. 1 loop
            for K in Axis loop
               for L in Axis loop
                  Cache.Product (I, J, K, L) := Dot
                    (Column (P (I).Rotation, L), Column (P (J).Rotation, K));
               end loop;
               Cache.Offset (I, J, K) := Dot (P (I).Position, Column (P (J).Rotation, K));
            end loop;
         end loop;
      end loop;
   end Prepare;

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
                  Proj (I) := ((Boxes (I).Center (0) * Cache.Product (I, J, K, 0)
                    + Boxes (I).Center (1) * Cache.Product (I, J, K, 1))
                    + Boxes (I).Center (2) * Cache.Product (I, J, K, 2)) + Cache.Offset (I, J, K);
                  Radius (I) := (abs (Boxes (I).Half (0) * Cache.Product (I, J, K, 0))
                    + abs (Boxes (I).Half (1) * Cache.Product (I, J, K, 1)))
                    + abs (Boxes (I).Half (2) * Cache.Product (I, J, K, 2));
               end loop;
               if Radius (0) + Radius (1) + Margin < abs (Proj (1) - Proj (0)) then return False; end if;
            end loop;
         end if;
      end loop;
      return True;
   end Oriented_Overlap;

   function Area (B : Box) return Real is
      X : constant Real := B.Half (0) - B.Center (0);
      Y : constant Real := B.Half (1) - B.Center (1);
      Z : constant Real := B.Half (2) - B.Center (2);
   begin
      return (X * Y + Y * Z) + Z * X;
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
      procedure Push (I, J : Natural) is
      begin
         if Top = Stack'Length then Result := Capacity_Limit;
         else Stack (Top) := (I, J); Top := Top + 1; end if;
      end Push;
   begin
      Count := 0; Result := Success;
      if A.Length = 0 or B.Length = 0 then return; end if;
      Prepare (PA, PB, Cache); Push (0, 0);
      while Top > 0 loop
         pragma Loop_Invariant (for all I in 0 .. Top-1 => Stack (I)'Initialized);
         Top := Top - 1; C := Stack (Top);
         if not Self or else C.First <= C.Second then
            LA := A.Nodes (C.First).Left = -1; LB := B.Nodes (C.Second).Left = -1;
            if Oriented then
               Hit := Oriented_Overlap (A.Nodes (C.First).Bounds, B.Nodes (C.Second).Bounds, Cache, Margin);
            else Hit := Overlap (A.Nodes (C.First).Bounds, B.Nodes (C.Second).Bounds, Margin); end if;
            if Hit then
               if LA and LB then
                  if not Self or else C.First /= C.Second then
                     if Count = Pairs'Length then Result := Capacity_Limit; Count := 0; return; end if;
                     Pairs (Pairs'First + Count) := (A.Nodes (C.First).Item, B.Nodes (C.Second).Item);
                     Count := Count + 1;
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

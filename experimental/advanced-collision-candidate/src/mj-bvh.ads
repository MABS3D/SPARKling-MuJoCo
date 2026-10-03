--  MuJoCo 3.14.0 midphase; Apache-2.0, see NOTICE.
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
package MJ.BVH with SPARK_Mode is
   Max_Leaves : constant := 4096;
   Max_Nodes : constant := 2 * Max_Leaves - 1;
   type Box is record
      Center : Vec := Zero;
      Half : Vec := Zero;
   end record;
   type Box_Array is array (Natural range <>) of Box;
   function Valid (B : Box) return Boolean is
     ((for all X of B.Center => X in -1.0e10 .. 1.0e10)
      and then (for all X of B.Half => X in 0.0 .. 1.0e10));
   function Overlap (A, B : Box; Margin : Real) return Boolean is
     (for all K in Axis =>
        A.Center (K) + A.Half (K) + Margin >= B.Center (K) - B.Half (K)
        and B.Center (K) + B.Half (K) + Margin >= A.Center (K) - A.Half (K))
     with Global => null, Pre => Valid (A) and Valid (B) and Margin in 0.0 .. 1.0e10;
   function Sphere_Overlap (Point : Vec; Radius : Real; B : Box) return Boolean is
     (for all K in Axis => Point (K) + Radius >= B.Center (K) - B.Half (K)
       and Point (K) - Radius <= B.Center (K) + B.Half (K))
     with Global => null, Pre => Valid (B) and Radius in 0.0 .. 1.0e10
       and (for all X of Point => X in -1.0e10 .. 1.0e10);
   --  Union results can exceed Valid's model-admission limits. This wider
   --  ghost domain makes the containment arithmetic safe without requiring
   --  callers to accept an out-of-domain tree.
   function Bounded (B : Box) return Boolean is
     ((for all X of B.Center => X in -1.0e100 .. 1.0e100)
      and then (for all X of B.Half => X in -1.0e100 .. 1.0e100)) with Ghost;
   function Contains (Parent, Child : Box) return Boolean is
     (for all K in Axis => Parent.Center (K) - Parent.Half (K) <=
          Child.Center (K) - Child.Half (K)
       and Parent.Center (K) + Parent.Half (K) >= Child.Center (K) + Child.Half (K))
     with Global => null, Pre => Bounded (Parent) and Bounded (Child);
   function Union_Box (A, B : Box) return Box
     with Global => null, Pre => Valid (A) and Valid (B),
       Post => Bounded (Union_Box'Result)
         and then Contains (Union_Box'Result, A) and then Contains (Union_Box'Result, B);
   type Node is record
      Bounds : Box;
      Left, Right : Integer range -1 .. Max_Nodes - 1 := -1;
      Item : Integer range -1 .. Max_Leaves - 1 := -1;
   end record;
   type Node_Array is array (Natural range 0 .. Max_Nodes - 1) of Node;
   type Tree is limited record
      Length : Natural range 0 .. Max_Nodes := 0;
      Nodes : Node_Array;
   end record;
   function Node_Shaped (T : Tree; I : Natural) return Boolean is
     (if T.Nodes (I).Left = -1 then
        T.Nodes (I).Right = -1 and then T.Nodes (I).Item >= 0
      else T.Nodes (I).Item = -1
        and then T.Nodes (I).Left > I and then T.Nodes (I).Right > I
        and then T.Nodes (I).Left < T.Length and then T.Nodes (I).Right < T.Length
        and then T.Nodes (I).Left /= T.Nodes (I).Right)
     with Ghost, Global => null, Pre => I < T.Length;
   function Shaped (T : Tree) return Boolean is
     (for all I in 0 .. T.Length - 1 => Node_Shaped (T, I)) with Ghost;
   function Boxes_Valid (T : Tree) return Boolean is
     (for all I in 0 .. T.Length - 1 => Valid (T.Nodes (I).Bounds)) with Ghost;
   function Enclosing (T : Tree) return Boolean is
     (for all I in 0 .. T.Length - 1 =>
       (if T.Nodes (I).Left >= 0 then
          Contains (T.Nodes (I).Bounds, T.Nodes (T.Nodes (I).Left).Bounds)
          and then Contains (T.Nodes (I).Bounds, T.Nodes (T.Nodes (I).Right).Bounds)))
     with Ghost, Pre => Shaped (T) and then Boxes_Valid (T);
   function Leaves_Match (B : Box_Array; T : Tree) return Boolean is
     (for all I in 0 .. T.Length - 1 =>
       (if T.Nodes (I).Left = -1 then T.Nodes (I).Item in B'Range
          and then T.Nodes (I).Bounds = B (T.Nodes (I).Item))) with Ghost;
   function Unique_Leaves (T : Tree) return Boolean is
     (for all I in 0 .. T.Length - 1 =>
       (for all J in 0 .. I - 1 =>
         (if T.Nodes (I).Left = -1 and then T.Nodes (J).Left = -1 then
            T.Nodes (I).Item /= T.Nodes (J).Item))) with Ghost;
   function Leaf_Item (T : Tree; Item : Natural) return Boolean is
     (for some I in 0 .. T.Length - 1 =>
        T.Nodes (I).Left = -1 and then T.Nodes (I).Item = Item) with Ghost;
   function Topology_Valid (T : Tree) return Boolean with Global => null,
     Post => (if Topology_Valid'Result then Shaped (T) and then Unique_Leaves (T));
   function Valid (T : Tree) return Boolean with Global => null,
     Post => (if Valid'Result then Shaped (T) and then Unique_Leaves (T)
       and then Boxes_Valid (T));
   --  Build once, refit only boxes when vertices move. Leaf IDs index input B.
   procedure Build (B : Box_Array; T : in out Tree; Result : out Status)
     with Global => null,
       Post => (if Result /= Success then T.Length = 0 else
         Int64 (T.Length) = (if B'Length = 0 then 0 else 2 * Int64 (B'Length) - 1)
         and then Shaped (T) and then Boxes_Valid (T)
         and then Enclosing (T) and then Leaves_Match (B, T));
   procedure Refit (B : Box_Array; T : in out Tree; Result : out Status)
     with Global => null, Pre => Topology_Valid (T),
       Post => T.Length in 0 | T.Length'Old
         and then (for all I in 0 .. T.Length'Old - 1 =>
           T.Nodes (I).Left = T.Nodes'Old (I).Left
           and then T.Nodes (I).Right = T.Nodes'Old (I).Right
           and then T.Nodes (I).Item = T.Nodes'Old (I).Item)
         and then (if Result /= Success then T.Length = 0 else
           T.Length = T.Length'Old and then Shaped (T) and then Boxes_Valid (T)
           and then Enclosing (T) and then Leaves_Match (B, T));
   type Frame_Cache is private;
   function Prepared (Cache : Frame_Cache) return Boolean with Ghost, Global => null;
   procedure Prepare (PA, PB : Pose; Cache : out Frame_Cache)
     with Global => null, Pre => Valid_Pose (PA) and Valid_Pose (PB),
       Post => Prepared (Cache);
   --  Matches C's conservative six face-axis test (not a 15-axis SAT).
   function Oriented_Overlap (A, B : Box; Cache : Frame_Cache; Margin : Real)
      return Boolean with Global => null,
       Pre => Valid (A) and Valid (B) and Prepared (Cache) and Margin in 0.0 .. 1.0e10;
   type Pair is record
      First, Second : Natural range 0 .. Max_Leaves - 1;
   end record;
   type Pair_Array is array (Natural range <>) of Pair with Relaxed_Initialization;
   procedure Traverse (A, B : Tree; PA, PB : Pose; Margin : Real;
                       Self : Boolean; Oriented : Boolean;
                       Pairs : out Pair_Array; Count : out Natural; Result : out Status)
     with Global => null,
       Pre => Valid (A) and Valid (B) and Valid_Pose (PA) and Valid_Pose (PB)
         and Margin in 0.0 .. 1.0e10
         and (if Self then A.Length = B.Length
           and then (for all I in 0 .. A.Length - 1 => A.Nodes (I) = B.Nodes (I))),
       Post => Int64 (Count) <= Int64 (Pairs'Length)
         and then (if Result /= Success then Count = 0)
         and then (if Count > 0 then Pairs (Pairs'First .. Pairs'First + (Count - 1))'Initialized)
         and then (for all I in Pairs'First .. Pairs'First + (Count - 1) => Leaf_Item (A, Pairs (I).First)
           and then Leaf_Item (B, Pairs (I).Second)
           and then (if Self then Pairs (I).First /= Pairs (I).Second));
private
   subtype Product_Value is Real range -1.0e2 .. 1.0e2;
   subtype Offset_Value is Real range -1.0e12 .. 1.0e12;
   type Products is array (Natural range 0 .. 1, Natural range 0 .. 1, Axis, Axis) of Product_Value;
   type Offsets is array (Natural range 0 .. 1, Natural range 0 .. 1, Axis) of Offset_Value;
   type Frame_Cache is record
      Product : Products := [others => [others => [others => [others => 0.0]]]];
      Offset : Offsets := [others => [others => [others => 0.0]]];
   end record;
   function Prepared (Cache : Frame_Cache) return Boolean is
     ((for all I in 0 .. 1 => (for all J in 0 .. 1 =>
        (for all K in Axis =>
          Cache.Offset (I, J, K) in -1.0e12 .. 1.0e12
          and then (for all L in Axis => Cache.Product (I, J, K, L) in -1.0e2 .. 1.0e2)))));
end MJ.BVH;

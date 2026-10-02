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
   function Topology_Valid (T : Tree) return Boolean with Global => null;
   function Valid (T : Tree) return Boolean with Global => null;
   --  Build once, refit only boxes when vertices move. Leaf IDs index input B.
   procedure Build (B : Box_Array; T : in out Tree; Result : out Status)
     with Global => null, Post => (if Result /= Success then T.Length = 0);
   procedure Refit (B : Box_Array; T : in out Tree; Result : out Status)
     with Global => null, Pre => Topology_Valid (T),
       Post => (if Result /= Success then T.Length = 0);
   type Frame_Cache is private;
   procedure Prepare (PA, PB : Pose; Cache : out Frame_Cache)
     with Global => null, Pre => Valid_Pose (PA) and Valid_Pose (PB);
   --  Matches C's conservative six face-axis test (not a 15-axis SAT).
   function Oriented_Overlap (A, B : Box; Cache : Frame_Cache; Margin : Real)
      return Boolean with Global => null,
       Pre => Valid (A) and Valid (B) and Margin in 0.0 .. 1.0e10;
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
       Post => Count <= Pairs'Length and then (if Result /= Success then Count = 0)
         and then (for all I in 0 .. Count-1 => Pairs (Pairs'First+I)'Initialized);
private
   type Products is array (Natural range 0 .. 1, Natural range 0 .. 1, Axis, Axis) of Real;
   type Offsets is array (Natural range 0 .. 1, Natural range 0 .. 1, Axis) of Real;
   type Frame_Cache is record
      Product : Products := [others => [others => [others => [others => 0.0]]]];
      Offset : Offsets := [others => [others => [others => 0.0]]];
   end record;
end MJ.BVH;

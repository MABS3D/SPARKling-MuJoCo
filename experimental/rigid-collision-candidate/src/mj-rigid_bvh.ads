with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

--  Body midphase for the existing sweep. Endpoint boxes avoid converting an
--  already admitted AABB to center/half coordinates and rounding it inward.
package MJ.Rigid_BVH with SPARK_Mode is
   Min_Leaves : constant := 32;
   Max_Nodes : constant := 2 * Max_Geoms - 1;
   type Id_Array is array (Geom_Id) of Geom_Id;
   type Vec_Array is array (Geom_Id) of Vec;
   type Boolean_Array is array (Geom_Id) of Boolean;
   type Rank_Array is array (Geom_Id) of Natural;
   type Cache is limited private;

   function Bounded (V : Vec) return Boolean is
     (for all X of V => X in -1.0e12 .. 1.0e12) with Ghost;
   function Box_OK (Lo, Hi : Vec) return Boolean is
     (Bounded (Lo) and then Bounded (Hi)
      and then (for all K in Axis => Lo (K) <= Hi (K))) with Ghost;
   function Overlaps (ALo, AHi, BLo, BHi : Vec; Y, Z : Axis) return Boolean is
     (ALo (Y) <= BHi (Y) and then BLo (Y) <= AHi (Y)
      and then ALo (Z) <= BHi (Z) and then BLo (Z) <= AHi (Z))
     with Inline, Global => null;

   procedure Merge_Bounds
     (ALo, AHi, BLo, BHi : Vec; Lo, Hi : out Vec)
     with Global => null, Pre => Box_OK (ALo, AHi) and then Box_OK (BLo, BHi),
       Post => Box_OK (Lo, Hi)
         and then (for all K in Axis => Lo (K) = Real'Min (ALo (K), BLo (K))
           and then Hi (K) = Real'Max (AHi (K), BHi (K))
           and then Lo (K) <= ALo (K) and then Lo (K) <= BLo (K)
           and then Hi (K) >= AHi (K) and then Hi (K) >= BHi (K));

   procedure Append_Id (Items : in out Id_Array; N : in out Count; Id : Geom_Id)
     with Global => null, Pre => N < Max_Geoms,
       Post => N = N'Old + 1 and then Items (N'Old) = Id
         and then (for all I in Geom_Id =>
           (if I /= N'Old then Items (I) = Items'Old (I)));

   procedure Configure (C : in out Cache; Groups : Id_Array;
                        Shapes : Shape_Array; Group_Count : Count)
     with Global => null,
       Pre => Shapes'First = 0 and then Shapes'Length <= Max_Geoms
         and then Group_Count <= Shapes'Length
         and then (for all I in Shapes'Range => Groups (I) < Group_Count);
   --  First admitted frame chooses deterministic median partitions. Later
   --  frames refit the same forest, including arbitrary changes of poses.
   procedure Update (C : in out Cache; Lo, Hi : Vec_Array; Groups : Id_Array)
     with Global => null;
   procedure Reset_Statistics (C : in out Cache) with Global => null;
   function Available (C : Cache; Group : Geom_Id) return Boolean
     with Global => null;
   function Selection_Matches
     (C : Cache; Group : Geom_Id; Lo, Hi : Vec; Y, Z : Axis;
      Active : Boolean_Array; Rank : Rank_Array) return Boolean
     with Ghost => Static, Global => null, Pre => Available (C, Group);
   procedure Query (C : in out Cache; Group : Geom_Id; Lo, Hi : Vec;
                    Y, Z : Axis; Active : Boolean_Array; Rank : Rank_Array)
     with Global => null, Pre => Available (C, Group),
       Post => (Static => Selection_Matches (C, Group, Lo, Hi, Y, Z, Active, Rank));
   function Selected_Count (C : Cache) return Count with Global => null;
   function Selected_Id (C : Cache; I : Geom_Id) return Geom_Id
     with Global => null, Pre => I < Selected_Count (C);
   function Node_Tests (C : Cache) return Natural with Global => null;
   function Leaf_Tests (C : Cache) return Natural with Global => null;
private
   subtype Node_Id is Natural range 0 .. Max_Nodes - 1;
   type Node is record
      Lo, Hi : Vec := Zero;
      First, Last : Geom_Id := 0;
      Left, Right : Node_Id := 0;
      Id : Count := Max_Geoms;
   end record;
   type Node_Array is array (Node_Id) of Node;
   type Root_Array is array (Geom_Id) of Natural range 0 .. Max_Nodes;
   type Count_Array is array (Geom_Id) of Count;
   type Stack_Array is array (Node_Id) of Node_Id;
   type Cache is limited record
      Ready : Boolean := False;
      N, NG : Count := 0;
      Length : Natural range 0 .. Max_Nodes := 0;
      Roots : Root_Array := [others => Max_Nodes];
      Sizes, Starts : Count_Array := [others => 0];
      Uniform : Boolean_Array := [others => False];
      Order : Id_Array := [others => 0];
      Leaf_Node : Root_Array := [others => Max_Nodes];
      Nodes : Node_Array;
      Stack : Stack_Array := [others => 0];
      Items, Scratch : Id_Array := [others => 0];
      Hits : Count := 0;
      Visited, Leaves : Natural := 0;
   end record;
end MJ.Rigid_BVH;

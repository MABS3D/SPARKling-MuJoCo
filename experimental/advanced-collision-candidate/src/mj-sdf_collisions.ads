with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.SDF_Fields; use MJ.SDF_Fields;
with MJ.BVH;
generic
   --  Native Ada providers; successful outputs must be finite. No C callback in production.
   with procedure Custom_Query (Key : Natural; X : Vec; Need_Gradient : Boolean;
                                Value : out Real; Gradient : out Vec; Result : out Status);
package MJ.SDF_Collisions with SPARK_Mode is
   type Objective is (Single, Intersection, Midsurface, Collision);
   type Problem is record
      A, B : Field;
      Relative : Pose;  --  A-local to B-local.
      Kind : Objective := Single;
   end record;
   type Search_Options is record
      Starts : Natural range 0 .. 10000 := 40;
      Iterations : Natural range 0 .. 1000 := 10;
   end record;
   function Halton (Index : Natural; Base : Positive) return Real
     with Global => null, Pre => Base in 2 .. 16;
   procedure Evaluate (P : Problem; T : Octree; X : Vec; Need_Gradient : Boolean;
                       Value : out Real; Gradient : out Vec; Result : out Status)
     with Global => null;
   procedure Descent (P : Problem; T : Octree; Iterations : Natural;
                      X : in out Vec; Depth : out Real; Result : out Status)
     with Global => null, Pre => Iterations <= 1000;
   procedure Generate (A, B : Field; T : Octree; PA, PB : Pose;
                       O : Search_Options; M : in out Manifold; Result : out Status)
     with Global => null,
       Pre => Valid (A, T) and Valid (B, T) and Valid_Pose (PA) and Valid_Pose (PB),
       Post => (if Result /= Success then M.Length = 0);
   type Triangle is record
      Corners : Vertex_Array (0 .. 2) := [others => Zero];
      Id : Natural := 0;
   end record;
   type Triangle_Array is array (Natural range <>) of Triangle;
   function Fits (Faces : Triangle_Array; Tree : MJ.BVH.Tree) return Boolean
     with Global => null;
   type Triangle_Path is (Linear_Flex, Tree_Flex, Tree_Mesh);
   type Id_Array is array (Natural range <>) of Natural;
   --  Corners/BVH in mesh-local coordinates for Tree_Mesh, world for flex.
   --  PB is the SDF's world pose. Returns element/face IDs alongside contacts.
   procedure Triangles (S : Field; T : Octree; Faces : Triangle_Array;
                        Tree : MJ.BVH.Tree; PA, PB : Pose;
                        Path : Triangle_Path; O : Search_Options;
                        M : in out Manifold; IDs : out Id_Array; Result : out Status)
     with Global => null,
       Pre => Valid (S, T) and then MJ.BVH.Valid (Tree) and then Valid_Pose (PA) and then Valid_Pose (PB)
         and then (if Path /= Linear_Flex and Tree.Length>0 then Fits (Faces,Tree)),
       Post => (if Result /= Success then M.Length = 0);
end MJ.SDF_Collisions;

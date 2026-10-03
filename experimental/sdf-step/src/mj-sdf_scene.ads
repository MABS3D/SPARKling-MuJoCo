with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Rigid_Detector;
with MJ.Contact_Geometry;
with MJ.Contact_Parameters;
with MJ.Full_Contacts;
with MJ.SDF_Fields;
with MJ.Convex_Contacts;
with MJ.BVH;
with MJ.Admitted_SDF;
with MJ.Flex_Collisions;
package MJ.SDF_Scene with SPARK_Mode is
   Max_G : constant := 256;
   Max_Octants : constant := 200_000;
   Max_Vertices : constant := 100_000;
   Max_Facets : constant := 65_536;
   type Scene is limited private;
   function Initialized (S : Scene) return Boolean with Global => null;
   procedure Load (M : MJ.Models.Model; S : in out Scene; Result : out Status)
     with Post => Initialized (S) = (Result = Success);
   procedure Release (S : in out Scene)
     with Post => not Initialized (S);
   procedure Generate (S : in out Scene; Poses : Pose_Array;
                       Contacts : in out MJ.Full_Contacts.Full_Array;
                       Length : out Natural; Result : out Status)
     with Pre => Initialized (S),
       Post => Length <= Contacts'Length and then
         (if Result /= Success then Length = 0);
   --  Reuse the owned octree for flex triangles without copying the sampled
   --  field or allocating in the simulation step.
   procedure Collide_Flex (S : in out Scene; G : Natural; Placement : Pose;
     F : MJ.Flex_Collisions.Flex; Elements : MJ.Flex_Collisions.Element_Array;
     Vertices : MJ.Contact_Geometry.Vertex_Array; Bodies : MJ.Flex_Collisions.Body_Array;
     Tree : MJ.BVH.Tree; Midphase : Boolean; Contacts : in out MJ.Flex_Collisions.Batch;
     Result : out Status)
     with Pre => Initialized (S),
       Post => Contacts.Length <= Contacts.Capacity
         and then (if Result /= Success then Contacts.Length = 0);
private
   type Octree_Access is access MJ.SDF_Fields.Octree;
   type Vertex_Access is access MJ.Contact_Geometry.Vertex_Array;
   type Facet_Access is access MJ.Contact_Geometry.Facet_Array;
   type Triangle_Access is access MJ.Admitted_SDF.Triangle_Array;
   type BVH_Access is access MJ.BVH.Tree;
   type Triangle_Owners is array (Natural range 0 .. Max_G - 1) of Triangle_Access;
   type BVH_Owners is array (Natural range 0 .. Max_G - 1) of BVH_Access;
   type Fields is array (Natural range 0 .. Max_G - 1) of MJ.SDF_Fields.Field;
   type Objects is array (Natural range 0 .. Max_G - 1) of MJ.Contact_Geometry.Object;
   type Materials is array (Natural range 0 .. Max_G - 1) of MJ.Contact_Parameters.Material;
   type Kinds is array (Natural range 0 .. Max_G - 1) of Boolean;
   type Scene is limited record
      Ready : Boolean := False;
      N : Natural := 0;
      Search : MJ.Rigid_Detector.Scene;
      Candidates : MJ.Rigid_Detector.Candidate_List;
      Is_SDF : Kinds := [others => False];
      Is_Mesh : Kinds := [others => False];
      Faces : Triangle_Owners := [others => null];
      BVHs : BVH_Owners := [others => null];
      Field : Fields;
      Solid : Objects;
      Surface : Materials;
      Tree : Octree_Access := null;
      Vertices : Vertex_Access := null;
      Facets : Facet_Access := null;
      Starts, Iterations : Natural := 0;
      Options : MJ.Rigid_Geometry.Options;
      Convex : MJ.Convex_Contacts.Workspace;
   end record;
end MJ.SDF_Scene;

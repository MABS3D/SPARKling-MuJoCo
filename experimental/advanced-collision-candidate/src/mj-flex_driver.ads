with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Flex_Collisions; use MJ.Flex_Collisions;
with MJ.SDF_Fields;
with MJ.SDF_Collisions;
with MJ.Heightfield_Contacts;
with MJ.Convex_Contacts;
with MJ.BVH;
generic
   with procedure Custom_Query (Key : Natural; X : Vec; Need_Gradient : Boolean;
                                Value : out Real; Gradient : out Vec; Result : out Status);
   --  Immutable fields validated at model creation use the same admitted
   --  query boundary as the integrated rigid/SDF scene.
   Fields_Admitted : Boolean := False;
package MJ.Flex_Driver with SPARK_Mode is
   package SDF is new MJ.SDF_Collisions (Custom_Query, Fields_Admitted);
   type Collider_Kind is (Rigid_Geom, Terrain_Geom, SDF_Geom);
   type Collider is record
      Kind : Collider_Kind := Rigid_Geom;
      Geometry : Object;
      Placement : Pose;
      Field : MJ.SDF_Fields.Field;
      Terrain : MJ.Heightfield_Contacts.Heightfield;
   end record;
   procedure Collide (G : Collider; Assets : Vertex_Array;
                      Elevation : MJ.Heightfield_Contacts.Elevation_Array;
                      F : Flex; E : Element_Array; V : Vertex_Array; Bodies : Body_Array;
                      T : MJ.BVH.Tree; Samples : MJ.SDF_Fields.Octree;
                      Midphase : Boolean; O : Options; Search : SDF.Search_Options;
                      W : in out MJ.Convex_Contacts.Workspace; C : in out Batch; Result : out Status;
                      Graphs : Graph_Array := Empty_Graph)
     with Global => null, Pre => MJ.BVH.Valid (T)
         and then (if (Midphase or G.Kind = SDF_Geom) and T.Length>0 then Fits (F,E,V,T))
         and then (if Fields_Admitted and G.Kind = SDF_Geom then MJ.SDF_Fields.Valid (G.Field, Samples)),
       Post => C.Length <= C.Capacity and (if Result /= Success then C.Length = 0);
end MJ.Flex_Driver;

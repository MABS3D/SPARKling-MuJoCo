with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Contact_Parameters; use MJ.Contact_Parameters;
with MJ.Full_Contacts; use MJ.Full_Contacts;
with MJ.Convex_Contacts;
with MJ.Convex_Assets;
with MJ.Heightfield_Contacts;
with MJ.Contact_Incidence;

package MJ.Collision_Contacts with SPARK_Mode is
   --  P is mixed/configured once per pair, then reused for its full manifold.
   --  No scene/broadphase work or construction of constraint rows is done here.
   procedure Generate (A, B : Object; PA, PB : Pose; V : Vertex_Array; F : Facet_Array;
                       Graphs : Graph_Array; P : Parameters; Geoms : Pair; O : Options;
                       W : in out MJ.Convex_Contacts.Workspace;
                       Full : in out Full_Manifold; Result : out Status;
                       Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup)
     with Global => null,
       Pre => Valid_Object (A, V) and Valid_Object (B, V) and Valid_Pose (PA) and Valid_Pose (PB)
         and MJ.Convex_Assets.Valid_Graph (A, Graphs) and MJ.Convex_Assets.Valid_Graph (B, Graphs)
         and MJ.Contact_Incidence.Matches (Incidence, F)
         and P.Detection_Margin in 0.0 .. 1.0e12,
       Post => (if Result /= Success then Full.Length = 0);
   procedure Generate_Terrain
     (H : MJ.Heightfield_Contacts.Heightfield; E : MJ.Heightfield_Contacts.Elevation_Array;
      PH : Pose; B : Object; PB : Pose; V : Vertex_Array; Graphs : Graph_Array;
      P : Parameters; Geoms : Pair; O : Options; W : in out MJ.Convex_Contacts.Workspace;
      Full : in out Full_Manifold; Result : out Status)
     with Global => null,
       Pre => MJ.Heightfield_Contacts.Valid (H, E) and Valid_Object (B, V)
         and MJ.Convex_Assets.Valid_Graph (B, Graphs)
         and Valid_Pose (PH) and Valid_Pose (PB)
         and (B.Kind /= Primitive or else B.Rigid.Kind /= Plane)
         and P.Detection_Margin in 0.0 .. 1.0e12,
       Post => (if Result /= Success then Full.Length = 0);
end MJ.Collision_Contacts;

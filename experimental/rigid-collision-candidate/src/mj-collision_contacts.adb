with MJ.Advanced_Contacts;
package body MJ.Collision_Contacts with SPARK_Mode is
   procedure Generate (A, B : Object; PA, PB : Pose; V : Vertex_Array; F : Facet_Array;
                       Graphs : Graph_Array; P : Parameters; Geoms : Pair; O : Options;
                       W : in out MJ.Convex_Contacts.Workspace;
                       Full : in out Full_Manifold; Result : out Status;
                       Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup) is
      M : Manifold;
   begin
      Full.Length := 0;
      MJ.Advanced_Contacts.Generate (A, B, PA, PB, V, F, P.Detection_Margin, O, W, M, Result, Graphs, Incidence);
      if Result = Success then Finalize (M, P, Geoms, Full, Result); end if;
   end Generate;

   procedure Generate_Terrain
     (H : MJ.Heightfield_Contacts.Heightfield; E : MJ.Heightfield_Contacts.Elevation_Array;
      PH : Pose; B : Object; PB : Pose; V : Vertex_Array; Graphs : Graph_Array;
      P : Parameters; Geoms : Pair; O : Options; W : in out MJ.Convex_Contacts.Workspace;
      Full : in out Full_Manifold; Result : out Status) is
      M : Manifold;
   begin
      Full.Length := 0;
      MJ.Heightfield_Contacts.Generate (H, E, PH, B, PB, V, P.Detection_Margin, O, W, M, Result, Graphs);
      if Result = Success then Finalize (M, P, Geoms, Full, Result); end if;
   end Generate_Terrain;
end MJ.Collision_Contacts;

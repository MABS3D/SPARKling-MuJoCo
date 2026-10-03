with MJ.Models;
with MJ.Contact_Geometry;
with MJ.Heightfield_Contacts;
with MJ.Contact_Incidence;
with MJ.Collision_Scene;

--  Assets are copied once from the compiled MJB model. The original model
--  may then be freed. No allocation or asset mutation occurs in Step.
package MJ.Constrained_Assets with SPARK_Mode is
   type Status is (Success, Invalid_Model, Capacity_Exceeded, Unsupported_Feature);
   Max_Vertices : constant := 65_536;
   Max_Facets : constant := 65_536;
   Max_Graph : constant := 1_048_576;
   Max_Elevations : constant := 1_048_576;
   type Vertex_Access is access MJ.Contact_Geometry.Vertex_Array;
   type Facet_Access is access MJ.Contact_Geometry.Facet_Array;
   type Graph_Access is access MJ.Contact_Geometry.Graph_Array;
   type Elevation_Access is access MJ.Heightfield_Contacts.Elevation_Array;
   type Store is limited record
      Vertices : Vertex_Access := null;
      Facets : Facet_Access := null;
      Graphs : Graph_Access := null;
      Elevations : Elevation_Access := null;
      Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup;
   end record;
   function Loaded (A : Store) return Boolean is
     (A.Vertices /= null and then A.Facets /= null
      and then A.Graphs /= null and then A.Elevations /= null);
   procedure Release (A : in out Store)
     with Post => not Loaded (A)
       and then A.Vertices = null and then A.Facets = null
       and then A.Graphs = null and then A.Elevations = null;
   procedure Load (M : MJ.Models.Model; A : in out Store; Result : out Status)
     with Pre => MJ.Models.Valid_Layout (M),
       Post => (if Result = Success then Loaded (A)
         else not Loaded (A));
   procedure Configure (M : MJ.Models.Model; G : Natural; A : Store;
                        Shape : in out MJ.Collision_Scene.Geometry;
                        Result : out Status)
     with Pre => MJ.Models.Valid_Layout (M) and then G < M.S.Ngeom and then Loaded (A);
end MJ.Constrained_Assets;

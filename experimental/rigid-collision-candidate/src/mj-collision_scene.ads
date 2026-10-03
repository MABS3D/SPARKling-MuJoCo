with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Rigid_Detector;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Contact_Parameters; use MJ.Contact_Parameters;
with MJ.Full_Contacts; use MJ.Full_Contacts;
with MJ.Convex_Contacts;
with MJ.Heightfield_Contacts; use MJ.Heightfield_Contacts;
with MJ.Contact_Incidence;

package MJ.Collision_Scene with SPARK_Mode is
   type Geometry is record
      Solid : Object;
      Surface : Material;
      Terrain : Boolean := False;
      Field : Heightfield;
      Elevation_First, Elevation_Length : Natural := 0;
   end record;
   type Geometry_Array is array (Natural range <>) of Geometry;
   type Declared_Pair is record
      Geoms : Pair := (0, 1);
      Margin, Gap : Real range 0.0 .. 1.0e10 := 0.0;
      Param : Parameters := Default_Parameters;
   end record;
   type Declared_Array is array (Natural range <>) of Declared_Pair;
   type Scene is limited private;

   function Initialized (S : Scene) return Boolean with Global => null;
   function Geom_Count (S : Scene) return Count with Global => null;
   --  C orders each emitted pair by geom type before narrowphase. Candidate
   --  list ordering still uses the original canonical geom IDs.
   function Contact_Type (S : Scene; G : Geom_Id) return Natural
     with Global => null, Pre => Initialized (S) and then G < Geom_Count (S),
       Post => Contact_Type'Result <= 7;
   function Contact_Order (S : Scene; P : Pair) return Boolean is
     (Initialized (S) and then P.First < Geom_Count (S) and then P.Second < Geom_Count (S)
      and then (Contact_Type (S, P.First) < Contact_Type (S, P.Second)
        or else (Contact_Type (S, P.First) = Contact_Type (S, P.Second) and then P.First < P.Second)))
     with Global => null;
   function Selected_Count (S : Scene) return Natural with Global => null;
   function Generation_Count (S : Scene) return Natural with Global => null;
   function BVH_Node_Tests (S : Scene) return Natural with Global => null;
   function BVH_Leaf_Tests (S : Scene) return Natural with Global => null;
   --  Asset admission is checked at initialization. Later calls retain this
   --  as a contract: vertices may change only within the installed bounds.
   function Assets_Admissible (S : Scene; V : Vertex_Array; E : Elevation_Array;
                               Graphs : Graph_Array) return Boolean
     with Global => null;

   procedure Initialize
     (S : in out Scene; Geoms : Geometry_Array; V : Vertex_Array;
      E : Elevation_Array; Graphs : Graph_Array; Explicit_Pairs : Declared_Array;
      Exclusions : Exclusion_Array; O : Options; Override : Override_Parameters;
      Result : out Status)
     with Global => null,
       Post => Initialized (S) = (Result = Success)
         and then (if Result = Success then Geom_Count (S) = Geoms'Length
           and then Assets_Admissible (S, V, E, Graphs));

   --  No boolean Test before Generate. Output is a flat caller-owned buffer;
   --  only the initialized prefix is exposed. Failure invalidates the prefix.
   procedure Generate
     (S : in out Scene; Poses : Pose_Array; V : Vertex_Array; F : Facet_Array;
      E : Elevation_Array; Graphs : Graph_Array; Contacts : in out Full_Array;
      Length : out Natural; Result : out Status;
      Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup)
     with Global => null,
       Pre => Initialized (S) and then Assets_Admissible (S, V, E, Graphs)
         and then MJ.Contact_Incidence.Matches (Incidence, F),
       Post => Length <= Contacts'Length
         and then (if Result /= Success then Length = 0)
         and then (for all I in 0 .. Length-1 =>
           Contacts (Contacts'First+I)'Initialized
           and then Contact_Order (S, Contacts (Contacts'First+I).Geoms));
private
   type Parameter_Array is array (Natural range 0 .. Max_Pairs-1) of Parameters;
   type Scene is limited record
      Ready : Boolean := False;
      N : Count := 0;
      Config : Options;
      Override : Override_Parameters;
      Geometries : Geometry_Array (0 .. Max_Geoms-1);
      Proxies : Shape_Array (0 .. Max_Geoms-1);
      Explicit_Parameters : Parameter_Array;
      Search : MJ.Rigid_Detector.Scene;
      Candidates : MJ.Rigid_Detector.Candidate_List;
      Convex : MJ.Convex_Contacts.Workspace;
      Calls : Natural := 0;
   end record;
end MJ.Collision_Scene;

with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Contact_Incidence;
package MJ.Contact_Features with SPARK_Mode is
   type Feature_Indices is array (Axis) of Integer;
   type Feature_Points is array (Axis) of Vec;
   procedure Expand (A, B : Object; PA, PB : Pose; V : Vertex_Array; Facets : Facet_Array;
                     I1, I2 : Feature_Indices; P1, P2 : Feature_Points;
                     M : in out Manifold; Result : out Status;
                     Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup)
     with Global => null, Pre => M.Length = 1 and then MJ.Contact_Incidence.Matches (Incidence, Facets),
       Post => (if Result /= Success then M.Length = 0);
end MJ.Contact_Features;

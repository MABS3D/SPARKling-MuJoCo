with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Convex_Contacts;
with MJ.Contact_Incidence;
package MJ.Advanced_Contacts with SPARK_Mode is
   procedure Generate (A, B : Object; PA, PB : Pose; V : Vertex_Array; F : Facet_Array;
                       Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph;
                       Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup)
     with Global => null,
       Subprogram_Variant => (Decreases => (if A.Kind = Hull and B.Kind = Primitive then 1 else 0)),
       Pre => Valid_Object (A, V) and Valid_Object (B, V) and Valid_Pose (PA) and Valid_Pose (PB)
         and MJ.Contact_Incidence.Matches (Incidence, F),
       Post => (if Result /= Success then M.Length = 0);
end MJ.Advanced_Contacts;

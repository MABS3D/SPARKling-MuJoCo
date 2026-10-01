with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Convex_Contacts;
package MJ.Contact_Perturbations with SPARK_Mode is
   procedure Expand (A, B : Object; PA, PB : Pose; V : Vertex_Array;
                     Margin, Radius1, Radius2 : Real; O : Options;
                     W : in out MJ.Convex_Contacts.Workspace;
                     M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph)
     with Global => null, Pre => M.Length = 1 and Active_Initialized (M) and Valid_Pose (PA) and Valid_Pose (PB) and Valid_Object (A, V) and Valid_Object (B, V),
       Post => (if Result /= Success then M.Length = 0);
end MJ.Contact_Perturbations;

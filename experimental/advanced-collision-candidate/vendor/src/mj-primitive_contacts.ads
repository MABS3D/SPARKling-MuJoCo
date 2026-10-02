with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Convex_Contacts;

package MJ.Primitive_Contacts with SPARK_Mode is
   procedure Generate (A, B : Shape; PA, PB : Pose; Margin : Real; O : Options;
                       W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status)
     with Global => null, Pre => Valid_Shape (A) and Valid_Shape (B)
       and Valid_Placement (A, PA) and Valid_Placement (B, PB)
       and Margin in 0.0 .. 1.0e12,
       Post => (if Result /= Success then M.Length = 0);
end MJ.Primitive_Contacts;

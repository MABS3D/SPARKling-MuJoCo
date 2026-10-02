with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
package MJ.Flex_Normals with SPARK_Mode is
   procedure Correct (S : Shape; P : Pose; M : in out Manifold; Result : out Status)
     with Global => null, Pre => Valid_Shape (S) and Valid_Pose (P),
       Post => (if Result/=Success then M.Length=0);
end MJ.Flex_Normals;

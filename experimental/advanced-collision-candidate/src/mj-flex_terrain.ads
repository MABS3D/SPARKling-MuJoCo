with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Heightfield_Contacts; use MJ.Heightfield_Contacts;
with MJ.Convex_Contacts;
package MJ.Flex_Terrain with SPARK_Mode is
   procedure Generate (H : Heightfield; Elevation : Elevation_Array; P : Pose;
                       Vertices : Vertex_Array; Center : Vec; Radius, Margin : Real;
                       O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status)
     with Global=>null,
       Pre=>Valid (H,Elevation) and Valid_Pose (P) and Vertices'Length in 2 .. 4
         and (for all V of Vertices => (for all X of V => X in Coordinate))
         and (for all X of Center => X in Coordinate)
         and Radius in 0.0 .. 1.0e10 and Margin in 0.0 .. 1.0e10,
       Post=>(if Result/=Success then M.Length=0);
end MJ.Flex_Terrain;

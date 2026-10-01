with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Convex_Contacts;
package MJ.Heightfield_Contacts with SPARK_Mode is
   type Elevation_Array is array (Natural range <>) of Real;
   type Heightfield is record
      Rows, Columns : Natural range 2 .. 65536 := 2;
      Half_X, Half_Y, Height, Base : Real range 1.0e-10 .. 1.0e10 := 1.0;
   end record;
   function Valid (H : Heightfield; E : Elevation_Array) return Boolean is
     (H.Rows <= Natural'Last/H.Columns and then E'Length = H.Rows*H.Columns
      and then (for all X of E => X in 0.0 .. 1.0)) with Global => null;
   procedure Generate (H : Heightfield; E : Elevation_Array; PH : Pose;
                       B : Object; PB : Pose; V : Vertex_Array;
                       Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph)
     with Global => null, Pre => Valid (H, E) and Valid_Object (B, V)
       and (B.Kind /= Primitive or else B.Rigid.Kind /= Plane)
       and Valid_Pose (PH) and Valid_Pose (PB)
       and Margin in 0.0 .. 1.0e12,
       Post => (if Result /= Success then M.Length = 0);
end MJ.Heightfield_Contacts;

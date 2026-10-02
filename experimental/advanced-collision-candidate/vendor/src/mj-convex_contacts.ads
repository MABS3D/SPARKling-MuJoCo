with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;

with MJ.Convex_Assets;
with MJ.Contact_Incidence;

package MJ.Convex_Contacts with SPARK_Mode is
   type Workspace is limited private;
   procedure Support_Point (S : Object; P : Pose; V : Vertex_Array; D : Vec;
                            Point : out Vec; Index : out Integer)
     with Global => null, Pre => Valid_Object (S, V) and then
       (S.Kind /= Primitive or else S.Rigid.Kind /= Plane);
   procedure Support_Cached (S : Object; P : Pose; V : Vertex_Array; D : Vec;
                             Graphs : Graph_Array; Cache : in out Integer;
                             Point : out Vec; Index : out Integer)
     with Global => null, Pre => Valid_Object (S, V) and then MJ.Convex_Assets.Valid_Graph (S, Graphs)
       and then (S.Kind /= Hull or else S.Length < 10 or else S.Graph_Length = 0 or else Cache < 0
         or else Cache < Graphs (S.First_Graph));
   procedure Generate (A, B : Object; PA, PB : Pose; V : Vertex_Array;
                       Margin : Real; O : Options; W : in out Workspace;
                       M : in out Manifold; Result : out Status;
                       Facets : Facet_Array := Empty_Facets; Multiple : Boolean := False;
                       Inflation1, Inflation2, Output_Margin : Real := -1.0; Graphs : Graph_Array := Empty_Graph;
                       Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup)
     with Global => null, Pre => Valid_Object (A, V) and Valid_Object (B, V)
       and Valid_Pose (PA) and Valid_Pose (PB)
       and MJ.Convex_Assets.Valid_Graph (A, Graphs) and MJ.Convex_Assets.Valid_Graph (B, Graphs)
       and (A.Kind /= Primitive or else A.Rigid.Kind /= Plane)
       and (B.Kind /= Primitive or else B.Rigid.Kind /= Plane),
       Post => (if Result /= Success then M.Length = 0);
private
   Max_Vertices : constant := 1005;
   Max_Faces : constant := 6000;
   subtype Vertex_Id is Natural range 0 .. Max_Vertices-1;
   subtype Face_Id is Natural range 0 .. Max_Faces-1;
   type Vertex is record
      Point, First, Second : Vec := Zero;
      Index1, Index2 : Integer := -1;
   end record;
   type Vertex_Buffer is array (Vertex_Id) of Vertex;
   type Triple is array (Axis) of Natural;
   type Face is record
      Vertices, Adjacent : Triple := [others => 0];
      Projection : Vec := Zero;
      Distance2 : Real := 0.0;
      Map_Index : Integer := -1;
   end record;
   type Face_Buffer is array (Face_Id) of Face;
   type Face_Map is array (Face_Id) of Face_Id;
   type Horizon_Array is array (Natural range 0 .. Max_Faces-1) of Natural;
   type Workspace is limited record
      Vertices : Vertex_Buffer;
      Faces : Face_Buffer;
      Map : Face_Map;
      Horizon_Faces, Horizon_Edges : Horizon_Array;
      NV : Natural range 0 .. Max_Vertices := 0;
      NF, NM, NH : Natural range 0 .. Max_Faces := 0;
      Center : Vec := Zero;
   end record;
end MJ.Convex_Contacts;

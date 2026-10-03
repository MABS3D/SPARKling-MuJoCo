with MJ.Models;
with MJ.Ray_Kernels; use MJ.Ray_Kernels;
with MJ.Ray_Geometry;
with MJ.Types; use MJ.Types;
package MJ.Rays with SPARK_Mode is
   Max_Geometries : constant := 4_096;
   Max_Bodies : constant := 4_096;
   Max_Assets : constant := 1_024;
   Max_Vertices : constant := 65_536;
   Max_Faces : constant := 65_536;
   Max_Nodes : constant := 131_072;
   Max_Heights : constant := 262_144;
   type Status is (Success, Not_Ready, Already_Ready, Invalid_Model,
                   Capacity_Exceeded, Unsupported_Feature, Invalid_Ray, Numeric_Limit);
   type Result is record
      Distance : Real := -1.0;
      Geometry_Id : Integer := -1;
      Normal : Vector := Zero;
   end record;
   type Options is record
      Include_Static : Boolean := True;
      Excluded_Body : Integer := -1;
      Filter_Groups : Boolean := False;
      Mask : Groups := [others => True];
      Cutoff : Real := Real'Last;
   end record;
   type Scene is limited private;
   function Ready (S : Scene) return Boolean;
   function Geometry_Count (S : Scene) return Natural;
   function Body_Count (S : Scene) return Natural;
   function Poses_Ready (S : Scene) return Boolean;
   procedure Initialize (M : MJ.Models.Model; S : in out Scene; State : out Status);
   procedure Clear (S : in out Scene) with Post => not Ready (S);
   procedure Set_Body_Pose (S : in out Scene; Body_Id : Natural;
                            Position : Vector; Rotation : Matrix);
   procedure Cast (S : Scene; Point, Direction : Vector; Hit : out Result;
                   State : out Status; Filter : Options := (others => <>))
     with Post => (if State /= Success then Hit = Result'(others => <>))
       and then (if State = Success then
         ((Hit.Geometry_Id = -1 and then Hit.Distance = -1.0 and then Hit.Normal = Zero)
          or else (Hit.Geometry_Id in 0 .. Integer (Geometry_Count (S))-1 and then Hit.Distance >= 0.0)));
   type Directions is array (Integer range <>) of Vector;
   type Results is array (Integer range <>) of Result;
   procedure Cast_Many (S : Scene; Point : Vector; Vectors : Directions;
                        Hits : out Results; State : out Status; Filter : Options := (others => <>));
private
   type Geometry is record
      Shape : MJ.Ray_Geometry.Kind := MJ.Ray_Geometry.Plane;
      Body_Id, Weld_Id, Group_Id, Data_Id : Integer := 0;
      Visible : Boolean := True;
      Size, Local_Position, Position : Vector := Zero;
      Local_Rotation, Rotation : Matrix := Identity;
   end record;
   type Geometries is array (Integer range 0 .. Max_Geometries-1) of Geometry;
   type Vertices is array (Integer range 0 .. Max_Vertices-1) of Vector;
   type Face is array (Axis) of Integer;
   type Faces is array (Integer range 0 .. Max_Faces-1) of Face;
   type Mesh_Info is record
      Face_Start, Vertex_Start, Node_Start, Node_Count : Integer := 0;
   end record;
   type Meshes is array (Integer range 0 .. Max_Assets-1) of Mesh_Info;
   type Node is record
      Child_0, Child_1, Face_Id : Integer := -1;
      Center, Half_Size : Vector := Zero;
   end record;
   type Nodes is array (Integer range 0 .. Max_Nodes-1) of Node;
   type Terrain_Info is record
      Rows, Columns, Start : Integer := 0;
      Size : Vector := Zero;
      Base_Depth : Real := 0.0;
   end record;
   type Terrains is array (Integer range 0 .. Max_Assets-1) of Terrain_Info;
   type Heights is array (Integer range 0 .. Max_Heights-1) of Real;
   type Body_Heads is array (Integer range 0 .. Max_Bodies-1) of Integer;
   type Geometry_Links is array (Integer range 0 .. Max_Geometries-1) of Integer;
   type Pose_Flags is array (Integer range 0 .. Max_Bodies-1) of Boolean;
   type Scene is limited record
      Initialized : Boolean := False;
      Ng, Nb : Natural := 0;
      Posed_Bodies : Natural := 0;
      First_Geom : Body_Heads := [others => -1];
      Next_Geom : Geometry_Links := [others => -1];
      Posed : Pose_Flags := [others => False];
      Shapes : Geometries;
      Points : Vertices;
      Triangles : Faces;
      Mesh_Data : Meshes;
      Tree : Nodes;
      Terrain_Data : Terrains;
      Elevations : Heights;
   end record;
   function Ready (S : Scene) return Boolean is (S.Initialized);
   function Geometry_Count (S : Scene) return Natural is (S.Ng);
   function Body_Count (S : Scene) return Natural is (S.Nb);
   function Poses_Ready (S : Scene) return Boolean is
     (S.Initialized and then S.Posed_Bodies=S.Nb);
end MJ.Rays;

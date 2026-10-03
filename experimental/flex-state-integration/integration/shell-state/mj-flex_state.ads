with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Rigid_Geometry;
with MJ.Contact_Geometry;
with MJ.Contact_Parameters;
with MJ.Flex_Collisions;
with MJ.Builtin_Flex;
with MJ.BVH;
with MJ.Convex_Contacts;
with MJ.Constrained_Assets;
with MJ.SDF_Scene;
with MJ.Full_Contacts;
with MJ.Flex_Interpolation;
package MJ.Flex_State with SPARK_Mode is
   Max_Flex : constant := 16;
   Max_Vertices : constant := 4096;
   Max_Elements : constant := 4096;
   Max_Geometries : constant := 256;
   Max_Bodies : constant := 4096;
   Max_Contacts : constant := 4096;
   type Status is (Success, Invalid_Model, Unsupported_Feature, Already_Allocated,
     Not_Allocated, Invalid_Input, Capacity_Limit, Numeric_Limit, Stale_State);
   type State is limited private;
   type Contact is record
      Geometry : MJ.Contact_Geometry.Contact;
      Geom : Integer := -1;
      Flex_First, Flex_Second : Integer := -1;
      Elem_First, Elem_Second, Vert_First, Vert_Second : Integer := -1;
      Parameters : MJ.Contact_Parameters.Parameters := MJ.Contact_Parameters.Default_Parameters;
   end record;
   type Contact_Array is array (Natural range <>) of Contact;
   type Contact_List (Capacity : Natural) is limited record
      Length : Natural := 0;
      Items : Contact_Array (1 .. Capacity);
   end record;
   function Ready (S : State) return Boolean;
   function Current (S : State) return Boolean;
   function Body_Count (S : State) return Natural;
   function Flex_Count (S : State) return Natural;
   function Has_SDF (S : State) return Boolean;
   procedure Generate_Rigid_Contacts (S : in out State;
     Poses : MJ.Rigid_Geometry.Pose_Array; Contacts : in out MJ.Full_Contacts.Full_Array;
     Length : out Natural; Result : out Status)
     with Pre => Ready (S) and then Has_SDF (S),
       Post => Length <= Contacts'Length and then (if Result /= Success then Length = 0);
   function Vertex_Count (S : State; F : Natural) return Natural
     with Pre => Ready (S) and F < Flex_Count (S);
   function Interpolation_Order (S : State; F : Natural) return Integer
     with Pre => Ready (S) and F < Flex_Count (S);
   function Node_Count (S : State; F : Natural) return Natural
     with Pre => Ready (S) and F < Flex_Count (S);
   function Node_Body (S : State; F, N : Natural) return Integer
     with Pre => Ready (S) and then F < Flex_Count (S) and then N < Node_Count (S, F);
   function Node_Position (S : State; F, N : Natural) return MJ.Rigid_Geometry.Vec
     with Pre => Ready (S) and then F < Flex_Count (S) and then N < Node_Count (S, F);
   function Dimension (S : State; F : Natural) return Positive
     with Pre => Ready (S) and F < Flex_Count (S), Post => Dimension'Result in 1 .. 3;
   function Element_Count (S : State; F : Natural) return Natural
     with Pre => Ready (S) and F < Flex_Count (S);
   function Element_Vertex (S : State; F, E, Corner : Natural) return Natural
     with Pre => Ready (S) and then F < Flex_Count (S)
       and then E < Element_Count (S,F) and then Corner <= Dimension (S,F);
   function Vertex_Body (S : State; F, V : Natural) return Integer
     with Pre => Ready (S) and then F < Flex_Count (S) and then V < Vertex_Count (S,F);
   function Position (S : State; F, V : Natural) return MJ.Rigid_Geometry.Vec
     with Pre => Ready (S) and F < Flex_Count (S) and V < Vertex_Count (S,F);
   procedure Create (M : MJ.Models.Model; S : in out State; Result : out Status)
     with Post => (if Result = Success then Ready (S) and not Current (S));
   procedure Free (S : in out State)
     with Post => not Ready (S) and not Current (S);
   --  Poses come from the same body's kinematic state, never from C collisions.
   --  Rejection preserves published vertex positions, invalidates cache currency.
   procedure Update (S : in out State; Bodies : MJ.Rigid_Geometry.Pose_Array;
                     Result : out Status;
                     Geometries : MJ.Rigid_Geometry.Pose_Array := [1 .. 0 => <>])
     with Post => (if Result = Success then Current (S));
   procedure Detect (S : in out State; Contacts : in out Contact_List;
                     Result : out Status)
     with Post => Contacts.Length <= Contacts.Capacity
       and (if Result /= Success then Contacts.Length = 0);
private
   package RG renames MJ.Rigid_Geometry;
   package FC renames MJ.Flex_Collisions;
   package CG renames MJ.Contact_Geometry;
   package CP renames MJ.Contact_Parameters;
   package CA renames MJ.Constrained_Assets;
   type Flex_Block is limited record
      Description : FC.Flex;
      Material : CP.Material;
      Centered : Boolean := False;
      Nv, Ne, Ni : Natural := 0;
      Interp : Integer range -2 .. 2 := 0;
      Nn : Natural range 0 .. Max_Vertices := 0;
      Cells : MJ.Flex_Interpolation.Grid := [others => 1];
      Local, World, Candidate : CG.Vertex_Array (0 .. Max_Vertices-1);
      Bodies : FC.Body_Array (0 .. Max_Vertices-1);
      Node_Local, Node_World, Node_Candidate : CG.Vertex_Array (0 .. Max_Vertices-1);
      Node_Bodies : FC.Body_Array (0 .. Max_Vertices-1);
      Elements : FC.Element_Array (0 .. Max_Elements-1);
      Internal : FC.Internal_Array (0 .. Max_Elements-1);
      Tree : MJ.BVH.Tree;
   end record;
   type Flex_Array is array (Natural range 0 .. Max_Flex-1) of Flex_Block;
   type Geom_Block is record
      Collider : MJ.Builtin_Flex.Collider;
      Local : RG.Pose;
      Body_Id : Natural := 0;
      Material : CP.Material;
      Elevation_First, Elevation_Length : Natural := 0;
   end record;
   type Geom_Array is array (Natural range 0 .. Max_Geometries-1) of Geom_Block;
   type State is limited record
      Initialized, Positions_Current : Boolean := False;
      Nf, Ng, Nb : Natural := 0;
      Flexes : Flex_Array;
      Geoms : Geom_Array;
      Assets : CA.Store;
      SDF : MJ.SDF_Scene.Scene;
      Uses_SDF : Boolean := False;
      Geom_Candidate : RG.Pose_Array (0 .. Max_Geometries-1);
      Options : RG.Options;
      Midphase : Boolean := True;
      Work : MJ.Convex_Contacts.Workspace;
      Group : FC.Batch (Max_Contacts);
      Pending : Contact_Array (0 .. Max_Contacts-1);
   end record;
   function Ready (S : State) return Boolean is (S.Initialized);
   function Current (S : State) return Boolean is (S.Initialized and S.Positions_Current);
   function Body_Count (S : State) return Natural is (S.Nb);
   function Flex_Count (S : State) return Natural is (S.Nf);
   function Has_SDF (S : State) return Boolean is (S.Uses_SDF);
   function Vertex_Count (S : State; F : Natural) return Natural is (S.Flexes (F).Nv);
   function Interpolation_Order (S : State; F : Natural) return Integer is (S.Flexes (F).Interp);
   function Node_Count (S : State; F : Natural) return Natural is (S.Flexes (F).Nn);
   function Node_Body (S : State; F, N : Natural) return Integer is (S.Flexes (F).Node_Bodies (N));
   function Node_Position (S : State; F, N : Natural) return RG.Vec is (S.Flexes (F).Node_World (N));
   function Dimension (S : State; F : Natural) return Positive is (S.Flexes (F).Description.Dimension);
   function Element_Count (S : State; F : Natural) return Natural is (S.Flexes (F).Ne);
   function Element_Vertex (S : State; F, E, Corner : Natural) return Natural is
     (S.Flexes (F).Elements (E).Vertices (Corner));
   function Vertex_Body (S : State; F, V : Natural) return Integer is (S.Flexes (F).Bodies (V));
   function Position (S : State; F, V : Natural) return RG.Vec is (S.Flexes (F).World (V));
end MJ.Flex_State;

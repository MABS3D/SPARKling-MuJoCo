with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.BVH;
with MJ.Convex_Contacts;
with MJ.Heightfield_Contacts;
package MJ.Flex_Collisions with SPARK_Mode is
   type Self_Mode is (None, Narrow, BVH, SAP, Auto);
   type Flex is record
      Id : Natural := 0;
      Dimension : Positive range 1 .. 3 := 2;
      Radius, Margin, Gap : Real range 0.0 .. 1.0e10 := 0.0;
      Contype, Conaffinity : Interfaces.Unsigned_32 := 1;
      Active_Layers : Natural := Natural'Last;
      Self_Collision : Self_Mode := Auto;
      Rigid, Internal : Boolean := False;
   end record;
   type Vertex_Indices is array (Natural range 0 .. 3) of Natural;
   type Element is record
      Vertices : Vertex_Indices := [others => 0];
      Layer : Natural := 0;
   end record;
   type Element_Array is array (Natural range <>) of Element;
   type Body_Array is array (Natural range <>) of Integer;
   type Internal_Pair is record Elem, Vert : Natural; end record;
   type Internal_Array is array (Natural range <>) of Internal_Pair;
   function Active (F : Flex; E : Element) return Boolean is
     (F.Dimension < 3 or else E.Layer < F.Active_Layers) with Global => null;
   function Compatible (A, B : Flex) return Boolean;
   function Valid (F : Flex; E : Element; V : Vertex_Array; Bodies : Body_Array) return Boolean is
     ((for all K in 0 .. F.Dimension => E.Vertices (K) in V'Range
         and then E.Vertices (K) in Bodies'Range)
       and then (for all K in 0 .. F.Dimension =>
         (for all X of V (E.Vertices (K)) => X in -1.0e10 .. 1.0e10)));
   function Bounds (F : Flex; E : Element; V : Vertex_Array) return MJ.BVH.Box
     with Global => null,
       Pre => (for all K in 0 .. F.Dimension => E.Vertices (K) in V'Range
         and then (for all X of V (E.Vertices (K)) => X in -1.0e10 .. 1.0e10));
   function Fits (F : Flex; E : Element_Array; V : Vertex_Array; T : MJ.BVH.Tree)
      return Boolean with Global=>null;
   procedure Update_Tree (F : Flex; E : Element_Array; V : Vertex_Array;
                          T : in out MJ.BVH.Tree; Rebuild : Boolean; Result : out Status)
     with Global => null, Pre => (if not Rebuild then MJ.BVH.Topology_Valid (T)),
       Post => (if Result /= Success then T.Length = 0 else MJ.BVH.Valid (T) and then Fits (F,E,V,T));
   procedure Geom_Element (G : Object; PG : Pose; Assets : Vertex_Array;
                           F : Flex; E : Element; V : Vertex_Array; Bodies : Body_Array;
                           Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                           M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph)
     with Global => null,
       Pre => Valid_Object (G, Assets) and Valid_Pose (PG) and Valid (F,E,V,Bodies)
         and Margin in 0.0 .. 1.0e10,
       Post => (if Result /= Success then M.Length = 0);
   procedure Elements (A : Flex; EA : Element; VA : Vertex_Array; BA : Body_Array;
                       B : Flex; EB : Element; VB : Vertex_Array; BB : Body_Array;
                       Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status)
     with Global => null, Pre => Valid (A,EA,VA,BA) and Valid (B,EB,VB,BB)
       and Margin in 0.0 .. 1.0e10,
       Post => (if Result /= Success then M.Length = 0);
   procedure Element_Vertex (F : Flex; E : Element; V : Vertex_Array; Vertex : Natural;
                             O : Options; W : in out MJ.Convex_Contacts.Workspace;
                             M : in out Manifold; Result : out Status)
     with Global => null,
       Post => (if Result /= Success then M.Length = 0);
   procedure Heightfield_Element (H : MJ.Heightfield_Contacts.Heightfield;
                                  Elevation : MJ.Heightfield_Contacts.Elevation_Array;
                                  PH : Pose; F : Flex; E : Element; V : Vertex_Array;
                                  Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                                  M : in out Manifold; Result : out Status)
     with Global => null,
       Post => (if Result /= Success then M.Length = 0);
   type Flex_Contact is record
      Geometry : MJ.Contact_Geometry.Contact;
      First_Element, Second_Element, First_Vertex, Second_Vertex : Integer := -1;
   end record;
   type Flex_Contact_Array is array (Natural range <>) of Flex_Contact;
   type Batch (Capacity : Natural) is limited record
      Length : Natural := 0;
      Items : Flex_Contact_Array (0 .. Capacity);  --  Last slot is a guard; usable count <= Capacity.
   end record;
   procedure Plane (P : Pose; F : Flex; V : Vertex_Array; Margin : Real;
                    C : in out Batch; Result : out Status)
     with Global => null,
       Post => C.Length <= C.Capacity and (if Result /= Success then C.Length = 0);
   --  Same >50 selection/order as C's filterFlexContacts, including its swaps.
   procedure Filter (C : in out Batch; Start : Natural := 0)
     with Global => null, Pre => Start <= C.Length and C.Length <= C.Capacity,
       Post => C.Length <= C.Length'Old and C.Length <= Start + Max_Manifold;
   procedure Self_Contacts (F : Flex; E : Element_Array; V : Vertex_Array; Bodies : Body_Array;
                            T : MJ.BVH.Tree; Internal_Pairs : Internal_Array;
                            Midphase : Boolean; O : Options;
                            W : in out MJ.Convex_Contacts.Workspace; C : in out Batch; Result : out Status)
     with Global => null, Pre => MJ.BVH.Valid (T)
         and then (if Midphase and T.Length>0 then Fits (F,E,V,T)),
       Post => C.Length <= C.Capacity and (if Result /= Success then C.Length = 0);
   procedure Flex_Pair (A : Flex; EA : Element_Array; VA : Vertex_Array; BA : Body_Array; TA : MJ.BVH.Tree;
                        B : Flex; EB : Element_Array; VB : Vertex_Array; BB : Body_Array; TB : MJ.BVH.Tree;
                        Midphase : Boolean; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                        C : in out Batch; Result : out Status)
     with Global => null, Pre => MJ.BVH.Valid (TA) and then MJ.BVH.Valid (TB)
         and then (if Midphase and TA.Length>0 then Fits (A,EA,VA,TA))
         and then (if Midphase and TB.Length>0 then Fits (B,EB,VB,TB)),
       Post => C.Length <= C.Capacity and (if Result /= Success then C.Length = 0);
end MJ.Flex_Collisions;

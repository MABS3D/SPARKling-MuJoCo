with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

package MJ.Contact_Geometry with SPARK_Mode is
   Max_Manifold : constant := 50;
   type Contact is record
      Position, Normal, Tangent : Vec;
      Distance : Real;
   end record;
   type Contact_Array is array (Natural range <>) of Contact with Relaxed_Initialization;
   type Manifold is record
      Length : Natural range 0 .. Max_Manifold := 0;
      Items : Contact_Array (0 .. Max_Manifold-1);
   end record;
   type Vertex_Array is array (Natural range <>) of Vec;
   Empty_Vertices : constant Vertex_Array (1 .. 0) := [others => Zero];
   Max_Facet_Vertices : constant := 64;
   type Facet_Indices is array (Natural range 0 .. Max_Facet_Vertices-1) of Natural;
   type Facet is record
      Normal : Vec := Zero;
      Length : Natural range 0 .. Max_Facet_Vertices := 0;
      Indices : Facet_Indices := [others => 0];
   end record;
   type Facet_Array is array (Natural range <>) of Facet;
   Empty_Facets : constant Facet_Array (1 .. 0) := [others => <>];
   type Graph_Array is array (Natural range <>) of Integer;
   Empty_Graph : constant Graph_Array (1 .. 0) := [others => 0];
   type Extrema_Array is array (Natural range 0 .. 26) of Natural;
   type Object_Kind is (Primitive, Hull, Prism);
   type Object is record
      Kind : Object_Kind := Primitive;
      Rigid : Shape;
      First : Natural := 0;
      Length : Natural := 0;
      Prism_Vertices : Vertex_Array (0 .. 5) := [others => Zero];
      Center_Offset : Vec := Zero;
      First_Graph, Graph_Length : Natural := 0;
      Packed_Graph, Packed_Degrees : Boolean := False;
      Extrema : Extrema_Array := [others => 0];
      First_Facet, Facet_Count : Natural := 0;
      Skin : Real range 0.0 .. 1.0e10 := 0.0;
   end record;
   function Valid_Object (S : Object; V : Vertex_Array) return Boolean is
     (if S.Kind = Primitive then Valid_Shape (S.Rigid)
      elsif S.Kind = Prism then (for all P of S.Prism_Vertices => (for all X of P => X in -1.0e22 .. 1.0e22))
      else S.Length > 0 and then S.First >= V'First and then S.First <= V'Last
        and then S.Length-1 <= V'Last-S.First
        and then (for all I in S.First .. S.First+(S.Length-1) =>
          (for all X of V (I) => X in Coordinate))) with Global => null;
   function As_Object (S : Shape) return Object is
     ((Kind => Primitive, Rigid => S, others => <>)) with Global => null;
   function Finite (C : Contact) return Boolean is
     (C.Distance in -1.0e100 .. 1.0e100
      and then (for all X of C.Position => X in -1.0e100 .. 1.0e100)
      and then (for all X of C.Normal => X in -2.0 .. 2.0)
      and then (for all X of C.Tangent => X in -2.0 .. 2.0)) with Global => null;
   function Active_Initialized (M : Manifold) return Boolean is
     (for all I in 0 .. M.Length-1 => M.Items (I)'Initialized) with Ghost;
   procedure Reverse_Manifold (M : in out Manifold) with Global => null, Pre => Active_Initialized (M),
     Post => Active_Initialized (M) and then M.Length = M.Length'Old
       and then (for all I in 0 .. M.Length-1 =>
         M.Items (I).Position = M.Items'Old (I).Position
         and M.Items (I).Distance = M.Items'Old (I).Distance
         and M.Items (I).Tangent = M.Items'Old (I).Tangent
         and (for all J in Axis => M.Items (I).Normal (J) = -M.Items'Old (I).Normal (J)));
end MJ.Contact_Geometry;

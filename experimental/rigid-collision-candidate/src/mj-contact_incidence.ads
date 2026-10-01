with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;

package MJ.Contact_Incidence with SPARK_Mode is
   --  Immutable vertex-to-polygon map, compiled once with the mesh assets.
   --  Capacity exhaustion is explicit; callers can retain the scanning path.
   Max_Indexed_Vertices : constant := 8192;
   Max_Incidences : constant := 65536;
   type Lookup is private;
   Empty_Lookup : constant Lookup;
   type Corner is record
      Face : Natural;
      Position : Natural range 0 .. Max_Facet_Vertices-1;
   end record;

   function Find_Corner (F : Facet; Vertex : Natural) return Natural
     with Global => null, Inline,
       Post => Find_Corner'Result <= F.Length
         and then (if Find_Corner'Result < F.Length then
           F.Indices (Find_Corner'Result) = Vertex
           and then (for all K in 0 .. Find_Corner'Result-1 => F.Indices (K) /= Vertex)
           else (for all K in 0 .. F.Length-1 => F.Indices (K) /= Vertex));

   function Model_Count (F : Facet_Array; Vertex : Natural; Last : Integer) return Natural
     with Ghost, Global => null,
       Pre => F'Length <= Max_Incidences and then Last <= F'Last,
       Subprogram_Variant => (Decreases => Last),
       Post => Model_Count'Result <= (if F'Length = 0 or else Last < F'First then 0 else Last-Integer (F'First)+1);
   function Matches (L : Lookup; F : Facet_Array) return Boolean with Ghost, Global => null;
   function Describes (L : Lookup; First_Vertex, Vertex_Count : Natural) return Boolean
     with Ghost, Global => null;

   function Covers (L : Lookup; S : Object; F : Facet_Array) return Boolean
     with Global => null, Inline;
   function Has_Vertex (L : Lookup; Vertex : Natural) return Boolean
     with Global => null, Inline;
   function Count (L : Lookup; Vertex : Natural) return Natural
     with Global => null, Inline, Pre => Has_Vertex (L, Vertex);
   function Item (L : Lookup; Vertex, Number : Natural) return Corner
     with Global => null, Inline,
       Pre => Has_Vertex (L, Vertex) and then Number < Count (L, Vertex);

   --  The lookup must be rebuilt if the facet/vertex IDs change.  Covers
   --  checks ranges; it does not establish identity of mutable asset data.
   procedure Build (First_Vertex, Vertex_Count : Natural; F : Facet_Array;
                    L : out Lookup; Result : out Status)
     with Global => null,
       Pre => Vertex_Count = 0 or else Vertex_Count-1 <= Natural'Last-First_Vertex,
       Post => Matches (L, F) and then
         (if Result /= Success then L = Empty_Lookup
          else Describes (L, First_Vertex, Vertex_Count));
private
   subtype Vertex_Id is Natural range 0 .. Max_Indexed_Vertices-1;
   subtype Entry_Id is Natural range 0 .. Max_Incidences-1;
   type Offsets is array (Vertex_Id) of Natural range 0 .. Max_Incidences;
   type Entries is array (Natural range <>) of Corner;
   type Lookup is record
      Ready : Boolean := False;
      First, Facet_Count : Natural := 0;
      First_Facet : Integer := 0;
      Length : Natural range 0 .. Max_Indexed_Vertices := 0;
      Start, Size : Offsets := [others => 0];
      Data : Entries (Entry_Id) := [others => (Face => 0, Position => 0)];
   end record;
   Empty_Lookup : constant Lookup := (others => <>);
   function List_Matches (Data : Entries; F : Facet_Array; Vertex : Natural) return Boolean
     with Ghost, Global => null, Pre => F'Length <= Max_Incidences and then Data'Length <= Max_Incidences,
       Post => List_Matches'Result =
         (Data'Length = Model_Count (F, Vertex, F'Last)
          and then (for all K in Data'Range =>
            Data (K).Face in F'Range
            and then Data (K).Position < F (Data (K).Face).Length
            and then Data (K).Position = Find_Corner (F (Data (K).Face), Vertex)
            and then (if K > Data'First then Data (K-1).Face < Data (K).Face)));
   function Vertex_Matches (L : Lookup; F : Facet_Array; Vertex : Natural) return Boolean
     with Ghost, Global => null,
       Pre => Vertex < L.Length and then Vertex <= Natural'Last-L.First
         and then F'Length <= Max_Incidences;
end MJ.Contact_Incidence;

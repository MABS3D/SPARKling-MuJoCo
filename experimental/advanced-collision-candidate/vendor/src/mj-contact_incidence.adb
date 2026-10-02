package body MJ.Contact_Incidence with SPARK_Mode is
   function Find_Corner (F : Facet; Vertex : Natural) return Natural is
   begin
      for K in 0 .. F.Length-1 loop
         pragma Loop_Invariant (for all J in 0 .. K-1 => F.Indices (J) /= Vertex);
         if F.Indices (K) = Vertex then return K; end if;
      end loop;
      return F.Length;
   end Find_Corner;

   function Model_Count (F : Facet_Array; Vertex : Natural; Last : Integer) return Natural is
     (if F'Length = 0 or else Last < F'First then 0 else Model_Count (F, Vertex, Last-1)
       + (if Find_Corner (F (Last), Vertex) < F (Last).Length then 1 else 0));

   function List_Matches (Data : Entries; F : Facet_Array; Vertex : Natural) return Boolean is
   begin
      return Data'Length = Model_Count (F, Vertex, F'Last)
        and then (for all K in Data'Range =>
          Data (K).Face in F'Range
          and then Data (K).Position < F (Data (K).Face).Length
          and then Data (K).Position = Find_Corner (F (Data (K).Face), Vertex)
          and then (if K > Data'First then Data (K-1).Face < Data (K).Face));
   end List_Matches;

   function Vertex_Matches (L : Lookup; F : Facet_Array; Vertex : Natural) return Boolean is
     (L.Size (Vertex) <= Max_Incidences-L.Start (Vertex)
      and then List_Matches (L.Data (L.Start (Vertex) .. L.Start (Vertex)+L.Size (Vertex)-1), F, L.First+Vertex));

   function Matches (L : Lookup; F : Facet_Array) return Boolean is
     (not L.Ready or else (F'Length <= Max_Incidences
      and then L.First_Facet = F'First and then L.Facet_Count = F'Length
      and then (L.Length = 0 or else L.Length-1 <= Natural'Last-L.First)
      and then (for all V in 0 .. L.Length-1 => Vertex_Matches (L, F, V))));

   function Describes (L : Lookup; First_Vertex, Vertex_Count : Natural) return Boolean is
     (L.Ready and L.First = First_Vertex and L.Length = Vertex_Count);

   function Has_Vertex (L : Lookup; Vertex : Natural) return Boolean is
     (L.Ready and then Vertex >= L.First and then Vertex-L.First < L.Length
      and then L.Size (Vertex-L.First) <= Max_Incidences-L.Start (Vertex-L.First));

   function Covers (L : Lookup; S : Object; F : Facet_Array) return Boolean is
     (L.Ready and then S.Kind = Hull and then S.Length > 0
      and then Has_Vertex (L, S.First)
      and then S.Length <= L.Length-(S.First-L.First)
      and then F'Length <= Max_Incidences
      and then L.First_Facet = F'First and then L.Facet_Count = F'Length);

   function Count (L : Lookup; Vertex : Natural) return Natural is
     (L.Size (Vertex-L.First));

   function Item (L : Lookup; Vertex, Number : Natural) return Corner is
     (L.Data (L.Start (Vertex-L.First)+Number));

   procedure Reset (L : out Lookup)
     with Global => null, Post => L = Empty_Lookup, Inline
   is
   begin
      L := Empty_Lookup;
   end Reset;

   --  Append one vertex list.  The frame postcondition lets the outer
   --  builder preserve previous lists without a nested semantic invariant.
   procedure Append_Vertex (F : Facet_Array; Vertex : Natural;
                            L : in out Lookup; Used : in out Natural;
                            Result : out Status)
     with Global => null,
       Pre => F'Length <= Max_Incidences and then Vertex < L.Length
         and then Vertex <= Natural'Last-L.First and then Used <= Max_Incidences
         and then L.Length-1 <= Natural'Last-L.First,
       Post => Used in Used'Old .. Max_Incidences
         and then L.First = L.First'Old and then L.Length = L.Length'Old
         and then L.First_Facet = L.First_Facet'Old and then L.Facet_Count = L.Facet_Count'Old
         and then L.Ready = L.Ready'Old
         and then (for all V in Vertex_Id =>
           (if V /= Vertex then L.Start (V) = L.Start'Old (V) and L.Size (V) = L.Size'Old (V)))
         and then (for all E in 0 .. Used'Old-1 => L.Data (E) = L.Data'Old (E))
         and then L.Data (0 .. Used'Old-1) = L.Data'Old (0 .. Used'Old-1)
         and then (for all V in 0 .. L.Length-1 =>
           (if V /= Vertex and then L.Start'Old (V)+L.Size'Old (V) <= Used'Old then
             Vertex_Matches (L, F, V) = Vertex_Matches (L'Old, F, V)))
         and then (if Result = Success then Vertex_Matches (L, F, Vertex)
           and then L.Start (Vertex)+L.Size (Vertex) <= Used)
   is
      Begin_At : constant Natural := Used;
      Position : Natural;
   begin
      Result := Success;
      L.Start (Vertex) := Begin_At; L.Size (Vertex) := 0;
      for Face in F'Range loop
         pragma Loop_Invariant (Used in Begin_At .. Max_Incidences);
         pragma Loop_Invariant (L.Start (Vertex) = Begin_At and L.Size (Vertex) = Used-Begin_At);
         pragma Loop_Invariant (L.Size (Vertex) = Model_Count (F, L.First+Vertex, Face-1));
         pragma Loop_Invariant (for all E in 0 .. Begin_At-1 => L.Data (E) = L.Data'Loop_Entry (E));
         pragma Loop_Invariant (L.Data (0 .. Begin_At-1) = L.Data'Loop_Entry (0 .. Begin_At-1));
         pragma Loop_Invariant (for all E in Begin_At .. Used-1 =>
           L.Data (E).Face in F'First .. Face-1
           and then L.Data (E).Position < F (L.Data (E).Face).Length
           and then L.Data (E).Position = Find_Corner (F (L.Data (E).Face), L.First+Vertex)
           and then (if E > Begin_At then L.Data (E-1).Face < L.Data (E).Face));
         Position := Find_Corner (F (Face), L.First+Vertex);
         if Position < F (Face).Length then
            if Used = Max_Incidences then Result := Capacity_Limit; exit; end if;
            L.Data (Used) := (Face => Face, Position => Position); Used := Used+1;
            L.Size (Vertex) := Used-Begin_At;
         end if;
      end loop;
      declare
         Complete : constant Boolean := List_Matches (
           L.Data (L.Start (Vertex) .. L.Start (Vertex)+L.Size (Vertex)-1),
           F, L.First+Vertex) with Ghost;
      begin
         pragma Assert (if Result = Success then Complete);
      end;
   end Append_Vertex;

   procedure Build (First_Vertex, Vertex_Count : Natural; F : Facet_Array;
                    L : out Lookup; Result : out Status) is
      Used : Natural := 0;
   begin
      Reset (L); Result := Success;
      if Vertex_Count > Max_Indexed_Vertices or F'Length > Max_Incidences then Result := Capacity_Limit; return; end if;
      L.First := First_Vertex; L.Length := Vertex_Count;
      L.First_Facet := F'First; L.Facet_Count := F'Length;
      for Vertex in 0 .. Vertex_Count-1 loop
         Append_Vertex (F, Vertex, L, Used, Result);
         if Result /= Success then Reset (L); return; end if;
         pragma Loop_Invariant (Result = Success);
         pragma Loop_Invariant (Used <= Max_Incidences);
         pragma Loop_Invariant (L.First = First_Vertex and L.Length = Vertex_Count);
         pragma Loop_Invariant (L.First_Facet = F'First and L.Facet_Count = F'Length);
         pragma Loop_Invariant (for all V in 0 .. Vertex => Vertex_Matches (L, F, V));
         pragma Loop_Invariant (for all V in 0 .. Vertex => L.Start (V)+L.Size (V) <= Used);
      end loop;
      L.Ready := True;
   end Build;
end MJ.Contact_Incidence;

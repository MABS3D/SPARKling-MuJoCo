with MJ.Convex_Assets;
with MJ.Collision_Contacts;
with MJ.Heightfield_Contacts;

package body MJ.Collision_Scene with SPARK_Mode is
   function BVH_Node_Tests (S : Scene) return Natural is
     (MJ.Rigid_Detector.BVH_Node_Tests (S.Search));
   function BVH_Leaf_Tests (S : Scene) return Natural is
     (MJ.Rigid_Detector.BVH_Leaf_Tests (S.Search));
   function Initialized (S : Scene) return Boolean is (S.Ready);
   function Geom_Count (S : Scene) return Count is (S.N);
   function Type_Number (G : Geometry) return Natural is
     (if G.Terrain then 1
      elsif G.Solid.Kind = Primitive then
        (if G.Solid.Rigid.Kind = Plane then 0 else Shape_Kind'Pos (G.Solid.Rigid.Kind)+1)
      else 7);
   function Contact_Type (S : Scene; G : Geom_Id) return Natural is
     (Type_Number (S.Geometries (G)));
   function Selected_Count (S : Scene) return Natural is (S.Candidates.Pairs.Length);
   function Generation_Count (S : Scene) return Natural is (S.Calls);

   function Valid_Elevations (G : Geometry; E : Elevation_Array) return Boolean is
     (G.Elevation_Length > 0 and then G.Elevation_First in E'Range
      and then G.Elevation_Length-1 <= E'Last-G.Elevation_First
      and then MJ.Heightfield_Contacts.Valid
        (G.Field, E (G.Elevation_First .. G.Elevation_First+(G.Elevation_Length-1))));

   function Enclosed (G : Geometry; Proxy : Shape; V : Vertex_Array) return Boolean is
     (if G.Terrain or else G.Solid.Kind = Primitive then True
      elsif G.Solid.Kind = Prism then
        (for all P of G.Solid.Prism_Vertices =>
          (for all K in Axis => abs P (K)+G.Solid.Skin <= Proxy.Size (K)))
      else (for all I in G.Solid.First .. G.Solid.First+(G.Solid.Length-1) =>
        (for all K in Axis => abs V (I) (K)+G.Solid.Skin <= Proxy.Size (K))))
     with Pre => G.Terrain or else Valid_Object (G.Solid, V);

   function Assets_Admissible (S : Scene; V : Vertex_Array; E : Elevation_Array;
                               Graphs : Graph_Array) return Boolean is
     (S.Ready and then (for all I in 0 .. S.N-1 =>
       (if S.Geometries (I).Terrain then Valid_Elevations (S.Geometries (I), E)
        else Valid_Object (S.Geometries (I).Solid, V)
          and then MJ.Convex_Assets.Valid_Graph (S.Geometries (I).Solid, Graphs)
          and then Enclosed (S.Geometries (I), S.Proxies (I), V))));

   function Expanded (Extent, Point : Vec; Skin : Real) return Vec
     with Pre => (for all X of Extent => X in 1.0e-10 .. 1.0e30)
       and (for all X of Point => X in -1.0e22 .. 1.0e22) and Skin in 0.0 .. 1.0e10,
       Post => (for all K in Axis => Expanded'Result (K) in 1.0e-10 .. 1.0e30
         and then Expanded'Result (K) = Real'Max (Extent (K), abs Point (K)+Skin)
         and then Expanded'Result (K) >= Extent (K)
         and then Expanded'Result (K) >= abs Point (K)+Skin)
   is
   begin
      return [Real'Max (Extent (0), abs Point (0)+Skin),
              Real'Max (Extent (1), abs Point (1)+Skin),
              Real'Max (Extent (2), abs Point (2)+Skin)];
   end Expanded;

   --  Bounds are centered on the geometry origin. Off-center hull vertices
   --  are included directly; Center_Offset is a GJK seed, not a translation.
   procedure Make_Proxy (G : Geometry; V : Vertex_Array; Proxy : out Shape;
                         Result : out Status)
     with Pre => G.Terrain or else Valid_Object (G.Solid, V),
       Post => (if Result = Success then Valid_Shape (Proxy)
         and then Enclosed (G, Proxy, V))
   is
      Extent : Vec := [others => 1.0e-10];
   begin
      Proxy := G.Solid.Rigid; Result := Success;
      if G.Terrain then
         Proxy.Kind := Box;
         Proxy.Size := [G.Field.Half_X, G.Field.Half_Y, Real'Max (G.Field.Height, G.Field.Base)];
      elsif G.Solid.Kind /= Primitive then
         if G.Solid.Kind = Prism then
            for I in G.Solid.Prism_Vertices'Range loop
               Extent := Expanded (Extent, G.Solid.Prism_Vertices (I), G.Solid.Skin);
               pragma Loop_Invariant (for all X of Extent => X in 1.0e-10 .. 1.0e30);
               pragma Loop_Invariant (for all J in G.Solid.Prism_Vertices'First .. I =>
                 (for all K in Axis => abs G.Solid.Prism_Vertices (J) (K)+G.Solid.Skin <= Extent (K)));
            end loop;
         else
            for I in G.Solid.First .. G.Solid.First+(G.Solid.Length-1) loop
               Extent := Expanded (Extent, V (I), G.Solid.Skin);
               pragma Loop_Invariant (for all X of Extent => X in 1.0e-10 .. 1.0e30);
               pragma Loop_Invariant (for all J in G.Solid.First .. I =>
                 (for all K in Axis => abs V (J) (K)+G.Solid.Skin <= Extent (K)));
            end loop;
         end if;
         if (for some X of Extent => X > 1.0e10) then Result := Numeric_Limit; return; end if;
         Proxy.Kind := Box; Proxy.Size := Extent;
      end if;
   end Make_Proxy;

   procedure Initialize
     (S : in out Scene; Geoms : Geometry_Array; V : Vertex_Array;
      E : Elevation_Array; Graphs : Graph_Array; Explicit_Pairs : Declared_Array;
      Exclusions : Exclusion_Array; O : Options; Override : Override_Parameters;
      Result : out Status)
   is
      Pairs : Explicit_Array (0 .. Max_Pairs-1) with Relaxed_Initialization;
      P : Parameters;
   begin
      S.Ready := False; S.N := 0; S.Calls := 0; S.Candidates.Pairs.Length := 0;
      Result := Invalid_Input;
      if Geoms'Length > Max_Geoms or Explicit_Pairs'Length > Max_Pairs then Result := Capacity_Limit; return; end if;
      if Override.Margin not in 0.0 .. 1.0e10
        or (for some X of Override.Ref => X not in -1.0e10 .. 1.0e10)
        or (for some X of Override.Imp => X not in -1.0e10 .. 1.0e10)
        or (for some X of Override.Fri => X not in 0.0 .. 1.0e10) then return; end if;
      for I in 0 .. Geoms'Length-1 loop
         S.Geometries (I) := Geoms (Geoms'First+I);
         if not Valid (S.Geometries (I).Surface) then return; end if;
         if S.Geometries (I).Terrain then
            if not Valid_Elevations (S.Geometries (I), E) then return; end if;
         elsif not Valid_Object (S.Geometries (I).Solid, V)
           or else not MJ.Convex_Assets.Valid_Graph (S.Geometries (I).Solid, Graphs) then return;
         end if;
         Make_Proxy (S.Geometries (I), V, S.Proxies (I), Result);
         if Result /= Success then return; end if;
         Result := Invalid_Input;
      end loop;
      for I in 0 .. Explicit_Pairs'Length-1 loop
         P := Explicit_Pairs (Explicit_Pairs'First+I).Param;
         if (for some X of P.Fri => X not in 0.0 .. 1.0e10)
           or (for some X of P.Ref => X not in -1.0e10 .. 1.0e10)
           or (for some X of P.Ref_Friction => X not in -1.0e10 .. 1.0e10)
           or (for some X of P.Imp => X not in -1.0e10 .. 1.0e10)
           or P.Adhesion not in 0.0 .. 2.0e10 then return; end if;
         Configure (P, Explicit_Pairs (Explicit_Pairs'First+I).Margin,
                    Explicit_Pairs (Explicit_Pairs'First+I).Gap, Override);
         S.Explicit_Parameters (I) := P;
         Pairs (I) := (Explicit_Pairs (Explicit_Pairs'First+I).Geoms, P.Detection_Margin);
         pragma Loop_Invariant (for all J in 0 .. I => Pairs (J)'Initialized);
      end loop;
      MJ.Rigid_Detector.Initialize (S.Search, S.Proxies (0 .. Geoms'Length-1),
        Pairs (0 .. Explicit_Pairs'Length-1), Exclusions, O, Result,
        (if Override.Enabled then Override.Margin else -1.0));
      if Result = Success then
         S.N := Geoms'Length; S.Config := O; S.Override := Override; S.Ready := True;
      end if;
   end Initialize;

   procedure Generate
     (S : in out Scene; Poses : Pose_Array; V : Vertex_Array; F : Facet_Array;
      E : Elevation_Array; Graphs : Graph_Array; Contacts : in out Full_Array;
      Length : out Natural; Result : out Status;
      Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup)
   is
      Full : Full_Manifold;
      Raw : Manifold;
      A, B : Geom_Id;
      Explicit_Index : Natural;
      P : Parameters;
      Geoms : Pair;
   begin
      Length := 0; S.Calls := 0;
      --  Find_Candidates admits/caches every frame needed by generators,
      --  including spheres. Do not repeat that scene scan here.
      MJ.Rigid_Detector.Find_Candidates (S.Search, Poses, S.Candidates, Result);
      if Result /= Success then return; end if;
      for I in 0 .. S.Candidates.Pairs.Length-1 loop
         Geoms := S.Candidates.Pairs.Items (I); A := Geoms.First; B := Geoms.Second;
         if Type_Number (S.Geometries (A)) > Type_Number (S.Geometries (B)) then
            declare Temp : constant Geom_Id := A; begin A := B; B := Temp; end;
            Geoms := (A, B);
         end if;
         --  These dispatch-table entries are empty in MuJoCo 3.14 as well.
         if (S.Geometries (A).Terrain and S.Geometries (B).Terrain)
           or else (S.Geometries (A).Terrain and then S.Geometries (B).Solid.Kind = Primitive
                    and then S.Geometries (B).Solid.Rigid.Kind = Plane)
           or else (S.Geometries (B).Terrain and then S.Geometries (A).Solid.Kind = Primitive
                    and then S.Geometries (A).Solid.Rigid.Kind = Plane) then
            null;
         else
            Explicit_Index := S.Candidates.Metadata (I).Explicit_Index;
            if Explicit_Index = 0 then
               P := Combine (S.Geometries (A).Surface, S.Geometries (B).Surface);
               Configure (P, S.Proxies (A).Margin+S.Proxies (B).Margin,
                          S.Proxies (A).Gap+S.Proxies (B).Gap, S.Override);
            else P := S.Explicit_Parameters (Explicit_Index-1);
            end if;
            S.Calls := S.Calls+1;
            if S.Geometries (A).Terrain or S.Geometries (B).Terrain then
               declare
                  T : constant Geom_Id := (if S.Geometries (A).Terrain then A else B);
                  C : constant Geom_Id := (if T = A then B else A);
                  G : constant Geometry := S.Geometries (T);
               begin
                  MJ.Heightfield_Contacts.Generate (G.Field,
                    E (G.Elevation_First .. G.Elevation_First+(G.Elevation_Length-1)),
                    Poses (Poses'First+T), S.Geometries (C).Solid, Poses (Poses'First+C),
                    V, P.Detection_Margin, S.Config, S.Convex, Raw, Result, Graphs);
                  if Result = Success then
                     if T = B then Reverse_Manifold (Raw); end if;
                     Finalize (Raw, P, Geoms, Full, Result);
                  end if;
               end;
            else
               MJ.Collision_Contacts.Generate (S.Geometries (A).Solid, S.Geometries (B).Solid,
                 Poses (Poses'First+A), Poses (Poses'First+B), V, F, Graphs, P, Geoms,
                 S.Config, S.Convex, Full, Result, Incidence);
            end if;
            if Result /= Success then Length := 0; return; end if;
            if Full.Length > Contacts'Length-Length then Length := 0; Result := Capacity_Limit; return; end if;
            for J in 0 .. Full.Length-1 loop
               Contacts (Contacts'First+Length) := Full.Items (J); Length := Length+1;
            end loop;
         end if;
      end loop;
   end Generate;
end MJ.Collision_Scene;

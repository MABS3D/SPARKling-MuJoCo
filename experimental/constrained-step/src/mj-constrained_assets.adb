with Ada.Unchecked_Deallocation;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry;
with MJ.Convex_Assets;
with MJ.Constrained_Asset_Kernels;

package body MJ.Constrained_Assets with SPARK_Mode is
   package CG renames MJ.Contact_Geometry;
   package RG renames MJ.Rigid_Geometry;
   package AK renames MJ.Constrained_Asset_Kernels;
   use type RG.Status;
   procedure Free_V is new Ada.Unchecked_Deallocation (CG.Vertex_Array, Vertex_Access);
   procedure Free_F is new Ada.Unchecked_Deallocation (CG.Facet_Array, Facet_Access);
   procedure Free_G is new Ada.Unchecked_Deallocation (CG.Graph_Array, Graph_Access);
   procedure Free_H is new Ada.Unchecked_Deallocation
     (MJ.Heightfield_Contacts.Elevation_Array, Elevation_Access);

   procedure Release (A : in out Store) is
   begin
      Free_V (A.Vertices); Free_F (A.Facets);
      Free_G (A.Graphs); Free_H (A.Elevations);
      A.Incidence := MJ.Contact_Incidence.Empty_Lookup;
   end Release;

   procedure Load (M : MJ.Models.Model; A : in out Store; Result : out Status) is
      S : RG.Status;
   begin
      Release (A);
      Result := Capacity_Exceeded;
      if M.S.Nmeshvert > Max_Vertices or else M.S.Nmeshpoly > Max_Facets
        or else M.S.Nmeshgraph > Max_Graph or else M.S.Nhfielddata > Max_Elevations
      then return; end if;
      A.Vertices := new CG.Vertex_Array'(0 .. M.S.Nmeshvert - 1 => RG.Zero);
      A.Facets := new CG.Facet_Array'(0 .. M.S.Nmeshpoly - 1 => <>);
      A.Graphs := new CG.Graph_Array'(0 .. M.S.Nmeshgraph - 1 => 0);
      A.Elevations := new MJ.Heightfield_Contacts.Elevation_Array'(0 .. M.S.Nhfielddata - 1 => 0.0);
      Result := Invalid_Model;
      for I in A.Vertices'Range loop
         for K in RG.Axis loop
            if M.Meshes.Mesh_Vert (3 * I + K) not in -1.0e10 .. 1.0e10 then
               Release (A); return;
            end if;
         end loop;
      end loop;
      if M.S.Nmeshvert > 0 then
         AK.Copy_Vertices (M.Meshes.Mesh_Vert.all, A.Vertices.all);
      end if;
      for I in A.Graphs'Range loop A.Graphs (I) := M.Meshes.Mesh_Graph (I); end loop;
      for I in A.Elevations'Range loop
         if M.Hfields.Hfield_Data (I) not in 0.0 .. 1.0 then Release (A); return; end if;
         A.Elevations (I) := AK.Promote (M.Hfields.Hfield_Data (I));
      end loop;
      for Mesh in 0 .. M.S.Nmesh - 1 loop
         for P in M.Meshes.Mesh_Polyadr (Mesh) ..
           M.Meshes.Mesh_Polyadr (Mesh) + M.Meshes.Mesh_Polynum (Mesh) - 1 loop
            declare
               N : constant Integer := M.Meshes.Mesh_Polyvertnum (P);
               First : constant Integer := M.Meshes.Mesh_Polyvertadr (P);
               V_First : constant Integer := M.Meshes.Mesh_Vertadr (Mesh);
               V_Count : constant Integer := M.Meshes.Mesh_Vertnum (Mesh);
            begin
               if N not in 3 .. CG.Max_Facet_Vertices then
                  Result := Capacity_Exceeded; Release (A); return;
               end if;
               for K in RG.Axis loop
                  if M.Meshes.Mesh_Polynormal (3 * P + K) not in -1.0e10 .. 1.0e10 then
                     Release (A); return;
                  end if;
                  A.Facets (P).Normal (K) := M.Meshes.Mesh_Polynormal (3 * P + K);
               end loop;
               A.Facets (P).Length := N;
               for K in 0 .. N - 1 loop
                  declare
                     V : constant Integer := M.Meshes.Mesh_Polyvert (First + K);
                  begin
                     if V not in 0 .. V_Count - 1 then Release (A); return; end if;
                     A.Facets (P).Indices (K) := AK.Vertex_Index (V_First, V, V_Count);
                  end;
               end loop;
            end;
         end loop;
      end loop;
      --  The reviewed incidence builder retains its scanning fallback when
      --  the optional index exceeds its capacity; geometry is never omitted.
      MJ.Contact_Incidence.Build (0, A.Vertices'Length, A.Facets.all, A.Incidence, S);
      if S not in RG.Success | RG.Capacity_Limit then Release (A); return; end if;
      Result := Success;
   exception
      when Constraint_Error => Release (A); Result := Invalid_Model;
      when Storage_Error => Release (A); Result := Capacity_Exceeded;
   end Load;

   procedure Configure (M : MJ.Models.Model; G : Natural; A : Store;
                        Shape : in out MJ.Collision_Scene.Geometry;
                        Result : out Status) is
      Kind : constant Integer := M.Geoms.Geom_Type (G);
      Id : constant Integer := M.Geoms.Geom_Dataid (G);
   begin
      Result := Unsupported_Feature;
      if Kind = 7 then
         if Id not in 0 .. M.S.Nmesh - 1 then Result := Invalid_Model; return; end if;
         Shape.Solid.Kind := CG.Hull;
         Shape.Solid.First := M.Meshes.Mesh_Vertadr (Id);
         Shape.Solid.Length := M.Meshes.Mesh_Vertnum (Id);
         Shape.Solid.First_Facet := M.Meshes.Mesh_Polyadr (Id);
         Shape.Solid.Facet_Count := M.Meshes.Mesh_Polynum (Id);
         --  Exactly the C hill-climb threshold and its compiled local/global
         --  graph. Keep it unmodified: meshes may share this immutable block.
         if M.Meshes.Mesh_Graphadr (Id) >= 0 and then Shape.Solid.Length >= 10 then
            declare
               First : constant Natural := M.Meshes.Mesh_Graphadr (Id);
               Nv : constant Integer := A.Graphs (First);
               Nf : constant Integer := A.Graphs (First + 1);
            begin
               if Nv <= 0 or else Nf < 0 then Result := Invalid_Model; return; end if;
               Shape.Solid.First_Graph := First;
               Shape.Solid.Graph_Length := AK.Graph_Span (Nv, Nf);
               for K in Shape.Solid.Extrema'Range loop
                  if M.Meshes.Mesh_Extrema (27 * Id + K) not in 0 .. Nv - 1 then
                     Result := Invalid_Model; return;
                  end if;
                  Shape.Solid.Extrema (K) := M.Meshes.Mesh_Extrema (27 * Id + K);
               end loop;
            end;
         end if;
         if not CG.Valid_Object (Shape.Solid, A.Vertices.all)
           or else not MJ.Convex_Assets.Valid_Graph (Shape.Solid, A.Graphs.all)
         then Result := Invalid_Model; return; end if;
      elsif Kind = 1 then
         if Id not in 0 .. M.S.Nhfield - 1 then Result := Invalid_Model; return; end if;
         if M.Hfields.Hfield_Nrow (Id) not in 2 .. 65_536
           or else M.Hfields.Hfield_Ncol (Id) not in 2 .. 65_536
           or else (for some K in 0 .. 3 => M.Hfields.Hfield_Size (4 * Id + K) not in 1.0e-10 .. 1.0e10)
         then return; end if;
         Shape.Terrain := True;
         Shape.Field := (M.Hfields.Hfield_Nrow (Id), M.Hfields.Hfield_Ncol (Id),
           M.Hfields.Hfield_Size (4 * Id), M.Hfields.Hfield_Size (4 * Id + 1),
           M.Hfields.Hfield_Size (4 * Id + 2), M.Hfields.Hfield_Size (4 * Id + 3));
         Shape.Elevation_First := M.Hfields.Hfield_Adr (Id);
         if Shape.Field.Rows > Max_Elevations / Shape.Field.Columns then
            Result := Capacity_Exceeded; return;
         end if;
         Shape.Elevation_Length := Shape.Field.Rows * Shape.Field.Columns;
      elsif Kind not in 0 | 2 .. 6 then return;
      end if;
      Result := Success;
   exception
      when Constraint_Error => Result := Invalid_Model;
   end Configure;
end MJ.Constrained_Assets;

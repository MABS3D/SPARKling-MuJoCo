with Ada.Unchecked_Deallocation;
with Interfaces;
with MJ.Models.Validity;
with MJ.SDF_Kernels;
with MJ.Collision_Contacts;
package body MJ.SDF_Scene with SPARK_Mode is
   use MJ.Contact_Geometry;
   use MJ.Contact_Parameters;
   use MJ.Full_Contacts;
   package SF renames MJ.SDF_Fields;
   package SDF renames MJ.Admitted_SDF;
   procedure Free_Tree is new Ada.Unchecked_Deallocation (SF.Octree, Octree_Access);
   procedure Free_Vertices is new Ada.Unchecked_Deallocation (Vertex_Array, Vertex_Access);
   procedure Free_Facets is new Ada.Unchecked_Deallocation (Facet_Array, Facet_Access);
   procedure Free_Faces is new Ada.Unchecked_Deallocation (SDF.Triangle_Array, Triangle_Access);
   procedure Free_BVH is new Ada.Unchecked_Deallocation (MJ.BVH.Tree, BVH_Access);
   function Initialized (S : Scene) return Boolean is (S.Ready);
   function Disabled (Flags, Flag : Integer) return Boolean is
     (Flags >= 0 and then (Flags / Flag) mod 2 = 1);
   procedure Release (S : in out Scene) is
   begin
      S.Ready := False; S.N := 0;
      Free_Tree (S.Tree); Free_Vertices (S.Vertices); Free_Facets (S.Facets);
      for G in S.Faces'Range loop Free_Faces (S.Faces (G)); Free_BVH (S.BVHs (G)); end loop;
   end Release;
   procedure Load (M : MJ.Models.Model; S : in out Scene; Result : out Status) is
      Proxies : Shape_Array (0 .. Max_G - 1);
      F : SF.Field;
      Mesh, First, Length : Integer;
      H : Real;
   begin
      Release (S); Result := Invalid_Input;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      if M.S.Ngeom > Max_G or M.S.Noct > Max_Octants
        or M.S.Nmeshvert > Max_Vertices or M.S.Nmeshpoly > Max_Facets
      then Result := Capacity_Limit; return; end if;
      if M.Opt.Sdf_Initpoints not in 0 .. 10000
        or M.Opt.Sdf_Iterations not in 0 .. 1000 then return; end if;
      S.N := M.S.Ngeom;
      S.Starts := M.Opt.Sdf_Initpoints; S.Iterations := M.Opt.Sdf_Iterations;
      S.Tree := new SF.Octree (0 .. Integer (M.S.Noct) - 1);
      S.Vertices := new Vertex_Array'(0 .. Integer (M.S.Nmeshvert) - 1 => Zero);
      S.Facets := new Facet_Array'(0 .. Integer (M.S.Nmeshpoly) - 1 => <>);
      for V in S.Vertices'Range loop
         for K in Axis loop
            S.Vertices (V)(K) := Real (M.Meshes.Mesh_Vert (3 * V + K));
            if S.Vertices (V)(K) not in -1.0e10 .. 1.0e10 then Release (S); return; end if;
         end loop;
      end loop;
      -- Plane/SDF uses the compiled convex polygons, just like plane/mesh.
      -- Keeping only vertices produces one support contact instead of a face.
      for Mesh_Id in 0 .. M.S.Nmesh - 1 loop
         for P in M.Meshes.Mesh_Polyadr (Mesh_Id) ..
           M.Meshes.Mesh_Polyadr (Mesh_Id) + M.Meshes.Mesh_Polynum (Mesh_Id) - 1 loop
            declare
               N : constant Integer := M.Meshes.Mesh_Polyvertnum (P);
               Base : constant Integer := M.Meshes.Mesh_Polyvertadr (P);
               V_Base : constant Integer := M.Meshes.Mesh_Vertadr (Mesh_Id);
               V_Count : constant Integer := M.Meshes.Mesh_Vertnum (Mesh_Id);
            begin
               if N not in 3 .. Max_Facet_Vertices then
                  Release (S); Result := Capacity_Limit; return;
               end if;
               S.Facets (P).Length := N;
               for K in Axis loop
                  if M.Meshes.Mesh_Polynormal (3 * P + K) not in -1.0e10 .. 1.0e10 then
                     Release (S); return;
                  end if;
                  S.Facets (P).Normal (K) := M.Meshes.Mesh_Polynormal (3 * P + K);
               end loop;
               for K in 0 .. N - 1 loop
                  declare V : constant Integer := M.Meshes.Mesh_Polyvert (Base + K); begin
                     if V not in 0 .. V_Count - 1 then Release (S); return; end if;
                     S.Facets (P).Indices (K) := V_Base + V;
                  end;
               end loop;
            end;
         end loop;
      end loop;
      for I in S.Tree'Range loop
         for K in Axis loop
            S.Tree (I).Bounds.Center (K) := M.Bvh.Oct_Aabb (6 * I + K);
            S.Tree (I).Bounds.Half (K) := M.Bvh.Oct_Aabb (6 * I + 3 + K);
         end loop;
         for K in 0 .. 7 loop
            S.Tree (I).Child (K) := M.Bvh.Oct_Child (8 * I + K);
            S.Tree (I).Coeff (K) := M.Bvh.Oct_Coeff (8 * I + K);
         end loop;
      end loop;
      for G in 0 .. S.N - 1 loop
         declare
            B : constant Natural := M.Geoms.Geom_Bodyid (G);
            W : constant Natural := M.Bodies.Body_Weldid (B);
            Kind : constant Integer := M.Geoms.Geom_Type (G);
         begin
            if Kind not in 0 | 2 .. 8 then Release (S); return; end if;
            S.Is_SDF (G) := Kind = 8;
            S.Is_Mesh (G) := Kind = 7;
            Proxies (G) := (Kind => (if Kind >= 7 then Box else Shape_Kind'Val ((if Kind = 0 then 0 else Kind - 1))),
              Size => [for K in Axis => M.Geoms.Geom_Size (3 * G + K)],
              Body_Id => B, Weld => W,
              Weld_Parent => M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (W)),
              Dynamic => W /= 0,
              Contype => Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Contype (G)),
              Conaffinity => Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Conaffinity (G)),
              Margin => M.Geoms.Geom_Margin (G), Gap => M.Geoms.Geom_Gap (G));
            F := (Kind => (if Kind = 8 then SF.Sampled else SF.Analytic),
              Geometry => Proxies (G), others => <>);
            for K in Axis loop
               F.Bounds.Center (K) := M.Geoms.Geom_Aabb (6 * G + K);
               F.Bounds.Half (K) := M.Geoms.Geom_Aabb (6 * G + 3 + K);
               -- Planes use C's conservative 1e10 extent and bypass SDF
               -- descent/proxy sizing in Generate. Preserve those bounds.
               if (Kind = 0 and then
                   (F.Bounds.Center (K) not in -1.0e10 .. 1.0e10
                    or F.Bounds.Half (K) not in 0.0 .. 1.0e10))
                 or else (Kind /= 0 and then
                   (F.Bounds.Center (K) not in -1.0e9 .. 1.0e9
                    or F.Bounds.Half (K) not in 0.0 .. 1.0e9))
               then Release (S); return; end if;
               if Kind >= 7 then
                  H := MJ.SDF_Kernels.Proxy_Extent (F.Bounds.Center (K), F.Bounds.Half (K));
                  Proxies (G).Size (K) := H;
               end if;
            end loop;
            S.Solid (G).Rigid := Proxies (G);
            if Kind = 7 then
               Mesh := M.Geoms.Geom_Dataid (G);
               S.Solid (G).Kind := Hull;
               S.Solid (G).First := M.Meshes.Mesh_Vertadr (Mesh);
               S.Solid (G).Length := M.Meshes.Mesh_Vertnum (Mesh);
               S.Solid (G).First_Facet := M.Meshes.Mesh_Polyadr (Mesh);
               S.Solid (G).Facet_Count := M.Meshes.Mesh_Polynum (Mesh);
               if not Valid_Object (S.Solid (G), S.Vertices.all) then Release (S); return; end if;
               First := M.Meshes.Mesh_Faceadr (Mesh); Length := M.Meshes.Mesh_Facenum (Mesh);
               if Length > MJ.BVH.Max_Leaves or M.Meshes.Mesh_Bvhnum (Mesh) > MJ.BVH.Max_Nodes then
                  Release (S); Result := Capacity_Limit; return;
               end if;
               S.Faces (G) := new SDF.Triangle_Array (0 .. Length - 1);
               for I in S.Faces (G)'Range loop
                  S.Faces (G)(I).Id := I;
                  for K in 0 .. 2 loop
                     S.Faces (G)(I).Corners (K) := S.Vertices
                       (S.Solid (G).First + M.Meshes.Mesh_Face (3 * (First + I) + K));
                  end loop;
               end loop;
               S.BVHs (G) := new MJ.BVH.Tree;
               S.BVHs (G).Length := M.Meshes.Mesh_Bvhnum (Mesh);
               First := M.Meshes.Mesh_Bvhadr (Mesh);
               for I in 0 .. S.BVHs (G).Length - 1 loop
                  for K in Axis loop
                     S.BVHs (G).Nodes (I).Bounds.Center (K) := M.Bvh.Bvh_Aabb (6 * (First + I) + K);
                     S.BVHs (G).Nodes (I).Bounds.Half (K) := M.Bvh.Bvh_Aabb (6 * (First + I) + 3 + K);
                  end loop;
                  S.BVHs (G).Nodes (I).Left := M.Bvh.Bvh_Child (2 * (First + I));
                  S.BVHs (G).Nodes (I).Right := M.Bvh.Bvh_Child (2 * (First + I) + 1);
                  S.BVHs (G).Nodes (I).Item := M.Bvh.Bvh_Nodeid (First + I);
               end loop;
               if not MJ.BVH.Valid (S.BVHs (G).all) or else
                 not SDF.Fits (S.Faces (G).all, S.BVHs (G).all) then Release (S); return; end if;
            end if;
            if Kind = 8 then
               Mesh := M.Geoms.Geom_Dataid (G);
               First := M.Meshes.Mesh_Octadr (Mesh); Length := M.Meshes.Mesh_Octnum (Mesh);
               if First < 0 or else Length <= 0 or else
                 not MJ.SDF_Kernels.Bounded_Index (First, Length, M.S.Noct) then Release (S); return; end if;
               F.First := First; F.Length := Length;
               if not SF.Valid (F, S.Tree.all) then Release (S); return; end if;
               -- Plane/SDF follows C's plane/convex mesh dispatch, not descent.
               S.Solid (G).Kind := Hull;
               S.Solid (G).First := M.Meshes.Mesh_Vertadr (Mesh);
               S.Solid (G).Length := M.Meshes.Mesh_Vertnum (Mesh);
               S.Solid (G).First_Facet := M.Meshes.Mesh_Polyadr (Mesh);
               S.Solid (G).Facet_Count := M.Meshes.Mesh_Polynum (Mesh);
               if not Valid_Object (S.Solid (G), S.Vertices.all) then Release (S); return; end if;
            elsif not SF.Valid (F, S.Tree.all) then Release (S); return;
            end if;
            S.Field (G) := F;
            S.Surface (G) := (Priority => M.Geoms.Geom_Priority (G),
              Dim => M.Geoms.Geom_Condim (G), Mix => M.Geoms.Geom_Solmix (G),
              Ref => [for K in 0 .. 1 => M.Geoms.Geom_Solref (2 * G + K)],
              Imp => [for K in 0 .. 4 => M.Geoms.Geom_Solimp (5 * G + K)],
              Fri => [for K in 0 .. 2 => M.Geoms.Geom_Friction (3 * G + K)], Adhesion => 0.0);
            if not Valid (S.Surface (G)) then Release (S); return; end if;
         end;
      end loop;
      S.Options := (Filter_Parent => not Disabled (M.Opt.Disableflags, 1024),
        Enabled => not Disabled (M.Opt.Disableflags, 1) and then not Disabled (M.Opt.Disableflags, 16),
        Sleep_Filter => False, Tolerance => M.Opt.Ccd_Tolerance,
        Iterations => M.Opt.Ccd_Iterations);
      MJ.Rigid_Detector.Initialize (S.Search, Proxies (0 .. S.N - 1),
        Explicit_Array'(1 .. 0 => (Geoms => (0, 0), Margin => 0.0)),
        Exclusion_Array'(1 .. 0 => <>), S.Options, Result);
      if Result /= Success then Release (S); return; end if;
      S.Ready := True;
   exception
      when Constraint_Error => Release (S); Result := Invalid_Input;
      when Storage_Error => Release (S); Result := Capacity_Limit;
   end Load;
   procedure Generate (S : in out Scene; Poses : Pose_Array;
                       Contacts : in out Full_Array;
                       Length : out Natural; Result : out Status) is
      Raw : Manifold;
      Full : Full_Manifold;
      P : Parameters;
      A, B, First, Second : Geom_Id;
      Geoms : Pair;
      IDs : SDF.Id_Array (0 .. Max_Manifold - 1);
   begin
      Length := 0;
      MJ.Rigid_Detector.Find_Candidates (S.Search, Poses, S.Candidates, Result);
      if Result /= Success then return; end if;
      for I in 0 .. S.Candidates.Pairs.Length - 1 loop
         Geoms := S.Candidates.Pairs.Items (I); A := Geoms.First; B := Geoms.Second;
         P := Combine (S.Surface (A), S.Surface (B));
         Configure (P, S.Solid (A).Rigid.Margin + S.Solid (B).Rigid.Margin,
           S.Solid (A).Rigid.Gap + S.Solid (B).Rigid.Gap, (others => <>));
         if (S.Is_SDF (A) or S.Is_SDF (B)) and then
           S.Field (A).Geometry.Kind /= Plane and then S.Field (B).Geometry.Kind /= Plane then
            -- C orders the SDF second, independently of the geometry IDs.
            First := (if S.Is_SDF (B) then A else B);
            Second := (if First = A then B else A);
            if S.Is_Mesh (First) then
               SDF.Triangles (S.Field (Second), S.Tree.all, S.Faces (First).all,
                 S.BVHs (First).all, Poses (Poses'First + First), Poses (Poses'First + Second),
                 SDF.Tree_Mesh, (S.Starts, S.Iterations), Raw, IDs, Result);
            else
               SDF.Generate_Admitted (S.Field (First), S.Field (Second), S.Tree.all,
                 Poses (Poses'First + First), Poses (Poses'First + Second),
                 (S.Starts, S.Iterations), Raw, Result);
            end if;
            if Result = Success then
               -- Preserve C's type-ordered pair through frame construction.
               -- Reversing the normal and rebuilding tangents changes the
               -- pyramid row order, which changes finite-iteration PGS.
               Finalize (Raw, P, (First => First, Second => Second), Full, Result);
            end if;
         else
            MJ.Collision_Contacts.Generate (S.Solid (A), S.Solid (B),
              Poses (Poses'First + A), Poses (Poses'First + B),
              S.Vertices.all, S.Facets.all, Empty_Graph, P, Geoms,
              S.Options, S.Convex, Full, Result);
         end if;
         if Result /= Success then Length := 0; return; end if;
         if Full.Length > Contacts'Length - Length then
            Length := 0; Result := Capacity_Limit; return;
         end if;
         for K in 0 .. Full.Length - 1 loop
            Contacts (Contacts'First + Length) := Full.Items (K); Length := Length + 1;
         end loop;
      end loop;
   exception
      when Constraint_Error => Length := 0; Result := Numeric_Limit;
   end Generate;
end MJ.SDF_Scene;

with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.SDF_Scene;
with MJ.Rigid_Geometry;
procedure SDF_Load_Checks (M : in out MJ.Models.Model) is
   package SS renames MJ.SDF_Scene;
   use type MJ.Rigid_Geometry.Status;
   S : SS.Scene;
   Result : MJ.Rigid_Geometry.Status;
   G, Mesh, Root : Integer := -1;
   Checks : Natural := 0;
   type Int_Test is (Layout, Geom_Kind, Geom_Body, Geom_Data, Parent, Weld,
                    Polygon, Octree_Address, Octree_Child);
   type Real_Test is (Margin, CCD_Tolerance, Octree_Coefficient, Octree_Half,
                     Friction);
   function Get (T : Int_Test) return Integer is
     (case T is
        when Layout => M.S.Ngeom,
        when Geom_Kind => M.Geoms.Geom_Type (G),
        when Geom_Body => M.Geoms.Geom_Bodyid (G),
        when Geom_Data => M.Geoms.Geom_Dataid (G),
        when Parent => M.Bodies.Body_Parentid (1),
        when Weld => M.Bodies.Body_Weldid (1),
        when Polygon => M.Meshes.Mesh_Polyadr (Mesh),
        when Octree_Address => M.Meshes.Mesh_Octadr (Mesh),
        when Octree_Child => M.Bvh.Oct_Child (8 * Root));
   procedure Set (T : Int_Test; V : Integer) is
   begin
      case T is
         when Layout => M.S.Ngeom := V;
         when Geom_Kind => M.Geoms.Geom_Type (G) := V;
         when Geom_Body => M.Geoms.Geom_Bodyid (G) := V;
         when Geom_Data => M.Geoms.Geom_Dataid (G) := V;
         when Parent => M.Bodies.Body_Parentid (1) := V;
         when Weld => M.Bodies.Body_Weldid (1) := V;
         when Polygon => M.Meshes.Mesh_Polyadr (Mesh) := V;
         when Octree_Address => M.Meshes.Mesh_Octadr (Mesh) := V;
         when Octree_Child => M.Bvh.Oct_Child (8 * Root) := V;
      end case;
   end Set;
   function Bad (T : Int_Test) return Integer is
     (case T is
        when Layout => M.S.Ngeom + 1,
        when Geom_Kind => 9,
        when Geom_Body => M.S.Nbody,
        when Geom_Data => M.S.Nmesh,
        when Parent => 1,
        when Weld => M.S.Nbody,
        when Polygon => M.S.Nmeshpoly + 1,
        when Octree_Address => M.S.Noct,
        when Octree_Child => Root);
   function Get (T : Real_Test) return Real is
     (case T is
        when Margin => M.Geoms.Geom_Margin (G),
        when CCD_Tolerance => M.Opt.Ccd_Tolerance,
        when Octree_Coefficient => M.Bvh.Oct_Coeff (8 * Root),
        when Octree_Half => M.Bvh.Oct_Aabb (6 * Root + 3),
        when Friction => M.Geoms.Geom_Friction (3 * G));
   procedure Set (T : Real_Test; V : Real) is
   begin
      case T is
         when Margin => M.Geoms.Geom_Margin (G) := V;
         when CCD_Tolerance => M.Opt.Ccd_Tolerance := V;
         when Octree_Coefficient => M.Bvh.Oct_Coeff (8 * Root) := V;
         when Octree_Half => M.Bvh.Oct_Aabb (6 * Root + 3) := V;
         when Friction => M.Geoms.Geom_Friction (3 * G) := V;
      end case;
   end Set;
   procedure Expect_Accept is
   begin
      SS.Load (M, S, Result);
      if Result /= MJ.Rigid_Geometry.Success or else not SS.Initialized (S) then
         raise Program_Error with "valid geometry rejected: " & Result'Image;
      end if;
      Checks := Checks + 1;
   end Expect_Accept;
   procedure Reject (Name : String) is
   begin
      SS.Load (M, S, Result);
      if Result = MJ.Rigid_Geometry.Success or else SS.Initialized (S) then
         raise Program_Error with "invalid geometry admitted: " & Name;
      end if;
      Checks := Checks + 1;
   end Reject;
begin
   for I in 0 .. M.S.Ngeom - 1 loop
      if M.Geoms.Geom_Type (I) = 8 then G := I; exit; end if;
   end loop;
   if G < 0 or M.S.Nflex = 0 or M.S.Nbody < 2 then
      raise Program_Error with "load checks require a flex/SDF model";
   end if;
   Mesh := M.Geoms.Geom_Dataid (G); Root := M.Meshes.Mesh_Octadr (Mesh);
   Expect_Accept;
   for T in Int_Test loop
      declare Saved : constant Integer := Get (T); begin
         Set (T, Bad (T)); Reject (T'Image); Set (T, Saved);
      exception when others => Set (T, Saved); raise;
      end;
      Expect_Accept;
   end loop;
   for T in Real_Test loop
      declare Saved : constant Real := Get (T); begin
         Set (T, (if T = Octree_Coefficient then 1.0e50 else -1.0));
         Reject (T'Image); Set (T, Saved);
      exception when others => Set (T, Saved); raise;
      end;
      Expect_Accept;
   end loop;
   --  These fields belong to other consumers, not this geometry owner.
   declare
      Normal_Adr : constant Integer := M.Meshes.Mesh_Normaladr (Mesh);
      Graph_Adr : constant Integer := M.Meshes.Mesh_Graphadr (Mesh);
      Depth : constant Integer := M.Bvh.Oct_Depth (Root);
   begin
      M.Meshes.Mesh_Normaladr (Mesh) := M.S.Nmeshnormal + 1;
      M.Meshes.Mesh_Graphadr (Mesh) := M.S.Nmeshgraph + 1;
      M.Bvh.Oct_Depth (Root) := -1;
      Expect_Accept;
      M.Meshes.Mesh_Normaladr (Mesh) := Normal_Adr;
      M.Meshes.Mesh_Graphadr (Mesh) := Graph_Adr;
      M.Bvh.Oct_Depth (Root) := Depth;
   exception
      when others =>
         M.Meshes.Mesh_Normaladr (Mesh) := Normal_Adr;
         M.Meshes.Mesh_Graphadr (Mesh) := Graph_Adr;
         M.Bvh.Oct_Depth (Root) := Depth;
         raise;
   end;
   --  Mesh triangles and static BVH ranges must be checked when selected.
   declare
      Kind : constant Integer := M.Geoms.Geom_Type (G);
      Face_Adr : constant Integer := M.Meshes.Mesh_Faceadr (Mesh);
      Vertex : constant Integer := M.Meshes.Mesh_Face (3 * Face_Adr);
      BVH_Adr : constant Integer := M.Meshes.Mesh_Bvhadr (Mesh);
      Child : constant Integer := M.Bvh.Bvh_Child (2 * BVH_Adr);
   begin
      M.Geoms.Geom_Type (G) := 7; Expect_Accept;
      M.Meshes.Mesh_Faceadr (Mesh) := M.S.Nmeshface;
      Reject ("mesh face range"); M.Meshes.Mesh_Faceadr (Mesh) := Face_Adr; Expect_Accept;
      M.Meshes.Mesh_Face (3 * Face_Adr) := M.Meshes.Mesh_Vertnum (Mesh);
      Reject ("mesh face vertex"); M.Meshes.Mesh_Face (3 * Face_Adr) := Vertex; Expect_Accept;
      M.Meshes.Mesh_Bvhadr (Mesh) := M.S.Nbvhstatic;
      Reject ("mesh static BVH range"); M.Meshes.Mesh_Bvhadr (Mesh) := BVH_Adr; Expect_Accept;
      M.Bvh.Bvh_Child (2 * BVH_Adr) := 0;
      Reject ("mesh BVH cycle"); M.Bvh.Bvh_Child (2 * BVH_Adr) := Child; Expect_Accept;
      M.Geoms.Geom_Type (G) := Kind; Expect_Accept;
   exception
      when others =>
         M.Geoms.Geom_Type (G) := Kind;
         M.Meshes.Mesh_Faceadr (Mesh) := Face_Adr;
         M.Meshes.Mesh_Face (3 * Face_Adr) := Vertex;
         M.Meshes.Mesh_Bvhadr (Mesh) := BVH_Adr;
         M.Bvh.Bvh_Child (2 * BVH_Adr) := Child;
         raise;
   end;
   SS.Release (S); SS.Release (S);
   if SS.Initialized (S) then raise Program_Error with "double release"; end if;
   Checks := Checks + 1;
   Ada.Text_IO.Put_Line ("load_checks" & Checks'Image);
exception
   when others => SS.Release (S); raise;
end SDF_Load_Checks;

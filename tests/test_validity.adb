with Check;              use Check;
with MJ.Types;           use MJ.Types;
with MJ.Models;          use MJ.Models;
with MJ.Models.Validity; use MJ.Models.Validity;

procedure Test_Validity is
   Empty : constant Int_Array (0 .. -1) := [];
   Owner : constant Int_Array := [0, 0, 1];
   Adr   : constant Int_Array := [0, 2];
   Num   : constant Int_Array := [2, 1];
begin
   Assert (not Owners_Sorted ([0 => 0], Integer'First), "minimum owner count is rejected");
   Assert (not Owners_Sorted (Empty, -1), "negative count rejected even with no objects");
   Assert (Owners_Sorted (Empty, 0), "empty ownership is valid");
   Assert (Owners_Sorted (Owner, 2), "sorted owners accepted");
   Assert (not Owners_Sorted ([1, 0], 2), "decreasing owners rejected");
   Assert (Blocks_OK (Adr, Num, Owner), "valid ownership blocks");
   Assert (Covered_OK (Adr, Num, Owner), "every object covered");
   Assert (not Blocks_OK ([0, 1], Num, Owner), "overlapping ownership blocks rejected");
   Assert (CSR_OK ([1, 1], [0, 1], [0, 1], 2, 2, 2), "valid CSR");
   Assert (not CSR_OK ([1, 1], [0, 2], [0, 1], 2, 2, 2), "CSR gap rejected");
   Assert (not CSR_OK ([2], [0], [1, 0], 1, 2, 2), "unsorted CSR columns rejected");
   Assert (CSR_OK (Empty, Empty, Empty, 0, 0, 0), "empty CSR");
   Assert (Texture_Block_OK (2, 3, 2, 4, 26), "texture exactly fits available bytes");
   Assert (not Texture_Block_OK (2, 3, 2, 4, 25), "texture one byte too large is rejected");
   Assert (not Texture_Block_OK (0, 4, Integer'Last, Integer'Last, Max_Size),
           "huge texture dimensions are rejected without overflowing");
   Assert (Texture_Block_OK (5, 4, 0, Integer'Last, 5), "zero-area texture at end is valid");
   Assert (not Texture_Block_OK (0, 0, 1, 1, 4), "zero channels rejected before division");
   Assert (not Texture_Block_OK (Int64'Last, 4, 1, 1, 4), "huge texture address rejected");
   Assert (not Texture_Block_OK (0, 4, -1, 1, 4), "negative texture height rejected");
   Assert (Unit_Quat ([1.0, 0.0, 0.0, 0.0], 0), "identity quaternion is unit");
   Assert (Unit_Quat ([5 => 1.0, 6 .. 8 => 0.0], 5), "quaternion at nonzero array base");
   Assert (not Unit_Quat ([Max_Val, Max_Val, Max_Val, Max_Val], 0),
           "large quaternion rejected without floating overflow");
   Assert (Unit_Vec3 ([0.0, 0.0, 1.0], 0), "unit axis accepted");
   Assert (not Unit_Vec3 ([Max_Val, Max_Val, Max_Val], 0),
           "large axis rejected without floating overflow");
   Assert (not Unit_Vec3 ([0.0, 0.0, 0.0], 0), "zero axis rejected");
   declare
      S : Sizes;
      M : Model;
   begin
      S.Nactuator := 1;
      S.Nu := 3;
      Allocate (S, M);
      Assert (Actuator_Ranges_OK (M), "vector control ranges initially valid");
      M.Actuators.Actuator_Ctrllimited (2) := 1;
      M.Actuators.Actuator_Ctrlrange (4) := 2.0;
      M.Actuators.Actuator_Ctrlrange (5) := 1.0;
      Assert (not Actuator_Ranges_OK (M), "last vector control channel is checked");
      M.Actuators.Actuator_Ctrlrange (5) := 3.0;
      Assert (Actuator_Ranges_OK (M), "ordered vector control range accepted");
      Free (M);
      S.Nactuator := 2;
      S.Nu := 0;
      Allocate (S, M);
      Assert (Actuator_Ranges_OK (M), "range checker never indexes channels by actuator count");
      Free (M);
   end;
   declare
      S : Sizes;
      M : Model;
   begin
      S.Nbody := 1;
      Allocate (S, M);
      M.Bodies.Body_Treeid (0) := -1;
      Assert (Body_Trees_OK (M), "world-only tree is valid");
      M.Bodies.Body_Weldid (0) := Integer'First;
      Assert (not Body_Trees_OK (M), "invalid weld is rejected before indexing");
      M.Bodies.Body_Weldid (0) := 0;
      M.Bodies.Body_Dofnum (0) := 1;
      Assert (not Body_Trees_OK (M), "missing dof is rejected before indexing");
      Free (M);
   end;
   declare
      --  Reserve 512 MiB of virtual space, without touching the elements.
      --  The predicate must reject the length before reading any element.
      Huge : Int_Array_Access := new Int_Array (0 .. Max_Size);
   begin
      Assert (not Block_At ([0 => 0], [0 => 1], Huge.all, 0), "oversized owner array rejected");
      Assert (not Blocks_OK (Empty, Empty, Huge.all), "oversized empty block table rejected");
      Free_Int (Huge);
   end;
   declare
      S : Sizes;
      M : Model;
   begin
      S.Nbody := 2;
      S.Njnt := 1;
      S.Nv := 1;
      S.Nq := 1;
      Allocate (S, M);
      M.Joints.Jnt_Bodyid (0) := 1;
      M.Joints.Jnt_Type (0) := 3;
      M.Dofs.Dof_Parentid (0) := -1;
      M.Dofs.Dof_Bodyid (0) := 1;
      Assert (Jnt_Adrs_OK (M), "single hinge addresses are valid");
      Assert (Dof_Parents_OK (M), "world is the first hinge parent");
      M.Dofs.Dof_Jntid (0) := -1;
      Assert (not Dof_Parents_OK (M), "invalid dof joint rejected before indexing");
      M.Dofs.Dof_Jntid (0) := 0;
      M.Joints.Jnt_Bodyid (0) := -1;
      Assert (not Dof_Parents_OK (M), "invalid joint body rejected before indexing");
      M.Joints.Jnt_Bodyid (0) := 1;
      M.Bodies.Body_Parentid (1) := -1;
      Assert (not Dof_Parents_OK (M), "invalid parent body rejected before indexing");
      M.Bodies.Body_Parentid (1) := 0;
      M.Bodies.Body_Weldid (0) := -1;
      Assert (not Dof_Parents_OK (M), "invalid parent weld rejected before indexing");
      M.Bodies.Body_Weldid (0) := 0;
      M.Bodies.Body_Dofnum (0) := 1;
      M.Bodies.Body_Dofadr (0) := Integer'Last;
      Assert (not Dof_Parents_OK (M), "overflowing parent dof block rejected");
      M.Bodies.Body_Dofadr (0) := 0;
      Assert (Expected_First_Parent (M, 0) = 0, "bounded parent dof block is decoded");
      M.Joints.Jnt_Dofadr (0) := Integer'Last;
      Assert (not Dof_Joints_OK (M), "overflowing joint dof interval rejected");
      M.Joints.Jnt_Type (0) := Integer'Last;
      Assert (not Dof_Joints_OK (M), "invalid joint type rejected before width lookup");
      Free (M);
   end;
   declare
      S : Sizes;
      M : Model;
   begin
      S.Nbody := 32_770;
      S.Ngeom := 2;
      S.Npair := 1;
      S.Nexclude := 1;
      Allocate (S, M);
      M.Geoms.Geom_Bodyid (0) := 32_768;
      M.Geoms.Geom_Bodyid (1) := 32_769;
      M.Pairs.Pair_Geom1 (0) := 0;
      M.Pairs.Pair_Geom2 (0) := 1;
      M.Pairs.Pair_Dim (0) := 1;
      M.Pairs.Pair_Signature (0) := Integer'First + 32_769;
      Assert (not Pairs_OK (M), "high-bit pair signature rejected without overflow");
      M.Geoms.Geom_Bodyid (0) := 32_767;
      M.Geoms.Geom_Bodyid (1) := 32_768;
      M.Pairs.Pair_Signature (0) := 2**31 - 32_768;
      Assert (Pairs_OK (M), "largest signed upper-body ID pair accepted");
      M.Pairs.Pair_Signature (0) := Integer'First + 32_768;
      Assert (not Pairs_OK (M), "wrong high-bit pair signature is rejected");
      M.Pairs.Pair_Geom1 (0) := -1;
      Assert (not Pairs_OK (M), "invalid pair geometry is rejected before indexing");
      M.Excludes.Exclude_Signature (0) := Integer'First + 32_769;
      Assert (not Excludes_OK (M), "high-bit exclusion rejected as in MuJoCo");
      M.Excludes.Exclude_Signature (0) := 2**31 - 32_768;
      Assert (Excludes_OK (M), "signed upper-body boundary exclusion accepted");
      M.Excludes.Exclude_Signature (0) := 32_767 * 2**16 + 32_767;
      Assert (not Excludes_OK (M), "self-exclusion is rejected");
      M.Excludes.Exclude_Signature (0) := -1;
      Assert (not Excludes_OK (M), "out-of-range exclusion bodies are rejected");
      Free (M);
   end;
   declare
      S : Sizes;
      M : Model;
   begin
      S.Nv := 1;
      S.Nc := 1;
      S.Nmesh := 1;
      S.Nmeshgraph := 2;
      Allocate (S, M);
      Assert (not M_Rows_OK (M), "empty inertia row rejected before last-column lookup");
      M.Sparse.M_Rownnz (0) := 1;
      M.Dofs.Dof_Simplenum (0) := 1;
      Assert (M_Rows_OK (M), "single diagonal inertia row accepted");
      M.Sparse.M_Rowadr (0) := Integer'Last;
      Assert (not M_Rows_OK (M), "invalid sparse row address rejected before indexing");
      M.Sparse.M_Rowadr (0) := 0;
      M.Dofs.Dof_Simplenum (0) := 0;
      M.Dofs.Dof_Parentid (0) := Integer'Last;
      Assert (not M_Rows_OK (M), "invalid sparse row parent rejected before indexing");
      Assert (Graph_Block_At (M, 0, 0, 0, 0), "empty graph block accepted");
      M.Meshes.Mesh_Vertnum (0) := Integer'Last;
      Assert (not Graph_Block_At (M, 0, 0, Integer'Last, 1),
              "oversized graph rejected before computing edge count");
      Free (M);
   end;
   Report_And_Exit;
end Test_Validity;

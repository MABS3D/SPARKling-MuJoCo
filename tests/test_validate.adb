with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Strings.Fixed;
with Check;         use Check;
with MJ.Types;      use MJ.Types;
with MJ.Fields;     use MJ.Fields;
with MJ.Models;     use MJ.Models;
with MJ.MJB;        use MJ.MJB;
with MJ.File_IO;
with MJ.Validation; use MJ.Validation;

--  Loads the humanoid from the corpus, checks it validates, then corrupts one
--  field at a time and checks the reported status, field, and index (spec 8.3).
procedure Test_Validate is
   Path    : constant String := "tests/out/corpus/model__humanoid__humanoid.mjb";
   Bytes   : Byte_Array_Access;
   Read_OK : Boolean;
   M       : Model;
   Opts    : constant Validate_Options := (Contact_Cap => 0);

   procedure Reload is
      R : Load_Result;
   begin
      if not All_Null (M) then
         Free (M);
      end if;
      Parse_Raw (Bytes.all, M, R);
      Assert (R.Status = OK, "reload humanoid: " & R.Status'Image);
   end Reload;

   procedure Expect (Status : Load_Status; Field : Field_Id; Index : Integer; What : String) is
      R : Load_Result;
   begin
      Validate (M, Opts, R);
      Assert (R.Status = Status, What & ": status " & R.Status'Image & ", want " & Status'Image);
      Assert (R.Field = Field, What & ": field " & R.Field'Image & ", want " & Field'Image);
      if Index >= 0 then
         Assert_Eq (R.Index, Index, What & ": index");
      end if;
      Reload;
   end Expect;

begin
   MJ.File_IO.Read_File (Path, Bytes, Read_OK);
   if not Read_OK then
      Fail ("cannot read " & Path & "; run: python tools/oracle.py corpus");
      Report_And_Exit;
      return;
   end if;
   Reload;

   --  positive control
   declare
      R : Load_Result;
   begin
      Validate (M, Opts, R);
      Assert (R.Status = OK, "humanoid validates: " & R.Status'Image & " at " & R.Field'Image & R.Index'Image);
      Assert (M.Caps.Efc_Cap >= 10 * M.Caps.Contact_Cap, "efc capacity covers the contact rows");
      Assert_Eq (M.Caps.NIdof_Cap, M.S.Nv, "idof capacity is nv");
      Assert_Eq (M.Caps.NIsland_Cap, M.S.Ntree, "island capacity is ntree");
      Put_Line ("humanoid caps: contact" & M.Caps.Contact_Cap'Image & " efc" & M.Caps.Efc_Cap'Image
                & " nJ" & M.Caps.NJ_Cap'Image);
   end;
   Assert (M.S.Nbody > 5 and M.S.Njnt > 3 and M.S.Ngeom > 3, "humanoid is big enough for the mutations");

   --  references (generated clauses)
   M.Bodies.Body_Parentid (1) := -1;
   Expect (Invalid_Reference, Body_Parentid, 1, "parent -1 not allowed");
   M.Geoms.Geom_Matid (0) := -2;
   Expect (Invalid_Reference, Geom_Matid, 0, "matid below -1");
   M.Geoms.Geom_Matid (0) := -1;
   Expect (OK, None, -1, "matid -1 is allowed");
   M.Bodies.Body_Jntnum (1) := M.S.Njnt + 1;
   Expect (Invalid_Reference, Body_Jntadr, 1, "jntnum past njnt");

   --  flags and real ranges (generated clauses)
   M.Joints.Jnt_Limited (0) := 2;
   Expect (Invalid_Parameter, Jnt_Limited, 0, "flag byte 2");
   M.Bodies.Body_Mass (1) := 1.0e11;
   Expect (Invalid_Parameter, Body_Mass, 1, "mass above Max_Val");

   --  body tree
   M.Bodies.Body_Parentid (1) := 1;
   Expect (Invalid_Tree, Body_Parentid, 1, "self parent");
   M.Bodies.Body_Rootid (2) := 2;
   Expect (Invalid_Tree, Body_Rootid, 2, "root of a non-root body");
   M.Bodies.Body_Weldid (1) := 0;
   Expect (Invalid_Tree, Body_Weldid, 1, "weld of a jointed body");
   M.Bodies.Body_Jntnum (1) := M.Bodies.Body_Jntnum (1) + 1;
   Expect (Invalid_Tree, Body_Jntadr, 1, "jntnum overlaps the next body");
   M.Joints.Jnt_Bodyid (1) := 0;
   Expect (Invalid_Tree, Jnt_Bodyid, -1, "joint owners out of order");
   M.Dofs.Dof_Treeid (0) := 1;
   Expect (Invalid_Tree, Dof_Treeid, 0, "first dof not in tree 0");
   M.Trees.Tree_Dofnum (0) := 0;
   Expect (Invalid_Tree, Tree_Dofnum, 0, "empty tree");
   M.Bodies.Body_Treeid (1) := -1;
   Expect (Invalid_Tree, Body_Treeid, 1, "jointed body marked static");
   M.Trees.Tree_Sleep_Policy (0) := 6;
   Expect (Invalid_Enum, Tree_Sleep_Policy, 0, "sleep policy 6");

   --  joints and dofs
   M.Joints.Jnt_Type (0) := 4;
   Expect (Invalid_Enum, Jnt_Type, 0, "joint type 4");
   M.Joints.Jnt_Qposadr (1) := M.Joints.Jnt_Qposadr (1) + 1;
   Expect (Invalid_Joint_Layout, Jnt_Qposadr, 1, "qposadr gap");
   M.Joints.Jnt_Dofadr (1) := M.Joints.Jnt_Dofadr (1) - 1;
   Expect (Invalid_Joint_Layout, Jnt_Qposadr, 1, "dofadr overlap");
   M.Dofs.Dof_Jntid (0) := 1;
   Expect (Invalid_Dof_Chain, Dof_Jntid, 0, "dof 0 claims joint 1");
   M.Dofs.Dof_Parentid (1) := 5;
   Expect (Invalid_Dof_Chain, Dof_Parentid, 1, "forward dof parent");
   M.Dofs.Dof_Parentid (1) := -1;
   Expect (Invalid_Tree, Dof_Treeid, 1, "detaching a dof breaks the tree numbering first");
   M.Dofs.Dof_Madr (1) := M.Dofs.Dof_Madr (1) + 1;
   Expect (Invalid_Dof_Chain, Dof_Madr, -1, "madr row length off by one");
   M.Dofs.Dof_Simplenum (0) := M.S.Nv + 1;
   Expect (Invalid_Dof_Chain, Dof_Simplenum, 0, "simplenum past nv");

   --  sparse structures
   M.Sparse.M_Rowadr (1) := M.Sparse.M_Rowadr (1) + 1;
   Expect (Invalid_CSR, M_Rowadr, 1, "inertia row start gap");
   M.Sparse.M_Colind (M.Sparse.M_Rowadr (1)) := M.S.Nv;
   Expect (Invalid_CSR, M_Rowadr, -1, "inertia column out of range");
   M.Sparse.M_Colind (M.Sparse.M_Rowadr (1) + M.Sparse.M_Rownnz (1) - 1) := 2;   --  still a valid CSR row
   Expect (Invalid_CSR, M_Colind, 1, "inertia row does not end with its own dof");
   M.Sparse.D_Diag (0) := M.Sparse.D_Rownnz (0);
   Expect (Invalid_CSR, D_Diag, 0, "diagonal offset past the row");
   M.Sparse.MapD2M (0) := M.S.Nd;
   Expect (Invalid_CSR, MapD2M, 0, "map entry out of range");

   --  geoms
   M.Geoms.Geom_Type (0) := 8;
   Expect (Unsupported_Plugins, Geom_Type, 0, "sdf geom");
   M.Geoms.Geom_Type (0) := 9;
   Expect (Invalid_Enum, Geom_Type, 0, "geom type 9");
   M.Geoms.Geom_Condim (0) := 2;
   Expect (Invalid_Enum, Geom_Condim, 0, "condim 2");
   M.Geoms.Geom_Dataid (0) := 0;
   Expect (Invalid_Reference, Geom_Dataid, 0, "primitive geom with a data id");
   M.Geoms.Geom_Sameframe (0) := 5;
   Expect (Invalid_Enum, Geom_Sameframe, 0, "sameframe 5");

   --  bounding volumes
   if M.S.Nbvh > 0 then
      M.Bvh.Bvh_Depth (0) := Max_Tree_Depth + 1;
      Expect (Invalid_BVH, Body_Bvhadr, -1, "bvh depth past the maximum");
      M.Bvh.Bvh_Child (0) := 0;
      Expect (Invalid_BVH, Body_Bvhadr, -1, "bvh child pointing at itself");
   end if;

   --  actuators (humanoid has motors on joints)
   Assert (M.S.Nactuator > 0, "humanoid has actuators");
   M.Actuators.Actuator_Trntype (0) := 7;
   Expect (Invalid_Enum, Actuator_Trntype, 0, "transmission type 7");
   M.Actuators.Actuator_Trntype (0) := 1000;
   Expect (OK, None, -1, "undefined transmission is allowed");
   M.Actuators.Actuator_Trnid (0) := M.S.Njnt;
   Expect (Invalid_Reference, Actuator_Trnid, 0, "joint transmission past njnt");
   M.Actuators.Actuator_Ctrlnum (0) := 0;
   Expect (Invalid_Reference, Actuator_Actadr, 0, "actuator without controls");
   M.Actuators.Actuator_Ctrllimited (0) := 1;
   M.Actuators.Actuator_Ctrlrange (0) := 2.0;
   M.Actuators.Actuator_Ctrlrange (1) := 1.0;
   Expect (Invalid_Parameter, Actuator_Ctrlrange, 0, "inverted control range");

   --  equality-free, tendon-free humanoid: corrupt the names buffer instead
   M.Names.Names (M.S.Nnames - 1) := Character'Pos ('x');
   Expect (Invalid_Parameter, Names, M.S.Nnames - 1, "names not NUL-terminated");

   --  parameters
   M.Opt.Timestep := 0.0;
   Expect (Invalid_Parameter, Option_Block, -1, "zero timestep");
   M.Opt.Integrator := 4;
   Expect (Invalid_Parameter, Option_Block, -1, "integrator 4");
   M.Stat.Extent := -1.0;
   Expect (Invalid_Parameter, Statistic_Block, -1, "negative extent");
   M.Bodies.Body_Mass (1) := -1.0;
   Expect (Invalid_Parameter, Body_Mass, 1, "negative mass");
   M.Bodies.Body_Quat (4) := 2.0;
   Expect (Invalid_Parameter, Body_Mass, 1, "non-unit body quaternion");
   M.Joints.Jnt_Axis (3 * 1) := 5.0;
   Expect (Invalid_Parameter, Jnt_Axis, 1, "non-unit joint axis");
   M.Geoms.Geom_Size (0) := -0.1;
   Expect (Invalid_Parameter, Geom_Size, 0, "negative geom size");
   M.Dofs.Dof_Damping (0) := -1.0;
   Expect (Invalid_Parameter, Dof_Damping, -1, "negative damping");
   M.Geoms.Geom_Adhesion (0) := 1.0;
   Expect (OK, None, -1, "adhesion is recomputed, not rejected");
   declare
      R : Load_Result;
   begin
      M.Geoms.Geom_Adhesion (0) := 1.0;
      Validate (M, Opts, R);
      Assert (R.Status = OK and then M.Flg_Adhesion, "adhesion flag set from geom_adhesion");
      Reload;
      Validate (M, Opts, R);
      Assert (R.Status = OK and then not M.Flg_Adhesion, "adhesion flag clear for the humanoid");
   end;

   Free (M);
   Free_Byte (Bytes);

   --  meshes, textures: use the first corpus model that has both a mesh and a texture
   declare
      L     : Ada.Text_IO.File_Type;
      Found : Boolean := False;
   begin
      Ada.Text_IO.Open (L, Ada.Text_IO.In_File, "tests/corpus_expected.txt");
      while not Found and then not Ada.Text_IO.End_Of_File (L) loop
         declare
            Line : constant String := Ada.Text_IO.Get_Line (L);
         begin
            if Line'Length > 3 and then Line (Line'First .. Line'First + 2) = "OK " then
               declare
                  Rest : constant String := Line (Line'First + 3 .. Line'Last);
                  Sp   : constant Natural := Ada.Strings.Fixed.Index (Rest, " ");
                  Name : constant String := Rest (Rest'First .. Sp - 1);
                  R    : Load_Result;
               begin
                  MJ.File_IO.Read_File ("tests/out/corpus/" & Name, Bytes, Read_OK);
                  if Read_OK then
                     Parse_Raw (Bytes.all, M, R);
                     if R.Status = OK and then M.S.Nmesh > 0 and then M.S.Ntex > 0 then
                        Found := True;
                        Put_Line ("mesh model: " & Name);
                     else
                        if R.Status = OK then
                           Free (M);
                        end if;
                        Free_Byte (Bytes);
                     end if;
                  end if;
               end;
            end if;
         end;
      end loop;
      Ada.Text_IO.Close (L);
      if Found then
         Expect (OK, None, -1, "mesh model validates");
         M.Meshes.Mesh_Face (3 * M.Meshes.Mesh_Faceadr (0)) := M.Meshes.Mesh_Vertnum (0);
         Expect (Invalid_Reference, Mesh_Face, 0, "face vertex past the mesh");
         if M.Meshes.Mesh_Graphadr (0) >= 0 then
            M.Meshes.Mesh_Graph (M.Meshes.Mesh_Graphadr (0)) := M.Meshes.Mesh_Vertnum (0) + 1;
            Expect (Invalid_Reference, Mesh_Graph, 0, "graph numvert past the mesh");
         end if;
         M.Textures.Tex_Nchannel (0) := 5;
         Expect (Invalid_Parameter, Tex_Adr, 0, "texture with five channels");
         M.Materials.Mat_Texid (0) := M.S.Ntex;
         Expect (Invalid_Reference, Mat_Texid, 0, "material texture id past ntex");
         if M.Meshes.Mesh_Bvhnum (0) > 0 then
            M.Bvh.Bvh_Nodeid (M.Meshes.Mesh_Bvhadr (0) + M.Meshes.Mesh_Bvhnum (0) - 1) := M.Meshes.Mesh_Facenum (0);
            Expect (Invalid_BVH, Mesh_Bvhadr, 0, "mesh bvh leaf past facenum");
         end if;
         if M.S.Nsensor > 0 then
            M.Sensors.Sensor_Type (0) := 47;
            Expect (Unsupported_Plugins, Sensor_Type, 0, "plugin sensor");
            M.Sensors.Sensor_Type (0) := 49;
            Expect (Invalid_Enum, Sensor_Type, 0, "sensor type 49");
            M.Sensors.Sensor_Adr (0) := 1;
            Expect (Invalid_Parameter, Sensor_Adr, 0, "first sensor not at address 0");
            M.Sensors.Sensor_Objtype (0) := 26;
            Expect (Invalid_Reference, Sensor_Objid, 0, "sensor object type mjNOBJECT");
         end if;
         if M.S.Ntendon > 0 then
            M.Tendons.Tendon_Num (0) := 0;
            Expect (Invalid_Reference, Tendon_Adr, 0, "empty tendon");
            M.Wraps.Wrap_Type (M.Tendons.Tendon_Adr (0)) := 6;
            Expect (Invalid_Enum, Wrap_Type, M.Tendons.Tendon_Adr (0), "wrap type 6");
         end if;
         if M.S.Npair > 0 then
            M.Pairs.Pair_Signature (0) := M.Pairs.Pair_Signature (0) + 1;
            Expect (Invalid_Signature, Pair_Signature, 0, "pair signature mismatch");
         end if;
         if M.S.Neq > 0 then
            M.Equalities.Eq_Type (0) := 7;
            Expect (Invalid_Enum, Eq_Type, 0, "distance equality");
            M.Equalities.Eq_Type (0) := 5;
            Expect (Unsupported_Flex, Eq_Type, 0, "flex equality");
         end if;
         Put_Line ("mesh model features: sensors" & M.S.Nsensor'Image & " tendons" & M.S.Ntendon'Image
                   & " pairs" & M.S.Npair'Image & " equalities" & M.S.Neq'Image);
         Free (M);
         Free_Byte (Bytes);
      else
         Put_Line ("no corpus model with both a mesh and a texture; mesh mutations skipped");
      end if;
   end;

   Report_And_Exit;
end Test_Validate;

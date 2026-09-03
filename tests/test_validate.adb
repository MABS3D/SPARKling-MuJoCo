with Ada.Text_IO;   use Ada.Text_IO;
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

   Free (M);
   Free_Byte (Bytes);
   Report_And_Exit;
end Test_Validate;

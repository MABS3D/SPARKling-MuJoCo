with Check;    use Check;
with MJ.Types; use MJ.Types;
with MJ.Models; use MJ.Models;

procedure Test_Model_Alloc is
   S : Sizes;
   M : Model;
begin
   Assert (All_Null (M), "fresh model has no allocations");

   S.Nbody := 3;
   S.Njnt := 2;
   S.Nv := 7;
   S.Nq := 8;
   S.Nuser_Body := 2;
   S.Nmocap := 1;
   S.Nkey := 2;
   Assert (Sizes_In_Range (S), "small sizes are in range");

   Allocate (S, M);
   Assert (Valid_Layout (M), "allocated model has a valid layout");
   Assert_Eq (M.S.Nbody, 3, "sizes copied into the model");
   Assert_Eq (M.Bodies.Body_Parentid'Length, 3, "nbody x 1 ints");
   Assert_Eq (M.Bodies.Body_Pos'Length, 9, "nbody x 3 reals");
   Assert_Eq (M.Bodies.Body_User'Length, 6, "nbody x nuser_body");
   Assert_Eq (M.Keys.Key_Qpos'Length, 16, "nkey x nq");
   Assert_Eq (M.Keys.Key_Mquat'Length, 8, "nkey x 4*nmocap");
   Assert_Eq (M.Geoms.Geom_Type'Length, 0, "ngeom = 0 gives an empty array");
   Assert_Eq (M.Geoms.Geom_Type'First, 0, "empty arrays still start at 0");
   Assert_Eq (M.Bodies.Body_Parentid (2), 0, "arrays are zero-filled");
   Assert (M.Bodies.Body_Mass (1) = 0.0, "real arrays are zero-filled");

   Free (M);
   Assert (All_Null (M), "free nulls every access value");

   declare
      Big : Sizes;
   begin
      Big.Nbody := Max_Size;
      Big.Nuser_Body := 2;
      Assert (not Sizes_In_Range (Big), "nbody * nuser_body above Max_Size is rejected");
      Big.Nuser_Body := 0;
      Big.Nbody := Max_Size / 4 + 1;
      Assert (not Sizes_In_Range (Big), "nbody * 4 (body_quat) above Max_Size is rejected");
      Big.Nbody := Max_Size / 4;
      Assert (Sizes_In_Range (Big), "nbody * 4 just below Max_Size is accepted");
   end;

   Report_And_Exit;
end Test_Model_Alloc;

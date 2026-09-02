with Check;         use Check;
with Interfaces;    use Interfaces;
with Ada.Unchecked_Conversion;
with MJ.Types;      use MJ.Types;
with MJ.Fields;     use MJ.Fields;
with MJ.Models;      use MJ.Models;
with MJ.MJB;        use MJ.MJB;
with MJ.Bytes;
with MJB_Serialize; use MJB_Serialize;

procedure Test_Parse_Raw is
   function To_Real is new Ada.Unchecked_Conversion (Unsigned_64, Real);
   NaN : constant Real := To_Real (16#7FF8_0000_0000_0000#);

   S  : Sizes;
   M0 : Model;

   --  A tiny two-body model image: world plus one body with a hinge and a sphere.
   procedure Build_Reference is
      Names : constant String := "world" & ASCII.NUL & "torso" & ASCII.NUL;
   begin
      S.Nbody := 2;
      S.Njnt := 1;
      S.Nq := 1;
      S.Nv := 1;
      S.Ngeom := 1;
      S.Nnames := Names'Length;
      S.Nmocap := 0;
      Allocate (S, M0);
      M0.Opt.Timestep := 0.002;
      M0.Opt.Gravity := [0.0, 0.0, -9.81];
      M0.Opt.Integrator := 1;
      M0.Vis.Global.Fovy := 45.0;
      M0.Stat.Extent := 2.5;
      M0.Flg_Gravcomp := True;
      M0.Bodies.Body_Parentid (1) := 0;
      M0.Bodies.Body_Mass (1) := 3.5;
      M0.Bodies.Body_Pos (3 .. 5) := [1.0, 2.0, 3.0];
      M0.Joints.Jnt_Type (0) := 3;
      M0.Geoms.Geom_Type (0) := 2;
      for K in Names'Range loop
         M0.Names.Names (K - Names'First) := Character'Pos (Names (K));
      end loop;
   end Build_Reference;

   procedure Expect (B : Byte_Array; Status : Load_Status; Field : Field_Id; Index : Integer; What : String) is
      M : Model;
      R : Load_Result;
   begin
      Parse_Raw (B, M, R);
      Assert (R.Status = Status, What & ": status " & R.Status'Image & ", want " & Status'Image);
      Assert (R.Field = Field, What & ": field " & R.Field'Image & ", want " & Field'Image);
      Assert_Eq (R.Index, Index, What & ": index");
      Assert (All_Null (M), What & ": nothing left allocated");
   end Expect;

begin
   Build_Reference;
   declare
      Len : constant Int64 := Serialized_Size (M0);
      B   : Byte_Array (0 .. Integer (Len) - 1);
      M1  : Model;
      R   : Load_Result;
   begin
      Serialize (M0, B);
      Assert_Eq (MJ.Bytes.Get_I32 (B, 0), 54321, "image starts with the header id");

      --  round trip
      Parse_Raw (B, M1, R);
      Assert (R.Status = OK, "reference image parses: " & R.Status'Image);
      Assert (Valid_Layout (M1), "parsed model has a valid layout");
      Assert (M1.Opt.Timestep = 0.002, "option timestep");
      Assert (M1.Opt.Gravity (2) = -9.81, "option gravity z");
      Assert_Eq (M1.Opt.Integrator, 1, "option integrator");
      Assert (M1.Vis.Global.Fovy = 45.0, "visual fovy");
      Assert (M1.Stat.Extent = 2.5, "statistic extent");
      Assert (M1.Flg_Gravcomp and not M1.Flg_Surfacevel, "flags");
      Assert_Eq (M1.Bodies.Body_Parentid (1), 0, "body parent");
      Assert (M1.Bodies.Body_Mass (1) = 3.5, "body mass");
      Assert (M1.Bodies.Body_Pos (4) = 2.0, "body pos");
      Assert_Eq (M1.Joints.Jnt_Type (0), 3, "joint type");
      Assert_Eq (Integer (M1.Names.Names (6)), Character'Pos ('t'), "names bytes");
      declare
         B2 : Byte_Array (0 .. Integer (Len) - 1);
      begin
         Serialize (M1, B2);
         Assert (B = B2, "serialize (parse (x)) = x");
      end;
      Free (M1);

      --  header corruptions, one field at a time
      declare
         Statuses : constant array (0 .. 4) of Load_Status :=
           [Bad_Header_ID, Bad_Precision, Bad_Size_Count, Bad_Version, Bad_Pointer_Count];
      begin
         for I in 0 .. 4 loop
            declare
               C : Byte_Array := B;
            begin
               C (4 * I) := C (4 * I) + 1;
               Expect (C, Statuses (I), Header, I, "header field" & I'Image);
            end;
         end loop;
      end;

      --  truncations
      Expect (B (0 .. 9), Truncated, Header, -1, "truncated header");
      Expect (B (0 .. Header_Bytes + 7), Truncated, Size_Table, -1, "truncated size table");
      Expect (B (0 .. Header_Bytes + 8 * Size_Count + 3), Truncated, Option_Block, -1, "truncated option block");
      Expect (B (0 .. Integer (Len) - 2), Truncated, D_Diag, -1, "truncated in the last non-empty array (D_diag has nv entries)");

      --  trailing byte
      declare
         C : constant Byte_Array (0 .. Integer (Len)) := B & Byte_Array'[0 => 0];
      begin
         Expect (C, Trailing_Bytes, None, Integer (Len), "trailing byte");
      end;

      --  size out of range: nq = -5 (size 0), nbody = 0 (size 6)
      declare
         C : Byte_Array := B;
      begin
         C (Header_Bytes .. Header_Bytes + 7) := [16#FB#, 16#FF#, 16#FF#, 16#FF#, 16#FF#, 16#FF#, 16#FF#, 16#FF#];
         Expect (C, Size_Out_Of_Range, Size_Table, 0, "negative nq");
      end;
      declare
         C : Byte_Array := B;
      begin
         C (Header_Bytes + 48 .. Header_Bytes + 55) := [others => 0];
         Expect (C, Size_Out_Of_Range, Size_Table, 6, "nbody = 0");
      end;
   end;

   --  non-finite values in an array and in the option block
   M0.Bodies.Body_Pos (4) := NaN;
   declare
      B : Byte_Array (0 .. Integer (Serialized_Size (M0)) - 1);
   begin
      Serialize (M0, B);
      Expect (B, Non_Finite_Value, Body_Pos, 4, "NaN in body_pos");
   end;
   M0.Bodies.Body_Pos (4) := 2.0;
   M0.Opt.Gravity (2) := NaN;
   declare
      B : Byte_Array (0 .. Integer (Serialized_Size (M0)) - 1);
   begin
      Serialize (M0, B);
      Expect (B, Non_Finite_Value, Option_Block, 7, "NaN in option gravity (member 7)");
   end;

   Free (M0);
   Report_And_Exit;
end Test_Parse_Raw;

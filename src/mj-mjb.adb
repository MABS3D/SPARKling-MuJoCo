with MJ.Fixed;
with MJ.Bytes;       use MJ.Bytes;
with MJ.MJB.Readers; use MJ.MJB.Readers;

package body MJ.MJB with SPARK_Mode is

   procedure Parse_Raw (B : Byte_Array; M : in out Model; Result : out Load_Result) is
      Pos        : Natural;
      S          : Sizes;
      Opt        : MJ.Fixed.Option;
      Vis        : MJ.Fixed.Visual;
      Stat       : MJ.Fixed.Statistic;
      Gravcomp   : Boolean;
      Surfacevel : Boolean;
   begin
      --  A zero-based array can have Natural'Last + 1 elements, but the
      --  cursor must also represent the position just past the final byte.
      if Int64 (B'Length) > Int64 (Natural'Last) then
         Result := (Size_Out_Of_Range, Header, -1);
         return;
      end if;
      if B'Length < Header_Bytes then
         Result := (Truncated, Header, -1);
         return;
      end if;

      if Get_I32 (B, 0) /= MJB_ID then
         Result := (Bad_Header_ID, Header, 0);
         return;
      elsif Get_I32 (B, 4) /= MJB_Precision then
         Result := (Bad_Precision, Header, 1);
         return;
      elsif Get_I32 (B, 8) /= Size_Count then
         Result := (Bad_Size_Count, Header, 2);
         return;
      elsif Get_I32 (B, 12) /= Version_Header then
         Result := (Bad_Version, Header, 3);
         return;
      elsif Get_I32 (B, 16) /= Pointer_Count then
         Result := (Bad_Pointer_Count, Header, 4);
         return;
      end if;
      Pos := Header_Bytes;

      if Int64 (B'Length) - Int64 (Pos) < 8 * Size_Count then
         Result := (Truncated, Size_Table, -1);
         return;
      end if;
      Read_Sizes (B, Pos, S, Result);
      if Result.Status /= OK then
         return;
      end if;
      if S.Nbody < 1 then
         Result := (Size_Out_Of_Range, Size_Table, 6);   --  nbody is the seventh size
         return;
      end if;
      if not Sizes_In_Range (S) then
         Result := (Size_Out_Of_Range, Size_Table, -1);
         return;
      end if;

      if Int64 (B'Length) - Int64 (Pos) < Fixed_Bytes then
         Result := (Truncated, Option_Block, -1);
         return;
      end if;
      Read_Fixed (B, Pos, Opt, Vis, Stat, Gravcomp, Surfacevel, Result);
      if Result.Status /= OK then
         return;
      end if;
      M.Opt := Opt;
      M.Vis := Vis;
      M.Stat := Stat;
      M.Flg_Gravcomp := Gravcomp;
      M.Flg_Surfacevel := Surfacevel;

      M.S := S;
      Read_Arrays (B, Pos, M, Result);
      if Result.Status /= OK then
         Free (M);
         return;
      end if;
      if Int64 (Pos) /= Int64 (B'Length) then
         Result := (Trailing_Bytes, None, Pos);
         Free (M);
         return;
      end if;
   end Parse_Raw;

   procedure Parse (B : Byte_Array; Options : Validate_Options; M : in out Model; Result : out Load_Result) is
      --  Compose the callees' contracts without expanding their model-wide
      --  predicates. This removes proof facts, not checks or obligations.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", All_Null);
   begin
      Parse_Raw (B, M, Result);
      if Result.Status /= OK then
         return;
      end if;
      Validate (M, Options, Result);
      if Result.Status /= OK then
         Free (M);
      end if;
   end Parse;

   procedure Load (Path : String; Options : Validate_Options; M : in out Model; Result : out Load_Result) is
      --  Compose the callees' contracts without expanding their model-wide
      --  predicates. This removes proof facts, not checks or obligations.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", All_Null);
      B       : Byte_Array_Access;
      Read_OK : Boolean;
   begin
      MJ.File_IO.Read_File (Path, B, Read_OK);
      if not Read_OK then
         Result := (File_Error, None, -1);
         return;
      end if;
      Parse (B.all, Options, M, Result);
      Free_Byte (B);
   end Load;

end MJ.MJB;

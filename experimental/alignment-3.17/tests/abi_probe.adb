with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces; use Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Fields; use MJ.Fields;
with MJ.Models; use MJ.Models;
with MJ.MJB;
with MJ.Validation;
with MJ.Models.Validity;
with MJ.File_IO;
with MJB_Serialize;

-- Test-only transport: compare raw decoded values and round-trip bytes with
-- fixtures produced by the real official compiler, before model admission.
procedure ABI_Probe is
   function Bits is new Ada.Unchecked_Conversion (Real, Unsigned_64);
   Input : Byte_Array_Access;
   Loaded : Boolean;
   M : Model;
   Result, Validation_Result : Load_Result;

   procedure Show (Name : String; A : Int_Array) is
   begin
      Put (Name);
      for V of A loop Put (" " & Integer'Image (V)); end loop;
      New_Line;
   end Show;

   procedure Show_Bits (Name : String; A : Real_Array) is
   begin
      Put (Name);
      for V of A loop Put (" " & Unsigned_64'Image (Bits (V))); end loop;
      New_Line;
   end Show_Bits;
begin
   if Ada.Command_Line.Argument_Count not in 1 .. 2 then
      raise Constraint_Error with "MJB path and optional mutation required";
   end if;
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1), Input, Loaded);
   if not Loaded then raise Program_Error with "fixture cannot be read"; end if;
   MJ.MJB.Parse_Raw (Input.all, M, Result);
   Put_Line ("STATUS " & Result.Status'Image);
   if Result.Status = OK then
      if Ada.Command_Line.Argument_Count = 2 then
         declare
            Mutation : constant String := Ada.Command_Line.Argument (2);
         begin
            if Mutation = "perm_low" or else Mutation = "perm_high" then
               -- The ordinary fixture has no flexes. A synthetic one-entry
               -- ordering isolates this malformed untrusted field from the
               -- existing Unsupported_Flex guard, without bypassing Validate.
               if M.S.NefmCvert /= 0 then raise Program_Error with "empty permutation expected"; end if;
               Free_Int (M.Flexes.EfmC_Perm);
               M.S.NefmCvert := 1;
               M.Flexes.EfmC_Perm := new Int_Array'(0 => (if Mutation = "perm_low" then -2 else M.S.Nv));
            elsif Mutation = "texture_path" then
               if M.S.Ntex /= 1 or else M.Textures.Tex_Adr (0) /= -1 then
                  raise Program_Error with "one external texture expected";
               end if;
               M.Textures.Tex_Pathadr (0) := -1;
            else
               raise Constraint_Error with "unknown mutation";
            end if;
         end;
      end if;
      Put_Line ("FLAGS" & Integer'Image (Boolean'Pos (M.Flg_Gravcomp))
        & Integer'Image (Boolean'Pos (M.Flg_Surfacevel)) & Integer'Image (Boolean'Pos (M.Flg_Adhesion)));
      Put_Line ("SIZES" & M.S.NefmCvert'Image & M.S.Neq'Image & M.S.Ntex'Image);
      Show ("EFMC_PERM", M.Flexes.EfmC_Perm.all);
      Show_Bits ("EQ_DATA_BITS", M.Equalities.Eq_Data.all);
      Show ("BODY_PARENT", M.Bodies.Body_Parentid.all);
      Show_Bits ("BODY_MASS_BITS", M.Bodies.Body_Mass.all);
      Put ("TEX_ADR");
      for V of M.Textures.Tex_Adr.all loop Put (" " & Int64'Image (V)); end loop;
      New_Line;
      Show ("TEX_WIDTH", M.Textures.Tex_Width.all);
      Show ("TEX_HEIGHT", M.Textures.Tex_Height.all);
      Show ("TEX_PATHADR", M.Textures.Tex_Pathadr.all);
      Show ("TEX_CONTENTTYPEADR", M.Textures.Tex_Contenttypeadr.all);
      declare
         Output : Byte_Array (0 .. Integer (MJB_Serialize.Serialized_Size (M)) - 1);
      begin
         MJB_Serialize.Serialize (M, Output);
         Put_Line ("ROUNDTRIP " & Boolean'Image (Output = Input.all));
      end;
      Put_Line ("PERM_VALID " & Boolean'Image (MJ.Models.Validity.EfmC_Permutation_OK (M)));
      Put_Line ("TEXTURES_VALID " & Boolean'Image (MJ.Models.Validity.Textures_OK (M)));
      MJ.Validation.Validate (M, (Contact_Cap => 0), Validation_Result);
      Put_Line ("VALIDATION " & Validation_Result.Status'Image);
      Free (M);
   end if;
   Put_Line ("ALL_NULL " & Boolean'Image (All_Null (M)));
   Free_Byte (Input);
end ABI_Probe;

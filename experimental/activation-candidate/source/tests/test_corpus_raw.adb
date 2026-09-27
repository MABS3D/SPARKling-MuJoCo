with Ada.Text_IO;      use Ada.Text_IO;
with Ada.Strings.Fixed;
with Check;            use Check;
with MJ.Types;         use MJ.Types;
with MJ.Fields;        use MJ.Fields;
with MJ.Models;        use MJ.Models;
with MJ.MJB;           use MJ.MJB;
with MJ.File_IO;

--  Every .mjb the reference compiler produced must parse (spec 8.4, raw half).
procedure Test_Corpus_Raw is
   Listing : constant String := "tests/corpus_expected.txt";
   Dir     : constant String := "tests/out/corpus/";
   F       : File_Type;
   Count   : Natural := 0;
begin
   begin
      Open (F, In_File, Listing);
   exception
      when others =>
         Fail ("cannot open " & Listing & "; run: python tools/oracle.py corpus");
         Report_And_Exit;
         return;
   end;
   while not End_Of_File (F) loop
      declare
         Line : constant String := Get_Line (F);
         Sp1  : constant Natural := Ada.Strings.Fixed.Index (Line, " ");
      begin
         if Sp1 > 0 and then Line (Line'First .. Sp1 - 1) /= "SKIP" then
            declare
               Rest : constant String := Line (Sp1 + 1 .. Line'Last);
               Sp2  : constant Natural := Ada.Strings.Fixed.Index (Rest, " ");
               Name : constant String := Rest (Rest'First .. Sp2 - 1);
               B    : Byte_Array_Access;
               Read_OK : Boolean;
               M    : Model;
               R    : Load_Result;
            begin
               MJ.File_IO.Read_File (Dir & Name, B, Read_OK);
               Assert (Read_OK, "read " & Name & " (run: python tools/oracle.py corpus)");
               if Read_OK then
                  Parse_Raw (B.all, M, R);
                  Assert (R.Status = OK, Name & ": " & R.Status'Image & " at " & R.Field'Image & R.Index'Image);
                  if R.Status = OK then
                     Assert (Valid_Layout (M), Name & ": valid layout");
                     Free (M);
                  end if;
                  Free_Byte (B);
                  Count := Count + 1;
               end if;
            end;
         end if;
      end;
   end loop;
   Close (F);
   Assert (Count >= 10, "at least ten corpus models parsed, got" & Count'Image);
   Put_Line ("parsed" & Count'Image & " corpus models");
   Report_And_Exit;
end Test_Corpus_Raw;

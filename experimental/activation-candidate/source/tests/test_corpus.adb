with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Check;                   use Check;
with MJ.Types;                use MJ.Types;
with MJ.Fields;               use MJ.Fields;
with MJ.Models;               use MJ.Models;
with MJ.MJB;

--  Every corpus model loads with exactly the status the oracle predicted
--  (spec 8.4). OK models must be Valid_Model; rejected ones leave nothing allocated.
procedure Test_Corpus is
   Listing : constant String := "tests/corpus_expected.txt";
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
               Want : constant String := To_Upper (Line (Line'First .. Sp1 - 1));
               Rest : constant String := Line (Sp1 + 1 .. Line'Last);
               Sp2  : constant Natural := Ada.Strings.Fixed.Index (Rest, " ");
               Name : constant String := Rest (Rest'First .. Sp2 - 1);
               M    : Model;
               R    : Load_Result;
            begin
               MJ.MJB.Load ("tests/out/corpus/" & Name, (Contact_Cap => 0), M, R);
               Assert (R.Status'Image = Want,
                       Name & ": got " & R.Status'Image & " at " & R.Field'Image & R.Index'Image & ", want " & Want);
               if R.Status = OK then
                  Assert (Valid_Layout (M), Name & ": valid layout");
                  Free (M);
               else
                  Assert (All_Null (M), Name & ": nothing allocated after rejection");
               end if;
               Count := Count + 1;
            end;
         end if;
      end;
   end loop;
   Close (F);
   Assert (Count >= 10, "at least ten corpus models checked, got" & Count'Image);
   Put_Line ("checked" & Count'Image & " corpus models");
   Report_And_Exit;
end Test_Corpus;

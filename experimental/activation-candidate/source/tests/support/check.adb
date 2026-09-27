with Ada.Text_IO;
with Ada.Command_Line;

package body Check is

   Passed : Natural := 0;
   Failed : Natural := 0;

   procedure Assert (Cond : Boolean; Msg : String) is
   begin
      if Cond then
         Passed := Passed + 1;
      else
         Failed := Failed + 1;
         Ada.Text_IO.Put_Line ("FAIL: " & Msg);
      end if;
   end Assert;

   procedure Assert_Eq (Actual, Expected : Integer; Msg : String) is
   begin
      Assert (Actual = Expected,
              Msg & " (got" & Actual'Image & ", want" & Expected'Image & ")");
   end Assert_Eq;

   procedure Assert_Eq64 (Actual, Expected : Long_Long_Integer; Msg : String) is
   begin
      Assert (Actual = Expected,
              Msg & " (got" & Actual'Image & ", want" & Expected'Image & ")");
   end Assert_Eq64;

   procedure Assert_Eq (Actual, Expected : String; Msg : String) is
   begin
      Assert (Actual = Expected, Msg & " (got '" & Actual & "', want '" & Expected & "')");
   end Assert_Eq;

   procedure Fail (Msg : String) is
   begin
      Assert (False, Msg);
   end Fail;

   function Failures return Natural is (Failed);

   procedure Report_And_Exit is
   begin
      Ada.Text_IO.Put_Line (Passed'Image & " passed," & Failed'Image & " failed");
      Ada.Command_Line.Set_Exit_Status
        (if Failed = 0 then Ada.Command_Line.Success else Ada.Command_Line.Failure);
   end Report_And_Exit;

end Check;

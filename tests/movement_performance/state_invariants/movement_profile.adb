with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
package body Movement_Profile is
   Began : array (Phase) of Time;
   Totals : array (Phase) of Duration := [others => 0.0];
   Counts : array (Phase) of Natural := [others => 0];
   procedure Start (P : Phase) is
   begin
      if Enabled then Began (P) := Clock; end if;
   end Start;
   procedure Stop (P : Phase) is
      Finished : constant Time := Clock;
   begin
      if Enabled then
         Totals (P) := Totals (P) + To_Duration (Finished - Began (P));
         Counts (P) := Counts (P) + 1;
      end if;
   end Stop;
   procedure Dump is
   begin
      for P in Phase loop
         Put_Line ("profile " & P'Image & " " & Totals (P)'Image & " " & Counts (P)'Image);
      end loop;
   end Dump;
end Movement_Profile;

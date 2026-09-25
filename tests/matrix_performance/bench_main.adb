with Ada.Command_Line;
with Interfaces.C; use Interfaces.C;
with Bench_Ada;
with Bench_Ada_Baseline;
procedure Bench_Main is
   function Driver (Backend, Op, NR, NC, NK, Reps, Pattern, Seed : int) return int
     with Import, Convention => C, External_Name => "bench_driver";
   Code : int;
begin
   if Ada.Command_Line.Argument_Count /= 8 then
      Ada.Command_Line.Set_Exit_Status (2); return;
   end if;
   Code := Driver
     (int'Value (Ada.Command_Line.Argument (1)), int'Value (Ada.Command_Line.Argument (2)),
      int'Value (Ada.Command_Line.Argument (3)), int'Value (Ada.Command_Line.Argument (4)),
      int'Value (Ada.Command_Line.Argument (5)), int'Value (Ada.Command_Line.Argument (6)),
      int'Value (Ada.Command_Line.Argument (7)), int'Value (Ada.Command_Line.Argument (8)));
   Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status (Code));
end Bench_Main;

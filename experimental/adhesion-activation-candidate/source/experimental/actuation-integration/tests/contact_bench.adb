with Ada.Command_Line;
with Interfaces.C; use Interfaces.C;
with Bench_Adapter;
procedure Contact_Bench is
   function Driver (Backend, Fixture, Steps, Repeats : int) return int
     with Import, Convention => C, External_Name => "contact_driver";
   Result : int;
begin
   Result := Driver (int'Value (Ada.Command_Line.Argument (1)),
                     int'Value (Ada.Command_Line.Argument (2)),
                     int'Value (Ada.Command_Line.Argument (3)),
                     int'Value (Ada.Command_Line.Argument (4)));
   if Result /= 0 then Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure); end if;
end Contact_Bench;

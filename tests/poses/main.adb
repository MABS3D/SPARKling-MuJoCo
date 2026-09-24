with Interfaces.C; use Interfaces.C;
with Ada.Command_Line;
with Adapter;
with MJ.Quaternions;
with MJ.Types;
procedure Main is
   function Driver (Backend, Op, Reps, Pattern : int) return int with
     Import, Convention => C, External_Name => "pose_driver";
   Result : int;
begin
   if MJ.Types.Real'Size /= 64 or else MJ.Quaternions.Quaternion'Size /= 256
     or else MJ.Quaternions.Vector_3'Size /= 192
     or else MJ.Quaternions.Matrix_3'Size /= 576
   then
      raise Program_Error with "C fixture requires contiguous binary64 storage";
   end if;
   if Ada.Command_Line.Argument_Count /= 4 then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;
   Result := Driver (int'Value (Ada.Command_Line.Argument (1)),
      int'Value (Ada.Command_Line.Argument (2)), int'Value (Ada.Command_Line.Argument (3)),
      int'Value (Ada.Command_Line.Argument (4)));
   Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status (Result));
end Main;

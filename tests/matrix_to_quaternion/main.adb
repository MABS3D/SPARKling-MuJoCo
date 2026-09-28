with Ada.Command_Line;
with Ada.Assertions;
with Interfaces.C; use Interfaces.C;
with Adapter;
with MJ.Quaternions; use MJ.Quaternions;
with MJ.Types;
procedure Main is
   function Driver (Mode, Backend, Reps, Pattern : int) return int with
     Import, Convention => C, External_Name => "matquat_driver";
   Result : int;
begin
   if MJ.Types.Real'Size /= 64 or else Quaternion'Size /= 256
     or else Matrix_3'Size /= 576
   then
      raise Program_Error with "C fixture requires contiguous binary64 storage";
   end if;
   if Ada.Command_Line.Argument_Count /= 4 then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;
   if Ada.Command_Line.Argument (1) = "2" then
      --  Run only in checked builds. All nine matrix components participate
      --  in the public domain precondition, including off-diagonal entries.
      for I in Axis loop
         for J in Axis loop
            for Sign in 0 .. 1 loop
               declare
                  A : Matrix_3 := [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]];
                  Q : Quaternion;
                  Status : Conversion_Status;
                  Rejected : Boolean := False;
               begin
                  A (I, J) := (if Sign = 0 then 1.1e10 else -1.1e10);
                  begin
                     From_Matrix (Q, A, Status);
                  exception
                     when Ada.Assertions.Assertion_Error => Rejected := True;
                  end;
                  if not Rejected then
                     raise Program_Error with "out-of-domain input accepted";
                  end if;
               end;
            end loop;
         end loop;
      end loop;
      return;
   end if;
   Result := Driver (int'Value (Ada.Command_Line.Argument (1)),
      int'Value (Ada.Command_Line.Argument (2)), int'Value (Ada.Command_Line.Argument (3)),
      int'Value (Ada.Command_Line.Argument (4)));
   Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status (Result));
end Main;

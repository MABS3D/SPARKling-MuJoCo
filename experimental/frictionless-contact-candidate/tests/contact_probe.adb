with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Contact_Rows; use MJ.Contact_Rows;
with MJ.Contact_Slider; use MJ.Contact_Slider;
procedure Contact_Probe is
   package F is new Ada.Text_IO.Float_IO (Real);
   package I is new Ada.Text_IO.Integer_IO (Integer);
   C : Configuration;
   S : State;
   E : Evaluation;
   Result : Status;
   Force : Real;
   Steps : Integer;
   procedure Get (X : out Real) is begin F.Get (X); end Get;
   procedure Put (X : Real) is begin F.Put (X, Fore => 1, Aft => 17, Exp => 3); Put (" "); end Put;
begin
   while not End_Of_File loop
      Get (C.Mass); Get (C.Radius); Get (C.Plane_Height); Get (C.Gravity); Get (C.H);
      Get (C.Margin); Get (C.Gap); Get (C.Solver.Time_Constant); Get (C.Solver.Damping_Ratio);
      Get (C.Solver.D0); Get (C.Solver.D_Width); Get (C.Solver.Width); Get (C.Solver.Midpoint);
      Get (S.Height); Get (S.Velocity); Get (S.Time); Get (Force); I.Get (Steps);
      if Steps = 0 then
         Evaluate (C, S, Force, E); Result := E.Result;
      else
         for K in 1 .. Steps loop
            Step (C, S, Force, E, Result);
            exit when Result /= Success;
         end loop;
      end if;
      I.Put (Status'Pos (Result), Width => 0); Put (" ");
      I.Put (Boolean'Pos (E.Info.Contact), Width => 0); Put (" ");
      I.Put (Boolean'Pos (E.Info.Active), Width => 0); Put (" ");
      Put (S.Height); Put (S.Velocity); Put (S.Time);
      Put (E.Info.Distance); Put (E.Info.Row.Impedance); Put (E.Info.Row.K); Put (E.Info.Row.B);
      Put (E.Info.Row.R); Put (E.Info.Row.AR); Put (E.Info.Row.Aref); Put (E.Info.Row.Force);
      Put (E.Info.Row.Acceleration); New_Line;
   end loop;
end Contact_Probe;

with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Activation;
with MJ.Adhesive_Slider; use MJ.Adhesive_Slider;
with MJ.Contact_Slider;
procedure Adhesive_Probe is
   use type MJ.Contact_Slider.Status;
   package F is new Ada.Text_IO.Float_IO (Real);
   package I is new Ada.Text_IO.Integer_IO (Integer);
   C : Configuration;
   S : State;
   E : Evaluation;
   Result : Status;
   U,Applied,Tau_Input : Real;
   Steps,Kind : Integer;
   procedure Get (X : out Real) is begin F.Get (X); end Get;
   procedure Get_B (X : out Boolean) is N : Integer; begin I.Get (N); X := N /= 0; end Get_B;
   procedure Put (X : Real) is begin F.Put (X,Fore=>1,Aft=>17,Exp=>3);Put (" ");end Put;
begin
   while not End_Of_File loop
      Get (C.Motion.Mass);Get (C.Motion.Radius);Get (C.Motion.Plane_Height);Get (C.Motion.Gravity);Get (C.Motion.H);
      Get (C.Motion.Margin);Get (C.Motion.Gap);Get (C.Motion.Solver.Time_Constant);Get (C.Motion.Solver.Damping_Ratio);
      Get (C.Motion.Solver.D0);Get (C.Motion.Solver.D_Width);Get (C.Motion.Solver.Width);Get (C.Motion.Solver.Midpoint);
      I.Get (Kind);C.Kind := MJ.Activation.Dynamics'Val (Kind);Get (Tau_Input);C.Tau:=Real'Max (1.0e-15,Tau_Input);
      C.Factor:=MJ.Activation.Exact_Factor (C.Motion.H,C.Tau);
      Get (C.Gain);Get_B (C.Enabled);Get_B (C.Clamp_Control);Get_B (C.Early);Get_B (C.Control_Limited);
      Get (C.Control_Lower);Get (C.Control_Upper);Get_B (C.Activation_Limited);Get (C.Activation_Lower);Get (C.Activation_Upper);
      Get_B (C.Force_Limited);Get (C.Force_Lower);Get (C.Force_Upper);
      Get (S.Motion.Height);Get (S.Motion.Velocity);Get (S.Motion.Time);Get (S.Act);Get (U);Get (Applied);I.Get (Steps);
      if Steps=0 then Evaluate (C,S,U,Applied,E);Result:=E.Result;
      else for K in 1 .. Steps loop Step (C,S,U,Applied,E,Result);exit when Result/=MJ.Contact_Slider.Success;end loop;end if;
      I.Put (MJ.Contact_Slider.Status'Pos (Result),Width=>0);Put (" ");
      I.Put (Boolean'Pos (E.Motion.Info.Contact),Width=>0);Put (" ");
      I.Put (Boolean'Pos (E.Motion.Info.Active),Width=>0);Put (" ");
      Put (S.Motion.Height);Put (S.Motion.Velocity);Put (S.Motion.Time);Put (S.Act);Put (E.Dot);
      Put (E.Force);Put (E.Moment);Put (E.Generalized);Put (E.Total_Applied);Put (E.Motion.Info.Row.Acceleration);
      Put (E.Motion.Info.Row.Force);New_Line;
   end loop;
end Adhesive_Probe;

with Ada.Command_Line;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Elastic_Network; use MJ.Elastic_Network;
with MJ.Flex_Contact_Kernels; use MJ.Flex_Contact_Kernels;
with MJ.Flex_Contact_Network; use MJ.Flex_Contact_Network;
with MJ.Flex_Contact_Filter;

procedure Flex_Contact_Probe is
   package RIO is new Ada.Text_IO.Float_IO (Real);
   N, M, Steps, Pin, A, B : Integer;
   C : Configuration;
   Dt : Time_Step;
   Gravity : Input_Vector;
   Result : MJ.Flex_Contact_Network.Status;
   procedure Read_Vector (V : out Input_Vector) is
   begin
      for K in Axis loop RIO.Get (V (K)); end loop;
   end Read_Vector;
   procedure Put_Real (X : Real) is
   begin
      Put (" "); RIO.Put (X, Fore => 1, Aft => 17, Exp => 3);
   end Put_Real;
begin
   if Ada.Command_Line.Argument_Count > 0 and then Ada.Command_Line.Argument (1) = "filter" then
      Ada.Integer_Text_IO.Get (N);
      declare
         use MJ.Flex_Contact_Filter;
         S : State (Integer'Max (1, N)) :=
           (Capacity => Integer'Max (1, N), Used => N, Items => [others => <>],
            Marked => [others => False], Minima => [others => 1.0e10], Best => 0, Kept => 0);
      begin
         for I in 1 .. N loop
            S.Items (I).Id := I;
            RIO.Get (S.Items (I).Separation);
            for K in Axis loop RIO.Get (S.Items (I).Position (K)); end loop;
         end loop;
         Reduce (S);
         Put ("selected");
         for I in 1 .. S.Kept loop Put (S.Items (I).Id'Image); end loop;
         New_Line;
      end;
      return;
   end if;
   Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (M);
   Ada.Integer_Text_IO.Get (Steps); RIO.Get (Dt); Read_Vector (Gravity);
   Read_Vector (C.Origin);
   for K in Axis loop RIO.Get (C.Normal (K)); end loop;
   RIO.Get (C.Radius); RIO.Get (C.Margin); RIO.Get (C.Gap);
   RIO.Get (C.Solver.Time_Constant); RIO.Get (C.Solver.Damping_Ratio);
   RIO.Get (C.Solver.D0); RIO.Get (C.Solver.D_Width);
   RIO.Get (C.Solver.Width); RIO.Get (C.Solver.Midpoint);
   declare
      P : Particle_Array (1 .. N);
      E : Edge_Array (1 .. M);
      Applied : Input_Array (P'Range);
      Info : Evaluation_Array (P'Range);
      Samples : constant Natural := (if Ada.Command_Line.Argument_Count = 0 then 0
        else Natural'Value (Ada.Command_Line.Argument (1)));
      T0, T1 : Ada.Real_Time.Time;
      Initial : Particle_Array (P'Range);
   begin
      for V in P'Range loop
         RIO.Get (P (V).Mass); Ada.Integer_Text_IO.Get (Pin);
         P (V).Pinned := Pin /= 0;
         Read_Vector (P (V).Position); Read_Vector (P (V).Velocity);
         Read_Vector (Applied (V));
      end loop;
      for I in E'Range loop
         Ada.Integer_Text_IO.Get (A); Ada.Integer_Text_IO.Get (B);
         E (I).A := A; E (I).B := B;
         RIO.Get (E (I).Rest); RIO.Get (E (I).Stiffness); RIO.Get (E (I).Damping);
      end loop;
      if not Valid (P, E) or else not Valid (C) then
         Put_Line ("invalid topology"); return;
      end if;
      Evaluate (C, P, E, Applied, Gravity, Dt, Info, Result);
      Put_Line ("evaluate " & Result'Image);
      for V in P'Range loop
         Put ("contact");
         Put_Real (Real (Boolean'Pos (Info (V).Contact)));
         Put_Real (Real (Boolean'Pos (Info (V).Active)));
         Put_Real (Info (V).Separation); Put_Real (Info (V).Force); New_Line;
         Put_Line ("rank " & Info (V).Retained_Rank'Image);
         Put ("acceleration"); for X of Info (V).Acceleration loop Put_Real (X); end loop; New_Line;
      end loop;
      Initial := P;
      for Sample in 0 .. Samples loop
      P := Initial;
      T0 := Clock;
      for I in 1 .. Steps loop
         if Samples > 0 then
            Step (C, P, E, Applied, Gravity, Dt, Info, Result);
            if Result /= MJ.Flex_Contact_Network.Success then raise Program_Error with "benchmark step failed"; end if;
         else
         declare
            Before : constant Particle_Array := P;
         begin
            Step (C, P, E, Applied, Gravity, Dt, Info, Result);
            if Result /= MJ.Flex_Contact_Network.Success then
               if P /= Before then raise Program_Error with "failure changed state"; end if;
               Put_Line ("step " & Result'Image); exit;
            end if;
         end;
         end if;
      end loop;
      T1 := Clock;
      if Samples > 0 and then Sample > 0 then
         Put ("timing"); Put_Real (Real (To_Duration (T1 - T0))); New_Line;
      end if;
      end loop;
      Put_Line ("step " & Result'Image);
      for V in P'Range loop
         Put ("position"); for X of P (V).Position loop Put_Real (X); end loop; New_Line;
         Put ("velocity"); for X of P (V).Velocity loop Put_Real (X); end loop; New_Line;
      end loop;
   end;
end Flex_Contact_Probe;

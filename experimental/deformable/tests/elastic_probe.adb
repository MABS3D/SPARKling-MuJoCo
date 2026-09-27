with Ada.Command_Line;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Elastic_Network; use MJ.Elastic_Network;

procedure Elastic_Probe is
   package RIO is new Ada.Text_IO.Float_IO (Real);
   N, M, Steps, Pin, A, B : Integer;
   Dt : Time_Step;
   Gravity : Input_Vector;
   Result : Status;
   procedure Read_Vector (V : out Input_Vector) is
   begin
      for K in Axis loop RIO.Get (V (K)); end loop;
   end Read_Vector;
   procedure Put_Real (X : Real) is
   begin
      Put (" "); RIO.Put (X, Fore => 1, Aft => 17, Exp => 3);
   end Put_Real;
begin
   Ada.Integer_Text_IO.Get (N); Ada.Integer_Text_IO.Get (M);
   Ada.Integer_Text_IO.Get (Steps); RIO.Get (Dt); Read_Vector (Gravity);
   declare
      P : Particle_Array (1 .. N);
      E : Edge_Array (1 .. M);
      Applied : Input_Array (P'Range);
      F : Force_Array (P'Range);
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
      if not Valid (P, E) then
         Put_Line ("invalid topology"); return;
      end if;
      Forces (P, E, F, Result); Put_Line ("forces " & Result'Image);
      for V in P'Range loop
         Put ("spring"); for X of F (V).Spring loop Put_Real (X); end loop; New_Line;
         Put ("damper"); for X of F (V).Damper loop Put_Real (X); end loop; New_Line;
      end loop;
      Initial := P;
      for Sample in 0 .. Samples loop
      P := Initial;
      T0 := Clock;
      for I in 1 .. Steps loop
         if Samples > 0 then
            Step (P, E, Applied, Gravity, Dt, Result);
            if Result /= Success then raise Program_Error with "benchmark step failed"; end if;
         else
         declare
            Before : constant Particle_Array := P;
         begin
            Step (P, E, Applied, Gravity, Dt, Result);
            if Result /= Success then
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
end Elastic_Probe;

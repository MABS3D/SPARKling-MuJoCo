with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Command_Line;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Elastic_Network; use MJ.Elastic_Network;
with MJ.Elastic_Contacts; use MJ.Elastic_Contacts;
with MJ.Elastic_Coordinates; use MJ.Elastic_Coordinates;

procedure Elastic_Contact_Probe is
   package RIO is new Ada.Text_IO.Float_IO (Real);
   procedure Get (X : out Integer) is
   begin Ada.Integer_Text_IO.Get (X); end Get;
   procedure Get (X : out Real) is
   begin RIO.Get (X); end Get;
   procedure Get_Vector (X : out Input_Vector) is
   begin for K in X'Range loop Get (X (K)); end loop; end Get_Vector;
   procedure Put_Real (X : Real) is
   begin Put (" "); RIO.Put (X, Fore => 1, Aft => 17, Exp => 3); end Put_Real;
   N, M, NB, NG, Steps, Flag : Integer;
   Dt : Time_Step;
   Gravity : Input_Vector;
   Options : Settings;
begin
   Get (N); Get (M); Get (NB); Get (NG); Get (Steps); Get (Dt); Get_Vector (Gravity);
   Get (Options.Radius); Get (Flag); Options.Self_Collision := Flag /= 0;
   Get (Options.Iterations); Get (Options.Tolerance);
   Get (Options.Contact.Time_Constant); Get (Options.Contact.Damping_Ratio);
   Get (Options.Contact.D0); Get (Options.Contact.D_Width); Get (Options.Contact.Width); Get (Options.Contact.Midpoint);
   declare
      P : Particle_Array (1 .. N);
      E : Edge_Array (1 .. M);
      Bodies : Body_Array (1 .. NB);
      Links : Attachment_Array (1 .. N);
      Shapes : Shape_Array (1 .. NG);
      Applied : Input_Array (1 .. N);
      Applied_Bodies : Wrench_Array (1 .. NB);
      PC : Particle_Loads (1 .. N);
      BC : Body_Loads (1 .. NB);
      Info : Report (Workspace_Capacity (N, M, NG));
      Initial : Particle_Array (P'Range);
      Coordinates : Frame_Array (P'Range);
      Initial_Bodies : Body_Array (Bodies'Range);
      Samples : constant Natural := (if Ada.Command_Line.Argument_Count = 0 then 0
        else Natural'Value (Ada.Command_Line.Argument (1)));
      Start, Finish : Ada.Real_Time.Time;
   begin
      for I in P'Range loop
         Get (P (I).Mass); Get (Flag); P (I).Pinned := Flag /= 0;
         Get_Vector (P (I).Position); Get_Vector (P (I).Velocity); Get_Vector (Applied (I));
         Get (Links (I).Body_Number); Get_Vector (Links (I).Local_Point);
      end loop;
      for I in E'Range loop
         Get (E (I).A); Get (E (I).B); Get (E (I).Rest); Get (E (I).Stiffness); Get (E (I).Damping);
      end loop;
      for B in Bodies'Range loop
         Get (Bodies (B).Mass); Get (Flag); Bodies (B).Fixed := Flag /= 0;
         for K in Axis loop Get (Bodies (B).Inertia (K)); end loop;
         Get_Vector (Bodies (B).Position); Get_Vector (Bodies (B).Velocity); Get_Vector (Bodies (B).Omega);
         for K in Quaternion'Range loop Get (Bodies (B).Orientation (K)); end loop;
         Get_Vector (Applied_Bodies (B).Force); Get_Vector (Applied_Bodies (B).Torque);
      end loop;
      for G in Shapes'Range loop
         Get (Flag); Shapes (G).Kind := Shape_Kind'Val (Flag);
         Get (Shapes (G).Body_Number); Get_Vector (Shapes (G).Center); Get_Vector (Shapes (G).Direction);
         Get (Shapes (G).Radius); Get (Shapes (G).Half_Length);
      end loop;
      Initial := P; Initial_Bodies := Bodies;
      for Sample in 0 .. Samples loop
         P := Initial; Bodies := Initial_Bodies;
         Reset (P, Coordinates);
         Start := Clock;
         for S in 1 .. Steps loop
            declare
               Before : constant Particle_Array := P;
               Before_Bodies : constant Body_Array := Bodies;
               Before_Coordinates : constant Frame_Array := Coordinates;
            begin
               Step (P, Coordinates, E, Bodies, Links, Shapes, Applied, Applied_Bodies, Gravity, Dt, Options, PC, BC, Info);
               if Info.Result /= Success then
                  if P /= Before or else Bodies /= Before_Bodies or else Coordinates /= Before_Coordinates
                    or else (for some F of PC => F /= Zero)
                    or else (for some F of BC => F /= (Zero, Zero))
                  then raise Program_Error with "failed step did not roll back"; end if;
                  exit;
               end if;
            end;
         end loop;
         Finish := Clock;
         if Sample > 0 then Put ("timing"); Put_Real (Real (To_Duration (Finish-Start))); New_Line; end if;
      end loop;
      Put_Line ("status " & Info.Result'Image);
      Put_Line ("count" & Info.Count'Image);
      Put ("solver"); Put_Real (Real (Info.Iterations)); Put_Real (Info.Residual); New_Line;
      for C in 1 .. Info.Count loop
         Put ("contact"); Put_Real (Info.Contacts (C).Distance); Put_Real (Info.Contacts (C).Force);
         for X of Info.Contacts (C).Point loop Put_Real (X); end loop;
         for X of Info.Contacts (C).Normal loop Put_Real (X); end loop; New_Line;
      end loop;
      for I in P'Range loop
         Put ("coordinate"); for X of Coordinates (I).Offset loop Put_Real (X); end loop; New_Line;
         Put ("position"); for X of P (I).Position loop Put_Real (X); end loop; New_Line;
         Put ("velocity"); for X of P (I).Velocity loop Put_Real (X); end loop; New_Line;
         Put ("particle_contact"); for X of PC (I) loop Put_Real (X); end loop; New_Line;
      end loop;
      for B in Bodies'Range loop
         Put ("body_position"); for X of Bodies (B).Position loop Put_Real (X); end loop; New_Line;
         Put ("body_velocity"); for X of Bodies (B).Velocity loop Put_Real (X); end loop; New_Line;
         Put ("body_omega"); for X of Bodies (B).Omega loop Put_Real (X); end loop; New_Line;
         Put ("body_quaternion"); for X of Bodies (B).Orientation loop Put_Real (X); end loop; New_Line;
         Put ("body_force"); for X of BC (B).Force loop Put_Real (X); end loop; New_Line;
         Put ("body_torque"); for X of BC (B).Torque loop Put_Real (X); end loop; New_Line;
      end loop;
   end;
end Elastic_Contact_Probe;

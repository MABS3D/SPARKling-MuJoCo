with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with System.Machine_Code; use System.Machine_Code;
with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
with MJ.Actuator_Curves; use MJ.Actuator_Curves;
with MJ.Transmissions; use MJ.Transmissions;
with MJ.Actuator_Transmissions;
with MJ.Advanced_Actuators;
procedure Actuation_Bench is
   package FIO is new Float_IO (Real);
   package TT renames MJ.Actuator_Transmissions;
   package AA renames MJ.Advanced_Actuators;
   Input_File : File_Type;
   function Read return Real is
      R : Real;
   begin FIO.Get (Input_File,R); return R; end Read;
   function Read_Vector return Vector is
      R : Vector;
   begin for X of R loop X := Read; end loop; return R; end Read_Vector;
   function Read_Quaternion return Quaternion is
      R : Quaternion;
   begin for X of R loop X := Read; end loop; return R; end Read_Quaternion;
   function Read_Params return Parameters is
      R : Parameters;
   begin for X of R loop X := Read; end loop; return R; end Read_Params;
   procedure Emit (X : Real) is
   begin FIO.Put (X,Fore=>1,Aft=>17,Exp=>3); Put (' '); end Emit;
   Steps : constant Positive := Positive'Value (Argument (2));
   Samples : constant Positive := Positive'Value (Argument (3));
   Warmups : constant Natural := Natural'Value (Argument (4));
begin
   Open (Input_File,In_File,Argument (1));
   declare
      NV : constant Positive := Positive (Read);
      NA : constant Positive := Positive (Read);
      NF : constant Positive := Positive (Read);
      NO : constant Positive := Positive (Read);
      type Row_Access is access Row;
      type Actor is record
         Trn, Model : Natural;
         Kind : Joint_Kind;
         Start : Dof;
         In_Parent : Boolean;
         Position : Input;
         Orientation : Quaternion;
         Gear : TT.Gear_Vector;
         Gain, Dyn, Bias : Parameters;
         U : AA.Servo_Input;
         H : Positive_Real;
         Period : Nonneg_Tier0;
         Early, Force_Limited : Boolean;
         Lower, Upper, Range_Lo, Range_Hi, Acceleration : Input;
         State : AA.State;
         P, RP, Axis, Displacement : Vector := Zero;
         M, RM : Matrix := (others => (others => 0.0));
         Q, RQ : Quaternion := Identity;
         JP, JR, JRP, JRR : TT.Jacobian (0 .. 2,0 .. NV-1) := (others => (others => 0.0));
         Common : Mask (0 .. NV-1) := (others => False);
         Reference : Boolean := False;
         Rod : Input := 0.0;
         Tendon_Row : Row_Access := null;
         Tendon_Length : Input := 0.0;
         Active, Gap : Dense_Row (0 .. NV-1) := (others => 0.0);
         Contacts : MJ.Transmissions.Count := 0;
      end record;
      type Actors is array (Natural range <>) of Actor;
      type Frame is record
         Velocity : Real_Array (0 .. NV-1);
         A : Actors (0 .. NA-1);
      end record;
      type Frames is array (Natural range <>) of Frame;
      Inputs : Frames (0 .. NF-1);
      Lengths, Velocities, Forces : Real_Array (0 .. NO-1) := (others => 0.0);
      Dots, Nexts : Real_Array (0 .. 5*NA-1) := (others => 0.0);
      Generalized : Real_Array (0 .. NV-1) := (others => 0.0);
      Row_N, Row_A : array (Natural range 0 .. NO-1) of Natural;
      Columns : array (Natural range 0 .. 3*NV*NA-1) of Natural;
      Moments : Real_Array (0 .. 3*NV*NA-1);
      Sink : Real := 0.0;
      procedure Read_Jac (J : out TT.Jacobian) is
      begin for I in 0 .. 2 loop for K in 0 .. NV-1 loop J (I,K) := Read; end loop; end loop; end Read_Jac;
      procedure Stage (F : Frame) is
         O, Adr : Natural := 0;
      begin
         Generalized := (others => 0.0);
         for Index in F.A'Range loop
            declare
               C : Actor renames F.A (Index);
               R : TT.Result;
               V, Force : Vector := Zero;
               Pid : AA.PID_Result;
               Motor : AA.DC_Result;
               Activation, Derivative : Real;
            begin
               case C.Trn is
                  when 0 => R := TT.Joint (C.Kind,NV,C.Start,C.Position,C.Orientation,C.Gear,C.In_Parent,C.Model>=4);
                  when 1 => R := TT.Tendon (C.Tendon_Length,C.Tendon_Row.all,C.Gear (0));
                  when 2 => R := TT.Site (C.P,C.RP,C.M,C.RM,C.Q,C.RQ,C.JP,C.JR,C.JRP,C.JRR,
                     C.Common,C.Gear,C.Reference,C.Model>=4);
                  when 3 => R := TT.Slidercrank (C.Axis,C.Displacement,C.JP,C.JR,C.Rod,C.Gear (0));
                  when 4 => R := TT.Body_Adhesion (C.Active,C.Gap,C.Contacts);
                  when others => raise Constraint_Error;
               end case;
               if not R.Accepted then raise Constraint_Error with "transmission rejected"; end if;
               for K in 0 .. R.Nout-1 loop V (K) := Velocity (R.Moments (K),F.Velocity); end loop;
               case C.Model is
                  when 0 => Force (0) := C.Gain (0)*C.U.Position+Affine (C.Bias,R.Length (0),V (0));
                  when 1 =>
                     Derivative := Muscle_Derivative (C.U.Position,C.State (0),C.Dyn);
                     Activation := C.State (0)+Derivative*C.H;
                     Activation := Real'Min (1.0,Real'Max (0.0,Activation));
                     Dots (5*Index) := Derivative; Nexts (5*Index) := Activation;
                     Force (0) := AA.Muscle_Force (R.Length (0),V (0),C.Range_Lo,C.Range_Hi,C.Acceleration,
                        (if C.Early then Activation else C.State (0)),C.Gain,C.Bias);
                  when 2 =>
                     Pid := AA.PID (C.U,R.Length (0),V (0),C.State (0),
                       (if C.Dyn (1)>0.0 then C.State (1) else C.State (0)),C.H,C.Period,C.Dyn,C.Gain,C.Bias,C.Early);
                     Force (0) := Pid.Force;
                     if C.Dyn (1)>0.0 then
                        Dots (5*Index) := Pid.Slew_Dot;
                        Nexts (5*Index) := C.State (0)+Pid.Slew_Dot*C.H;
                     end if;
                     if C.Gain (0)>0.0 then
                        Dots (5*Index+Boolean'Pos (C.Dyn (1)>0.0)) := Pid.Integral_Dot;
                        Nexts (5*Index+Boolean'Pos (C.Dyn (1)>0.0)) := Pid.Next_Integral;
                     end if;
                  when 3 =>
                     Motor := AA.DC (C.U,R.Length (0),V (0),C.State,C.H,C.Dyn,C.Gain,C.Bias,C.Early,C.Force_Limited,C.Lower,C.Upper);
                     Force (0) := Motor.Force;
                     for K in 0 .. 4 loop Dots (5*Index+K) := Motor.Dot (K); Nexts (5*Index+K) := Motor.Next (K); end loop;
                  when 4 => Force := AA.SO3 ((C.U.Position,C.U.Velocity,C.U.Feedforward,C.U.Voltage),
                     R.Length,V,C.Gain,C.Bias,C.Force_Limited,Real'Max (0.0,C.Upper));
                  when 5 => Force := AA.SO3_Expmap ((C.U.Position,C.U.Velocity,C.U.Feedforward),
                     R.Length,V,C.Gain,C.Bias,C.Force_Limited,Real'Max (0.0,C.Upper));
                  when others => raise Constraint_Error;
               end case;
               if C.Model<3 and then C.Force_Limited then Force (0) := Real'Min (C.Upper,Real'Max (C.Lower,Force (0))); end if;
               for K in 0 .. R.Nout-1 loop
                  Lengths (O) := R.Length (K); Velocities (O) := V (K); Forces (O) := Force (K);
                  Row_N (O) := R.Moments (K).N; Row_A (O) := Adr;
                  for J in 0 .. Integer (R.Moments (K).N)-1 loop
                     Columns (Adr) := R.Moments (K).Col (J); Moments (Adr) := R.Moments (K).Val (J); Adr := Adr+1;
                  end loop;
                  Project (R.Moments (K),Force (K),Generalized); O := O+1;
               end loop;
            end;
         end loop;
         if O/=NO then raise Constraint_Error; end if;
      end Stage;
   begin
      for F of Inputs loop
         for X of F.Velocity loop X := Read; end loop;
         for C of F.A loop
            C.Trn := Natural (Read); C.Model := Natural (Read); C.Kind := Joint_Kind'Val (Integer (Read));
            C.Start := Dof (Read); C.In_Parent := Read/=0.0;
            C.Position := Read; C.Orientation := Read_Quaternion;
            for X of C.Gear loop X := Read; end loop;
            C.Gain := Read_Params; C.Dyn := Read_Params; C.Bias := Read_Params;
            C.U.Position := Read; C.U.Velocity := Read; C.U.Feedforward := Read; C.U.Voltage := Read;
            declare Flags : constant Natural := Natural (Read); begin
               C.U.Has_Position := Flags mod 2=1; C.U.Has_Velocity := (Flags/2) mod 2=1;
               C.U.Has_Feedforward := (Flags/4) mod 2=1; C.U.Has_Voltage := (Flags/8) mod 2=1;
            end;
            C.H := Read; C.Period := Read; C.Early := Read/=0.0; C.Force_Limited := Read/=0.0;
            C.Lower := Read; C.Upper := Read; C.Range_Lo := Read; C.Range_Hi := Read; C.Acceleration := Read;
            for X of C.State loop X := Read; end loop;
            case C.Trn is
               when 1 =>
                  C.Tendon_Length := Read; C.Tendon_Row := new Row;
                  C.Tendon_Row.N := MJ.Transmissions.Count (Read);
                  for K in 0 .. Integer (C.Tendon_Row.N)-1 loop C.Tendon_Row.Col (K) := Dof (Read); C.Tendon_Row.Val (K) := Read; end loop;
               when 2 =>
                  C.P := Read_Vector; C.RP := Read_Vector;
                  for I in 0 .. 2 loop for J in 0 .. 2 loop C.M (I,J) := Read; end loop; end loop;
                  for I in 0 .. 2 loop for J in 0 .. 2 loop C.RM (I,J) := Read; end loop; end loop;
                  C.Q := Read_Quaternion; C.RQ := Read_Quaternion;
                  Read_Jac (C.JP); Read_Jac (C.JR); Read_Jac (C.JRP); Read_Jac (C.JRR);
                  for X of C.Common loop X := Read/=0.0; end loop;
                  C.Reference := Read/=0.0;
               when 3 => C.Axis := Read_Vector; C.Displacement := Read_Vector; C.Rod := Read; Read_Jac (C.JP); Read_Jac (C.JR);
               when 4 =>
                  for X of C.Active loop X := Read; end loop;
                  for X of C.Gap loop X := Read; end loop;
                  C.Contacts := MJ.Transmissions.Count (Read);
               when others => null;
            end case;
         end loop;
      end loop;
      Close (Input_File);
      for K in Inputs'Range loop
         Stage (Inputs (K)); Put ("frame "); Put (Natural'Image (K)); Put (' ');
         for X of Lengths loop Emit (X); end loop; for X of Velocities loop Emit (X); end loop;
         for X of Forces loop Emit (X); end loop; for X of Dots loop Emit (X); end loop;
         for X of Nexts loop Emit (X); end loop; for X of Generalized loop Emit (X); end loop;
         for O in Row_N'Range loop Emit (Real (Row_N (O)));
            for J in Row_A (O) .. Integer (Row_A (O)+Row_N (O))-1 loop Emit (Real (Columns (J))); Emit (Moments (J)); end loop;
         end loop;
         New_Line;
      end loop;
      for Run in 0 .. Warmups+Samples-1 loop
         declare Start_Time : constant Time := Clock; Stop_Time : Time; begin
            for K in 0 .. Steps-1 loop
               Asm ("",Clobber=>"memory",Volatile=>True);
               Stage (Inputs (K mod NF));
               Sink := Sink+Forces (0)+Generalized (NV-1)+Nexts (5*NA-1);
            end loop;
            Stop_Time := Clock;
            if Run>=Warmups then Put ("sample "); Emit (Real (To_Duration (Stop_Time-Start_Time))); New_Line; end if;
         end;
      end loop;
      Put ("sink "); Emit (Sink); New_Line;
   end;
end Actuation_Bench;

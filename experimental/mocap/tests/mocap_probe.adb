with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Exceptions;
with Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Mocap_Test;
with MJ.Data.Kinematics;
with MJ.Data.Forward;
with MJ.Data.Euler;
with MJ.Data.Constrained;
procedure Mocap_Probe is
   use type Ada.Real_Time.Time;
   use type Ada.Real_Time.Time_Span;
   package IO is new Ada.Text_IO.Float_IO (Real);
   package C renames MJ.Data.Constrained;
   M : MJ.Models.Model;
   D : Simulation;
   type Engine_Access is access C.Engine;
   E : Engine_Access := new C.Engine;
   Constrained : constant Boolean := Ada.Command_Line.Argument (2) = "constrained";
   Load : MJ.Fields.Load_Result;
   Result : Status;
   Nb, Nv, Nm, Nq : Natural;
   Samples, Steps : Integer;
   Benchmark : constant Boolean := Ada.Command_Line.Argument_Count > 2;
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
   procedure Values (Name : String; V : Real_Array) is
   begin
      Put (Name);
      for X of V loop Put (' '); IO.Put (X, Fore => 1, Aft => 17, Exp => 3); end loop;
      New_Line;
   end Values;
   procedure Input (V : out State_Vector) is
      X : Real;
   begin
      for I in V'Range loop IO.Get (X); V (I) := Tier0_Real (X); end loop;
   end Input;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Load);
   if Load.Status /= OK then raise Program_Error with "load"; end if;
   Nb := M.S.Nbody; Nv := M.S.Nv; Nq := M.S.Nq; Nm := M.S.Nmocap;
   declare
      Flags : constant Integer := M.Opt.Disableflags;
   begin
      if Flags mod 2 = 0 then M.Opt.Disableflags := Flags + 1; end if;
      MJ.Data.Create (M, D, Result); Check;
      declare
         Dynamics : Simulation;
         First_Mocap : Integer := -1;
      begin
         MJ.Data.Mocap_Test.Create_Dynamics (M, Dynamics, Result); Check;
         if Mocap_Values (Dynamics) /= Mocap_Values (D) then
            raise Program_Error with "dynamics mocap reset";
         end if;
         Free (Dynamics);
         if Nm > 1 then
            for B in M.Bodies.Body_Mocapid'Range loop
               if M.Bodies.Body_Mocapid (B) >= 0 then
                  if First_Mocap < 0 then
                     First_Mocap := B;
                  else
                     declare
                        Original : constant Integer := M.Bodies.Body_Mocapid (B);
                     begin
                        M.Bodies.Body_Mocapid (B) := M.Bodies.Body_Mocapid (First_Mocap);
                        MJ.Data.Mocap_Test.Create_Dynamics (M, Dynamics, Result);
                        M.Bodies.Body_Mocapid (B) := Original;
                        if Result /= Invalid_Model or else not Is_Empty (Dynamics) then
                           raise Program_Error with "duplicate mocap mapping";
                        end if;
                     end;
                     exit;
                  end if;
               end if;
            end loop;
         end if;
      end;
      M.Opt.Disableflags := Flags;
   end;
   if Constrained then C.Create (M, E.all, Result); Check; end if;
   MJ.Models.Free (M);
   Ada.Integer_Text_IO.Get (Samples); Ada.Integer_Text_IO.Get (Steps);
   for Sample in 1 .. Samples loop
      declare
         Q : State_Vector (0 .. Integer (Nq) - 1);
         V : State_Vector (0 .. Integer (Nv) - 1);
         P : State_Vector (10 .. 12) := [others => 0.0];
         Quat : State_Vector (20 .. 23) := [1.0, 0.0, 0.0, 0.0];
      begin
         Input (Q); Input (V);
         Set_State (D, Q, V, 0.0, Result); Check;
         if Constrained then C.Set_State (E.all, Q, V, 0.0, Result); Check; end if;
         for Id in 0 .. Integer (Nm) - 1 loop
            Input (P); Input (Quat);
            Set_Mocap (D, Id, P, Quat, Result); Check;
            if Constrained then C.Set_Mocap (E.all, Id, P, Quat, Result); Check; end if;
         end loop;
         MJ.Data.Kinematics.Update (D, Result); Check;
         declare
            Before : constant Real_Array := Complete_State_Values (D);
            Was_Current : constant Boolean := Positions_Current (D);
         begin
            Set_Mocap (D, Nm, P, Quat, Result);
            if Result /= Invalid_Index or else Complete_State_Values (D) /= Before
              or else Positions_Current (D) /= Was_Current then raise Program_Error with "index atomicity"; end if;
            if Nm > 0 then
               Set_Mocap (D, 0, P, State_Vector'(2 .. 4 => 0.0), Result);
               if Result /= Invalid_Size or else Complete_State_Values (D) /= Before
                 or else Positions_Current (D) /= Was_Current then raise Program_Error with "size atomicity"; end if;
            end if;
         end;
         Values ("mocap", Mocap_Values (D));
         declare
            Poses : Real_Array (0 .. Integer (Nb) * 7 - 1);
         begin
            for B in 0 .. Nb - 1 loop
               Poses (7 * B .. 7 * B + 2) := Real_Array (Body_Position (D, B));
               Poses (7 * B + 3 .. 7 * B + 6) := Real_Array (Body_Orientation (D, B));
            end loop;
            Values ("poses", Poses);
         end;
         if Constrained then
            C.Evaluate (E.all, Result); Check;
            declare
               T : constant C.Trace := C.Diagnostics (E.all);
            begin
               Values ("counts", Real_Array'[Real (T.Ncontact), Real (T.Nrow)]);
               Values ("acc", Real_Array (T.Acceleration (1 .. Nv)));
            end;
         else
            MJ.Data.Forward.Evaluate (D, Result); Check;
            Values ("counts", Real_Array'[0.0, 0.0]);
            Values ("acc", [for I in 0 .. Integer (Nv) - 1 => Acceleration (D, I)]);
         end if;
         declare
            Start : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
         begin
            for S in 1 .. Steps loop
               if Constrained then C.Step (E.all, Result);
               else MJ.Data.Euler.Step (D, Result); end if;
               Check;
            end loop;
            if Benchmark then
               Values ("seconds", Real_Array'[Real (Ada.Real_Time.To_Duration (Ada.Real_Time.Clock - Start))]);
            end if;
         end;
         if Constrained then Values ("state", C.Complete_State (E.all));
         else Values ("state", Complete_State_Values (D)); end if;
      end;
   end loop;
   if Nm > 0 then
      declare
         Large_P : constant State_Vector (Integer'Last - 2 .. Integer'Last) := [1.0, 2.0, 3.0];
         Large_Q : constant State_Vector (Integer'Last - 3 .. Integer'Last) := [1.0, 0.0, 0.0, 0.0];
      begin
         Set_Mocap (D, 0, Large_P, Large_Q, Result); Check;
         if Mocap_Positions (D) (0 .. 2) /= Real_Array'[1.0, 2.0, 3.0]
           or else Mocap_Quaternions (D) (0 .. 3) /= Real_Array'[1.0, 0.0, 0.0, 0.0]
         then raise Program_Error with "large array origin"; end if;
      end;
   end if;
   Reset (D, Result); Check;
   Values ("reset", Mocap_Values (D));
   Free (D);
   if Mocap_Count (D) /= 0 or else Mocap_Values (D)'Length /= 0 then raise Program_Error with "free"; end if;
   Set_Mocap (D, 0, [1.0, 2.0, 3.0], [1.0, 0.0, 0.0, 0.0], Result);
   if Result /= Not_Allocated then raise Program_Error with "freed setter"; end if;
   if Constrained then C.Free (E.all, Result); Check; end if;
   Put_Line ("edges PASS");
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Mocap_Probe;

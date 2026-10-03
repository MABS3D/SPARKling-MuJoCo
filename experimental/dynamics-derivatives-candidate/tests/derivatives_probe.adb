with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data;
with MJ.External_Forces;
with MJ.Dynamics_Derivatives;

procedure Derivatives_Probe is
   package DD renames MJ.Dynamics_Derivatives;
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   use type MJ.Data.Status;
   use type DD.Matrix;
   use type DD.Backend;
   type Workspace_Access is access DD.Workspace;
   type Matrix_Access is access DD.Matrix;
   W : Workspace_Access := new DD.Workspace;
   M : MJ.Models.Model;
   Loaded : MJ.Fields.Load_Result;
   Result : MJ.Data.Status;
   Original_Flags : Integer;
   Original_Adhesion : Boolean;
   Mode : constant DD.Backend :=
     (if Ada.Command_Line.Argument (2) = "constrained" then DD.Constrained else DD.Smooth);
   Benchmark : constant Boolean := Ada.Command_Line.Argument_Count >= 3
     and then Ada.Command_Line.Argument (3) = "benchmark";
   procedure Check is
   begin
      if Result /= MJ.Data.Success then raise Program_Error with Result'Image; end if;
   end Check;
   procedure Emit (Name : String; Values : DD.Matrix) is
   begin
      Put (Name);
      for R in Values'Range (1) loop
         for C in Values'Range (2) loop
            Put (' '); Numbers.Put (Values (R, C), Fore => 1, Aft => 17, Exp => 3);
         end loop;
      end loop;
      New_Line;
   end Emit;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with Loaded.Status'Image; end if;
   Original_Flags := M.Opt.Disableflags; Original_Adhesion := M.Flg_Adhesion;
   DD.Create (M, W.all, Mode, Result); Check;
   if M.Opt.Disableflags /= Original_Flags or else M.Flg_Adhesion /= Original_Adhesion then
      raise Program_Error with "borrowed model flags changed";
   end if;
   declare
      D : constant DD.Dimensions := DD.Shape (W.all);
      Nb : constant Natural := M.S.Nbody;
      Nx : constant Natural := DD.State_Dimension (W.all);
      Q : DD.State_Vector (0 .. D.Nq - 1);
      V, Applied, Acc : DD.State_Vector (0 .. D.Nv - 1);
      Act : DD.State_Vector (0 .. D.Na - 1);
      Ctrl : DD.State_Vector (0 .. D.Nu - 1);
      Loads : MJ.External_Forces.Wrench_Array (0 .. Nb - 1);
      A : Matrix_Access := new DD.Matrix'(0 .. Nx - 1 => [0 .. Nx - 1 => -777.0]);
      B : Matrix_Access := new DD.Matrix'(0 .. Nx - 1 => [0 .. D.Nu - 1 => -777.0]);
      Sv, Pv, Fq, Fv, Fa : Matrix_Access;
      Mq : Matrix_Access;
      T, H, X : Real;
      Centered, Subtract, Cases : Integer;
   begin
      DD.Create (M, W.all, Mode, Result);
      if Result /= MJ.Data.Already_Allocated then raise Program_Error with "double create"; end if;
      MJ.Models.Free (M); -- scratch workspace must own every required field
      Sv := new DD.Matrix'(0 .. D.Nv - 1 => [0 .. D.Nv - 1 => -777.0]);
      Pv := new DD.Matrix'(Sv.all); Fq := new DD.Matrix'(Sv.all);
      Fv := new DD.Matrix'(Sv.all); Fa := new DD.Matrix'(Sv.all);
      Mq := new DD.Matrix'(0 .. D.Nv - 1 => [0 .. D.Nmass - 1 => -777.0]);
      Ada.Integer_Text_IO.Get (Cases);
      for Sample in 1 .. Cases loop
         Numbers.Get (T); Numbers.Get (H);
         Ada.Integer_Text_IO.Get (Centered); Ada.Integer_Text_IO.Get (Subtract);
         for Y of Q loop Numbers.Get (X); Y := X; end loop;
         for Y of V loop Numbers.Get (X); Y := X; end loop;
         for Y of Act loop Numbers.Get (X); Y := X; end loop;
         for Y of Ctrl loop Numbers.Get (X); Y := X; end loop;
         for Y of Applied loop Numbers.Get (X); Y := X; end loop;
         for Y of Acc loop Numbers.Get (X); Y := X; end loop;
         for L of Loads loop
            for I in 0 .. 2 loop Numbers.Get (X); L.Force (I) := X; end loop;
            for I in 0 .. 2 loop Numbers.Get (X); L.Torque (I) := X; end loop;
         end loop;
         -- Reported failures must preserve every output, including B.
         declare
            Empty : DD.State_Vector (1 .. 0);
            Before_A : constant DD.Matrix := A.all;
            Before_B : constant DD.Matrix := B.all;
         begin
            DD.Transition_FD (W.all, Empty, V, Act, Ctrl, Applied,
              T, H, Centered /= 0, A.all, B.all, Result, Loads);
            if Result /= MJ.Data.Invalid_Size or else A.all /= Before_A or else B.all /= Before_B then
               raise Program_Error with "invalid-size atomicity";
            end if;
            DD.Transition_FD (W.all, Q, V, Act, Ctrl, Applied,
              1.0e10, H, Centered /= 0, A.all, B.all, Result, Loads);
            if Result = MJ.Data.Success or else A.all /= Before_A or else B.all /= Before_B then
               raise Program_Error with "numeric-failure atomicity";
            end if;
         end;
         if Benchmark then
            declare Start : constant Ada.Real_Time.Time := Clock;
            begin
               for Repeat in 1 .. 32 loop
                  DD.Transition_FD (W.all, Q, V, Act, Ctrl, Applied,
                    T, H, Centered /= 0, A.all, B.all, Result, Loads); Check;
               end loop;
               Put ("seconds "); Numbers.Put (Real (To_Duration (Clock - Start)), Fore => 1, Aft => 17, Exp => 3);
               New_Line;
            end;
         else
            DD.Transition_FD (W.all, Q, V, Act, Ctrl, Applied,
              T, H, Centered /= 0, A.all, B.all, Result, Loads); Check;
         end if;
         Emit ("A", A.all); Emit ("B", B.all);
         DD.Velocity_FD (W.all, Q, V, Act, Ctrl, H, DD.Smooth_Force, Sv.all, Result); Check;
         DD.Velocity_FD (W.all, Q, V, Act, Ctrl, H, DD.Passive_Force, Pv.all, Result); Check;
         Emit ("smooth", Sv.all); Emit ("passive", Pv.all);
         DD.Inverse_FD (W.all, Q, V, Act, Ctrl, Acc, H, Subtract /= 0,
                       Fq.all, Fv.all, Fa.all, Mq.all, Result);
         Check; Emit ("Fq", Fq.all); Emit ("Fv", Fv.all); Emit ("Fa", Fa.all); Emit ("Mq", Mq.all);
      end loop;
      DD.Free (W.all); DD.Free (W.all);
      if DD.Ready (W.all) then raise Program_Error with "free"; end if;
   end;
exception when Error : others =>
   Put_Line (Ada.Exceptions.Exception_Information (Error));
   Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Derivatives_Probe;

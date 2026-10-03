with MJ.Integration_PCG.Testing;
with Ada.Command_Line; with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions; with MJ.Types; use MJ.Types;
with MJ.Fields; with MJ.Models; with MJ.MJB;
with MJ.Data; use MJ.Data; with MJ.Data.Integrators;
procedure Integrators_Probe is
   package F is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model; D : Simulation; Load : MJ.Fields.Load_Result;
   S : Status; Selected : MJ.Data.Integrators.Selection;
   Steps : constant Natural := Natural'Value (Ada.Command_Line.Argument (2));
   procedure Read (A : out State_Vector) is X : Real;
   begin for I in A'Range loop F.Get (X); A (I) := X; end loop; end Read;
   procedure Check is
   begin
      if S /= Success then raise Program_Error with S'Image; end if;
   end Check;
   Original : Integer;
begin
   MJ.Integration_PCG.Testing.Check_Reduction;
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Load);
   if Load.Status /= OK then raise Program_Error with "load"; end if;
   Original := M.Opt.Integrator;
   MJ.Data.Integrators.Create (M, D, Selected, S);
   if M.Opt.Integrator /= Original then raise Program_Error with "model option changed"; end if;
   Put_Line ("create " & S'Image);
   if S /= Success then return; end if;
   MJ.Models.Free (M);
   declare
      Q : State_Vector (0 .. Integer (Position_Count (D))-1);
      V, Applied : State_Vector (0 .. Integer (Velocity_Count (D))-1);
      Ctrl : State_Vector (0 .. Integer (Control_Count (D))-1);
      Act : State_Vector (0 .. Integer (Activation_Count (D))-1);
      T : Real;
   begin
      F.Get (T); Read (Q); Read (V); Read (Ctrl); Read (Applied); Read (Act);
      Set_State (D, Q, V, T, S); Check; Set_Activation (D, Act, S); Check;
      for I in Ctrl'Range loop Set_Control (D, I, Ctrl (I), S); Check; end loop;
      for I in Applied'Range loop Set_Applied_Force (D, I, Applied (I), S); Check; end loop;
      declare
         Before : constant Real_Array := Complete_State_Values (D);
         Inputs : constant Real_Array := Input_Values (D);
         Invalid : constant Real_Array (0 .. Velocity_Count (D)**2) := [others => 0.0];
      begin
         MJ.Data.Integrators.Step (D, Selected, S, Velocity_Jacobian => Invalid);
         if S /= Invalid_Size or else Before /= Complete_State_Values (D)
           or else Inputs /= Input_Values (D) then
            raise Program_Error with "invalid operator atomicity";
         end if;
      end;
      for I in 1 .. Steps loop
         MJ.Data.Integrators.Step (D, Selected, S);
         if S /= Success then Put_Line ("step " & S'Image); exit; end if;
      end loop;
      Put ("state");
      for X of Complete_State_Values (D) loop Put (' '); F.Put (X, Fore => 1, Aft => 17, Exp => 3); end loop;
      New_Line;
   end;
   Free (D); Free (D);
   if not Is_Empty (D) then raise Program_Error with "free"; end if;
   Put_Line ("edges PASS");
exception when E : others => Put_Line (Ada.Exceptions.Exception_Information (E)); Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Integrators_Probe;

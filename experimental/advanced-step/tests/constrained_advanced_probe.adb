with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;
with MJ.Fields;
with MJ.MJB;
with MJ.Models;
with MJ.Types; use MJ.Types;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained.Advanced;
with MJ.External_Forces;
procedure Constrained_Advanced_Probe is
   package A renames MJ.Data.Constrained.Advanced;
   package IO is new Ada.Text_IO.Float_IO (Real);
   package NI is new Ada.Text_IO.Integer_IO (Natural);
   type Engine_Access is access A.Engine;
   E : Engine_Access := new A.Engine;
   M : MJ.Models.Model;
   Load : MJ.Fields.Load_Result;
   Result : Status;
   Samples, Steps, Nb, Na : Natural;
   Clock, X : Real;
   Has_Loads : constant Boolean := Ada.Command_Line.Argument_Count > 1;
   procedure Emit (Tag : String; Values : Real_Array) is
   begin
      Put (Tag);
      for V of Values loop Put (" "); IO.Put (V,Fore=>1,Aft=>17,Exp=>3); end loop;
      New_Line;
   end Emit;
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 128), M, Load);
   if Load.Status /= OK then raise Program_Error with "load"; end if;
   Nb := M.S.Nbody; Na := M.S.Na;
   A.Create (M, E.all, Result);
   if Result /= Success then Put_Line ("create " & Result'Image); return; end if;
   A.Create (M, E.all, Result);
   if Result /= Already_Allocated then raise Program_Error with "double create"; end if;
   MJ.Models.Free (M);
   NI.Get (Samples);
   declare
      Q : State_Vector (0 .. Integer (A.Position_Count (E.all))-1);
      V : State_Vector (0 .. Integer (A.Velocity_Count (E.all))-1);
      Act : State_Vector (3 .. Integer (Na)+2);
      Loads : MJ.External_Forces.Wrench_Array (0 .. Nb-1);
   begin
      for S in 1 .. Samples loop
         NI.Get (Steps); IO.Get (Clock);
         for Z of Q loop IO.Get (X); Z := X; end loop;
         for Z of V loop IO.Get (X); Z := X; end loop;
         A.Reset (E.all, Result); Check;
         A.Set_State (E.all, Q, V, Clock, Result); Check;
         for I in 0 .. Integer (A.Control_Count (E.all))-1 loop IO.Get (X); A.Set_Control (E.all,I,X,Result); Check; end loop;
         for Z of Act loop IO.Get (X); Z := X; end loop;
         A.Set_Activation (E.all,Act,Result); Check;
         for I in 0 .. Integer (A.Velocity_Count (E.all))-1 loop IO.Get (X); A.Set_Applied (E.all,I,X,Result); Check; end loop;
         if Has_Loads then
            for W of Loads loop
               for Z of W.Force loop IO.Get (X); Z := X; end loop;
               for Z of W.Torque loop IO.Get (X); Z := X; end loop;
            end loop;
         end if;
         declare
            Before : constant Real_Array := A.State (E.all);
            Inputs : constant Real_Array := A.Inputs (E.all);
         begin
            if Has_Loads then A.Evaluate (E.all,Result,Loads); else A.Evaluate (E.all,Result); end if;
            Put_Line ("evaluate " & Result'Image);
            if Before /= A.State (E.all) or else Inputs /= A.Inputs (E.all) then raise Program_Error with "evaluate frame"; end if;
            Emit ("length",A.Lengths (E.all)); Emit ("velocity",A.Velocities (E.all));
            Emit ("force",A.Forces (E.all)); Emit ("qforce",A.Generalized (E.all));
            Emit ("acc",A.Accelerations (E.all)); Emit ("dot",A.Rates (E.all));
            for K in 1 .. Steps loop
               if Has_Loads then A.Step (E.all,Result,Loads); else A.Step (E.all,Result); end if;
               if Result /= Success then exit; end if;
            end loop;
            Put_Line ("step " & Result'Image); Emit ("state",A.State (E.all));
            if Result /= Success and then A.State (E.all) /= Before then raise Program_Error with "step atomicity"; end if;
         end;
      end loop;
   end;
   A.Free (E.all); A.Free (E.all);
   if A.Ready (E.all) then raise Program_Error with "free"; end if;
   Put_Line ("lifecycle PASS");
exception
   when X : others => Put_Line (Ada.Exceptions.Exception_Information (X));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Constrained_Advanced_Probe;

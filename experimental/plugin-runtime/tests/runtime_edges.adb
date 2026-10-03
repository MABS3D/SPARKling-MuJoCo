with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Plugin_Protocol; use MJ.Plugin_Protocol;
with Test_Runtime;
procedure Runtime_Edges is
   package R renames Test_Runtime;
   use type R.Runtime;
   P, D : R.Runtime;
   F : Frame;
   S : Result;
   C : Configurations (0 .. 3);
   procedure Expect (B : Boolean) is
   begin if not B then raise Program_Error with "runtime edge"; end if; end Expect;
begin
   F.Nq := 1; F.Nv := 1; F.Nu := 1; F.Ns := 4;
   C (0) := (Capabilities => 4, State_Count => 3, Has_Advance => True, others => <>);
   C (1) := (Capabilities => 1, State_Count => 3, Has_Advance => True, others => <>);
   C (1).Parameters (8) := -1.0;
   C (2) := (Capabilities => 2, State_Count => 3, Need_Stage => None, others => <>);
   C (3) := (Capabilities => 8, others => <>);
   R.Create (P, C, F, S); Expect (S = Success and then P.State (0) (0) = 1.0);
   R.Dispatch (P, Compute, Sensor, Position, F, S); Expect (S = Success and then P.State (2) (1) = 1.0);
   R.Dispatch (P, Compute, Sensor, Velocity, F, S); Expect (S = Success and then P.State (2) (1) = 1.0);
   R.Dispatch (P, Advance, Passive, None, F, S); Expect (S = Success and then P.State (0) (2) = 1.0 and then P.State (2) (2) = 0.0);
   R.Copy (P, D, F, S); Expect (S = Success and then D = P);
   R.Reset (P, F, S); Expect (S = Success and then P.State (0) (0) = 2.0 and then P.State (0) (2) = 0.0);
   F.Point := [1.0, 2.0, 3.0]; R.Query (P, 3, Distance, F, S); Expect (S = Success and then P.Output.Distance = 3.0);
   R.Query (P, 3, Gradient, F, S); Expect (S = Success and then P.Output.Gradient = [0.0, 0.0, 1.0]);
   R.Query (P, 1, Distance, F, S); Expect (S = Unsupported);
   declare
      Before : R.Runtime;
   begin
      -- A fractional near-end index must reject before Ada's rounded conversion
      -- can turn it into the first element beyond the activation buffer.
      P.Config (1).Parameters (8) := Real (Max_Outputs) - 0.25;
      F.Na := Max_Outputs; Before := P;
      R.Dispatch (P, Compute, Actuator, None, F, S);
      Expect (S = Callback_Failure and then P = Before);
      P.Config (1).Parameters (8) := -1.0; F.Na := 0;
      P.Config (1).Parameters (15) := Real (Hook'Pos (Compute) + 1); Before := P;
      R.Dispatch (P, Compute, Actuator, None, F, S); Expect (S = Callback_Failure and then P = Before);
      P.Config (1).Parameters (15) := Real (Hook'Pos (Reset) + 1); Before := P;
      R.Reset (P, F, S); Expect (S = Callback_Failure and then P = Before);
   end;
   R.Free (P, F, S); Expect (not P.Ready and then P.Count = 0); R.Free (P, F, S); Expect (S = Success);
   R.Dispatch (P, Compute, Passive, None, F, S); Expect (S = Not_Initialized);
   declare
      Too_Many : Configurations (0 .. Max_Instances);
   begin R.Create (P, Too_Many, F, S); Expect (S = Invalid_Config and then not P.Ready); end;
   Put_Line ("runtime lifecycle, stages, SDF and atomic failures PASS");
end Runtime_Edges;

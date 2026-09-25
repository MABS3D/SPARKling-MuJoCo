--  Checked executable boundary for the C/Spark differential suite.
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Forward;
with MJ.Data.Euler;
with MJ.Smooth_Math;

procedure Smooth_Probe is
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   D : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Cases, Steps : Integer;
   Input_Time : Real;
   Selected_Policy : Inertia_Policy := Compatible;

   procedure Check (Expected : Status := Success) is
   begin
      if Result /= Expected then
         raise Program_Error with "expected " & Expected'Image & ", got " & Result'Image;
      end if;
   end Check;

   procedure Emit (Name : String; A : Real_Array) is
   begin
      Put (Name);
      for X of A loop
         Put (' ');
         Numbers.Put (X, Fore => 1, Aft => 17, Exp => 3);
      end loop;
      New_Line;
   end Emit;

   procedure Read_State (A : out State_Vector) is
      X : Real;
   begin
      for I in A'Range loop
         Numbers.Get (X);
         A (I) := X;
      end loop;
   end Read_State;

   procedure Check_Normalization is
      package Math renames MJ.Smooth_Math;
      use type Math.Vector;
      use type Math.Quaternion;
      V : Math.Vector;
      Q : Math.Quaternion;
      Accepted : Boolean;
   begin
      V := Math.Zero;
      Math.Normalize (V, Accepted);
      if Accepted or else V /= Math.Zero then
         raise Program_Error with "zero vector normalization";
      end if;
      V := [1.0e-300, -1.0e-300, 0.0];
      Math.Normalize (V, Accepted);
      if not Accepted or else not Math.Unit_Vector (V) or else V (0) /= -V (1) then
         raise Program_Error with "tiny vector normalization";
      end if;
      V := [Math.Work_Limit, -Math.Work_Limit, 0.0];
      Math.Normalize (V, Accepted);
      if not Accepted or else not Math.Unit_Vector (V) or else V (0) /= -V (1) then
         raise Program_Error with "large vector normalization";
      end if;
      V := [2.0 * Math.Work_Limit, 0.0, 0.0];
      Math.Normalize (V, Accepted);
      if Accepted or else V /= [2.0 * Math.Work_Limit, 0.0, 0.0] then
         raise Program_Error with "rejected vector changed";
      end if;
      Q := [others => 0.0];
      Math.Normalize (Q, Accepted);
      if Accepted or else Q /= [0.0, 0.0, 0.0, 0.0] then
         raise Program_Error with "zero quaternion normalization";
      end if;
      Q := [1.0e-100, 0.0, 0.0, 0.0];
      Math.Normalize (Q, Accepted);
      if Accepted or else Q /= [1.0e-100, 0.0, 0.0, 0.0] then
         raise Program_Error with "tiny quaternion changed";
      end if;
      Q := [Math.Work_Limit, Math.Work_Limit, -Math.Work_Limit, Math.Work_Limit];
      Math.Normalize (Q, Accepted);
      if not Accepted or else Q /= [0.5, 0.5, -0.5, 0.5] then
         raise Program_Error with "large quaternion normalization";
      end if;
   end Check_Normalization;
begin
   Check_Normalization;
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then
      raise Program_Error with "load: " & Loaded.Status'Image;
   end if;
   if Ada.Command_Line.Argument_Count > 1 then
      Selected_Policy := Inertia_Policy'Value (Ada.Command_Line.Argument (2));
   end if;
   Create (M, D, Result, Selected_Policy);
   if Result = Success and then Policy (D) /= Selected_Policy then
      raise Program_Error with "solver policy selection";
   end if;
   Put_Line ("create " & Result'Image);
   if Result /= Success then
      MJ.Models.Free (M);
      return;
   end if;
   Create (M, D, Result);
   Check (Already_Allocated);
   if Policy (D) /= Selected_Policy then raise Program_Error with "allocated policy changed"; end if;
   MJ.Models.Free (M);  --  Exercise ownership: the snapshot must survive.
   declare
      N : constant Natural := Velocity_Count (D);
      U : constant Natural := Control_Count (D);
      Q, V : State_Vector (3 .. N + 2);  --  Nonzero lower bound is intentional.
      Controls : State_Vector (0 .. Integer (U) - 1);
      Applied : State_Vector (0 .. Integer (N) - 1);
      Qout, Vout, Acc, G, B, P, A : Real_Array (0 .. Integer (N) - 1);
      Mass : Real_Array (0 .. Integer (N * N) - 1);
      Len, Vel, Force : Real_Array (0 .. Integer (U) - 1);
      Empty : State_Vector (1 .. 0);
      Bad : State_Vector (0 .. Integer (N)) := [others => 0.0];
      T : Real;
      Pos : MJ.Smooth_Math.Vector;
      Quat : MJ.Smooth_Math.Quaternion;
   begin
      --  Explicit lifecycle/error checks; no assertions depend on optimization.
      Get_Acceleration (D, Acc, Result); Check (Stale_Results);
      Set_State (D, Bad, Empty, 0.0, Result); Check (Invalid_Size);
      Set_Control (D, U, 0.0, Result); Check (Invalid_Index);
      Set_Applied_Force (D, N, 0.0, Result); Check (Invalid_Index);
      if N > 0 then
         declare
            Edge_Q : State_Vector (Natural'Last - N + 1 .. Natural'Last) := [others => 0.25];
            Edge_V : State_Vector (Natural'Last - N + 1 .. Natural'Last) := [others => -0.5];
            Edge_Qout, Edge_Vout : Real_Array (Edge_Q'Range);
         begin
            Set_State (D, Edge_Q, Edge_V, 0.125, Result); Check;
            Get_State (D, Edge_Qout, Edge_Vout, T, Result); Check;
            if (for some X of Edge_Qout => X /= 0.25)
              or else (for some X of Edge_Vout => X /= -0.5) or else T /= 0.125
            then
               raise Program_Error with "state access at high array bounds";
            end if;
         end;
      end if;
      Ada.Integer_Text_IO.Get (Cases);
      for C in 1 .. Cases loop
         Reset (D, Result); Check;
         Get_State (D, Qout, Vout, T, Result); Check;
         if Policy (D) /= Selected_Policy then raise Program_Error with "reset changed policy"; end if;
         if Clamped_Dof (D) /= -1 then raise Program_Error with "warning reset"; end if;
         Emit ("reset_qpos", Qout);
         Emit ("reset_qvel", Vout);
         Read_State (Q); Read_State (V); Read_State (Controls); Read_State (Applied);
         Numbers.Get (Input_Time);
         Ada.Integer_Text_IO.Get (Steps);
         Set_State (D, Q, V, Input_Time, Result); Check;
         declare
            Before : constant Real_Array := State_Values (D);
         begin
            Set_State (D, Bad, Empty, 0.0, Result); Check (Invalid_Size);
            if State_Values (D) /= Before then
               raise Program_Error with "invalid Set_State changed state";
            end if;
         end;
         for I in Controls'Range loop
            Set_Control (D, I, Controls (I), Result); Check;
         end loop;
         for I in Applied'Range loop
            Set_Applied_Force (D, I, Applied (I), Result); Check;
         end loop;
         MJ.Data.Forward.Evaluate (D, Result);
         Put_Line ("forward " & Result'Image);
         Emit ("forward_clamped", [Real (Clamped_Dof (D))]);
         if Result = Success then
            Get_Acceleration (D, Acc, Result); Check; Emit ("qacc", Acc);
            Get_Mass_Matrix (D, Mass, Result); Check; Emit ("mass", Mass);
            Get_Forces (D, G, B, P, A, Result); Check;
            Emit ("gravity", G); Emit ("bias", B); Emit ("passive", P); Emit ("actuation", A);
            Get_Actuator_Outputs (D, Len, Vel, Force, Result); Check;
            Emit ("length", Len); Emit ("velocity", Vel); Emit ("force", Force);
            for Body_Id in 0 .. Body_Count (D) - 1 loop
               Get_Body_Pose (D, Body_Id, Pos, Quat, Result); Check;
               Emit ("position", Real_Array (Pos));
               Emit ("quaternion", Real_Array (Quat));
            end loop;
            Get_State (D, Qout, Vout, T, Result); Check;
            Emit ("unchanged_qpos", Qout); Emit ("unchanged_qvel", Vout);
            Emit ("unchanged_time", [T]);
            --  Failed setters must also preserve already-current caches.
            Set_Control (D, U, 0.0, Result); Check (Invalid_Index);
            Set_Applied_Force (D, N, 0.0, Result); Check (Invalid_Index);
            Set_State (D, Bad, Empty, 0.0, Result); Check (Invalid_Size);
            if not Positions_Current (D) or else not Forces_Current (D) then
               raise Program_Error with "rejected setter invalidated current results";
            end if;
         end if;
         for S in 1 .. Steps loop
            declare
               Before : constant Real_Array := State_Values (D);
            begin
               MJ.Data.Euler.Step (D, Result);
               if Result /= Success and then State_Values (D) /= Before then
                  raise Program_Error with "failed Step changed state";
               end if;
            end;
            exit when Result /= Success;
         end loop;
         Put_Line ("step " & Result'Image);
         Emit ("step_clamped", [Real (Clamped_Dof (D))]);
         Get_State (D, Qout, Vout, T, Result); Check;
         Emit ("qpos", Qout); Emit ("qvel", Vout); Emit ("time", [T]);
         if Steps > 0 and then not Forces_Current (D) then
            Get_Acceleration (D, Acc, Result); Check (Stale_Results);
         end if;
      end loop;
   end;
   Free (D); Free (D);
   Reset (D, Result); Check (Not_Allocated);
   Put_Line ("lifecycle PASS");
exception
   when E : others =>
      Put_Line (Standard_Error, Ada.Exceptions.Exception_Information (E));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Smooth_Probe;

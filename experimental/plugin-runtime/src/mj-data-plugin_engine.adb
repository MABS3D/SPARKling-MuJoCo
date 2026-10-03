with MJ.Plugin_Model_Copy;
with MJ.Models.Validity;
with MJ.Validation;
with MJ.Fields;
with MJ.Data.Kinematics;
with MJ.Data.Forces;
with MJ.Data.Actuation;
with MJ.Data.Manifold_Actuation;
with MJ.Data.Inertia;
with MJ.Data.Inertia_Phase;
with MJ.Data.Euler;
package body MJ.Data.Plugin_Engine with SPARK_Mode is
   use type P.Result;
   use type P.Values;
   use type R.Config_Buffer;
   use type P.Stage;
   function Ready (E : Engine) return Boolean is (Is_Ready (E.D) and then E.Plugins.Ready);
   function State (E : Engine) return Real_Array is (State_Values (E.D));
   function Activation (E : Engine) return Real_Array is (Activation_Values (E.D));
   function Diagnostics (E : Engine) return P.Outputs is (E.Plugins.Output);
   function Plugin_State (E : Engine; Instance : Natural) return P.Values is
   begin
      if not E.Plugins.Ready or else Instance >= E.Plugins.Count then return [1 .. 0 => 0.0]; end if;
      return [for I in 0 .. Integer (E.Plugins.Config (Instance).State_Count) - 1 => E.Plugins.State (Instance) (I)];
   end Plugin_State;
   function Acceleration (E : Engine) return Real_Array is
   begin
      if not Ready (E) or else not Forces_Current (E.D) then return [1 .. 0 => 0.0]; end if;
      return E.D.Dynamics.Acceleration.all;
   end Acceleration;
   function Context (E : Engine) return P.Frame is
      F : P.Frame;
   begin
      if not Is_Ready (E.D) then return F; end if;
      F.Nq := E.D.Nq; F.Nv := E.D.Nv; F.Nu := E.D.Nu;
      F.Na := E.D.Nactivation; F.Ns := E.Ns;
      F.Time := E.D.Clock; F.Timestep := E.D.Timestep;
      for I in 0 .. F.Nq - 1 loop F.Qpos (I) := E.D.State.Qpos (I); end loop;
      for I in 0 .. F.Nv - 1 loop
         F.Qvel (I) := E.D.State.Qvel (I);
         F.Qacc (I) := E.D.Dynamics.Acceleration (I);
      end loop;
      for I in 0 .. F.Nu - 1 loop F.Control (I) := E.D.State.Ctrl (I); end loop;
      for I in 0 .. F.Na - 1 loop F.Activation (I) := E.D.Activation (I); end loop;
      if E.D.Cache.Actuation_Valid then
         for I in 0 .. E.D.No - 1 loop
            F.Length (I) := E.D.Actuators.Length (I); F.Velocity (I) := E.D.Actuators.Velocity (I);
         end loop;
      end if;
      return F;
   end Context;
   procedure Create (M : MJ.Models.Model; Config : P.Configurations;
                     E : in out Engine; Result : out Status) is
      Base : MJ.Models.Model;
      V : MJ.Fields.Load_Result;
      Status : P.Result;
      Offset : Natural := 0;
      function Owner_OK (I : Integer; Kind : P.Capability) return Boolean is
        (I = -1 or else (I in Config'Range and then P.Has (Config (I).Capabilities, Kind)));
   begin
      if not Is_Empty (E.D) then Result := Already_Allocated; return; end if;
      E.Actuator_Owner := [others => -1]; E.Sensor_Owner := [others => -1]; E.Ns := 0;
      Result := Invalid_Model;
      if not MJ.Models.Valid_Layout (M) then return; end if;
      if Config'First /= 0 or else Config'Length /= M.S.Nplugin or else Config'Length > P.Max_Instances
        or else M.S.Nsensordata > P.Max_Outputs or else M.S.Nout > P.Max_Outputs then return; end if;
      for I in Config'Range loop
         if M.Plugins.Plugin (I) /= Config (I).Slot
           or else M.Plugins.Plugin_Statenum (I) /= Config (I).State_Count
           or else M.Plugins.Plugin_Stateadr (I) /= Offset then return; end if;
         Offset := Offset + Config (I).State_Count;
      end loop;
      if Offset /= M.S.Npluginstate then return; end if;
      for I in 0 .. M.S.Nbody - 1 loop
         if not Owner_OK (M.Bodies.Body_Plugin (I), P.Passive) then return; end if;
      end loop;
      for I in 0 .. M.S.Ngeom - 1 loop
         if M.Geoms.Geom_Type (I) = 8 then Result := Unsupported_Feature; return; end if;
         if not Owner_OK (M.Geoms.Geom_Plugin (I), P.SDF) then return; end if;
      end loop;
      for I in 0 .. M.S.Nactuator - 1 loop
         if not Owner_OK (M.Actuators.Actuator_Plugin (I), P.Actuator) then return; end if;
         if M.Actuators.Actuator_Plugin (I) >= 0 and then
           (M.Actuators.Actuator_Actnum (I) not in 0 .. 1 or else M.Actuators.Actuator_Dyntype (I) not in 0 | 7
            or else M.Actuators.Actuator_Trntype (I) not in 0 .. 1)
         then Result := Unsupported_Feature; return; end if;
         E.Actuator_Owner (I) := M.Actuators.Actuator_Plugin (I);
      end loop;
      E.Ns := M.S.Nsensordata;
      for I in 0 .. M.S.Nsensor - 1 loop
         if M.Sensors.Sensor_Type (I) /= 47 then Result := Unsupported_Feature; return; end if;
         if not Owner_OK (M.Sensors.Sensor_Plugin (I), P.Sensor) or else M.Sensors.Sensor_Plugin (I) < 0
           or else M.Sensors.Sensor_Needstage (I) not in 0 .. 3
           or else M.Sensors.Sensor_Needstage (I) /= P.Stage'Pos (Config (M.Sensors.Sensor_Plugin (I)).Need_Stage)
           or else M.Sensors.Sensor_Datatype (I) not in 0 .. 1
           or else M.Sensors.Sensor_Cutoff (I) not in P.Value or else M.Sensors.Sensor_Cutoff (I) < 0.0
           or else M.Sensors.Sensor_Dim (I) not in 0 .. E.Ns
           or else M.Sensors.Sensor_Adr (I) not in 0 .. E.Ns - M.Sensors.Sensor_Dim (I)
         then return; end if;
         for K in M.Sensors.Sensor_Adr (I) .. M.Sensors.Sensor_Adr (I) + M.Sensors.Sensor_Dim (I) - 1 loop
            if E.Sensor_Owner (K) /= -1 then return; end if;
            E.Sensor_Owner (K) := M.Sensors.Sensor_Plugin (I);
            E.Sensor_Stage (K) := P.Stage'Val (M.Sensors.Sensor_Needstage (I));
            E.Sensor_Cutoff (K) := M.Sensors.Sensor_Cutoff (I);
            E.Sensor_Positive (K) := M.Sensors.Sensor_Datatype (I) = 1;
         end loop;
      end loop;
      MJ.Plugin_Model_Copy.Build (M, Base);
      MJ.Validation.Validate (Base, (Contact_Cap => 0), V);
      if V.Status /= OK then
         MJ.Models.Free (Base); Result := Invalid_Model; return;
      end if;
      E.Sensor_Enabled := (M.Opt.Disableflags / 8192) mod 2 = 0;
      E.Passive_Enabled := (M.Opt.Disableflags / 32) mod 2 = 0 or else (M.Opt.Disableflags / 64) mod 2 = 0;
      MJ.Data.Create (Base, E.D, Result); MJ.Models.Free (Base);
      if Result /= Success then return; end if;
      R.Create (E.Plugins, Config, Context (E), Status);
      if Status /= P.Success then MJ.Data.Free (E.D); Result := Invalid_Model; end if;
   exception
      when Constraint_Error => MJ.Models.Free (Base); MJ.Data.Free (E.D); E.Plugins := (others => <>); Result := Invalid_Model;
   end Create;
   procedure Free (E : in out Engine; Result : out Status) is
      S : P.Result;
   begin
      R.Free (E.Plugins, Context (E), S); MJ.Data.Free (E.D);
      E.Actuator_Owner := [others => -1]; E.Sensor_Owner := [others => -1]; E.Ns := 0;
      Result := (if S = P.Success then Success else Numeric_Limit);
   end Free;
   procedure Reset (E : in out Engine; Result : out Status) is
      S : P.Result;
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      MJ.Data.Reset (E.D, Result);
      if Result = Success then R.Reset (E.Plugins, Context (E), S); if S /= P.Success then Result := Numeric_Limit; end if; end if;
   end Reset;
   procedure Set_State (E : in out Engine; Q, V : State_Vector;
                        Clock : Nonneg_Tier0; Result : out Status) is
   begin MJ.Data.Set_State (E.D, Q, V, Clock, Result); end Set_State;
   procedure Set_Control (E : in out Engine; I : Natural; V : Tier0_Real; Result : out Status) is
   begin MJ.Data.Set_Control (E.D, I, V, Result); end Set_Control;
   procedure Set_Activation (E : in out Engine; A : State_Vector; Result : out Status) is
   begin MJ.Data.Set_Activation (E.D, A, Result); end Set_Activation;
   procedure Set_Applied_Force (E : in out Engine; I : Natural; V : Tier0_Real; Result : out Status) is
   begin MJ.Data.Set_Applied_Force (E.D, I, V, Result); end Set_Applied_Force;
   procedure Evaluate_Internal (E : in out Engine; Result : out Status;
                               External : MJ.External_Forces.Wrench_Array) is
      S : P.Result;
      F : P.Frame;
      procedure Dispatch (H : P.Hook; Kind : P.Capability; Stage : P.Stage) is
      begin
         F := Context (E); R.Dispatch (E.Plugins, H, Kind, Stage, F, S);
         if S /= P.Success then Result := Numeric_Limit; end if;
      end Dispatch;
      procedure Sensors (Stage : P.Stage) is
      begin
         if not E.Sensor_Enabled then return; end if;
         Dispatch (P.Compute, P.Sensor, Stage);
         if Result /= Success then return; end if;
         for I in 0 .. E.Ns - 1 loop
            if E.Sensor_Owner (I) >= 0 and then E.Sensor_Stage (I) = Stage then
               E.Plugins.Output.Sensor (I) := P.Cutoff (E.Plugins.Output.Sensor (I), E.Sensor_Cutoff (I), E.Sensor_Positive (I));
            end if;
         end loop;
      end Sensors;
   begin
      Result := Success;
      E.D.Cache.Force_Valid := False;
      E.D.Cache.Passive_Valid := False;
      E.D.Cache.Actuation_Valid := False;
      MJ.Data.Kinematics.Update (E.D, Result); if Result /= Success then return; end if;
      Sensors (P.Position); if Result /= Success then return; end if;
      MJ.Data.Inertia.Assemble (E.D, Result); if Result /= Success then return; end if;
      MJ.Data.Forces.Compute (E.D, Result); if Result /= Success then return; end if;
      for I in 0 .. E.D.Nv - 1 loop E.Plugins.Output.Passive (I) := E.D.Dynamics.Passive (I); end loop;
      if E.Passive_Enabled then Dispatch (P.Compute, P.Passive, P.Velocity); if Result /= Success then return; end if; end if;
      for I in 0 .. E.D.Nv - 1 loop E.D.Dynamics.Passive (I) := E.Plugins.Output.Passive (I); end loop;
      Sensors (P.Velocity); if Result /= Success then return; end if;
      MJ.Data.Actuation.Compute (E.D, Result); if Result /= Success then return; end if;
      for I in 0 .. E.D.No - 1 loop E.Plugins.Output.Force (I) := E.D.Actuators.Force (I); end loop;
      for I in 0 .. E.D.Nactivation - 1 loop E.Plugins.Output.Act_Dot (I) := E.D.Act_Dot (I); end loop;
      if E.D.Actuation_Enabled then
         Dispatch (P.Act_Dot, P.Actuator, P.None); if Result /= Success then return; end if;
         for A in 0 .. E.D.Na - 1 loop
            if E.Actuator_Owner (A) >= 0 and then E.D.Actuator_Config (A).Activation_Id >= 0 then
               declare
                  C : Actuator_Parameters renames E.D.Actuator_Config (A);
                  I : constant Natural := C.Activation_Id;
                  Next : Real;
               begin
                  E.D.Act_Dot (I) := E.Plugins.Output.Act_Dot (I);
                  Next := MJ.Activation.Next_Value (C.Kind, E.D.Activation (I), E.D.Act_Dot (I),
                    E.D.Timestep, C.Tau, C.Factor, C.Activation_Limited, C.Activation_Lower,
                    C.Activation_Upper);
                  if Next not in Tier0_Real then Result := Numeric_Limit; return; end if;
                  E.D.Next_Activation (I) := Next;
               end;
            end if;
         end loop;
         Dispatch (P.Compute, P.Actuator, P.None); if Result /= Success then return; end if;
      end if;
      E.D.Dynamics.Actuator.all := [others => 0.0];
      for A in 0 .. E.D.Na - 1 loop
         declare
            C : Actuator_Parameters renames E.D.Actuator_Config (A);
            Force : Real := E.Plugins.Output.Force (A);
            Moment : constant MJ.Data.Manifold_Actuation.Moment :=
              MJ.Data.Manifold_Actuation.Transmission_Moment (C, E.D.State.Qpos.all);
            N : constant Natural := (if C.Joint_Type = 0 then 6 elsif C.Joint_Type = 1 then 3 else 1);
         begin
            if E.D.Actuation_Enabled and then C.Force_Limited then Force := Real'Max (C.Force_Lower, Real'Min (C.Force_Upper, Force)); end if;
            E.D.Actuators.Force (A) := Force; E.Plugins.Output.Force (A) := Force;
            for K in 0 .. N - 1 loop
               E.D.Dynamics.Actuator (C.Joint_Id + K) := E.D.Dynamics.Actuator (C.Joint_Id + K) + Moment (K) * Force;
            end loop;
         end;
      end loop;
      MJ.Data.Inertia_Phase.Solve_Acceleration (E.D, Result, External); if Result /= Success then return; end if;
      Sensors (P.Acceleration);
   end Evaluate_Internal;
   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Previous : constant R.Runtime := E.Plugins;
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      Evaluate_Internal (E, Result, External);
      if Result /= Success then E.Plugins := Previous; E.D.Cache.Force_Valid := False; end if;
   exception
      when Constraint_Error => E.Plugins := Previous; E.D.Cache.Force_Valid := False; Result := Numeric_Limit;
   end Evaluate;
   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Previous : constant R.Runtime := E.Plugins;
      S : P.Result;
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      declare
         Q : constant State_Vector := [for X of E.D.State.Qpos.all => MJ.Types.Tier0_Real (X)];
         V : constant State_Vector := [for X of E.D.State.Qvel.all => MJ.Types.Tier0_Real (X)];
         A : constant State_Vector := E.D.Activation (0 .. Integer (E.D.Nactivation) - 1);
         T : constant Nonneg_Tier0 := E.D.Clock;
         Ignore : Status;
      begin
         Evaluate (E, Result, External); if Result /= Success then return; end if;
         --  Euler.Step reruns Pipeline, whose Update_Poses invalidates all
         --  force buffers; that would erase the just-computed plugin forces.
         --  Reuse its effective-mass solve and quaternion arithmetic, then
         --  stage the state update before publishing it once.
         MJ.Data.Inertia.Solve_Euler (E.D, Result);
         if Result = Success then
            declare
               D : Simulation renames E.D;
               Next_Time : constant Real := D.Clock + D.Timestep;
               Next_Q : State_Vector := [for X of D.State.Qpos.all => MJ.Types.Tier0_Real (X)];
               Next_V : State_Vector := [for X of D.State.Qvel.all => MJ.Types.Tier0_Real (X)];
               X : Real;
               Orientation : Quaternion;
            begin
               if Next_Time not in Nonneg_Tier0 then Result := Numeric_Limit;
               else
                  for I in 0 .. D.Nv - 1 loop
                     X := D.State.Qvel (I) + D.Timestep * D.Scratch.Solution (I);
                     if X not in Tier0_Real then Result := Numeric_Limit; exit; end if;
                     Next_V (I) := X;
                  end loop;
                  if Result = Success then
                     for C of D.Joint_Config.all loop
                        if C.Group_Type in 2 .. 3 or else (C.Group_Type = 0 and then C.Component < 3) then
                           X := D.State.Qpos (C.Qadr) + D.Timestep * Next_V (C.Vadr);
                           if X not in Tier0_Real then Result := Numeric_Limit; exit; end if;
                           Next_Q (C.Qadr) := X;
                        elsif (C.Group_Type = 1 and then C.Component = 0) or else (C.Group_Type = 0 and then C.Component = 3) then
                           Orientation := MJ.Manifold_Math.Integrated
                             (Read_Quaternion (D.State.Qpos.all, C.Qadr),
                              Vector'(Next_V (C.Vadr), Next_V (C.Vadr + 1), Next_V (C.Vadr + 2)), D.Timestep);
                           for K in 0 .. 3 loop Next_Q (C.Qadr + K) := Orientation (K); end loop;
                        end if;
                     end loop;
                  end if;
                  if Result = Success then
                     if not D.Activation_Can_Advance then Result := Numeric_Limit;
                     else
                        D.State.Qpos.all := [for X of Next_Q => MJ.Types.Real (X)];
                        D.State.Qvel.all := [for X of Next_V => MJ.Types.Real (X)];
                        D.Activation := D.Next_Activation; D.Clock := Next_Time;
                        Invalidate (D.Cache);
                     end if;
                  end if;
               end if;
            end;
         end if;
         if Result = Success then
            R.Dispatch (E.Plugins, P.Advance, P.Passive, P.None, Context (E), S);
            if S /= P.Success then Result := Numeric_Limit; end if;
         end if;
         if Result /= Success then
            E.Plugins := Previous;
            MJ.Data.Set_State (E.D, Q, V, T, Ignore); MJ.Data.Set_Activation (E.D, A, Ignore);
         end if;
      exception
         when Constraint_Error =>
            E.Plugins := Previous;
            MJ.Data.Set_State (E.D, Q, V, T, Ignore); MJ.Data.Set_Activation (E.D, A, Ignore);
            Result := Numeric_Limit;
      end;
   end Step;
   procedure SDF_Query (E : in out Engine; Instance : Natural; Point : P.Values;
                        Distance : out P.Value; Gradient : out P.Values; Result : out Status) is
      F : P.Frame := Context (E);
      Previous : constant R.Runtime := E.Plugins;
      S : P.Result;
   begin
      Distance := 0.0; Gradient := [others => 0.0];
      if not Ready (E) then Result := Not_Allocated; return; end if;
      if Point'First /= 0 or else Point'Length /= 3 or else Gradient'First /= 0 or else Gradient'Length /= 3
        then Result := Invalid_Size; return; end if;
      F.Point := Point;
      R.Query (E.Plugins, Instance, P.Distance, F, S);
      if S = P.Success then R.Query (E.Plugins, Instance, P.Gradient, F, S); end if;
      if S /= P.Success then E.Plugins := Previous; Result := Unsupported_Feature; return; end if;
      Distance := E.Plugins.Output.Distance; Gradient := E.Plugins.Output.Gradient; Result := Success;
   end SDF_Query;
   procedure Copy_State (Source : Engine; Dest : in out Engine; Result : out Status) is
      S : P.Result;
      Candidate : R.Runtime := Dest.Plugins;
   begin
      if not Ready (Source) or else not Ready (Dest) then Result := Not_Allocated; return; end if;
      if Shape (Source.D) /= Shape (Dest.D) or else Source.Plugins.Config /= Dest.Plugins.Config
        or else Source.Plugins.Count /= Dest.Plugins.Count or else Source.Actuator_Owner /= Dest.Actuator_Owner
        or else Source.Sensor_Owner /= Dest.Sensor_Owner
      then Result := Invalid_Model; return; end if;
      R.Copy (Source.Plugins, Candidate, Context (Source), S);
      if S /= P.Success then Result := Numeric_Limit; return; end if;
      MJ.Data.Set_State (Dest.D, [for X of Source.D.State.Qpos.all => MJ.Types.Tier0_Real (X)],
                         [for X of Source.D.State.Qvel.all => MJ.Types.Tier0_Real (X)], Source.D.Clock, Result);
      MJ.Data.Set_Activation (Dest.D, Source.D.Activation (0 .. Integer (Source.D.Nactivation) - 1), Result);
      Dest.D.State.Ctrl.all := Source.D.State.Ctrl.all;
      Dest.D.State.Applied.all := Source.D.State.Applied.all;
      Dest.Plugins := Candidate;
   end Copy_State;
end MJ.Data.Plugin_Engine;

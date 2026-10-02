with MJ.Manifold_Math;
with MJ.Muscle_Actuation;
with MJ.Muscle_Kernels;
package body MJ.Data.Manifold_Actuation with SPARK_Mode is
   use type MJ.Activation.Dynamics;
   function Transmission_Moment (C : Actuator_Parameters; Q : Real_Array) return Moment is
      R : Moment := [others => 0.0];
      Gear_Axis : Vector;
      Orientation : Quaternion;
      N : constant Natural := (if C.Joint_Type = 0 then 6 elsif C.Joint_Type = 1 then 3 else 1);
   begin
      for K in 0 .. N - 1 loop R (K) := C.Wrench_Gear (K); end loop;
      if C.Parent_Frame and then C.Joint_Type in 0 .. 1 then
         Orientation := MJ.Manifold_Math.Normalized (Read_Quaternion (Q, C.Position_Id + (if C.Joint_Type = 0 then 3 else 0)));
         Gear_Axis := Apply_Transpose (Rotation (Orientation), Read_Vector (C.Wrench_Gear, (if C.Joint_Type = 0 then 3 else 0)));
         for K in Axis loop R ((if C.Joint_Type = 0 then 3 else 0) + K) := Gear_Axis (K); end loop;
      end if;
      return R;
   end Transmission_Moment;
   function Length (C : Actuator_Parameters; Q : Real_Array) return Real is
      M : Moment;
      R : Vector;
   begin
      if C.Joint_Type = 0 then return 0.0;
      elsif C.Joint_Type = 1 then
         M := Transmission_Moment (C, Q);
         R := MJ.Manifold_Math.Rotation_Vector (Read_Quaternion (Q, C.Position_Id));
         return (R (0)*M (0) + R (1)*M (1)) + R (2)*M (2);
      else return Q (C.Position_Id) * C.Gear; end if;
   end Length;
   function Velocity (C : Actuator_Parameters; Q, V : Real_Array) return Real is
      M : constant Moment := Transmission_Moment (C, Q);
      N : constant Natural := (if C.Joint_Type = 0 then 6 elsif C.Joint_Type = 1 then 3 else 1);
      R : Real := 0.0;
   begin
      for K in 0 .. N - 1 loop R := R + M (K) * V (C.Joint_Id + K); end loop;
      return R;
   end Velocity;
   function Force (C : Actuator_Parameters; L, V, U : Real; Enabled, Clamp_Control : Boolean) return Real is
      R : Real;
   begin
      if not Enabled then return 0.0; end if;
      if C.Muscle_Mode then
         return MJ.Muscle_Actuation.Force (C.Muscle,
           MJ.Muscle_Kernels.Gain (L, V, C.Muscle.Range_Of_Length,
             C.Muscle.Acc0, C.Muscle.Gain_Parameters),
           MJ.Muscle_Kernels.Bias (L, C.Muscle.Range_Of_Length,
             C.Muscle.Acc0, C.Muscle.Bias_Parameters), U);
      end if;
      R := MJ.Smooth_Kernels.Affine_Force
        (C.Gain, MJ.Smooth_Kernels.Control_Value (U, C.Control_Lower, C.Control_Upper,
           Clamp_Control and then C.Kind = MJ.Activation.None and then C.Control_Limited), C.Bias, L, V);
      return (if C.Force_Limited then MJ.Smooth_Kernels.Clamp (R, C.Force_Lower, C.Force_Upper) else R);
   end Force;
   function Reduced (C : Actuator_Parameter_Array; Q, F : Real_Array; Dof, Count : Natural) return Real is
      P : Actuator_Parameters;
      M : Moment;
      N : Natural;
   begin
      if Count = 0 then return 0.0; end if;
      P := C (Count - 1);
      N := (if P.Joint_Type = 0 then 6 elsif P.Joint_Type = 1 then 3 else 1);
      if Dof >= P.Joint_Id and then Dof - P.Joint_Id < N then
         M := Transmission_Moment (P, Q);
         return Reduced (C, Q, F, Dof, Count - 1) + M (Dof - P.Joint_Id) * F (Count - 1);
      end if;
      return Reduced (C, Q, F, Dof, Count - 1);
   end Reduced;
   procedure Compute (D : in out Simulation; Result : out Status) is
      L, V, F, Sum : Real;
      M : Moment;
      N : Natural;
      Control : Tier0_Real;
      Accepted : Boolean;
   begin
      Result := Numeric_Limit;
      D.Activation_Can_Advance := True;
      D.Cache.Force_Valid := False; D.Cache.Actuation_Valid := False;
      D.Dynamics.Actuator.all := [others => 0.0];
      for A in 0 .. D.Na - 1 loop
         declare
            P : constant Actuator_Parameters := D.Actuator_Config (A);
         begin
            L := Length (P, D.State.Qpos.all);
            V := (if D.Actuation_Enabled then Velocity (P, D.State.Qpos.all, D.State.Qvel.all) else 0.0);
            if L not in -1.0e20 .. 1.0e20 or else V not in -1.0e20 .. 1.0e20 then return; end if;
            F := 0.0;
            D.Drive (A) := D.State.Ctrl (A);
            if P.Muscle_Mode then
               if L not in Tier0_Real or else V not in Tier0_Real then return; end if;
               D.Act_Dot (P.Activation_Id) := 0.0;
               D.Next_Activation (P.Activation_Id) := D.Activation (P.Activation_Id);
               D.Drive (A) := D.Activation (P.Activation_Id);
               if D.Actuation_Enabled then
                  declare
                     E : MJ.Muscle_Actuation.Evaluation;
                  begin
                     MJ.Muscle_Actuation.Evaluate (P.Muscle,
                       (Activation => D.Activation (P.Activation_Id)),
                       D.State.Ctrl (A), L, V, D.Timestep, E);
                     F := E.Force;
                     if E.Derivative not in MJ.Activation.Rate then return; end if;
                     D.Act_Dot (P.Activation_Id) := E.Derivative;
                     if E.Next_Activation not in Tier0_Real then
                        D.Activation_Can_Advance := False;
                        if P.Early then return; end if;
                     else
                        D.Next_Activation (P.Activation_Id) := E.Next_Activation;
                        if P.Early then D.Drive (A) := E.Next_Activation; end if;
                     end if;
                  end;
               end if;
            elsif P.Kind /= MJ.Activation.None then
               Control := MJ.Smooth_Kernels.Control_Value
                 (D.State.Ctrl (A), P.Control_Lower, P.Control_Upper,
                  D.Clamp_Control and then P.Control_Limited);
               MJ.Activation.Prepare
                 (P.Kind, Control, D.Activation (P.Activation_Id), D.Timestep,
                  P.Tau, P.Factor, D.Actuation_Enabled, P.Early,
                  P.Activation_Limited, P.Activation_Lower, P.Activation_Upper,
                  D.Act_Dot (P.Activation_Id), D.Next_Activation (P.Activation_Id),
                  D.Drive (A), Accepted);
               if not Accepted then
                  D.Activation_Can_Advance := False;
                  if P.Early then return; end if;
               end if;
            end if;
            if not P.Muscle_Mode then
               F := Force (P, L, V, D.Drive (A), D.Actuation_Enabled, D.Clamp_Control);
            end if;
            if F not in MJ.Smooth_Kernels.Actuator_Force_Real then return; end if;
            D.Actuators.Length (A) := L; D.Actuators.Velocity (A) := V; D.Actuators.Force (A) := F;
            M := Transmission_Moment (P, D.State.Qpos.all);
            N := (if P.Joint_Type = 0 then 6 elsif P.Joint_Type = 1 then 3 else 1);
            for K in 0 .. N - 1 loop
               Sum := D.Dynamics.Actuator (P.Joint_Id + K) + M (K) * F;
               if Sum not in -1.0e50 .. 1.0e50 then return; end if;
               D.Dynamics.Actuator (P.Joint_Id + K) := Sum;
            end loop;
         end;
      end loop;
      D.Cache.Actuation_Valid := True;
      Result := Success;
   end Compute;
end MJ.Data.Manifold_Actuation;

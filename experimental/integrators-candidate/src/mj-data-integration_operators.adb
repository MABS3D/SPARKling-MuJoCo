with MJ.Integration_Kernels;
with MJ.Spatial_Kernels; with MJ.Spatial_Dynamics; with MJ.Spatial_Storage;
with MJ.Data.Manifold_Actuation;
with MJ.Data.Spatial; with MJ.Data.Pipeline;
with MJ.Data.Integration_Fluid;
with MJ.Muscle_Kernels; with MJ.Integration_Duals;
with MJ.Spatial_Tendons; with MJ.Tendon_Vectors;
package body MJ.Data.Integration_Operators with SPARK_Mode is
   package K renames MJ.Integration_Kernels;
   package SK renames MJ.Spatial_Kernels;
   package SD renames MJ.Spatial_Dynamics;
   function Ancestor (D : Simulation; A, B : Natural) return Boolean is
      Current : Natural := B;
   begin
      while Current > 0 loop
         if Current = A then return True; end if;
         Current := D.Body_Config (Current).Parent;
      end loop;
      return A = 0;
   end Ancestor;
   function Connected (D : Simulation; R, C : Natural) return Boolean is
     (Ancestor (D, D.Joint_Config (R).Body_Id, D.Joint_Config (C).Body_Id)
       or else Ancestor (D, D.Joint_Config (C).Body_Id, D.Joint_Config (R).Body_Id));
   function Standalone_Free (D : Simulation; Row : Natural) return Boolean is
      B : constant Natural := D.Joint_Config (Row).Body_Id;
   begin
      if D.Joint_Config (Row).Group_Type /= 0 or else D.Body_Config (B).Parent /= 0 then return False; end if;
      for P of D.Joint_Config.all loop
         if P.Body_Id /= B and then Ancestor (D, B, P.Body_Id) then return False; end if;
      end loop;
      return True;
   end Standalone_Free;

   procedure Bias_Column (D : Simulation; Column : Natural; Output : out Real_Array) is
      type Motions is array (Natural range <>) of SK.Motion;
      V, DV, A, DA, DF : Motions (0 .. D.Nb-1) := [others => [others => 0.0]];
      Group_V, Group_DV, Delta_A, Delta_DA, Axis_Value, Rate, DRate : SK.Motion;
      Speed, Basis : Real;
   begin
      for B in 1 .. D.Nb-1 loop
         V (B) := V (D.Body_Config (B).Parent); DV (B) := DV (D.Body_Config (B).Parent);
         Delta_A := [others => 0.0]; Delta_DA := [others => 0.0];
         Group_V := V (B); Group_DV := DV (B);
         for I in 0 .. D.Body_Config (B).Joint_Count-1 loop
            declare
               J : constant Natural := D.Body_Config (B).First_Joint+I;
               P : Joint_Parameters renames D.Joint_Config (J);
            begin
               Axis_Value := MJ.Spatial_Storage.Load_Motion (D.Kinematic.Spatial_Motions.all, 6*J);
               Speed := D.State.Qvel (J); Basis := (if J = Column then 1.0 else 0.0);
               if P.Group_Type in 0 .. 1 then
                  if P.Component = (if P.Group_Type = 0 then 3 else 0) then Group_V := V (B); Group_DV := DV (B); end if;
                  if P.Group_Type = 0 and then P.Component < 3 then
                     Rate := [others => 0.0]; DRate := [others => 0.0];
                  else
                     Rate := SD.Cross_Motion (Group_V, Axis_Value);
                     DRate := SD.Cross_Motion (Group_DV, Axis_Value);
                  end if;
               else
                  Rate := SD.Cross_Motion (V (B), Axis_Value);
                  DRate := SD.Cross_Motion (DV (B), Axis_Value);
               end if;
               for C in 0 .. 5 loop
                  Delta_A (C) := Delta_A (C) + Rate (C)*Speed;
                  Delta_DA (C) := (Delta_DA (C) + DRate (C)*Speed) + Rate (C)*Basis;
                  V (B)(C) := V (B)(C) + Axis_Value (C)*Speed;
                  DV (B)(C) := DV (B)(C) + Axis_Value (C)*Basis;
               end loop;
            end;
         end loop;
         for C in 0 .. 5 loop
            A (B)(C) := A (D.Body_Config (B).Parent)(C) + Delta_A (C);
            DA (B)(C) := DA (D.Body_Config (B).Parent)(C) + Delta_DA (C);
         end loop;
         declare
            Inertia : constant SK.Inertia := MJ.Spatial_Storage.Load_Inertia (D.Kinematic.Spatial_Inertias.all, 10*B);
            IA : constant SK.Motion := SK.Multiply (Inertia, DA (B));
            IV : constant SK.Motion := SK.Multiply (Inertia, V (B));
            IDV : constant SK.Motion := SK.Multiply (Inertia, DV (B));
            First : constant SK.Motion := SD.Cross_Force (DV (B), IV);
            Second : constant SK.Motion := SD.Cross_Force (V (B), IDV);
         begin
            for C in 0 .. 5 loop DF (B)(C) := (IA (C)+First (C))+Second (C); end loop;
         end;
      end loop;
      for B in reverse 1 .. D.Nb-1 loop
         declare P : constant Natural := D.Body_Config (B).Parent;
         begin
            if P > 0 then for C in 0 .. 5 loop DF (P)(C) := DF (P)(C)+DF (B)(C); end loop; end if;
         end;
      end loop;
      for J in 0 .. D.Nv-1 loop
         Output (J) := SK.Dot (MJ.Spatial_Storage.Load_Motion (D.Kinematic.Spatial_Motions.all, 6*J), DF (D.Joint_Config (J).Body_Id));
      end loop;
   end Bias_Column;

   function Muscle_Derivative (D : Simulation; Id : Natural; Length_Rate : Boolean) return Real is
      package AD renames MJ.Integration_Duals; use AD;
      package MK renames MJ.Muscle_Kernels;
      P : Actuator_Parameters renames D.Actuator_Config (Id);
      G : MK.Parameters renames P.Muscle.Gain_Parameters;
      B : MK.Parameters renames P.Muscle.Bias_Parameters;
      N, V, X, FL, FV, FB, FG : Dual;
      Lo, A, Z, Den : Real;
   begin
      Lo := MK.Optimal_Length (P.Muscle.Range_Of_Length,G);
      N := (MK.Normalized_Length (D.Actuators.Length (Id),P.Muscle.Range_Of_Length,G),
        (if Length_Rate then 1.0/Real'Max (Min_Val,Lo) else 0.0));
      Den := Real'Max (Min_Val,Lo*G (6));
      V := (D.Actuators.Velocity (Id)/Den, (if Length_Rate then 0.0 else 1.0/Den));
      A := 0.5*(G (4)+1.0); Z := 0.5*(1.0+G (5));
      if N.Value < G (4) or else N.Value > G (5) then FL := C (0.0);
      elsif N.Value <= A then X := (N-C (G (4)))*C (1.0/Real'Max (Min_Val,A-G (4))); FL := (C (0.5)*X)*X;
      elsif N.Value <= 1.0 then X := (C (1.0)-N)*C (1.0/Real'Max (Min_Val,1.0-A)); FL := C (1.0)-(C (0.5)*X)*X;
      elsif N.Value <= Z then X := (N-C (1.0))*C (1.0/Real'Max (Min_Val,Z-1.0)); FL := C (1.0)-(C (0.5)*X)*X;
      else X := (C (G (5))-N)*C (1.0/Real'Max (Min_Val,G (5)-Z)); FL := (C (0.5)*X)*X; end if;
      if V.Value <= -1.0 then FV := C (0.0);
      elsif V.Value <= 0.0 then FV := (V+C (1.0))*(V+C (1.0));
      elsif V.Value <= G (8)-1.0 then
         X := C (G (8)-1.0)-V; FV := C (G (8))-(X*X)*C (1.0/Real'Max (Min_Val,G (8)-1.0));
      else FV := C (G (8)); end if;
      FG := (C (-MK.Scaled_Force (G,P.Muscle.Acc0))*FL)*FV;
      Lo := MK.Optimal_Length (P.Muscle.Range_Of_Length,B);
      N := (MK.Normalized_Length (D.Actuators.Length (Id),P.Muscle.Range_Of_Length,B),
        (if Length_Rate then 1.0/Real'Max (Min_Val,Lo) else 0.0));
      Z := 0.5*(1.0+B (5));
      if N.Value <= 1.0 then FB := C (0.0);
      elsif N.Value <= Z then
         X := (N-C (1.0))*C (1.0/Real'Max (Min_Val,Z-1.0));
         FB := (((C (-MK.Scaled_Force (B,P.Muscle.Acc0)*B (7))*C (0.5))*X)*X);
      else
         X := (N-C (Z))*C (1.0/Real'Max (Min_Val,Z-1.0));
         FB := C (-MK.Scaled_Force (B,P.Muscle.Acc0)*B (7))*(C (0.5)+X);
      end if;
      FB := FG*C (D.Drive (Id))+FB;
      return FB.Rate;
   end Muscle_Derivative;

   procedure Tendon_Moment (D : in out Simulation; Id : Positive; Row : out Real_Array; Result : out Status) is
      package ST renames MJ.Spatial_Tendons; package TV renames MJ.Tendon_Vectors;
      P : MJ.Spatial_Tendon_Models.Parameters renames D.Tendons.Tendons (Id);
      Sites : ST.Site_Array (0 .. D.Tendons.Ns-1) := D.Tendons.Sites;
      Geoms : ST.Geometry_Array (0 .. D.Tendons.Ng-1) := D.Tendons.Geometries;
      Origins : ST.Vector_Array (0 .. D.Nb-1);
      Route : ST.Route_Array (0 .. P.Count-1) := D.Tendons.Nodes (P.First+1 .. P.First+P.Count);
      Points : ST.Point_Array (0 .. 3*P.Count-1);
      R : TV.Matrix; Position, V : TV.Vector; B, Count : Natural;
      Length : Real; Eval : ST.Evaluation_Status;
      use type ST.Evaluation_Status;
   begin
      Row := [others => 0.0]; Result := Success;
      if P.Fixed then
         for E of D.Tendons.Jacobian (P.First+1 .. P.First+P.Jacobian_Count) loop Row (E.Dof) := Row (E.Dof)+E.Coefficient; end loop;
         return;
      end if;
      Pipeline.Ensure_Jacobians (D, Result); if Result /= Success then return; end if;
      for Body_Id in Origins'Range loop
         Origins (Body_Id) := (D.Kinematic.Bodies (Body_Id).Center (0), D.Kinematic.Bodies (Body_Id).Center (1), D.Kinematic.Bodies (Body_Id).Center (2));
      end loop;
      for I in Sites'Range loop
         B := Sites (I).Body_Id;
         for A in 1 .. 3 loop Position (A) := D.Kinematic.Bodies (B).Position (A-1);
            for C0 in 1 .. 3 loop R (A,C0) := D.Kinematic.Bodies (B).Rotation (A-1,C0-1); end loop;
         end loop;
         Sites (I).Position := TV.Add (Position,TV.Multiply (R,Sites (I).Position));
      end loop;
      for I in Geoms'Range loop
         B := Geoms (I).Body_Id;
         for A in 1 .. 3 loop Position (A) := D.Kinematic.Bodies (B).Position (A-1);
            for C0 in 1 .. 3 loop R (A,C0) := D.Kinematic.Bodies (B).Rotation (A-1,C0-1); end loop;
         end loop;
         Geoms (I).Position := TV.Add (Position,TV.Multiply (R,Geoms (I).Position));
         for C0 in 1 .. 3 loop
            V := TV.Multiply (R,(Geoms (I).Orientation (1,C0),Geoms (I).Orientation (2,C0),Geoms (I).Orientation (3,C0)));
            for A in 1 .. 3 loop Geoms (I).Orientation (A,C0) := V (A); end loop;
         end loop;
      end loop;
      ST.Evaluate_Flat (Route,Sites,Geoms,Origins,D.Kinematic.Linear_Jacobian.all,D.Kinematic.Angular_Jacobian.all,Eval,Length,Row,Points,Count);
      if Eval /= ST.Success then Result := Numeric_Limit; end if;
   end Tendon_Moment;

   procedure Build (D : in out Simulation; Full_Bias, Discrete, Use_Couplings : Boolean;
      Deriv, Addition, Shift, Backbone, Gyro : out Real_Array;
      Has_Couplings : out Boolean; Result : out Status) is
      N : constant Natural := D.Nv; H : constant Real := D.Timestep;
      Stiffness, Damping, Scale, Velocity_Deriv, Length_Deriv, Displacement, Speed : Real;
      Ready : Boolean;
      Coupled : array (0 .. D.Nb - 1) of Boolean := [others => False];
      Fluid : Real_Array (0 .. Integer (N*N)-1) := [others => 0.0];
      Moment, Bias : Real_Array (0 .. Integer (N)-1);
   begin
      Deriv := [others => 0.0]; Addition := [others => 0.0]; Shift := [others => 0.0];
      Backbone := [others => 0.0]; Gyro := [others => 0.0]; Has_Couplings := False;
      Result := Unsupported_Feature;
      Spatial.Prepare (D, Ready);
      if not Ready then Result := Numeric_Limit; return; end if;
      for I in 0 .. N-1 loop
         Stiffness := (if D.Spring_Enabled then D.Joint_Config (I).Stiffness else 0.0);
         Damping := (if D.Damper_Enabled then D.Joint_Config (I).Damping else 0.0);
         Deriv (I*N+I) := -Damping;
         Addition (I*N+I) := K.Discrete_Scale (Stiffness, Damping, H);
         Backbone (I*N+I) := Addition (I*N+I);
         Shift (I) := -(H*Stiffness)*D.State.Qvel (I);
      end loop;
      if D.Actuation_Enabled then
         for A in D.Actuator_Config'Range loop
            declare
               P : Actuator_Parameters renames D.Actuator_Config (A);
               M : constant Manifold_Actuation.Moment := Manifold_Actuation.Transmission_Moment (P, D.State.Qpos.all);
            begin
               Moment := [others => 0.0];
               for I in 0 .. (if P.Joint_Type = 0 then 5 elsif P.Joint_Type = 1 then 2 else 0) loop
                  Moment (P.Joint_Id+I) := M (I);
               end loop;
               Velocity_Deriv := (if P.Muscle_Mode then Muscle_Derivative (D,A,False) else P.Bias (2));
               Length_Deriv := (if P.Muscle_Mode then Muscle_Derivative (D,A,True) else P.Bias (1));
               if P.Force_Limited and then (D.Actuators.Force (A) <= P.Force_Lower or else D.Actuators.Force (A) >= P.Force_Upper) then
                  Velocity_Deriv := 0.0; Length_Deriv := 0.0;
               end if;
               Stiffness := Real'Max (0.0, -Length_Deriv); Damping := Real'Max (0.0, -Velocity_Deriv);
               Scale := K.Discrete_Scale (Stiffness, Damping, H);
               if Use_Couplings and then Scale > 0.0 then
                  Has_Couplings := True;
                  for I in 0 .. N - 1 loop
                     if Moment (I) /= 0.0 then Coupled (D.Joint_Config (I).Body_Id) := True; end if;
                  end loop;
               end if;
               for I in 0 .. N-1 loop
                  if Use_Couplings then Backbone (I*N+I) := Backbone (I*N+I)+(Moment (I)*Scale)*Moment (I); end if;
                  if Use_Couplings then Shift (I) := Shift (I) - ((H*Stiffness)*D.Actuators.Velocity (A))*Moment (I); end if;
                  for J in 0 .. N-1 loop
                     if Connected (D,I,J) then Deriv (I*N+J) := Deriv (I*N+J) + (Moment (I)*Velocity_Deriv)*Moment (J); end if;
                     if Use_Couplings then Addition (I*N+J) := Addition (I*N+J) + (Moment (I)*Scale)*Moment (J); end if;
                  end loop;
               end loop;
            end;
         end loop;
      end if;
      if D.Tendons /= null then
         for T in 1 .. D.Tendons.Nt loop
            declare P : MJ.Spatial_Tendon_Models.Parameters renames D.Tendons.Tendons (T);
            begin
               Tendon_Moment (D,T,Moment,Result); if Result /= Success then return; end if;
               Speed := D.Tendon_Outputs (D.Tendons.Nt+T-1);
               Displacement := MJ.Spatial_Tendon_Models.Displacement (D.Tendon_Outputs (T-1),P.Lower,P.Upper);
               Length_Deriv := P.Stiffness+2.0*P.Spring_Linear*Displacement+3.0*P.Spring_Quadratic*Displacement*Displacement;
               Stiffness := (if D.Spring_Enabled and then Displacement /= 0.0 then Real'Max (0.0,Length_Deriv) else 0.0);
               Velocity_Deriv := (if D.Damper_Enabled then -(P.Damping+2.0*P.Damper_Linear*abs Speed+3.0*P.Damper_Quadratic*Speed*Speed) else 0.0);
               Damping := Real'Max (0.0,-Velocity_Deriv); Scale := K.Discrete_Scale (Stiffness,Damping,H);
               if Use_Couplings and then Scale > 0.0 then
                  Has_Couplings := True;
                  for I in 0 .. N - 1 loop
                     if Moment (I) /= 0.0 then Coupled (D.Joint_Config (I).Body_Id) := True; end if;
                  end loop;
               end if;
               for I in 0 .. N-1 loop
                  if Use_Couplings then Backbone (I*N+I) := Backbone (I*N+I)+(Moment (I)*Scale)*Moment (I); end if;
                  if Use_Couplings then Shift (I) := Shift (I)-((H*Stiffness)*Speed)*Moment (I); end if;
                  for J in 0 .. N-1 loop
                     if Connected (D,I,J) then Deriv (I*N+J) := Deriv (I*N+J)+(Moment (I)*Velocity_Deriv)*Moment (J); end if;
                     if Use_Couplings then Addition (I*N+J) := Addition (I*N+J)+(Moment (I)*Scale)*Moment (J); end if;
                  end loop;
               end loop;
            end;
         end loop;
      end if;
      Integration_Fluid.Add (D,Discrete,not Full_Bias,Fluid,Result); if Result /= Success then return; end if;
      for I in 0 .. N-1 loop
         for J in 0 .. N-1 loop
            if Connected (D,I,J) then Deriv (I*N+J) := Deriv (I*N+J)+Fluid (I*N+J); end if;
            if Discrete then
               Addition (I*N+J) := Addition (I*N+J)-H*Fluid (Natural'Max (I,J)*N+Natural'Min (I,J));
               Backbone (I*N+J) := Backbone (I*N+J)-H*Fluid (Natural'Max (I,J)*N+Natural'Min (I,J));
            end if;
         end loop;
      end loop;
      for C in 0 .. N-1 loop
         if Full_Bias or else (Standalone_Free (D,C) and then (not Discrete or else not Coupled (D.Joint_Config (C).Body_Id))) then
            Bias_Column (D,C,Bias);
            for R in 0 .. N-1 loop
               if Full_Bias or else (Standalone_Free (D,R) and then D.Joint_Config (R).Body_Id=D.Joint_Config (C).Body_Id) then
                  Deriv (R*N+C) := Deriv (R*N+C)-Bias (R);
                  if Discrete then Gyro (R*N+C) := H*Bias (R); end if;
               end if;
            end loop;
         end if;
      end loop;
      Result := Success;
   end Build;
end MJ.Data.Integration_Operators;

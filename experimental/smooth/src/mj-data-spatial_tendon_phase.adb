with MJ.Manifold_Math;
with MJ.Data.Pipeline;
with MJ.Spatial_Tendons;
with MJ.Spatial_Tendon_Models;
with MJ.Tendon_Vectors;
with MJ.Tendon_Kernels;

package body MJ.Data.Spatial_Tendon_Phase with SPARK_Mode is
   package ST renames MJ.Spatial_Tendons;
   package TM renames MJ.Spatial_Tendon_Models;
   package TV renames MJ.Tendon_Vectors;
   package TK renames MJ.Tendon_Kernels;
   use type ST.Evaluation_Status;

   procedure Compute_Passive (D : in out Simulation; Result : out Status) is
      Nt : constant Natural := Tendon_Count (D);
      Outputs : Real_Array (0 .. 3 * Nt - 1) := (others => 0.0);
      Nv : constant Natural := D.Nv;
      Nb : constant Natural := D.Nb;
      Delta_Rotation : Vector := Zero;
      Displacement : Real;
      Springs, Dampers, Total : Real_Array (0 .. Nv - 1) := (others => 0.0);
   begin
      Result := Numeric_Limit;
      --  Same two force channels as mj_springdamper, combined only at the end.
      if D.Nq = D.Nv then
      for J in 0 .. D.Nj - 1 loop
         Springs (J) := MJ.Smooth_Kernels.Passive_Force (D.State.Qpos (J),
           D.Joint_Config (J).Spring_Reference, D.State.Qvel (J),
           D.Joint_Config (J).Stiffness, D.Joint_Config (J).Damping,
           D.Spring_Enabled, False);
         Dampers (J) := MJ.Smooth_Kernels.Passive_Force (D.State.Qpos (J),
           D.Joint_Config (J).Spring_Reference, D.State.Qvel (J),
           D.Joint_Config (J).Stiffness, D.Joint_Config (J).Damping,
           False, D.Damper_Enabled);
      end loop;
      else
         for J in 0 .. D.Nv - 1 loop
            declare
               P : constant Joint_Parameters := D.Joint_Config (J);
            begin
               if not D.Spring_Enabled or else P.Stiffness = 0.0 then
                  Displacement := 0.0;
               elsif P.Group_Type in 0 .. 1 and then P.Kind = Hinge_Joint then
                  if P.Component = (if P.Group_Type = 0 then 3 else 0) then
                     Delta_Rotation := MJ.Manifold_Math.Difference
                       (Read_Quaternion (D.State.Qpos.all, P.Qadr), P.Spring_Quaternion);
                  end if;
                  Displacement := Delta_Rotation (P.Component - (if P.Group_Type = 0 then 3 else 0));
               else
                  Displacement := D.State.Qpos (P.Qadr) - P.Spring_Reference;
               end if;
               Springs (J) := (if D.Spring_Enabled then -P.Stiffness * Displacement else 0.0);
               Dampers (J) := (if D.Damper_Enabled then -P.Damping * D.State.Qvel (J) else 0.0);
            end;
         end loop;
      end if;
      if D.Tendons /= null then
         if D.Tendons.Has_Spatial then
            Pipeline.Ensure_Jacobians (D, Result);
            if Result /= Success then return; end if;
         end if;
         Result := Numeric_Limit;
         declare
            Ns : constant Natural := D.Tendons.Ns;
            Ng : constant Natural := D.Tendons.Ng;
            Sites : ST.Site_Array (0 .. Ns - 1) := D.Tendons.Sites;
            Geoms : ST.Geometry_Array (0 .. Ng - 1) := D.Tendons.Geometries;
            Origins : ST.Vector_Array (0 .. Nb - 1);
            R : TV.Matrix;
            V, Position : TV.Vector;
            B : Natural;
         begin
            if D.Tendons.Has_Spatial then
            for Body_Id in Origins'Range loop
               --  The linear Jacobian is evaluated at the COM, not xpos.
               Origins (Body_Id) := (D.Kinematic.Bodies (Body_Id).Center (0),
                 D.Kinematic.Bodies (Body_Id).Center (1), D.Kinematic.Bodies (Body_Id).Center (2));
            end loop;
            for I in Sites'Range loop
               B := Sites (I).Body_Id;
               for A in 1 .. 3 loop
                  Position (A) := D.Kinematic.Bodies (B).Position (A - 1);
                  for C in 1 .. 3 loop R (A, C) := D.Kinematic.Bodies (B).Rotation (A - 1, C - 1); end loop;
               end loop;
               if not TV.Rotation_Bounded (R) or else not TV.Bounded (Position, 1.0e10) then return; end if;
               Sites (I).Position := TV.Add (Position, TV.Multiply (R, Sites (I).Position));
            end loop;
            for I in Geoms'Range loop
               B := Geoms (I).Body_Id;
               for A in 1 .. 3 loop
                  Position (A) := D.Kinematic.Bodies (B).Position (A - 1);
                  for C in 1 .. 3 loop R (A, C) := D.Kinematic.Bodies (B).Rotation (A - 1, C - 1); end loop;
               end loop;
               if not TV.Rotation_Bounded (R) or else not TV.Bounded (Position, 1.0e10) then return; end if;
               Geoms (I).Position := TV.Add (Position, TV.Multiply (R, Geoms (I).Position));
               for C in 1 .. 3 loop
                  V := TV.Multiply (R, (Geoms (I).Orientation (1, C),
                    Geoms (I).Orientation (2, C), Geoms (I).Orientation (3, C)));
                  for A in 1 .. 3 loop Geoms (I).Orientation (A, C) := V (A); end loop;
               end loop;
            end loop;
            if not ST.Valid_Flat_Kinematics (Sites, Geoms, Origins,
              D.Kinematic.Linear_Jacobian.all, D.Kinematic.Angular_Jacobian.all, Nv) then return; end if;
            end if;
            for T in D.Tendons.Tendons'Range loop
               declare
                  P : constant TM.Parameters := D.Tendons.Tendons (T);
                  Route : constant ST.Route_Array (0 .. P.Count - 1) :=
                    D.Tendons.Nodes (P.First + 1 .. P.First + P.Count);
                  Points : ST.Point_Array (0 .. 3 * P.Count - 1);
                  Row : Real_Array (0 .. Nv - 1);
                  Length, Velocity, Spring, Damper : Real;
                  Count : Natural;
                  Eval : ST.Evaluation_Status;
               begin
                  if P.Fixed then
                     MJ.Tendon_Kernels.Fixed_Kinematics
                       (D.Tendons.Terms (P.First + 1 .. P.First + P.Count),
                        D.Tendons.Jacobian (P.First + 1 .. P.First + P.Jacobian_Count),
                        D.State.Qpos.all, D.State.Qvel.all, Length, Velocity);
                  else
                  if not ST.Valid_Path (Route, Sites, Geoms) then return; end if;
                  ST.Evaluate_Flat (Route, Sites, Geoms, Origins,
                               D.Kinematic.Linear_Jacobian.all, D.Kinematic.Angular_Jacobian.all,
                               Eval, Length, Row, Points, Count);
                  if Eval /= ST.Success or else Length not in 0.0 .. 1.0e30 then return; end if;
                  Velocity := ST.Velocity (Row, D.State.Qvel.all);
                  end if;
                  if Velocity not in -1.0e30 .. 1.0e30 then return; end if;
                  TM.Spring_Damper (P, Length, Velocity, D.Spring_Enabled, D.Damper_Enabled, Spring, Damper);
                  Outputs (T - 1) := Length;
                  Outputs (Nt + T - 1) := Velocity;
                  Outputs (2 * Nt + T - 1) := Spring + Damper;
                  if Spring /= 0.0 or else Damper /= 0.0 then
                     if P.Fixed then
                        if Spring in TK.Small_Force and then Damper in TK.Small_Force then
                           for E of D.Tendons.Jacobian (P.First + 1 .. P.First + P.Jacobian_Count) loop
                              Springs (E.Dof) := TK.Project_Small (Springs (E.Dof), E.Coefficient, Spring);
                              Dampers (E.Dof) := TK.Project_Small (Dampers (E.Dof), E.Coefficient, Damper);
                           end loop;
                        else
                           for E of D.Tendons.Jacobian (P.First + 1 .. P.First + P.Jacobian_Count) loop
                              Springs (E.Dof) := Springs (E.Dof) + E.Coefficient * Spring;
                              Dampers (E.Dof) := Dampers (E.Dof) + E.Coefficient * Damper;
                              if Springs (E.Dof) not in -1.0e60 .. 1.0e60
                                or else Dampers (E.Dof) not in -1.0e60 .. 1.0e60 then return; end if;
                           end loop;
                        end if;
                     else
                     for K in Row'Range loop
                        Springs (K) := Springs (K) + Row (K) * Spring;
                        Dampers (K) := Dampers (K) + Row (K) * Damper;
                        if Springs (K) not in -1.0e60 .. 1.0e60
                          or else Dampers (K) not in -1.0e60 .. 1.0e60 then return; end if;
                     end loop;
                     end if;
                  end if;
               end;
            end loop;
         end;
      end if;
      for K in Total'Range loop
         Total (K) := Springs (K) + Dampers (K);
         if Total (K) not in -Work_Limit .. Work_Limit then return; end if;
      end loop;
      --  Publication is atomic. No partial tendon force escapes on failure.
      D.Dynamics.Passive.all := Total;
      if Nt > 0 then D.Tendon_Outputs.all := Outputs; end if;
      Result := Success;
   end Compute_Passive;
end MJ.Data.Spatial_Tendon_Phase;

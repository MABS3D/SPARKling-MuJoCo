with MJ.Spatial_Kernels;
with Ada.Unchecked_Deallocation;
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Fluid_Kernels;
package body MJ.Data.Fluid_Phase with SPARK_Mode is
   package FK renames MJ.Fluid_Kernels;
   procedure Free_Elements is new Ada.Unchecked_Deallocation (FK.Element_Array, FK.Element_Access);
   procedure Release (D : in out Simulation) is
   begin
      Free_Elements (D.Fluid_Elements);
      D.Fluid := (others => <>);
   end Release;

   procedure Initialize (M : MJ.Models.Model; D : in out Simulation; Result : out Status) is
      use Ada.Numerics.Long_Elementary_Functions;
      type Flags is array (Natural range <>) of Boolean;
      Ellipsoids : Flags (0 .. D.Nb-1) := [others => False];
      Count : Natural := 0;
      Next : Natural := 0;
      Ok : Boolean;
      Q : Quaternion;
   begin
      Result := Invalid_Model;
      if M.Opt.Density not in Nonneg_Tier0 or else M.Opt.Viscosity not in Nonneg_Tier0
        or else not Bounded (Read_Vector (M.Opt.Wind, 0), Max_Val) then return; end if;
      D.Fluid := (M.Opt.Density, M.Opt.Viscosity, Read_Vector (M.Opt.Wind, 0));
      if (D.Fluid.Density = 0.0 and then D.Fluid.Viscosity = 0.0)
        or else (not D.Spring_Enabled and then not D.Damper_Enabled) then
         Result := Success; return;
      end if;
      for G in 0 .. M.S.Ngeom-1 loop
         if M.Geoms.Geom_Bodyid(G) not in 0 .. D.Nb-1 then return; end if;
         if M.Geoms.Geom_Fluid(12*G) > 0.0 then
            Ellipsoids (M.Geoms.Geom_Bodyid(G)) := True;
         end if;
      end loop;
      for B in 1 .. D.Nb-1 loop
         if D.Body_Config(B).Mass >= Min_Val then
            if not Ellipsoids(B) then Count := Count + 1;
            else
               for G in 0 .. M.S.Ngeom-1 loop
                  if M.Geoms.Geom_Bodyid(G) = B and then M.Geoms.Geom_Fluid(12*G) /= 0.0 then
                     Count := Count + 1;
                  end if;
               end loop;
            end if;
         end if;
      end loop;
      D.Fluid_Elements := new FK.Element_Array (0 .. Integer(Count)-1);
      for B in 1 .. D.Nb-1 loop
         if D.Body_Config(B).Mass >= Min_Val then
            if not Ellipsoids(B) then
               declare
                  E : FK.Element;
                  C : Body_Parameters renames D.Body_Config(B);
               begin
                  E.Body_Id := B; E.Inverse_Mass := 1.0/D.Body_Config(B).Mass;
                  E.Position := C.Inertial_Position;
                  E.Rotation := Rotation(C.Inertial_Orientation);
                  E.Box := [
                    Sqrt(Real'Max(Min_Val, C.Inertia(1)+C.Inertia(2)-C.Inertia(0))/C.Mass*6.0),
                    Sqrt(Real'Max(Min_Val, C.Inertia(0)+C.Inertia(2)-C.Inertia(1))/C.Mass*6.0),
                    Sqrt(Real'Max(Min_Val, C.Inertia(0)+C.Inertia(1)-C.Inertia(2))/C.Mass*6.0)];
                  if not Bounded(E.Box,1.0e14) then return; end if;
                  E.Box_Data := FK.Prepare_Box(E.Box,D.Fluid.Density,D.Fluid.Viscosity);
                  D.Fluid_Elements(Next) := E; Next := Next+1;
               end;
            else
               for G in 0 .. M.S.Ngeom-1 loop
                  if M.Geoms.Geom_Bodyid(G) = B and then M.Geoms.Geom_Fluid(12*G) /= 0.0 then
                     declare
                        E : FK.Element;
                        P : FK.Ellipsoid_Parameters renames E.Parameters;
                        A : constant Natural := 12*G;
                     begin
                        E.Body_Id := B; E.Inverse_Mass := 1.0/D.Body_Config(B).Mass; E.Is_Ellipsoid := True;
                        E.Position := Read_Vector(M.Geoms.Geom_Pos.all,3*G);
                        if not Bounded(E.Position,Max_Val) then return; end if;
                        Q := Read_Quaternion(M.Geoms.Geom_Quat.all,4*G);
                        Normalize(Q,Ok); if not Ok then return; end if;
                        E.Rotation := Rotation(Q);
                        for K in 0 .. 5 loop
                           if M.Geoms.Geom_Fluid(A+K) not in Nonneg_Tier0 then return; end if;
                        end loop;
                        P.Interaction := M.Geoms.Geom_Fluid(A);
                        P.Blunt := M.Geoms.Geom_Fluid(A+1);
                        P.Slender := M.Geoms.Geom_Fluid(A+2);
                        P.Angular := M.Geoms.Geom_Fluid(A+3);
                        P.Kutta := M.Geoms.Geom_Fluid(A+4);
                        P.Magnus := M.Geoms.Geom_Fluid(A+5);
                        P.Virtual_Mass := Read_Vector(M.Geoms.Geom_Fluid.all,A+6);
                        P.Virtual_Inertia := Read_Vector(M.Geoms.Geom_Fluid.all,A+9);
                        P.Size := Read_Vector(M.Geoms.Geom_Size.all,3*G);
                        case M.Geoms.Geom_Type(G) is
                           when 2 => P.Size := [others => P.Size(0)];
                           when 3 => P.Size := [P.Size(0),P.Size(0),P.Size(1)+P.Size(0)];
                           when 5 => P.Size := [P.Size(0),P.Size(0),P.Size(1)];
                           when others => null;
                        end case;
                        if (for some X of P.Size => X not in Nonneg_Tier0)
                          or else not Bounded(P.Virtual_Mass,Max_Val)
                          or else not Bounded(P.Virtual_Inertia,Max_Val) then return; end if;
                        E.Ellipsoid_Data := FK.Prepare_Ellipsoid(P);
                        D.Fluid_Elements(Next) := E; Next := Next+1;
                     end;
                  end if;
               end loop;
            end if;
         end if;
      end loop;
      Result := Success;
   end Initialize;

   procedure Accumulate (D : in out Simulation; Result : out Status;
                         Root_Velocity : MJ.Fluid_Kernels.Motion_Array := MJ.Fluid_Kernels.No_Motions) is
      type Vectors is array (Natural range <>) of Vector;
      Linear, Angular : Vectors (0 .. (if Root_Velocity'Length = 0 then D.Nb-1 else -1)) := [others => Zero];
      Forces, Torques : Vectors (0 .. D.Nb-1) := [others => Zero];
      R : Matrix;
      Offset, LV, AV, F, T : Vector;
      W : FK.Wrench;
      Value : Real;
   begin
      Result := Success;
      if D.Fluid_Elements = null or else D.Fluid_Elements'Length = 0 then return; end if;
      Result := Numeric_Limit;
      if Root_Velocity'Length = 0 then
      --  Velocities at body origins, constructed once in topological order.
      for B in 1 .. D.Nb-1 loop
         declare
            C : Body_Parameters renames D.Body_Config(B);
            Parent : constant Natural := C.Parent;
         begin
            Angular(B) := Angular(Parent);
            Linear(B) := Linear(Parent) + Cross(Angular(Parent),
              D.Kinematic.Bodies(B).Position-D.Kinematic.Bodies(Parent).Position);
            for K in 0 .. C.Joint_Count-1 loop
               declare
                  J : constant Natural := C.First_Joint+K;
                  Speed : constant Real := D.State.Qvel(D.Joint_Config(J).Vadr);
                  Axis : Vector := D.Kinematic.Joints(J).Direction;
               begin
                  if D.Joint_Config(J).Kind = Hinge_Joint then
                     Angular(B) := Angular(B) + Speed*Axis;
                     Axis := Cross(Axis,D.Kinematic.Bodies(B).Position-D.Kinematic.Joints(J).Anchor);
                  end if;
                  Linear(B) := Linear(B) + Speed*Axis;
               end;
            end loop;
            if not Bounded(Linear(B),1.0e12) or else not Bounded(Angular(B),1.0e12) then return; end if;
         end;
      end loop;
      end if;
      for E of D.Fluid_Elements.all loop
         declare
            B : constant Natural := E.Body_Id;
            BR : Matrix renames D.Kinematic.Bodies(B).Rotation;
         begin
            Offset := Apply(BR,E.Position);
            if E.Is_Ellipsoid then
            --  Preserve C's subtraction in the local frame, including wind.
            for I in Axis loop
               for J in Axis loop
                  R(I,J) := BR(I,0)*E.Rotation(0,J) + BR(I,1)*E.Rotation(1,J) + BR(I,2)*E.Rotation(2,J);
               end loop;
            end loop;
            else
               R := D.Kinematic.Bodies(B).Inertial_Rotation;
            end if;
            if Root_Velocity'Length > 0 then
               declare
                  V : MJ.Spatial_Kernels.Motion renames Root_Velocity(B);
                  Center_Offset : constant Vector := [D.Kinematic.Spatial_Inertias(10*B+6)*E.Inverse_Mass,
                    D.Kinematic.Spatial_Inertias(10*B+7)*E.Inverse_Mass,D.Kinematic.Spatial_Inertias(10*B+8)*E.Inverse_Mass];
                  Point_Offset : constant Vector := (Offset + (D.Kinematic.Bodies(B).Position-D.Kinematic.Bodies(B).Center)) + Center_Offset;
                  Omega : constant Vector := [V(0),V(1),V(2)];
                  Speed : constant Vector := [V(3),V(4),V(5)];
               begin
                  AV := Apply_Transpose(R,Omega);
                  LV := Apply_Transpose(R,Speed+Cross(Omega,Point_Offset)) - Apply_Transpose(R,D.Fluid.Wind);
               end;
            else
               AV := Apply_Transpose(R,Angular(B));
               LV := Apply_Transpose(R,Linear(B)+Cross(Angular(B),Offset)) - Apply_Transpose(R,D.Fluid.Wind);
            end if;
            if not Bounded(LV,1.0e12) or else not Bounded(AV,1.0e12) then return; end if;
            W := (if E.Is_Ellipsoid then FK.Ellipsoid(E.Parameters,E.Ellipsoid_Data,D.Fluid.Density,D.Fluid.Viscosity,LV,AV)
                  else FK.Apply_Box(E.Box_Data,LV,AV));
            F := Apply(R,W.Force); T := Apply(R,W.Torque);
            Forces(B) := Forces(B)+F;
            Torques(B) := Torques(B)+(T+Cross(Offset,F));
            if not Bounded(Forces(B)) or else not Bounded(Torques(B)) then return; end if;
         end;
      end loop;
      --  Accumulate each subtree's wrench once. Equivalent to summing each
      --  element's ancestor Jacobian projection, with a different FP order.
      for B in reverse 1 .. D.Nb-1 loop
         declare
            C : Body_Parameters renames D.Body_Config(B);
            Parent : constant Natural := C.Parent;
         begin
            for K in 0 .. C.Joint_Count-1 loop
               declare
                  J : constant Natural := C.First_Joint+K;
                  V : constant Natural := D.Joint_Config(J).Vadr;
                  Axis : Vector renames D.Kinematic.Joints(J).Direction;
               begin
                  if D.Joint_Config(J).Kind = Hinge_Joint then
                     T := Torques(B) + Cross(D.Kinematic.Bodies(B).Position-D.Kinematic.Joints(J).Anchor,Forces(B));
                     Value := Dot(Axis,T);
                  else Value := Dot(Axis,Forces(B)); end if;
                  Value := D.Dynamics.Passive(V) + Value;
                  if not Within_Work(Value) then return; end if;
                  D.Dynamics.Passive(V) := Value;
               end;
            end loop;
            if Parent > 0 then
               Forces(Parent) := Forces(Parent)+Forces(B);
               Torques(Parent) := Torques(Parent)+(Torques(B)+Cross(
                 D.Kinematic.Bodies(B).Position-D.Kinematic.Bodies(Parent).Position,Forces(B)));
               if not Bounded(Forces(Parent)) or else not Bounded(Torques(Parent)) then return; end if;
            end if;
         end;
      end loop;
      Result := Success;
   end Accumulate;
end MJ.Data.Fluid_Phase;

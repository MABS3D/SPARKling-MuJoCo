with MJ.Fluid_Metadata;
with MJ.Data.Fluid_Tree;
with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;
with Ada.Unchecked_Deallocation;
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Fluid_Kernels;
package body MJ.Data.Fluid_Phase with SPARK_Mode is
   package FK renames MJ.Fluid_Kernels;
   use type FK.Element;
   procedure Free_Elements is new Ada.Unchecked_Deallocation (FK.Element_Array, FK.Element_Access);
   procedure Release (Elements : in out MJ.Fluid_Kernels.Element_Access; Fluid : out Fluid_Options) is
   begin
      Free_Elements (Elements);
      Fluid := (others => <>);
   end Release;

   procedure Make_Box
     (C : Body_Parameters; Body_Id, Nb : Natural; Fluid : Fluid_Options;
      E : out FK.Element; Ok : out Boolean) with Global => null,
     Pre => Body_Id > 0 and then Body_Id < Nb and then C.Mass >= Min_Val
       and then Bounded (C.Inertial_Position, Max_Val) and then Bounded (C.Inertia, Max_Val)
       and then Unit_Quaternion (C.Inertial_Orientation),
     Post => (if Ok then FK.Element_Valid (E, Nb) and then not E.Is_Ellipsoid
       and then E.Body_Id = Body_Id and then E.Inverse_Mass = 1.0/C.Mass
       and then E.Position = C.Inertial_Position and then E.Rotation = Rotation (C.Inertial_Orientation))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", FK.Element_Valid);
   begin
      E := (others => <>); Ok := False;
                  E.Body_Id := Body_Id; E.Inverse_Mass := MJ.Fluid_Metadata.Inverse_Mass (C.Mass);
                  E.Position := C.Inertial_Position;
                  E.Rotation := Rotation(C.Inertial_Orientation);
                  E.Box := [
                    MJ.Fluid_Metadata.Box_Length (C.Inertia (0), C.Inertia (1), C.Inertia (2), C.Mass),
                    MJ.Fluid_Metadata.Box_Length (C.Inertia (1), C.Inertia (0), C.Inertia (2), C.Mass),
                    MJ.Fluid_Metadata.Box_Length (C.Inertia (2), C.Inertia (0), C.Inertia (1), C.Mass)];
                  if (for some X of E.Box => X not in FK.Dimension)
                    or else (E.Box (0) + E.Box (1) + E.Box (2)) / 3.0 not in FK.Dimension then return; end if;
                  E.Box_Data := FK.Prepare_Box(E.Box,Fluid.Density,Fluid.Viscosity);
      Ok := FK.Element_Valid (E, Nb);
   end Make_Box;

   procedure Make_Ellipsoid
     (M : MJ.Models.Model; G, Body_Id, Nb : Natural; Mass : Nonneg_Tier0;
      E : out FK.Element; Ok : out Boolean) with Global => null,
     Pre => MJ.Models.Sizes_In_Range (M.S) and then MJ.Models.Geom_Layout_OK (M.S, M.Geoms)
       and then G < M.S.Ngeom and then Body_Id > 0 and then Body_Id < Nb and then Mass >= Min_Val,
     Post => (if Ok then FK.Element_Valid (E, Nb) and then E.Is_Ellipsoid
       and then E.Body_Id = Body_Id and then E.Inverse_Mass = 1.0/Mass
       and then E.Position = Read_Vector (M.Geoms.Geom_Pos.all, 3*G)
       and then E.Parameters.Interaction = M.Geoms.Geom_Fluid (12*G)
       and then E.Parameters.Blunt = M.Geoms.Geom_Fluid (12*G+1)
       and then E.Parameters.Slender = M.Geoms.Geom_Fluid (12*G+2)
       and then E.Parameters.Angular = M.Geoms.Geom_Fluid (12*G+3)
       and then E.Parameters.Kutta = M.Geoms.Geom_Fluid (12*G+4)
       and then E.Parameters.Magnus = M.Geoms.Geom_Fluid (12*G+5))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", FK.Element_Valid);
      P : FK.Ellipsoid_Parameters renames E.Parameters;
      A : constant Natural := 12*G;
      Q : Quaternion;
      Normal : Boolean;
   begin
      E := (others => <>); Ok := False;
                        E.Body_Id := Body_Id; E.Inverse_Mass := MJ.Fluid_Metadata.Inverse_Mass (Mass); E.Is_Ellipsoid := True;
                        E.Position := Read_Vector(M.Geoms.Geom_Pos.all,3*G);
                        if not Bounded(E.Position,Max_Val) then return; end if;
                        Q := Read_Quaternion(M.Geoms.Geom_Quat.all,4*G);
                        Normalize(Q,Normal); if not Normal then return; end if;
                        E.Rotation := Rotation(Q);
                        for K in 0 .. 5 loop
                           if M.Geoms.Geom_Fluid(A+K) not in Nonneg_Tier0 then return; end if;
                           pragma Loop_Invariant (for all L in 0 .. K => M.Geoms.Geom_Fluid (A+L) in Nonneg_Tier0);
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
                        if not Bounded (P.Size, Max_Val) then return; end if;
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
      Ok := FK.Element_Valid (E, Nb);
   end Make_Ellipsoid;

   procedure Append_Element
     (Elements : in out FK.Element_Array; Next : in out Natural; Nb : Natural; E : FK.Element)
     with Global => null,
     Pre => Elements'First = 0 and then Elements'Length <= Natural'Last
       and then Next < Elements'Length and then FK.Element_Valid (E, Nb)
       and then (for all I in 0 .. Next-1 => FK.Element_Valid (Elements (I), Nb)),
     Post => Next = Next'Old+1
       and then (for all I in 0 .. Next-1 => FK.Element_Valid (Elements (I), Nb))
       and then (for all I in Elements'Range => Elements (I) = (if I = Next'Old then E else Elements'Old (I)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", FK.Element_Valid);
   begin
      Elements (Next) := E;
      Next := Next+1;
   end Append_Element;

   procedure Build
     (M : MJ.Models.Model; Bodies : Body_Parameter_Array;
      Spring_Enabled, Damper_Enabled : Boolean; Fluid : out Fluid_Options;
      Elements : in out MJ.Fluid_Kernels.Element_Access; Result : out Status) with Global => null,
     Pre => Elements = null and then MJ.Models.Sizes_In_Range (M.S)
       and then MJ.Models.Geom_Layout_OK (M.S, M.Geoms)
       and then Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
       and then Bodies'Length = M.S.Nbody
       and then (for all B of Bodies => Bounded (B.Inertial_Position, Max_Val)
         and then Bounded (B.Inertia, Max_Val) and then Unit_Quaternion (B.Inertial_Orientation)),
     Post => (if Result = Success then MJ.Fluid_Kernels.Storage_Valid (Elements, Bodies'Length)
       and then Fluid.Density = M.Opt.Density and then Fluid.Viscosity = M.Opt.Viscosity
       and then Fluid.Wind = Read_Vector (M.Opt.Wind, 0))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", FK.Element_Valid);
      Nb : constant Natural := Bodies'Length;
      type Flags is array (Natural range <>) of Boolean;
      Ellipsoids : Flags (0 .. Nb-1) := [others => False];
      Count : Natural := 0;
      Next : Natural := 0;
      Ok : Boolean;
   begin
      Fluid := (others => <>);
      Result := Invalid_Model;
      if M.Opt.Density not in Nonneg_Tier0 or else M.Opt.Viscosity not in Nonneg_Tier0
        or else not Bounded (Read_Vector (M.Opt.Wind, 0), Max_Val) then return; end if;
      Fluid := (M.Opt.Density, M.Opt.Viscosity, Read_Vector (M.Opt.Wind, 0));
      if (Fluid.Density = 0.0 and then Fluid.Viscosity = 0.0)
        or else (not Spring_Enabled and then not Damper_Enabled) then
         Result := Success; return;
      end if;
      for G in 0 .. M.S.Ngeom-1 loop
         if M.Geoms.Geom_Bodyid(G) not in 0 .. Bodies'Length-1 then return; end if;
         if M.Geoms.Geom_Fluid(12*G) > 0.0 then
            Ellipsoids (M.Geoms.Geom_Bodyid(G)) := True;
         end if;
      end loop;
      for B in 1 .. Bodies'Length-1 loop
         if Bodies(B).Mass >= Min_Val then
            if not Ellipsoids(B) then if Count = Natural'Last then return; end if; Count := Count + 1;
            else
               for G in 0 .. M.S.Ngeom-1 loop
                  if M.Geoms.Geom_Bodyid(G) = B and then M.Geoms.Geom_Fluid(12*G) /= 0.0 then
                     if Count = Natural'Last then return; end if; Count := Count + 1;
                  end if;
               end loop;
            end if;
         end if;
      end loop;
      Elements := new FK.Element_Array (0 .. Integer(Count)-1);
      for B in 1 .. Bodies'Length-1 loop
         pragma Loop_Invariant (Elements /= null and then Elements'First = 0 and then Elements'Length = Count);
         pragma Loop_Invariant (Next <= Count);
         pragma Loop_Invariant (for all I in 0 .. Next - 1 => FK.Element_Valid (Elements (I), Nb));
         if Bodies(B).Mass >= Min_Val then
            if not Ellipsoids(B) then
               declare
                  E : FK.Element;
               begin
                  Make_Box (Bodies (B), B, Nb, Fluid, E, Ok);
                  if not Ok or else Next >= Count then return; end if;
                  Append_Element (Elements.all, Next, Nb, E);
               end;
            else
               for G in 0 .. M.S.Ngeom-1 loop
         pragma Loop_Invariant (Elements /= null and then Elements'First = 0 and then Elements'Length = Count);
         pragma Loop_Invariant (Next <= Count);
         pragma Loop_Invariant (for all I in 0 .. Next - 1 => FK.Element_Valid (Elements (I), Nb));
                  if M.Geoms.Geom_Bodyid(G) = B and then M.Geoms.Geom_Fluid(12*G) /= 0.0 then
                     declare
                        E : FK.Element;
                     begin
                        Make_Ellipsoid (M, G, B, Nb, Bodies (B).Mass, E, Ok);
                        if not Ok or else Next >= Count then return; end if;
                        Append_Element (Elements.all, Next, Nb, E);
                     end;
                  end if;
               end loop;
            end if;
         end if;
      end loop;
      if Next /= Count then return; end if;
      Result := Success;
   end Build;

   procedure Initialize
     (M : MJ.Models.Model; Bodies : Body_Parameter_Array;
      Spring_Enabled, Damper_Enabled : Boolean; Fluid : out Fluid_Options;
      Elements : in out MJ.Fluid_Kernels.Element_Access; Result : out Status) is
   begin
      Build (M, Bodies, Spring_Enabled, Damper_Enabled, Fluid, Elements, Result);
      if Result /= Success then Release (Elements, Fluid); end if;
   end Initialize;

   procedure Build_Wrenches
     (D : Simulation; Root_Velocity : FK.Motion_Array;
      Forces, Torques : out FK.Vector_Array; Result : out Status)
     with Global => null,
     Pre => Is_Ready (D) and then Positions_Current (D)
       and then Forces'First = 0 and then Forces'Last = D.Nb-1
       and then Torques'First = 0 and then Torques'Last = D.Nb-1
       and then (if Root_Velocity'Length /= 0 then
         Root_Velocity'First = 0 and then Root_Velocity'Length in 1 .. Max_Bodies
         and then Root_Velocity'Length = D.Nb
         and then FK.Motions_Bounded (Root_Velocity) and then D.Cache.Spatial_Valid),
     Post => (if Result = Success then (for all F of Forces => Bounded (F))
       and then (for all T of Torques => Bounded (T)))
   is
      Nb : constant Natural := D.Nb;
      subtype Vectors is FK.Vector_Array;
      Linear, Angular : Vectors (0 .. (if Root_Velocity'Length = 0 then Nb-1 else -1)) := [others => Zero];
      R : Matrix;
      Offset, LV, AV, F, T : Vector;
      W : FK.Wrench;
   begin
      Forces := [others => Zero]; Torques := [others => Zero];
      Result := Success;
      if D.Fluid_Elements = null or else D.Fluid_Elements'Length = 0 then return; end if;
      Result := Numeric_Limit;
      if Root_Velocity'Length = 0 then
      --  Velocities at body origins, constructed once in topological order.
      for B in 1 .. D.Nb-1 loop
         declare
            C : constant Body_Parameters := D.Body_Config(B);
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
         pragma Loop_Invariant (for all F of Forces => Bounded (F));
         pragma Loop_Invariant (for all T of Torques => Bounded (T));
         declare
            B : constant Natural := E.Body_Id;
            BR : constant Matrix := D.Kinematic.Bodies(B).Rotation;
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
      Result := Success;
   end Build_Wrenches;

   procedure Accumulate (D : in out Simulation; Result : out Status;
                         Root_Velocity : MJ.Fluid_Kernels.Motion_Array := MJ.Fluid_Kernels.No_Motions) is
      Nb : constant Natural := D.Nb;
      Forces, Torques : FK.Vector_Array (0 .. Nb-1);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Build_Wrenches (D, Root_Velocity, Forces, Torques, Result);
      if Result /= Success then return; end if;
      if D.Fluid_Elements = null or else D.Fluid_Elements'Length = 0 then return; end if;
      --  Reverse parent-before-child traversal; each subtree is merged once.
      MJ.Data.Fluid_Tree.Fold
        (D.Body_Config.all, D.Joint_Config.all, D.Kinematic.Bodies.all, D.Kinematic.Joints.all,
         Forces, Torques, D.Dynamics.Passive.all, Result);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Accumulate;
end MJ.Data.Fluid_Phase;

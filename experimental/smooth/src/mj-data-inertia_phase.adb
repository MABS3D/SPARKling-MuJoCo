with MJ.Data.Compact_Assembly;
with MJ.Compact_Tendon_Mass;
with MJ.Compact_Inertia;
with MJ.Data.Composite_Assembly;
with MJ.Spatial_Tendon_Models;
with MJ.Data.External_Loads;
with MJ.Data.Mass_Publication;
with MJ.Composite_Bounds;
with MJ.Composite_Weights;
with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;
with MJ.Solver_Kernels;
with MJ.Solver_Reductions;
with MJ.Data.Pipeline;
with MJ.Data.Spatial;
with MJ.Smooth_Topology;

package body MJ.Data.Inertia_Phase with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   package CA renames MJ.Data.Composite_Assembly;
   subtype Composite_Array is CA.Composite_Array;
   package SK renames MJ.Spatial_Kernels;
   use type SK.Inertia;
   procedure Accumulate_Composite (Bodies : Body_Parameter_Array; Composite : in out Composite_Array)
     renames CA.Accumulate_Composite;
   procedure Load_Composite (Source : Real_Array; Composite : out Composite_Array)
     renames CA.Load_Composite;


   procedure Zero_CRB_Mass (Mass : out Real_Array; Nv : Natural)
     with Global => null,
       Pre => Nv <= 256 and then Mass'First = 0 and then Mass'Last = Nv * Nv - 1,
       Post => MJ.Smooth_Dynamics.Work_Array (Mass)
         and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv)
         and then (for all X of Mass => X = 0.0)
   is
   begin
      Mass := [others => 0.0];
   end Zero_CRB_Mass;
   pragma Inline_Always (Zero_CRB_Mass);

   --  Read only the CRB inputs; writes are restricted to the candidate mass.
   procedure Fill_CRB_Mass
     (Topology : MJ.Smooth_Topology.Cache; Composite : Composite_Array;
      Motions : Real_Array; Nv : Natural; Mass : in out Real_Array; Ok : in out Boolean)
     with Global => null,
       Pre => not Ok and then Nv in 1 .. Max_Dofs
         and then MJ.Smooth_Topology.Dof_Count (Topology) = Nv
         and then Composite'First = 0 and then Composite'Length in 1 .. Max_Bodies
         and then MJ.Smooth_Topology.Body_Count (Topology) = Composite'Length
         and then (for all X of Composite => SK.Bounded (X, 1.0e40))
         and then Motions'First = 0 and then Motions'Last = 6 * Nv - 1
         and then (for all X of Motions => X in -1.0e12 .. 1.0e12)
         and then MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
         and then MJ.Smooth_Dynamics.Work_Array (Mass)
         and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv),
       Post => MJ.Smooth_Dynamics.Work_Array (Mass)
         and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Work_Array);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      package T renames MJ.Smooth_Topology;
   begin
      for I in 0 .. Nv - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass)
           and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv));
         if T.Simple_Count (Topology, I) > 0 then
            MJ.Smooth_Dynamics.Store_Symmetric
              (Mass, Nv, I, I, T.Fixed_Inertia (Topology, I));
         else
            declare
               Product : constant SK.Motion := SK.Multiply
                 (Composite (T.Dof_Body (Topology, I)),
                  MJ.Spatial_Storage.Load_Motion (Motions, 6 * T.Dof_Joint (Topology, I)));
               J : Integer := I;
               Value : Real;
            begin
               while J >= 0 loop
                  pragma Loop_Variant (Decreases => J);
                  pragma Loop_Invariant (J in 0 .. I);
                  pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass)
                    and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv));
                  Value := (if J = I then T.Armature (Topology, I) else 0.0)
                    + SK.Dot (MJ.Spatial_Storage.Load_Motion (Motions, 6 * T.Dof_Joint (Topology, J)), Product);
                  if not Within_Work (Value) then return; end if;
                  MJ.Smooth_Dynamics.Store_Symmetric (Mass, Nv, I, J, Value);
                  J := T.Parent_Dof (Topology, J);
               end loop;
            end;
         end if;
      end loop;
      Ok := True;
   end Fill_CRB_Mass;
   pragma Inline_Always (Fill_CRB_Mass);

   procedure Try_Assemble_CRB (D : Simulation; Mass : out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid and then D.Cache.Spatial_Valid
       and then D.Nv <= 256
       and then Mass'First = 0 and then Mass'Last = D.Nv * D.Nv - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Mass)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, D.Nv)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Work_Array);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", CA.Accumulation_Model);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", CA.Model_Step);
      package SK renames MJ.Spatial_Kernels;
      package T renames MJ.Smooth_Topology;
      package CB renames MJ.Composite_Bounds;
      package CW renames MJ.Composite_Weights;
      Composite : Composite_Array (0 .. D.Nb - 1) with Relaxed_Initialization;
   begin
      Ok := False;
      Zero_CRB_Mass (Mass, D.Nv);
      if D.Nv = 0 then Ok := True; return; end if;
      Load_Composite (D.Kinematic.Spatial_Inertias.all, Composite);
      Accumulate_Composite (D.Body_Config.all, Composite);
      Fill_CRB_Mass
        (D.Topology, Composite, D.Kinematic.Spatial_Motions.all, D.Nv, Mass, Ok);
   end Try_Assemble_CRB;

   procedure Assemble_Dense_Mass
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Poses : Body_State_Array; Linear, Angular : Real_Array;
      Nv : Natural; Mass : in out Real_Array; Result : out Status)
     with Global => null,
       Pre => Nv <= Max_Dofs
         and then Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
         and then Joints'First = 0 and then Int64 (Joints'Length) = Int64 (Nv)
         and then Poses'First = 0 and then Poses'Last = Bodies'Last
         and then (for all B in Bodies'Range => Bounded (Bodies (B).Inertia, Max_Val)
           and then Bounded (Poses (B).Inertial_Rotation, 16.0))
         and then (for all J of Joints => J.Vadr < Nv)
         and then Linear'First = 0 and then Linear'Last = 3 * Bodies'Length * Nv - 1
         and then Angular'First = 0 and then Angular'Last = Linear'Last
         and then MJ.Smooth_Dynamics.Work_Array (Linear)
         and then MJ.Smooth_Dynamics.Work_Array (Angular)
         and then MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
         and then MJ.Smooth_Dynamics.Work_Array (Mass)
         and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv),
       Post => Result in Success | Numeric_Limit
         and then MJ.Smooth_Dynamics.Work_Array (Mass)
         and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
   begin
      Result := Numeric_Limit;
      --  Kinetic energy: M = sum(m*Jv'Jv + Jw'*I_world*Jw) + armature.
      for B in 1 .. Bodies'Length - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass) and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv));
         declare
            C : constant Body_Parameters := Bodies (B);
            R : constant Matrix := Poses (B).Inertial_Rotation;
            First : constant Natural := 3 * B * Nv;
            Last : constant Integer := First + 3 * Nv - 1;
            Columns : MJ.Smooth_Dynamics.Inertia_Column_Array (0 .. Nv - 1);
         begin
            MJ.Smooth_Dynamics.Prepare_Mass_Columns
              (Angular (First .. Last), R, C.Inertia, Columns);
            for I in 0 .. Nv - 1 loop
               pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass) and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv));
               declare
                  Li : constant Vector := Read_Vector (Linear, First + 3 * I);
                  Ai : constant Vector := Read_Vector (Angular, First + 3 * I);
               begin
                  for J in 0 .. I loop
                     pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass) and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv));
                     declare
                        Lj : constant Vector := Read_Vector (Linear, First + 3 * J);
                        Value : constant Real := MJ.Smooth_Dynamics.Prepared_Mass_Contribution
                          (Mass (I * Nv + J), C.Mass, Li, Lj, Ai, Columns (J));
                     begin
                        if not Within_Work (Value) then return; end if;
                        MJ.Smooth_Dynamics.Store_Symmetric (Mass, Nv, I, J, Value);
                     end;
                  end loop;
               end;
            end loop;
         end;
      end loop;
      for J in 0 .. Joints'Length - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Mass) and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv));
         declare
            V : constant Natural := Joints (J).Vadr;
            I : constant Natural := MJ.Smooth_Kernels.Matrix_Offset (Nv, V, V);
            Value : constant Real := Mass (I) + Joints (J).Armature;
         begin
            if not Within_Work (Value) then
               return;
            end if;
            MJ.Smooth_Dynamics.Store_Symmetric (Mass, Nv, V, V, Value);
         end;
      end loop;
      Result := Success;
   end Assemble_Dense_Mass;
   pragma Inline_Always (Assemble_Dense_Mass);

   procedure Prove_Dense_Inputs (D : Simulation)
     with Ghost => Static, Global => null,
       Pre => Is_Ready (D) and then D.Cache.Jacobian_Valid,
       Post => (for all B in D.Body_Config'Range =>
         Bounded (D.Body_Config (B).Inertia, Max_Val)
           and then Bounded (D.Kinematic.Bodies (B).Inertial_Rotation, 16.0))
         and then (for all J of D.Joint_Config.all => J.Vadr < D.Nv)
         and then MJ.Smooth_Dynamics.Work_Array (D.Kinematic.Linear_Jacobian.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Kinematic.Angular_Jacobian.all)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
   begin
      null;
   end Prove_Dense_Inputs;

   procedure Expose_Assembly_Layout (D : Simulation)
     with Ghost => Static, Global => null, Pre => Stable_Ready (D),
       Post => D.Dynamics.Mass /= null and then D.Dynamics.Mass'First = 0
         and then D.Dynamics.Mass'Last = D.Nv * D.Nv - 1
         and then D.Body_Config'First = 0 and then D.Body_Config'Length = D.Nb
         and then D.Kinematic.Linear_Jacobian'First = 0
         and then D.Kinematic.Linear_Jacobian'Last = 3 * D.Body_Config'Length * D.Nv - 1
         and then D.Kinematic.Angular_Jacobian'First = 0
         and then D.Kinematic.Angular_Jacobian'Last = D.Kinematic.Linear_Jacobian'Last
   is
   begin
      null;
   end Expose_Assembly_Layout;

   procedure Reset_Mass (D : in out Simulation)
     with Global => null, Pre => Is_Ready (D),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then not Mass_Current (D) and then not Forces_Current (D)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Mass.all)
         and then MJ.Smooth_Dynamics.Symmetric (D.Dynamics.Mass.all, D.Nv)
         and then (for all X of D.Dynamics.Mass.all => X = 0.0))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      D.Cache.Mass_Valid := False;
      D.Cache.Force_Valid := False;
      Zero_CRB_Mass (D.Dynamics.Mass.all, D.Nv);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Reset_Mass;
   pragma Inline_Always (Reset_Mass);

   --  CRB builds its own complete candidate. Preserve the published matrix
   --  while marking it stale; the dense fallback still clears its workspace.
   procedure Invalidate_Mass (D : in out Simulation)
     with Global => null, Pre => Is_Ready (D),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then not Mass_Current (D) and then not Forces_Current (D)
         and then D.Dynamics.Mass.all = D.Dynamics.Mass.all'Old)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Expose_Assembly_Layout (D);
      D.Cache.Mass_Valid := False;
      D.Cache.Force_Valid := False;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Invalidate_Mass;
   pragma Inline_Always (Invalidate_Mass);

   procedure Ready_Properties (D : Simulation)
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
       Post => Stable_Ready (D) and then D.Allocated and then not Is_Empty (D) and then D.Nv <= Max_Dofs
   is
   begin
      null;
   end Ready_Properties;

   procedure Build_And_Publish_CRB (D : in out Simulation; Used_CRB : out Boolean)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D) and then D.Cache.Spatial_Valid,
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then (if Used_CRB then Mass_Current (D) and then Symmetric_Mass (D)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Symmetric_Mass);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.All_Tier0);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      Nv : constant Natural := D.Nv;
      Candidate : Real_Array (0 .. Nv * Nv - 1);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      pragma Assert (Static => State_Values (D) = Initial_State);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Try_Assemble_CRB (D, Candidate, Used_CRB);
      if not Used_CRB then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Mass_Publication.Publish (D, Candidate);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
         pragma Assert (Static => Configuration (D) = Initial_Config);
      end;
   end Build_And_Publish_CRB;
   pragma Inline_Always (Build_And_Publish_CRB);

   procedure Assemble_CRB_Path (D : in out Simulation; Used_CRB : out Boolean)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then (if Used_CRB then Mass_Current (D) and then Symmetric_Mass (D)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.All_Tier0);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      Spatial_Ok : Boolean;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      pragma Assert (Static => State_Values (D) = Initial_State);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Used_CRB := False;
      if D.Nv < 3 then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Spatial.Prepare (D, Spatial_Ok);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
         pragma Assert (Static => Configuration (D) = Initial_Config);
      end;
      if not Spatial_Ok then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Build_And_Publish_CRB (D, Used_CRB);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
         pragma Assert (Static => Configuration (D) = Initial_Config);
      end;
   end Assemble_CRB_Path;
   pragma Inline_Always (Assemble_CRB_Path);

   procedure Expose_Compact_Layout (D : Simulation)
     with Ghost => Static, Global => null, Pre => Stable_Ready (D),
       Post => MJ.Ancestor_Rows.Size (D.Ancestors) = D.Nv
         and then MJ.Smooth_Topology.Dof_Count (D.Topology) = D.Nv
         and then MJ.Smooth_Topology.Body_Count (D.Topology) = D.Nb
         and then D.Dynamics.Compact_Mass /= null
         and then D.Dynamics.Compact_Mass'First = 0
         and then D.Dynamics.Compact_Mass'Last = MJ.Ancestor_Rows.Count (D.Ancestors) - 1
         and then (if D.Tendons /= null then
           MJ.Spatial_Tendon_Models.Mass_Ready (D.Tendons.all, MJ.Ancestor_Rows.Size (D.Ancestors)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
   begin
      null;
   end Expose_Compact_Layout;

   procedure Assemble_Compact_Path (D : in out Simulation; Used_CRB : out Boolean)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then (if Used_CRB then Mass_Current (D) and then Symmetric_Mass (D)))
   is
      --  The independently proved layout lemma supplies this predicate;
      --  retain it abstractly across writes to the disjoint mass buffer.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Spatial_Tendon_Models.Mass_Ready);
      Spatial_Ok : Boolean;
   begin
      Used_CRB := False;
      --  Preserve the existing small-model algorithm and its rounded results.
      if D.Nv < 3 then return; end if;
      D.Cache.Mass_Valid := False;
      D.Cache.Force_Valid := False;
      Spatial.Prepare (D, Spatial_Ok);
      if not Spatial_Ok then return; end if;
      Expose_Compact_Layout (D);
      MJ.Data.Compact_Assembly.Build
        (D.Ancestors, D.Topology, D.Body_Config.all,
         D.Kinematic.Spatial_Inertias.all, D.Kinematic.Spatial_Motions.all,
         D.Dynamics.Compact_Mass.all, Used_CRB);
      if not Used_CRB then return; end if;
      if D.Tendons /= null and then D.Tendons.Nm > 0 then
         MJ.Compact_Tendon_Mass.Accumulate
           (D.Tendons.all, D.Ancestors, D.Dynamics.Compact_Mass.all, Used_CRB);
         if not Used_CRB then return; end if;
      end if;
      Mass_Publication.Mark_Compact_Ready (D);
   end Assemble_Compact_Path;
   pragma Inline_Always (Assemble_Compact_Path);

   procedure Fill_Dense_Ready (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D)
         and then D.Cache.Jacobian_Valid
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Mass.all)
         and then MJ.Smooth_Dynamics.Symmetric (D.Dynamics.Mass.all, D.Nv),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Mass.all)
         and then MJ.Smooth_Dynamics.Symmetric (D.Dynamics.Mass.all, D.Nv))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.All_Tier0);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Expose_Assembly_Layout (D);
      Prove_Jacobian_Readiness (D);
      Prove_Dense_Inputs (D);
      Assemble_Dense_Mass
        (D.Body_Config.all, D.Joint_Config.all, D.Kinematic.Bodies.all,
         D.Kinematic.Linear_Jacobian.all, D.Kinematic.Angular_Jacobian.all,
         D.Nv, D.Dynamics.Mass.all, Result);
      pragma Assert (Static => Has_Real_Layout (D.Dynamics.Mass, D.Nv * D.Nv));
      pragma Assert (Static => Ancestor_Storage_Ready (D));
      pragma Assert (Static => Topology_Storage_Ready (D));
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Configuration_Bounded (D));
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => Inputs_Bounded (D));
      pragma Assert (Static => Caches_Bounded (D));
      pragma Assert (Static => Is_Ready (D));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Fill_Dense_Ready;
   pragma Inline_Always (Fill_Dense_Ready);

   procedure Fill_And_Mark_Mass (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D)
         and then D.Cache.Jacobian_Valid
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Mass.all)
         and then MJ.Smooth_Dynamics.Symmetric (D.Dynamics.Mass.all, D.Nv),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then (if Result = Success then Mass_Current (D) and then Symmetric_Mass (D)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.All_Tier0);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      pragma Assert (Static => State_Values (D) = Initial_State);
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Fill_Dense_Ready (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      if Result /= Success then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Mass_Publication.Mark_Ready (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
   end Fill_And_Mark_Mass;
   pragma Inline_Always (Fill_And_Mark_Mass);

   procedure Assemble_Dense_Path (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then (if Result = Success then Mass_Current (D) and then Symmetric_Mass (D)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Work_Array);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.All_Tier0);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Symmetric_Mass);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);

      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      pragma Assert (Static => State_Values (D) = Initial_State);
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Reset_Mass (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      end;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Pipeline.Ensure_Jacobians (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      end;
      if Result /= Success then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Fill_And_Mark_Mass (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      end;
   end Assemble_Dense_Path;
   pragma Inline_Always (Assemble_Dense_Path);

   procedure Assemble_Ready (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D),
       Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then (if Result = Success then Mass_Current (D) and then Symmetric_Mass (D)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Symmetric_Mass);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.All_Tier0);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      Used_CRB : Boolean;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Ready_Properties (D);
      pragma Assert (Static => Phase_Ready (D));
      if not D.Cache.Pose_Valid then Result := Stale_Results; return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Invalidate_Mass (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Input_Values (D) = Initial_Inputs);
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
      end;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Assemble_Compact_Path (D, Used_CRB);
         if Used_CRB then
            MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
            MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
            MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
            MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
            Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
            Prove_Configuration_Equality (Configuration (D), Initial_Config);
            Result := Success;
            return;
         end if;
         Assemble_CRB_Path (D, Used_CRB);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Input_Values (D) = Initial_Inputs);
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
      end;
      if Used_CRB then
         if D.Tendons /= null and then D.Tendons.Nm > 0 then
            MJ.Spatial_Tendon_Models.Add_Mass (D.Tendons.all, D.Nv, D.Dynamics.Mass.all, Used_CRB);
         end if;
         Result := Success; return;
      end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Assemble_Dense_Path (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Input_Values (D) = Initial_Inputs);
         Prove_Configuration_Equality (Configuration (D), Initial_Config);
      end;
      if Result = Success and then D.Tendons /= null and then D.Tendons.Nm > 0 then
         MJ.Spatial_Tendon_Models.Add_Mass (D.Tendons.all, D.Nv, D.Dynamics.Mass.all, Used_CRB);
      end if;
   end Assemble_Ready;
   pragma Inline_Always (Assemble_Ready);

   procedure Assemble (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Symmetric_Mass);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
   begin
      Assemble_Ready (D, Result);
   end Assemble;

   --  A positive divisor may be much smaller than Min_Val in a uniformly
   --  small, well-conditioned system. Bound the quotient before dividing.
   function Division_Bounded (Numerator, Denominator : Real) return Boolean is
     (Within_Work (Numerator) and then Denominator > 0.0
      and then (Denominator >= 1.0
                or else abs Numerator <= Work_Limit * Denominator));

   --  Binary envelopes keep each ordered reduction finite without adding
   --  a runtime scan or relying on associativity of floating-point sums.
   Product_Unit : constant Real := 2.0 ** 402;
   Triple_Unit : constant Real := 2.0 ** 608;

   function Subtract_Product
     (Previous : Real; Left, Right : MJ.Smooth_Dynamics.Work_Real; Count : Natural)
      return Real
     with Global => null,
     Pre => Count <= Max_Dofs and then
       Previous in -Real (Count + 1) * Product_Unit .. Real (Count + 1) * Product_Unit,
     Post => Subtract_Product'Result = Previous - Left * Right
       and then Subtract_Product'Result in
         -Real (Count + 2) * Product_Unit .. Real (Count + 2) * Product_Unit
   is
   begin
      return Previous - Left * Right;
   end Subtract_Product;
   pragma Inline_Always (Subtract_Product);

   function Subtract_Triple
     (Previous : Real; A, B, C : MJ.Smooth_Dynamics.Work_Real; Count : Natural)
      return Real
     with Global => null,
     Pre => Count <= Max_Dofs and then
       Previous in -Real (Count + 1) * Triple_Unit .. Real (Count + 1) * Triple_Unit,
     Post => Subtract_Triple'Result = Previous - A * B * C
       and then Subtract_Triple'Result in
         -Real (Count + 2) * Triple_Unit .. Real (Count + 2) * Triple_Unit
       and then (if A = B and then C >= 0.0 then Subtract_Triple'Result <= Previous)
   is
      Product : constant Real := A * B * C;
   begin
      pragma Assert (Static => Product in -1.0e181 .. 1.0e181);
      return Previous - Product;
   end Subtract_Triple;
   pragma Inline_Always (Subtract_Triple);

   function Divide_Bounded (Numerator, Denominator : Real) return Real
     with Global => null, Pre => Division_Bounded (Numerator, Denominator),
     Post => Divide_Bounded'Result = Numerator / Denominator
       and then Divide_Bounded'Result in -2.0e60 .. 2.0e60
   is
   begin
      return Numerator / Denominator;
   end Divide_Bounded;
   pragma Inline_Always (Divide_Bounded);

   function Diagonal_Quotient (Value : MJ.Smooth_Dynamics.Work_Real; Scale : Real) return Real
     with Global => null,
     Pre => Scale > 0.0 and then (Scale >= Min_Val or else Value in 0.0 .. Scale),
     Post => Diagonal_Quotient'Result = Value / Scale
       and then Diagonal_Quotient'Result in -1.0e76 .. 1.0e76
   is
   begin
      return Value / Scale;
   end Diagonal_Quotient;
   pragma Inline_Always (Diagonal_Quotient);

   procedure Store_Work_Entry
     (Target : in out Real_Array; Index : Natural;
      Value : MJ.Smooth_Dynamics.Work_Real)
     with Global => null,
     Pre => Index in Target'Range and then MJ.Smooth_Dynamics.Work_Array (Target),
     Post => MJ.Smooth_Dynamics.Work_Array (Target)
       and then (for all K in Target'Range =>
         Target (K) = (if K = Index then Value else Target'Old (K)))
   is
   begin
      Target (Index) := Value;
   end Store_Work_Entry;
   pragma Inline_Always (Store_Work_Entry);

   function Off (N, Row, Column : Natural) return Natural
     renames MJ.Smooth_Kernels.Matrix_Offset;

   Sum_Unit : constant Real := 2.0 ** 202;
   function Add_Absolute
     (Previous : Real; Value : MJ.Smooth_Dynamics.Work_Real; Count : Natural) return Real
     with Global => null,
     Pre => Count <= Max_Dofs and then Previous in 0.0 .. Real (Count) * Sum_Unit,
     Post => Add_Absolute'Result = Previous + abs Value
       and then Add_Absolute'Result in 0.0 .. Real (Count + 1) * Sum_Unit
       and then Add_Absolute'Result >= Previous and then Add_Absolute'Result >= abs Value
   is
   begin
      return Previous + abs Value;
   end Add_Absolute;
   pragma Inline_Always (Add_Absolute);

   function Row_Norm (Row : Real_Array) return Real
     with Global => null,
     Pre => Row'First >= 0 and then Int64 (Row'Length) <= Max_Dofs
       and then MJ.Smooth_Dynamics.Work_Array (Row),
     Post => Row_Norm'Result in 0.0 .. Real (Max_Dofs) * Sum_Unit
       and then (for all X of Row => abs X <= Row_Norm'Result)
   is
      Sum : Real := 0.0;
   begin
      for J in Row'Range loop
         pragma Loop_Invariant (Sum in 0.0 .. Real (J - Row'First) * Sum_Unit);
         pragma Loop_Invariant (for all K in Row'First .. J - 1 => abs Row (K) <= Sum);
         Sum := Add_Absolute (Sum, Row (J), J - Row'First);
      end loop;
      return Sum;
   end Row_Norm;
   pragma Inline_Always (Row_Norm);

   procedure Diagonal_Indices (N, I, J : Natural)
     with Ghost => Static, Global => null,
     Pre => N <= Max_Dofs and then I < N and then J < N,
     Post => (for all K in 0 .. N - 1 =>
       (Off (N, I, J) = Off (N, K, K)) = (I = K and then J = K))
   is
   begin
      for K in 0 .. N - 1 loop
         MJ.Smooth_Dynamics.Offset_Identity (N, I, J, K, K);
         pragma Loop_Invariant (for all L in 0 .. K =>
           (Off (N, I, J) = Off (N, L, L)) = (I = L and then J = L));
      end loop;
   end Diagonal_Indices;

   --  Solve (A / Diagonal_Scale) x = Rhs using the existing A = L D L' factors.
   --  Scaling D alone leaves L unchanged. Rhs is workspace; Solution is output.
   procedure Solve_Factored_Buffers
     (N : Natural; Factor : Real_Array; Rhs, Solution : in out Real_Array;
      Diagonal_Scale : Real; Pivots : Real_Array; Result : out Status)
     with Global => null,
     Pre => N <= Max_Dofs and then MJ.Smooth_Dynamics.Square_Layout (Factor, N)
       and then Rhs'First = 0 and then Rhs'Last = N - 1
       and then Solution'First = 0 and then Solution'Last = N - 1
       and then Int64 (Pivots'Length) <= Max_Dofs
       and then (if Pivots'Length = N then Pivots'First = 0)
       and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then MJ.Smooth_Dynamics.Work_Array (Rhs)
       and then (if Diagonal_Scale > 0.0 and then Diagonal_Scale < Min_Val then
         (for all I in 0 .. N - 1 => Factor (Off (N, I, I)) in 0.0 .. Diagonal_Scale)),
     Post => Result in Success | Numeric_Limit and then MJ.Smooth_Dynamics.Work_Array (Rhs)
       and then (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Solution))
   is
      Value, Pivot : Real;
   begin
      Result := Numeric_Limit;
      if Diagonal_Scale <= 0.0 then return; end if;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Rhs));
         Value := Rhs (I);
         for J in 0 .. I - 1 loop
            pragma Loop_Invariant (Value in
              -Real (J + 1) * Product_Unit .. Real (J + 1) * Product_Unit);
            Value := Subtract_Product (Value, Factor (Off (N, I, J)), Rhs (J), J);
         end loop;
         if not Within_Work (Value) then return; end if;
         Store_Work_Entry (Rhs, I, Value);
      end loop;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Rhs));
         Pivot := (if Pivots'Length = N then Pivots (I)
                   else Diagonal_Quotient (Factor (Off (N, I, I)), Diagonal_Scale));
         if not Division_Bounded (Rhs (I), Pivot) then return; end if;
         Value := Divide_Bounded (Rhs (I), Pivot);
         if not Within_Work (Value) then return; end if;
         Store_Work_Entry (Rhs, I, Value);
      end loop;
      pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (Rhs));
      for I in reverse 0 .. N - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Rhs));
         pragma Loop_Invariant (for all K in I + 1 .. N - 1 => Within_Work (Solution (K)));
         Value := Rhs (I);
         for J in I + 1 .. N - 1 loop
            pragma Loop_Invariant (Value in
              -Real (J - I) * Product_Unit .. Real (J - I) * Product_Unit);
            Value := Subtract_Product (Value, Factor (Off (N, J, I)), Solution (J), J - I - 1);
         end loop;
         if not Within_Work (Value) then return; end if;
         Solution (I) := Value;
      end loop;
      Result := Success;
   end Solve_Factored_Buffers;

   procedure Check_Condition_Buffers
     (N : Natural; Factor : Real_Array; Rhs, Solution : in out Real_Array; Condition_Sums : out Real_Array;
      Matrix_Norm, Condition_Limit : Real; Result : out Status)
     with Global => null,
     Pre => N <= Max_Dofs and then MJ.Smooth_Dynamics.Square_Layout (Factor, N)
       and then Rhs'First = 0 and then Rhs'Last = N - 1
       and then Solution'First = 0 and then Solution'Last = N - 1
       and then Condition_Sums'First = 0 and then Condition_Sums'Last = N - 1
       and then Matrix_Norm > 0.0 and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then (for all I in 0 .. N - 1 => Factor (Off (N, I, I)) in 0.0 .. Matrix_Norm),
     Post => Result in Success | Numeric_Limit | Ill_Conditioned_Inertia
       and then MJ.Smooth_Dynamics.Work_Array (Condition_Sums)
       and then (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Solution)
         and then MJ.Smooth_Dynamics.Work_Array (Rhs))
   is
      Value : Real;
      Pivots : Real_Array (0 .. (if Matrix_Norm in Min_Val .. 1.0e100 then N else 0) - 1)
        with Relaxed_Initialization;
   begin
      Condition_Sums := [others => 0.0];
      if Matrix_Norm in Min_Val .. 1.0e100 then
         MJ.Smooth_Dynamics.Prepare_Scaled_Diagonal (Factor, N, Matrix_Norm, Pivots);
      end if;
      for Column in 0 .. N - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Condition_Sums));
         Rhs := [others => 0.0];
         Rhs (Column) := 1.0;
         Solve_Factored_Buffers (N, Factor, Rhs, Solution, Matrix_Norm, Pivots, Result);
         if Result /= Success then return; end if;
         for I in 0 .. N - 1 loop
            pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Condition_Sums));
            Value := Condition_Sums (I) + abs Solution (I);
            if not Within_Work (Value) then
               Result := Numeric_Limit;
               return;
            elsif Value >= Condition_Limit then
               Result := Ill_Conditioned_Inertia;
               return;
            end if;
            Store_Work_Entry (Condition_Sums, I, Value);
         end loop;
      end loop;
      Result := Success;
   end Check_Condition_Buffers;

   procedure Store_Lower_Entry
     (Factor : in out Real_Array; N, I, J : Natural; Value : MJ.Smooth_Dynamics.Work_Real)
     with Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N and then J < I
       and then MJ.Smooth_Dynamics.Work_Array (Factor),
     Post => MJ.Smooth_Dynamics.Work_Array (Factor)
       and then (for all K in 0 .. N - 1 => Factor (Off (N, K, K)) = Factor'Old (Off (N, K, K)))
       and then (for all K in Factor'Range => Factor (K) =
         (if K = Off (N, I, J) then Value else Factor'Old (K)))
   is
   begin
      Diagonal_Indices (N, I, J);
      Store_Work_Entry (Factor, Off (N, I, J), Value);
   end Store_Lower_Entry;
   pragma Inline_Always (Store_Lower_Entry);

   procedure Store_Diagonal_Entry
     (Factor : in out Real_Array; N, I : Natural; Value : MJ.Smooth_Dynamics.Work_Real)
     with Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N
       and then MJ.Smooth_Dynamics.Work_Array (Factor),
     Post => MJ.Smooth_Dynamics.Work_Array (Factor)
       and then (for all K in 0 .. N - 1 => Factor (Off (N, K, K)) =
         (if K = I then Value else Factor'Old (Off (N, K, K))))
       and then (for all K in Factor'Range => Factor (K) =
         (if K = Off (N, I, I) then Value else Factor'Old (K)))
   is
   begin
      Diagonal_Indices (N, I, I);
      Store_Work_Entry (Factor, Off (N, I, I), Value);
   end Store_Diagonal_Entry;
   pragma Inline_Always (Store_Diagonal_Entry);

   function Ordered_Triple_Model
     (Factor : Real_Array; N, I, J, Count : Natural) return Real is
     (if Count = 0 then Factor (Off (N, I, J))
      elsif I = J then Subtract_Triple
        (Ordered_Triple_Model (Factor, N, I, J, Count - 1),
         Factor (Off (N, I, Count - 1)), Factor (Off (N, I, Count - 1)),
         Factor (Off (N, Count - 1, Count - 1)), Count - 1)
      else Subtract_Triple
        (Ordered_Triple_Model (Factor, N, I, J, Count - 1),
         Factor (Off (N, I, Count - 1)), Factor (Off (N, Count - 1, Count - 1)),
         Factor (Off (N, J, Count - 1)), Count - 1))
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N and then J <= I
       and then Count <= J and then MJ.Smooth_Dynamics.Work_Array (Factor),
     Post => Ordered_Triple_Model'Result in -Real (Count + 1) * Triple_Unit .. Real (Count + 1) * Triple_Unit,
     Subprogram_Variant => (Decreases => Count);

   procedure Initialize_Triple_Model (Factor : Real_Array; N, I, J : Natural)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N and then J <= I
       and then MJ.Smooth_Dynamics.Work_Array (Factor),
     Post => Ordered_Triple_Model (Factor, N, I, J, 0) = Factor (Off (N, I, J))
   is
   begin
      null;
   end Initialize_Triple_Model;

   procedure Unfold_Triple_Model (Factor : Real_Array; N, I, J, Count : Natural)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N and then J <= I
       and then Count < J and then MJ.Smooth_Dynamics.Work_Array (Factor),
     Post => Ordered_Triple_Model (Factor, N, I, J, Count + 1) =
       (if I = J then Subtract_Triple (Ordered_Triple_Model (Factor, N, I, J, Count),
          Factor (Off (N, I, Count)), Factor (Off (N, I, Count)), Factor (Off (N, Count, Count)), Count)
        else Subtract_Triple (Ordered_Triple_Model (Factor, N, I, J, Count),
          Factor (Off (N, I, Count)), Factor (Off (N, Count, Count)), Factor (Off (N, J, Count)), Count))
   is
   begin
      null;
   end Unfold_Triple_Model;

   procedure Prove_Lower_Update
     (Factor : Real_Array; N, I, J, Count : Natural; Previous, Next : Real)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N and then J < I
       and then Count < J and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then Previous = Ordered_Triple_Model (Factor, N, I, J, Count)
       and then Next = Subtract_Triple (Previous, Factor (Off (N, I, Count)),
         Factor (Off (N, Count, Count)), Factor (Off (N, J, Count)), Count),
     Post => Next = Ordered_Triple_Model (Factor, N, I, J, Count + 1)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ordered_Triple_Model);
   begin
      Unfold_Triple_Model (Factor, N, I, J, Count);
   end Prove_Lower_Update;

   function Lower_Entry (Factor : Real_Array; N, I, J : Natural) return Real
     with Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N and then J < I
       and then MJ.Smooth_Dynamics.Work_Array (Factor),
     Post => (Static => Lower_Entry'Result in -Real (J + 1) * Triple_Unit .. Real (J + 1) * Triple_Unit
       and then Lower_Entry'Result = Ordered_Triple_Model (Factor, N, I, J, J))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ordered_Triple_Model);
      Value : Real := Factor (Off (N, I, J));
   begin
      Initialize_Triple_Model (Factor, N, I, J);
      for K in 0 .. J - 1 loop
         pragma Loop_Invariant (Value in -Real (K + 1) * Triple_Unit .. Real (K + 1) * Triple_Unit);
         pragma Loop_Invariant (Static => Value = Ordered_Triple_Model (Factor, N, I, J, K));
         declare
            Previous : constant Real := Value with Ghost => Static;
         begin
            Value := Subtract_Triple (Value, Factor (Off (N, I, K)),
              Factor (Off (N, K, K)), Factor (Off (N, J, K)), K);
            Prove_Lower_Update (Factor, N, I, J, K, Previous, Value);
         end;
      end loop;
      pragma Assert (Static => Value = Ordered_Triple_Model (Factor, N, I, J, J));
      return Value;
   end Lower_Entry;
   pragma Inline_Always (Lower_Entry);

   function Diagonal_Entry (Factor : Real_Array; N, I : Natural) return Real
     with Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N
       and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then (for all K in 0 .. I - 1 => Factor (Off (N, K, K)) > 0.0),
     Post => (Static => Diagonal_Entry'Result in -Real (I + 1) * Triple_Unit .. Real (I + 1) * Triple_Unit
       and then Diagonal_Entry'Result <= Factor (Off (N, I, I))
       and then Diagonal_Entry'Result = Ordered_Triple_Model (Factor, N, I, I, I))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ordered_Triple_Model);
      Value : Real := Factor (Off (N, I, I));
   begin
      Initialize_Triple_Model (Factor, N, I, I);
      for K in 0 .. I - 1 loop
         pragma Loop_Invariant (Value in -Real (K + 1) * Triple_Unit .. Real (K + 1) * Triple_Unit);
         pragma Loop_Invariant (Value <= Factor (Off (N, I, I)));
         pragma Loop_Invariant (Static => Value = Ordered_Triple_Model (Factor, N, I, I, K));
         Unfold_Triple_Model (Factor, N, I, I, K);
         Value := Subtract_Triple (Value, Factor (Off (N, I, K)),
           Factor (Off (N, I, K)), Factor (Off (N, K, K)), K);
      end loop;
      return Value;
   end Diagonal_Entry;
   pragma Inline_Always (Diagonal_Entry);

   procedure Store_Bounded_Diagonal
     (Factor : in out Real_Array; N, I : Natural; Value : MJ.Smooth_Dynamics.Work_Real;
      Matrix_Norm : Real)
     with Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N
       and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then Value in 0.0 .. Matrix_Norm
       and then (for all K in 0 .. N - 1 => abs Factor (Off (N, K, K)) <= Matrix_Norm),
     Post => MJ.Smooth_Dynamics.Work_Array (Factor)
       and then (for all K in 0 .. N - 1 => abs Factor (Off (N, K, K)) <= Matrix_Norm)
       and then (for all K in 0 .. N - 1 => Factor (Off (N, K, K)) =
         (if K = I then Value else Factor'Old (Off (N, K, K))))
   is
   begin
      Store_Diagonal_Entry (Factor, N, I, Value);
   end Store_Bounded_Diagonal;
   pragma Inline_Always (Store_Bounded_Diagonal);

   procedure Factor_Strict_Row
     (Factor : in out Real_Array; N, I : Natural; Matrix_Norm, Tolerance : Real;
      Result : out Status)
     with Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Factor, N) and then I < N
       and then MJ.Smooth_Dynamics.Work_Array (Factor) and then Matrix_Norm > 0.0
       and then (for all K in 0 .. N - 1 => abs Factor (Off (N, K, K)) <= Matrix_Norm)
       and then (for all K in 0 .. I - 1 => Factor (Off (N, K, K)) > 0.0),
     Post => Result in Success | Numeric_Limit | Ill_Conditioned_Inertia | Singular_Inertia
       and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then (for all K in 0 .. N - 1 => abs Factor (Off (N, K, K)) <= Matrix_Norm)
       and then (for all K in 0 .. I - 1 => Factor (Off (N, K, K)) > 0.0)
       and then (if Result = Success then Factor (Off (N, I, I)) > 0.0)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Work_Array);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ordered_Triple_Model);
      Value : Real;
   begin
      Result := Numeric_Limit;
      for J in 0 .. I - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Factor));
         pragma Loop_Invariant (for all K in 0 .. N - 1 => abs Factor (Off (N, K, K)) <= Matrix_Norm);
         pragma Loop_Invariant (for all K in 0 .. I - 1 => Factor (Off (N, K, K)) > 0.0);
         Value := Lower_Entry (Factor, N, I, J);
         if not Division_Bounded (Value, Factor (Off (N, J, J))) then return; end if;
         Value := Divide_Bounded (Value, Factor (Off (N, J, J)));
         if not Within_Work (Value) then return; end if;
         Store_Lower_Entry (Factor, N, I, J, Value);
      end loop;
      pragma Assert_And_Cut (Static => MJ.Smooth_Dynamics.Square_Layout (Factor, N)
        and then I < N and then Matrix_Norm > 0.0 and then Result = Numeric_Limit
        and then MJ.Smooth_Dynamics.Work_Array (Factor)
        and then (for all K in 0 .. N - 1 => abs Factor (Off (N, K, K)) <= Matrix_Norm)
        and then (for all K in 0 .. I - 1 => Factor (Off (N, K, K)) > 0.0));
      Value := Diagonal_Entry (Factor, N, I);
      if not Within_Work (Value) then
         return;
      elsif Value <= 0.0 then
         Result := Singular_Inertia;
         return;
      elsif Diagonal_Quotient (Value, Matrix_Norm) <= Tolerance then
         Result := Ill_Conditioned_Inertia;
         return;
      end if;
      Store_Bounded_Diagonal (Factor, N, I, Value, Matrix_Norm);
      pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (Factor));
      Result := Success;
   end Factor_Strict_Row;
   pragma Inline_Always (Factor_Strict_Row);

   procedure Solve_Strict_Buffers
     (N : Natural; Joints : Joint_Parameter_Array; Mass, Total : Real_Array;
      Factor, Rhs, Solution, Condition_Sums : in out Real_Array;
      Damping_Step : Nonneg_Tier0; Result : out Status)
     with Global => null,
     Pre => N <= Max_Dofs and then MJ.Smooth_Dynamics.Square_Layout (Factor, N)
       and then Rhs'First = 0 and then Rhs'Last = N - 1
       and then Solution'First = 0 and then Solution'Last = N - 1
       and then Condition_Sums'First = 0 and then Condition_Sums'Last = N - 1
       and then Mass'First = 0 and then Mass'Last = Factor'Last
       and then Total'First = 0 and then Total'Last = N - 1
       and then Joints'First = 0 and then Joints'Last = N - 1
       and then (for all J of Joints => J.Vadr < N)
       and then MJ.Smooth_Dynamics.Work_Array (Mass) and then MJ.Smooth_Dynamics.Work_Array (Total),
     Post => Result in Success | Numeric_Limit | Ill_Conditioned_Inertia | Singular_Inertia
       and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Solution))
   is
      --  Dimensionless draft acceptance policy, not a proved error bound.
      Relative_Tolerance : constant Real :=
        64.0 * Real'Model_Epsilon * Real (Natural'Max (1, N));
      Matrix_Norm : Real := 0.0;
      Row_Sum, Value : Real;
   begin
      Result := Numeric_Limit;
      Factor := Mass;
      if N = 0 then
         Result := Success;
         return;
      end if;
      if Damping_Step > 0.0 then
         for J in 0 .. N - 1 loop
            pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Factor));
            declare
               V : constant Natural := Joints (J).Vadr;
               Index : constant Natural := V * N + V;
            begin
               Value := Factor (Index) + Damping_Step * Joints (J).Damping;
               if not Within_Work (Value) then
                  return;
               end if;
               Store_Work_Entry (Factor, Index, Value);
            end;
         end loop;
      end if;
      --  Measure the matrix actually solved: M, or M + h*diag(damping).
      --  A row has at most Max_Dofs entries of magnitude Work_Limit.
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Matrix_Norm in 0.0 .. Real (Max_Dofs) * Sum_Unit);
         pragma Loop_Invariant (for all K in 0 .. I - 1 =>
           abs Factor (Off (N, K, K)) <= Matrix_Norm);
         Row_Sum := Row_Norm (Factor (I * N .. I * N + N - 1));
         Matrix_Norm := Real'Max (Matrix_Norm, Row_Sum);
      end loop;
      if Matrix_Norm = 0.0 then
         Result := Singular_Inertia;
         return;
      end if;

      --  In-place LDL': D on the diagonal, unit-diagonal L below it.
      --  No regularization. Pivot and condition policies use relative scales.
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Factor));
         pragma Loop_Invariant (for all K in 0 .. N - 1 => abs Factor (Off (N, K, K)) <= Matrix_Norm);
         pragma Loop_Invariant (for all K in 0 .. I - 1 => Factor (Off (N, K, K)) > 0.0);
         Factor_Strict_Row (Factor, N, I, Matrix_Norm, Relative_Tolerance, Result);
         if Result /= Success then return; end if;
      end loop;
      pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (Factor));

      Check_Condition_Buffers (N, Factor, Rhs, Solution, Condition_Sums, Matrix_Norm, 1.0 / Relative_Tolerance, Result);
      if Result /= Success then
         return;
      end if;
      --  Condition estimation consumed the RHS and solution buffers.
      Rhs := Total;
      Solve_Factored_Buffers (N, Factor, Rhs, Solution, 1.0, [1 .. 0 => 0.0], Result);
   end Solve_Strict_Buffers;



   --  C's reverse L' D L algorithm on full ancestor rows. A row of an
   --  ancestor occupies the corresponding prefix of every descendant row.
   procedure Add_Prefix_Row
     (Target : in out Real_Array; Source : Real_Array;
      Multiplier : MJ.Solver_Kernels.Scale_Real; Ok : out Boolean)
     with Global => null,
     Pre => Target'First = 0 and then Source'Length <= Target'Length
       and then Source'Length <= MJ.Ancestor_Rows.Max_Dofs
       and then MJ.Smooth_Dynamics.Work_Array (Target)
       and then MJ.Smooth_Dynamics.Work_Array (Source),
     Post => Ok = MJ.Smooth_Dynamics.Work_Array (Target)
       and then (for all K in Target'Range =>
         Target (K) = (if K < Source'Length then
           MJ.Solver_Kernels.Add_Product
             (Target'Old (K), Source (Source'First + K), Multiplier)
           else Target'Old (K)))
   is
   begin
      MJ.Solver_Kernels.Add_Row
        (Target (0 .. Source'Length - 1), Source, Multiplier, Ok);
   end Add_Prefix_Row;
   pragma Inline_Always (Add_Prefix_Row);




   procedure Solve_Compatible_Buffers
     (Rows : MJ.Ancestor_Rows.Pattern; Total : Real_Array;
      Factor, Solution : in out Real_Array;
      First_Clamped : in out Dof_Diagnostic; Result : out Status)
     with Global => null,
     Pre => Total'First = 0 and then Total'Last = MJ.Ancestor_Rows.Size (Rows) - 1
       and then Factor'First = 0 and then Factor'Last = MJ.Ancestor_Rows.Count (Rows) - 1
       and then Solution'First = 0 and then Solution'Last = Total'Last
       and then MJ.Smooth_Dynamics.Work_Array (Factor)
       and then MJ.Smooth_Dynamics.Work_Array (Total),
     Post => Result in Success | Numeric_Limit
       and then (if First_Clamped'Old >= 0 then First_Clamped = First_Clamped'Old)
       and then (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Solution)
         and then MJ.Smooth_Dynamics.Work_Array (Factor))
   is
      package SK renames MJ.Solver_Kernels;
      package SR renames MJ.Solver_Reductions;
      package AR renames MJ.Ancestor_Rows;
      N : constant Natural := AR.Size (Rows);
      Inverses : array (0 .. N - 1) of SK.Inverse_Real := [others => 1.0];
      Pivot : SK.Positive_Pivot;
      Multiplier : SK.Scale_Real;
      Value : Real;
      Accepted : Boolean;
   begin
      Result := Numeric_Limit;
      for K in reverse 0 .. N - 1 loop
         pragma Loop_Invariant (Static => (if First_Clamped'Loop_Entry >= 0 then First_Clamped = First_Clamped'Loop_Entry));
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Factor));
         declare
            First : constant Natural := AR.Start (Rows, K);
            Diag : constant Natural := AR.Length (Rows, K) - 1;
            Last : constant Natural := First + Diag;
         begin
            Pivot := SK.Clamp_Pivot (Factor (Last));
            if Factor (Last) < Min_Val and then First_Clamped < 0 then
               First_Clamped := K;
            end if;
            Factor (Last) := Pivot;
            Inverses (K) := SK.Reciprocal (Pivot);
            for A in reverse 0 .. Diag - 1 loop
               pragma Loop_Invariant (Static => (if First_Clamped'Loop_Entry >= 0 then First_Clamped = First_Clamped'Loop_Entry));
               pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Factor));
               declare
                  I : constant Natural := (if Diag = K then A else AR.Column (Rows, K, A));
               begin
                  pragma Assert (Static => I = AR.Column (Rows, K, A));
                  pragma Assert (Static => AR.Length (Rows, I) = A + 1);
                  AR.Rows_Disjoint (Rows, I, K);
                  declare
                     Target : constant Natural :=
                       (if Diag = K then AR.Dense_Prefix_Start (Rows, I)
                        else AR.Start (Rows, I));
                  begin
                     pragma Assert (Static => Target + A < First);
                     Multiplier := SK.Scale (-Factor (First + A), Inverses (K));
                     SK.Add_Row_Disjoint
                       (Factor, Target, First, A + 1,
                        Multiplier, Accepted);
                     if not Accepted then return; end if;
                  end;
               end;
            end loop;
            SK.Scale_Row
              (Factor (First .. Last - 1), Inverses (K), Accepted);
            if not Accepted then return; end if;
         end;
      end loop;
      pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (Factor));
      Solution := Total;
      --  L' y = rhs, followed by diagonal scaling, then L x = y.
      for I in reverse 0 .. N - 1 loop
         pragma Loop_Invariant (Static => (if First_Clamped'Loop_Entry >= 0 then First_Clamped = First_Clamped'Loop_Entry));
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Solution));
         declare
            First : constant Natural := AR.Start (Rows, I);
            Diag : constant Natural := AR.Length (Rows, I) - 1;
         begin
            if Solution (I) /= 0.0 and then Diag > 0 then
               if Diag = I then
                  --  Full prefix: preserve the contiguous SIMD row kernel.
                  Add_Prefix_Row
                    (Solution,
                     Factor (First .. First + Diag - 1),
                     -Solution (I), Accepted);
                  if not Accepted then return; end if;
               else
                  for A in 0 .. Diag - 1 loop
                     declare
                        J : constant Natural := AR.Column (Rows, I, A);
                     begin
                        Value := SK.Add_Product
                          (Solution (J), Factor (First + A),
                           -Solution (I));
                        if not Within_Work (Value) then return; end if;
                        Store_Work_Entry (Solution, J, Value);
                     end;
                     pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Solution));
                  end loop;
               end if;
            end if;
         end;
      end loop;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => (if First_Clamped'Loop_Entry >= 0 then First_Clamped = First_Clamped'Loop_Entry));
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Solution));
         Value := SK.Scale (Solution (I), Inverses (I));
         if not Within_Work (Value) then return; end if;
         Solution (I) := Value;
      end loop;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Static => (if First_Clamped'Loop_Entry >= 0 then First_Clamped = First_Clamped'Loop_Entry));
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Solution));
         SR.Forward_Value
           (Rows, I, Factor, Solution,
            Solution (I), Value, Accepted);
         if not Accepted then return; end if;
         Solution (I) := Value;
      end loop;
      Result := Success;
   end Solve_Compatible_Buffers;



   --  Keep the public dense mass and the strict solver unchanged. Pack only
   --  structural entries, once per physical solve; no tolerance drops terms.
   procedure Load_Ancestor_Buffers
     (Rows : MJ.Ancestor_Rows.Pattern; Mass : Real_Array; Joints : Joint_Parameter_Array;
      Factor : in out Real_Array; Damping_Step : Nonneg_Tier0; Result : out Status)
     with Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Mass, MJ.Ancestor_Rows.Size (Rows))
       and then MJ.Smooth_Dynamics.Work_Array (Mass)
       and then Factor'First = 0 and then Factor'Last = MJ.Ancestor_Rows.Count (Rows) - 1
       and then Joints'First = 0 and then Joints'Last = MJ.Ancestor_Rows.Size (Rows) - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Factor)
   is
      package AR renames MJ.Ancestor_Rows;
      Value : Real;
   begin
      Result := Numeric_Limit;
      AR.Copy_Matrix (Rows, Mass, Factor);
      if Damping_Step > 0.0 then
         for I in Joints'Range loop
            pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Factor));
            declare
               Last : constant Natural := AR.Start (Rows, I) + AR.Length (Rows, I) - 1;
            begin
               Value := Factor (Last) + Damping_Step * Joints (I).Damping;
               if not Within_Work (Value) then return; end if;
               Store_Work_Entry (Factor, Last, Value);
            end;
         end loop;
      end if;
      Result := Success;
   end Load_Ancestor_Buffers;
   pragma Inline_Always (Load_Ancestor_Buffers);

   procedure Load_Compact_Buffers
     (Rows : MJ.Ancestor_Rows.Pattern; Mass : Real_Array; Joints : Joint_Parameter_Array;
      Factor : in out Real_Array; Damping_Step : Nonneg_Tier0; Result : out Status)
     with Global => null,
     Pre => Mass'First = 0 and then Mass'Last = MJ.Ancestor_Rows.Count (Rows) - 1
       and then MJ.Smooth_Dynamics.Work_Array (Mass)
       and then Factor'First = 0 and then Factor'Last = MJ.Ancestor_Rows.Count (Rows) - 1
       and then Joints'First = 0 and then Joints'Last = MJ.Ancestor_Rows.Size (Rows) - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Factor)
   is
      package AR renames MJ.Ancestor_Rows;
      Value : Real;
   begin
      Result := Numeric_Limit;
      Factor := Mass;
      if Damping_Step > 0.0 then
         for I in Joints'Range loop
            pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Factor));
            declare
               Last : constant Natural := AR.Start (Rows, I) + AR.Length (Rows, I) - 1;
            begin
               Value := Factor (Last) + Damping_Step * Joints (I).Damping;
               if not Within_Work (Value) then return; end if;
               Store_Work_Entry (Factor, Last, Value);
            end;
         end loop;
      end if;
      Result := Success;
   end Load_Compact_Buffers;
   pragma Inline_Always (Load_Compact_Buffers);





   procedure Solver_Ready_Properties (D : Simulation)
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => Stable_Ready (D) and then Phase_Ready (D) and then D.Allocated
       and then Forces_Current (D) = D.Cache.Force_Valid
       and then Positions_Current (D) = D.Cache.Pose_Valid
   is
   begin
      null;
   end Solver_Ready_Properties;

   procedure Solve_Workspace
     (N : Natural; Rows : MJ.Ancestor_Rows.Pattern; Joints : Joint_Parameter_Array;
      Mass, Total : Real_Array; Policy : Inertia_Policy; Damping_Step : Nonneg_Tier0;
      Factor, Ancestor_Factor, Rhs, Solution, Condition_Sums : in out Real_Array;
      First_Clamped : in out Dof_Diagnostic; Result : out Status)
     with Global => null,
     Pre => N <= Max_Dofs and then MJ.Ancestor_Rows.Size (Rows) = N
       and then MJ.Smooth_Dynamics.Square_Layout (Mass, N)
       and then MJ.Smooth_Dynamics.Square_Layout (Factor, N)
       and then Joints'First = 0 and then Joints'Last = N - 1
       and then (for all J of Joints => J.Vadr < N)
       and then Total'First = 0 and then Total'Last = N - 1
       and then Rhs'First = 0 and then Rhs'Last = N - 1
       and then Solution'First = 0 and then Solution'Last = N - 1
       and then Condition_Sums'First = 0 and then Condition_Sums'Last = N - 1
       and then Ancestor_Factor'First = 0 and then Ancestor_Factor'Last = MJ.Ancestor_Rows.Count (Rows) - 1
       and then MJ.Smooth_Dynamics.Work_Array (Mass) and then MJ.Smooth_Dynamics.Work_Array (Total),
     Post => (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Solution))
       and then (if Policy = Strict or else First_Clamped'Old >= 0 then First_Clamped = First_Clamped'Old)
   is
   begin
      if Policy = Compatible then
         Load_Ancestor_Buffers (Rows, Mass, Joints, Ancestor_Factor, Damping_Step, Result);
         if Result = Success then
            Solve_Compatible_Buffers (Rows, Total, Ancestor_Factor, Solution, First_Clamped, Result);
         end if;
      else
         Solve_Strict_Buffers
           (N, Joints, Mass, Total, Factor, Rhs, Solution, Condition_Sums, Damping_Step, Result);
      end if;
   end Solve_Workspace;
   pragma Inline_Always (Solve_Workspace);

   procedure Solve (D : in out Simulation; Damping_Step : Real; Result : out Status)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Mass_Valid and then Array_Bounded (D.Dynamics.Total)
       and then Damping_Step in 0.0 .. Max_Val;
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Stable_Ready (D));
   pragma Postcondition (Static => Is_Empty (D) = Is_Empty (D)'Old);
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Positions_Current (D) = Positions_Current (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);
   pragma Postcondition (Static => Position_Values (D) = Position_Values (D)'Old);
   pragma Postcondition (Static => Velocity_Values (D) = Velocity_Values (D)'Old);
   pragma Postcondition (Static => Time (D) = Time (D)'Old);
   pragma Postcondition (Static => Step_Size (D) = Step_Size (D)'Old);
   pragma Postcondition (Static => D.Cache = D.Cache'Old);
   pragma Postcondition (Static => D.Dynamics.Total.all = D.Dynamics.Total.all'Old);
   pragma Postcondition (Static => Array_Bounded (D.Dynamics.Total));

   procedure Solve (D : in out Simulation; Damping_Step : Real; Result : out Status)
   is
   begin
      if D.Cache.Mass_Compact then
         if D.Solver_Policy = Compatible then
            Load_Compact_Buffers
              (D.Ancestors, D.Dynamics.Compact_Mass.all, D.Joint_Config.all,
               D.Scratch.Ancestor_Factor.all, Damping_Step, Result);
            if Result = Success then
               Solve_Compatible_Buffers
                 (D.Ancestors, D.Dynamics.Total.all, D.Scratch.Ancestor_Factor.all,
                  D.Scratch.Solution.all, D.First_Clamped, Result);
            end if;
         else
            declare
               N : constant Natural := D.Nv;
               Dense : Real_Array (0 .. N * N - 1);
            begin
               MJ.Compact_Inertia.Expand (D.Ancestors, D.Dynamics.Compact_Mass.all, Dense);
               --  Expand proves that a bounded canonical cache gives bounded
               --  dense output. No second runtime traversal is needed here.
               pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (Dense));
               Solve_Workspace
                 (D.Nv, D.Ancestors, D.Joint_Config.all, Dense, D.Dynamics.Total.all,
                  D.Solver_Policy, Damping_Step, D.Scratch.Factor.all,
                  D.Scratch.Ancestor_Factor.all, D.Scratch.Rhs.all,
                  D.Scratch.Solution.all, D.Scratch.Condition_Sums.all,
                  D.First_Clamped, Result);
            end;
         end if;
      else
      Solve_Workspace
        (D.Nv, D.Ancestors, D.Joint_Config.all, D.Dynamics.Mass.all, D.Dynamics.Total.all,
         D.Solver_Policy, Damping_Step, D.Scratch.Factor.all, D.Scratch.Ancestor_Factor.all,
         D.Scratch.Rhs.all, D.Scratch.Solution.all, D.Scratch.Condition_Sums.all,
         D.First_Clamped, Result);
      end if;
   end Solve;

   procedure Total_Forces_Buffers
     (Gravity, Bias, Passive, Actuator, Applied : Real_Array;
      Total : in out Real_Array; Result : out Status)
     with Global => null,
     Pre => Total'First = 0 and then Total'Length <= Max_Dofs
       and then Gravity'First = 0 and then Gravity'Last = Total'Last
       and then Bias'First = 0 and then Bias'Last = Total'Last
       and then Passive'First = 0 and then Passive'Last = Total'Last
       and then Actuator'First = 0 and then Actuator'Last = Total'Last
       and then Applied'First = 0 and then Applied'Last = Total'Last
       and then MJ.Smooth_Dynamics.Work_Array (Gravity)
       and then MJ.Smooth_Dynamics.Work_Array (Bias)
       and then MJ.Smooth_Dynamics.Work_Array (Passive)
       and then MJ.Smooth_Dynamics.Work_Array (Actuator)
       and then MJ.Smooth_Kernels.All_Tier0 (Applied),
     Post => (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Total)
       and then (for all I in Total'Range => Total (I) = MJ.Smooth_Dynamics.Total_Force
         (Gravity (I), Bias (I), Passive (I), Actuator (I), Applied (I))))
   is
      Value : Real;
   begin
      Result := Numeric_Limit;
      for I in Total'Range loop
         pragma Loop_Invariant (for all K in 0 .. I - 1 => Total (K) in MJ.Smooth_Dynamics.Work_Real
           and then Total (K) = MJ.Smooth_Dynamics.Total_Force (Gravity (K), Bias (K), Passive (K), Actuator (K), Applied (K)));
         Value := MJ.Smooth_Dynamics.Total_Force (Gravity (I), Bias (I), Passive (I), Actuator (I), Applied (I));
         if not Within_Work (Value) then return; end if;
         Total (I) := Value;
      end loop;
      Result := Success;
   end Total_Forces_Buffers;
   pragma Inline_Always (Total_Forces_Buffers);



   procedure Prove_Work_Bounded (D : Simulation)
     with Ghost => Static, Global => null,
     Pre => D.Dynamics.Total /= null and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Total.all),
     Post => Array_Bounded (D.Dynamics.Total)
   is
   begin
      null;
   end Prove_Work_Bounded;

   procedure Fill_Total (D : in out Simulation; Result : out Status)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Pose_Valid and then D.Cache.Mass_Valid
       and then D.Cache.Passive_Valid and then D.Cache.Actuation_Valid;
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Stable_Ready (D));
   pragma Postcondition (Static => Is_Empty (D) = Is_Empty (D)'Old);
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Positions_Current (D) = Positions_Current (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);
   pragma Postcondition (Static => Position_Values (D) = Position_Values (D)'Old);
   pragma Postcondition (Static => Velocity_Values (D) = Velocity_Values (D)'Old);
   pragma Postcondition (Static => Time (D) = Time (D)'Old);
   pragma Postcondition (Static => Step_Size (D) = Step_Size (D)'Old);
   pragma Postcondition (Static => not D.Cache.Force_Valid);
   pragma Postcondition (Static => D.Cache.Mass_Valid);
   pragma Postcondition (Static => (if Result = Success then Array_Bounded (D.Dynamics.Total)));

   procedure Fill_Total (D : in out Simulation; Result : out Status)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      D.Cache.Force_Valid := False;
      Total_Forces_Buffers
        (D.Dynamics.Gravity.all, D.Dynamics.Bias.all, D.Dynamics.Passive.all,
         D.Dynamics.Actuator.all, D.State.Applied.all, D.Dynamics.Total.all, Result);
      pragma Assert (Static => (if Result = Success then
         MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Total.all)));
      if Result = Success then Prove_Work_Bounded (D); end if;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Solver_Ready_Properties (D);
   end Fill_Total;
   pragma Inline_Always (Fill_Total);

   procedure Apply_External_Total
     (D : in out Simulation; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Global => null,
     Pre => Is_Ready (D) and then Positions_Current (D) and then D.Cache.Mass_Valid
       and then not D.Cache.Force_Valid and then Array_Bounded (D.Dynamics.Total);
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Stable_Ready (D));
   pragma Postcondition (Static => Is_Empty (D) = Is_Empty (D)'Old);
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Positions_Current (D) = Positions_Current (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);
   pragma Postcondition (Static => Position_Values (D) = Position_Values (D)'Old);
   pragma Postcondition (Static => Velocity_Values (D) = Velocity_Values (D)'Old);
   pragma Postcondition (Static => Time (D) = Time (D)'Old);
   pragma Postcondition (Static => Step_Size (D) = Step_Size (D)'Old);
   pragma Postcondition (Static => not D.Cache.Force_Valid);
   pragma Postcondition (Static => D.Cache.Mass_Valid);
   pragma Postcondition (Static => (if Result = Success then Array_Bounded (D.Dynamics.Total)));

   procedure Apply_External_Total
     (D : in out Simulation; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      MJ.Data.External_Loads.Apply_Buffers
        (D.Body_Config.all, D.Joint_Config.all, D.Kinematic.Bodies.all,
         D.Kinematic.Joints.all, External, D.Dynamics.Total.all, Result);
      pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Total.all));
      Prove_Work_Bounded (D);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Solver_Ready_Properties (D);
   end Apply_External_Total;
   pragma Inline_Always (Apply_External_Total);

   procedure Publish_Acceleration (D : in out Simulation; Result : out Status)
     with Global => null,
     Pre => Is_Ready (D) and then not D.Cache.Force_Valid and then Array_Bounded (D.Dynamics.Total);
   pragma Postcondition (Static => Is_Ready (D));
   pragma Postcondition (Static => Stable_Ready (D));
   pragma Postcondition (Static => Is_Empty (D) = Is_Empty (D)'Old);
   pragma Postcondition (Static => Shape (D) = Shape (D)'Old);
   pragma Postcondition (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Static => Positions_Current (D) = Positions_Current (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);
   pragma Postcondition (Static => Position_Values (D) = Position_Values (D)'Old);
   pragma Postcondition (Static => Velocity_Values (D) = Velocity_Values (D)'Old);
   pragma Postcondition (Static => Time (D) = Time (D)'Old);
   pragma Postcondition (Static => Step_Size (D) = Step_Size (D)'Old);
   pragma Postcondition (Static => (if Result = Success then Forces_Current (D)));

   procedure Publish_Acceleration (D : in out Simulation; Result : out Status)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Result := Numeric_Limit;
      for I in 0 .. D.Nv - 1 loop
         if D.Scratch.Solution (I) not in Tier0_Real then return; end if;
         pragma Loop_Invariant (for all K in 0 .. I => D.Scratch.Solution (K) in Tier0_Real);
      end loop;
      D.Dynamics.Acceleration.all := D.Scratch.Solution.all;
      D.Cache.Force_Valid := True;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Result := Success;
   end Publish_Acceleration;
   pragma Inline_Always (Publish_Acceleration);

   procedure Solve_Acceleration
     (D : in out Simulation; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Forces_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Solver_Ready_Properties (D);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      pragma Assert (Static => Phase_Ready (D));
      if not (D.Cache.Pose_Valid and then D.Cache.Mass_Valid and then D.Cache.Passive_Valid and then D.Cache.Actuation_Valid) then
         Result := Stale_Results;
         return;
      end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Fill_Total (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      if Result /= Success then return; end if;
      if External'Length > 0 then
         declare
            Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
            Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
            Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
            Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
            Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
         begin
            Apply_External_Total (D, Result, External);
            MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
            MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
            MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
            MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
            Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         end;
         if Result /= Success then return; end if;
      end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Solve (D, 0.0, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      if Result /= Success then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Publish_Acceleration (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
   end Solve_Acceleration;

   function Damping_Present (D : Simulation) return Boolean
     with Global => null, Pre => Is_Ready (D),
     Post => Damping_Present'Result = (for some J in 0 .. D.Nj - 1 => D.Joint_Config (J).Damping > 0.0)
   is
   begin
      for J in 0 .. D.Nj - 1 loop
         if D.Joint_Config (J).Damping > 0.0 then return True; end if;
         pragma Loop_Invariant (for all K in 0 .. J => D.Joint_Config (K).Damping = 0.0);
      end loop;
      return False;
   end Damping_Present;

   procedure Copy_Acceleration (D : in out Simulation)
     with Global => null, Pre => Is_Ready (D) and then D.Cache.Force_Valid,
     Post => (Static => Is_Ready (D) and then Stable_Ready (D)
       and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then Activation_Values (D) = Activation_Values (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then Positions_Current (D) = Positions_Current (D)'Old
       and then Configuration (D) = Configuration (D)'Old
       and then Position_Values (D) = Position_Values (D)'Old
       and then Velocity_Values (D) = Velocity_Values (D)'Old
       and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
       and then Forces_Current (D) and then D.Cache = D.Cache'Old
       and then D.Scratch.Solution.all = D.Dynamics.Acceleration.all)
   is
   begin
      D.Scratch.Solution.all := D.Dynamics.Acceleration.all;
   end Copy_Acceleration;
   pragma Inline_Always (Copy_Acceleration);

   procedure Solve_Euler (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Forces_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
   begin
      Solver_Ready_Properties (D);
      pragma Assert (Static => Phase_Ready (D));
      if not D.Cache.Force_Valid then
         Result := Stale_Results;
      elsif D.Implicit_Damping and then Damping_Present (D) then
         if not D.Cache.Mass_Valid then Result := Stale_Results; return; end if;
         Solve (D, D.Timestep, Result);
         Solver_Ready_Properties (D);
      else
         Copy_Acceleration (D);
         Result := Success;
      end if;
      pragma Assert (Stable_Ready (D));
   end Solve_Euler;
end MJ.Data.Inertia_Phase;

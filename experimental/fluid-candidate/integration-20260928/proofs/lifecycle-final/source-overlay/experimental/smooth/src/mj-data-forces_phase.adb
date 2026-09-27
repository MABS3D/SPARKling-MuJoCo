with MJ.Gravity_Bounds;
with MJ.Data.Fluid_Phase;
with MJ.Fluid_Kernels;
with MJ.Composite_Weights;
with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;
with MJ.Fused_RNE;
with MJ.Spatial_Storage;
with MJ.Data.Pipeline;
with MJ.Data.Spatial;
with MJ.Spatial_Dynamics;
with MJ.Smooth_Topology;

package body MJ.Data.Forces_Phase with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
   function Capture_Configuration (D : Simulation) return Configuration_Snapshot
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => Capture_Configuration'Result = Configuration (D)
   is
      C : constant Configuration_Snapshot := Configuration (D);
   begin
      Prove_Configuration_Equality (C, Configuration (D));
      return C;
   end Capture_Configuration;

   function Inertia_Times (R : Matrix; Diagonal, V : Vector) return Vector
     renames MJ.Smooth_Kernels.Inertia_Times;

   --  Scalar-joint comVel and RNE. All vectors share the root subtree COM
   --  frame prepared for CRB; no repeated inertia rotation or wrench shifting.
   package SK renames MJ.Spatial_Kernels;
   use type SK.Motion;
   package SD renames MJ.Spatial_Dynamics;
   package T renames MJ.Smooth_Topology;
   subtype Motion_Array is MJ.Fluid_Kernels.Motion_Array;

   procedure Transfer_Motion_Bound (Left, Right : SK.Motion; Limit : Real)
     with Ghost => Static, Global => null,
       Pre => Limit >= 0.0 and then Left = Right and then SK.Bounded (Left, Limit),
       Post => SK.Bounded (Right, Limit)
   is
   begin
      null;
   end Transfer_Motion_Bound;

   procedure Preserve_Gravity_Prefix
     (Before, After : Motion_Array; Old_Weights, New_Weights : MJ.Composite_Weights.Weight_Array;
      B, P : Natural)
     with Ghost => Static, Global => null,
       Pre => Before'First = 0 and then After'First = 0
         and then After'Last = Before'Last
         and then Old_Weights'First = 0 and then Old_Weights'Last = Before'Last
         and then New_Weights'First = 0 and then New_Weights'Last = Before'Last
         and then P < B and then B <= Before'Last
         and then (for all K in 0 .. B => Old_Weights (K) > 0
           and then SK.Bounded (Before (K), MJ.Gravity_Bounds.Budget (Old_Weights (K))))
         and then (if P > 0 then New_Weights (P) > 0
           and then SK.Bounded (After (P), MJ.Gravity_Bounds.Budget (New_Weights (P))))
         and then (for all K in 0 .. B - 1 =>
           (if P = 0 or else K /= P then
              New_Weights (K) = Old_Weights (K) and then After (K) = Before (K))),
       Post => (for all K in 0 .. B - 1 => New_Weights (K) > 0
         and then SK.Bounded (After (K), MJ.Gravity_Bounds.Budget (New_Weights (K))))
   is
   begin
      for K in 0 .. B - 1 loop
         if P = 0 or else K /= P then
            Transfer_Motion_Bound (Before (K), After (K), MJ.Gravity_Bounds.Budget (Old_Weights (K)));
         end if;
         pragma Loop_Invariant (for all I in 0 .. K => New_Weights (I) > 0
           and then SK.Bounded (After (I), MJ.Gravity_Bounds.Budget (New_Weights (I))));
      end loop;
   end Preserve_Gravity_Prefix;

   procedure Advance_Joint (Vel, Delta_Acc : in out SK.Motion; Axis : SK.Motion;
                            Speed : Tier0_Real; Ok : out Boolean)
     with Global => null,
     Pre => SK.Bounded (Vel, 1.0e12) and then SK.Bounded (Delta_Acc, 1.0e12) and then SK.Bounded (Axis, 1.0e12),
     Post => SK.Bounded (Vel, 1.0e12) and then SK.Bounded (Delta_Acc, 1.0e12)
       and then (if Ok then Vel = SD.Add_Scaled (Vel'Old, Axis, Speed)
         and then Delta_Acc = SD.Add_Scaled (Delta_Acc'Old, SD.Cross_Motion (Vel'Old, Axis), Speed))
   is
      Rate : constant SK.Motion := SD.Cross_Motion (Vel, Axis);
      Candidate : SK.Motion := SD.Add_Scaled (Vel, Axis, Speed);
   begin
      Ok := False;
      if not SK.Bounded (Candidate, 1.0e12) then return; end if;
      Vel := Candidate;
      Candidate := SD.Add_Scaled (Delta_Acc, Rate, Speed);
      if not SK.Bounded (Candidate, 1.0e12) then return; end if;
      Delta_Acc := Candidate;
      Ok := True;
   end Advance_Joint;
   pragma Inline_Always (Advance_Joint);

   procedure Body_Wrenches
     (I : SK.Inertia; Velocity, Acceleration : SK.Motion; Gravity_Vector : Vector;
      Gravity_Enabled : Boolean; Bias, Gravity : out SK.Motion; Ok : out Boolean)
     with Global => null, Relaxed_Initialization => Gravity,
     Pre => SK.Bounded (I, 1.0e36) and then SK.Bounded (Velocity, 1.0e12)
       and then SK.Bounded (Acceleration, 1.0e12) and then Bounded (Gravity_Vector, Max_Val),
     Post => (if Ok then Gravity'Initialized and then SK.Bounded (Bias, 1.0e54) and then SK.Bounded (Gravity, 1.0e48))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Fused_RNE.Gyroscopic_Model);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Fused_RNE.Body_Force_Model);
   begin
      MJ.Fused_RNE.Try_Body_Force (I, Velocity, Acceleration, Bias, Ok);
      if not Ok then return; end if;
      Gravity := (if Gravity_Enabled then SD.Gravity_Force
        (I (6), I (7), I (8), I (9), Gravity_Vector (0), Gravity_Vector (1), Gravity_Vector (2))
        else [others => 0.0]);
   end Body_Wrenches;
   pragma Inline_Always (Body_Wrenches);

   procedure Forward_One_Body
     (C : Body_Parameters; Joint_Config : Joint_Parameter_Array;
      Qvel, Spatial_Motions : Real_Array; I : SK.Inertia;
      Parent_Velocity, Parent_Acceleration : SK.Motion; Gravity_Vector : Vector;
      Gravity_Enabled : Boolean; Vel, Acc, Bias_Out, Gravity_Out : out SK.Motion; Ok : out Boolean)
     with Global => null, Relaxed_Initialization => (Vel, Acc, Bias_Out, Gravity_Out),
     Pre => Joint_Config'First = 0 and then Joint_Config'Length <= Max_Dofs
       and then Qvel'First = 0 and then Qvel'Last = Joint_Config'Last
       and then (for all X of Qvel => X in Tier0_Real)
       and then C.Joint_Count <= Joint_Config'Length
       and then (if C.Joint_Count > 0 then C.First_Joint >= 0
         and then C.First_Joint <= Joint_Config'Length - C.Joint_Count)
       and then (for all J in Joint_Config'Range => Joint_Config (J).Vadr = J)
       and then Spatial_Motions'First = 0 and then Spatial_Motions'Length = 6 * Qvel'Length
       and then (for all X of Spatial_Motions => X in -1.0e12 .. 1.0e12)
       and then SK.Bounded (I, 1.0e36) and then SK.Bounded (Parent_Velocity, 1.0e12)
       and then SK.Bounded (Parent_Acceleration, 1.0e12) and then Bounded (Gravity_Vector, Max_Val),
     Post => (if Ok then Vel'Initialized and then Acc'Initialized and then Bias_Out'Initialized and then Gravity_Out'Initialized
       and then SK.Bounded (Vel, 1.0e12) and then SK.Bounded (Acc, 1.0e12)
       and then SK.Bounded (Bias_Out, 1.0e54) and then SK.Bounded (Gravity_Out, 1.0e48))
   is
      Current_Velocity : SK.Motion := Parent_Velocity;
      Delta_Acc : SK.Motion := [others => 0.0];
      Current_Acceleration : SK.Motion;
      Accepted : Boolean;
   begin
      Ok := False;
      --  Match mj_comVel: form cdofdot before adding this joint's velocity.
      for K in 0 .. C.Joint_Count - 1 loop
         pragma Loop_Invariant (SK.Bounded (Current_Velocity, 1.0e12) and then SK.Bounded (Delta_Acc, 1.0e12));
         declare
            J : constant Natural := C.First_Joint + K;
            V : constant Natural := Joint_Config (J).Vadr;
            Axis : constant SK.Motion := MJ.Spatial_Storage.Load_Motion (Spatial_Motions, 6 * J);
         begin
            Advance_Joint (Current_Velocity, Delta_Acc, Axis, Qvel (V), Accepted);
            if not Accepted then return; end if;
         end;
      end loop;
      Current_Acceleration := SK.Add_Wrenches (Parent_Acceleration, Delta_Acc);
      if not SK.Bounded (Current_Acceleration, 1.0e12) then return; end if;
      Body_Wrenches (I, Current_Velocity, Current_Acceleration, Gravity_Vector,
                     Gravity_Enabled, Bias_Out, Gravity_Out, Ok);
      if not Ok then return; end if;
      Vel := Current_Velocity;
      Transfer_Motion_Bound (Current_Velocity, Vel, 1.0e12);
      Acc := Current_Acceleration;
      pragma Assert (Static => Vel'Initialized and then Acc'Initialized and then Bias_Out'Initialized and then Gravity_Out'Initialized);
      pragma Assert (Static => SK.Bounded (Vel, 1.0e12));
      pragma Assert (Static => SK.Bounded (Acc, 1.0e12));
      pragma Assert (Static => SK.Bounded (Bias_Out, 1.0e54));
      pragma Assert (Static => SK.Bounded (Gravity_Out, 1.0e48));
   end Forward_One_Body;
   pragma Inline_Always (Forward_One_Body);

   procedure Finish_Initialization (A : Motion_Array)
     with Ghost => Static, Global => null, Relaxed_Initialization => A,
     Pre => (for all I in A'Range => A (I)'Initialized),
     Post => A'Initialized
   is
   begin
      null;
   end Finish_Initialization;

   procedure Store_Motion_Prefix
     (Buffer : in out Motion_Array; Index : Natural; Value : SK.Motion; Limit : Real)
     with Global => null, Relaxed_Initialization => Buffer,
     Pre => Limit >= 0.0 and then Buffer'First = 0 and then Index in Buffer'Range
       and then SK.Bounded (Value, Limit)
       and then (for all K in 0 .. Index - 1 => Buffer (K)'Initialized
         and then SK.Bounded (Buffer (K), Limit)),
     Post => (for all K in 0 .. Index => Buffer (K)'Initialized
       and then SK.Bounded (Buffer (K), Limit)) and then Buffer (Index) = Value
   is
   begin
      Buffer (Index) := Value;
   end Store_Motion_Prefix;
   pragma Inline_Always (Store_Motion_Prefix);

   procedure Forward_Bodies
     (Body_Config : Body_Parameter_Array; Joint_Config : Joint_Parameter_Array;
      Qvel, Spatial_Inertias, Spatial_Motions : Real_Array; Gravity_Vector : Vector;
      Gravity_Enabled : Boolean; Bias, Gravity : out Motion_Array; Ok : out Boolean; Velocity : in out Motion_Array)
     with Global => null, Relaxed_Initialization => (Bias, Gravity),
     Pre => Velocity'First = 0 and then Velocity'Length = Body_Config'Length
       and then Body_Config'First = 0 and then Body_Config'Length in 1 .. Max_Bodies
       and then Joint_Config'First = 0 and then Joint_Config'Length <= Max_Dofs
       and then Qvel'First = 0 and then Qvel'Last = Joint_Config'Last
       and then (for all X of Qvel => X in Tier0_Real)
       and then (for all B in Body_Config'Range =>
         (if B = 0 then Body_Config (B).Parent = 0 else Body_Config (B).Parent < B)
         and then Body_Config (B).Joint_Count <= Joint_Config'Length
         and then (if Body_Config (B).Joint_Count > 0 then
           Body_Config (B).First_Joint >= 0
           and then Body_Config (B).First_Joint <= Joint_Config'Length - Body_Config (B).Joint_Count))
       and then (for all J in Joint_Config'Range => Joint_Config (J).Vadr = J)
       and then Spatial_Inertias'First = 0
       and then Spatial_Inertias'Length = 10 * Body_Config'Length
       and then (for all X of Spatial_Inertias => X in -1.0e36 .. 1.0e36)
       and then Spatial_Motions'First = 0
       and then Spatial_Motions'Length = 6 * Qvel'Length
       and then (for all X of Spatial_Motions => X in -1.0e12 .. 1.0e12)
       and then Bounded (Gravity_Vector, Max_Val)
       and then Bias'First = 0 and then Bias'Last = Body_Config'Last
       and then Gravity'First = 0 and then Gravity'Last = Body_Config'Last,
     Post => (if Ok then Bias'Initialized and then Gravity'Initialized
       and then (for all X of Bias => SK.Bounded (X, 1.0e54))
       and then (for all X of Gravity => SK.Bounded (X, 1.0e48))
       and then MJ.Fluid_Kernels.Motions_Bounded (Velocity))
   is
      Acceleration : Motion_Array (Body_Config'Range) with Relaxed_Initialization;
      V, A, G, F : SK.Motion with Relaxed_Initialization;
      Accepted : Boolean;
   begin
      Ok := False;
      Velocity (0) := [others => 0.0];
      Acceleration (0) := [others => 0.0];
      Bias (0) := [others => 0.0];
      Gravity (0) := [others => 0.0];
      if Body_Config'Length = 1 then
         Finish_Initialization (Bias);
         Finish_Initialization (Gravity);
         Ok := True;
         return;
      end if;
      for B in 1 .. Body_Config'Length - 1 loop
            Forward_One_Body
              (Body_Config (B), Joint_Config, Qvel, Spatial_Motions,
               MJ.Spatial_Storage.Load_Inertia (Spatial_Inertias, 10 * B),
               Velocity (Body_Config (B).Parent), Acceleration (Body_Config (B).Parent),
               Gravity_Vector, Gravity_Enabled, V, A, F, G, Accepted);
            if not Accepted then return; end if;
            Velocity (B) := V;
            Store_Motion_Prefix (Acceleration, B, A, 1.0e12);
            Store_Motion_Prefix (Bias, B, F, 1.0e54);
            Store_Motion_Prefix (Gravity, B, G, 1.0e48);
         pragma Loop_Invariant (for all K in 0 .. B => SK.Bounded (Velocity (K), 1.0e12));
         pragma Loop_Invariant (for all K in 0 .. B => Acceleration (K)'Initialized
           and then SK.Bounded (Acceleration (K), 1.0e12));
         pragma Loop_Invariant (for all K in 0 .. B => Bias (K)'Initialized
           and then SK.Bounded (Bias (K), 1.0e54));
         pragma Loop_Invariant (for all K in 0 .. B => Gravity (K)'Initialized
           and then SK.Bounded (Gravity (K), 1.0e48));
      end loop;
      Finish_Initialization (Bias);
      Finish_Initialization (Gravity);
      pragma Assert (Static => (for all X of Bias => SK.Bounded (X, 1.0e54)));
      pragma Assert (Static => (for all X of Gravity => SK.Bounded (X, 1.0e48)));
      Ok := True;
   end Forward_Bodies;
   pragma Inline_Always (Forward_Bodies);

   procedure Backward_Bodies
     (Body_Config : Body_Parameter_Array; Bias, Gravity : in out Motion_Array; Ok : out Boolean)
     with Global => null,
     Pre => Body_Config'First = 0 and then Body_Config'Length in 1 .. Max_Bodies
       and then (for all B in Body_Config'Range => (if B = 0 then Body_Config (B).Parent = 0 else Body_Config (B).Parent < B))
       and then Bias'First = 0 and then Bias'Last = Body_Config'Last
       and then Gravity'First = 0 and then Gravity'Last = Body_Config'Last
       and then (for all X of Bias => SK.Bounded (X, 1.0e54))
       and then (for all X of Gravity => SK.Bounded (X, 1.0e48)),
     Post => (for all X of Bias => SK.Bounded (X, 1.0e54))
       and then (for all X of Gravity => SK.Bounded (X, 1.0e54))
   is
      package GB renames MJ.Gravity_Bounds;
      package CW renames MJ.Composite_Weights;
      Weights : CW.Weight_Array (Gravity'Range) with Ghost => Static;
   begin
      CW.Initialize (Weights);
      GB.Budget_Bounds (1);
      Ok := False;
      for B in reverse 1 .. Body_Config'Length - 1 loop
         pragma Loop_Invariant (for all K in Bias'Range => SK.Bounded (Bias (K), 1.0e54)
           and then SK.Bounded (Gravity (K), 1.0e54));
         pragma Loop_Invariant (Static => CW.Prefix_Sum (Weights, Weights'Length) <= Max_Bodies);
         pragma Loop_Invariant (Static => (for all K in Weights'Range =>
           (if K <= B then Weights (K) > 0 else Weights (K) = 0)));
         pragma Loop_Invariant (Static => (for all K in 0 .. B =>
           Weights (K) > 0 and then SK.Bounded (Gravity (K), GB.Budget (Weights (K)))));
         declare
            P : constant Natural := Body_Config (B).Parent;
            Sum : SK.Motion;
            Old_Gravity : constant Motion_Array := Gravity with Ghost => Static;
            Old_Weights : constant CW.Weight_Array := Weights with Ghost => Static;
         begin
            if P > 0 then
               Sum := SK.Add_Wrenches (Bias (P), Bias (B));
               if not SK.Bounded (Sum, 1.0e54) then return; end if;
               Bias (P) := Sum;
               CW.Pair_Bound (Weights, Weights'Length, P, B);
               GB.Bound_Wrench_Sum (Gravity (P), Gravity (B), Weights (P), Weights (B));
               GB.Budget_Bounds (Weights (P) + Weights (B));
               Sum := SK.Add_Wrenches (Gravity (P), Gravity (B));
               Gravity (P) := Sum;
               CW.Transfer (Weights, B, P);
            else
               CW.Discard (Weights, B);
            end if;
            Preserve_Gravity_Prefix (Old_Gravity, Gravity, Old_Weights, Weights, B, P);
         end;
      end loop;
      pragma Assert (Static => (for all X of Bias => SK.Bounded (X, 1.0e54)));
      pragma Assert (Static => (for all X of Gravity => SK.Bounded (X, 1.0e54)));
      Ok := True;
   end Backward_Bodies;
   pragma Inline_Always (Backward_Bodies);

   procedure Store_Force_Entry (A : in out Real_Array; Index : Natural; Value : MJ.Smooth_Dynamics.Work_Real)
     with Global => null, Pre => Index in A'Range and then MJ.Smooth_Dynamics.Work_Array (A),
     Post => MJ.Smooth_Dynamics.Work_Array (A)
       and then (for all K in A'Range => A (K) = (if K = Index then Value else A'Old (K)))
   is
   begin
      A (Index) := Value;
   end Store_Force_Entry;
   pragma Inline_Always (Store_Force_Entry);

   procedure Project_Bodies
     (Topology : T.Cache; Spatial_Motions : Real_Array; Bias, Gravity : Motion_Array;
      Gravity_Out, Bias_Out : in out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Bias'First = 0 and then Bias'Length <= Max_Bodies and then Bias'Length = T.Body_Count (Topology)
       and then Gravity'First = 0 and then Gravity'Last = Bias'Last
       and then (for all X of Bias => SK.Bounded (X, 1.0e54))
       and then (for all X of Gravity => SK.Bounded (X, 1.0e54))
       and then Gravity_Out'First = 0 and then Gravity_Out'Length <= Max_Dofs and then Gravity_Out'Length = T.Dof_Count (Topology)
       and then Bias_Out'First = 0 and then Bias_Out'Last = Gravity_Out'Last
       and then MJ.Smooth_Dynamics.Work_Array (Gravity_Out) and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
       and then Spatial_Motions'First = 0 and then Spatial_Motions'Length = 6 * Gravity_Out'Length
       and then (for all X of Spatial_Motions => X in -1.0e12 .. 1.0e12),
     Post => MJ.Smooth_Dynamics.Work_Array (Gravity_Out) and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
   is
   begin
      Ok := False;
      for V in Gravity_Out'Range loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
           and then MJ.Smooth_Dynamics.Work_Array (Bias_Out));
         declare
            Axis : constant SK.Motion := MJ.Spatial_Storage.Load_Motion (Spatial_Motions, 6 * T.Dof_Joint (Topology, V));
            Body_Id : constant Natural := T.Dof_Body (Topology, V);
            G : constant Real := SK.Dot (Axis, Gravity (Body_Id));
            B : constant Real := SK.Dot (Axis, Bias (Body_Id));
         begin
            if not Within_Work (G) or else not Within_Work (B) then return; end if;
            Store_Force_Entry (Gravity_Out, V, G);
            Store_Force_Entry (Bias_Out, V, B);
         end;
      end loop;
      Ok := True;
   end Project_Bodies;
   pragma Inline_Always (Project_Bodies);

   procedure Recursive_Forces_Buffers
     (Body_Config : Body_Parameter_Array; Joint_Config : Joint_Parameter_Array;
      Qvel, Spatial_Inertias, Spatial_Motions : Real_Array;
      Topology : MJ.Smooth_Topology.Cache; Gravity_Vector : Vector;
      Gravity_Enabled : Boolean; Gravity_Out, Bias_Out : out Real_Array; Ok : out Boolean; Velocity : in out Motion_Array)
     with Global => null,
     Pre => Velocity'First = 0 and then Velocity'Length = Body_Config'Length
       and then Body_Config'First = 0 and then Body_Config'Length in 1 .. Max_Bodies
       and then Joint_Config'First = 0 and then Joint_Config'Length <= Max_Dofs
       and then Qvel'First = 0 and then Qvel'Last = Joint_Config'Last
       and then (for all X of Qvel => X in Tier0_Real)
       and then (for all B in Body_Config'Range =>
         (if B = 0 then Body_Config (B).Parent = 0 else Body_Config (B).Parent < B)
         and then Body_Config (B).Joint_Count <= Joint_Config'Length
         and then (if Body_Config (B).Joint_Count > 0 then
           Body_Config (B).First_Joint >= 0
           and then Body_Config (B).First_Joint <= Joint_Config'Length - Body_Config (B).Joint_Count))
       and then (for all J in Joint_Config'Range => Joint_Config (J).Vadr = J)
       and then Spatial_Inertias'First = 0
       and then Spatial_Inertias'Length = 10 * Body_Config'Length
       and then (for all X of Spatial_Inertias => X in -1.0e36 .. 1.0e36)
       and then Spatial_Motions'First = 0
       and then Spatial_Motions'Length = 6 * Qvel'Length
       and then (for all X of Spatial_Motions => X in -1.0e12 .. 1.0e12)
       and then MJ.Smooth_Topology.Body_Count (Topology) = Body_Config'Length
       and then MJ.Smooth_Topology.Dof_Count (Topology) = Qvel'Length
       and then Bounded (Gravity_Vector, Max_Val)
       and then Gravity_Out'First = 0 and then Gravity_Out'Last = Qvel'Last
       and then Bias_Out'First = 0 and then Bias_Out'Last = Qvel'Last,
     Post => MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
       and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
       and then (if Ok then MJ.Fluid_Kernels.Motions_Bounded (Velocity))
   is
      Bias, Gravity : Motion_Array (Body_Config'Range) with Relaxed_Initialization;
   begin
      Gravity_Out := [others => 0.0];
      Bias_Out := [others => 0.0];
      Forward_Bodies (Body_Config, Joint_Config, Qvel, Spatial_Inertias, Spatial_Motions,
                      Gravity_Vector, Gravity_Enabled, Bias, Gravity, Ok, Velocity);
      if not Ok then return; end if;
      Backward_Bodies (Body_Config, Bias, Gravity, Ok);
      if not Ok then return; end if;
      Project_Bodies (Topology, Spatial_Motions, Bias, Gravity, Gravity_Out, Bias_Out, Ok);
   end Recursive_Forces_Buffers;
   pragma Inline_Always (Recursive_Forces_Buffers);

   procedure Try_Recursive
     (D : Simulation; Gravity_Out, Bias_Out : out Real_Array; Ok : out Boolean; Velocity : in out Motion_Array)
     with Global => null,
     Pre => Is_Ready (D) and then Velocity'First = 0 and then Velocity'Length in 1 .. Max_Bodies
       and then Velocity'Length = D.Nb and then D.Cache.Pose_Valid and then D.Cache.Spatial_Valid
       and then Gravity_Out'First = 0 and then Gravity_Out'Last = D.Nv - 1
       and then Bias_Out'First = 0 and then Bias_Out'Last = D.Nv - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
       and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
       and then (if Ok then MJ.Fluid_Kernels.Motions_Bounded (Velocity))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
   begin
      Recursive_Forces_Buffers
        (D.Body_Config.all, D.Joint_Config.all, D.State.Qvel.all,
         D.Kinematic.Spatial_Inertias.all, D.Kinematic.Spatial_Motions.all,
         D.Topology, D.Gravity, D.Gravity_Enabled, Gravity_Out, Bias_Out, Ok, Velocity);
   end Try_Recursive;

   procedure Passive_Buffers
     (Joints : Joint_Parameter_Array; Qpos, Qvel : Real_Array;
      Spring_Enabled, Damper_Enabled : Boolean; Passive : in out Real_Array;
      Result : out Status)
     with Global => null,
     Pre => Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Qpos'First = 0 and then Qpos'Last = Joints'Last
       and then Qvel'First = 0 and then Qvel'Last = Joints'Last
       and then Passive'First = 0 and then Passive'Last = Joints'Last
       and then (for all J in Joints'Range => Joints (J).Qadr = J and then Joints (J).Vadr = J)
       and then MJ.Smooth_Kernels.All_Tier0 (Qpos)
       and then MJ.Smooth_Kernels.All_Tier0 (Qvel),
     Post => (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Passive) and then
         (for all J in Joints'Range => Passive (J) = MJ.Smooth_Kernels.Passive_Force
           (Qpos (J), Joints (J).Spring_Reference, Qvel (J),
            Joints (J).Stiffness, Joints (J).Damping, Spring_Enabled, Damper_Enabled)))
   is
   begin
      Result := Numeric_Limit;
      for J in Joints'Range loop
         pragma Loop_Invariant (for all K in 0 .. J - 1 => Passive (K) in MJ.Smooth_Dynamics.Work_Real);
         pragma Loop_Invariant (for all K in 0 .. J - 1 => Passive (K) = MJ.Smooth_Kernels.Passive_Force
           (Qpos (K), Joints (K).Spring_Reference, Qvel (K),
            Joints (K).Stiffness, Joints (K).Damping, Spring_Enabled, Damper_Enabled));
         declare
            C : constant Joint_Parameters := Joints (J);
            Value : constant Real := MJ.Smooth_Kernels.Passive_Force
              (Qpos (C.Qadr), C.Spring_Reference, Qvel (C.Vadr),
               C.Stiffness, C.Damping, Spring_Enabled, Damper_Enabled);
         begin
            if not Within_Work (Value) then return; end if;
            Passive (C.Vadr) := Value;
         end;
      end loop;
      Result := Success;
   end Passive_Buffers;
   pragma Inline_Always (Passive_Buffers);

   procedure Passive_Bounded_Buffers
     (Joints : Joint_Parameter_Array; Qpos, Qvel : Real_Array;
      Spring_Enabled, Damper_Enabled : Boolean; Passive : in out Real_Array;
      Result : out Status)
     with Global => null,
     Pre => Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Qpos'First = 0 and then Qpos'Last = Joints'Last
       and then Qvel'First = 0 and then Qvel'Last = Joints'Last
       and then Passive'First = 0 and then Passive'Last = Joints'Last
       and then (for all J in Joints'Range => Joints (J).Qadr = J and then Joints (J).Vadr = J)
       and then MJ.Smooth_Kernels.All_Tier0 (Qpos)
       and then MJ.Smooth_Kernels.All_Tier0 (Qvel),
     Post => (if Result = Success then MJ.Smooth_Dynamics.Work_Array (Passive))
   is
   begin
      Passive_Buffers (Joints, Qpos, Qvel, Spring_Enabled, Damper_Enabled, Passive, Result);
   end Passive_Bounded_Buffers;
   pragma Inline_Always (Passive_Bounded_Buffers);

   procedure Body_Forces
     (C : Body_Parameters; S : Body_State; Gravity_Vector : Vector;
      Gravity_Enabled : Boolean; Force, Torque, Gravity : out Vector; Ok : out Boolean)
     with Global => null,
     Pre => Body_Bounded (S) and then Bounded (C.Inertial_Position, Max_Val)
       and then Bounded (C.Inertia, Max_Val) and then Bounded (Gravity_Vector, Max_Val),
     Post => Ok = (Bounded (Force) and then Bounded (Torque) and then Bounded (Gravity))
       and then Force = MJ.Smooth_Dynamics.Mass_Force (C.Mass,
         MJ.Smooth_Dynamics.Center_Acceleration
           (S.Linear_Bias, S.Angular_Bias, S.Angular_Velocity,
            MJ.Smooth_Dynamics.Apply_Config (S.Rotation, C.Inertial_Position)))
       and then Torque = MJ.Smooth_Dynamics.Inertial_Torque
         (S.Inertial_Rotation, C.Inertia, S.Angular_Bias, S.Angular_Velocity)
       and then Gravity = (if Gravity_Enabled then C.Mass * Gravity_Vector else Zero)
   is
      Offset : constant Vector := MJ.Smooth_Dynamics.Apply_Config (S.Rotation, C.Inertial_Position);
      Acceleration : constant Vector := MJ.Smooth_Dynamics.Center_Acceleration
        (S.Linear_Bias, S.Angular_Bias, S.Angular_Velocity, Offset);
   begin
      Force := MJ.Smooth_Dynamics.Mass_Force (C.Mass, Acceleration);
      Torque := MJ.Smooth_Dynamics.Inertial_Torque
        (S.Inertial_Rotation, C.Inertia, S.Angular_Bias, S.Angular_Velocity);
      Gravity := (if Gravity_Enabled then C.Mass * Gravity_Vector else Zero);
      Ok := Bounded (Force) and then Bounded (Torque) and then Bounded (Gravity);
   end Body_Forces;
   pragma Inline_Always (Body_Forces);

   procedure Accumulate_Body_Forces
     (Linear_Jacobian, Angular_Jacobian : Real_Array;
      Force, Torque, Gravity : Vector;
      Gravity_Out, Bias_Out : in out Real_Array; Result : out Status)
     with Global => null,
     Pre => Gravity_Out'First = 0 and then Gravity_Out'Length <= Max_Dofs
       and then Bias_Out'First = 0 and then Bias_Out'Last = Gravity_Out'Last
       and then MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
       and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
       and then Linear_Jacobian'First >= 0
       and then MJ.Smooth_Dynamics.Jacobian_Layout (Linear_Jacobian, Gravity_Out'Length)
       and then Angular_Jacobian'First = Linear_Jacobian'First
       and then Angular_Jacobian'Last = Linear_Jacobian'Last
       and then MJ.Smooth_Dynamics.Work_Array (Linear_Jacobian)
       and then MJ.Smooth_Dynamics.Work_Array (Angular_Jacobian)
       and then Bounded (Force) and then Bounded (Torque) and then Bounded (Gravity),
     Post => MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
       and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
       and then (if Result = Success then
         (for all I in Gravity_Out'Range => Gravity_Out (I) =
           MJ.Smooth_Dynamics.Gravity_Contribution (Gravity_Out'Old (I),
             MJ.Smooth_Dynamics.Read_Motion (Linear_Jacobian, Linear_Jacobian'First + 3 * I), Gravity)
           and then Bias_Out (I) = MJ.Smooth_Dynamics.Bias_Contribution (Bias_Out'Old (I),
             MJ.Smooth_Dynamics.Read_Motion (Linear_Jacobian, Linear_Jacobian'First + 3 * I), Force,
             MJ.Smooth_Dynamics.Read_Motion (Angular_Jacobian, Angular_Jacobian'First + 3 * I), Torque)))
   is
   begin
      Result := Numeric_Limit;
      for I in Gravity_Out'Range loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Gravity_Out)
           and then MJ.Smooth_Dynamics.Work_Array (Bias_Out));
         pragma Loop_Invariant (for all K in I .. Gravity_Out'Last =>
           Gravity_Out (K) = Gravity_Out'Loop_Entry (K) and then Bias_Out (K) = Bias_Out'Loop_Entry (K));
         pragma Loop_Invariant (for all K in 0 .. I - 1 => Gravity_Out (K) =
           MJ.Smooth_Dynamics.Gravity_Contribution (Gravity_Out'Loop_Entry (K),
             MJ.Smooth_Dynamics.Read_Motion (Linear_Jacobian, Linear_Jacobian'First + 3 * K), Gravity)
           and then Bias_Out (K) = MJ.Smooth_Dynamics.Bias_Contribution (Bias_Out'Loop_Entry (K),
             MJ.Smooth_Dynamics.Read_Motion (Linear_Jacobian, Linear_Jacobian'First + 3 * K), Force,
             MJ.Smooth_Dynamics.Read_Motion (Angular_Jacobian, Angular_Jacobian'First + 3 * K), Torque));
         declare
            Base : constant Natural := Linear_Jacobian'First + 3 * I;
            Linear : constant Vector := MJ.Smooth_Dynamics.Read_Motion (Linear_Jacobian, Base);
            Angular : constant Vector := MJ.Smooth_Dynamics.Read_Motion (Angular_Jacobian, Base);
            G : constant Real := MJ.Smooth_Dynamics.Gravity_Contribution (Gravity_Out (I), Linear, Gravity);
            B : constant Real := MJ.Smooth_Dynamics.Bias_Contribution (Bias_Out (I), Linear, Force, Angular, Torque);
         begin
            if not Within_Work (G) or else not Within_Work (B) then return; end if;
            Gravity_Out (I) := G;
            Bias_Out (I) := B;
         end;
      end loop;
      Result := Success;
   end Accumulate_Body_Forces;
   pragma Inline_Always (Accumulate_Body_Forces);

   procedure Prove_Body_Slice (N, Nb, B : Natural)
     with Ghost => Static, Global => null,
     Pre => N <= Max_Dofs and then Nb <= Max_Bodies and then B < Nb,
     Post => 3 * B * N + 3 * N <= 3 * Nb * N
       and then 3 * B * N + 3 * N = 3 * (B + 1) * N
   is
   begin
      null;
   end Prove_Body_Slice;

   procedure Dense_Force_Buffers
     (Configs : Body_Parameter_Array; Bodies : Body_State_Array;
      Linear, Angular : Real_Array; Gravity_Vector : Vector; Gravity_Enabled : Boolean;
      Gravity_Out, Bias_Out : out Real_Array; Result : out Status)
     with Global => null,
     Pre => Configs'First = 0 and then Configs'Length in 1 .. Max_Bodies
       and then Bodies'First = 0 and then Bodies'Last = Configs'Last
       and then (for all S of Bodies => Body_Bounded (S))
       and then (for all C of Configs => Bounded (C.Inertial_Position, Max_Val) and then Bounded (C.Inertia, Max_Val))
       and then Gravity_Out'First = 0 and then Gravity_Out'Length <= Max_Dofs
       and then Bias_Out'First = 0 and then Bias_Out'Last = Gravity_Out'Last
       and then Linear'First = 0 and then Linear'Length = 3 * Configs'Length * Gravity_Out'Length
       and then Angular'First = 0 and then Angular'Last = Linear'Last
       and then MJ.Smooth_Dynamics.Work_Array (Linear) and then MJ.Smooth_Dynamics.Work_Array (Angular)
       and then Bounded (Gravity_Vector, Max_Val),
     Post => MJ.Smooth_Dynamics.Work_Array (Gravity_Out) and then MJ.Smooth_Dynamics.Work_Array (Bias_Out)
   is
      N : constant Natural := Gravity_Out'Length;
      Force, Torque, Gravity : Vector;
      Ok : Boolean;
   begin
      Gravity_Out := [others => 0.0];
      Bias_Out := [others => 0.0];
      for B in 1 .. Configs'Last loop
         pragma Loop_Invariant (MJ.Smooth_Dynamics.Work_Array (Gravity_Out) and then MJ.Smooth_Dynamics.Work_Array (Bias_Out));
         Body_Forces (Configs (B), Bodies (B), Gravity_Vector, Gravity_Enabled, Force, Torque, Gravity, Ok);
         if not Ok then Result := Numeric_Limit; return; end if;
         Prove_Body_Slice (N, Configs'Length, B);
         pragma Assert (Static => 3 * B * N + 3 * N <= Linear'Length);
         pragma Assert (Static => 3 * B * N + 3 * N <= Angular'Length);
         Accumulate_Body_Forces
           (Linear (3 * B * N .. 3 * B * N + 3 * N - 1),
            Angular (3 * B * N .. 3 * B * N + 3 * N - 1), Force, Torque, Gravity,
            Gravity_Out, Bias_Out, Result);
         pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (Gravity_Out));
         pragma Assert (Static => MJ.Smooth_Dynamics.Work_Array (Bias_Out));
         if Result /= Success then return; end if;
      end loop;
      Result := Success;
   end Dense_Force_Buffers;
   pragma Inline_Always (Dense_Force_Buffers);

   procedure Zero_Forces (D : in out Simulation)
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
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Passive.all)
         and then not Passive_Current (D) and then not Forces_Current (D)
         and then (for all X of D.Dynamics.Gravity.all => X = 0.0)
         and then (for all X of D.Dynamics.Bias.all => X = 0.0)
         and then (for all X of D.Dynamics.Passive.all => X = 0.0))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Capture_Configuration (D) with Ghost => Static;
   begin
      D.Cache.Passive_Valid := False;
      D.Cache.Force_Valid := False;
      D.Dynamics.Gravity.all := [others => 0.0];
      D.Dynamics.Bias.all := [others => 0.0];
      D.Dynamics.Passive.all := [others => 0.0];
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Zero_Forces;
   pragma Inline_Always (Zero_Forces);

   procedure Publish_Passive (D : in out Simulation)
     with Global => null, Pre => Is_Ready (D) and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Passive.all),
     Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
         and then Passive_Current (D) and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Passive.all))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Capture_Configuration (D) with Ghost => Static;
   begin
      D.Cache.Passive_Valid := True;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Publish_Passive;
   pragma Inline_Always (Publish_Passive);

   procedure Expose_Passive_Inputs (D : Simulation)
     with Ghost => Static, Global => null, Pre => Stable_Ready (D),
     Post => (for all J in D.Joint_Config'Range => D.Joint_Config (J).Qadr = J and then D.Joint_Config (J).Vadr = J)
   is
   begin
      null;
   end Expose_Passive_Inputs;

   procedure Establish_Readiness (D : Simulation)
     with Ghost => Static, Global => null,
     Pre => Storage_Ready (D) and then Configuration_Bounded (D)
       and then Configuration_Valid (D.Body_Config.all, D.Joint_Config.all,
         D.Actuator_Config.all, D.Nb, D.Nj, D.Na)
       and then Inputs_Bounded (D) and then Caches_Bounded (D),
     Post => Is_Ready (D) and then Stable_Ready (D)
   is
   begin
      null;
   end Establish_Readiness;

   procedure Complete_Passive (D : in out Simulation; Result : out Status; Velocity : Motion_Array; Reuse : Boolean)
     with Global => null, Pre => Is_Ready (D) and then (if Reuse then Velocity'First = 0 and then Velocity'Length in 1 .. Max_Bodies and then Velocity'Length = D.Nb
       and then MJ.Fluid_Kernels.Motions_Bounded (Velocity) and then D.Cache.Spatial_Valid)
       and then Positions_Current (D) and then Is_Ready (D) and then not D.Cache.Passive_Valid and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all)
         and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all);
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
   pragma Postcondition (Static => (if Result = Success then Passive_Current (D)));

   procedure Complete_Passive (D : in out Simulation; Result : out Status; Velocity : Motion_Array; Reuse : Boolean)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
   begin
      Expose_Passive_Inputs (D);
      Passive_Bounded_Buffers (D.Joint_Config.all, D.State.Qpos.all, D.State.Qvel.all,
                       D.Spring_Enabled, D.Damper_Enabled, D.Dynamics.Passive.all, Result);
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Configuration_Bounded (D));
      pragma Assert (Static => Configuration_Valid (D.Body_Config.all, D.Joint_Config.all, D.Actuator_Config.all, D.Nb, D.Nj, D.Na));

      if Result = Success and then D.Fluid_Elements /= null then
         MJ.Data.Fluid_Phase.Accumulate (D, Result, (if Reuse then Velocity else MJ.Fluid_Kernels.No_Motions));
      end if;
      if Result = Success then D.Cache.Passive_Valid := True; end if;
      pragma Assert (Static => Inputs_Bounded (D));
      pragma Assert (Static => Caches_Bounded (D));
      Establish_Readiness (D);
   end Complete_Passive;
   pragma Inline_Always (Complete_Passive);

   procedure Fill_Dense (D : in out Simulation; Result : out Status)
     with Global => null,
     Pre => Is_Ready (D) and then D.Cache.Jacobian_Valid and then not D.Cache.Passive_Valid,
     Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
       and then not D.Cache.Passive_Valid and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all) and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Capture_Configuration (D) with Ghost => Static;
   begin
      Prove_Jacobian_Readiness (D);
      Dense_Force_Buffers
        (D.Body_Config.all, D.Kinematic.Bodies.all, D.Kinematic.Linear_Jacobian.all,
         D.Kinematic.Angular_Jacobian.all, D.Gravity, D.Gravity_Enabled,
         D.Dynamics.Gravity.all, D.Dynamics.Bias.all, Result);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Fill_Dense;
   pragma Inline_Always (Fill_Dense);

   procedure Ready_Properties (D : Simulation)
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => Shape (D).Bodies = D.Nb and then Stable_Ready (D) and then Phase_Ready (D) and then D.Allocated and then not Is_Empty (D)
       and then Positions_Current (D) = D.Cache.Pose_Valid
       and then Passive_Current (D) = D.Cache.Passive_Valid
       and then D.Dynamics.Gravity /= null and then D.Dynamics.Bias /= null
   is
   begin
      null;
   end Ready_Properties;

   procedure Publish_Gravity_Bias (D : in out Simulation; Gravity, Bias : Real_Array)
     with Global => null,
     Pre => Is_Ready (D) and then not D.Cache.Passive_Valid
       and then Gravity'First = 0 and then Gravity'Last = D.Nv - 1
       and then Bias'First = 0 and then Bias'Last = D.Nv - 1
       and then MJ.Smooth_Dynamics.Work_Array (Gravity) and then MJ.Smooth_Dynamics.Work_Array (Bias),
     Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old and then not D.Cache.Passive_Valid
       and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all) and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all) and then D.Dynamics.Gravity.all = Gravity and then D.Dynamics.Bias.all = Bias and then D.Cache.Spatial_Valid = D.Cache.Spatial_Valid'Old)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      Initial_Config : constant Configuration_Snapshot := Capture_Configuration (D) with Ghost => Static;
   begin
      D.Dynamics.Gravity.all := Gravity;
      D.Dynamics.Bias.all := Bias;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Publish_Gravity_Bias;
   pragma Inline_Always (Publish_Gravity_Bias);

   procedure Recursive_Path (D : in out Simulation; Used : out Boolean; Velocity : in out Motion_Array)
     with Global => null,
     Pre => Is_Ready (D) and then Velocity'First = 0 and then Velocity'Length in 1 .. Max_Bodies
       and then Velocity'Length = D.Nb and then Positions_Current (D) and then not D.Cache.Passive_Valid;
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
   pragma Postcondition (Static => not D.Cache.Passive_Valid);
   pragma Postcondition (Static => (if Used then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all) and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all)));

   pragma Postcondition (if Used then D.Cache.Spatial_Valid
     and then MJ.Fluid_Kernels.Motions_Bounded (Velocity));

   procedure Recursive_Path (D : in out Simulation; Used : out Boolean; Velocity : in out Motion_Array)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Passive_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Inputs_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Caches_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Prepared : Boolean;
   begin
      Ready_Properties (D);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      pragma Assert (Static => Position_Values (D) = Initial_Pos);
      pragma Assert (Static => Velocity_Values (D) = Initial_Vel);
      Used := False;
      if D.Nv < 3 then return; end if;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Spatial.Prepare (D, Prepared);
         Ready_Properties (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      if not Prepared then return; end if;
      declare
         Nv : constant Natural := D.Nv;
         Gravity, Bias : Real_Array (0 .. Nv - 1);
      begin
         Try_Recursive (D, Gravity, Bias, Used, Velocity);
         if Used then
            declare
               Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
               Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
               Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
               Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
               Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
            begin
               Publish_Gravity_Bias (D, Gravity, Bias);
         Ready_Properties (D);
               MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
               MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
               MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
               MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
               Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
            end;
         end if;
      end;
      pragma Assert (Static => Is_Ready (D));
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => not D.Cache.Passive_Valid);
      pragma Assert (Static => Configuration (D) = Initial_Config);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Position_Values (D) = Initial_Pos);
      pragma Assert (Static => Velocity_Values (D) = Initial_Vel);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      pragma Assert (Static => (if Used then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all) and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all)));
   end Recursive_Path;
   pragma Inline_Always (Recursive_Path);

   procedure Dense_Path (D : in out Simulation; Result : out Status)
     with Global => null,
     Pre => Is_Ready (D) and then Positions_Current (D) and then not D.Cache.Passive_Valid,
     Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old
       and then not D.Cache.Passive_Valid and then (if Result = Success then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Gravity.all) and then MJ.Smooth_Dynamics.Work_Array (D.Dynamics.Bias.all)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Passive_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Inputs_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Caches_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Ready_Properties (D);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Pipeline.Ensure_Cartesian_Motion (D, Result);
         Ready_Properties (D);
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
         Pipeline.Ensure_Jacobians (D, Result);
         Ready_Properties (D);
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
         Fill_Dense (D, Result);
         Ready_Properties (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
   end Dense_Path;
   pragma Inline_Always (Dense_Path);

   procedure Compute_Ready (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Positions_Current (D),
     Post => (Static => Is_Ready (D) and then Stable_Ready (D)
         and then Is_Empty (D) = Is_Empty (D)'Old and then Shape (D) = Shape (D)'Old
         and then State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Positions_Current (D) = Positions_Current (D)'Old
         and then Configuration (D) = Configuration (D)'Old
         and then Position_Values (D) = Position_Values (D)'Old
         and then Velocity_Values (D) = Velocity_Values (D)'Old
         and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old and then (if Result = Success then Passive_Current (D)))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Inputs_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Caches_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Capture_Configuration (D) with Ghost => Static;
      Used : Boolean;
      Velocity : Motion_Array (0 .. D.Nb-1) := [others => [others => 0.0]];
   begin
      Ready_Properties (D);
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Zero_Forces (D);
         Ready_Properties (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Recursive_Path (D, Used, Velocity);
         Ready_Properties (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
      if not Used then
      declare
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Pos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Vel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      begin
         Dense_Path (D, Result);
         Ready_Properties (D);
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
         Complete_Passive (D, Result, Velocity, Used);
         Ready_Properties (D);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Pos, Initial_Pos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Vel, Initial_Vel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
      end;
   end Compute_Ready;
   pragma Inline_Always (Compute_Ready);

   procedure Compute (D : in out Simulation; Result : out Status) is
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
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Passive_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
   begin
      Ready_Properties (D);
      pragma Assert (Static => Phase_Ready (D));
      if not D.Cache.Pose_Valid then Result := Stale_Results; return; end if;
      Compute_Ready (D, Result);
   end Compute;
end MJ.Data.Forces_Phase;

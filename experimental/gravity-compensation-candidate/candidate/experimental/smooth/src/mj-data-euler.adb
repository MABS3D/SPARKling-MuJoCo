with MJ.Data.Pipeline;
with MJ.Data.Boundary;
with MJ.Data.Inertia_Phase;

package body MJ.Data.Euler with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Input_Query_Image (D : Simulation)
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => Input_Values (D) = Input_Image (D.State.Ctrl.all, D.State.Applied.all)
   is
   begin
      null;
   end Input_Query_Image;

   procedure State_Query_Image (D : Simulation)
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => State_Values (D) = State_Image (D.State.Qpos.all, D.State.Qvel.all, D.Clock)
   is
   begin
      null;
   end State_Query_Image;

   procedure Equal_State_Images
     (Q1, Q2, V1, V2 : Real_Array; T1, T2 : Nonneg_Tier0)
     with Ghost => Static, Global => null,
     Pre => Q1'First = 0 and then Q2'First = 0 and then V1'First = 0 and then V2'First = 0
       and then Int64 (Q1'Length) <= Max_Dofs and then Int64 (Q2'Length) <= Max_Dofs
       and then Int64 (V1'Length) <= Max_Dofs and then Int64 (V2'Length) <= Max_Dofs
       and then Q1 = Q2 and then V1 = V2 and then T1 = T2,
     Post => State_Image (Q1, V1, T1) = State_Image (Q2, V2, T2)
   is
   begin
      null;
   end Equal_State_Images;

   procedure Integrate_Buffers
     (Q, V : in out Real_Array; Rate : Real_Array; H : Nonneg_Tier0;
      Clock : in out Nonneg_Tier0; Next_Q, Next_V : in out Real_Array; Result : out Status)
     with Global => null,
     Pre => MJ.Smooth_Kernels.Same_Bounds (Q, V)
       and then MJ.Smooth_Kernels.Same_Bounds (Q, Rate)
       and then MJ.Smooth_Kernels.Same_Bounds (Q, Next_Q)
       and then MJ.Smooth_Kernels.Same_Bounds (Q, Next_V)
       and then MJ.Smooth_Kernels.All_Tier0 (Q) and then MJ.Smooth_Kernels.All_Tier0 (V),
     Post => MJ.Smooth_Kernels.All_Tier0 (Q) and then MJ.Smooth_Kernels.All_Tier0 (V)
       and then (if Result = Success then Clock = Clock'Old + H
         else Q = Q'Old and then V = V'Old and then Clock = Clock'Old);
   pragma Postcondition (Static => (if Result = Success then
     MJ.Smooth_Kernels.Euler_Update (Q'Old, V'Old, Rate, Q, V, H)));

   procedure Integrate_Buffers
     (Q, V : in out Real_Array; Rate : Real_Array; H : Nonneg_Tier0;
      Clock : in out Nonneg_Tier0; Next_Q, Next_V : in out Real_Array; Result : out Status)
   is
      Next_Time : constant Real := Clock + H;
      Ok : Boolean;
   begin
      Result := Numeric_Limit;
      if Next_Time not in Nonneg_Tier0 then return; end if;
      MJ.Smooth_Kernels.Stage_Euler (Q, V, Rate, H, Next_Q, Next_V, Ok);
      if not Ok then return; end if;
      Q := Next_Q;
      V := Next_V;
      Clock := Next_Time;
      Result := Success;
   end Integrate_Buffers;
   pragma Inline_Always (Integrate_Buffers);

   procedure Integrate (D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.Euler_Update);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Array_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Control : constant Real_Array := D.State.Ctrl.all with Ghost => Static;
      Initial_Applied : constant Real_Array := D.State.Applied.all with Ghost => Static;
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_Qpos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Qvel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Time : constant Nonneg_Tier0 := Time (D) with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Shape : constant Dimensions := Shape (D) with Ghost => Static;
      Initial_Step : constant Nonneg_Tier0 := Step_Size (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      State_Query_Image (D);
      pragma Assert (Static => Initial_State = State_Image (Initial_Qpos, Initial_Qvel, Initial_Time));
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      pragma Assert (Static => Initial_Inputs = Input_Image (Initial_Control, Initial_Applied));
      Integrate_Buffers
        (D.State.Qpos.all, D.State.Qvel.all, D.Scratch.Solution.all, D.Timestep,
         D.Clock, D.Scratch.Next_Qpos.all, D.Scratch.Next_Qvel.all, Result);
      pragma Assert (Static => (if Result = Success then D.Clock = Initial_Time + Initial_Step));
      if Result = Success then Invalidate (D.Cache); end if;
      pragma Assert (Static => Array_Bounded (D.State.Qpos, Max_Val));
      pragma Assert (Static => Array_Bounded (D.State.Qvel, Max_Val));
      pragma Assert (Static => Array_Bounded (D.State.Ctrl, Max_Val));
      pragma Assert (Static => Array_Bounded (D.State.Applied, Max_Val));
      pragma Assert (Static => Inputs_Bounded (D));
      pragma Assert (Static => Storage_Ready (D));
      pragma Assert (Static => Stable_Ready (D));
      pragma Assert (Static => Is_Ready (D));
      pragma Assert (Static => (if Result = Success then
        MJ.Smooth_Kernels.Euler_Update
          (Initial_Qpos, Initial_Qvel, Step_Rates (D), Position_Values (D),
           Velocity_Values (D), Initial_Step)));
      if Result /= Success then
         State_Query_Image (D);
         Equal_State_Images
           (D.State.Qpos.all, Initial_Qpos, D.State.Qvel.all, Initial_Qvel,
            D.Clock, Initial_Time);
         MJ.Smooth_Kernels.Equal_Transitive
           (State_Values (D), State_Image (D.State.Qpos.all, D.State.Qvel.all, D.Clock),
            State_Image (Initial_Qpos, Initial_Qvel, Initial_Time));
         MJ.Smooth_Kernels.Equal_Transitive
           (State_Values (D), State_Image (Initial_Qpos, Initial_Qvel, Initial_Time), Initial_State);
         pragma Assert (Static => State_Values (D) = Initial_State);
      end if;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Equal_Input_Images (D.State.Ctrl.all, Initial_Control, D.State.Applied.all, Initial_Applied);
      Input_Query_Image (D);
      MJ.Smooth_Kernels.Equal_Transitive
        (Input_Values (D), Input_Image (D.State.Ctrl.all, D.State.Applied.all),
         Input_Image (Initial_Control, Initial_Applied));
      MJ.Smooth_Kernels.Equal_Transitive
        (Input_Values (D), Input_Image (Initial_Control, Initial_Applied), Initial_Inputs);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      pragma Assert_And_Cut (Static => Is_Ready (D) and then not Is_Empty (D)
        and then Shape (D) = Initial_Shape and then Configuration (D) = Initial_Config
        and then Input_Values (D) = Initial_Inputs
        and then (if Result /= Success then State_Values (D) = Initial_State)
        and then (if Result = Success then Time (D) = Initial_Time + Initial_Step
          and then not Positions_Current (D) and then not Forces_Current (D)
          and then MJ.Smooth_Kernels.Euler_Update
            (Initial_Qpos, Initial_Qvel, Step_Rates (D), Position_Values (D),
             Velocity_Values (D), Initial_Step)));
   end Integrate;
   procedure Equal_Euler_Values (A, B, Rate : Tier0_Real; H1, H2 : Nonneg_Tier0)
     with Ghost => Static, Global => null, Pre => A = B and then H1 = H2,
     Post => A + H1 * Rate = B + H2 * Rate
   is
   begin
      null;
   end Equal_Euler_Values;

   procedure Equal_Euler_Inputs
     (Q1, Q2, V1, V2, Rate, Next_Q, Next_V : Real_Array; H1, H2 : Nonneg_Tier0)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Kernels.Same_Bounds (Q1, Q2)
       and then MJ.Smooth_Kernels.Same_Bounds (V1, V2)
       and then Q1 = Q2 and then V1 = V2 and then H1 = H2
       and then MJ.Smooth_Kernels.Euler_Update (Q1, V1, Rate, Next_Q, Next_V, H1),
     Post => MJ.Smooth_Kernels.Euler_Update (Q2, V2, Rate, Next_Q, Next_V, H2)
   is
   begin
      pragma Assert (MJ.Smooth_Kernels.All_Tier0 (Q2));
      pragma Assert (MJ.Smooth_Kernels.All_Tier0 (V2));
      for I in Q1'Range loop
         pragma Loop_Invariant (for all J in Q1'First .. I - 1 =>
           Next_V (J) = MJ.Smooth_Kernels.Euler_Value (V2 (J), Rate (J), H2)
           and then Next_Q (J) = MJ.Smooth_Kernels.Euler_Value (Q2 (J), Next_V (J), H2));
         Equal_Euler_Values (V1 (I), V2 (I), Rate (I), H1, H2);
         Equal_Euler_Values (Q1 (I), Q2 (I), Next_V (I), H1, H2);
      end loop;
   end Equal_Euler_Inputs;

   procedure State_Query_Layout (D : Simulation)
     with Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => Position_Values (D)'First = 0 and then Velocity_Values (D)'First = 0
       and then Position_Values (D)'Last = Integer (Shape (D).Positions) - 1
       and then Velocity_Values (D)'Last = Integer (Shape (D).Velocities) - 1
       and then MJ.Smooth_Kernels.All_Tier0 (Position_Values (D))
       and then MJ.Smooth_Kernels.All_Tier0 (Velocity_Values (D))
   is
   begin
      null;
   end State_Query_Layout;

   procedure Step_Ready
     (D : in out Simulation; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) with Global => null, Pre => Is_Ready (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old;
   pragma Postcondition (Is_Ready (D) = Is_Ready (D)'Old);
   pragma Postcondition (Shape (D) = Shape (D)'Old);
   pragma Postcondition (Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (if Result = Success then Is_Ready (D));
   pragma Postcondition (if Result = Success then Time (D) = Time (D)'Old + Step_Size (D)'Old);
   pragma Postcondition (if Result = Success then not Positions_Current (D) and then not Forces_Current (D));
   pragma Postcondition (if Result /= Success then State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);

   pragma Postcondition (Static => (if Result = Success then
     MJ.Smooth_Kernels.Euler_Update (Position_Values (D)'Old, Velocity_Values (D)'Old,
       Step_Rates (D), Position_Values (D), Velocity_Values (D), Step_Size (D)'Old)));

   procedure Step_Ready
     (D : in out Simulation; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Rates);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Stable_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Storage_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Inputs_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Caches_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Array_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Kernels.Euler_Update);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Shape);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Time);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Step_Size);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Positions_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Forces_Current);
      Initial_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
      Initial_State : constant Real_Array := State_Values (D) with Ghost => Static;
      Initial_Qpos : constant Real_Array := Position_Values (D) with Ghost => Static;
      Initial_Qvel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      Initial_Step : constant Nonneg_Tier0 := Step_Size (D) with Ghost => Static;
      Initial_Empty : constant Boolean := Is_Empty (D) with Ghost => Static;
      Initial_Shape : constant Dimensions := Shape (D) with Ghost => Static;
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
      Next_Time : Real;
   begin
      State_Query_Layout (D);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      Next_Time := Time (D) + Step_Size (D);
      if Next_Time not in Nonneg_Tier0 then
         Result := Numeric_Limit;
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Result /= Success and then Is_Ready (D)
           and then Is_Empty (D) = Initial_Empty and then Shape (D) = Initial_Shape
           and then State_Values (D) = Initial_State
           and then Input_Values (D) = Initial_Inputs
           and then Configuration (D) = Initial_Config);
         return;
      end if;
      Pipeline.Evaluate_Ready (D, Result, External);
      pragma Assert (Static => State_Values (D) = Initial_State);
      pragma Assert (Static => Input_Values (D) = Initial_Inputs);
      if Result /= Success then
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Result /= Success and then Is_Ready (D)
           and then Is_Empty (D) = Initial_Empty and then Shape (D) = Initial_Shape
           and then State_Values (D) = Initial_State
           and then Input_Values (D) = Initial_Inputs
           and then Configuration (D) = Initial_Config);
         return;
      end if;
      declare
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Qpos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Qvel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
      begin
         Inertia_Phase.Solve_Euler (D, Result);
         MJ.Smooth_Kernels.Equal_Transitive (Position_Values (D), Before_Qpos, Initial_Qpos);
         MJ.Smooth_Kernels.Equal_Transitive (Velocity_Values (D), Before_Qvel, Initial_Qvel);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
      end;
      if Result /= Success then
         pragma Assert (Static => State_Values (D) = Initial_State);
         pragma Assert (Static => Result /= Success and then Is_Ready (D)
           and then Is_Empty (D) = Initial_Empty and then Shape (D) = Initial_Shape
           and then State_Values (D) = Initial_State
           and then Input_Values (D) = Initial_Inputs
           and then Configuration (D) = Initial_Config);
         return;
      end if;
      declare
         Before_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
         Before_State : constant Real_Array := State_Values (D) with Ghost => Static;
         Before_Inputs : constant Real_Array := Input_Values (D) with Ghost => Static;
         Before_Qpos : constant Real_Array := Position_Values (D) with Ghost => Static;
         Before_Qvel : constant Real_Array := Velocity_Values (D) with Ghost => Static;
         Before_Step : constant Nonneg_Tier0 := Step_Size (D) with Ghost => Static;
      begin
         State_Query_Layout (D);
         pragma Assert (Static => Before_Qpos = Initial_Qpos and then Before_Qvel = Initial_Qvel);
         pragma Assert (Static => MJ.Smooth_Kernels.Same_Bounds (Before_Qpos, Initial_Qpos)
           and then MJ.Smooth_Kernels.Same_Bounds (Before_Qvel, Initial_Qvel));
         Integrate (D, Result);
         Equal_Configurations (Configuration (D), Before_Config, Initial_Config);
         MJ.Smooth_Kernels.Equal_Transitive (Input_Values (D), Before_Inputs, Initial_Inputs);
         if Result /= Success then
            MJ.Smooth_Kernels.Equal_Transitive (State_Values (D), Before_State, Initial_State);
            pragma Assert (Static => State_Values (D) = Initial_State);
            pragma Assert (Static => Result /= Success and then Is_Ready (D)
              and then Is_Empty (D) = Initial_Empty and then Shape (D) = Initial_Shape
              and then State_Values (D) = Initial_State
              and then Input_Values (D) = Initial_Inputs
              and then Configuration (D) = Initial_Config);
            return;
         end if;
         Equal_Euler_Inputs
           (Before_Qpos, Initial_Qpos, Before_Qvel, Initial_Qvel,
            Step_Rates (D), Position_Values (D), Velocity_Values (D), Before_Step, Initial_Step);
      end;
   end Step_Ready;
   procedure Step
     (D : in out Simulation; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Empty);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Values);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Values);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
      if not Boundary.Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      if External'Length /= 0 and then
        (External'First /= 0 or else Int64 (External'Length) /= Int64 (Body_Count (D)))
      then
         Result := Invalid_Size;
         return;
      end if;
      Step_Ready (D, Result, External);
   end Step;
end MJ.Data.Euler;

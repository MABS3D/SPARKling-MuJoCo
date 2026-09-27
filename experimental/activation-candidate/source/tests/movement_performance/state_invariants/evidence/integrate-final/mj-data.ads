--  Owned scalar-joint simulation state with executable lifecycle contracts.
with MJ.Types;       use MJ.Types;
with MJ.Models;
with MJ.Smooth_Math;
with MJ.Smooth_Kernels;
with MJ.Smooth_Actuation;

package MJ.Data with SPARK_Mode is
   use type MJ.Smooth_Math.Vector;
   use type MJ.Smooth_Math.Quaternion;
   --  These total value queries are safe to snapshot unconditionally on entry.
   pragma Unevaluated_Use_Of_Old (Allow);
   Max_Dofs   : constant := 256;
   Max_Bodies : constant := 4_096;
   Max_Actuators : constant := 1_024;

   type Status is
     (Success, Already_Allocated, Not_Allocated, Invalid_Model,
      Capacity_Exceeded, Unsupported_Joint, Unsupported_Feature,
      Unsupported_Actuator, Invalid_Index, Invalid_Size,
      Numeric_Limit, Singular_Inertia, Stale_Results, Ill_Conditioned_Inertia);
   --  Singular_Inertia also covers a computed nonpositive LDL pivot.
   --  Ill_Conditioned_Inertia means the relative numerical policy rejected
   --  a positive pivot or estimated condition number, not exact singularity.

   type State_Vector is array (Natural range <>) of Tier0_Real;
   function As_Reals (Values : State_Vector) return Real_Array is
     ([for I in Values'Range => Real (Values (I))]) with Global => null;
   type Simulation is limited private;

   --  A value snapshot, with no access values: exact configuration frames.
   type Configuration_Snapshot (<>) is private with Ghost => Static;
   function Configuration (D : Simulation) return Configuration_Snapshot with
     Ghost => Static, Global => null;

   function Is_Empty (D : Simulation) return Boolean with Global => null;
   function Is_Ready (D : Simulation) return Boolean with Global => null;
   --  Public lifecycle boundary: default/freed, or successfully created.
   --  Free remains available for cleanup after an allocation exception.
   function Valid_State (D : Simulation) return Boolean is
     (Is_Empty (D) or else Is_Ready (D)) with Global => null;
   function Position_Count (D : Simulation) return Natural with Global => null;
   function Velocity_Count (D : Simulation) return Natural with Global => null;
   function Control_Count (D : Simulation) return Natural with Global => null;
   function Position (D : Simulation; Index : Natural) return Real with Global => null,
     Pre => Is_Ready (D) and then Index < Position_Count (D);
   function Velocity (D : Simulation; Index : Natural) return Real with Global => null,
     Pre => Is_Ready (D) and then Index < Velocity_Count (D);
   function Body_Count (D : Simulation) return Natural with Global => null;
   function Time (D : Simulation) return Real with Global => null,
     Post => Time'Result in Nonneg_Tier0;
   function Positions_Current (D : Simulation) return Boolean with Global => null;
   function Forces_Current (D : Simulation) return Boolean with Global => null;
   function Mass_Current (D : Simulation) return Boolean with Global => null;
   function Symmetric_Mass (D : Simulation) return Boolean with Global => null;
   function Passive_Current (D : Simulation) return Boolean with Global => null;
   function Actuation_Current (D : Simulation) return Boolean with Global => null;
   function Step_Size (D : Simulation) return Real with Global => null,
     Post => Step_Size'Result in Nonneg_Tier0;

   --  Value snapshots for contracts and regression checks. Empty when D is
   --  unallocated; these copy values, never expose owned access objects.
   --  State = [qpos, qvel, time]; inputs = [control, applied force].
   function State_Values (D : Simulation) return Real_Array with Global => null,
     Post => (if Valid_State (D) then MJ.Smooth_Kernels.All_Tier0 (State_Values'Result));
   function Input_Values (D : Simulation) return Real_Array with Global => null,
     Post => (if Valid_State (D) then MJ.Smooth_Kernels.All_Tier0 (Input_Values'Result));
   function Position_Values (D : Simulation) return Real_Array with Ghost => Static, Global => null;
   function Velocity_Values (D : Simulation) return Real_Array with Ghost => Static, Global => null;
   function Step_Rates (D : Simulation) return Real_Array with Ghost => Static, Global => null;
   function Reset_Values (D : Simulation) return Real_Array with Global => null;
   --  Exact reset semantics, expressed componentwise to avoid concatenation
   --  in a lifecycle postcondition: qpos0, zero qvel/time/control/applied force.
   function At_Reset_State (D : Simulation) return Boolean with Global => null;
   function Replaced (A : Real_Array; Index : Natural; Value : Real) return Real_Array is
     ([for I in A'Range => (if I = Index then Value else A (I))])
     with Global => null;
   type Dimensions is record
      Positions, Velocities, Controls, Bodies : Natural;
   end record;
   function Shape (D : Simulation) return Dimensions with Global => null;

   --  Copies the supported model subset. Subsequent model edits do not affect D.
   --  A failed Create on an empty D leaves it empty. An allocated D is left
   --  unchanged and returns Already_Allocated. Storage_Error is out of scope.
   procedure Create (M : MJ.Models.Model; D : in out Simulation; Result : out Status)
     with Global => null, Pre => Valid_State (D),
     Post => (if Is_Empty (D)'Old then
                (if Result = Success then Is_Ready (D) and then Time (D) = 0.0
                   and then At_Reset_State (D) and then not Positions_Current (D) and then not Forces_Current (D)
                   and then Shape (D) = Dimensions'(M.S.Nq, M.S.Nv, M.S.Nu, M.S.Nbody)
                 else Is_Empty (D))
              else Result = Already_Allocated
                and then Is_Ready (D) = Is_Ready (D)'Old
                and then State_Values (D) = State_Values (D)'Old
                and then Input_Values (D) = Input_Values (D)'Old);
   procedure Free (D : in out Simulation) with Global => null,
     Post => Is_Empty (D);
   procedure Reset (D : in out Simulation; Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then (if Is_Ready (D)'Old then Result = Success and then Time (D) = 0.0
         and then not Positions_Current (D) and then not Forces_Current (D)
         and then At_Reset_State (D)
         else Result = Not_Allocated);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);

   --  Typed finite boundary, not an FFI byte decoder. Invalid sizes are atomic.
   procedure Set_State
     (D : in out Simulation; Qpos, Qvel : State_Vector; New_Time : Nonneg_Tier0;
      Result : out Status) with Global => null, Pre => Valid_State (D),
     Contract_Cases =>
       (not Is_Ready (D) => Result = Not_Allocated,
        Is_Ready (D) and then (Int64 (Qpos'Length) /= Int64 (Position_Count (D))
          or else Int64 (Qvel'Length) /= Int64 (Velocity_Count (D))) => Result = Invalid_Size,
        others => Result = Success),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then Input_Values (D) = Input_Values (D)'Old
       and then (if Result = Success then Is_Ready (D) and then Time (D) = New_Time
         and then Int64 (Qpos'Length) = Int64 (Position_Count (D))
         and then Int64 (Qvel'Length) = Int64 (Velocity_Count (D))
         and then (for all I in Qpos'Range => Position (D, I - Qpos'First) = Qpos (I))
         and then (for all I in Qvel'Range => Velocity (D, I - Qvel'First) = Qvel (I))
         and then not Positions_Current (D) and then not Forces_Current (D)
         else State_Values (D) = State_Values (D)'Old
           and then Positions_Current (D) = Positions_Current (D)'Old
           and then Forces_Current (D) = Forces_Current (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);
   procedure Set_Control
     (D : in out Simulation; Index : Natural; Value : Tier0_Real; Result : out Status)
     with Global => null, Pre => Valid_State (D),
     Contract_Cases =>
       (not Is_Ready (D) => Result = Not_Allocated,
        Is_Ready (D) and then Index >= Control_Count (D) => Result = Invalid_Index,
        others => Result = Success),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then (if Result = Success then not Actuation_Current (D) and then not Forces_Current (D)
         and then Input_Values (D) = Replaced (Input_Values (D)'Old, Index, Value)
         else Input_Values (D) = Input_Values (D)'Old
           and then Actuation_Current (D) = Actuation_Current (D)'Old
           and then Forces_Current (D) = Forces_Current (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);
   procedure Set_Applied_Force
     (D : in out Simulation; Index : Natural; Value : Tier0_Real; Result : out Status)
     with Global => null, Pre => Valid_State (D),
     Contract_Cases =>
       (not Is_Ready (D) => Result = Not_Allocated,
        Is_Ready (D) and then Index >= Velocity_Count (D) => Result = Invalid_Index,
        others => Result = Success),
     Post => Is_Empty (D) = Is_Empty (D)'Old and then Is_Ready (D) = Is_Ready (D)'Old and then Shape (D) = Shape (D)'Old
       and then State_Values (D) = State_Values (D)'Old
       and then (if Result = Success then not Forces_Current (D)
         and then Input_Values (D) = Replaced (Input_Values (D)'Old, Control_Count (D) + Index, Value)
         else Input_Values (D) = Input_Values (D)'Old
           and then Forces_Current (D) = Forces_Current (D)'Old);
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old);

   procedure Get_State
     (D : Simulation; Qpos, Qvel : out Real_Array; Current_Time : out Real;
      Result : out Status) with Global => null, Pre => Valid_State (D),
     Contract_Cases =>
       (not Is_Ready (D) => Result = Not_Allocated,
        Is_Ready (D) and then (Int64 (Qpos'Length) /= Int64 (Position_Count (D))
          or else Int64 (Qvel'Length) /= Int64 (Velocity_Count (D))) => Result = Invalid_Size,
        others => Result = Success),
     Post => Current_Time = Time (D)
       and then (if Result = Success then Is_Ready (D)
         and then Int64 (Qpos'Length) = Int64 (Position_Count (D))
         and then Int64 (Qvel'Length) = Int64 (Velocity_Count (D))
         and then (for all I in Qpos'Range => Qpos (I) = Position (D, I - Qpos'First))
         and then (for all I in Qvel'Range => Qvel (I) = Velocity (D, I - Qvel'First))
         else (for all X of Qpos => X = 0.0) and then (for all X of Qvel => X = 0.0));
   function Acceleration (D : Simulation; Index : Natural) return Real with
     Global => null, Pre => Is_Ready (D) and then Forces_Current (D) and then Index < Velocity_Count (D),
     Post => Acceleration'Result in Tier0_Real;
   function Mass_Entry (D : Simulation; Row, Column : Natural) return Real with
     Global => null, Pre => Is_Ready (D) and then Mass_Current (D)
       and then Row < Velocity_Count (D) and then Column < Velocity_Count (D);
   type Force_Kind is (Gravity_Force, Velocity_Bias, Passive_Force, Actuator_Force);
   function Force_Value (D : Simulation; Kind : Force_Kind; Index : Natural) return Real with
     Global => null, Pre => Is_Ready (D)
       and then (if Kind = Actuator_Force then Actuation_Current (D) else Passive_Current (D))
       and then Index < Velocity_Count (D);
   type Actuator_Quantity is (Transmission_Length, Transmission_Velocity, Output_Force);
   function Actuator_Value (D : Simulation; Kind : Actuator_Quantity; Index : Natural) return Real with
     Global => null, Pre => Is_Ready (D) and then Actuation_Current (D) and then Index < Control_Count (D);
   function Body_Position (D : Simulation; Index : Natural) return MJ.Smooth_Math.Vector with
     Global => null, Pre => Is_Ready (D) and then Positions_Current (D) and then Index < Body_Count (D),
     Post => MJ.Smooth_Math.Bounded (Body_Position'Result);
   function Body_Orientation (D : Simulation; Index : Natural) return MJ.Smooth_Math.Quaternion with
     Global => null, Pre => Is_Ready (D) and then Positions_Current (D) and then Index < Body_Count (D),
     Post => MJ.Smooth_Math.Unit_Quaternion (Body_Orientation'Result);

   procedure Get_Acceleration
     (D : Simulation; Qacc : out Real_Array; Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => (if Result = Success then Is_Ready (D) and then Forces_Current (D)
       and then Qacc'Length = Velocity_Count (D) and then (for all X of Qacc => X in Tier0_Real)
       and then (for all I in Qacc'Range => Qacc (I) = Acceleration (D, I - Qacc'First))
       else (for all X of Qacc => X = 0.0));
   procedure Get_Mass_Matrix
     (D : Simulation; Dense : out Real_Array; Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => (if Result = Success then Is_Ready (D) and then Mass_Current (D)
       and then Int64 (Dense'Length) = Int64 (Velocity_Count (D)) ** 2
       and then (for all I in 0 .. Velocity_Count (D) - 1 =>
         (for all J in 0 .. Velocity_Count (D) - 1 =>
           Dense (Dense'First + (I * Velocity_Count (D) + J)) = Mass_Entry (D, I, J)))
       else (for all X of Dense => X = 0.0));
   procedure Get_Forces
     (D : Simulation; Gravity, Bias, Passive, Actuation : out Real_Array;
      Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => (if Result = Success then Is_Ready (D)
       and then Passive_Current (D) and then Actuation_Current (D)
       and then Gravity'Length = Velocity_Count (D) and then Bias'Length = Gravity'Length
       and then Passive'Length = Gravity'Length and then Actuation'Length = Gravity'Length
       and then (for all I in Gravity'Range => Gravity (I) = Force_Value (D, Gravity_Force, I - Gravity'First))
       and then (for all I in Bias'Range => Bias (I) = Force_Value (D, Velocity_Bias, I - Bias'First))
       and then (for all I in Passive'Range => Passive (I) = Force_Value (D, Passive_Force, I - Passive'First))
       and then (for all I in Actuation'Range => Actuation (I) = Force_Value (D, Actuator_Force, I - Actuation'First))
       else (for all X of Gravity => X = 0.0) and then (for all X of Bias => X = 0.0)
         and then (for all X of Passive => X = 0.0) and then (for all X of Actuation => X = 0.0));
   procedure Get_Actuator_Outputs
     (D : Simulation; Length, Velocity, Force : out Real_Array;
      Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => (if Result = Success then Is_Ready (D) and then Actuation_Current (D)
       and then Length'Length = Control_Count (D) and then Velocity'Length = Length'Length
       and then Force'Length = Length'Length
       and then (for all I in Length'Range => Length (I) = Actuator_Value (D, Transmission_Length, I - Length'First))
       and then (for all I in Velocity'Range => Velocity (I) = Actuator_Value (D, Transmission_Velocity, I - Velocity'First))
       and then (for all I in Force'Range => Force (I) = Actuator_Value (D, Output_Force, I - Force'First))
       else (for all X of Length => X = 0.0) and then (for all X of Velocity => X = 0.0)
         and then (for all X of Force => X = 0.0));
   procedure Get_Body_Pose
     (D : Simulation; Body_Id : Natural; Position : out MJ.Smooth_Math.Vector;
      Orientation : out MJ.Smooth_Math.Quaternion; Result : out Status)
     with Global => null, Pre => Valid_State (D),
     Post => (if Result = Success then Is_Ready (D) and then Positions_Current (D)
       and then Body_Id < Body_Count (D) and then MJ.Smooth_Math.Bounded (Position)
       and then MJ.Smooth_Math.Unit_Quaternion (Orientation)
       and then Position = Body_Position (D, Body_Id)
       and then Orientation = Body_Orientation (D, Body_Id)
       else Position = MJ.Smooth_Math.Zero and then Orientation = MJ.Smooth_Math.Identity_Quaternion);

private
   use MJ.Smooth_Math;
   type Scalar_Joint_Kind is (Slide_Joint, Hinge_Joint);
   type Body_Parameters is record
      Parent : Natural := 0;
      First_Joint : Integer := -1;
      Joint_Count : Natural := 0;
      Position, Inertial_Position : Vector := Zero;
      Orientation, Inertial_Orientation : Quaternion := Identity_Quaternion;
      Mass : Nonneg_Tier0 := 0.0;
      Inertia : Vector := Zero;
   end record;
   type Joint_Parameters is record
      Kind : Scalar_Joint_Kind := Hinge_Joint;
      Body_Id, Qadr, Vadr : Natural := 0;
      Anchor, Direction : Vector := Zero;  --  Direction is normalized by Create.
      Reference, Spring_Reference : Tier0_Real := 0.0;
      Stiffness, Damping, Armature : Nonneg_Tier0 := 0.0;
   end record;
   subtype Actuator_Parameters is MJ.Smooth_Actuation.Parameters;
   type Body_Parameter_Array is array (Natural range <>) of Body_Parameters;
   type Joint_Parameter_Array is array (Natural range <>) of Joint_Parameters;
   subtype Actuator_Parameter_Array is MJ.Smooth_Actuation.Parameter_Array;
   use type Actuator_Parameters;
   use type Actuator_Parameter_Array;
   type Configuration_Snapshot (Nb, Nj, Na : Natural) is record
      Nq, Nv, Nu, No : Natural;
      Timestep : Nonneg_Tier0;
      Gravity : Vector;
      Gravity_Enabled, Spring_Enabled, Damper_Enabled : Boolean;
      Actuation_Enabled, Clamp_Control, Implicit_Damping : Boolean;
      Bodies : Body_Parameter_Array (1 .. Nb);
      Joints : Joint_Parameter_Array (1 .. Nj);
      Actuators : Actuator_Parameter_Array (1 .. Na);
   end record;
   type Body_Parameter_Access is access Body_Parameter_Array;
   type Joint_Parameter_Access is access Joint_Parameter_Array;
   type Actuator_Parameter_Access is access Actuator_Parameter_Array;

   --  Each body carries motion at its own origin, in world coordinates.
   --  Bias accelerations are evaluated at qacc = 0, without gravity.
   type Body_State is record
      Position, Center : Vector := Zero;
      Orientation : Quaternion := Identity_Quaternion;
      Rotation, Inertial_Rotation : Matrix := Identity;
      Linear_Velocity, Angular_Velocity : Vector := Zero;
      Linear_Bias, Angular_Bias : Vector := Zero;
   end record;
   type Body_State_Array is array (Natural range <>) of Body_State;
   type Body_State_Access is access Body_State_Array;
   type Joint_State is record
      Anchor, Direction : Vector := Zero;
   end record;
   type Joint_State_Array is array (Natural range <>) of Joint_State;
   type Joint_State_Access is access Joint_State_Array;

   type State_Buffers is record
      Qpos, Qvel, Ctrl, Applied : Real_Array_Access := null;
   end record;
   type Kinematic_Buffers is record
      Bodies : Body_State_Access := null;
      Joints : Joint_State_Access := null;
      --  Flat offset: 3 * (body * nv + velocity_index) + component.
      Linear_Jacobian, Angular_Jacobian : Real_Array_Access := null;
   end record;
   type Force_Buffers is record
      Mass, Bias, Gravity, Passive, Actuator, Acceleration, Total : Real_Array_Access := null;
   end record;
   type Actuator_Buffers is record
      Length, Velocity, Force : Real_Array_Access := null;
   end record;
   type Scratch_Buffers is record
      Factor, Rhs, Solution, Next_Qpos, Next_Qvel : Real_Array_Access := null;
      Condition_Sums : Real_Array_Access := null;
   end record;
   type Cache_Flags is record
      Pose_Valid, Mass_Valid, Passive_Valid, Actuation_Valid, Force_Valid : Boolean := False;
   end record;
   type Simulation is limited record
      Allocated : Boolean := False;
      Nq, Nv, Nj : Natural range 0 .. Max_Dofs := 0;
      Nu, Na, No : Natural range 0 .. Max_Actuators := 0;
      Nb : Natural range 0 .. Max_Bodies := 0;
      Clock : Nonneg_Tier0 := 0.0;
      Timestep : Nonneg_Tier0 := 0.0;
      Gravity : Vector := Zero;
      Gravity_Enabled, Spring_Enabled, Damper_Enabled : Boolean := True;
      Actuation_Enabled, Clamp_Control, Implicit_Damping : Boolean := True;
      Cache : Cache_Flags;
      Body_Config : Body_Parameter_Access := null;
      Joint_Config : Joint_Parameter_Access := null;
      Actuator_Config : Actuator_Parameter_Access := null;
      State : State_Buffers;
      Kinematic : Kinematic_Buffers;
      Dynamics : Force_Buffers;
      Actuators : Actuator_Buffers;
      Scratch : Scratch_Buffers;
   end record;

   function Configuration (D : Simulation) return Configuration_Snapshot is
     (if D.Body_Config /= null and then D.Joint_Config /= null and then D.Actuator_Config /= null
        and then Int64 (D.Body_Config'Length) = Int64 (D.Nb) and then Int64 (D.Joint_Config'Length) = Int64 (D.Nj)
        and then Int64 (D.Actuator_Config'Length) = Int64 (D.Na) then
        (Nb => D.Nb, Nj => D.Nj, Na => D.Na, Nq => D.Nq, Nv => D.Nv, Nu => D.Nu, No => D.No,
         Timestep => D.Timestep, Gravity => D.Gravity, Gravity_Enabled => D.Gravity_Enabled,
         Spring_Enabled => D.Spring_Enabled, Damper_Enabled => D.Damper_Enabled,
         Actuation_Enabled => D.Actuation_Enabled, Clamp_Control => D.Clamp_Control,
         Implicit_Damping => D.Implicit_Damping,
         Bodies => D.Body_Config.all, Joints => D.Joint_Config.all, Actuators => D.Actuator_Config.all)
      else
        (Nb => 0, Nj => 0, Na => 0, Nq => D.Nq, Nv => D.Nv, Nu => D.Nu, No => D.No,
         Timestep => D.Timestep, Gravity => D.Gravity, Gravity_Enabled => D.Gravity_Enabled,
         Spring_Enabled => D.Spring_Enabled, Damper_Enabled => D.Damper_Enabled,
         Actuation_Enabled => D.Actuation_Enabled, Clamp_Control => D.Clamp_Control,
         Implicit_Damping => D.Implicit_Damping,
         Bodies => [others => <>], Joints => [others => <>], Actuators => [others => <>]));

   function Has_Real_Layout (P : Real_Array_Access; Length : Natural) return Boolean is
     (P /= null and then P'First = 0 and then P'Last = Length - 1
      and then Int64 (P'Length) = Int64 (Length))
     with Global => null;

   function Is_Empty (D : Simulation) return Boolean is
     (not D.Allocated and then D.Body_Config = null and then D.Joint_Config = null
      and then D.Actuator_Config = null and then D.State.Qpos = null
      and then D.State.Qvel = null and then D.State.Ctrl = null and then D.State.Applied = null
      and then D.Kinematic.Bodies = null and then D.Kinematic.Joints = null
      and then D.Kinematic.Linear_Jacobian = null and then D.Kinematic.Angular_Jacobian = null
      and then D.Dynamics.Mass = null and then D.Dynamics.Bias = null
      and then D.Dynamics.Gravity = null and then D.Dynamics.Passive = null
      and then D.Dynamics.Actuator = null and then D.Dynamics.Acceleration = null
      and then D.Dynamics.Total = null and then D.Actuators.Length = null
      and then D.Actuators.Velocity = null and then D.Actuators.Force = null
      and then D.Scratch.Factor = null and then D.Scratch.Rhs = null
      and then D.Scratch.Solution = null and then D.Scratch.Next_Qpos = null
      and then D.Scratch.Next_Qvel = null and then D.Scratch.Condition_Sums = null);

   function Position_Count (D : Simulation) return Natural is (D.Nq);

   function Velocity_Count (D : Simulation) return Natural is (D.Nv);

   function Control_Count (D : Simulation) return Natural is (D.Nu);
   function Position (D : Simulation; Index : Natural) return Real is (D.State.Qpos (Index));
   function Velocity (D : Simulation; Index : Natural) return Real is (D.State.Qvel (Index));

   function Body_Count (D : Simulation) return Natural is (D.Nb);

   function Time (D : Simulation) return Real is (D.Clock);

   function Positions_Current (D : Simulation) return Boolean is (D.Allocated and then D.Cache.Pose_Valid);

   function Forces_Current (D : Simulation) return Boolean is (D.Allocated and then D.Cache.Force_Valid);

   function Mass_Current (D : Simulation) return Boolean is (D.Allocated and then D.Cache.Mass_Valid);

   function Passive_Current (D : Simulation) return Boolean is (D.Allocated and then D.Cache.Passive_Valid);

   function Actuation_Current (D : Simulation) return Boolean is (D.Allocated and then D.Cache.Actuation_Valid);

   function Step_Size (D : Simulation) return Real is (D.Timestep);

   function Shape (D : Simulation) return Dimensions is ((D.Nq, D.Nv, D.Nu, D.Nb));

   function State_Image (Qpos, Qvel : Real_Array; Clock : Nonneg_Tier0) return Real_Array is
     (Qpos & Qvel & Clock) with Global => null,
     Pre => Qpos'First = 0 and then Qvel'First = 0
       and then Int64 (Qpos'Length) <= Max_Dofs and then Int64 (Qvel'Length) <= Max_Dofs,
     Post => (if MJ.Smooth_Kernels.All_Tier0 (Qpos) and then MJ.Smooth_Kernels.All_Tier0 (Qvel)
       then MJ.Smooth_Kernels.All_Tier0 (State_Image'Result));
   function Input_Image (Ctrl, Applied : Real_Array) return Real_Array is
     (Ctrl & Applied) with Global => null,
     Pre => Ctrl'First = 0 and then Applied'First = 0
       and then Int64 (Ctrl'Length) <= Max_Actuators and then Int64 (Applied'Length) <= Max_Dofs,
     Post => (if MJ.Smooth_Kernels.All_Tier0 (Ctrl) and then MJ.Smooth_Kernels.All_Tier0 (Applied)
       then MJ.Smooth_Kernels.All_Tier0 (Input_Image'Result));
   procedure Equal_Input_Images (C1, C2, F1, F2 : Real_Array) with Ghost => Static, Global => null,
     Pre => C1'First = 0 and then C2'First = 0 and then F1'First = 0 and then F2'First = 0
       and then Int64 (C1'Length) <= Max_Actuators and then Int64 (C2'Length) <= Max_Actuators
       and then Int64 (F1'Length) <= Max_Dofs and then Int64 (F2'Length) <= Max_Dofs
       and then C1 = C2 and then F1 = F2,
     Post => Input_Image (C1, F1) = Input_Image (C2, F2);
   procedure Prove_Configuration_Equality (A, B : Configuration_Snapshot) with Ghost => Static, Global => null,
     Pre => A.Nb = B.Nb and then A.Nj = B.Nj and then A.Na = B.Na
       and then A.Nq = B.Nq and then A.Nv = B.Nv and then A.Nu = B.Nu and then A.No = B.No
       and then A.Timestep = B.Timestep and then A.Gravity = B.Gravity
       and then A.Gravity_Enabled = B.Gravity_Enabled and then A.Spring_Enabled = B.Spring_Enabled
       and then A.Damper_Enabled = B.Damper_Enabled and then A.Actuation_Enabled = B.Actuation_Enabled
       and then A.Clamp_Control = B.Clamp_Control and then A.Implicit_Damping = B.Implicit_Damping
       and then A.Bodies = B.Bodies and then A.Joints = B.Joints and then A.Actuators = B.Actuators,
     Post => A = B;
   procedure Equal_Configurations (A, B, C : Configuration_Snapshot) with Ghost => Static, Global => null,
     Pre => A = B and then B = C, Post => A = C;

   function State_Values (D : Simulation) return Real_Array is
     (if D.Allocated and then Has_Real_Layout (D.State.Qpos, D.Nq)
        and then Has_Real_Layout (D.State.Qvel, D.Nv)
      then State_Image (D.State.Qpos.all, D.State.Qvel.all, D.Clock) else [1 .. 0 => 0.0]);
   function Input_Values (D : Simulation) return Real_Array is
     (if D.Allocated and then Has_Real_Layout (D.State.Ctrl, D.Nu)
        and then Has_Real_Layout (D.State.Applied, D.Nv)
      then Input_Image (D.State.Ctrl.all, D.State.Applied.all) else [1 .. 0 => 0.0]);

   function Position_Values (D : Simulation) return Real_Array is
     (if D.State.Qpos = null then Real_Array'[1 .. 0 => 0.0] else D.State.Qpos.all);
   function Velocity_Values (D : Simulation) return Real_Array is
     (if D.State.Qvel = null then Real_Array'[1 .. 0 => 0.0] else D.State.Qvel.all);
   function Step_Rates (D : Simulation) return Real_Array is
     (if D.Scratch.Solution = null then Real_Array'[1 .. 0 => 0.0] else D.Scratch.Solution.all);

   function Reset_Values (D : Simulation) return Real_Array is
     (if D.Allocated and then D.Joint_Config /= null
        and then D.Joint_Config'First = 0 and then Int64 (D.Joint_Config'Length) = Int64 (D.Nj) then
        Real_Array'[for J in 0 .. D.Nj - 1 => Real (D.Joint_Config (J).Reference)]
        & Real_Array'[0 .. Integer (D.Nv) - 1 => 0.0] & 0.0
      else [1 .. 0 => 0.0]);

   function Body_Bounded (S : Body_State) return Boolean is
     (Bounded (S.Position) and then Bounded (S.Center)
      and then Unit_Quaternion (S.Orientation)
      and then Bounded (S.Rotation, 16.0) and then Bounded (S.Inertial_Rotation, 16.0)
      and then Bounded (S.Linear_Velocity) and then Bounded (S.Angular_Velocity)
      and then Bounded (S.Linear_Bias) and then Bounded (S.Angular_Bias));
   function Joint_Bounded (S : Joint_State) return Boolean is
     (Bounded (S.Anchor) and then Bounded (S.Direction, 1.00001));
   function Array_Bounded (P : Real_Array_Access; Limit : Real := Work_Limit) return Boolean is
     (P /= null and then (for all X of P.all => X in -Limit .. Limit))
     with Pre => Limit >= 0.0;
   function Configuration_Bounded (D : Simulation) return Boolean is
     (Bounded (D.Gravity, Max_Val)
      and then D.Body_Config /= null and then D.Joint_Config /= null and then D.Actuator_Config /= null
      and then (for all B of D.Body_Config.all => Bounded (B.Position, Max_Val)
        and then Bounded (B.Inertial_Position, Max_Val) and then Bounded (B.Inertia, Max_Val))
      and then (for all J of D.Joint_Config.all => Bounded (J.Anchor, Max_Val))
      and then (for all A of D.Actuator_Config.all => Bounded (A.Bias, Max_Val)));
   function Kinematic_Bounded (K : Kinematic_Buffers) return Boolean is
     (K.Bodies /= null and then K.Joints /= null
      and then (for all B of K.Bodies.all => Body_Bounded (B))
      and then (for all J of K.Joints.all => Joint_Bounded (J))
      and then Array_Bounded (K.Linear_Jacobian) and then Array_Bounded (K.Angular_Jacobian));
   function Caches_Bounded (D : Simulation) return Boolean is
     ((if D.Cache.Pose_Valid then Kinematic_Bounded (D.Kinematic))
      and then (if D.Cache.Mass_Valid then Array_Bounded (D.Dynamics.Mass))
      and then (if D.Cache.Passive_Valid then Array_Bounded (D.Dynamics.Gravity)
        and then Array_Bounded (D.Dynamics.Bias) and then Array_Bounded (D.Dynamics.Passive))
      and then (if D.Cache.Actuation_Valid then Array_Bounded (D.Dynamics.Actuator, 1.0e50)
        and then Array_Bounded (D.Actuators.Length, 1.0e20) and then Array_Bounded (D.Actuators.Velocity, 1.0e20)
        and then Array_Bounded (D.Actuators.Force, 4.0e30))
      and then (if D.Cache.Force_Valid then Array_Bounded (D.Dynamics.Acceleration, Max_Val)
        and then Array_Bounded (D.Dynamics.Total)));

   function Configuration_Valid
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array; Actuators : Actuator_Parameter_Array;
      Nb, Nj, Na : Natural) return Boolean is
     ((for all B in 0 .. Nb - 1 =>
        (if B = 0 then Bodies (B).Parent = 0 and then Bodies (B).Joint_Count = 0
         else Bodies (B).Parent < B)
        and then Bodies (B).Joint_Count <= Nj
        and then (if Bodies (B).Joint_Count > 0 then Bodies (B).First_Joint >= 0
          and then Bodies (B).First_Joint <= Nj - Bodies (B).Joint_Count)
        and then Unit_Quaternion (Bodies (B).Orientation)
        and then Unit_Quaternion (Bodies (B).Inertial_Orientation))
      and then (for all J in 0 .. Nj - 1 =>
        Joints (J).Body_Id in 1 .. Nb - 1
        and then Joints (J).Qadr = J and then Joints (J).Vadr = J
        and then Unit_Vector (Joints (J).Direction))
      and then (for all A in 0 .. Na - 1 => Actuators (A).Joint_Id < Nj
        and then Actuators (A).Control_Id = A and then Actuators (A).Output_Id = A
        and then (if Actuators (A).Control_Limited then
          Actuators (A).Control_Lower <= Actuators (A).Control_Upper)
        and then (if Actuators (A).Force_Limited then
          Actuators (A).Force_Lower <= Actuators (A).Force_Upper))) with Global => null,
     Pre => Nb <= Max_Bodies and then Nj <= Max_Dofs and then Na <= Max_Actuators
       and then Bodies'First = 0 and then Bodies'Last = Nb - 1
       and then Joints'First = 0 and then Joints'Last = Nj - 1
       and then Actuators'First = 0 and then Actuators'Last = Na - 1;

   function Is_Ready (D : Simulation) return Boolean is
     (D.Allocated and then D.Nb in 1 .. Max_Bodies and then D.Nv <= Max_Dofs
      and then D.Nq = D.Nv and then D.Nj = D.Nv and then D.Na <= Max_Actuators
      and then D.Nu = D.Na and then D.No = D.Na
      and then D.Body_Config /= null and then D.Body_Config'First = 0 and then Int64 (D.Body_Config'Length) = Int64 (D.Nb)
      and then D.Joint_Config /= null and then D.Joint_Config'First = 0 and then D.Joint_Config'Last = D.Nj - 1 and then Int64 (D.Joint_Config'Length) = Int64 (D.Nj)
      and then D.Actuator_Config /= null and then D.Actuator_Config'First = 0 and then D.Actuator_Config'Last = D.Na - 1 and then Int64 (D.Actuator_Config'Length) = Int64 (D.Na)
      and then D.Kinematic.Bodies /= null and then D.Kinematic.Bodies'First = 0
      and then Int64 (D.Kinematic.Bodies'Length) = Int64 (D.Nb)
      and then D.Kinematic.Joints /= null and then D.Kinematic.Joints'First = 0
      and then Int64 (D.Kinematic.Joints'Length) = Int64 (D.Nj)
      and then Has_Real_Layout (D.State.Qpos, D.Nq) and then Has_Real_Layout (D.State.Qvel, D.Nv)
      and then Has_Real_Layout (D.State.Ctrl, D.Nu) and then Has_Real_Layout (D.State.Applied, D.Nv)
      and then Has_Real_Layout (D.Kinematic.Linear_Jacobian, 3 * D.Nb * D.Nv)
      and then Has_Real_Layout (D.Kinematic.Angular_Jacobian, 3 * D.Nb * D.Nv)
      and then Has_Real_Layout (D.Dynamics.Mass, D.Nv * D.Nv)
      and then Has_Real_Layout (D.Dynamics.Bias, D.Nv) and then Has_Real_Layout (D.Dynamics.Gravity, D.Nv)
      and then Has_Real_Layout (D.Dynamics.Passive, D.Nv) and then Has_Real_Layout (D.Dynamics.Actuator, D.Nv)
      and then Has_Real_Layout (D.Dynamics.Acceleration, D.Nv) and then Has_Real_Layout (D.Dynamics.Total, D.Nv)
      and then Has_Real_Layout (D.Actuators.Length, D.No) and then Has_Real_Layout (D.Actuators.Velocity, D.No)
      and then Has_Real_Layout (D.Actuators.Force, D.No)
      and then Has_Real_Layout (D.Scratch.Factor, D.Nv * D.Nv)
      and then Has_Real_Layout (D.Scratch.Rhs, D.Nv) and then Has_Real_Layout (D.Scratch.Solution, D.Nv)
      and then Has_Real_Layout (D.Scratch.Condition_Sums, D.Nv)
      and then Has_Real_Layout (D.Scratch.Next_Qpos, D.Nq) and then Has_Real_Layout (D.Scratch.Next_Qvel, D.Nv)
      and then Configuration_Bounded (D) and then Caches_Bounded (D)
      and then (for all X of D.State.Qpos.all => X in Tier0_Real)
      and then (for all X of D.State.Qvel.all => X in Tier0_Real)
      and then (for all X of D.State.Ctrl.all => X in Tier0_Real)
      and then (for all X of D.State.Applied.all => X in Tier0_Real)
      and then Configuration_Valid (D.Body_Config.all, D.Joint_Config.all, D.Actuator_Config.all,
        D.Nb, D.Nj, D.Na));

   --  Under the existing lifecycle invariant, allocation alone distinguishes
   --  the empty and ready cases. This lemma does not validate arbitrary state.
   --  The runtime phase guards retain Is_Ready until their preservation proofs
   --  close; the inexpensive query is measured only in an isolated experiment.
   function Ready_Flag (D : Simulation) return Boolean is (D.Allocated)
     with Global => null, Pre => Valid_State (D),
     Post => Ready_Flag'Result = Is_Ready (D)
       and then (if not Ready_Flag'Result then Is_Empty (D));

   function Acceleration (D : Simulation; Index : Natural) return Real is (D.Dynamics.Acceleration (Index));
   function Mass_Entry (D : Simulation; Row, Column : Natural) return Real is
     (D.Dynamics.Mass (MJ.Smooth_Kernels.Matrix_Offset (D.Nv, Row, Column)));
   function Force_Value (D : Simulation; Kind : Force_Kind; Index : Natural) return Real is
     (case Kind is
        when Gravity_Force => D.Dynamics.Gravity (Index),
        when Velocity_Bias => D.Dynamics.Bias (Index),
        when Passive_Force => D.Dynamics.Passive (Index),
        when Actuator_Force => D.Dynamics.Actuator (Index));
   function Actuator_Value (D : Simulation; Kind : Actuator_Quantity; Index : Natural) return Real is
     (case Kind is
        when Transmission_Length => D.Actuators.Length (Index),
        when Transmission_Velocity => D.Actuators.Velocity (Index),
        when Output_Force => D.Actuators.Force (Index));
   function Body_Position (D : Simulation; Index : Natural) return Vector is
     (D.Kinematic.Bodies (Index).Position);
   function Body_Orientation (D : Simulation; Index : Natural) return Quaternion is
     (D.Kinematic.Bodies (Index).Orientation);

   function Jacobian_Offset (D : Simulation; Body_Id, Velocity_Id : Natural) return Natural is
     (MJ.Smooth_Kernels.Jacobian_Index (D.Nb, D.Nv, Body_Id, Velocity_Id))
     with Pre => D.Nb <= Max_Bodies and then D.Nv <= Max_Dofs
       and then Body_Id < D.Nb and then Velocity_Id < D.Nv,
     Post => Jacobian_Offset'Result = 3 * (Body_Id * D.Nv + Velocity_Id)
       and then Jacobian_Offset'Result + 2 < 3 * D.Nb * D.Nv;
   function At_Reset_State (D : Simulation) return Boolean is
     (Is_Ready (D) and then D.Clock = 0.0
      and then (for all J in 0 .. D.Nj - 1 => D.State.Qpos (J) = D.Joint_Config (J).Reference)
      and then (for all X of D.State.Qvel.all => X = 0.0)
      and then (for all X of D.State.Ctrl.all => X = 0.0)
      and then (for all X of D.State.Applied.all => X = 0.0));
   function Symmetric_Mass (D : Simulation) return Boolean is
     (Is_Ready (D) and then (for all I in 0 .. D.Nv - 1 =>
       (for all J in 0 .. D.Nv - 1 =>
         D.Dynamics.Mass (I * D.Nv + J) = D.Dynamics.Mass (J * D.Nv + I))));
   --  Limit the mutable formal to cache flags so state/configuration frames
   --  follow directly from the language's parameter and ownership rules.
   procedure Invalidate (Cache : in out Cache_Flags) with Global => null,
     Post => not Cache.Pose_Valid and then not Cache.Mass_Valid
       and then not Cache.Passive_Valid and then not Cache.Actuation_Valid
       and then not Cache.Force_Valid;
   function Within_Work (X : Real) return Boolean is (X in -Work_Limit .. Work_Limit);
   function Zero_Array (Length : Natural) return Real_Array_Access with
     Pre => Length <= Max_Size,
     Post => Zero_Array'Result /= null and then Zero_Array'Result'First = 0
       and then Zero_Array'Result'Length = Length and then Zero_Array'Result'Last = Length - 1
       and then (for all X of Zero_Array'Result.all => X = 0.0);
end MJ.Data;

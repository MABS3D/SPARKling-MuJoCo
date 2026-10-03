with MJ.Collision_Scene;
with MJ.Rigid_Geometry;
with MJ.Full_Contacts;
with MJ.Constraint_Assembly;
with MJ.Constraint_Solvers;
with MJ.Joint_Limit_Response;
with MJ.External_Forces;
with MJ.Surface_Velocity;
with MJ.Constrained_Assets;
with MJ.Equality_Scalar;

--  Opt-in integrated rigid constraint path. Reuses the owned smooth engine.
--  This entry point has pending composition proofs; it does not promote its
--  experimental callees to Gold. All build profiles retain runtime checks.
package MJ.Data.Constrained with SPARK_Mode is
   Max_V : constant := MJ.Constraint_Solvers.Max_Dofs;
   Max_R : constant := MJ.Constraint_Solvers.Max_Rows;
   Max_G : constant := 256;
   Max_C : constant := 128;
   type Engine is limited private;
   type Trace is record
      Valid : Boolean := False;
      Nv, Nrow, Ncontact : Natural := 0;
      J : MJ.Constraint_Solvers.Matrix (1 .. Max_R, 1 .. Max_V) := [others => [others => 0.0]];
      Aref, R, Force : MJ.Constraint_Solvers.Vector (1 .. Max_R) := [others => 0.0];
      A_Free, Acceleration, Constraint_Force : MJ.Constraint_Solvers.Vector (1 .. Max_V) := [others => 0.0];
      Adhesion_Force : MJ.Constraint_Solvers.Vector (1 .. Max_V) := [others => 0.0];
      Report : MJ.Constraint_Solvers.Report;
   end record;
   function Ready (E : Engine) return Boolean with Global => null;
   function State (E : Engine) return Real_Array with Global => null;
   --  State retains [qpos,qvel,time]; Complete_State also includes activation.
   function Complete_State (E : Engine) return Real_Array with Global => null;
   function Activation_Count (E : Engine) return Natural with Global => null;
   function Activation_Values (E : Engine) return Real_Array with Global => null;
   function Activation_Rates (E : Engine) return Real_Array with Global => null;
   function Mocap_Count (E : Engine) return Natural with Global => null;
   function Mocap_Values (E : Engine) return Real_Array with Global => null;
   procedure Set_Mocap (E : in out Engine; Index : Natural;
                        Position, Quaternion : State_Vector; Result : out Status);
   function Diagnostics (E : Engine) return Trace with Global => null;
   function Adhesion_Moment (E : Engine; Index : Natural) return Real_Array
     with Global => null, Pre => Ready (E);
   function Actuator_Forces (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Actuator_Velocities (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Equality_Count (E : Engine) return Natural with Global => null;
   function Equality_Active (E : Engine; Index : Natural) return Boolean
     with Global => null, Pre => Index < Equality_Count (E);
   procedure Set_Equality_Active
     (E : in out Engine; Index : Natural; Active : Boolean; Result : out Status);
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status)
     with Post => M.Opt.Disableflags = M.Opt.Disableflags'Old
       and then M.Flg_Adhesion = M.Flg_Adhesion'Old
       and then (if Result = Success then Ready (E));
   procedure Free (E : in out Engine; Result : out Status)
     with Post => not Ready (E) and then Result = Success;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Status);
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status)
     with Global => null, Pre => Ready (E),
       Post => (Static => Ready (E) and then State (E) = State (E)'Old
         and then (if Result = Success then Activation_Values (E) = As_Reals (Values)
           else Activation_Values (E) = Activation_Values (E)'Old));
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => Complete_State (E) = Complete_State (E)'Old);
   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => (if Result /= Success then Complete_State (E) = Complete_State (E)'Old));
private
   --  Child force producers can own activation/control while sharing D.
   procedure Create_Core (M : in out MJ.Models.Model; E : in out Engine;
                          Result : out Status; Dynamics_Only : Boolean)
     with Post => M.Opt.Disableflags = M.Opt.Disableflags'Old
       and then M.Flg_Adhesion = M.Flg_Adhesion'Old
       and then (if Result = Success then Ready (E));
   procedure Generate_Contacts (E : in out Engine; Result : out Status);
   --  Shared stages for child contact producers. The ordinary entry retains
   --  its own admission and collision dispatch.
   procedure Assemble (E : in out Engine; Result : out Status);
   --  Specialized equality producers insert their ordered rows between
   --  these stages. Friction, limits and contacts follow all equalities.
   procedure Begin_Assembly (E : in out Engine; Result : out Status);
   procedure Finish_Assembly (E : in out Engine; Result : out Status);
   procedure Prepare_And_Solve (E : in out Engine; Result : out Status);
   procedure Advance (E : in out Engine; Result : out Status);
   package CA renames MJ.Constraint_Assembly;
   package CS renames MJ.Constraint_Solvers;
   package RG renames MJ.Rigid_Geometry;
   package LR renames MJ.Joint_Limit_Response;
   --  Shared by ordinary and specialized contact producers. The result
   --  follows mj_local2Global, including compiled same-frame shortcuts.
   procedure Generate_Geom_Poses
     (E : in out Engine; Poses : out RG.Pose_Array; Result : out Status);
   function Disabled (Flags, Flag : Integer) return Boolean;
   function Parameters (Ref, Imp : Real_Array; Id : Natural) return LR.Parameters;
   type Geom_Description is record
      Body_Id : Natural := 0;
      Position : Vector := Zero;
      Orientation : Quaternion := Identity_Quaternion;
      Same_Frame : Natural range 0 .. 4 := 0;
      Surface : MJ.Surface_Velocity.Motion := [others => 0.0];
      Surface_Pose : MJ.Surface_Velocity.Pose;
   end record;
   type Geom_Array is array (Natural range 0 .. Max_G - 1) of Geom_Description;
   type Joint_Description is record
      Kind : Joint_Kind := Hinge;
      Qadr, Vadr : Natural := 0;
      Is_Limited : Boolean := False;
      Low, High, Margin : Tier0_Real := 0.0;
      Params : LR.Parameters;
   end record;
   type Joint_Array is array (Natural range 0 .. Max_V - 1) of Joint_Description;
   type Dof_Description is record
      Parent : Integer := -1;
      Loss, Weight : Nonneg_Tier0 := 0.0;
      Params : LR.Parameters;
   end record;
   type Dof_Array is array (Natural range 0 .. Max_V - 1) of Dof_Description;
   type Body_Description is record
      Leaf : Integer := -1;
      Translation, Rotation : Nonneg_Tier0 := 0.0;
   end record;
   type Body_Array is array (Natural range 0 .. Max_Bodies - 1) of Body_Description;
   Max_T : constant := MJ.Spatial_Tendon_Models.Max_Objects;
   Max_T_Entries : constant := Max_T * Max_V;
   type Tendon_Description is record
      First, Width : Natural := 0;
      Is_Limited : Boolean := False;
      Required_By_Equality : Boolean := False;
      Low, High, Margin : Tier0_Real := 0.0;
      Loss, Weight : Nonneg_Tier0 := 0.0;
      Limit_Params, Friction_Params : LR.Parameters;
   end record;
   type Tendon_Array is array (Natural range 0 .. Max_T - 1) of Tendon_Description;
   type Equality_Tendon_Map is array (Positive range 1 .. Max_V) of Natural range 0 .. Max_T_Entries;
   type Equality_Description is record
      Weld, Site, Active : Boolean := False;
      Kind : Natural range 0 .. 6 := 0;
      Object0 : Natural := 0;
      Object1 : Integer := -1;
      Reference0, Reference1 : Tier0_Real := 0.0;
      Polynomial : MJ.Equality_Scalar.Coefficients := [others => 0.0];
      Scalar_Weight : Tier1_Real := 0.0;
      Map0, Map1 : Equality_Tendon_Map;
      Body0, Body1 : Natural := 0;
      Anchor0, Anchor1 : Vector := Zero;
      Local0, Local1 : Quaternion := Identity_Quaternion;
      Torque : Tier0_Real := 1.0;
      Params : LR.Parameters;
      Width, First_Row : Natural := 0;
      Columns : CA.Column_Array (1 .. Max_V);
      Position_Norm : Real := 0.0;
      Jdot_V : CA.Value_Array (1 .. 6) := [others => 0.0];
   end record;
   type Equality_Array is array (Natural range 0 .. Max_R - 1) of Equality_Description;
   type Contact_Endpoints is record
      Body0, Body1 : Natural := 0;
      Geom0, Geom1 : Integer range -1 .. Max_G - 1 := -1;
   end record;
   type Contact_Endpoint_Array is array (Natural range 0 .. Max_C - 1) of Contact_Endpoints;
   -- Ordered, positive C element weights, not exact real barycentric weights.
   -- Repeated bodies are retained: combining them changes rounded evaluation.
   type Weighted_Body is record
      Body_Id : Natural := 0;
      Weight : Real := 0.0;
   end record;
   type Weighted_Body_Array is array (Positive range 1 .. 4) of Weighted_Body;
   type Weighted_Side is record
      Count : Natural := 1;
      Items : Weighted_Body_Array := [1 => (0, 1.0), others => <>];
   end record;
   type Weighted_Contact is record
      Active : Boolean := False;
      Side0, Side1 : Weighted_Side;
   end record;
   type Weighted_Contact_Array is array (Natural range 0 .. Max_C - 1) of Weighted_Contact;
   type Engine is limited record
      Initialized : Boolean := False;
      D : MJ.Data.Simulation;
      Has_Adhesion : Boolean := False;
      Body_Moments : CS.Matrix (1 .. Max_Actuators, 1 .. Max_V)
        := [others => [others => 0.0]];
      Scene : MJ.Collision_Scene.Scene;
      Assets : MJ.Constrained_Assets.Store;
      Ng, Nj : Natural := 0;
      Flags : Integer := 0;
      Has_Surface_Velocity : Boolean := False;
      Cone : CA.Cone_Kind := CA.Pyramidal;
      Impratio : Real := 1.0;
      Settings : CS.Options;
      Geoms : Geom_Array;
      Joints : Joint_Array;
      Dofs : Dof_Array;
      Bodies : Body_Array;
      Ne : Natural := 0;
      Equalities : Equality_Array;
      Nt, Tendon_Entries : Natural := 0;
      Tendons : Tendon_Array;
      Tendon_Columns : CA.Column_Array (1 .. Max_T_Entries);
      Tendon_J : CA.Value_Array (1 .. Max_T_Entries);
      Contacts : MJ.Full_Contacts.Full_Array (0 .. Max_C - 1);
      Endpoints : Contact_Endpoint_Array;
      Contact_Weights : Weighted_Contact_Array;
      Rows : CA.Storage (Max_R, Max_R * Max_V);
      Solver_Rows : CS.Rows (1 .. Max_R);
      --  Only rows produced by specialized flex equalities read this cache.
      --  The producer writes each consumed slot; no per-step clear is needed.
      Equality_Weights : CA.Value_Array (1 .. Max_R) := [others => 0.0];
      Surface_Rows : CS.Vector (1 .. Max_R) := [others => 0.0];
      T : Trace;
   end record;
   -- Contact producers set real body endpoints independently of optional geom
   -- ids. A flex vertex has one body endpoint and Geom_Id = -1.
   procedure Set_Contact_Endpoints
     (E : in out Engine; Id, Body0, Body1 : Natural;
      Geom0, Geom1 : Integer; Result : out Status)
     with Global => null,
     Post => (Static => Result in Success | Invalid_Index
       and then (if Result = Success then Id in E.Endpoints'Range
         and then Body0 in E.Bodies'Range and then Body1 in E.Bodies'Range
         and then Geom0 in -1 .. Max_G - 1 and then Geom1 in -1 .. Max_G - 1
         and then E.Endpoints (Id) = (Body0, Body1, Geom0, Geom1)
         and then E.Contact_Weights (Id) = (False,
           E.Contact_Weights'Old (Id).Side0, E.Contact_Weights'Old (Id).Side1)
         and then (for all K in E.Endpoints'Range =>
           (if K /= Id then E.Endpoints (K) = E.Endpoints'Old (K)))
         and then (for all K in E.Contact_Weights'Range =>
           (if K /= Id then E.Contact_Weights (K) = E.Contact_Weights'Old (K)))
         else E.Endpoints = E.Endpoints'Old and then E.Contact_Weights = E.Contact_Weights'Old));
   -- Validates both complete lists before publishing metadata. Geom sides
   -- require exactly one body of weight 1; flex element sides use Geom=-1.
   -- The singleton body ids are diagnostic representatives while Active.
   procedure Set_Weighted_Contact_Endpoints
     (E : in out Engine; Id : Natural; Side0, Side1 : Weighted_Side;
      Geom0, Geom1 : Integer; Result : out Status) with Global => null,
     Post => (Static => Result in Success | Invalid_Index
       and then (if Result = Success then Id in E.Endpoints'Range
         and then Side0.Count in 1 .. 4 and then Side1.Count in 1 .. 4
         and then Geom0 in -1 .. Max_G-1 and then Geom1 in -1 .. Max_G-1
         and then E.Endpoints (Id) =
           (Side0.Items (1).Body_Id, Side1.Items (1).Body_Id, Geom0, Geom1)
         and then E.Contact_Weights (Id) = (True, Side0, Side1)
         and then (for all K in E.Endpoints'Range =>
           (if K /= Id then E.Endpoints (K) = E.Endpoints'Old (K)))
         and then (for all K in E.Contact_Weights'Range =>
           (if K /= Id then E.Contact_Weights (K) = E.Contact_Weights'Old (K)))
         else E.Endpoints = E.Endpoints'Old and then E.Contact_Weights = E.Contact_Weights'Old));
   procedure Set_Rigid_Contact_Endpoints (E : in out Engine; Result : out Status);
end MJ.Data.Constrained;

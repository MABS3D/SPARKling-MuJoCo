with MJ.Collision_Scene;
with MJ.Rigid_Geometry;
with MJ.Full_Contacts;
with MJ.Constraint_Assembly;
with MJ.Constraint_Solvers;
with MJ.Joint_Limit_Response;
with MJ.External_Forces;

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
   function Diagnostics (E : Engine) return Trace with Global => null;
   function Adhesion_Moment (E : Engine; Index : Natural) return Real_Array
     with Global => null, Pre => Ready (E);
   function Actuator_Forces (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Actuator_Velocities (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
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
   package CA renames MJ.Constraint_Assembly;
   package CS renames MJ.Constraint_Solvers;
   package RG renames MJ.Rigid_Geometry;
   package LR renames MJ.Joint_Limit_Response;
   type Geom_Description is record
      Body_Id : Natural := 0;
      Position : Vector := Zero;
      Rotation : Matrix := Identity;
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
   type Engine is limited record
      Initialized : Boolean := False;
      D : MJ.Data.Simulation;
      Has_Adhesion : Boolean := False;
      Body_Moments : CS.Matrix (1 .. Max_Actuators, 1 .. Max_V)
        := [others => [others => 0.0]];
      Scene : MJ.Collision_Scene.Scene;
      Ng, Nj : Natural := 0;
      Flags : Integer := 0;
      Cone : CA.Cone_Kind := CA.Pyramidal;
      Impratio : Real := 1.0;
      Settings : CS.Options;
      Geoms : Geom_Array;
      Joints : Joint_Array;
      Dofs : Dof_Array;
      Bodies : Body_Array;
      Contacts : MJ.Full_Contacts.Full_Array (0 .. Max_C - 1);
      Rows : CA.Storage (Max_R, Max_R * Max_V);
      Solver_Rows : CS.Rows (1 .. Max_R);
      T : Trace;
   end record;
end MJ.Data.Constrained;

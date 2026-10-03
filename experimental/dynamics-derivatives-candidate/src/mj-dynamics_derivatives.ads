with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Data;
with MJ.Data.Constrained;
with MJ.External_Forces;
with MJ.Derivative_Kernels;

-- Owns scratch simulators; never perturbs an existing caller simulation.
-- Integration proofs are pending; no whole-engine Gold claim is made here.
package MJ.Dynamics_Derivatives with SPARK_Mode is
   package DK renames MJ.Derivative_Kernels;
   use type DK.Matrix;
   use type MJ.Data.Status;
   subtype Matrix is DK.Matrix;
   subtype Increment is DK.Increment;
   subtype State_Vector is MJ.Data.State_Vector;
   subtype Status is MJ.Data.Status;
   type Backend is (Smooth, Constrained);
   type Dimensions is record
      Nq, Nv, Nu, Na, Nmass : Natural := 0;
   end record;
   type Workspace is limited private;
   function Ready (W : Workspace) return Boolean with Global => null;
   function Shape (W : Workspace) return Dimensions with Global => null;
   function State_Dimension (W : Workspace) return Natural with Global => null;
   procedure Create (M : in out MJ.Models.Model; W : in out Workspace;
                     Mode : Backend; Result : out Status)
     with Post => M.Opt.Disableflags = M.Opt.Disableflags'Old
       and then M.Flg_Adhesion = M.Flg_Adhesion'Old;
   procedure Free (W : in out Workspace);

   -- A: output tangent-state rows, input tangent-state columns; B: controls.
   -- Tangent state [dq(nv), dv(nv), da(na)] excludes time.
   -- Inputs include qpos(nq), velocities, activation, controls and applied force.
   -- Output matrices are atomic on all reported failures, including size errors.
   procedure Transition_FD
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl, Applied : State_Vector;
      Time : Nonneg_Tier0; Eps : Increment; Centered : Boolean;
      A, B : in out Matrix; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => (if Result /= MJ.Data.Success then
       A = A'Old and then B = B'Old));

   -- d(actuator+passive-bias)/dv, or d(passive)/dv.
   -- Smooth uses the centered C stencil; Passive uses the forward C stencil.
   type Force_Derivative is (Smooth_Force, Passive_Force);
   procedure Velocity_FD
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl : State_Vector;
      Eps : Increment; Kind : Force_Derivative;
      Derivative : in out Matrix; Result : out Status)
     with Post => (Static => (if Result /= MJ.Data.Success then
       Derivative = Derivative'Old));

   -- C convention: input direction is the ROW, output force is the COLUMN.
   -- DmDq uses MuJoCo 3.14.0 lower-triangular CSR order (m->M_rownnz/colind).
   -- Includes scalar, pyramidal and elliptic inverse-constraint response.
   -- Inverse-discrete correction remains unsupported.
   -- Forward finite differences, optionally subtracting actuator force.
   procedure Inverse_FD
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl, Acc : State_Vector;
      Eps : Increment; Subtract_Actuation : Boolean;
      DfDq, DfDv, DfDa, DmDq : in out Matrix; Result : out Status)
     with Post => (Static => (if Result /= MJ.Data.Success then
       DfDq = DfDq'Old and then DfDv = DfDv'Old
       and then DfDa = DfDa'Old and then DmDq = DmDq'Old));
private
   type Matrix_Access is access Matrix;
   type Joint is record
      Kind, Qadr, Vadr : Natural := 0;
   end record;
   type Joint_Array is array (Natural range 0 .. MJ.Data.Max_Dofs - 1) of Joint;
   type Control is record
      Is_Limited : Boolean := False;
      Low, High : Tier0_Real := 0.0;
   end record;
   type Controls is array (Natural range 0 .. MJ.Data.Max_Actuators - 1) of Control;
   type Mass_Entry is record
      Row, Column : Natural := 0;
   end record;
   type Mass_Layout is array (Natural range 0 ..
     (MJ.Data.Max_Dofs * (MJ.Data.Max_Dofs + 1)) / 2 - 1) of Mass_Entry;
   type Workspace is limited record
      Initialized : Boolean := False;
      Mode : Backend := Smooth;
      Sparse : Boolean := False;
      Dims : Dimensions;
      Nj : Natural := 0;
      Joints : Joint_Array;
      Ctrl : Controls;
      Mass : Mass_Layout;
      S : MJ.Data.Simulation;
      C : MJ.Data.Constrained.Engine;
      TA, TB, TQ, TV, TAcc, TM : Matrix_Access := null;
   end record;
end MJ.Dynamics_Derivatives;

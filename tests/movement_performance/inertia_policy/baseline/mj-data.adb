with Ada.Unchecked_Deallocation;
with Interfaces;
with MJ.Models.Validity;

package body MJ.Data with SPARK_Mode is
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
   --  Clear-buffer preconditions make these entry-bound snapshots defined.
   pragma Unevaluated_Use_Of_Old (Allow);
   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_8;

   procedure Free_Body_Config is new Ada.Unchecked_Deallocation
     (Body_Parameter_Array, Body_Parameter_Access);
   procedure Free_Joint_Config is new Ada.Unchecked_Deallocation
     (Joint_Parameter_Array, Joint_Parameter_Access);
   procedure Free_Actuator_Config is new Ada.Unchecked_Deallocation
     (Actuator_Parameter_Array, Actuator_Parameter_Access);
   procedure Free_Body_State is new Ada.Unchecked_Deallocation
     (Body_State_Array, Body_State_Access);
   procedure Free_Joint_State is new Ada.Unchecked_Deallocation
     (Joint_State_Array, Joint_State_Access);

   function Has_Flag (Flags, Flag : Integer) return Boolean is
     ((Interfaces.Unsigned_32 (Flags) and Interfaces.Unsigned_32 (Flag)) /= 0)
     with Pre => Flags >= 0 and then Flag >= 0;





   function Zero_Array (Length : Natural) return Real_Array_Access is
   begin
      return new Real_Array'[0 .. Integer (Length) - 1 => 0.0];
   end Zero_Array;

   procedure Equal_Input_Images (C1, C2, F1, F2 : Real_Array) is null;
   procedure Prove_Configuration_Equality (A, B : Configuration_Snapshot) is
   begin
      for I in A.Bodies'Range loop
         pragma Assert (A.Bodies (I) = B.Bodies (I));
         pragma Loop_Invariant (for all K in A.Bodies'First .. I => A.Bodies (K) = B.Bodies (K));
      end loop;
      for I in A.Joints'Range loop
         pragma Assert (A.Joints (I) = B.Joints (I));
         pragma Loop_Invariant (for all K in A.Joints'First .. I => A.Joints (K) = B.Joints (K));
      end loop;
      for I in A.Actuators'Range loop
         pragma Assert (A.Actuators (I) = B.Actuators (I));
         pragma Loop_Invariant (for all K in A.Actuators'First .. I => A.Actuators (K) = B.Actuators (K));
      end loop;
   end Prove_Configuration_Equality;

   procedure Equal_Configurations (A, B, C : Configuration_Snapshot) is
   begin
      for I in A.Bodies'Range loop
         pragma Assert (A.Bodies (I) = C.Bodies (I));
         pragma Loop_Invariant (for all J in A.Bodies'First .. I => A.Bodies (J) = C.Bodies (J));
      end loop;
      for I in A.Joints'Range loop
         pragma Assert (A.Joints (I) = C.Joints (I));
         pragma Loop_Invariant (for all J in A.Joints'First .. I => A.Joints (J) = C.Joints (J));
      end loop;
      for I in A.Actuators'Range loop
         pragma Assert (A.Actuators (I) = C.Actuators (I));
         pragma Loop_Invariant (for all J in A.Actuators'First .. I => A.Actuators (J) = C.Actuators (J));
      end loop;
   end Equal_Configurations;

   procedure Invalidate (Cache : in out Cache_Flags) is
   begin
      Cache.Pose_Valid := False;
      Cache.Mass_Valid := False;
      Cache.Passive_Valid := False;
      Cache.Actuation_Valid := False;
      Cache.Force_Valid := False;
   end Invalidate;

   function Body_Status (S : MJ.Models.Sizes; Fields : MJ.Models.Body_Arrays) return Status with
     Global => null,
     Pre => S.Nbody >= 1 and then MJ.Models.Sizes_In_Range (S) and then MJ.Models.Body_Layout_OK (S, Fields),
     Post => (Body_Status'Result = Success) =
       (Fields.Body_Jntnum (0) = 0 and then (for all K in 0 .. S.Nbody - 1 => Fields.Body_Gravcomp (K) = 0.0))
   is
   begin
      if Fields.Body_Jntnum (0) /= 0 then
         return Unsupported_Feature;
      end if;
      for B in 0 .. S.Nbody - 1 loop
         if Fields.Body_Gravcomp (B) /= 0.0 then
            return Unsupported_Feature;
         end if;
         pragma Loop_Invariant (for all K in 0 .. B => Fields.Body_Gravcomp (K) = 0.0);
      end loop;
      return Success;
   end Body_Status;

   function Joint_Element (S : MJ.Models.Sizes; Fields : MJ.Models.Joint_Arrays; J : Natural) return Status with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Joint_Layout_OK (S, Fields)
       and then J < S.Njnt,
     Post => (Joint_Element'Result = Success) = (Fields.Jnt_Type (J) in 2 .. 3
          and then Fields.Jnt_Actfrclimited (J) = 0 and then Fields.Jnt_Actgravcomp (J) = 0
          and then Fields.Jnt_Stiffnesspoly (2 * J) = 0.0 and then Fields.Jnt_Stiffnesspoly (2 * J + 1) = 0.0
          and then Fields.Jnt_Stiffness (J) in Nonneg_Tier0)
   is
   begin
         if Fields.Jnt_Type (J) not in 2 .. 3 then
            return Unsupported_Joint;
         end if;
         if Fields.Jnt_Actfrclimited (J) /= 0 or else Fields.Jnt_Actgravcomp (J) /= 0
           or else Fields.Jnt_Stiffnesspoly (2 * J) /= 0.0
           or else Fields.Jnt_Stiffnesspoly (2 * J + 1) /= 0.0
         then
            return Unsupported_Feature;
         end if;
         if Fields.Jnt_Stiffness (J) not in Nonneg_Tier0 then
            return Invalid_Model;
         end if;
      return Success;
   end Joint_Element;

   function Joint_Status (S : MJ.Models.Sizes; Fields : MJ.Models.Joint_Arrays) return Status with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Joint_Layout_OK (S, Fields),
     Post => (Joint_Status'Result = Success) =
       (for all K in 0 .. S.Njnt - 1 => Joint_Element (S, Fields, K) = Success)
   is
      Detail : Status;
   begin
      for J in 0 .. S.Njnt - 1 loop
         Detail := Joint_Element (S, Fields, J);
         if Detail /= Success then
            return Detail;
         end if;
         pragma Loop_Invariant (for all K in 0 .. J => Joint_Element (S, Fields, K) = Success);
      end loop;
      return Success;
   end Joint_Status;

   function Dof_Element (S : MJ.Models.Sizes; Fields : MJ.Models.Dof_Arrays; V : Natural) return Status with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Dof_Layout_OK (S, Fields)
       and then V < S.Nv,
     Post => (Dof_Element'Result = Success) = (Fields.Dof_Dampingpoly (2 * V) = 0.0 and then Fields.Dof_Dampingpoly (2 * V + 1) = 0.0
          and then Fields.Dof_Armature (V) in Nonneg_Tier0 and then Fields.Dof_Damping (V) in Nonneg_Tier0)
   is
   begin
         if Fields.Dof_Dampingpoly (2 * V) /= 0.0
           or else Fields.Dof_Dampingpoly (2 * V + 1) /= 0.0
         then
            return Unsupported_Feature;
         end if;
         if Fields.Dof_Armature (V) not in Nonneg_Tier0
           or else Fields.Dof_Damping (V) not in Nonneg_Tier0
         then
            return Invalid_Model;
         end if;
      return Success;
   end Dof_Element;

   function Dof_Status (S : MJ.Models.Sizes; Fields : MJ.Models.Dof_Arrays) return Status with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Dof_Layout_OK (S, Fields),
     Post => (Dof_Status'Result = Success) =
       (for all K in 0 .. S.Nv - 1 => Dof_Element (S, Fields, K) = Success)
   is
      Detail : Status;
   begin
      for V in 0 .. S.Nv - 1 loop
         Detail := Dof_Element (S, Fields, V);
         if Detail /= Success then
            return Detail;
         end if;
         pragma Loop_Invariant (for all K in 0 .. V => Dof_Element (S, Fields, K) = Success);
      end loop;
      return Success;
   end Dof_Status;

   function Actuator_Element (S : MJ.Models.Sizes; Fields : MJ.Models.Actuator_Arrays; A : Natural) return Status with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Actuator_Layout_OK (S, Fields)
       and then A < S.Nactuator,
     Post => (Actuator_Element'Result = Success) = (Fields.Actuator_Trntype (A) in 0 .. 1 and then Fields.Actuator_Dyntype (A) = 0
          and then Fields.Actuator_Gaintype (A) = 0 and then Fields.Actuator_Biastype (A) in 0 .. 1
          and then Fields.Actuator_Ctrlnum (A) = 1 and then Fields.Actuator_Outnum (A) = 1
          and then Fields.Actuator_Ctrladr (A) = A and then Fields.Actuator_Outadr (A) = A
          and then Fields.Actuator_Actnum (A) = 0 and then Fields.Actuator_Delay (A) = 0.0
          and then Fields.Actuator_Damping (A) = 0.0 and then Fields.Actuator_Dampingpoly (2 * A) = 0.0
          and then Fields.Actuator_Dampingpoly (2 * A + 1) = 0.0 and then Fields.Actuator_Armature (A) = 0.0)
   is
   begin
         if Fields.Actuator_Trntype (A) not in 0 .. 1
           or else Fields.Actuator_Dyntype (A) /= 0
           or else Fields.Actuator_Gaintype (A) /= 0
           or else Fields.Actuator_Biastype (A) not in 0 .. 1
           or else Fields.Actuator_Ctrlnum (A) /= 1
           or else Fields.Actuator_Outnum (A) /= 1
           or else Fields.Actuator_Ctrladr (A) /= A
           or else Fields.Actuator_Outadr (A) /= A
           or else Fields.Actuator_Actnum (A) /= 0
           or else Fields.Actuator_Delay (A) /= 0.0
           or else Fields.Actuator_Damping (A) /= 0.0
           or else Fields.Actuator_Dampingpoly (2 * A) /= 0.0
           or else Fields.Actuator_Dampingpoly (2 * A + 1) /= 0.0
           or else Fields.Actuator_Armature (A) /= 0.0
         then
            return Unsupported_Actuator;
         end if;
      return Success;
   end Actuator_Element;

   function Actuator_Status (S : MJ.Models.Sizes; Fields : MJ.Models.Actuator_Arrays) return Status with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Actuator_Layout_OK (S, Fields),
     Post => (Actuator_Status'Result = Success) =
       (for all K in 0 .. S.Nactuator - 1 => Actuator_Element (S, Fields, K) = Success)
   is
      Detail : Status;
   begin
      for A in 0 .. S.Nactuator - 1 loop
         Detail := Actuator_Element (S, Fields, A);
         if Detail /= Success then
            return Detail;
         end if;
         pragma Loop_Invariant (for all K in 0 .. A => Actuator_Element (S, Fields, K) = Success);
      end loop;
      return Success;
   end Actuator_Status;

   function Creation_Inputs (M : MJ.Models.Model) return Boolean is
     (MJ.Models.Sizes_In_Range (M.S)
      and then MJ.Models.Body_Layout_OK (M.S, M.Bodies)
      and then MJ.Models.Joint_Layout_OK (M.S, M.Joints)
      and then MJ.Models.Dof_Layout_OK (M.S, M.Dofs)
      and then MJ.Models.Actuator_Layout_OK (M.S, M.Actuators)
      and then MJ.Models.Qpos_Layout_OK (M.S, M.Qpos)
      and then M.S.Nbody in 1 .. Max_Bodies and then M.S.Nv <= Max_Dofs
      and then M.S.Nq = M.S.Nv and then M.S.Njnt = M.S.Nv
      and then M.S.Nactuator <= Max_Actuators
      and then M.S.Nu = M.S.Nactuator and then M.S.Nout = M.S.Nactuator
      and then M.Opt.Disableflags >= 0 and then M.Opt.Timestep in Nonneg_Tier0);

   function Model_Status (M : MJ.Models.Model) return Status with
     Global => null,
     Post => (if Model_Status'Result = Success then Creation_Inputs (M) and then MJ.Models.Valid_Layout (M)
       and then MJ.Models.Validity.Is_Valid (M)
       and then MJ.Models.Sizes_In_Range (M.S)
       and then MJ.Models.Body_Layout_OK (M.S, M.Bodies)
       and then MJ.Models.Joint_Layout_OK (M.S, M.Joints)
       and then MJ.Models.Dof_Layout_OK (M.S, M.Dofs)
       and then MJ.Models.Actuator_Layout_OK (M.S, M.Actuators)
       and then MJ.Models.Qpos_Layout_OK (M.S, M.Qpos)
       and then M.S.Nbody in 1 .. Max_Bodies and then M.S.Nv <= Max_Dofs
       and then M.S.Nq = M.S.Nv and then M.S.Njnt = M.S.Nv
       and then M.S.Nactuator <= Max_Actuators
       and then M.S.Nu = M.S.Nactuator and then M.S.Nout = M.S.Nactuator
       and then M.Opt.Disableflags >= 0 and then M.Opt.Timestep in Nonneg_Tier0)
   is
      --  The validator is proved separately. Its Boolean result remains in
      --  the contract; expanding every physical clause is unnecessary here.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Is_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Sizes_In_Range);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Body_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Joint_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Dof_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Actuator_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Qpos_Layout_OK);
      Flags : constant Integer := M.Opt.Disableflags;
      Detail : Status;
   begin
      if not MJ.Models.Valid_Layout (M) then
         return Invalid_Model;
      end if;
      if not MJ.Models.Sizes_In_Range (M.S)
        or else not MJ.Models.Body_Layout_OK (M.S, M.Bodies)
        or else not MJ.Models.Joint_Layout_OK (M.S, M.Joints)
        or else not MJ.Models.Dof_Layout_OK (M.S, M.Dofs)
        or else not MJ.Models.Actuator_Layout_OK (M.S, M.Actuators)
        or else not MJ.Models.Qpos_Layout_OK (M.S, M.Qpos)
      then
         return Invalid_Model;
      end if;
      if M.S.Nbody = 0 or else M.Opt.Timestep not in Nonneg_Tier0 then
         return Invalid_Model;
      end if;
      if M.S.Nv > Max_Dofs or else M.S.Nbody > Max_Bodies
        or else M.S.Nactuator > Max_Actuators
      then
         return Capacity_Exceeded;
      end if;
      if M.S.Nu /= M.S.Nactuator or else M.S.Nout /= M.S.Nactuator then
         return Unsupported_Actuator;
      end if;
      if not MJ.Models.Validity.Is_Valid (M) then
         return Invalid_Model;
      end if;
      if Flags < 0 then
         return Invalid_Model;
      end if;
      --  This entry point is deliberately an unconstrained simulator. Requiring
      --  the reference flag avoids silently dropping enabled contacts/limits.
      if not Has_Flag (Flags, Dsbl_Constraint)
        or else M.Opt.Integrator /= 0 or else M.Opt.Enableflags /= 0
        or else M.Opt.Disableactuator /= 0
        or else M.S.Ntendon /= 0 or else M.S.Nflex /= 0 or else M.S.Nplugin /= 0
        or else M.S.Nmocap /= 0 or else M.S.Na /= 0 or else M.S.Nhistory /= 0
        or else M.Opt.Density /= 0.0 or else M.Opt.Viscosity /= 0.0
        or else M.Flg_Adhesion
      then
         return Unsupported_Feature;
      end if;
      Detail := Body_Status (M.S, M.Bodies);
      if Detail /= Success then
         return Detail;
      end if;
      Detail := Joint_Status (M.S, M.Joints);
      if Detail /= Success then
         return Detail;
      end if;
      if M.S.Nq /= M.S.Nv or else M.S.Njnt /= M.S.Nv then
         return Invalid_Model;
      end if;
      Detail := Dof_Status (M.S, M.Dofs);
      if Detail /= Success then
         return Detail;
      end if;
      Detail := Actuator_Status (M.S, M.Actuators);
      if Detail /= Success then
         return Detail;
      end if;
      return Success;
   end Model_Status;

   procedure Set_Dimensions (D : in out Simulation; S : MJ.Models.Sizes) with
     Global => null,
     Pre => Is_Empty (D) and then S.Nq <= Max_Dofs and then S.Nv <= Max_Dofs
       and then S.Njnt <= Max_Dofs and then S.Nbody <= Max_Bodies
       and then S.Nu <= Max_Actuators and then S.Nactuator <= Max_Actuators
       and then S.Nout <= Max_Actuators,
     Post => Is_Empty (D) and then D.Nq = S.Nq and then D.Nv = S.Nv
       and then D.Nj = S.Njnt and then D.Nb = S.Nbody and then D.Nu = S.Nu
       and then D.Na = S.Nactuator and then D.No = S.Nout
   is
   begin
      D.Nq := S.Nq; D.Nv := S.Nv; D.Nu := S.Nu;
      D.Nb := S.Nbody; D.Nj := S.Njnt; D.Na := S.Nactuator; D.No := S.Nout;
   end Set_Dimensions;

   procedure Set_Options (D : in out Simulation; M : MJ.Models.Model) with
     Global => null,
     Pre => Is_Empty (D) and then M.Opt.Disableflags >= 0
       and then M.Opt.Timestep in Nonneg_Tier0,
     Post => Is_Empty (D) and then Shape (D) = Shape (D)'Old
       and then D.Nj = D.Nj'Old and then D.Na = D.Na'Old and then D.No = D.No'Old
       and then D.Timestep = M.Opt.Timestep and then D.Gravity = Read_Vector (M.Opt.Gravity, 0)
       and then D.Gravity_Enabled = not Has_Flag (M.Opt.Disableflags, Dsbl_Gravity)
       and then D.Spring_Enabled = not Has_Flag (M.Opt.Disableflags, Dsbl_Spring)
       and then D.Damper_Enabled = not Has_Flag (M.Opt.Disableflags, Dsbl_Damper)
       and then D.Actuation_Enabled = not Has_Flag (M.Opt.Disableflags, Dsbl_Actuation)
       and then D.Clamp_Control = not Has_Flag (M.Opt.Disableflags, Dsbl_Clampctrl)
       and then D.Implicit_Damping =
         (not Has_Flag (M.Opt.Disableflags, Dsbl_Eulerdamp) and then D.Damper_Enabled)
   is
      Flags : constant Integer := M.Opt.Disableflags;
   begin
      D.Timestep := M.Opt.Timestep;
      D.Gravity := Read_Vector (M.Opt.Gravity, 0);
      D.Gravity_Enabled := not Has_Flag (Flags, Dsbl_Gravity);
      D.Spring_Enabled := not Has_Flag (Flags, Dsbl_Spring);
      D.Damper_Enabled := not Has_Flag (Flags, Dsbl_Damper);
      D.Actuation_Enabled := not Has_Flag (Flags, Dsbl_Actuation);
      D.Clamp_Control := not Has_Flag (Flags, Dsbl_Clampctrl);
      D.Implicit_Damping := not Has_Flag (Flags, Dsbl_Eulerdamp) and then D.Damper_Enabled;
   end Set_Options;

   procedure Allocate_State (B : in out State_Buffers; Nq, Nv, Nu : Natural) with
     Global => null, Pre => Nq <= Max_Dofs and then Nv <= Max_Dofs and then Nu <= Max_Actuators
       and then B.Qpos = null and then B.Qvel = null and then B.Ctrl = null and then B.Applied = null,
     Post => Has_Real_Layout (B.Qpos, Nq) and then (for all X of B.Qpos.all => X = 0.0) and then Has_Real_Layout (B.Qvel, Nv) and then (for all X of B.Qvel.all => X = 0.0) and then Has_Real_Layout (B.Ctrl, Nu) and then (for all X of B.Ctrl.all => X = 0.0) and then Has_Real_Layout (B.Applied, Nv) and then (for all X of B.Applied.all => X = 0.0)
   is
   begin
      B.Qpos := Zero_Array (Nq);
      B.Qvel := Zero_Array (Nv);
      B.Ctrl := Zero_Array (Nu);
      B.Applied := Zero_Array (Nv);
   end Allocate_State;

   procedure Allocate_Kinematic (B : in out Kinematic_Buffers; Nb, Nj, Nv : Natural) with
     Global => null, Pre => Nb <= Max_Bodies and then Nj <= Max_Dofs and then Nv <= Max_Dofs
       and then B.Bodies = null and then B.Joints = null and then B.Linear_Jacobian = null and then B.Angular_Jacobian = null,
     Post => B.Bodies /= null and then B.Bodies'First = 0 and then B.Bodies'Length = Nb and then (for all X of B.Bodies.all => X = (others => <>)) and then B.Joints /= null and then B.Joints'First = 0 and then B.Joints'Length = Nj and then (for all X of B.Joints.all => X = (others => <>)) and then Has_Real_Layout (B.Linear_Jacobian, 3 * Nb * Nv) and then (for all X of B.Linear_Jacobian.all => X = 0.0) and then Has_Real_Layout (B.Angular_Jacobian, 3 * Nb * Nv) and then (for all X of B.Angular_Jacobian.all => X = 0.0)
   is
   begin
      B.Bodies := new Body_State_Array (0 .. Integer (Nb) - 1);
      B.Joints := new Joint_State_Array (0 .. Integer (Nj) - 1);
      B.Linear_Jacobian := Zero_Array (3 * Nb * Nv);
      B.Angular_Jacobian := Zero_Array (3 * Nb * Nv);
   end Allocate_Kinematic;

   procedure Allocate_Dynamics (B : in out Force_Buffers; Nv : Natural) with
     Global => null, Pre => Nv <= Max_Dofs
       and then B.Mass = null and then B.Bias = null and then B.Gravity = null and then B.Passive = null and then B.Actuator = null and then B.Acceleration = null and then B.Total = null,
     Post => Has_Real_Layout (B.Mass, Nv * Nv) and then (for all X of B.Mass.all => X = 0.0) and then Has_Real_Layout (B.Bias, Nv) and then (for all X of B.Bias.all => X = 0.0) and then Has_Real_Layout (B.Gravity, Nv) and then (for all X of B.Gravity.all => X = 0.0) and then Has_Real_Layout (B.Passive, Nv) and then (for all X of B.Passive.all => X = 0.0) and then Has_Real_Layout (B.Actuator, Nv) and then (for all X of B.Actuator.all => X = 0.0) and then Has_Real_Layout (B.Acceleration, Nv) and then (for all X of B.Acceleration.all => X = 0.0) and then Has_Real_Layout (B.Total, Nv) and then (for all X of B.Total.all => X = 0.0)
   is
   begin
      B.Mass := Zero_Array (Nv * Nv);
      B.Bias := Zero_Array (Nv);
      B.Gravity := Zero_Array (Nv);
      B.Passive := Zero_Array (Nv);
      B.Actuator := Zero_Array (Nv);
      B.Acceleration := Zero_Array (Nv);
      B.Total := Zero_Array (Nv);
   end Allocate_Dynamics;

   procedure Allocate_Actuators (B : in out Actuator_Buffers; No : Natural) with
     Global => null, Pre => No <= Max_Actuators
       and then B.Length = null and then B.Velocity = null and then B.Force = null,
     Post => Has_Real_Layout (B.Length, No) and then (for all X of B.Length.all => X = 0.0) and then Has_Real_Layout (B.Velocity, No) and then (for all X of B.Velocity.all => X = 0.0) and then Has_Real_Layout (B.Force, No) and then (for all X of B.Force.all => X = 0.0)
   is
   begin
      B.Length := Zero_Array (No);
      B.Velocity := Zero_Array (No);
      B.Force := Zero_Array (No);
   end Allocate_Actuators;

   procedure Allocate_Scratch (B : in out Scratch_Buffers; Nq, Nv : Natural) with
     Global => null, Pre => Nq <= Max_Dofs and then Nv <= Max_Dofs
       and then B.Factor = null and then B.Rhs = null and then B.Solution = null and then B.Next_Qpos = null and then B.Next_Qvel = null and then B.Condition_Sums = null,
     Post => Has_Real_Layout (B.Factor, Nv * Nv) and then (for all X of B.Factor.all => X = 0.0) and then Has_Real_Layout (B.Rhs, Nv) and then (for all X of B.Rhs.all => X = 0.0) and then Has_Real_Layout (B.Solution, Nv) and then (for all X of B.Solution.all => X = 0.0) and then Has_Real_Layout (B.Next_Qpos, Nq) and then (for all X of B.Next_Qpos.all => X = 0.0) and then Has_Real_Layout (B.Next_Qvel, Nv) and then (for all X of B.Next_Qvel.all => X = 0.0) and then Has_Real_Layout (B.Condition_Sums, Nv) and then (for all X of B.Condition_Sums.all => X = 0.0)
   is
   begin
      B.Factor := Zero_Array (Nv * Nv);
      B.Rhs := Zero_Array (Nv);
      B.Solution := Zero_Array (Nv);
      B.Next_Qpos := Zero_Array (Nq);
      B.Next_Qvel := Zero_Array (Nv);
      B.Condition_Sums := Zero_Array (Nv);
   end Allocate_Scratch;

   function Matches_Body
     (S : MJ.Models.Sizes; Source : MJ.Models.Body_Arrays;
      Index : Natural; Item : Body_Parameters) return Boolean is
     (Unit_Quaternion (Item.Orientation) and then Unit_Quaternion (Item.Inertial_Orientation)
       and then Bounded (Item.Position, Max_Val) and then Bounded (Item.Inertial_Position, Max_Val)
       and then Bounded (Item.Inertia, Max_Val)
       and then Item.Parent = Source.Body_Parentid (Index)
       and then Item.First_Joint = Source.Body_Jntadr (Index) and then Item.Joint_Count = Source.Body_Jntnum (Index)
       and then Item.Position = Read_Vector (Source.Body_Pos.all, 3 * Index)
       and then Item.Inertial_Position = Read_Vector (Source.Body_Ipos.all, 3 * Index)
       and then Item.Inertia = Read_Vector (Source.Body_Inertia.all, 3 * Index)
       and then Item.Mass = Source.Body_Mass (Index)) with Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Body_Layout_OK (S, Source)
       and then S.Nbody <= Max_Bodies and then Index < S.Nbody;

   procedure Read_Body_Config
     (S : MJ.Models.Sizes; Source : MJ.Models.Body_Arrays; Index : Natural;
      Item : out Body_Parameters; Ok : out Boolean) with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Body_Layout_OK (S, Source)
       and then S.Nbody <= Max_Bodies and then Index < S.Nbody,
     Post => MJ.Models.Body_Layout_OK (S, Source)
       and then (if Ok then Matches_Body (S, Source, Index, Item))
   is
      Normal : Boolean;
      Position : constant Vector := Read_Vector (Source.Body_Pos.all, 3 * Index);
      Ipos : constant Vector := Read_Vector (Source.Body_Ipos.all, 3 * Index);
      Inertia : constant Vector := Read_Vector (Source.Body_Inertia.all, 3 * Index);
   begin
      Item := (others => <>); Ok := False;
      if Source.Body_Parentid (Index) < 0 or else Source.Body_Jntnum (Index) < 0
        or else Source.Body_Mass (Index) not in Nonneg_Tier0
        or else not Bounded (Position, Max_Val) or else not Bounded (Ipos, Max_Val)
        or else not Bounded (Inertia, Max_Val)
      then
         return;
      end if;
      Item := (Parent => Source.Body_Parentid (Index), First_Joint => Source.Body_Jntadr (Index),
        Joint_Count => Source.Body_Jntnum (Index), Position => Position, Inertial_Position => Ipos,
        Orientation => Read_Quaternion (Source.Body_Quat.all, 4 * Index),
        Inertial_Orientation => Read_Quaternion (Source.Body_Iquat.all, 4 * Index),
        Mass => Source.Body_Mass (Index), Inertia => Inertia);
      Normalize (Item.Orientation, Normal);
      if not Normal then return; end if;
      Normalize (Item.Inertial_Orientation, Normal);
      if not Normal then return; end if;
      Ok := True;
   end Read_Body_Config;

   function Matches_Joint
     (S : MJ.Models.Sizes; Source : MJ.Models.Joint_Arrays; Dofs : MJ.Models.Dof_Arrays; Positions : MJ.Models.Qpos_Arrays;
      Index : Natural; Item : Joint_Parameters) return Boolean is
     (Unit_Vector (Item.Direction) and then Bounded (Item.Anchor, Max_Val)
       and then Item.Kind = (if Source.Jnt_Type (Index) = 2 then Slide_Joint else Hinge_Joint)
       and then Item.Body_Id = Source.Jnt_Bodyid (Index)
       and then Item.Qadr = Source.Jnt_Qposadr (Index) and then Item.Qadr < S.Nq
       and then Item.Vadr = Source.Jnt_Dofadr (Index) and then Item.Vadr < S.Nv
       and then Item.Anchor = Read_Vector (Source.Jnt_Pos.all, 3 * Index)
       and then Item.Reference = Positions.Qpos0 (Item.Qadr)
       and then Item.Spring_Reference = Positions.Qpos_Spring (Item.Qadr)
       and then Item.Stiffness = Source.Jnt_Stiffness (Index)
       and then Item.Damping = Dofs.Dof_Damping (Item.Vadr)
       and then Item.Armature = Dofs.Dof_Armature (Item.Vadr)) with Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Joint_Layout_OK (S, Source)
       and then MJ.Models.Dof_Layout_OK (S, Dofs) and then MJ.Models.Qpos_Layout_OK (S, Positions)
       and then S.Njnt <= Max_Dofs and then Index < S.Njnt;

   procedure Read_Joint_Config
     (S : MJ.Models.Sizes; Source : MJ.Models.Joint_Arrays; Dofs : MJ.Models.Dof_Arrays;
      Positions : MJ.Models.Qpos_Arrays; Index : Natural; Item : out Joint_Parameters; Ok : out Boolean) with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Joint_Layout_OK (S, Source)
       and then MJ.Models.Dof_Layout_OK (S, Dofs) and then MJ.Models.Qpos_Layout_OK (S, Positions)
       and then S.Njnt <= Max_Dofs and then Index < S.Njnt,
     Post => MJ.Models.Joint_Layout_OK (S, Source) and then MJ.Models.Dof_Layout_OK (S, Dofs) and then MJ.Models.Qpos_Layout_OK (S, Positions)
       and then (if Ok then Matches_Joint (S, Source, Dofs, Positions, Index, Item))
   is
      Q : constant Integer := Source.Jnt_Qposadr (Index);
      V : constant Integer := Source.Jnt_Dofadr (Index);
      Anchor : constant Vector := Read_Vector (Source.Jnt_Pos.all, 3 * Index);
      Normal : Boolean;
   begin
      Item := (others => <>); Ok := False;
      if Q not in 0 .. S.Nq - 1 or else V not in 0 .. S.Nv - 1
        or else Source.Jnt_Bodyid (Index) < 0 or else not Bounded (Anchor, Max_Val)
        or else Source.Jnt_Stiffness (Index) not in Nonneg_Tier0
        or else Dofs.Dof_Damping (V) not in Nonneg_Tier0 or else Dofs.Dof_Armature (V) not in Nonneg_Tier0
        or else Positions.Qpos0 (Q) not in Tier0_Real or else Positions.Qpos_Spring (Q) not in Tier0_Real
      then
         return;
      end if;
      Item := (Kind => (if Source.Jnt_Type (Index) = 2 then Slide_Joint else Hinge_Joint),
        Body_Id => Source.Jnt_Bodyid (Index), Qadr => Q, Vadr => V, Anchor => Anchor,
        Direction => Read_Vector (Source.Jnt_Axis.all, 3 * Index), Reference => Positions.Qpos0 (Q),
        Spring_Reference => Positions.Qpos_Spring (Q), Stiffness => Source.Jnt_Stiffness (Index),
        Damping => Dofs.Dof_Damping (V), Armature => Dofs.Dof_Armature (V));
      Normalize (Item.Direction, Normal);
      if not Normal then return; end if;
      Ok := True;
   end Read_Joint_Config;

   function Matches_Actuator
     (S : MJ.Models.Sizes; Source : MJ.Models.Actuator_Arrays;
      Index : Natural; Item : Actuator_Parameters) return Boolean is
     (Bounded (Item.Bias, Max_Val)
       and then Item.Joint_Id = Source.Actuator_Trnid (2 * Index)
       and then Item.Control_Id = Source.Actuator_Ctrladr (Index) and then Item.Control_Id < S.Nu
       and then Item.Output_Id = Source.Actuator_Outadr (Index) and then Item.Output_Id < S.Nout
       and then Item.Gear = Source.Actuator_Gear (6 * Item.Output_Id)
       and then Item.Gain = Source.Actuator_Gainprm (10 * Index)
       and then Item.Bias = (if Source.Actuator_Biastype (Index) = 1
         then Read_Vector (Source.Actuator_Biasprm.all, 10 * Index) else Zero)
       and then Item.Control_Limited = (Source.Actuator_Ctrllimited (Item.Control_Id) /= 0)
       and then Item.Force_Limited = (Source.Actuator_Forcelimited (Index) /= 0)
       and then Item.Control_Lower = Source.Actuator_Ctrlrange (2 * Item.Control_Id)
       and then Item.Control_Upper = Source.Actuator_Ctrlrange (2 * Item.Control_Id + 1)
       and then Item.Force_Lower = Source.Actuator_Forcerange (2 * Index)
       and then Item.Force_Upper = Source.Actuator_Forcerange (2 * Index + 1)) with Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Actuator_Layout_OK (S, Source)
       and then S.Nactuator <= Max_Actuators and then Index < S.Nactuator;

   procedure Read_Actuator_Config
     (S : MJ.Models.Sizes; Source : MJ.Models.Actuator_Arrays; Index : Natural;
      Item : out Actuator_Parameters; Ok : out Boolean) with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Actuator_Layout_OK (S, Source)
       and then S.Nactuator <= Max_Actuators and then Index < S.Nactuator,
     Post => MJ.Models.Actuator_Layout_OK (S, Source)
       and then (if Ok then Matches_Actuator (S, Source, Index, Item))
   is
      U : constant Integer := Source.Actuator_Ctrladr (Index);
      O : constant Integer := Source.Actuator_Outadr (Index);
      Bias : constant Vector := (if Source.Actuator_Biastype (Index) = 1
        then Read_Vector (Source.Actuator_Biasprm.all, 10 * Index) else Zero);
   begin
      Item := (others => <>); Ok := False;
      if U not in 0 .. S.Nu - 1 or else O not in 0 .. S.Nout - 1
        or else Source.Actuator_Trnid (2 * Index) < 0 or else not Bounded (Bias, Max_Val)
        or else Source.Actuator_Gear (6 * O) not in Tier0_Real
        or else Source.Actuator_Gainprm (10 * Index) not in Tier0_Real
        or else Source.Actuator_Ctrlrange (2 * U) not in Tier0_Real
        or else Source.Actuator_Ctrlrange (2 * U + 1) not in Tier0_Real
        or else Source.Actuator_Forcerange (2 * Index) not in Tier0_Real
        or else Source.Actuator_Forcerange (2 * Index + 1) not in Tier0_Real
      then
         return;
      end if;
      Item := (Joint_Id => Source.Actuator_Trnid (2 * Index), Control_Id => U, Output_Id => O,
        Gear => Source.Actuator_Gear (6 * O), Gain => Source.Actuator_Gainprm (10 * Index), Bias => Bias,
        Control_Limited => Source.Actuator_Ctrllimited (U) /= 0,
        Force_Limited => Source.Actuator_Forcelimited (Index) /= 0,
        Control_Lower => Source.Actuator_Ctrlrange (2 * U), Control_Upper => Source.Actuator_Ctrlrange (2 * U + 1),
        Force_Lower => Source.Actuator_Forcerange (2 * Index), Force_Upper => Source.Actuator_Forcerange (2 * Index + 1));
      Ok := True;
   end Read_Actuator_Config;

   procedure Copy_Bodies
     (S : MJ.Models.Sizes; Source : MJ.Models.Body_Arrays;
      P : out Body_Parameter_Access; Ok : out Boolean) with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Body_Layout_OK (S, Source)
       and then S.Nbody <= Max_Bodies,
     Post => MJ.Models.Body_Layout_OK (S, Source)

       and then P /= null and then P'First = 0 and then P'Last = S.Nbody - 1
       and then (if Ok then (for all I in P'Range => Matches_Body (S, Source, I, P (I))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Matches_Body);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Sizes_In_Range);
   begin
      P := new Body_Parameter_Array (0 .. S.Nbody - 1);
      for Index in P'Range loop
         Read_Body_Config (S, Source, Index, P (Index), Ok);
         if not Ok then return; end if;
         pragma Loop_Invariant (MJ.Models.Body_Layout_OK (S, Source)
);
         pragma Loop_Invariant (for all I in P'First .. Index => Matches_Body (S, Source, I, P (I)));
      end loop;
      Ok := True;
   end Copy_Bodies;

   procedure Copy_Joints
     (S : MJ.Models.Sizes; Source : MJ.Models.Joint_Arrays; Dofs : MJ.Models.Dof_Arrays; Positions : MJ.Models.Qpos_Arrays;
      P : out Joint_Parameter_Access; Ok : out Boolean) with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Joint_Layout_OK (S, Source)
       and then MJ.Models.Dof_Layout_OK (S, Dofs) and then MJ.Models.Qpos_Layout_OK (S, Positions)
       and then S.Njnt <= Max_Dofs,
     Post => MJ.Models.Joint_Layout_OK (S, Source) and then MJ.Models.Dof_Layout_OK (S, Dofs) and then MJ.Models.Qpos_Layout_OK (S, Positions)

       and then P /= null and then P'First = 0 and then P'Last = S.Njnt - 1
       and then (if Ok then (for all I in P'Range => Matches_Joint (S, Source, Dofs, Positions, I, P (I))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Matches_Joint);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Sizes_In_Range);
   begin
      P := new Joint_Parameter_Array (0 .. S.Njnt - 1);
      for Index in P'Range loop
         Read_Joint_Config (S, Source, Dofs, Positions, Index, P (Index), Ok);
         if not Ok then return; end if;
         pragma Loop_Invariant (MJ.Models.Joint_Layout_OK (S, Source) and then MJ.Models.Dof_Layout_OK (S, Dofs) and then MJ.Models.Qpos_Layout_OK (S, Positions)
);
         pragma Loop_Invariant (for all I in P'First .. Index => Matches_Joint (S, Source, Dofs, Positions, I, P (I)));
      end loop;
      Ok := True;
   end Copy_Joints;

   procedure Copy_Actuators
     (S : MJ.Models.Sizes; Source : MJ.Models.Actuator_Arrays;
      P : out Actuator_Parameter_Access; Ok : out Boolean) with
     Global => null,
     Pre => MJ.Models.Sizes_In_Range (S) and then MJ.Models.Actuator_Layout_OK (S, Source)
       and then S.Nactuator <= Max_Actuators,
     Post => MJ.Models.Actuator_Layout_OK (S, Source)

       and then P /= null and then P'First = 0 and then P'Last = S.Nactuator - 1
       and then (if Ok then (for all I in P'Range => Matches_Actuator (S, Source, I, P (I))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Matches_Actuator);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Sizes_In_Range);
   begin
      P := new Actuator_Parameter_Array (0 .. S.Nactuator - 1);
      for Index in P'Range loop
         Read_Actuator_Config (S, Source, Index, P (Index), Ok);
         if not Ok then return; end if;
         pragma Loop_Invariant (MJ.Models.Actuator_Layout_OK (S, Source)
);
         pragma Loop_Invariant (for all I in P'First .. Index => Matches_Actuator (S, Source, I, P (I)));
      end loop;
      Ok := True;
   end Copy_Actuators;

   procedure Initialize (M : MJ.Models.Model; D : in out Simulation; Result : out Status) with
     Global => null, Pre => Is_Empty (D) and then Creation_Inputs (M),
     Post => (if Result = Success then Is_Ready (D) and then At_Reset_State (D)
        and then Time (D) = 0.0 and then not Positions_Current (D) and then not Forces_Current (D)
        and then Shape (D) = Dimensions'(M.S.Nq, M.S.Nv, M.S.Nu, M.S.Nbody)
      else Is_Empty (D))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", At_Reset_State);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Sizes_In_Range);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Matches_Body);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Matches_Joint);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Matches_Actuator);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Body_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Joint_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Dof_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Actuator_Layout_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Qpos_Layout_OK);
      Normal : Boolean;
   begin
      Set_Dimensions (D, M.S);
      Set_Options (D, M);

      Copy_Bodies (M.S, M.Bodies, D.Body_Config, Normal);
      if not Normal then Free (D); Result := Invalid_Model; return; end if;
      Copy_Joints (M.S, M.Joints, M.Dofs, M.Qpos, D.Joint_Config, Normal);
      if not Normal then Free (D); Result := Invalid_Model; return; end if;
      Copy_Actuators (M.S, M.Actuators, D.Actuator_Config, Normal);
      if not Normal then Free (D); Result := Invalid_Model; return; end if;
      Allocate_State (D.State, D.Nq, D.Nv, D.Nu);
      Allocate_Kinematic (D.Kinematic, D.Nb, D.Nj, D.Nv);
      Allocate_Dynamics (D.Dynamics, D.Nv);
      Allocate_Actuators (D.Actuators, D.No);
      Allocate_Scratch (D.Scratch, D.Nq, D.Nv);
      D.Allocated := True;
      if not Is_Ready (D) then
         Free (D);
         Result := Invalid_Model;
         return;
      end if;
      Reset (D, Result);
   end Initialize;

   procedure Create (M : MJ.Models.Model; D : in out Simulation; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Is_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Creation_Inputs);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", At_Reset_State);
   begin
      if not Is_Empty (D) then Result := Already_Allocated; return; end if;
      Result := Model_Status (M);
      if Result /= Success then return; end if;
      Initialize (M, D, Result);
   end Create;

   procedure Free_State (S : in out State_Buffers) with
     Global => null, Post => S.Qpos = null
       and then S.Qvel = null
       and then S.Ctrl = null
       and then S.Applied = null
   is
   begin
      Free_Real (S.Qpos); Free_Real (S.Qvel);
      Free_Real (S.Ctrl); Free_Real (S.Applied);
   end Free_State;
   procedure Free_Kinematic (K : in out Kinematic_Buffers) with
     Global => null, Post => K.Bodies = null
       and then K.Joints = null
       and then K.Linear_Jacobian = null
       and then K.Angular_Jacobian = null
   is
   begin
      Free_Body_State (K.Bodies); Free_Joint_State (K.Joints);
      Free_Real (K.Linear_Jacobian); Free_Real (K.Angular_Jacobian);
   end Free_Kinematic;
   procedure Free_Forces (F : in out Force_Buffers) with
     Global => null, Post => F.Mass = null
       and then F.Bias = null
       and then F.Gravity = null
       and then F.Passive = null
       and then F.Actuator = null
       and then F.Acceleration = null
       and then F.Total = null
   is
   begin
      Free_Real (F.Mass); Free_Real (F.Bias); Free_Real (F.Gravity);
      Free_Real (F.Passive); Free_Real (F.Actuator); Free_Real (F.Acceleration); Free_Real (F.Total);
   end Free_Forces;
   procedure Free_Actuators (A : in out Actuator_Buffers) with
     Global => null, Post => A.Length = null
       and then A.Velocity = null
       and then A.Force = null
   is
   begin
      Free_Real (A.Length); Free_Real (A.Velocity); Free_Real (A.Force);
   end Free_Actuators;
   procedure Free_Scratch (S : in out Scratch_Buffers) with
     Global => null, Post => S.Factor = null
       and then S.Rhs = null
       and then S.Solution = null
       and then S.Next_Qpos = null
       and then S.Next_Qvel = null
       and then S.Condition_Sums = null
   is
   begin
      Free_Real (S.Factor); Free_Real (S.Rhs); Free_Real (S.Solution);
      Free_Real (S.Next_Qpos); Free_Real (S.Next_Qvel); Free_Real (S.Condition_Sums);
   end Free_Scratch;

   procedure Free (D : in out Simulation) is
   begin
      Free_Body_Config (D.Body_Config);
      Free_Joint_Config (D.Joint_Config);
      Free_Actuator_Config (D.Actuator_Config);
      Free_State (D.State);
      Free_Kinematic (D.Kinematic);
      Free_Forces (D.Dynamics);
      Free_Actuators (D.Actuators);
      Free_Scratch (D.Scratch);
      D.Allocated := False;
      D.Nq := 0; D.Nv := 0; D.Nu := 0; D.Nb := 0;
      D.Nj := 0; D.Na := 0; D.No := 0;
      D.Clock := 0.0;
      D.Timestep := 0.0;
      D.Gravity := Zero;
      Invalidate (D.Cache);
   end Free;

   procedure Clear_State (S : in out State_Buffers) with
     Global => null, Pre => S.Qpos /= null and then S.Qvel /= null and then S.Ctrl /= null and then S.Applied /= null,
     Post => S.Qpos /= null and then S.Qpos'First = S.Qpos'First'Old
       and then S.Qpos'Last = S.Qpos'Last'Old
       and then (for all X of S.Qpos.all => X = 0.0)
       and then S.Qvel /= null and then S.Qvel'First = S.Qvel'First'Old
       and then S.Qvel'Last = S.Qvel'Last'Old
       and then (for all X of S.Qvel.all => X = 0.0)
       and then S.Ctrl /= null and then S.Ctrl'First = S.Ctrl'First'Old
       and then S.Ctrl'Last = S.Ctrl'Last'Old
       and then (for all X of S.Ctrl.all => X = 0.0)
       and then S.Applied /= null and then S.Applied'First = S.Applied'First'Old
       and then S.Applied'Last = S.Applied'Last'Old
       and then (for all X of S.Applied.all => X = 0.0)
   is
   begin
      S.Qpos.all := [others => 0.0]; S.Qvel.all := [others => 0.0];
      S.Ctrl.all := [others => 0.0]; S.Applied.all := [others => 0.0];
   end Clear_State;
   procedure Clear_Kinematic (K : in out Kinematic_Buffers) with
     Global => null, Pre => K.Bodies /= null and then K.Joints /= null and then K.Linear_Jacobian /= null and then K.Angular_Jacobian /= null,
     Post => K.Bodies /= null and then K.Bodies'First = K.Bodies'First'Old
       and then K.Bodies'Last = K.Bodies'Last'Old
       and then (for all X of K.Bodies.all => X = Body_State'(others => <>))
       and then K.Joints /= null and then K.Joints'First = K.Joints'First'Old
       and then K.Joints'Last = K.Joints'Last'Old
       and then (for all X of K.Joints.all => X = Joint_State'(others => <>))
       and then K.Linear_Jacobian /= null and then K.Linear_Jacobian'First = K.Linear_Jacobian'First'Old
       and then K.Linear_Jacobian'Last = K.Linear_Jacobian'Last'Old
       and then (for all X of K.Linear_Jacobian.all => X = 0.0)
       and then K.Angular_Jacobian /= null and then K.Angular_Jacobian'First = K.Angular_Jacobian'First'Old
       and then K.Angular_Jacobian'Last = K.Angular_Jacobian'Last'Old
       and then (for all X of K.Angular_Jacobian.all => X = 0.0)
   is
   begin
      K.Bodies.all := [others => (others => <>)];
      K.Joints.all := [others => (others => <>)];
      K.Linear_Jacobian.all := [others => 0.0]; K.Angular_Jacobian.all := [others => 0.0];
   end Clear_Kinematic;
   procedure Clear_Forces (F : in out Force_Buffers) with
     Global => null, Pre => F.Mass /= null and then F.Bias /= null and then F.Gravity /= null and then F.Passive /= null and then F.Actuator /= null and then F.Acceleration /= null and then F.Total /= null,
     Post => F.Mass /= null and then F.Mass'First = F.Mass'First'Old
       and then F.Mass'Last = F.Mass'Last'Old
       and then (for all X of F.Mass.all => X = 0.0)
       and then F.Bias /= null and then F.Bias'First = F.Bias'First'Old
       and then F.Bias'Last = F.Bias'Last'Old
       and then (for all X of F.Bias.all => X = 0.0)
       and then F.Gravity /= null and then F.Gravity'First = F.Gravity'First'Old
       and then F.Gravity'Last = F.Gravity'Last'Old
       and then (for all X of F.Gravity.all => X = 0.0)
       and then F.Passive /= null and then F.Passive'First = F.Passive'First'Old
       and then F.Passive'Last = F.Passive'Last'Old
       and then (for all X of F.Passive.all => X = 0.0)
       and then F.Actuator /= null and then F.Actuator'First = F.Actuator'First'Old
       and then F.Actuator'Last = F.Actuator'Last'Old
       and then (for all X of F.Actuator.all => X = 0.0)
       and then F.Acceleration /= null and then F.Acceleration'First = F.Acceleration'First'Old
       and then F.Acceleration'Last = F.Acceleration'Last'Old
       and then (for all X of F.Acceleration.all => X = 0.0)
       and then F.Total /= null and then F.Total'First = F.Total'First'Old
       and then F.Total'Last = F.Total'Last'Old
       and then (for all X of F.Total.all => X = 0.0)
   is
   begin
      F.Mass.all := [others => 0.0]; F.Bias.all := [others => 0.0];
      F.Gravity.all := [others => 0.0]; F.Passive.all := [others => 0.0];
      F.Actuator.all := [others => 0.0]; F.Acceleration.all := [others => 0.0];
      F.Total.all := [others => 0.0];
   end Clear_Forces;
   procedure Clear_Actuators (A : in out Actuator_Buffers) with
     Global => null, Pre => A.Length /= null and then A.Velocity /= null and then A.Force /= null,
     Post => A.Length /= null and then A.Length'First = A.Length'First'Old
       and then A.Length'Last = A.Length'Last'Old
       and then (for all X of A.Length.all => X = 0.0)
       and then A.Velocity /= null and then A.Velocity'First = A.Velocity'First'Old
       and then A.Velocity'Last = A.Velocity'Last'Old
       and then (for all X of A.Velocity.all => X = 0.0)
       and then A.Force /= null and then A.Force'First = A.Force'First'Old
       and then A.Force'Last = A.Force'Last'Old
       and then (for all X of A.Force.all => X = 0.0)
   is
   begin
      A.Length.all := [others => 0.0]; A.Velocity.all := [others => 0.0]; A.Force.all := [others => 0.0];
   end Clear_Actuators;
   procedure Clear_Scratch (S : in out Scratch_Buffers) with
     Global => null, Pre => S.Factor /= null and then S.Rhs /= null and then S.Solution /= null and then S.Next_Qpos /= null and then S.Next_Qvel /= null and then S.Condition_Sums /= null,
     Post => S.Factor /= null and then S.Factor'First = S.Factor'First'Old
       and then S.Factor'Last = S.Factor'Last'Old
       and then (for all X of S.Factor.all => X = 0.0)
       and then S.Rhs /= null and then S.Rhs'First = S.Rhs'First'Old
       and then S.Rhs'Last = S.Rhs'Last'Old
       and then (for all X of S.Rhs.all => X = 0.0)
       and then S.Solution /= null and then S.Solution'First = S.Solution'First'Old
       and then S.Solution'Last = S.Solution'Last'Old
       and then (for all X of S.Solution.all => X = 0.0)
       and then S.Next_Qpos /= null and then S.Next_Qpos'First = S.Next_Qpos'First'Old
       and then S.Next_Qpos'Last = S.Next_Qpos'Last'Old
       and then (for all X of S.Next_Qpos.all => X = 0.0)
       and then S.Next_Qvel /= null and then S.Next_Qvel'First = S.Next_Qvel'First'Old
       and then S.Next_Qvel'Last = S.Next_Qvel'Last'Old
       and then (for all X of S.Next_Qvel.all => X = 0.0)
       and then S.Condition_Sums /= null and then S.Condition_Sums'First = S.Condition_Sums'First'Old
       and then S.Condition_Sums'Last = S.Condition_Sums'Last'Old
       and then (for all X of S.Condition_Sums.all => X = 0.0)
   is
   begin
      S.Factor.all := [others => 0.0]; S.Rhs.all := [others => 0.0];
      S.Solution.all := [others => 0.0]; S.Next_Qpos.all := [others => 0.0];
      S.Next_Qvel.all := [others => 0.0]; S.Condition_Sums.all := [others => 0.0];
   end Clear_Scratch;

   procedure Reset (D : in out Simulation; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      Invalidate (D.Cache);
      D.Clock := 0.0;
      Clear_State (D.State);
      D.State.Qpos.all :=
        [for J in 0 .. D.Nj - 1 => Real (D.Joint_Config (J).Reference)];
      Clear_Kinematic (D.Kinematic);
      Clear_Forces (D.Dynamics);
      Clear_Actuators (D.Actuators);
      Clear_Scratch (D.Scratch);
      pragma Assert (Is_Ready (D));
      pragma Assert (D.State.Qpos.all =
        Real_Array'[for J in 0 .. D.Nj - 1 => Real (D.Joint_Config (J).Reference)]);
      pragma Assert (D.State.Qvel.all = Real_Array'[0 .. Integer (D.Nv) - 1 => 0.0]);
      pragma Assert (D.State.Ctrl.all = Real_Array'[0 .. Integer (D.Nu) - 1 => 0.0]);
      pragma Assert (D.State.Applied.all = Real_Array'[0 .. Integer (D.Nv) - 1 => 0.0]);
      pragma Assert (At_Reset_State (D));
      Result := Success;
   end Reset;

   procedure Set_State
     (D : in out Simulation; Qpos, Qvel : State_Vector; New_Time : Nonneg_Tier0;
      Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      if Int64 (Qpos'Length) /= Int64 (D.Nq) or else Int64 (Qvel'Length) /= Int64 (D.Nv) then
         Result := Invalid_Size;
         return;
      end if;
      --  Array assignment slides the caller's index range onto the owned
      --  zero-based buffers, including inputs ending at Natural'Last.
      D.State.Qpos.all := As_Reals (Qpos);
      D.State.Qvel.all := As_Reals (Qvel);
      D.Clock := New_Time;
      Invalidate (D.Cache);
      pragma Assert (Is_Ready (D));
      pragma Assert
        (for all I in Qpos'Range => Position (D, I - Qpos'First) = Qpos (I));
      pragma Assert
        (for all I in Qvel'Range => Velocity (D, I - Qvel'First) = Qvel (I));
      Result := Success;
   end Set_State;

   procedure Set_Control
     (D : in out Simulation; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      elsif Index >= D.Nu then
         Result := Invalid_Index;
         return;
      end if;
      D.State.Ctrl (Index) := Value;
      D.Cache.Actuation_Valid := False;
      D.Cache.Force_Valid := False;
      pragma Assert (for all X of D.State.Ctrl.all => X in Tier0_Real);
      pragma Assert (Is_Ready (D));
      Result := Success;
   end Set_Control;

   procedure Set_Applied_Force
     (D : in out Simulation; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      elsif Index >= D.Nv then
         Result := Invalid_Index;
         return;
      end if;
      D.State.Applied (Index) := Value;
      D.Cache.Force_Valid := False;
      pragma Assert (for all X of D.State.Applied.all => X in Tier0_Real);
      pragma Assert (Is_Ready (D));
      Result := Success;
   end Set_Applied_Force;

   procedure Get_State
     (D : Simulation; Qpos, Qvel : out Real_Array; Current_Time : out Real; Result : out Status) is
   begin
      Qpos := [others => 0.0];
      Qvel := [others => 0.0];
      Current_Time := D.Clock;
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif Int64 (Qpos'Length) /= Int64 (D.Nq) or else Int64 (Qvel'Length) /= Int64 (D.Nv) then
         Result := Invalid_Size;
      else
         Qpos := D.State.Qpos.all;
         Qvel := D.State.Qvel.all;
         Result := Success;
      end if;
   end Get_State;

   procedure Get_Acceleration (D : Simulation; Qacc : out Real_Array; Result : out Status) is
   begin
      Qacc := [others => 0.0];
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif not D.Cache.Force_Valid then
         Result := Stale_Results;
      elsif Int64 (Qacc'Length) /= Int64 (D.Nv) then
         Result := Invalid_Size;
      else
         Qacc := D.Dynamics.Acceleration.all;
         Result := Success;
      end if;
   end Get_Acceleration;

   procedure Get_Mass_Matrix (D : Simulation; Dense : out Real_Array; Result : out Status) is
   begin
      Dense := [others => 0.0];
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif not D.Cache.Mass_Valid then
         Result := Stale_Results;
      elsif Int64 (Dense'Length) /= Int64 (D.Nv) * Int64 (D.Nv) then
         Result := Invalid_Size;
      else
         Dense := D.Dynamics.Mass.all;
         Result := Success;
      end if;
   end Get_Mass_Matrix;

   procedure Get_Forces
     (D : Simulation; Gravity, Bias, Passive, Actuation : out Real_Array; Result : out Status) is
   begin
      Gravity := [others => 0.0]; Bias := [others => 0.0];
      Passive := [others => 0.0]; Actuation := [others => 0.0];
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif not (D.Cache.Passive_Valid and then D.Cache.Actuation_Valid) then
         Result := Stale_Results;
      elsif Int64 (Gravity'Length) /= Int64 (D.Nv) or else Int64 (Bias'Length) /= Int64 (D.Nv)
        or else Int64 (Passive'Length) /= Int64 (D.Nv) or else Int64 (Actuation'Length) /= Int64 (D.Nv)
      then
         Result := Invalid_Size;
      else
         Gravity := D.Dynamics.Gravity.all; Bias := D.Dynamics.Bias.all;
         Passive := D.Dynamics.Passive.all; Actuation := D.Dynamics.Actuator.all;
         Result := Success;
      end if;
   end Get_Forces;

   procedure Get_Actuator_Outputs
     (D : Simulation; Length, Velocity, Force : out Real_Array; Result : out Status) is
   begin
      Length := [others => 0.0]; Velocity := [others => 0.0]; Force := [others => 0.0];
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif not D.Cache.Actuation_Valid then
         Result := Stale_Results;
      elsif Int64 (Length'Length) /= Int64 (D.No) or else Int64 (Velocity'Length) /= Int64 (D.No)
        or else Int64 (Force'Length) /= Int64 (D.No)
      then
         Result := Invalid_Size;
      else
         Length := D.Actuators.Length.all;
         Velocity := D.Actuators.Velocity.all;
         Force := D.Actuators.Force.all;
         Result := Success;
      end if;
   end Get_Actuator_Outputs;

   procedure Get_Body_Pose
     (D : Simulation; Body_Id : Natural; Position : out Vector;
      Orientation : out Quaternion; Result : out Status) is
   begin
      Position := Zero;
      Orientation := Identity_Quaternion;
      if not Is_Ready (D) then
         Result := Not_Allocated;
      elsif Body_Id >= D.Nb then
         Result := Invalid_Index;
      elsif not D.Cache.Pose_Valid then
         Result := Stale_Results;
      else
         Position := D.Kinematic.Bodies (Body_Id).Position;
         Orientation := D.Kinematic.Bodies (Body_Id).Orientation;
         Result := Success;
      end if;
   end Get_Body_Pose;
end MJ.Data;

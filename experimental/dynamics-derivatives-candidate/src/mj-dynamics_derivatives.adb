with Ada.Unchecked_Deallocation;
with Interfaces;
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Data.Forward;
with MJ.Data.Inverse;
with MJ.Data.Euler;
with MJ.BLAS;
with MJ.Data.Constrained.Derivative_Projection;
with MJ.Models.Validity;
with MJ.Smooth_Math;
with MJ.Manifold_Math;

package body MJ.Dynamics_Derivatives with SPARK_Mode is
   use MJ.Data;
   use type MJ.Data.Status;
   use type DK.Stencil;
   use type Interfaces.Unsigned_8;
   package C renames MJ.Data.Constrained;
   package SM renames MJ.Smooth_Math;
   package MM renames MJ.Manifold_Math;
   package E renames Ada.Numerics.Long_Elementary_Functions;
   procedure Release is new Ada.Unchecked_Deallocation (Matrix, Matrix_Access);

   function Ready (W : Workspace) return Boolean is (W.Initialized);
   function Shape (W : Workspace) return Dimensions is (W.Dims);
   function State_Dimension (W : Workspace) return Natural is
     (2 * W.Dims.Nv + W.Dims.Na);
   procedure Free (W : in out Workspace) is
      Result : Status;
   begin
      MJ.Data.Free (W.S); C.Free (W.C, Result);
      Release (W.TA); Release (W.TB); Release (W.TQ);
      Release (W.TV); Release (W.TAcc); Release (W.TM);
      W.Initialized := False; W.Dims := (others => 0); W.Nj := 0;
   end Free;

   procedure Create (M : in out MJ.Models.Model; W : in out Workspace;
                     Mode : Backend; Result : out Status) is
      Flags : constant Integer := M.Opt.Disableflags;
      Adhesion : constant Boolean := M.Flg_Adhesion;
      Count : Natural := 0;
   begin
      if W.Initialized then Result := Already_Allocated; return; end if;
      Free (W);
      Result := Invalid_Model;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      if M.S.Nv not in 1 .. Max_Dofs or else M.S.Njnt > Max_Dofs
        or else M.S.Nq > Max_Positions or else M.S.Nu > Max_Actuators
        or else M.S.Na > Max_Actuators then Result := Capacity_Exceeded; return; end if;
      if Mode = Smooth and then Flags mod 2 = 0 then
         Result := Unsupported_Feature; return;
      end if;
      if Mode = Smooth and then Adhesion then
         Result := Unsupported_Feature; return;
      end if;
      if Flags mod 2 = 0 then M.Opt.Disableflags := Flags + Dsbl_Constraint; end if;
      -- The constrained workspace owns contact-dependent body transmissions;
      -- its smooth scratch engine supplies only inertia and passive quantities.
      M.Flg_Adhesion := False;
      MJ.Data.Create (M, W.S, Result);
      M.Flg_Adhesion := Adhesion;
      M.Opt.Disableflags := Flags;
      if Result /= Success then Free (W); return; end if;
      if Mode = Constrained then
         C.Create (M, W.C, Result);
         if Result /= Success then Free (W); return; end if;
      end if;
      W.Mode := Mode; W.Nj := M.S.Njnt;
      W.Sparse := M.Opt.Jacobian = 1 or else (M.Opt.Jacobian = 2 and then M.S.Nv >= 60);
      W.Dims := (M.S.Nq, M.S.Nv, M.S.Nu, M.S.Na, M.S.NC);
      for J in 0 .. W.Nj - 1 loop
         W.Joints (J) := (M.Joints.Jnt_Type (J), M.Joints.Jnt_Qposadr (J),
                         M.Joints.Jnt_Dofadr (J));
      end loop;
      for U in 0 .. W.Dims.Nu - 1 loop
         W.Ctrl (U) := (M.Actuators.Actuator_Ctrllimited (U) /= 0,
           M.Actuators.Actuator_Ctrlrange (2 * U), M.Actuators.Actuator_Ctrlrange (2 * U + 1));
         if W.Ctrl (U).Low > W.Ctrl (U).High then
            Free (W); Result := Invalid_Model; return;
         end if;
      end loop;
      -- Copy the compiler's actual pattern, including simple diagonal bodies.
      -- Reconstructing it from dof_parentid would retain redundant free-body
      -- ancestors and disagree with m->M and the public inverseFD layout.
      for Row in 0 .. W.Dims.Nv - 1 loop
         if M.Sparse.M_Rowadr (Row) /= Count or else M.Sparse.M_Rownnz (Row) < 1 then
            Free (W); Result := Invalid_Model; return;
         end if;
         for K in 1 .. M.Sparse.M_Rownnz (Row) loop
            if Count >= W.Mass'Length or else Count >= M.S.NC then
               Free (W); Result := Capacity_Exceeded; return;
            end if;
            if M.Sparse.M_Colind (Count) not in 0 .. Integer (Row)
              or else (K > 1 and then M.Sparse.M_Colind (Count) <= M.Sparse.M_Colind (Count - 1))
            then Free (W); Result := Invalid_Model; return; end if;
            W.Mass (Count) := (Row, M.Sparse.M_Colind (Count)); Count := Count + 1;
         end loop;
      end loop;
      if Count /= W.Dims.Nmass then Free (W); Result := Unsupported_Feature; return; end if;
      declare D : constant Dimensions := W.Dims; Nx : constant Natural := State_Dimension (W);
      begin
         W.TA := new Matrix'(0 .. Nx - 1 => [0 .. Nx - 1 => 0.0]);
         W.TB := new Matrix'(0 .. Nx - 1 => [0 .. D.Nu - 1 => 0.0]);
         W.TQ := new Matrix'(0 .. D.Nv - 1 => [0 .. D.Nv - 1 => 0.0]);
         W.TV := new Matrix'(0 .. D.Nv - 1 => [0 .. D.Nv - 1 => 0.0]);
         W.TAcc := new Matrix'(0 .. D.Nv - 1 => [0 .. D.Nv - 1 => 0.0]);
         W.TM := new Matrix'(0 .. D.Nv - 1 => [0 .. D.Nmass - 1 => 0.0]);
      end;
      W.Initialized := True; Result := Success;
   exception
      when Constraint_Error => M.Opt.Disableflags := Flags; M.Flg_Adhesion := Adhesion; Free (W); Result := Numeric_Limit;
      when others => M.Opt.Disableflags := Flags; M.Flg_Adhesion := Adhesion; Free (W); raise;
   end Create;

   function Sized (M : Matrix; Rows, Columns : Natural) return Boolean is
     (M'First (1) = 0 and then M'First (2) = 0
       and then M'Length (1) = Rows and then M'Length (2) = Columns);
   function Inputs_OK (W : Workspace; Qpos, Qvel, Act, Ctrl : State_Vector) return Boolean is
     (Qpos'First = 0 and then Qpos'Length = W.Dims.Nq
       and then Qvel'First = 0 and then Qvel'Length = W.Dims.Nv
       and then Act'First = 0 and then Act'Length = W.Dims.Na
       and then Ctrl'First = 0 and then Ctrl'Length = W.Dims.Nu);
   procedure Install
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl, Applied : State_Vector;
      Time : Nonneg_Tier0; Use_Constraints : Boolean; Result : out Status) is
   begin
      if Use_Constraints then
         C.Set_State (W.C, Qpos, Qvel, Time, Result);
         if Result /= Success then return; end if;
         C.Set_Activation (W.C, Act, Result);
      else
         Set_State (W.S, Qpos, Qvel, Time, Result);
         if Result /= Success then return; end if;
         Set_Activation (W.S, Act, Result);
      end if;
      if Result /= Success then return; end if;
      for U in Ctrl'Range loop
         if Use_Constraints then C.Set_Control (W.C, U, Ctrl (U), Result);
         else Set_Control (W.S, U, Ctrl (U), Result); end if;
         if Result /= Success then return; end if;
      end loop;
      for V in Applied'Range loop
         if Use_Constraints then C.Set_Applied_Force (W.C, V, Applied (V), Result);
         else Set_Applied_Force (W.S, V, Applied (V), Result); end if;
         if Result /= Success then return; end if;
      end loop;
   end Install;

   procedure Nudge (Values : in out State_Vector; Index : Natural; Amount : Real) is
      Value : constant Real := Values (Index) + Amount;
   begin
      Values (Index) := Value; -- checked Tier0 boundary, caught before publication
   end Nudge;
   procedure Nudge_Position
     (W : Workspace; Q : in out State_Vector; Direction : Natural; Amount : Real) is
      Qadr, Vadr, Rot, Axis : Natural;
      Quat, Dq, Out_Q : SM.Quaternion;
      Normalized : MJ.BLAS.Vector_4;
      Length : MJ.BLAS.Nonnegative_Real;
   begin
      for J in 0 .. W.Nj - 1 loop
         Qadr := W.Joints (J).Qadr; Vadr := W.Joints (J).Vadr;
         if W.Joints (J).Kind in 2 .. 3 and then Direction = Vadr then
            Nudge (Q, Qadr, Amount); return;
         elsif W.Joints (J).Kind = 0 and then Direction in Vadr .. Vadr + 2 then
            Nudge (Q, Qadr + Direction - Vadr, Amount); return;
         elsif (W.Joints (J).Kind = 1 and then Direction in Vadr .. Vadr + 2)
           or else (W.Joints (J).Kind = 0 and then Direction in Vadr + 3 .. Vadr + 5)
         then
            Rot := (if W.Joints (J).Kind = 0 then Qadr + 3 else Qadr);
            Axis := Direction - Vadr - (if W.Joints (J).Kind = 0 then 3 else 0);
            Normalized := [for K in 0 .. 3 => Real (Q (Rot + K))];
            -- mju_quatIntegrate normalizes the input before multiplying;
            -- it does not renormalize the perturbed quaternion afterwards.
            MJ.BLAS.Normalize4 (Normalized, Length);
            Quat := SM.Quaternion (Normalized);
            Dq := [E.Cos (0.5 * Amount), 0.0, 0.0, 0.0];
            Dq (Axis + 1) := E.Sin (0.5 * Amount);
            Out_Q := SM.Multiply (Quat, Dq);
            for K in 0 .. 3 loop Q (Rot + K) := Out_Q (K); end loop;
            return;
         end if;
      end loop;
      raise Constraint_Error with "missing tangent direction";
   end Nudge_Position;

   procedure State_Difference
     (W : Workspace; Left, Right : Real_Array; Scale : DK.Reciprocal;
      Values : out Real_Array) is
      D : constant Dimensions := W.Dims;
      Qadr, Vadr, Rot, Vrot : Natural;
      L, R : SM.Quaternion;
      Angle : SM.Vector;
   begin
      for J in 0 .. W.Nj - 1 loop
         Qadr := W.Joints (J).Qadr; Vadr := W.Joints (J).Vadr;
         if W.Joints (J).Kind in 2 .. 3 then
            Values (Vadr) := DK.Scaled_Difference (Left (Qadr), Right (Qadr), Scale);
         else
            if W.Joints (J).Kind = 0 then
               for I in 0 .. 2 loop
                  Values (Vadr + I) := DK.Scaled_Difference (Left (Qadr + I), Right (Qadr + I), Scale);
               end loop;
               Rot := Qadr + 3; Vrot := Vadr + 3;
            else Rot := Qadr; Vrot := Vadr;
            end if;
            L := [for K in 0 .. 3 => Left (Rot + K)];
            R := [for K in 0 .. 3 => Right (Rot + K)];
            Angle := MM.Rotation_Vector (SM.Multiply ([L (0), -L (1), -L (2), -L (3)], R));
            for I in 0 .. 2 loop Values (Vrot + I) := DK.Scaled_Difference (0.0, Angle (I), Scale); end loop;
         end if;
      end loop;
      for I in 0 .. D.Nv + D.Na - 1 loop
         Values (D.Nv + I) := DK.Scaled_Difference (Left (D.Nq + I), Right (D.Nq + I), Scale);
      end loop;
   end State_Difference;

   procedure Transition_FD
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl, Applied : State_Vector;
      Time : Nonneg_Tier0; Eps : Increment; Centered : Boolean;
      A, B : in out Matrix; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      D : constant Dimensions := W.Dims;
      Nx : constant Natural := State_Dimension (W);
      Base, Plus, Minus : Real_Array (0 .. D.Nq + D.Nv + D.Na - 1);
      Column : Real_Array (0 .. Nx - 1);
      Q : State_Vector (Qpos'Range); V : State_Vector (Qvel'Range);
      Activation : State_Vector (Act'Range); U : State_Vector (Ctrl'Range);
      procedure Sample is
         Raw : Real_Array (0 .. D.Nq + D.Nv);
      begin
         Install (W, Q, V, Activation, U, Applied, Time, W.Mode = Constrained, Result);
         if Result /= Success then return; end if;
         if W.Mode = Constrained then
            C.Step (W.C, Result, External);
            if Result = Success then
               Raw := C.State (W.C);
               Base := Raw (0 .. D.Nq + D.Nv - 1) & C.Activation_Values (W.C);
            end if;
         else
            MJ.Data.Euler.Step (W.S, Result, External);
            if Result = Success then
               Raw := State_Values (W.S);
               Base := Raw (0 .. D.Nq + D.Nv - 1) & Activation_Values (W.S);
            end if;
         end if;
      end Sample;
      procedure Reset_Inputs is
      begin Q := Qpos; V := Qvel; Activation := Act; U := Ctrl; end Reset_Inputs;
      Reference : Real_Array (Base'Range);
      St : DK.Stencil;
   begin
      if not Ready (W) then Result := Not_Allocated; return; end if;
      if not Inputs_OK (W, Qpos, Qvel, Act, Ctrl)
        or else Applied'First /= 0 or else Applied'Length /= D.Nv
        or else not Sized (A, Nx, Nx) or else not Sized (B, Nx, D.Nu)
      then Result := Invalid_Size; return; end if;
      Reset_Inputs; Sample;
      if Result /= Success then return; end if;
      Reference := Base;
      -- C ordering: controls, activations, velocities, positions.
      for I in 0 .. D.Nu - 1 loop
         St := DK.Control_Stencil (Ctrl (I), Eps, W.Ctrl (I).Is_Limited,
           Centered, W.Ctrl (I).Low, W.Ctrl (I).High);
         Plus := Reference; Minus := Reference;
         if St in DK.Forward | DK.Central then
            Reset_Inputs; Nudge (U, I, Eps); Sample;
            if Result /= Success then return; end if;
            Plus := Base;
         end if;
         if St in DK.Backward | DK.Central then
            Reset_Inputs; Nudge (U, I, -Eps); Sample;
            if Result /= Success then return; end if;
            Minus := Base;
         end if;
         if St = DK.Zero then Column := [others => 0.0];
         else State_Difference (W, Minus, Plus,
           (if St = DK.Central then 1.0 / (2.0 * Eps) else 1.0 / Eps), Column); end if;
         DK.Store_Column (W.TB.all, I, Column);
      end loop;
      for Group in 0 .. 2 loop
         for I in 0 .. (if Group = 0 then D.Na else D.Nv) - 1 loop
            Reset_Inputs;
            if Group = 0 then Nudge (Activation, I, Eps);
            elsif Group = 1 then Nudge (V, I, Eps);
            else Nudge_Position (W, Q, I, Eps); end if;
            Sample; if Result /= Success then return; end if; Plus := Base;
            Minus := Reference;
            if Centered then
               Reset_Inputs;
               if Group = 0 then Nudge (Activation, I, -Eps);
               elsif Group = 1 then Nudge (V, I, -Eps);
               else Nudge_Position (W, Q, I, -Eps); end if;
               Sample; if Result /= Success then return; end if; Minus := Base;
            end if;
            State_Difference (W, Minus, Plus,
              (if Centered then 1.0 / (2.0 * Eps) else 1.0 / Eps), Column);
            DK.Store_Column (W.TA.all,
              (if Group = 0 then 2 * D.Nv + I elsif Group = 1 then D.Nv + I else I), Column);
         end loop;
      end loop;
      A := W.TA.all; B := W.TB.all; Result := Success;
   exception when Constraint_Error => Result := Numeric_Limit;
   end Transition_FD;

   procedure Force_Sample
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl : State_Vector;
      Kind : Force_Derivative; Force : out Real_Array; Result : out Status) is
      Applied : State_Vector (0 .. W.Dims.Nv - 1) := [others => 0.0];
      Actuation : Real_Array (Force'Range) := [others => 0.0];
   begin
      Install (W, Qpos, Qvel, Act, Ctrl, Applied, 0.0, False, Result);
      if Result /= Success then return; end if;
      MJ.Data.Forward.Evaluate (W.S, Result);
      if Result /= Success then return; end if;
      if Kind = Smooth_Force and then W.Mode = Constrained then
         Install (W, Qpos, Qvel, Act, Ctrl, Applied, 0.0, True, Result);
         if Result /= Success then return; end if;
         C.Evaluate (W.C, Result);
         if Result /= Success then return; end if;
         Actuation := C.Derivative_Projection.Actuation (W.C);
      end if;
      for I in Force'Range loop
         if Kind = Passive_Force then Force (I) := Force_Value (W.S, MJ.Data.Passive_Force, I);
         else
            Force (I) := DK.Smooth_Force
              ((if W.Mode = Constrained then Actuation (I) else Force_Value (W.S, Actuator_Force, I)),
              Force_Value (W.S, MJ.Data.Passive_Force, I),
              Force_Value (W.S, Velocity_Bias, I) - Force_Value (W.S, Gravity_Force, I));
         end if;
      end loop;
   end Force_Sample;
   procedure Velocity_FD
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl : State_Vector;
      Eps : Increment; Kind : Force_Derivative;
      Derivative : in out Matrix; Result : out Status) is
      V : State_Vector (Qvel'Range);
      Plus, Minus, Column : Real_Array (0 .. W.Dims.Nv - 1);
   begin
      if not Ready (W) then Result := Not_Allocated; return; end if;
      if not Inputs_OK (W, Qpos, Qvel, Act, Ctrl)
        or else not Sized (Derivative, W.Dims.Nv, W.Dims.Nv)
      then Result := Invalid_Size; return; end if;
      for I in 0 .. W.Dims.Nv - 1 loop
         V := Qvel; Nudge (V, I, Eps);
         Force_Sample (W, Qpos, V, Act, Ctrl, Kind, Plus, Result);
         if Result /= Success then return; end if;
         V := Qvel;
         if Kind = Smooth_Force then Nudge (V, I, -Eps); end if;
         Force_Sample (W, Qpos, V, Act, Ctrl, Kind, Minus, Result);
         if Result /= Success then return; end if;
         DK.Differentiate (Minus, Plus, (if Kind = Smooth_Force then 0.5 / Eps else 1.0 / Eps), Column);
         DK.Store_Column (W.TV.all, I, Column);
      end loop;
      Derivative := W.TV.all; Result := Success;
   exception when Constraint_Error => Result := Numeric_Limit;
   end Velocity_FD;

   procedure Inverse_Sample
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl, Acc : State_Vector;
      Subtract_Actuation : Boolean; Force, Mass : out Real_Array; Result : out Status) is
      Applied : State_Vector (0 .. W.Dims.Nv - 1) := [others => 0.0];
      Value : Real;
      Constraint : Real_Array (0 .. W.Dims.Nv - 1) := [others => 0.0];
   begin
      Install (W, Qpos, Qvel, Act, Ctrl, Applied, 0.0, False, Result);
      if Result /= Success then return; end if;
      MJ.Data.Forward.Evaluate (W.S, Result);
      if Result /= Success then return; end if;
      if W.Mode = Constrained then
         Install (W, Qpos, Qvel, Act, Ctrl, Applied, 0.0, True, Result);
         if Result /= Success then return; end if;
         C.Evaluate (W.C, Result);
         if Result /= Success then return; end if;
         C.Derivative_Projection.Evaluate (W.C, Acc, W.Sparse, Constraint, Result);
         if Result /= Success then return; end if;
      end if;
      Force := [others => 0.0];
      MJ.Data.Inverse.Current (W.S, Acc, Force, Result, Constraint);
      if Result /= Success then return; end if;
      declare
         Constrained_Actuation : constant Real_Array :=
           (if Subtract_Actuation and then W.Mode = Constrained then
              C.Derivative_Projection.Actuation (W.C) else [1 .. 0 => 0.0]);
      begin
         for I in 0 .. W.Dims.Nv - 1 loop
            Value := Force (I);
            if Subtract_Actuation then
               Value := Value - (if W.Mode = Constrained then Constrained_Actuation (I)
                 else Force_Value (W.S, Actuator_Force, I));
            end if;
            if Value not in DK.Operand then Result := Numeric_Limit; return; end if;
            Force (I) := Value;
         end loop;
      end;
      for K in Mass'Range loop Mass (K) := MJ.Data.Mass_Entry (W.S, W.Mass (K).Row, W.Mass (K).Column); end loop;
   end Inverse_Sample;
   procedure Inverse_FD
     (W : in out Workspace; Qpos, Qvel, Act, Ctrl, Acc : State_Vector;
      Eps : Increment; Subtract_Actuation : Boolean;
      DfDq, DfDv, DfDa, DmDq : in out Matrix; Result : out Status) is
      D : constant Dimensions := W.Dims;
      Base, Plus, Row : Real_Array (0 .. D.Nv - 1);
      Base_M, Plus_M, Row_M : Real_Array (0 .. D.Nmass - 1);
      Q : State_Vector (Qpos'Range); V : State_Vector (Qvel'Range);
      Acceleration : State_Vector (Acc'Range);
   begin
      if not Ready (W) then Result := Not_Allocated; return; end if;
      if not Inputs_OK (W, Qpos, Qvel, Act, Ctrl)
        or else Acc'First /= 0 or else Acc'Length /= D.Nv
        or else not Sized (DfDq, D.Nv, D.Nv) or else not Sized (DfDv, D.Nv, D.Nv)
        or else not Sized (DfDa, D.Nv, D.Nv) or else not Sized (DmDq, D.Nv, D.Nmass)
      then Result := Invalid_Size; return; end if;
      Inverse_Sample (W, Qpos, Qvel, Act, Ctrl, Acc, Subtract_Actuation, Base, Base_M, Result);
      if Result /= Success then return; end if;
      for Group in 0 .. 2 loop
         for I in 0 .. D.Nv - 1 loop
            Q := Qpos; V := Qvel; Acceleration := Acc;
            if Group = 0 then Nudge (Acceleration, I, Eps);
            elsif Group = 1 then Nudge (V, I, Eps);
            else Nudge_Position (W, Q, I, Eps); end if;
            Inverse_Sample (W, Q, V, Act, Ctrl, Acceleration,
              Subtract_Actuation, Plus, Plus_M, Result);
            if Result /= Success then return; end if;
            DK.Differentiate (Base, Plus, 1.0 / Eps, Row);
            if Group = 0 then DK.Store_Row (W.TAcc.all, I, Row);
            elsif Group = 1 then DK.Store_Row (W.TV.all, I, Row);
            else
               DK.Store_Row (W.TQ.all, I, Row);
               DK.Differentiate (Base_M, Plus_M, 1.0 / Eps, Row_M);
               DK.Store_Row (W.TM.all, I, Row_M);
            end if;
         end loop;
      end loop;
      DfDq := W.TQ.all; DfDv := W.TV.all; DfDa := W.TAcc.all; DmDq := W.TM.all;
      Result := Success;
   exception when Constraint_Error => Result := Numeric_Limit;
   end Inverse_FD;
end MJ.Dynamics_Derivatives;

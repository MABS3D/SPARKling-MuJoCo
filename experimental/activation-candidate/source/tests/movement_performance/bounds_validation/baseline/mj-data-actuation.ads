--  Review draft. Stateless scalar joint transmissions with fixed gain and
--  optional affine bias; supports simple motors and position/velocity servos.
package MJ.Data.Actuation with SPARK_Mode is
   --  These total value queries are safe to snapshot unconditionally on entry.
   pragma Unevaluated_Use_Of_Old (Allow);
   function Expected_Length (D : Simulation; Index : Natural) return Real with
     Ghost => Static, Global => null, Pre => Is_Ready (D) and then Index < Control_Count (D);
   function Expected_Velocity (D : Simulation; Index : Natural) return Real with
     Ghost => Static, Global => null, Pre => Is_Ready (D) and then Index < Control_Count (D);
   function Expected_Force (D : Simulation; Index : Natural) return Real with
     Ghost => Static, Global => null, Pre => Is_Ready (D) and then Index < Control_Count (D);
   function Expected_Generalized (D : Simulation; Index : Natural) return Real with
     Ghost => Static, Global => null, Pre => Is_Ready (D) and then Actuation_Current (D) and then Index < Velocity_Count (D);
   procedure Compute (D : in out Simulation; Result : out Status) with Global => null, Pre => Valid_State (D),
     Post => Is_Empty (D) = Is_Empty (D)'Old;
   pragma Postcondition (Is_Ready (D) = Is_Ready (D)'Old);
   pragma Postcondition (Shape (D) = Shape (D)'Old);
   pragma Postcondition (State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Input_Values (D) = Input_Values (D)'Old);
   pragma Postcondition (Positions_Current (D) = Positions_Current (D)'Old);
   pragma Postcondition (if Result = Success then Is_Ready (D) and then Actuation_Current (D));
   pragma Postcondition (Static => Configuration (D) = Configuration (D)'Old
     and then Position_Values (D) = Position_Values (D)'Old
     and then Velocity_Values (D) = Velocity_Values (D)'Old
     and then Time (D) = Time (D)'Old and then Step_Size (D) = Step_Size (D)'Old);

   pragma Postcondition (Static => (if Result = Success then
     (for all A in 0 .. Control_Count (D) - 1 =>
       Actuator_Value (D, Transmission_Length, A) = Expected_Length (D, A)
       and then Actuator_Value (D, Transmission_Velocity, A) = Expected_Velocity (D, A)
       and then Actuator_Value (D, Output_Force, A) = Expected_Force (D, A))
     and then (for all J in 0 .. Velocity_Count (D) - 1 =>
       Force_Value (D, Actuator_Force, J) = Expected_Generalized (D, J))));
private
   function Expected_Length (D : Simulation; Index : Natural) return Real is
     (MJ.Smooth_Kernels.Transmission (D.Actuator_Config (Index).Gear,
       D.State.Qpos (D.Actuator_Config (Index).Joint_Id)));
   function Expected_Velocity (D : Simulation; Index : Natural) return Real is
     (if D.Actuation_Enabled then MJ.Smooth_Kernels.Transmission (D.Actuator_Config (Index).Gear,
       D.State.Qvel (D.Actuator_Config (Index).Joint_Id)) else 0.0);
   function Expected_Force (D : Simulation; Index : Natural) return Real is
     (MJ.Smooth_Actuation.Force_For (D.Actuator_Config (Index),
       D.State.Qpos (D.Actuator_Config (Index).Joint_Id), D.State.Qvel (D.Actuator_Config (Index).Joint_Id),
       D.State.Ctrl (Index), D.Actuation_Enabled, D.Clamp_Control));
   function Expected_Generalized (D : Simulation; Index : Natural) return Real is
     (MJ.Smooth_Actuation.Reduced_Force (D.Actuator_Config.all, D.Actuators.Force.all, Index, D.Na));
end MJ.Data.Actuation;

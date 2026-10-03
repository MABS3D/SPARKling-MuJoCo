-- Continuous inverse dynamics for the owned smooth Model/Data subset.
package MJ.Data.Inverse with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   No_Constraints : constant Real_Array := [1 .. 0 => 0.0];
   -- Current is read-only and reuses position/velocity stages. Required_Force
   -- follows qfrc_inverse, including the total required actuator/applied load;
   -- controls and applied loads are not subtracted. Optional Constraint_Force
   -- is already projected into generalized coordinates at this acceleration.
   procedure Current
     (D : Simulation; Qacc : State_Vector; Required_Force : in out Real_Array;
      Result : out Status; Constraint_Force : Real_Array := No_Constraints)
     with Global => null, Pre => Valid_State (D),
       Post => (if Result /= Success then Required_Force = Required_Force'Old);
   -- Prepare only kinematics, inertia and passive forces; no actuation,
   -- acceleration solve, integration or state publication.
   procedure Evaluate
     (D : in out Simulation; Qacc : State_Vector; Required_Force : in out Real_Array;
      Result : out Status)
     with Global => null, Pre => Valid_State (D),
       Post => (Static => Is_Ready (D) = Is_Ready (D)'Old
         and then State_Values (D) = State_Values (D)'Old
         and then Activation_Values (D) = Activation_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then (if Result /= Success then Required_Force = Required_Force'Old));
end MJ.Data.Inverse;

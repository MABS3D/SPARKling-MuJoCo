with MJ.Muscle_Actuation;
private package MJ.Data.Manifold_Actuation with SPARK_Mode is
   type Moment is array (Natural range 0 .. 5) of Real;
   function Valid_Transmission (C : Actuator_Parameters; Q : Real_Array; Nv : Natural) return Boolean is
     (Nv <= Max_Dofs and then Q'First = 0 and then Q'Length <= Max_Positions
      and then MJ.Smooth_Kernels.All_Tier0 (Q) and then MJ.Smooth_Actuation.Valid_Parameter (C)
      and then C.Position_Id < Q'Length and then C.Joint_Id < Nv
      and then C.Position_Id <= Q'Length - (if C.Joint_Type = 0 then 7 elsif C.Joint_Type = 1 then 4 else 1)
      and then C.Joint_Id <= Nv - (if C.Joint_Type = 0 then 6 elsif C.Joint_Type = 1 then 3 else 1)
      and then (for all X of C.Wrench_Gear => X in Tier0_Real)) with Global => null;
   function Transmission_Moment (C : Actuator_Parameters; Q : Real_Array) return Moment with Global => null,
     Pre => Valid_Transmission (C, Q, Max_Dofs),
     Post => (for all X of Transmission_Moment'Result => X in -1.0e12 .. 1.0e12);
   function Length (C : Actuator_Parameters; Q : Real_Array) return Real with Global => null,
     Pre => Valid_Transmission (C, Q, Max_Dofs), Post => Length'Result in -1.0e21 .. 1.0e21;
   function Velocity (C : Actuator_Parameters; Q, V : Real_Array) return Real with Global => null,
     Pre => V'First = 0 and then Valid_Transmission (C, Q, V'Length)
       and then MJ.Smooth_Kernels.All_Tier0 (V), Post => Velocity'Result in -1.0e23 .. 1.0e23;
   function Force (C : Actuator_Parameters; L, V, U : Real; Enabled, Clamp_Control : Boolean) return Real
     with Global => null, Pre => MJ.Smooth_Actuation.Valid_Parameter (C)
       and then L in -1.0e20 .. 1.0e20 and then V in -1.0e20 .. 1.0e20 and then U in Tier0_Real
       and then (if C.Muscle_Mode then L in Tier0_Real and then V in Tier0_Real),
     Post => (if not C.Muscle_Mode then Force'Result in MJ.Smooth_Kernels.Actuator_Force_Real)
       and then Force'Result in MJ.Muscle_Actuation.Force_Value;
   function Reduced (C : Actuator_Parameter_Array; Q, F : Real_Array; Dof, Count : Natural) return Real
     with Ghost => Static, Global => null,
       Pre => C'First = 0 and then C'Length <= Max_Actuators and then Count <= C'Length
         and then F'First = 0 and then F'Last = C'Last
         and then (for all X of F => X in MJ.Smooth_Kernels.Actuator_Force_Real)
         and then (for all P of C => Valid_Transmission (P, Q, Max_Dofs)),
       Post => Reduced'Result in -1.0e50 .. 1.0e50,
       Subprogram_Variant => (Decreases => Count);
   procedure Compute (D : in out Simulation; Result : out Status)
     with Global => null, Pre => Is_Ready (D),
     Post => (if Result = Success then Is_Ready (D) and then Actuation_Current (D));
end MJ.Data.Manifold_Actuation;

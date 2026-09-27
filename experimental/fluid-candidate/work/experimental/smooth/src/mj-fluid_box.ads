with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with Ada.Numerics;
package MJ.Fluid_Box with SPARK_Mode is
   Pi : constant Real := Ada.Numerics.Pi;
   subtype Dimension is Real range 0.0 .. 1.0e14;
   subtype Coefficient is Real range -1.0e90 .. 1.0e90;
   subtype Rate is Real range -1.0e12 .. 1.0e12;
   subtype Force_Value is Real range -1.0e120 .. 1.0e120;
   type Coefficient_Vector is array (Axis) of Coefficient;
   type Coefficients is record
      Linear_Viscous, Angular_Viscous : Coefficient := 0.0;
      Linear_Drag, Angular_Drag : Coefficient_Vector := [others => 0.0];
   end record;
   type Wrench is record
      Force, Torque : Vector := Zero;
   end record;
   function Viscous_Linear (Diameter : Dimension; Viscosity : Nonneg_Tier0) return Coefficient
     with Global => null, Post => Viscous_Linear'Result = -3.0*Pi*Diameter*Viscosity;
   function Viscous_Angular (Diameter : Dimension; Viscosity : Nonneg_Tier0) return Coefficient
     with Global => null, Post => Viscous_Angular'Result = -Pi*Diameter*Diameter*Diameter*Viscosity;
   function Drag_Linear (S1, S2 : Dimension; Density : Nonneg_Tier0) return Coefficient
     with Global => null, Post => Drag_Linear'Result = 0.5*Density*S1*S2;
   function Drag_Angular (S0, S1, S2 : Dimension; Density : Nonneg_Tier0) return Coefficient
     with Global => null, Post => Drag_Angular'Result = Density*S0*(S1*S1*S1*S1+S2*S2*S2*S2);
   function Component (Viscous, Quadratic : Coefficient; V : Rate; Rotation : Boolean) return Force_Value
     with Global => null, Post => Component'Result = Viscous*V -
       (if Rotation then Quadratic*abs(V)*V/64.0 else Quadratic*abs(V)*V);
   function Prepare (Box : Vector; Density, Viscosity : Nonneg_Tier0) return Coefficients
     with Global => null,
     Pre => (for all X of Box => X in Dimension) and then (Box(0)+Box(1)+Box(2))/3.0 in Dimension,
     Post => Prepare'Result.Linear_Viscous = Viscous_Linear((Box(0)+Box(1)+Box(2))/3.0,Viscosity);
   pragma Postcondition (Prepare'Result.Angular_Viscous = Viscous_Angular((Box(0)+Box(1)+Box(2))/3.0,Viscosity));
   pragma Postcondition (Prepare'Result.Linear_Drag(0) = Drag_Linear(Box(1),Box(2),Density));
   pragma Postcondition (Prepare'Result.Angular_Drag(0) = Drag_Angular(Box(0),Box(1),Box(2),Density));
   pragma Postcondition (Prepare'Result.Linear_Drag(1) = Drag_Linear(Box(0),Box(2),Density));
   pragma Postcondition (Prepare'Result.Angular_Drag(1) = Drag_Angular(Box(1),Box(0),Box(2),Density));
   pragma Postcondition (Prepare'Result.Linear_Drag(2) = Drag_Linear(Box(0),Box(1),Density));
   pragma Postcondition (Prepare'Result.Angular_Drag(2) = Drag_Angular(Box(2),Box(0),Box(1),Density));
   function Evaluate (C : Coefficients; Linear, Angular : Vector) return Wrench
     with Global => null,
     Pre => Bounded(Linear,1.0e12) and then Bounded(Angular,1.0e12),
     Post => Bounded(Evaluate'Result.Force,1.0e120) and then Bounded(Evaluate'Result.Torque,1.0e120);
   pragma Postcondition (Evaluate'Result.Force(0) = Component(C.Linear_Viscous,C.Linear_Drag(0),Linear(0),False));
   pragma Postcondition (Evaluate'Result.Torque(0) = Component(C.Angular_Viscous,C.Angular_Drag(0),Angular(0),True));
   pragma Postcondition (Evaluate'Result.Force(1) = Component(C.Linear_Viscous,C.Linear_Drag(1),Linear(1),False));
   pragma Postcondition (Evaluate'Result.Torque(1) = Component(C.Angular_Viscous,C.Angular_Drag(1),Angular(1),True));
   pragma Postcondition (Evaluate'Result.Force(2) = Component(C.Linear_Viscous,C.Linear_Drag(2),Linear(2),False));
   pragma Postcondition (Evaluate'Result.Torque(2) = Component(C.Angular_Viscous,C.Angular_Drag(2),Angular(2),True));
end MJ.Fluid_Box;

package body MJ.Fluid_Box with SPARK_Mode is
   function Viscous_Linear (Diameter : Dimension; Viscosity : Nonneg_Tier0) return Coefficient is
   begin
      return -3.0*Pi*Diameter*Viscosity;
   end Viscous_Linear;
   function Viscous_Angular (Diameter : Dimension; Viscosity : Nonneg_Tier0) return Coefficient is
   begin
      return -Pi*Diameter*Diameter*Diameter*Viscosity;
   end Viscous_Angular;
   function Drag_Linear (S1, S2 : Dimension; Density : Nonneg_Tier0) return Coefficient is
   begin
      return 0.5*Density*S1*S2;
   end Drag_Linear;
   function Drag_Angular (S0, S1, S2 : Dimension; Density : Nonneg_Tier0) return Coefficient is
      subtype P4 is Real range 0.0 .. 2.0e56;
      A : constant P4 := S1*S1*S1*S1;
      B : constant P4 := S2*S2*S2*S2;
   begin
      return Density*S0*(A+B);
   end Drag_Angular;
   function Component (Viscous, Quadratic : Coefficient; V : Rate; Rotation : Boolean) return Force_Value is
      subtype Partial_Value is Real range -1.0e116 .. 1.0e116;
      F : constant Partial_Value := Viscous*V;
      D : constant Partial_Value := Quadratic*abs(V)*V;
   begin
      return F - (if Rotation then D/64.0 else D);
   end Component;
   function Prepare (Box : Vector; Density, Viscosity : Nonneg_Tier0) return Coefficients is
      Diameter : constant Dimension := (Box(0)+Box(1)+Box(2))/3.0;
   begin
      return (Linear_Viscous => Viscous_Linear(Diameter,Viscosity),
              Angular_Viscous => Viscous_Angular(Diameter,Viscosity),
              Linear_Drag => [Drag_Linear(Box(1),Box(2),Density),Drag_Linear(Box(0),Box(2),Density),Drag_Linear(Box(0),Box(1),Density)],
              Angular_Drag => [Drag_Angular(Box(0),Box(1),Box(2),Density),Drag_Angular(Box(1),Box(0),Box(2),Density),Drag_Angular(Box(2),Box(0),Box(1),Density)]);
   end Prepare;
   function Evaluate (C : Coefficients; Linear, Angular : Vector) return Wrench is
   begin
      return (Force => [Component(C.Linear_Viscous,C.Linear_Drag(0),Linear(0),False),
                        Component(C.Linear_Viscous,C.Linear_Drag(1),Linear(1),False),
                        Component(C.Linear_Viscous,C.Linear_Drag(2),Linear(2),False)],
              Torque => [Component(C.Angular_Viscous,C.Angular_Drag(0),Angular(0),True),
                         Component(C.Angular_Viscous,C.Angular_Drag(1),Angular(1),True),
                         Component(C.Angular_Viscous,C.Angular_Drag(2),Angular(2),True)]);
   end Evaluate;
end MJ.Fluid_Box;

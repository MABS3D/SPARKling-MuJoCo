package body MJ.Fluid_Projection with SPARK_Mode is
   function Inverse (X : Real) return Inverse_Value is
   begin
      return (if X > Min_Val then 1.0/X else 0.0);
   end Inverse;
   function Normalize (Inv : Inverse_Value; V : Rate) return Normalized_Rate is
   begin
      return Inv*V;
   end Normalize;
   function Numerator_Part (S : Surface; V : Normalized_Rate) return Numerator_Term is
   begin
      return S*V*V;
   end Numerator_Part;
   function Numerator (S0,S1,S2 : Surface; V0,V1,V2 : Normalized_Rate) return Numerator_Value is
   begin
      return Numerator_Part(S0,V0)+Numerator_Part(S1,V1)+Numerator_Part(S2,V2);
   end Numerator;
   function Coefficient (S : Surface; Inv : Inverse_Value) return Projection_Coefficient is
   begin
      return S*Inv;
   end Coefficient;
   function Denominator_Part (C : Projection_Coefficient; V : Normalized_Rate) return Denominator_Term is
   begin
      return C*C*V*V;
   end Denominator_Part;
   function Denominator (C0,C1,C2 : Projection_Coefficient; V0,V1,V2 : Normalized_Rate) return Denominator_Value is
   begin
      return Denominator_Part(C0,V0)+Denominator_Part(C1,V1)+Denominator_Part(C2,V2);
   end Denominator;
   function Normal (C : Projection_Coefficient; V : Normalized_Rate) return Normal_Value is
   begin
      return C*V;
   end Normal;
   function Norm_Squared (X,Y,Z : Norm_Input) return Norm_Squared_Value is
   begin
      return (X*X+Y*Y)+Z*Z;
   end Norm_Squared;
   function Projected_Area (Dmax : Nonneg_Tier0; Root : Area_Root) return Area_Value is
   begin
      return Pi*Dmax*Dmax*Root;
   end Projected_Area;
   function Linear_Drag (Viscosity,Density,Blunt,Slender : Nonneg_Tier0; Lin_Visc : MJ.Fluid_Geometry.Linear_Viscous; Speed : Speed_Value; Aproj : Area_Value; Amax : MJ.Fluid_Geometry.Area_Value) return Drag_Value is
   begin
      return Viscosity*Lin_Visc+Density*Speed*(Aproj*Blunt+Slender*(Amax-Aproj));
   end Linear_Drag;
   function Moment (W : Rate; M : Angular_Moment) return Norm_Input is
   begin
      return W*M;
   end Moment;
   function Angular_Drag (Viscosity,Density : Nonneg_Tier0; Ang_Visc : MJ.Fluid_Geometry.Angular_Viscous; Root : Area_Root) return Drag_Value is
   begin
      return Viscosity*Ang_Visc+Density*Root;
   end Angular_Drag;
   function Norm (X,Y,Z : Norm_Input) return Real is
   begin
      return Ada.Numerics.Long_Elementary_Functions.Sqrt(Norm_Squared(X,Y,Z));
   end Norm;
   function Projection_Product (PN : Numerator_Value; PD : Denominator_Value) return Root_Argument is
   begin
      return PN*PD;
   end Projection_Product;
end MJ.Fluid_Projection;

with MJ.Types; use MJ.Types;
with Ada.Numerics;
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Fluid_Geometry;
package MJ.Fluid_Projection with SPARK_Mode is
   Pi : constant Real := Ada.Numerics.Pi;
   subtype Rate is Real range -1.0e12 .. 1.0e12;
   subtype Normalized_Rate is Real range -1.0e28 .. 1.0e28;
   subtype Surface is Real range 0.0 .. 2.0;
   subtype Inverse_Value is Real range 0.0 .. 2.0e15;
   subtype Projection_Coefficient is Real range 0.0 .. 5.0e15;
   subtype Numerator_Term is Real range 0.0 .. 1.0e57;
   subtype Numerator_Value is Real range 0.0 .. 1.0e58;
   subtype Denominator_Term is Real range 0.0 .. 1.0e88;
   subtype Denominator_Value is Real range 0.0 .. 1.0e89;
   subtype Normal_Value is Real range -1.0e44 .. 1.0e44;
   subtype Norm_Input is Real range -1.0e76 .. 1.0e76;
   subtype Norm_Squared_Value is Real range 0.0 .. 1.0e154;
   subtype Root_Argument is Real range 0.0 .. 1.0e149;
   subtype Area_Root is Real range 0.0 .. 1.0e76;
   subtype Area_Value is Real range 0.0 .. 1.0e98;
   subtype Speed_Value is Real range 0.0 .. 1.0e14;
   subtype Drag_Value is Real range -1.0e135 .. 1.0e135;
   subtype Angular_Moment is Real range -1.0e63 .. 1.0e63;
   function Inverse (X : Real) return Inverse_Value
     with Global => null, Inline, Post => Inverse'Result = (if X > Min_Val then 1.0/X else 0.0);
   function Normalize (Inv : Inverse_Value; V : Rate) return Normalized_Rate
     with Global => null, Inline, Post => Normalize'Result = Inv*V;
   function Numerator_Part (S : Surface; V : Normalized_Rate) return Numerator_Term
     with Global => null, Inline, Post => Numerator_Part'Result = S*V*V;
   function Numerator (S0,S1,S2 : Surface; V0,V1,V2 : Normalized_Rate) return Numerator_Value
     with Global => null, Inline, Post => Numerator'Result = Numerator_Part(S0,V0)+Numerator_Part(S1,V1)+Numerator_Part(S2,V2);
   function Coefficient (S : Surface; Inv : Inverse_Value) return Projection_Coefficient
     with Global => null, Inline, Post => Coefficient'Result = S*Inv;
   function Denominator_Part (C : Projection_Coefficient; V : Normalized_Rate) return Denominator_Term
     with Global => null, Inline, Post => Denominator_Part'Result = C*C*V*V;
   function Denominator (C0,C1,C2 : Projection_Coefficient; V0,V1,V2 : Normalized_Rate) return Denominator_Value
     with Global => null, Inline, Post => Denominator'Result = Denominator_Part(C0,V0)+Denominator_Part(C1,V1)+Denominator_Part(C2,V2);
   function Normal (C : Projection_Coefficient; V : Normalized_Rate) return Normal_Value
     with Global => null, Inline, Post => Normal'Result = C*V;
   function Norm_Squared (X,Y,Z : Norm_Input) return Norm_Squared_Value
     with Global => null, Inline, Post => Norm_Squared'Result = (X*X+Y*Y)+Z*Z;
   function Projected_Area (Dmax : Nonneg_Tier0; Root : Area_Root) return Area_Value
     with Global => null, Inline, Post => Projected_Area'Result = Pi*Dmax*Dmax*Root;
   function Linear_Drag (Viscosity,Density,Blunt,Slender : Nonneg_Tier0; Lin_Visc : MJ.Fluid_Geometry.Linear_Viscous; Speed : Speed_Value; Aproj : Area_Value; Amax : MJ.Fluid_Geometry.Area_Value) return Drag_Value
     with Global => null, Inline, Post => Linear_Drag'Result = Viscosity*Lin_Visc+Density*Speed*(Aproj*Blunt+Slender*(Amax-Aproj));
   function Moment (W : Rate; M : Angular_Moment) return Norm_Input
     with Global => null, Inline, Post => Moment'Result = W*M;
   function Angular_Drag (Viscosity,Density : Nonneg_Tier0; Ang_Visc : MJ.Fluid_Geometry.Angular_Viscous; Root : Area_Root) return Drag_Value
     with Global => null, Inline, Post => Angular_Drag'Result = Viscosity*Ang_Visc+Density*Root;
   function Projection_Product (PN : Numerator_Value; PD : Denominator_Value) return Root_Argument
     with Global => null, Inline, Post => Projection_Product'Result = PN*PD;
   -- The runtime contract supplies nonnegativity, but no quantitative upper
   -- bound. Callers must still establish the range of each square-root result.
   function Norm (X,Y,Z : Norm_Input) return Real
     with Global => null, Inline,
     Post => Norm'Result >= 0.0 and then Norm'Result =
       Ada.Numerics.Long_Elementary_Functions.Sqrt(Norm_Squared(X,Y,Z));
end MJ.Fluid_Projection;

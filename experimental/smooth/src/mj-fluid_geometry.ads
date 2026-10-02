with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with Ada.Numerics;
package MJ.Fluid_Geometry with SPARK_Mode is
   Pi : constant Real := Ada.Numerics.Pi;
   subtype Mid_Value is Real range -1.0e11 .. 1.0e11;
   subtype Volume_Value is Real range 0.0 .. 1.0e32;
   subtype Area_Value is Real range -1.0e24 .. 1.0e24;
   subtype Diameter_Value is Real range 0.0 .. 3.0e10;
   subtype Linear_Viscous is Real range 0.0 .. 1.0e13;
   subtype Angular_Viscous is Real range 0.0 .. 1.0e33;
   subtype Normalized_Axis is Real range 0.0 .. 1.1;
   subtype Surface_Value is Real range 0.0 .. 2.0;
   subtype Moment_Value is Real range -1.0e52 .. 1.0e52;
   subtype Angular_Value is Real range -1.0e63 .. 1.0e63;
   function Volume (X,Y,Z : Nonneg_Tier0) return Volume_Value
     with Global => null, Inline,
     Post => Volume'Result = 4.0/3.0*Pi*X*Y*Z;
   function Middle (X,Y,Z : Nonneg_Tier0) return Mid_Value
     with Global => null, Inline,
     Post => Middle'Result = X+Y+Z-Real'Max(Real'Max(X,Y),Z)-Real'Min(Real'Min(X,Y),Z);
   function Area (Dmax : Nonneg_Tier0; Dmid : Mid_Value) return Area_Value
     with Global => null, Inline,
     Post => Area'Result = Pi*Dmax*Dmid;
   function Normalize_Axis (X,Dmax : Nonneg_Tier0) return Normalized_Axis
     with Global => null, Inline,
     Pre => X <= Dmax,
     Post => Normalize_Axis'Result = (if Dmax > Min_Val then (1.0/Dmax)*X else 0.0);
   function Surface (X,Y : Normalized_Axis) return Surface_Value
     with Global => null, Inline,
     Post => Surface'Result = (X*Y)*(X*Y);
   function Diameter (X,Y,Z : Nonneg_Tier0) return Diameter_Value
     with Global => null, Inline,
     Post => Diameter'Result = 2.0/3.0*(X+Y+Z);
   function Linear_Viscosity (D : Diameter_Value) return Linear_Viscous
     with Global => null, Inline,
     Post => Linear_Viscosity'Result = 3.0*Pi*D;
   function Angular_Viscosity (D : Diameter_Value) return Angular_Viscous
     with Global => null, Inline,
     Post => Angular_Viscosity'Result = Pi*D*D*D;
   function Moment (Dmid : Mid_Value; Dmax : Nonneg_Tier0) return Moment_Value
     with Global => null, Inline,
     Post => Moment'Result = 8.0/15.0*Pi*Dmid*((Dmax*Dmax)*(Dmax*Dmax));
   function Angular_Moment (Angular,Slender : Nonneg_Tier0; II,Imax : Moment_Value) return Angular_Value
     with Global => null, Inline,
     Post => Angular_Moment'Result = Angular*II+Slender*(Imax-II);
   function Surface_From_Size (X,Y,Z : Nonneg_Tier0) return Surface_Value
     with Global => null, Inline,
     Post => Surface_From_Size'Result = Surface(
       Normalize_Axis(Y,Real'Max(Real'Max(X,Y),Z)),
       Normalize_Axis(Z,Real'Max(Real'Max(X,Y),Z)));
   function Moment_From_Size (Angular,Slender,X,Y,Z : Nonneg_Tier0;
                              Imax : Moment_Value) return Angular_Value
     with Global => null, Inline,
     Post => Moment_From_Size'Result =
       Angular_Moment(Angular,Slender,Moment(X,Real'Max(Y,Z)),Imax);
end MJ.Fluid_Geometry;

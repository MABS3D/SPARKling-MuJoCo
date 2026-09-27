package body MJ.Fluid_Geometry with SPARK_Mode is
   function Volume (X,Y,Z : Nonneg_Tier0) return Volume_Value is
   begin
      return 4.0/3.0*Pi*X*Y*Z;
   end Volume;
   function Middle (X,Y,Z : Nonneg_Tier0) return Mid_Value is
   begin
      return X+Y+Z-Real'Max(Real'Max(X,Y),Z)-Real'Min(Real'Min(X,Y),Z);
   end Middle;
   function Area (Dmax : Nonneg_Tier0; Dmid : Mid_Value) return Area_Value is
   begin
      return Pi*Dmax*Dmid;
   end Area;
   function Normalize_Axis (X,Dmax : Nonneg_Tier0) return Normalized_Axis is
      Inv : Real;
   begin
      if Dmax > Min_Val then
         Inv := 1.0/Dmax;
         pragma Assert (Inv*Dmax <= 1.1);
         return Inv*X;
      else
         return 0.0;
      end if;
   end Normalize_Axis;
   function Surface (X,Y : Normalized_Axis) return Surface_Value is
   begin
      return (X*Y)*(X*Y);
   end Surface;
   function Diameter (X,Y,Z : Nonneg_Tier0) return Diameter_Value is
   begin
      return 2.0/3.0*(X+Y+Z);
   end Diameter;
   function Linear_Viscosity (D : Diameter_Value) return Linear_Viscous is
   begin
      return 3.0*Pi*D;
   end Linear_Viscosity;
   function Angular_Viscosity (D : Diameter_Value) return Angular_Viscous is
   begin
      return Pi*D*D*D;
   end Angular_Viscosity;
   function Moment (Dmid : Mid_Value; Dmax : Nonneg_Tier0) return Moment_Value is
   begin
      return 8.0/15.0*Pi*Dmid*((Dmax*Dmax)*(Dmax*Dmax));
   end Moment;
   function Angular_Moment (Angular,Slender : Nonneg_Tier0; II,Imax : Moment_Value) return Angular_Value is
   begin
      return Angular*II+Slender*(Imax-II);
   end Angular_Moment;
   function Surface_From_Size (X,Y,Z : Nonneg_Tier0) return Surface_Value is
      Dmax : constant Nonneg_Tier0 := Real'Max(Real'Max(X,Y),Z);
      NY : constant Normalized_Axis := Normalize_Axis(Y,Dmax);
      NZ : constant Normalized_Axis := Normalize_Axis(Z,Dmax);
   begin
      return Surface(NY,NZ);
   end Surface_From_Size;
   function Moment_From_Size (Angular,Slender,X,Y,Z : Nonneg_Tier0;
                              Imax : Moment_Value) return Angular_Value is
      II : constant Moment_Value := Moment(X,Real'Max(Y,Z));
   begin
      return Angular_Moment(Angular,Slender,II,Imax);
   end Moment_From_Size;
end MJ.Fluid_Geometry;

with Ada.Numerics.Long_Elementary_Functions;
with MJ.Fluid_Added_Mass;
package body MJ.Fluid_Kernels with SPARK_Mode is
   function Prepare_Ellipsoid (P : Ellipsoid_Parameters) return Ellipsoid_Cache is
      S : Vector renames P.Size;
      R : Ellipsoid_Cache;
      Dmin, Dmid, Inv_Dmax, Diameter, Imax : Real;
      SN : Vector;
   begin
      R.Volume := 4.0/3.0*Pi*S(0)*S(1)*S(2);
      R.Dmax := Real'Max (Real'Max(S(0),S(1)),S(2));
      Dmin := Real'Min (Real'Min(S(0),S(1)),S(2));
      Dmid := S(0)+S(1)+S(2)-R.Dmax-Dmin;
      R.Amax := Pi*R.Dmax*Dmid;
      Inv_Dmax := (if R.Dmax > Min_Val then 1.0/R.Dmax else 0.0);
      SN := Inv_Dmax*S;
      R.Surface := [(SN(1)*SN(2))*(SN(1)*SN(2)),
                    (SN(2)*SN(0))*(SN(2)*SN(0)),
                    (SN(0)*SN(1))*(SN(0)*SN(1))];
      Diameter := 2.0/3.0*(S(0)+S(1)+S(2));
      R.Lin_Visc := 3.0*Pi*Diameter;
      R.Ang_Visc := Pi*Diameter*Diameter*Diameter;
      Imax := 8.0/15.0*Pi*Dmid*Fourth(R.Dmax);
      for I in Axis loop
         declare
            II : constant Real := 8.0/15.0*Pi*S(I)*Fourth(Real'Max(S((I+1) mod 3),S((I+2) mod 3)));
         begin
            R.Angular_Moment(I) := P.Angular*II + P.Slender*(Imax-II);
         end;
      end loop;
      return R;
   end Prepare_Ellipsoid;

   function Blend_Force (Added, Magnus, Kutta, Drag : Blend_Input;
                         Speed : Rate; Interaction : Nonneg_Tier0) return Blend_Value is
   begin
      return (Added + (Magnus+Kutta-Drag*Speed))*Interaction;
   end Blend_Force;
   function Blend_Torque (Added, Drag : Blend_Input; Speed : Rate;
                          Interaction : Nonneg_Tier0) return Blend_Value is
   begin
      return (Added-Drag*Speed)*Interaction;
   end Blend_Torque;

   function Ellipsoid (P : Ellipsoid_Parameters; Cache : Ellipsoid_Cache; Density, Viscosity : Nonneg_Tier0;
                        Linear, Angular : Vector) return Wrench is
      use Ada.Numerics.Long_Elementary_Functions;
      Volume : constant Real := Cache.Volume;
      Dmax : constant Real := Cache.Dmax;
      Amax : constant Real := Cache.Amax;
      Speed : constant Real := Sqrt (Dot (Linear, Linear));
      Inv_Speed : constant Real := (if Speed > Min_Val then 1.0/Speed else 0.0);
      V : constant Vector := Inv_Speed * Linear;
      Araw : constant Real := Cache.Surface(0);
      Braw : constant Real := Cache.Surface(1);
      Craw : constant Real := Cache.Surface(2);
      PN : constant Real := Araw*V(0)*V(0) + Braw*V(1)*V(1) + Craw*V(2)*V(2);
      Inv_PN : constant Real := (if PN > Min_Val then 1.0/PN else 0.0);
      A : constant Real := Araw*Inv_PN;
      B : constant Real := Braw*Inv_PN;
      C : constant Real := Craw*Inv_PN;
      PD : constant Real := A*A*V(0)*V(0) + B*B*V(1)*V(1) + C*C*V(2)*V(2);
      Aproj : constant Real := Pi*Dmax*Dmax*Sqrt (PN*PD);
      Normal : constant Vector := [A*V(0),B*V(1),C*V(2)];
      Cos_Alpha : constant Real := (if PD > Min_Val then 1.0/PD else 0.0);
      Magnus : constant Vector := (P.Magnus*Density*Volume) * Cross (Angular, Linear);
      Circulation : constant Vector := (P.Kutta*Density*Cos_Alpha*Aproj) * Cross (Normal, Linear);
      Kutta : constant Vector := Cross (Circulation, Linear);
      Lin_Visc : constant Real := Cache.Lin_Visc;
      Ang_Visc : constant Real := Cache.Ang_Visc;
      Mom : Vector;
      R : Wrench;
      Drag_Lin : constant Real := Viscosity*Lin_Visc + Density*Speed*
        (Aproj*P.Blunt + P.Slender*(Amax-Aproj));
      Drag_Ang : Real;
   begin
      for I in Axis loop
         Mom(I) := Angular(I)*Cache.Angular_Moment(I);
      end loop;
      Drag_Ang := Viscosity*Ang_Visc + Density*Sqrt (Dot (Mom,Mom));
      R := MJ.Fluid_Added_Mass.Evaluate (Density,P.Virtual_Mass,P.Virtual_Inertia,Linear,Angular);
      for I in Axis loop
         R.Torque(I) := Blend_Torque(R.Torque(I),Drag_Ang,Angular(I),P.Interaction);
         R.Force(I) := Blend_Force(R.Force(I),Magnus(I),Kutta(I),Drag_Lin,Linear(I),P.Interaction);
      end loop;
      return R;
   end Ellipsoid;
end MJ.Fluid_Kernels;

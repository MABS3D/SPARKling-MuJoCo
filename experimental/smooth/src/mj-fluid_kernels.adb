with Ada.Numerics.Long_Elementary_Functions;
with MJ.Fluid_Added_Mass;
with MJ.Fluid_Lift;
with MJ.Fluid_Projection;
package body MJ.Fluid_Kernels with SPARK_Mode is
   function Prepare_Ellipsoid (P : Ellipsoid_Parameters) return Ellipsoid_Cache is
      package G renames MJ.Fluid_Geometry;
      S : Vector renames P.Size;
      Dmax : constant Nonneg_Tier0 := Real'Max(Real'Max(S(0),S(1)),S(2));
      Dmid : constant G.Mid_Value := G.Middle(S(0),S(1),S(2));
      D : constant G.Diameter_Value := G.Diameter(S(0),S(1),S(2));
      Imax : constant G.Moment_Value := G.Moment(Dmid,Dmax);
   begin
      return (Volume => G.Volume(S(0),S(1),S(2)), Dmax => Dmax,
              Amax => G.Area(Dmax,Dmid), Lin_Visc => G.Linear_Viscosity(D),
              Ang_Visc => G.Angular_Viscosity(D),
              Surface => [G.Surface_From_Size(S(0),S(1),S(2)),G.Surface_From_Size(S(1),S(2),S(0)),G.Surface_From_Size(S(2),S(0),S(1))],
              Angular_Moment => [
                G.Moment_From_Size(P.Angular,P.Slender,S(0),S(1),S(2),Imax),
                G.Moment_From_Size(P.Angular,P.Slender,S(1),S(2),S(0),Imax),
                G.Moment_From_Size(P.Angular,P.Slender,S(2),S(0),S(1),Imax)]);
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
      package F renames MJ.Fluid_Projection;
      type Magnus_Vector is array (Axis) of MJ.Fluid_Lift.Magnus_Value;
      type Kutta_Vector is array (Axis) of MJ.Fluid_Lift.Lift_Value;
      Volume : constant MJ.Fluid_Geometry.Volume_Value := Cache.Volume;
      Dmax : constant Nonneg_Tier0 := Cache.Dmax;
      Amax : constant MJ.Fluid_Geometry.Area_Value := Cache.Amax;
      Speed : constant Real := F.Norm(Linear(0),Linear(1),Linear(2));
      Inv_Speed : constant F.Inverse_Value := F.Inverse(Speed);
      V : constant Vector := [F.Normalize(Inv_Speed,Linear(0)),F.Normalize(Inv_Speed,Linear(1)),F.Normalize(Inv_Speed,Linear(2))];
      Araw : constant F.Surface := Cache.Surface(0);
      Braw : constant F.Surface := Cache.Surface(1);
      Craw : constant F.Surface := Cache.Surface(2);
      PN : constant F.Numerator_Value := F.Numerator(Araw,Braw,Craw,V(0),V(1),V(2));
      Inv_PN : constant F.Numerator_Value := F.Inverse(PN);
      A : constant F.Projection_Coefficient := F.Coefficient(Araw,Inv_PN);
      B : constant F.Projection_Coefficient := F.Coefficient(Braw,Inv_PN);
      C : constant F.Projection_Coefficient := F.Coefficient(Craw,Inv_PN);
      PD : constant F.Denominator_Value := F.Denominator(A,B,C,V(0),V(1),V(2));
      Aproj : constant F.Area_Value := F.Projected_Area(Dmax,Sqrt(F.Projection_Product(PN,PD)));
      Normal : constant Vector := [F.Normal(A,V(0)),F.Normal(B,V(1)),F.Normal(C,V(2))];
      Cos_Alpha : constant F.Inverse_Value := F.Inverse(PD);
      Magnus_Raw : constant Vector := MJ.Fluid_Lift.Magnus(P.Magnus,Density,Volume,Linear,Angular);
      Magnus : constant Magnus_Vector := [Magnus_Raw(0),Magnus_Raw(1),Magnus_Raw(2)];
      Circulation : constant Vector := MJ.Fluid_Lift.Circulation(P.Kutta,Density,Cos_Alpha,Aproj,Normal,Linear);
      Kutta_Raw : constant Vector := MJ.Fluid_Lift.Kutta(Circulation,Linear);
      Kutta : constant Kutta_Vector := [Kutta_Raw(0),Kutta_Raw(1),Kutta_Raw(2)];
      Lin_Visc : constant MJ.Fluid_Geometry.Linear_Viscous := Cache.Lin_Visc;
      Ang_Visc : constant MJ.Fluid_Geometry.Angular_Viscous := Cache.Ang_Visc;
      Mom : Vector;
      R : Wrench;
      Drag_Lin : constant F.Drag_Value := F.Linear_Drag(Viscosity,Density,P.Blunt,P.Slender,Lin_Visc,Speed,Aproj,Amax);
      Drag_Ang : F.Drag_Value;
   begin
      for I in Axis loop
         Mom(I) := F.Moment(Angular(I),Cache.Angular_Moment(I));
      end loop;
      Drag_Ang := F.Angular_Drag(Viscosity,Density,Ang_Visc,F.Norm(Mom(0),Mom(1),Mom(2)));
      R := MJ.Fluid_Added_Mass.Evaluate (Density,P.Virtual_Mass,P.Virtual_Inertia,Linear,Angular);
      for I in Axis loop
         R.Torque(I) := Blend_Torque(R.Torque(I),Drag_Ang,Angular(I),P.Interaction);
         R.Force(I) := Blend_Force(R.Force(I),Magnus(I),Kutta(I),Drag_Lin,Linear(I),P.Interaction);
      end loop;
      return R;
   end Ellipsoid;
end MJ.Fluid_Kernels;

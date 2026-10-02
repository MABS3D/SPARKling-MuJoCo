with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with Ada.Numerics;
with MJ.Fluid_Box;
with MJ.Fluid_Geometry;
with MJ.Spatial_Kernels;
package MJ.Fluid_Kernels with SPARK_Mode is
   type Vector_Array is array (Natural range <>) of Vector;
   type Motion_Array is array (Natural range <>) of MJ.Spatial_Kernels.Motion;
   function Motions_Bounded (Values : Motion_Array) return Boolean is
     (for all V of Values => MJ.Spatial_Kernels.Bounded (V, 1.0e12))
     with Global => null;
   No_Motions : constant Motion_Array := [1 .. 0 => [others => 0.0]];
   Pi : constant Real := Ada.Numerics.Pi;
   subtype Dimension is Real range 0.0 .. 1.0e14;
   subtype Rate is Real range -1.0e12 .. 1.0e12;
   subtype Fluid_Value is Real range -1.0e110 .. 1.0e110;
   subtype Wrench is MJ.Fluid_Box.Wrench;
   use type MJ.Fluid_Box.Wrench;
   subtype Box_Coefficients is MJ.Fluid_Box.Coefficients;
   type Ellipsoid_Cache is record
      Volume, Dmax, Amax, Lin_Visc, Ang_Visc : Real := 0.0;
      Surface, Angular_Moment : Vector := Zero;
   end record;
   type Ellipsoid_Parameters is record
      Size : Vector := Zero;
      Interaction, Blunt, Slender, Angular, Kutta, Magnus : Nonneg_Tier0 := 0.0;
      Virtual_Mass, Virtual_Inertia : Vector := Zero;
   end record;
   function Fourth (X : Dimension) return Real is ((X*X)*(X*X))
     with Global => null, Post => Fourth'Result in 0.0 .. 2.0e56;
   function Prepare_Box (Box : Vector; Density, Viscosity : Nonneg_Tier0) return Box_Coefficients
     renames MJ.Fluid_Box.Prepare;
   function Apply_Box (C : Box_Coefficients; Linear, Angular : Vector) return Wrench
     renames MJ.Fluid_Box.Evaluate;
   function Cache_Bounded (C : Ellipsoid_Cache) return Boolean is
     (C.Volume in 0.0 .. 1.0e32 and then C.Dmax in 0.0 .. Max_Val
      and then C.Amax in -1.0e24 .. 1.0e24
      and then C.Lin_Visc in 0.0 .. 1.0e13 and then C.Ang_Visc in 0.0 .. 1.0e33
      and then (for all X of C.Surface => X in 0.0 .. 2.0)
      and then Bounded(C.Angular_Moment,1.0e63)) with Global => null;
   function Prepare_Ellipsoid (P : Ellipsoid_Parameters) return Ellipsoid_Cache
     with Global => null, Pre => (P.Size(0) in Nonneg_Tier0 and then P.Size(1) in Nonneg_Tier0 and then P.Size(2) in Nonneg_Tier0),
     Post => Cache_Bounded(Prepare_Ellipsoid'Result)
       and then Prepare_Ellipsoid'Result.Volume = MJ.Fluid_Geometry.Volume(P.Size(0),P.Size(1),P.Size(2))
       and then Prepare_Ellipsoid'Result.Amax = MJ.Fluid_Geometry.Area(Real'Max(Real'Max(P.Size(0),P.Size(1)),P.Size(2)),MJ.Fluid_Geometry.Middle(P.Size(0),P.Size(1),P.Size(2)))
       and then Prepare_Ellipsoid'Result.Lin_Visc = MJ.Fluid_Geometry.Linear_Viscosity(MJ.Fluid_Geometry.Diameter(P.Size(0),P.Size(1),P.Size(2)))
       and then Prepare_Ellipsoid'Result.Ang_Visc = MJ.Fluid_Geometry.Angular_Viscosity(MJ.Fluid_Geometry.Diameter(P.Size(0),P.Size(1),P.Size(2)))
       and then Prepare_Ellipsoid'Result.Dmax = Real'Max(Real'Max(P.Size(0),P.Size(1)),P.Size(2));
   pragma Postcondition (Prepare_Ellipsoid'Result.Surface(0) = MJ.Fluid_Geometry.Surface_From_Size(P.Size(0),P.Size(1),P.Size(2)));
   pragma Postcondition (Prepare_Ellipsoid'Result.Angular_Moment(0) = MJ.Fluid_Geometry.Moment_From_Size(P.Angular,P.Slender,P.Size(0),P.Size(1),P.Size(2),MJ.Fluid_Geometry.Moment(MJ.Fluid_Geometry.Middle(P.Size(0),P.Size(1),P.Size(2)),Real'Max(Real'Max(P.Size(0),P.Size(1)),P.Size(2)))));
   pragma Postcondition (Prepare_Ellipsoid'Result.Surface(1) = MJ.Fluid_Geometry.Surface_From_Size(P.Size(1),P.Size(2),P.Size(0)));
   pragma Postcondition (Prepare_Ellipsoid'Result.Angular_Moment(1) = MJ.Fluid_Geometry.Moment_From_Size(P.Angular,P.Slender,P.Size(1),P.Size(2),P.Size(0),MJ.Fluid_Geometry.Moment(MJ.Fluid_Geometry.Middle(P.Size(0),P.Size(1),P.Size(2)),Real'Max(Real'Max(P.Size(0),P.Size(1)),P.Size(2)))));
   pragma Postcondition (Prepare_Ellipsoid'Result.Surface(2) = MJ.Fluid_Geometry.Surface_From_Size(P.Size(2),P.Size(0),P.Size(1)));
   pragma Postcondition (Prepare_Ellipsoid'Result.Angular_Moment(2) = MJ.Fluid_Geometry.Moment_From_Size(P.Angular,P.Slender,P.Size(2),P.Size(0),P.Size(1),MJ.Fluid_Geometry.Moment(MJ.Fluid_Geometry.Middle(P.Size(0),P.Size(1),P.Size(2)),Real'Max(Real'Max(P.Size(0),P.Size(1)),P.Size(2)))));
   subtype Blend_Value is Real range -1.0e250 .. 1.0e250;
   subtype Blend_Input is Real range -1.0e220 .. 1.0e220;
   function Blend_Force (Added, Magnus, Kutta, Drag : Blend_Input;
                         Speed : Rate; Interaction : Nonneg_Tier0) return Blend_Value
     with Global => null,
     Post => Blend_Force'Result = (Added + (Magnus+Kutta-Drag*Speed))*Interaction;
   function Blend_Torque (Added, Drag : Blend_Input; Speed : Rate;
                          Interaction : Nonneg_Tier0) return Blend_Value
     with Global => null,
     Post => Blend_Torque'Result = (Added-Drag*Speed)*Interaction;
   function Ellipsoid (P : Ellipsoid_Parameters; Cache : Ellipsoid_Cache; Density, Viscosity : Nonneg_Tier0;
                        Linear, Angular : Vector) return Wrench
     with Global => null,
     Pre => Cache_Bounded(Cache)
       and then Bounded (Linear, 1.0e12) and then Bounded (Angular, 1.0e12)
       and then (P.Size(0) in Nonneg_Tier0 and then P.Size(1) in Nonneg_Tier0 and then P.Size(2) in Nonneg_Tier0)
       and then Bounded (P.Virtual_Mass, Max_Val) and then Bounded (P.Virtual_Inertia, Max_Val);
   --  Metadata is frozen at Create, so geometric quantities are computed once.
   type Element is record
      Body_Id : Natural := 0;
      Inverse_Mass : Real := 0.0;
      Position : Vector := Zero;
      Rotation : Matrix := Identity;
      Is_Ellipsoid : Boolean := False;
      Box : Vector := Zero;
      Parameters : Ellipsoid_Parameters;
      Box_Data : Box_Coefficients;
      Ellipsoid_Data : Ellipsoid_Cache;
   end record;
   function Element_Valid (E : Element; Nb : Natural) return Boolean is
     (E.Body_Id > 0 and then E.Body_Id < Nb
      and then E.Inverse_Mass in 0.0 .. 2.0e15
      and then Bounded (E.Position, Max_Val) and then Bounded (E.Rotation, 8.0)
      and then (if E.Is_Ellipsoid then Cache_Bounded (E.Ellipsoid_Data)
        and then (for all X of E.Parameters.Size => X in Nonneg_Tier0)
        and then Bounded (E.Parameters.Virtual_Mass, Max_Val)
        and then Bounded (E.Parameters.Virtual_Inertia, Max_Val)))
     with Global => null;
   type Element_Array is array (Natural range <>) of Element;
   type Element_Access is access Element_Array;
   function Storage_Valid (Elements : Element_Access; Nb : Natural) return Boolean is
     (Elements = null or else (Elements'First = 0
       and then (for all E of Elements.all => Element_Valid (E, Nb))))
     with Global => null;
end MJ.Fluid_Kernels;


with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
package MJ.Rigid_CCD with SPARK_Mode is
   function Convex (A, B : Shape; PA, PB : Pose; Margin : Real; O : Options) return Decision
     with Global => null, Pre => A.Kind /= Plane and B.Kind /= Plane;
end MJ.Rigid_CCD;

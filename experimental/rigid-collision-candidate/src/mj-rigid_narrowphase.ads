with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

package MJ.Rigid_Narrowphase with SPARK_Mode is
   function Plane_Distance (A, B : Shape; PA, PB : Pose) return Real
     with Global => null, Pre => A.Kind = Plane and B.Kind /= Plane;
   function Test (A, B : Shape; PA, PB : Pose; Margin : Real; O : Options) return Decision
     with Global => null, Pre => Valid_Shape (A) and Valid_Shape (B)
       and Valid_Placement (A, PA) and Valid_Placement (B, PB) and Margin in 0.0 .. 1.0e12;
end MJ.Rigid_Narrowphase;

with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

package MJ.Rigid_Primitives with SPARK_Mode is
   function Sphere_Pair (A, B : Vec; RA, RB, Margin : Real) return Boolean
     with Global => null;
   function Sphere_Cylinder (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean
     with Global => null, Pre => A.Kind = Sphere and B.Kind = Cylinder;
   function Capsule_Capsule (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean
     with Global => null, Pre => A.Kind = Capsule and B.Kind = Capsule
       and A.Size (1) > 0.0 and B.Size (1) > 0.0;
   function Capsule_Box (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean
     with Global => null, Pre => A.Kind = Capsule and B.Kind = Box;
   function Box_Box (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean
     with Global => null, Pre => A.Kind = Box and B.Kind = Box;
end MJ.Rigid_Primitives;

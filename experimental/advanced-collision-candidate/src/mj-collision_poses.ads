with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
package MJ.Collision_Poses with SPARK_Mode is
   type Quaternion is array (Natural range 0 .. 3) of Real;
   function From_Matrix (R : Matrix) return Quaternion with Global => null,
     Pre => Valid_Pose ((Position=>Zero,Rotation=>R,others=><>));
   function To_Matrix (Q : Quaternion) return Matrix with Global => null;
   function Rotate (Q : Quaternion; V : Vec) return Vec with Global => null;
   function Relative (A, B : Pose) return Pose with Global => null,
     Pre => Valid_Pose (A) and Valid_Pose (B);
end MJ.Collision_Poses;

with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

package MJ.Rigid_Support with SPARK_Mode is
   function Support (S : Shape; P : Pose; Direction : Vec) return Vec
     with Inline, Global => null, Pre => S.Kind /= Plane and then Valid_Shape (S);
   function Radius (S : Shape) return Real with Global => null;
   procedure Bounds (S : Shape; P : Pose; Lo, Hi : out Vec)
     with Global => null, Pre => S.Kind /= Plane and then Valid_Shape (S);
   procedure Projection_Bounds (S : Shape; P : Pose; Lo, Hi : out Real)
     with Global => null;
end MJ.Rigid_Support;

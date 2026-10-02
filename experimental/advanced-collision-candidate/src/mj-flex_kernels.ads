with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
package MJ.Flex_Kernels with SPARK_Mode is
   subtype Triangle_Vertices is Vertex_Array (0 .. 2);
   function Bounded (V : Triangle_Vertices) return Boolean is
     (for all P of V => (for all X of P => X in -1.0e10 .. 1.0e10));
   function Sign (X : Real) return Real is (if X > 0.0 then 1.0 elsif X < 0.0 then -1.0 else 0.0)
     with Global => null,
       Post => (if X > 0.0 then Sign'Result = 1.0 elsif X < 0.0 then Sign'Result = -1.0 else Sign'Result = 0.0);
   procedure Sphere_Triangle (Center : Vec; Radius : Real; V : Triangle_Vertices;
                              Skin, Margin : Real; M : in out Manifold)
     with Global => null, Pre => Bounded (V) and Radius in 0.0 .. 1.0e10
       and Skin in 0.0 .. 1.0e10 and Margin in 0.0 .. 1.0e10
       and (for all X of Center => X in -1.0e10 .. 1.0e10),
       Post => M.Length <= 1;
   procedure Box_Triangle (P : Pose; Size : Vec; V : Triangle_Vertices;
                           Skin, Margin : Real; M : in out Manifold)
     with Global => null, Pre => Valid_Pose (P) and Bounded (V)
       and (for all X of Size => X in 0.0 .. 1.0e10)
       and Skin in 0.0 .. 1.0e10 and Margin in 0.0 .. 1.0e10,
       Post => M.Length <= 11;
   procedure Capsule_Triangle (P : Pose; Radius, Half_Length : Real; V : Triangle_Vertices;
                               Skin, Margin : Real; M : in out Manifold)
     with Global => null, Pre => Valid_Pose (P) and Bounded (V)
       and Radius in 0.0 .. 1.0e10 and Half_Length in 0.0 .. 1.0e10
       and Skin in 0.0 .. 1.0e10 and Margin in 0.0 .. 1.0e10,
       Post => M.Length <= 5;
   procedure Plane_Vertex (V : Triangle_Vertices; Point : Vec; Radius : Real;
                           C : out MJ.Contact_Geometry.Contact; Hit : out Boolean)
     with Global => null, Pre => Bounded (V) and Radius in 0.0 .. 1.0e10
       and (for all X of Point => X in -1.0e10 .. 1.0e10);
   procedure Capsule_From_Segment (A, B : Vec; Radius : Real; S : out Shape; P : out Pose)
     with Global => null, Pre => Radius in 0.0 .. 1.0e10
       and (for all X of A => X in -1.0e10 .. 1.0e10)
       and (for all X of B => X in -1.0e10 .. 1.0e10);
end MJ.Flex_Kernels;

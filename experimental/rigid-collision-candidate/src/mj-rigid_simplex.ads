with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;

package MJ.Rigid_Simplex with SPARK_Mode is
   type Vertices is array (Natural range 0 .. 3) of Vec;
   type Coefficients is array (Natural range 0 .. 3) of Real;
   function Determinant (A, B, C : Vec) return Real with Global => null;
   procedure Projection (A, B, C : Vec; P : out Vec; Degenerate : out Boolean) with Global => null;
   procedure Affine (A, B, C, P : Vec; Cof : out Vec; Minor : out Real) with Global => null;
   procedure Segment (A, B : Vec; L : out Coefficients) with Global => null;
   procedure Triangle (A, B, C : Vec; L : out Coefficients) with Global => null;
   procedure Closest (V : Vertices; N : Positive; L : out Coefficients)
     with Global => null, Pre => N <= 4;
   function Combination (V : Vertices; L : Coefficients) return Vec with Global => null;
   function Strict_Tetrahedron (A, B, C, D : Vec) return Boolean with Global => null;
end MJ.Rigid_Simplex;

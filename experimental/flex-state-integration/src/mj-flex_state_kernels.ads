with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
package MJ.Flex_State_Kernels with SPARK_Mode is
   function Component (P, A, B, C, X, Y, Z : Real) return Real
     with Global => null,
       Pre => P in -1.0e10 .. 1.0e10
         and A in -1.1 .. 1.1 and B in -1.1 .. 1.1 and C in -1.1 .. 1.1
         and X in -1.0e10 .. 1.0e10 and Y in -1.0e10 .. 1.0e10 and Z in -1.0e10 .. 1.0e10,
       Post => Component'Result in -5.0e10 .. 5.0e10
         and Component'Result = ((A * X + B * Y) + C * Z) + P;
   function Point (P : Pose; Local : Vec; Centered : Boolean) return Vec
     with Global => null,
       Pre => P.Position (0) in Coordinate and P.Position (1) in Coordinate and P.Position (2) in Coordinate
         and Local (0) in Coordinate and Local (1) in Coordinate and Local (2) in Coordinate
         and P.Rotation (0) in -1.1 .. 1.1 and P.Rotation (1) in -1.1 .. 1.1 and P.Rotation (2) in -1.1 .. 1.1
         and P.Rotation (3) in -1.1 .. 1.1 and P.Rotation (4) in -1.1 .. 1.1 and P.Rotation (5) in -1.1 .. 1.1
         and P.Rotation (6) in -1.1 .. 1.1 and P.Rotation (7) in -1.1 .. 1.1 and P.Rotation (8) in -1.1 .. 1.1,
       Post => Point'Result (0) in -5.0e10 .. 5.0e10 and Point'Result (1) in -5.0e10 .. 5.0e10
         and Point'Result (2) in -5.0e10 .. 5.0e10
         and Point'Result (0) = (if Centered or Local = Zero then P.Position (0) else
           Component (P.Position (0),P.Rotation (0),P.Rotation (1),P.Rotation (2),Local (0),Local (1),Local (2)))
         and Point'Result (1) = (if Centered or Local = Zero then P.Position (1) else
           Component (P.Position (1),P.Rotation (3),P.Rotation (4),P.Rotation (5),Local (0),Local (1),Local (2)))
         and Point'Result (2) = (if Centered or Local = Zero then P.Position (2) else
           Component (P.Position (2),P.Rotation (6),P.Rotation (7),P.Rotation (8),Local (0),Local (1),Local (2)));
   function Rotation_Component (A, B, C, X, Y, Z : Real) return Matrix_Entry
     with Global => null,
       Pre => A in -1.1 .. 1.1 and B in -1.1 .. 1.1 and C in -1.1 .. 1.1
         and X in -1.1 .. 1.1 and Y in -1.1 .. 1.1 and Z in -1.1 .. 1.1,
       Post => Rotation_Component'Result = (A*X + B*Y) + C*Z;
   function Compose (A, B : Matrix) return Matrix
     with Global => null,
       Pre => A (0) in -1.1 .. 1.1
         and then A (1) in -1.1 .. 1.1
         and then A (2) in -1.1 .. 1.1
         and then A (3) in -1.1 .. 1.1
         and then A (4) in -1.1 .. 1.1
         and then A (5) in -1.1 .. 1.1
         and then A (6) in -1.1 .. 1.1
         and then A (7) in -1.1 .. 1.1
         and then A (8) in -1.1 .. 1.1
         and then B (0) in -1.1 .. 1.1
         and then B (1) in -1.1 .. 1.1
         and then B (2) in -1.1 .. 1.1
         and then B (3) in -1.1 .. 1.1
         and then B (4) in -1.1 .. 1.1
         and then B (5) in -1.1 .. 1.1
         and then B (6) in -1.1 .. 1.1
         and then B (7) in -1.1 .. 1.1
         and then B (8) in -1.1 .. 1.1,
       Post => Compose'Result (0) = Rotation_Component
           (A (0), A (1), A (2), B (0), B (3), B (6))
         and then Compose'Result (1) = Rotation_Component
           (A (0), A (1), A (2), B (1), B (4), B (7))
         and then Compose'Result (2) = Rotation_Component
           (A (0), A (1), A (2), B (2), B (5), B (8))
         and then Compose'Result (3) = Rotation_Component
           (A (3), A (4), A (5), B (0), B (3), B (6))
         and then Compose'Result (4) = Rotation_Component
           (A (3), A (4), A (5), B (1), B (4), B (7))
         and then Compose'Result (5) = Rotation_Component
           (A (3), A (4), A (5), B (2), B (5), B (8))
         and then Compose'Result (6) = Rotation_Component
           (A (6), A (7), A (8), B (0), B (3), B (6))
         and then Compose'Result (7) = Rotation_Component
           (A (6), A (7), A (8), B (1), B (4), B (7))
         and then Compose'Result (8) = Rotation_Component
           (A (6), A (7), A (8), B (2), B (5), B (8));
end MJ.Flex_State_Kernels;

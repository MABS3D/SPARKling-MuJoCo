package body MJ.Flex_State_Kernels with SPARK_Mode is
   function Component (P, A, B, C, X, Y, Z : Real) return Real is
   begin
      return ((A*X + B*Y) + C*Z) + P;
   end Component;
   function Point (P : Pose; Local : Vec; Centered : Boolean) return Vec is
   begin
      if Centered or Local = Zero then return P.Position; end if;
      return [Component (P.Position (0),P.Rotation (0),P.Rotation (1),P.Rotation (2),Local (0),Local (1),Local (2)),
        Component (P.Position (1),P.Rotation (3),P.Rotation (4),P.Rotation (5),Local (0),Local (1),Local (2)),
        Component (P.Position (2),P.Rotation (6),P.Rotation (7),P.Rotation (8),Local (0),Local (1),Local (2))];
   end Point;
   function Rotation_Component (A, B, C, X, Y, Z : Real) return Matrix_Entry is
   begin
      return (A*X + B*Y) + C*Z;
   end Rotation_Component;
   function Compose (A, B : Matrix) return Matrix is
   begin
      --  Nine fixed-size entries preserve the ordered products and make the
      --  complete component relation explicit at the proof boundary.
      return [Rotation_Component (A (0), A (1), A (2), B (0), B (3), B (6)),
        Rotation_Component (A (0), A (1), A (2), B (1), B (4), B (7)),
        Rotation_Component (A (0), A (1), A (2), B (2), B (5), B (8)),
        Rotation_Component (A (3), A (4), A (5), B (0), B (3), B (6)),
        Rotation_Component (A (3), A (4), A (5), B (1), B (4), B (7)),
        Rotation_Component (A (3), A (4), A (5), B (2), B (5), B (8)),
        Rotation_Component (A (6), A (7), A (8), B (0), B (3), B (6)),
        Rotation_Component (A (6), A (7), A (8), B (1), B (4), B (7)),
        Rotation_Component (A (6), A (7), A (8), B (2), B (5), B (8))];
   end Compose;
end MJ.Flex_State_Kernels;

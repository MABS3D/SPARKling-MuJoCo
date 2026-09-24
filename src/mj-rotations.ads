--  Fixed-size vector rotations. All arithmetic lives in the existing kernels.
with MJ.Types; use MJ.Types;
with MJ.BLAS;
with MJ.Quaternions;
with MJ.Matrix_Types;
with MJ.Matrices;
package MJ.Rotations with SPARK_Mode is
   use type MJ.Quaternions.Quaternion;
   subtype Vector_3 is MJ.BLAS.Vector_3;
   subtype Quaternion is MJ.Quaternions.Quaternion;
   subtype Matrix_3 is MJ.Matrix_Types.Matrix_3;
   subtype Axis is Natural range 0 .. 2;

   --  A fixed-size value constructor; release inlining removes the return copy.
   function Conjugated (Q : Quaternion) return Quaternion is
     ([Q (0), -Q (1), -Q (2), -Q (3)])
     with Inline_Always, Global => null, Pre => MJ.Quaternions.In_Tier0 (Q),
     Post => Conjugated'Result = [Q (0), -Q (1), -Q (2), -Q (3)]
       and then MJ.Quaternions.In_Tier0 (Conjugated'Result);

   package Model with Ghost => Static is
      function Matrix_Component (A : Matrix_3; V : Vector_3; I : Axis;
                                 Transposed : Boolean) return Tier1_Real is
        (if Transposed then MJ.Matrices.Dot_3
           (A (0, I), A (1, I), A (2, I), V (0), V (1), V (2))
         else MJ.Matrices.Dot_3
           (A (I, 0), A (I, 1), A (I, 2), V (0), V (1), V (2)))
        with Global => null, Pre => MJ.Matrix_Types.In_Tier0 (A)
          and then MJ.BLAS.In_Tier0 (V);
   end Model;

   --  Separate-result actual parameters must be disjoint under SPARK rules.
   procedure Rotate (R : out Vector_3; Q : Quaternion; V : Vector_3) with
     Inline_Always, Global => null, Relaxed_Initialization => R,
     Pre => MJ.Quaternions.In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => R'Initialized and then (for all I in Axis =>
       R (I) in Tier2_Real and then
       R (I) = MJ.Quaternions.Model.Rotated_Component (Q, V, I)));

   procedure Rotate (V : in out Vector_3; Q : Quaternion) with
     Inline_Always, Global => null,
     Pre => MJ.Quaternions.In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => (for all I in Axis => V (I) in Tier2_Real and then
       V (I) = MJ.Quaternions.Model.Rotated_Component (Q, V'Old, I)));

   --  Apply the conjugate; an inverse rotation requires a unit quaternion.
   --  No normalization or division is hidden in this operation.
   procedure Rotate_Conjugate (R : out Vector_3; Q : Quaternion; V : Vector_3) with
     Inline_Always, Global => null, Relaxed_Initialization => R,
     Pre => MJ.Quaternions.In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => R'Initialized and then (for all I in Axis =>
       R (I) in Tier2_Real and then R (I) =
       MJ.Quaternions.Model.Rotated_Component (Conjugated (Q), V, I)));

   procedure Rotate_Conjugate (V : in out Vector_3; Q : Quaternion) with
     Inline_Always, Global => null,
     Pre => MJ.Quaternions.In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => (for all I in Axis => V (I) in Tier2_Real and then
       V (I) = MJ.Quaternions.Model.Rotated_Component
         (Conjugated (Q), V'Old, I)));

   --  Matrices are row-major. These contracts allow any Tier0 matrix;
   --  a geometric rotation additionally requires a proper rotation matrix.
   procedure Rotate (R : out Vector_3; A : Matrix_3; V : Vector_3) with
     Inline_Always, Global => null, Relaxed_Initialization => R,
     Pre => MJ.Matrix_Types.In_Tier0 (A) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => R'Initialized and then MJ.BLAS.In_Tier1 (R)
       and then (for all I in Axis => R (I) = Model.Matrix_Component (A, V, I, False)));

   procedure Rotate (V : in out Vector_3; A : Matrix_3) with
     Inline_Always, Global => null,
     Pre => MJ.Matrix_Types.In_Tier0 (A) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => MJ.BLAS.In_Tier1 (V) and then
       (for all I in Axis => V (I) = Model.Matrix_Component (A, V'Old, I, False)));

   --  Apply A transpose without building a temporary matrix.
   --  It is an inverse rotation when A is orthogonal, up to FP rounding.
   procedure Rotate_Transpose (R : out Vector_3; A : Matrix_3; V : Vector_3) with
     Inline_Always, Global => null, Relaxed_Initialization => R,
     Pre => MJ.Matrix_Types.In_Tier0 (A) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => R'Initialized and then MJ.BLAS.In_Tier1 (R)
       and then (for all I in Axis => R (I) = Model.Matrix_Component (A, V, I, True)));

   procedure Rotate_Transpose (V : in out Vector_3; A : Matrix_3) with
     Inline_Always, Global => null,
     Pre => MJ.Matrix_Types.In_Tier0 (A) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => MJ.BLAS.In_Tier1 (V) and then
       (for all I in Axis => V (I) = Model.Matrix_Component (A, V'Old, I, True)));
end MJ.Rotations;

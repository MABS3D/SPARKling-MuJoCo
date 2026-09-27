--  Scalar-first (w,x,y,z), fixed storage, no normalization hidden in arithmetic.
with MJ.Quaternion_Math;
with MJ.Types; use MJ.Types;
with MJ.BLAS;
with MJ.Matrix_Types;
package MJ.Quaternions with SPARK_Mode is
   subtype Component is Natural range 0 .. 3;
   type Quaternion is array (Component) of Real;
   W : constant Component := 0;
   X : constant Component := 1;
   Y : constant Component := 2;
   Z : constant Component := 3;
   Identity : constant Quaternion := [1.0, 0.0, 0.0, 0.0];
   subtype Vector_3 is MJ.BLAS.Vector_3;
   subtype Matrix_3 is MJ.Matrix_Types.Matrix_3;
   subtype Axis is Natural range 0 .. 2;
   subtype Nonnegative_Real is MJ.BLAS.Nonnegative_Real;

   function In_Tier0 (Q : Quaternion) return Boolean is
     (for all E of Q => E in Tier0_Real) with Global => null;
   function In_Tier1 (Q : Quaternion) return Boolean is
     (for all E of Q => E in Tier1_Real) with Global => null;
   function In_Tier2 (Q : Quaternion) return Boolean is
     (for all E of Q => E in Tier2_Real) with Global => null;
   function Is_Identity (Q : Quaternion) return Boolean is
     (Q (W) = 1.0 and then Q (X) = 0.0 and then Q (Y) = 0.0 and then Q (Z) = 0.0)
     with Inline_Always, Global => null;

   --  Executable kernels never evaluate these specification functions.
   package Model with Ghost => Static is
      function Product_Component (A, B : Quaternion; I : Component) return Tier1_Real is
        (case I is
         when 0 => ((A (0)*B (0) - A (1)*B (1)) - A (2)*B (2)) - A (3)*B (3),
         when 1 => ((A (0)*B (1) + A (1)*B (0)) + A (2)*B (3)) - A (3)*B (2),
         when 2 => ((A (0)*B (2) - A (1)*B (3)) + A (2)*B (0)) + A (3)*B (1),
         when 3 => ((A (0)*B (3) + A (1)*B (2)) - A (2)*B (1)) + A (3)*B (0))
        with Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B);
      function Rotation_Intermediate (Q : Quaternion; V : Vector_3; I : Axis) return Tier1_Real is
        (case I is
         when 0 => (Q (0)*V (0) + Q (2)*V (2)) - Q (3)*V (1),
         when 1 => (Q (0)*V (1) + Q (3)*V (0)) - Q (1)*V (2),
         when 2 => (Q (0)*V (2) + Q (1)*V (1)) - Q (2)*V (0))
        with Global => null, Pre => In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V);
      function Rotated_Component (Q : Quaternion; V : Vector_3; I : Axis) return Tier2_Real is
        (if V (0) = 0.0 and then V (1) = 0.0 and then V (2) = 0.0 then 0.0
         elsif Is_Identity (Q) then V (I)
         else (case I is
          when 0 => V (0) + 2.0 * (Q (2) * Rotation_Intermediate (Q, V, 2)
                                 - Q (3) * Rotation_Intermediate (Q, V, 1)),
          when 1 => V (1) + 2.0 * (Q (3) * Rotation_Intermediate (Q, V, 0)
                                 - Q (1) * Rotation_Intermediate (Q, V, 2)),
          when 2 => V (2) + 2.0 * (Q (1) * Rotation_Intermediate (Q, V, 1)
                                 - Q (2) * Rotation_Intermediate (Q, V, 0))))
        with Global => null, Pre => In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V);
      function Matrix_Component (Q : Quaternion; I, J : Axis) return Tier1_Real is
        (if Is_Identity (Q) then (if I = J then 1.0 else 0.0)
         else (case 3 * I + J is
         when 0 => ((Q (0)*Q (0) + Q (1)*Q (1)) - Q (2)*Q (2)) - Q (3)*Q (3),
         when 1 => 2.0*(Q (1)*Q (2) - Q (0)*Q (3)),
         when 2 => 2.0*(Q (1)*Q (3) + Q (0)*Q (2)),
         when 3 => 2.0*(Q (1)*Q (2) + Q (0)*Q (3)),
         when 4 => ((Q (0)*Q (0) - Q (1)*Q (1)) + Q (2)*Q (2)) - Q (3)*Q (3),
         when 5 => 2.0*(Q (2)*Q (3) - Q (0)*Q (1)),
         when 6 => 2.0*(Q (1)*Q (3) - Q (0)*Q (2)),
         when 7 => 2.0*(Q (2)*Q (3) + Q (0)*Q (1)),
         when others => ((Q (0)*Q (0) - Q (1)*Q (1)) - Q (2)*Q (2)) + Q (3)*Q (3)))
        with Global => null, Annotate => (GNATprove, Inline_For_Proof), Pre => In_Tier0 (Q);
      function Scaled_Component (Value : Tier1_Real; Length : Real) return Tier2_Real is
        (Value * (1.0 / Length)) with Global => null, Pre => Length >= Min_Val,
        Post => (if Value in Tier0_Real then Scaled_Component'Result in Tier1_Real);
   end Model;

   procedure Set_Identity (R : out Quaternion) with Inline_Always, Global => null,
     Post => R = Identity;
   procedure Conjugate (R : out Quaternion; Q : Quaternion) with Inline_Always, Global => null,
     Post => R = [Q (W), -Q (X), -Q (Y), -Q (Z)];
   procedure Conjugate (Q : in out Quaternion) with Inline_Always, Global => null,
     Post => Q = [Q'Old (W), -Q'Old (X), -Q'Old (Y), -Q'Old (Z)];

   procedure Multiply (R : out Quaternion; A, B : Quaternion) with
     Inline_Always, Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => (Static => In_Tier1 (R) and then
       (for all I in Component => R (I) = Model.Product_Component (A, B, I)));
   --  Value-returning form for functional composition of fixed-size kernels.
   function Product (A, B : Quaternion) return Quaternion with
     Inline_Always, Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => (Static => In_Tier1 (Product'Result) and then
       (for all I in Component => Product'Result (I) = Model.Product_Component (A, B, I)));
   --  Q := Q * Right. Right is a distinct object under SPARK aliasing rules.
   procedure Multiply (Q : in out Quaternion; Right : Quaternion) with
     Inline_Always, Global => null, Pre => In_Tier0 (Q) and then In_Tier0 (Right),
     Post => (Static => In_Tier1 (Q) and then
       (for all I in Component => Q (I) = Model.Product_Component (Q'Old, Right, I)));

   function Norm (Q : Quaternion) return Nonnegative_Real with
     Inline_Always, Global => null, Pre => In_Tier1 (Q),
     Post => (Static => Norm'Result = MJ.Quaternion_Math.Sqrt
       (((Q (W)*Q (W) + Q (X)*Q (X)) + Q (Y)*Q (Y)) + Q (Z)*Q (Z)));
   --  Tier1 accepts products of Tier0 quaternions without an extra restriction
   --  on pose composition. The previous Tier0 input/output guarantee is retained.
   procedure Normalize (Q : in out Quaternion; Length : out Nonnegative_Real) with
     Inline_Always, Global => null, Pre => In_Tier1 (Q),
     Post => (Static => In_Tier2 (Q)
       and then (if In_Tier0 (Q'Old) then In_Tier1 (Q))
       and then Length = Norm (Q'Old)
       and then (if Length < Min_Val then Q = Identity
                 elsif abs (Length - 1.0) <= Min_Val then Q = Q'Old
                 else (for all I in Component => Q (I) = Model.Scaled_Component (Q'Old (I), Length))));

   --  Inputs need not be exactly unit length: these specify the actual C formulas.
   procedure Rotate (R : out Vector_3; Q : Quaternion; V : Vector_3) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => R'Initialized and then (for all I in Axis =>
       R (I) in Tier2_Real and then R (I) = Model.Rotated_Component (Q, V, I)));
   procedure To_Matrix (R : out Matrix_3; Q : Quaternion) with
     Inline_Always, Global => null,
     Pre => In_Tier0 (Q),
     Post => (Static => MJ.Matrix_Types.In_Tier1 (R)
       and then (for all I in Axis => (for all J in Axis => R (I, J) = Model.Matrix_Component (Q, I, J))));
end MJ.Quaternions;

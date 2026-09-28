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
   type Conversion_Status is (Success, Numeric_Limit);

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

      --  mju_mat2Quat: preserve the strict comparisons, tie order and rounded
      --  expressions. This specifies a conversion, not projection onto SO(3).
      function Matrix_Branch (D0, D1, D2 : Tier0_Real) return Component is
        (if (D0 + D1) + D2 > 0.0 then W
         elsif D0 > D1 and then D0 > D2 then X
         elsif D1 > D2 then Y else Z) with Global => null;
      function Matrix_Radicand (D0, D1, D2 : Tier0_Real;
                                Branch : Component) return Real is
        (case Branch is
         when W => ((1.0 + D0) + D1) + D2,
         when X => ((1.0 + D0) - D1) - D2,
         when Y => ((1.0 - D0) + D1) - D2,
         when Z => ((1.0 - D0) - D1) + D2)
        with Global => null,
        Pre => Branch = Matrix_Branch (D0, D1, D2),
        Post => Matrix_Radicand'Result in 0.0 .. 4.0e10,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Matrix_Pivot (A : Matrix_3) return Nonnegative_Real is
        (0.5 * MJ.Quaternion_Math.Sqrt (Matrix_Radicand
          (A (0, 0), A (1, 1), A (2, 2),
           Matrix_Branch (A (0, 0), A (1, 1), A (2, 2)))))
        with Global => null, Pre => MJ.Matrix_Types.In_Tier0 (A);
      function Matrix_Conversion_Safe (A : Matrix_3) return Boolean is
        (Matrix_Pivot (A) in Min_Val .. 1.0e15)
        with Global => null, Pre => MJ.Matrix_Types.In_Tier0 (A);
      function Matrix_Quotient (Left, Right : Tier0_Real;
                                Pivot : Real; Subtract : Boolean) return Tier1_Real is
        (if Subtract then (0.25 * (Left - Right)) / Pivot
         else (0.25 * (Left + Right)) / Pivot)
        with Global => null, Pre => Pivot in Min_Val .. 1.0e15,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Matrix_Raw (A : Matrix_3; Pivot : Real) return Quaternion is
        (case Matrix_Branch (A (0, 0), A (1, 1), A (2, 2)) is
         when W => [Pivot,
           Matrix_Quotient (A (2, 1), A (1, 2), Pivot, True),
           Matrix_Quotient (A (0, 2), A (2, 0), Pivot, True),
           Matrix_Quotient (A (1, 0), A (0, 1), Pivot, True)],
         when X => [Matrix_Quotient (A (2, 1), A (1, 2), Pivot, True), Pivot,
           Matrix_Quotient (A (0, 1), A (1, 0), Pivot, False),
           Matrix_Quotient (A (0, 2), A (2, 0), Pivot, False)],
         when Y => [Matrix_Quotient (A (0, 2), A (2, 0), Pivot, True),
           Matrix_Quotient (A (0, 1), A (1, 0), Pivot, False), Pivot,
           Matrix_Quotient (A (1, 2), A (2, 1), Pivot, False)],
         when Z => [Matrix_Quotient (A (1, 0), A (0, 1), Pivot, True),
           Matrix_Quotient (A (0, 2), A (2, 0), Pivot, False),
           Matrix_Quotient (A (1, 2), A (2, 1), Pivot, False), Pivot])
        with Global => null,
        Pre => MJ.Matrix_Types.In_Tier0 (A) and then Pivot in Min_Val .. 1.0e15,
        Post => In_Tier1 (Matrix_Raw'Result),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Normalization_Length (Q : Quaternion) return Nonnegative_Real is
        (MJ.Quaternion_Math.Sqrt
          (((Q (W)*Q (W) + Q (X)*Q (X)) + Q (Y)*Q (Y)) + Q (Z)*Q (Z)))
        with Global => null, Pre => In_Tier1 (Q),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Normalized_Component (Q : Quaternion; I : Component) return Tier2_Real is
        (if Normalization_Length (Q) < Min_Val then Identity (I)
         elsif abs (Normalization_Length (Q) - 1.0) <= Min_Val then Q (I)
         else Scaled_Component (Q (I), Normalization_Length (Q)))
        with Global => null, Pre => In_Tier1 (Q);
      function Normalized (Q : Quaternion) return Quaternion is
        ([Normalized_Component (Q, W), Normalized_Component (Q, X),
          Normalized_Component (Q, Y), Normalized_Component (Q, Z)])
        with Global => null, Pre => In_Tier1 (Q),
        Post => In_Tier2 (Normalized'Result),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
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

   --  Row-major matrix to scalar-first quaternion, followed by normalize4.
   --  No orthogonality precondition: bounded non-rotation matrices retain C's
   --  algorithmic behavior. The limited runtime Sqrt contract requires checking
   --  its pivot before division. Numeric_Limit returns Identity explicitly.
   procedure From_Matrix (R : out Quaternion; A : Matrix_3;
                          Result : out Conversion_Status) with
     Inline_Always, Global => null, Pre => MJ.Matrix_Types.In_Tier0 (A),
     Post => (Static => In_Tier2 (R)
       and then (Result = Success) = Model.Matrix_Conversion_Safe (A)
       and then (if Result = Success then
         R = Model.Normalized (Model.Matrix_Raw (A, Model.Matrix_Pivot (A)))
         else R = Identity));
end MJ.Quaternions;

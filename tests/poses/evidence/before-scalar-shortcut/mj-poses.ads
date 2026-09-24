--  Fixed-storage pose primitives matching MuJoCo's ordered binary64 formulas.
with MJ.Types; use MJ.Types;
with MJ.BLAS;
with MJ.Quaternions;
with MJ.Rotations;
package MJ.Poses with SPARK_Mode is
   use type MJ.Quaternions.Quaternion;
   subtype Vector_3 is MJ.BLAS.Vector_3;
   subtype Quaternion is MJ.Quaternions.Quaternion;
   subtype Axis is MJ.Quaternions.Axis;
   subtype Component is MJ.Quaternions.Component;

   package Model with Ghost => Static is
      function Normalized_Component (Q : Quaternion; I : Component) return Tier2_Real is
        (if MJ.Quaternions.Norm (Q) < Min_Val then MJ.Quaternions.Identity (I)
         elsif abs (MJ.Quaternions.Norm (Q) - 1.0) <= Min_Val then Q (I)
         else MJ.Quaternions.Model.Scaled_Component (Q (I), MJ.Quaternions.Norm (Q)))
        with Global => null, Pre => MJ.Quaternions.In_Tier1 (Q);
      function Normalized (Q : Quaternion) return Quaternion is
        ([Normalized_Component (Q, 0), Normalized_Component (Q, 1),
          Normalized_Component (Q, 2), Normalized_Component (Q, 3)])
        with Global => null, Pre => MJ.Quaternions.In_Tier1 (Q);
      function Transformed_Component
        (Position : Vector_3; Q : Quaternion; Point : Vector_3; I : Axis) return Tier3_Real is
        (if MJ.Quaternions.Is_Identity (Q) then Point (I) + Position (I)
         else (case I is
          when 0 => (Point (0) + 2.0*(Q (2)*MJ.Quaternions.Model.Rotation_Intermediate (Q, Point, 2)
                                    - Q (3)*MJ.Quaternions.Model.Rotation_Intermediate (Q, Point, 1))) + Position (0),
          when 1 => (Point (1) + 2.0*(Q (3)*MJ.Quaternions.Model.Rotation_Intermediate (Q, Point, 0)
                                    - Q (1)*MJ.Quaternions.Model.Rotation_Intermediate (Q, Point, 2))) + Position (1),
          when 2 => (Point (2) + 2.0*(Q (1)*MJ.Quaternions.Model.Rotation_Intermediate (Q, Point, 1)
                                    - Q (2)*MJ.Quaternions.Model.Rotation_Intermediate (Q, Point, 0))) + Position (2)))
        with Global => null, Pre => MJ.BLAS.In_Tier0 (Position)
          and then MJ.Quaternions.In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (Point);
   end Model;

   --  Translation of a point: R = rotate(Q, Point) + Position, in that order.
   procedure Transform (R : out Vector_3; Position : Vector_3; Q : Quaternion; Point : Vector_3) with
     Inline_Always, Relaxed_Initialization => R, Global => null,
     Pre => MJ.BLAS.In_Tier0 (Position) and then MJ.Quaternions.In_Tier0 (Q)
       and then MJ.BLAS.In_Tier0 (Point),
     Post => (Static => R'Initialized and then (for all I in Axis => R (I) in Tier3_Real
       and then R (I) = Model.Transformed_Component (Position, Q, Point, I)));
   procedure Transform (Point : in out Vector_3; Position : Vector_3; Q : Quaternion) with
     Inline_Always, Global => null,
     Pre => MJ.BLAS.In_Tier0 (Position) and then MJ.Quaternions.In_Tier0 (Q)
       and then MJ.BLAS.In_Tier0 (Point),
     Post => (Static => (for all I in Axis => Point (I) in Tier3_Real
       and then Point (I) = Model.Transformed_Component (Position, Q, Point'Old, I)));

   --  MuJoCo mju_mulPose: quaternion product is normalized; position uses Q1.
   procedure Compose
     (Position : out Vector_3; Q : out Quaternion;
      Position_1 : Vector_3; Q1 : Quaternion; Position_2 : Vector_3; Q2 : Quaternion) with
     Inline_Always, Relaxed_Initialization => Position, Global => null,
     Pre => MJ.BLAS.In_Tier0 (Position_1) and then MJ.Quaternions.In_Tier0 (Q1)
       and then MJ.BLAS.In_Tier0 (Position_2) and then MJ.Quaternions.In_Tier0 (Q2),
     Post => (Static => Position'Initialized and then MJ.Quaternions.In_Tier2 (Q)
       and then Q = Model.Normalized (MJ.Quaternions.Product (Q1, Q2))
       and then (for all I in Axis => Position (I) in Tier3_Real
         and then Position (I) = Model.Transformed_Component (Position_1, Q1, Position_2, I)));
   --  Left pose is replaced; Right remains a distinct input object in SPARK.
   procedure Compose
     (Position : in out Vector_3; Q : in out Quaternion; Right_Position : Vector_3; Right_Q : Quaternion) with
     Inline_Always, Global => null,
     Pre => MJ.BLAS.In_Tier0 (Position) and then MJ.Quaternions.In_Tier0 (Q)
       and then MJ.BLAS.In_Tier0 (Right_Position) and then MJ.Quaternions.In_Tier0 (Right_Q),
     Post => (Static => MJ.Quaternions.In_Tier2 (Q)
       and then Q = Model.Normalized (MJ.Quaternions.Product (Q'Old, Right_Q))
       and then (for all I in Axis => Position (I) in Tier3_Real
         and then Position (I) = Model.Transformed_Component (Position'Old, Q'Old, Right_Position, I)));

   --  MuJoCo mju_negPose. Conjugation is a geometric inverse for unit input;
   --  the contract specifies the actual formula also for non-unit inputs.
   procedure Inverse
     (Position : out Vector_3; Q : out Quaternion; Source_Position : Vector_3; Source_Q : Quaternion) with
     Inline_Always, Relaxed_Initialization => Position, Global => null,
     Pre => MJ.BLAS.In_Tier0 (Source_Position) and then MJ.Quaternions.In_Tier0 (Source_Q),
     Post => (Static => Position'Initialized and then Q = MJ.Rotations.Conjugated (Source_Q) and then MJ.Quaternions.In_Tier0 (Q)
       and then (for all I in Axis => Position (I) in Tier2_Real
         and then Position (I) = -MJ.Quaternions.Model.Rotated_Component (MJ.Rotations.Conjugated (Source_Q), Source_Position, I)));
   procedure Inverse (Position : in out Vector_3; Q : in out Quaternion) with
     Inline_Always, Global => null,
     Pre => MJ.BLAS.In_Tier0 (Position) and then MJ.Quaternions.In_Tier0 (Q),
     Post => (Static => Q = MJ.Rotations.Conjugated (Q'Old) and then MJ.Quaternions.In_Tier0 (Q)
       and then (for all I in Axis => Position (I) in Tier2_Real
         and then Position (I) = -MJ.Quaternions.Model.Rotated_Component (MJ.Rotations.Conjugated (Q'Old), Position'Old, I)));
end MJ.Poses;

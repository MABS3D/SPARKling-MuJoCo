--  Bounded dense vector kernels aligned with MuJoCo 3.14.0.
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Types; use MJ.Types;
with MJ.Vector_Models;

package MJ.BLAS with SPARK_Mode is
   subtype Vector_3 is Real_Array (0 .. 2);
   subtype Vector_4 is Real_Array (0 .. 3);
   subtype Nonnegative_Real is Real range 0.0 .. Real'Last;

   function In_Tier0 (V : Real_Array) return Boolean is
     (for all I in V'Range => V (I) in Tier0_Real)
   with Global => null;

   function In_Tier1 (V : Real_Array) return Boolean is
     (for all I in V'Range => V (I) in Tier1_Real)
   with Global => null;

   --  Generic operations preserve array bounds, including null arrays.
   function Same_Bounds (A, B : Real_Array) return Boolean is
     (A'First = B'First and then A'Last = B'Last)
   with Global => null;

   function Zero3 return Vector_3 with
     Global => null, Post => Zero3'Result = [0.0, 0.0, 0.0];
   function Zero4 return Vector_4 with
     Global => null, Post => Zero4'Result = [0.0, 0.0, 0.0, 0.0];
   function Unit4 return Vector_4 with
     Global => null, Post => Unit4'Result = [1.0, 0.0, 0.0, 0.0];
   function Copy3 (A : Vector_3) return Vector_3 with
     Global => null, Post => Copy3'Result = A;
   function Copy4 (A : Vector_4) return Vector_4 with
     Global => null, Post => Copy4'Result = A;
   --  MuJoCo equality is a strict component-wise mjMINVAL comparison.
   function Equal3 (A, B : Vector_3) return Boolean with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => Equal3'Result =
       (for all I in A'Range => abs (A (I) - B (I)) < Min_Val);

   function Add3 (A, B : Vector_3) return Vector_3 with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (Add3'Result)
       and then (for all I in A'Range => Add3'Result (I) = A (I) + B (I));

   function Sub3 (A, B : Vector_3) return Vector_3 with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (Sub3'Result)
       and then (for all I in A'Range => Sub3'Result (I) = A (I) - B (I));

   function Scl3 (A : Vector_3; Scale : Tier0_Real) return Vector_3 with
     Global => null, Pre => In_Tier0 (A),
     Post => In_Tier1 (Scl3'Result)
       and then (for all I in A'Range => Scl3'Result (I) = A (I) * Scale);

   --  Scalar contract shared by scaled vector additions.
   function Scaled_Add (X, Y, Scale : Tier0_Real) return Tier1_Real with
     Global => null, Post => Scaled_Add'Result = X + (Y * Scale);

   function AddScl3 (A, B : Vector_3; Scale : Tier0_Real) return Vector_3 with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (AddScl3'Result)
       and then (for all I in A'Range => AddScl3'Result (I) = Scaled_Add (A (I), B (I), Scale));

   procedure AddTo3 (R : in out Vector_3; A : Vector_3) with
     Global => null, Pre => In_Tier0 (R) and then In_Tier0 (A),
     Post => In_Tier1 (R) and then R = Add3 (R'Old, A);

   procedure SubFrom3 (R : in out Vector_3; A : Vector_3) with
     Global => null, Pre => In_Tier0 (R) and then In_Tier0 (A),
     Post => In_Tier1 (R) and then R = Sub3 (R'Old, A);

   procedure AddToScl3 (R : in out Vector_3; A : Vector_3; Scale : Tier0_Real) with
     Global => null, Pre => In_Tier0 (R) and then In_Tier0 (A),
     Post => In_Tier1 (R) and then R = AddScl3 (R'Old, A, Scale);

   function Dot3 (A, B : Vector_3) return Tier1_Real with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => Dot3'Result = ((A (0) * B (0)) + (A (1) * B (1))) + (A (2) * B (2));

   --  Scalar 2x2 determinant used by the Cartesian cross product.
   function Det2 (A, B, C, D : Tier0_Real) return Tier1_Real with
     Global => null, Post => Det2'Result = (A * D) - (B * C);

   function Cross3 (A, B : Vector_3) return Vector_3 with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (Cross3'Result)
       and then Cross3'Result =
         [Det2 (A (1), A (2), B (1), B (2)),
          Det2 (A (2), A (0), B (2), B (0)),
          Det2 (A (0), A (1), B (0), B (1))];

   --  Norms also accept Tier1, so a Tier0 difference can be measured directly.
   --  Sqrt is the standard Ada runtime operation with its supplied SPARK contract.
   function Norm3 (A : Vector_3) return Nonnegative_Real with
     Global => null, Pre => In_Tier1 (A),
     Post => Norm3'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt
       (((A (0) * A (0)) + (A (1) * A (1))) + (A (2) * A (2)));
   function Norm4 (A : Vector_4) return Nonnegative_Real with
     Global => null, Pre => In_Tier1 (A),
     Post => Norm4'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt
       ((((A (0) * A (0)) + (A (1) * A (1))) + (A (2) * A (2))) + (A (3) * A (3)));
   function Dist3 (A, B : Vector_3) return Nonnegative_Real with
     Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => Dist3'Result = Norm3 (Sub3 (A, B));

   procedure Normalize3 (A : in out Vector_3; Length : out Nonnegative_Real) with
     Global => null, Pre => In_Tier0 (A),
     Post => (Static => In_Tier1 (A) and then Length = Norm3 (A'Old)
       and then (if Length < Min_Val then A = [1.0, 0.0, 0.0]
                 else (for all I in A'Range => A (I) = MJ.Vector_Models.Normalized_Component (A'Old (I), Length))));
   procedure Normalize4 (A : in out Vector_4; Length : out Nonnegative_Real) with
     Global => null, Pre => In_Tier0 (A),
     Post => (Static => In_Tier1 (A) and then Length = Norm4 (A'Old)
       and then (if Length < Min_Val then A = [1.0, 0.0, 0.0, 0.0]
                 elsif abs (Length - 1.0) <= Min_Val then A = A'Old
                 else (for all I in A'Range => A (I) = MJ.Vector_Models.Normalized_Component (A'Old (I), Length))));

   procedure Zero (R : out Real_Array) with
     Global => null, Post => (for all I in R'Range => R (I) = 0.0);
   procedure Fill (R : out Real_Array; Value : Real) with
     Global => null, Post => (for all I in R'Range => R (I) = Value);
   procedure Copy (R : out Real_Array; A : Real_Array) with
     Global => null, Pre => R'First = A'First and then R'Last = A'Last, Post => R = A;

   procedure Scl (R : out Real_Array; A : Real_Array; Scale : Tier0_Real) with
     Global => null, Relaxed_Initialization => R,
     Pre => R'First = A'First and then R'Last = A'Last and then In_Tier0 (A),
     Post => R'Initialized and then In_Tier1 (R) and then (for all I in R'Range => R (I) = A (I) * Scale);

   procedure Add (R : out Real_Array; A, B : Real_Array) with
     Global => null, Relaxed_Initialization => R,
     Pre => R'First = A'First and then R'Last = A'Last and then In_Tier0 (A)
       and then Same_Bounds (A, B) and then In_Tier0 (B),
     Post => R'Initialized and then In_Tier1 (R) and then (for all I in R'Range => R (I) = A (I) + B (I));

   procedure Sub (R : out Real_Array; A, B : Real_Array) with
     Global => null, Relaxed_Initialization => R,
     Pre => R'First = A'First and then R'Last = A'Last and then In_Tier0 (A)
       and then Same_Bounds (A, B) and then In_Tier0 (B),
     Post => R'Initialized and then In_Tier1 (R) and then (for all I in R'Range => R (I) = A (I) - B (I));

   procedure AddScl (R : out Real_Array; A, B : Real_Array; Scale : Tier0_Real) with
     Global => null, Relaxed_Initialization => R,
     Pre => R'First = A'First and then R'Last = A'Last and then In_Tier0 (A)
       and then Same_Bounds (A, B) and then In_Tier0 (B),
     Post => R'Initialized and then In_Tier1 (R) and then (for all I in R'Range => R (I) = Scaled_Add (A (I), B (I), Scale));

   procedure AddTo (R : in out Real_Array; A : Real_Array) with
     Global => null, Pre => R'First = A'First and then R'Last = A'Last and then In_Tier0 (A) and then In_Tier0 (R),
     Post => In_Tier1 (R) and then (for all I in R'Range => R (I) = R'Old (I) + A (I));

   procedure SubFrom (R : in out Real_Array; A : Real_Array) with
     Global => null, Pre => R'First = A'First and then R'Last = A'Last and then In_Tier0 (A) and then In_Tier0 (R),
     Post => In_Tier1 (R) and then (for all I in R'Range => R (I) = R'Old (I) - A (I));

   procedure AddToScl (R : in out Real_Array; A : Real_Array; Scale : Tier0_Real) with
     Global => null, Pre => R'First = A'First and then R'Last = A'Last and then In_Tier0 (A) and then In_Tier0 (R),
     Post => In_Tier1 (R) and then (for all I in R'Range => R (I) = Scaled_Add (R'Old (I), A (I), Scale));

   --  Reduction lengths are bounded by the existing model-size limit.
   --  Sum and L1 accumulate in index order; Dot uses MuJoCo's four lanes.
   --  Static contracts specify the exact floating-point recurrence, not real sums.
   function Sum (A : Real_Array) return Tier1_Real with
     Global => null, Pre => A'Length <= Max_Size and then In_Tier0 (A),
     Post => (Static => (if A'Length = 0 then Sum'Result = 0.0)
       and then Sum'Result = MJ.Vector_Models.Prefix_Sum (A, A'Length, False));
   function L1 (A : Real_Array) return Nonnegative_Real with
     Global => null, Pre => A'Length <= Max_Size and then In_Tier0 (A),
     Post => (Static => L1'Result <= Tier1_Real'Last
       and then (if A'Length = 0 then L1'Result = 0.0)
       and then L1'Result = MJ.Vector_Models.Prefix_Sum (A, A'Length, True));
   function Dot (A, B : Real_Array) return Tier1_Real with
     Global => null,
     Pre => A'Length <= Max_Size and then Same_Bounds (A, B)
       and then In_Tier0 (A) and then In_Tier0 (B),
     Post => (Static => (if A'Length = 0 then Dot'Result = 0.0)
       and then (if A = B then Dot'Result >= 0.0)
       and then Dot'Result = MJ.Vector_Models.Dot_Value (A, B));
   function Norm (A : Real_Array) return Nonnegative_Real with
     Global => null, Pre => A'Length <= Max_Size and then In_Tier0 (A),
     Post => Norm'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt (Dot (A, A));
   --  Unlike other generic operations, normalization requires a component
   --  in which to place MuJoCo's fallback unit vector.
   procedure Normalize (A : in out Real_Array; Length : out Nonnegative_Real) with
     Global => null,
     Pre => A'Length in 1 .. Max_Size and then In_Tier0 (A),
     Post => (Static => In_Tier1 (A) and then Length = Norm (A'Old)
       and then (if Length < Min_Val then
                   (for all I in A'Range => A (I) = (if I = A'First then 1.0 else 0.0))
                 else (for all I in A'Range => A (I) = MJ.Vector_Models.Normalized_Component (A'Old (I), Length))));
end MJ.BLAS;

--  Contracts bound machine arithmetic, not accumulated approximation error.
with MJ.Types; use MJ.Types;
with Ada.Numerics.Long_Elementary_Functions;

package MJ.Smooth_Math with SPARK_Mode is
   subtype Axis is Integer range 0 .. 2;
   type Vector is array (Axis) of Real;
   type Quaternion is array (Integer range 0 .. 3) of Real;
   type Matrix is array (Axis, Axis) of Real;

   Zero : constant Vector := [others => 0.0];
   Identity_Quaternion : constant Quaternion := [1.0, 0.0, 0.0, 0.0];
   Identity : constant Matrix :=
     [0 => [1.0, 0.0, 0.0], 1 => [0.0, 1.0, 0.0], 2 => [0.0, 0.0, 1.0]];

   --  Storage limits, not proved error bounds. Stage boundaries check them.
   Work_Limit : constant Real := 1.0e60;
   function Bounded (V : Vector; Limit : Real := Work_Limit) return Boolean is
     (V (0) in -Limit .. Limit and then V (1) in -Limit .. Limit
      and then V (2) in -Limit .. Limit)
   with Global => null, Pre => Limit >= 0.0;

   function Bounded (Q : Quaternion; Limit : Real) return Boolean is
     (Q (0) in -Limit .. Limit and then Q (1) in -Limit .. Limit
      and then Q (2) in -Limit .. Limit and then Q (3) in -Limit .. Limit)
     with Global => null, Pre => Limit >= 0.0;
   function Bounded (R : Matrix; Limit : Real) return Boolean is
     (R (0, 0) in -Limit .. Limit and then R (0, 1) in -Limit .. Limit
      and then R (0, 2) in -Limit .. Limit and then R (1, 0) in -Limit .. Limit
      and then R (1, 1) in -Limit .. Limit and then R (1, 2) in -Limit .. Limit
      and then R (2, 0) in -Limit .. Limit and then R (2, 1) in -Limit .. Limit
      and then R (2, 2) in -Limit .. Limit)
     with Global => null, Pre => Limit >= 0.0;
   --  Transient arithmetic may exceed the much smaller storage limit.
   function "+" (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e300) and then Bounded (B, 1.0e300),
     Post => Bounded ("+"'Result, 4.0e300)
       and then "+"'Result = [A (0) + B (0), A (1) + B (1), A (2) + B (2)];
   function "-" (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e300) and then Bounded (B, 1.0e300),
     Post => Bounded ("-"'Result, 4.0e300)
       and then "-"'Result = [A (0) - B (0), A (1) - B (1), A (2) - B (2)];
   function "-" (A : Vector) return Vector with Global => null,
     Post => "-"'Result = [-A (0), -A (1), -A (2)];
   function "*" (S : Real; V : Vector) return Vector with Global => null,
     Pre => S in -1.0e100 .. 1.0e100 and then Bounded (V, 1.0e200),
     Post => Bounded ("*"'Result, 4.0e300)
       and then "*"'Result = [S * V (0), S * V (1), S * V (2)];
   function Dot (A, B : Vector) return Real with Global => null,
     Pre => Bounded (A, 1.0e150) and then Bounded (B, 1.0e150),
     Post => Dot'Result in -8.0e300 .. 8.0e300
       and then Dot'Result = (A (0)*B (0) + A (1)*B (1)) + A (2)*B (2);
   function Cross (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e150) and then Bounded (B, 1.0e150),
     Post => Bounded (Cross'Result, 8.0e300)
       and then Cross'Result = [A (1)*B (2) - A (2)*B (1),
         A (2)*B (0) - A (0)*B (2), A (0)*B (1) - A (1)*B (0)];
   function Apply (R : Matrix; V : Vector) return Vector with Global => null,
     Pre => Bounded (R, 16.0) and then Bounded (V, 1.0e280),
     Post => Bounded (Apply'Result, 1.0e282)
       and then Apply'Result =
         [R (0, 0)*V (0) + R (0, 1)*V (1) + R (0, 2)*V (2),
          R (1, 0)*V (0) + R (1, 1)*V (1) + R (1, 2)*V (2),
          R (2, 0)*V (0) + R (2, 1)*V (1) + R (2, 2)*V (2)];
   function Apply_Transpose (R : Matrix; V : Vector) return Vector with Global => null,
     Pre => Bounded (R, 16.0) and then Bounded (V, 1.0e280),
     Post => Bounded (Apply_Transpose'Result, 1.0e282)
       and then Apply_Transpose'Result =
         [R (0, 0)*V (0) + R (1, 0)*V (1) + R (2, 0)*V (2),
          R (0, 1)*V (0) + R (1, 1)*V (1) + R (2, 1)*V (2),
          R (0, 2)*V (0) + R (1, 2)*V (1) + R (2, 2)*V (2)];
   function Multiply (A, B : Quaternion) return Quaternion with Global => null,
     Pre => Bounded (A, 2.0) and then Bounded (B, 2.0),
     Post => Bounded (Multiply'Result, 32.0)
       and then Multiply'Result (0) = A (0)*B (0) - A (1)*B (1) - A (2)*B (2) - A (3)*B (3)
       and then Multiply'Result (1) = A (0)*B (1) + A (1)*B (0) + A (2)*B (3) - A (3)*B (2)
       and then Multiply'Result (2) = A (0)*B (2) - A (1)*B (3) + A (2)*B (0) + A (3)*B (1)
       and then Multiply'Result (3) = A (0)*B (3) + A (1)*B (2) - A (2)*B (1) + A (3)*B (0);
   function Unit_Quaternion (Q : Quaternion) return Boolean is
     (Bounded (Q, 1.000001) and then
      abs (((Q (0)*Q (0) + Q (1)*Q (1)) + Q (2)*Q (2)) + Q (3)*Q (3) - 1.0)
        <= 64.0 * Real'Model_Epsilon) with Global => null;
   function Rotation (Q : Quaternion) return Matrix with Global => null,
     Pre => Unit_Quaternion (Q), Post => Bounded (Rotation'Result, 8.0)
       and then Rotation'Result (0, 0) = 1.0 - 2.0*(Q (2)*Q (2) + Q (3)*Q (3))
       and then Rotation'Result (0, 1) = 2.0*(Q (1)*Q (2) - Q (0)*Q (3))
       and then Rotation'Result (0, 2) = 2.0*(Q (1)*Q (3) + Q (0)*Q (2))
       and then Rotation'Result (1, 0) = 2.0*(Q (1)*Q (2) + Q (0)*Q (3))
       and then Rotation'Result (1, 1) = 1.0 - 2.0*(Q (1)*Q (1) + Q (3)*Q (3))
       and then Rotation'Result (1, 2) = 2.0*(Q (2)*Q (3) - Q (0)*Q (1))
       and then Rotation'Result (2, 0) = 2.0*(Q (1)*Q (3) - Q (0)*Q (2))
       and then Rotation'Result (2, 1) = 2.0*(Q (2)*Q (3) + Q (0)*Q (1))
       and then Rotation'Result (2, 2) = 1.0 - 2.0*(Q (1)*Q (1) + Q (2)*Q (2));
   function Unit_Vector (V : Vector) return Boolean is
     (Bounded (V, 1.000001)
      and then abs (Dot (V, V) - 1.0) <= 64.0 * Real'Model_Epsilon)
     with Global => null;
   function Axis_Angle (V : Vector; Angle : Real) return Quaternion
     with Global => null, Pre => Unit_Vector (V) and then Angle in -2.0e10 .. 2.0e10,
     Post => Bounded (Axis_Angle'Result, 1.000001)
       and then Axis_Angle'Result (0) = Ada.Numerics.Long_Elementary_Functions.Cos (0.5 * Angle)
       and then (for all I in Axis => Axis_Angle'Result (I + 1) =
         Ada.Numerics.Long_Elementary_Functions.Sin (0.5 * Angle) * V (I));
   function Scale_Of (V : Vector) return Real is
     (Real'Max (Real'Max (abs V (0), abs V (1)), abs V (2))) with Global => null;
   function Scale_Of (Q : Quaternion) return Real is
     (Real'Max (Real'Max (Real'Max (abs Q (0), abs Q (1)), abs Q (2)), abs Q (3)))
     with Global => null;
   function Scaled_Vector (V : Vector) return Vector with Global => null,
     Pre => Bounded (V) and then Scale_Of (V) > 0.0,
     Post => Bounded (Scaled_Vector'Result, 1.0)
       and then (for all I in Axis => Scaled_Vector'Result (I) = V (I) / Scale_Of (V));
   function Scaled_Quaternion (Q : Quaternion) return Quaternion with Global => null,
     Pre => Bounded (Q, Work_Limit) and then Scale_Of (Q) >= Min_Val,
     Post => Bounded (Scaled_Quaternion'Result, 1.0)
       and then (for all I in Q'Range => Scaled_Quaternion'Result (I) = Q (I) / Scale_Of (Q));
   function Scaled_Norm (V : Vector) return Real with Global => null,
     Pre => Bounded (V) and then Scale_Of (V) > 0.0,
     Post => Scaled_Norm'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt
       ((Scaled_Vector (V) (0)*Scaled_Vector (V) (0)
         + Scaled_Vector (V) (1)*Scaled_Vector (V) (1))
         + Scaled_Vector (V) (2)*Scaled_Vector (V) (2));
   function Scaled_Norm (Q : Quaternion) return Real with Global => null,
     Pre => Bounded (Q, Work_Limit) and then Scale_Of (Q) >= Min_Val,
     Post => Scaled_Norm'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt
       (((Scaled_Quaternion (Q) (0)*Scaled_Quaternion (Q) (0)
          + Scaled_Quaternion (Q) (1)*Scaled_Quaternion (Q) (1))
          + Scaled_Quaternion (Q) (2)*Scaled_Quaternion (Q) (2))
          + Scaled_Quaternion (Q) (3)*Scaled_Quaternion (Q) (3));
   --  Normalize once at the model boundary. Failure leaves the vector unchanged.
   procedure Normalize (V : in out Vector; Success : out Boolean)
     with Global => null, Post => (if Success then Unit_Vector (V)
       and then Bounded (V'Old) and then Scale_Of (V'Old) > 0.0
       and then Scaled_Norm (V'Old) in 1.0 .. 2.0
       and then (for all I in Axis => V (I) =
         Scaled_Vector (V'Old) (I) / Scaled_Norm (V'Old))
       else V = V'Old);
   procedure Normalize (Q : in out Quaternion; Success : out Boolean) with Global => null,
     Post => (if Success then Unit_Quaternion (Q)
       and then Bounded (Q'Old, Work_Limit) and then Scale_Of (Q'Old) >= Min_Val
       and then Scaled_Norm (Q'Old) in 1.0 .. 2.0
       and then (for all I in Q'Range => Q (I) =
         Scaled_Quaternion (Q'Old) (I) / Scaled_Norm (Q'Old))
       else Q = Q'Old);

   function Read_Vector (A : Real_Array; Offset : Natural) return Vector with
     Global => null,
     Pre => Offset >= A'First and then Int64 (Offset) + 2 <= Int64 (A'Last),
     Post => Read_Vector'Result = [A (Offset), A (Offset + 1), A (Offset + 2)];
   function Read_Quaternion (A : Real_Array; Offset : Natural) return Quaternion with
     Global => null,
     Pre => Offset >= A'First and then Int64 (Offset) + 3 <= Int64 (A'Last),
     Post => Read_Quaternion'Result = [A (Offset), A (Offset + 1), A (Offset + 2), A (Offset + 3)];
   procedure Write_Vector (A : in out Real_Array; Offset : Natural; V : Vector) with
     Global => null,
     Pre => Offset >= A'First and then Int64 (Offset) + 2 <= Int64 (A'Last),
     Post => (for all I in A'Range =>
       (if I in Offset .. Offset + 2 then A (I) = V (I - Offset) else A (I) = A'Old (I)));
private
   subtype Unit_Component is Real range -1.0 .. 1.0;
   --  Isolate the division theorem from vector indexing and max selection.
   function Unit_Ratio (X, Scale : Real) return Unit_Component with
     Global => null,
     Pre => Scale > 0.0 and then Scale <= Work_Limit and then X in -Scale .. Scale,
     Post => Unit_Ratio'Result = X / Scale;
end MJ.Smooth_Math;

with MJ.Trigonometry;
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Spatial_Kernels;
with MJ.Spatial_Dynamics;
package MJ.Manifold_Math with SPARK_Mode is
   use type MJ.Spatial_Kernels.Motion;
   --  Pipeline geometric predicate; normalization below uses the distinct
   --  C near-unit threshold on the original ordered norm.
   function Already_Normalized (Q : Quaternion) return Boolean with Global => null,
     Post => Already_Normalized'Result = Unit_Quaternion (Q);
   function Normalization_Length (Q : Quaternion) return Real is
     (Ada.Numerics.Long_Elementary_Functions.Sqrt
        (((Q (0)*Q (0) + Q (1)*Q (1)) + Q (2)*Q (2)) + Q (3)*Q (3)))
     with Global => null, Pre => Bounded (Q, Work_Limit),
       Post => Normalization_Length'Result in 0.0 .. 1.0e61;
   function Normalization_Unchanged (Q : Quaternion) return Boolean is
     (abs (Normalization_Length (Q)-1.0) <= Min_Val)
     with Global => null, Pre => Bounded (Q, Work_Limit);
   function Normalization_Component (X, N : Real) return Real
     with Global => null,
       Pre => X in -Work_Limit .. Work_Limit and then N in Min_Val .. 1.0e61,
       Post => Normalization_Component'Result in -1.0e76 .. 1.0e76
         and then Normalization_Component'Result = X * (1.0 / N);
   function Normalization_Value (Q : Quaternion; I : Natural) return Real is
     (if Normalization_Length (Q) < Min_Val then Identity_Quaternion (I)
      elsif Normalization_Unchanged (Q) then Q (I)
      else Normalization_Component (Q (I), Normalization_Length (Q)))
     with Ghost => Static, Global => null,
       Pre => Bounded (Q, Work_Limit) and then I <= 3;
   function Normalized (Q : Quaternion) return Quaternion with Global => null,
     Pre => Bounded (Q, Work_Limit), Post => Unit_Quaternion (Normalized'Result)
       and then (if Normalization_Unchanged (Q) then Normalized'Result = Q);
   pragma Postcondition (Static =>
     (for all I in Quaternion'Range => Normalized'Result (I) = Normalization_Value (Q, I)));
   --  MuJoCo uses a right multiplication: angular speeds are in the child frame.
   function Rotation_Increment (V : Vector; H : Nonneg_Tier0) return Quaternion
     with Global => null,
     Pre => Bounded (V, Max_Val),
     Post => Bounded (Rotation_Increment'Result, 1.000001);
   function Integrated (Q : Quaternion; V : Vector; H : Nonneg_Tier0) return Quaternion is
     (Multiply (Normalized (Q), Rotation_Increment (V, H))) with Global => null,
     Pre => Bounded (Q, Max_Val) and then Bounded (V, Max_Val),
     Post => Bounded (Integrated'Result, 32.0);
   function Rotation_Vector (Q : Quaternion) return Vector with Global => null,
     Pre => Bounded (Q, Work_Limit), Post => Bounded (Rotation_Vector'Result, 8.0);
   function Difference (Q, Reference : Quaternion) return Vector is
     (Rotation_Vector (Multiply
       ([Reference (0), -Reference (1), -Reference (2), -Reference (3)], Normalized (Q))))
     with Global => null, Pre => Bounded (Q, Max_Val) and then Unit_Quaternion (Reference),
     Post => Bounded (Difference'Result, 8.0);
   procedure Widen_Motion (V : MJ.Spatial_Kernels.Motion) with Ghost => Static, Global => null,
     Pre => MJ.Spatial_Kernels.Bounded (V, 1.0e12),
     Post => MJ.Spatial_Kernels.Bounded (V, 1.0e26);
   procedure Advance_Axis
     (Velocity, Acceleration : in out MJ.Spatial_Kernels.Motion;
      Derivative_Velocity, Axis : MJ.Spatial_Kernels.Motion;
      Speed : Tier0_Real; Translation : Boolean; Ok : out Boolean)
     with Global => null,
     Pre => MJ.Spatial_Kernels.Bounded (Velocity, 1.0e12)
       and then MJ.Spatial_Kernels.Bounded (Acceleration, 1.0e12)
       and then MJ.Spatial_Kernels.Bounded (Derivative_Velocity, 1.0e12)
       and then MJ.Spatial_Kernels.Bounded (Axis, 1.0e12)
       and then MJ.Spatial_Kernels.Bounded (Velocity, 1.0e26)
       and then MJ.Spatial_Kernels.Bounded (Acceleration, 1.0e26)
       and then MJ.Spatial_Kernels.Bounded (Axis, 1.0e26),
     Post => MJ.Spatial_Kernels.Bounded (Velocity, 1.0e12)
       and then MJ.Spatial_Kernels.Bounded (Acceleration, 1.0e12)
       and then (if Ok then
         Velocity = MJ.Spatial_Dynamics.Add_Scaled (Velocity'Old, Axis, Speed)
         and then Acceleration = (if Translation then Acceleration'Old else
           MJ.Spatial_Dynamics.Add_Scaled (Acceleration'Old,
             MJ.Spatial_Dynamics.Cross_Motion (Derivative_Velocity, Axis), Speed)));
   pragma Inline_Always (Normalization_Length, Normalization_Component, Normalization_Unchanged, Already_Normalized, Normalized, Rotation_Increment, Rotation_Vector, Advance_Axis);
end MJ.Manifold_Math;

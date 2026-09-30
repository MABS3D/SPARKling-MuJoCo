with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Spatial_Kernels;
with MJ.Spatial_Dynamics;
package MJ.Manifold_Math with SPARK_Mode is
   use type MJ.Spatial_Kernels.Motion;
   --  Reuse the existing checked near-unit tolerance (64 model epsilons).
   --  Already normalized inputs are preserved; all others use the original
   --  scaled normalization, including the tiny-norm identity fallback.
   function Already_Normalized (Q : Quaternion) return Boolean with Global => null,
     Post => Already_Normalized'Result = Unit_Quaternion (Q);
   function Normalized (Q : Quaternion) return Quaternion with Global => null,
     Pre => Bounded (Q, Work_Limit), Post => Unit_Quaternion (Normalized'Result)
       and then (if Already_Normalized (Q) then Normalized'Result = Q);
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
   pragma Inline_Always (Already_Normalized, Normalized, Rotation_Increment, Rotation_Vector, Advance_Axis);
end MJ.Manifold_Math;

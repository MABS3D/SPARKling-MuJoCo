with Ada.Numerics.Long_Elementary_Functions;
package body MJ.Manifold_Math with SPARK_Mode is
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Spatial_Kernels.Bounded);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
   use type MJ.Spatial_Kernels.Motion;
   package E renames Ada.Numerics.Long_Elementary_Functions;
   function Already_Normalized (Q : Quaternion) return Boolean is
   begin
      return Unit_Quaternion (Q);
   end Already_Normalized;
   function Normalized (Q : Quaternion) return Quaternion is
      R : Quaternion := Q;
      Ok : Boolean;
      N : Real;
   begin
      if Already_Normalized (Q) then return Q; end if;
      --  The threshold is the norm, not the largest component: four small
      --  components can still form a nonvanishing MuJoCo quaternion.
      if Scale_Of (Q) < Min_Val then
         N := E.Sqrt (((Q (0)*Q (0) + Q (1)*Q (1)) + Q (2)*Q (2)) + Q (3)*Q (3));
         if N < Min_Val then return Identity_Quaternion; end if;
         declare
            subtype Tiny is Real range -Min_Val .. Min_Val;
            Q0 : constant Tiny := Q (0); Q1 : constant Tiny := Q (1);
            Q2 : constant Tiny := Q (2); Q3 : constant Tiny := Q (3);
         begin
            R := [Q0/Min_Val, Q1/Min_Val, Q2/Min_Val, Q3/Min_Val];
         end;
      end if;
      Normalize (R, Ok);
      return (if Ok then R else Identity_Quaternion);
   end Normalized;
   function Rotation_Increment (V : Vector; H : Nonneg_Tier0) return Quaternion is
      N : constant Real := E.Sqrt ((V (0)*V (0) + V (1)*V (1)) + V (2)*V (2));
      Direction : Vector := [1.0, 0.0, 0.0];
      Angle : Real := H * N;
      R : Quaternion;
   begin
      if N >= Min_Val then
         Direction := [V (0)/N, V (1)/N, V (2)/N];
      else
         --  normalize3 returns zero for a vector shorter than mjMINVAL.
         Angle := 0.0;
      end if;
      declare
         Sine : constant Real := E.Sin (0.5 * Angle);
      begin
         R := [E.Cos (0.5 * Angle), Sine*Direction (0),
               Sine*Direction (1), Sine*Direction (2)];
      end;
      return R;
   end Rotation_Increment;
   function Rotation_Vector (Q : Quaternion) return Vector is
      R : constant Quaternion := Normalized (Q);
      N : constant Real := E.Sqrt ((R (1)*R (1) + R (2)*R (2)) + R (3)*R (3));
      Angle, Scale : Real;
   begin
      if N < Min_Val then return Zero; end if;
      Angle := 2.0 * E.Arctan (N, R (0));
      if Angle > Ada.Numerics.Pi then Angle := Angle - 2.0 * Ada.Numerics.Pi; end if;
      Scale := Angle / N;
      return [Scale * R (1), Scale * R (2), Scale * R (3)];
   end Rotation_Vector;
   procedure Widen_Motion (V : MJ.Spatial_Kernels.Motion) is
   begin
      null;
   end Widen_Motion;
   procedure Advance_Axis
     (Velocity, Acceleration : in out MJ.Spatial_Kernels.Motion;
      Derivative_Velocity, Axis : MJ.Spatial_Kernels.Motion;
      Speed : Tier0_Real; Translation : Boolean; Ok : out Boolean)
   is
      package S renames MJ.Spatial_Dynamics;
      V : constant MJ.Spatial_Kernels.Motion := S.Add_Scaled (Velocity, Axis, Speed);
      A : constant MJ.Spatial_Kernels.Motion :=
        (if Translation then Acceleration else S.Add_Scaled
          (Acceleration, S.Cross_Motion (Derivative_Velocity, Axis), Speed));
   begin
      Ok := MJ.Spatial_Kernels.Bounded (V, 1.0e12)
        and then MJ.Spatial_Kernels.Bounded (A, 1.0e12);
      if Ok then Velocity := V; Acceleration := A; end if;
   end Advance_Axis;
end MJ.Manifold_Math;

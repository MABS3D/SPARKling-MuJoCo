with Ada.Numerics;
with MJ.Joint_Limit_Math;
with MJ.Types; use MJ.Types;
with MJ.BLAS;

--  Per-joint sparse rows of mj_instantiateLimit, MuJoCo 3.14.0.
--  No allocation, model mutation, or global constraint solver is hidden here.
package MJ.Joint_Limits with SPARK_Mode is
   subtype Vector is MJ.BLAS.Vector_3;
   subtype Quaternion is MJ.BLAS.Vector_4;
   type Status is (Success, Numeric_Limit, Unsupported_Integrator);
   type Angle_Result is record
      Result : Status := Numeric_Limit;
      Value : Real range -10.0 .. 10.0 := 0.0;
   end record;
   type Side is (Lower, Upper, Angular);
   subtype Distance is Real range -3.0e10 .. 3.0e10;
   type Row is record
      Joint : Index_Type := 0;
      Dof : Index_Type := 0;
      Width : Positive range 1 .. 3 := 1;
      Boundary : Side := Lower;
      Position : Distance := 0.0;
      Margin : Tier0_Real := 0.0;
      Jacobian : Vector := [0.0, 0.0, 0.0];
   end record;
   type Row_Array is array (Positive range 1 .. 2) of Row;
   type Forces is array (Positive range 1 .. 2) of Real range 0.0 .. 1.0e58;
   type Batch is record
      Result : Status := Success;
      Count : Natural range 0 .. 2 := 0;
      Rows : Row_Array := [others => <>];
   end record;
   Empty : constant Batch := (others => <>);
   Rejected : constant Batch := (Result => Numeric_Limit, others => <>);
   function Well_Formed (B : Batch) return Boolean is
     ((if B.Result /= Success then B.Count = 0)
      and then (for all I in 1 .. B.Count => MJ.BLAS.In_Tier0 (B.Rows (I).Jacobian)
        and then B.Rows (I).Width in 1 | 3)) with Global => null;
   function Is_Enabled (Constraints_Disabled, Limits_Disabled, Joint_Limited,
                        Sleep_Filter, Sleeping : Boolean) return Boolean is
     (not Constraints_Disabled and then not Limits_Disabled and then Joint_Limited
      and then not (Sleep_Filter and then Sleeping))
     with Global => null, Post => Is_Enabled'Result =
       (not Constraints_Disabled and then not Limits_Disabled and then Joint_Limited
        and then (not Sleep_Filter or else not Sleeping));
   function Norm3 (V : Vector) return Real is
     (MJ.Joint_Limit_Math.Sqrt ((V (0)*V (0) + V (1)*V (1)) + V (2)*V (2)))
     with Global => null, Pre => MJ.BLAS.In_Tier0 (V),
     Post => Norm3'Result = MJ.Joint_Limit_Math.Sqrt ((V (0)*V (0) + V (1)*V (1)) + V (2)*V (2)),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Norm4 (Q : Quaternion) return Real is
     (MJ.Joint_Limit_Math.Sqrt (((Q (0)*Q (0) + Q (1)*Q (1)) + Q (2)*Q (2)) + Q (3)*Q (3)))
     with Global => null, Pre => MJ.BLAS.In_Tier0 (Q),
     Post => Norm4'Result = MJ.Joint_Limit_Math.Sqrt (((Q (0)*Q (0) + Q (1)*Q (1)) + Q (2)*Q (2)) + Q (3)*Q (3)),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Scaled_Component (X : Tier0_Real; N : Real) return Tier1_Real
     with Global => null, Pre => N >= Min_Val,
     Post => Scaled_Component'Result = X * (1.0/N);
   function Rotation_Vector (Axis : Vector; Speed : Real) return Vector
     with Global => null, Pre => MJ.BLAS.In_Tier0 (Axis) and then Speed in -10.0 .. 10.0,
     Post => MJ.BLAS.In_Tier1 (Rotation_Vector'Result)
       and then (for all I in 0 .. 2 => Rotation_Vector'Result (I) = Axis (I)*Speed);

   package Model with Ghost => Static is
      function Projected_Component (B : Batch; F : Forces; Axis : Natural) return Tier3_Real is
        (if B.Result /= Success or else B.Count = 0 then 0.0 else
          (if B.Rows (1).Width = 1 and then Axis /= 0 then 0.0 else B.Rows (1).Jacobian (Axis)*F (1))
          + (if B.Count = 1 or else (B.Rows (2).Width = 1 and then Axis /= 0)
             then 0.0 else B.Rows (2).Jacobian (Axis)*F (2)))
        with Global => null, Pre => Well_Formed (B) and then Axis <= 2,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Normalized3 (V : Vector) return Vector is
        (declare N : constant Real := Norm3 (V);
         begin (if N < Min_Val then [1.0, 0.0, 0.0] else
           [Scaled_Component (V (0), N), Scaled_Component (V (1), N), Scaled_Component (V (2), N)]))
        with Global => null, Pre => MJ.BLAS.In_Tier0 (V),
        Post => MJ.BLAS.In_Tier1 (Normalized3'Result),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Normalized4 (Q : Quaternion) return Quaternion is
        (declare N : constant Real := Norm4 (Q);
         begin (if N < Min_Val then [1.0, 0.0, 0.0, 0.0]
           elsif abs (N - 1.0) <= Min_Val then Q else
           [Scaled_Component (Q (0), N), Scaled_Component (Q (1), N),
            Scaled_Component (Q (2), N), Scaled_Component (Q (3), N)]))
        with Global => null, Pre => MJ.BLAS.In_Tier0 (Q),
        Post => MJ.BLAS.In_Tier1 (Normalized4'Result),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Short_Angle (Sin_Half, Cos_Half : Real) return Angle_Result is
        (declare T : constant Real := MJ.Joint_Limit_Math.Atan2 (Sin_Half, Cos_Half);
         begin (if T not in -5.0 .. 5.0 then (others => <>) else
          (declare A : constant Real := 2.0*T;
           begin (Success, (if A > Ada.Numerics.Pi then A - 2.0 * Ada.Numerics.Pi else A)))))
        with Global => null, Pre => Sin_Half >= 0.0 and then
          (Sin_Half /= 0.0 or else Cos_Half /= 0.0),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Scalar (Joint, Dof : Index_Type; Position, Low, High : Tier0_Real;
                       Margin : Tier0_Real; Enabled : Boolean) return Batch is
        (declare L : constant Distance := -1.0 * (Low - Position);
                 U : constant Distance := High - Position;
                 RL : constant Row := (Joint, Dof, 1, Lower, L, Margin, [1.0, 0.0, 0.0]);
                 RU : constant Row := (Joint, Dof, 1, Upper, U, Margin, [-1.0, 0.0, 0.0]);
         begin (if not Enabled then Empty
           elsif L < Margin and then U < Margin then (Success, 2, [RL, RU])
           elsif L < Margin then (Success, 1, [RL, (others => <>)])
           elsif U < Margin then (Success, 1, [RU, (others => <>)]) else Empty))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Ball_Row (Joint, Dof : Index_Type; Angle : Nonneg_Tier0; Axis : Vector;
                         Low, High : Tier0_Real; Margin : Tier0_Real) return Batch is
        (declare Dist : constant Distance := Real'Max (Low, High) - Angle;
         begin (if Dist < Margin then
           (Success, 1, [(Joint, Dof, 3, Angular, Dist, Margin,
             [-Axis (0), -Axis (1), -Axis (2)]), (others => <>)]) else Empty))
        with Global => null, Pre => MJ.BLAS.In_Tier0 (Axis),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Ball (Joint, Dof : Index_Type; Q : Quaternion; Low, High : Tier0_Real;
                     Margin : Tier0_Real; Enabled : Boolean) return Batch is
        (if not Enabled then Empty else
          (declare NQ : constant Quaternion := Normalized4 (Q);
           begin (if not MJ.BLAS.In_Tier0 (NQ) then Rejected else
            (declare V : constant Vector := [NQ (1), NQ (2), NQ (3)];
                     N : constant Real := Norm3 (V);
                     Axis : constant Vector := Normalized3 (V);
             begin (if N < 0.0 or else (N = 0.0 and then NQ (0) = 0.0) or else not MJ.BLAS.In_Tier0 (Axis)
              then Rejected else
              (declare Speed : constant Angle_Result := Short_Angle (N, NQ (0));
                       Rotation : constant Vector := Rotation_Vector (Axis, Speed.Value);
               begin (if Speed.Result /= Success or else not MJ.BLAS.In_Tier0 (Rotation) then Rejected else
                (declare Angle : constant Real := Norm3 (Rotation);
                         Direction : constant Vector := Normalized3 (Rotation);
                 begin (if Angle not in Nonneg_Tier0 or else not MJ.BLAS.In_Tier0 (Direction)
                  then Rejected else Ball_Row (Joint, Dof, Angle, Direction, Low, High, Margin))))))))))
        with Global => null, Pre => MJ.BLAS.In_Tier0 (Q),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;

   function Normalize3 (V : Vector) return Vector with Global => null,
     Pre => MJ.BLAS.In_Tier0 (V),
     Post => (Static => MJ.BLAS.In_Tier1 (Normalize3'Result)
       and then Normalize3'Result = Model.Normalized3 (V));
   function Normalize4 (Q : Quaternion) return Quaternion with Global => null,
     Pre => MJ.BLAS.In_Tier0 (Q),
     Post => (Static => MJ.BLAS.In_Tier1 (Normalize4'Result)
       and then Normalize4'Result = Model.Normalized4 (Q));
   function Short_Angle (Sin_Half, Cos_Half : Real) return Angle_Result with Global => null,
     Pre => Sin_Half >= 0.0 and then (Sin_Half /= 0.0 or else Cos_Half /= 0.0),
     Post => (Static => Short_Angle'Result = Model.Short_Angle (Sin_Half, Cos_Half));
   function Build_Scalar (Joint, Dof : Index_Type; Position, Low, High : Tier0_Real;
                          Margin : Tier0_Real; Enabled : Boolean := True) return Batch
     with Global => null, Post => (Static => Well_Formed (Build_Scalar'Result) and then Build_Scalar'Result =
       Model.Scalar (Joint, Dof, Position, Low, High, Margin, Enabled));
   function Build_Ball_Row (Joint, Dof : Index_Type; Angle : Nonneg_Tier0; Axis : Vector;
                           Low, High : Tier0_Real; Margin : Tier0_Real) return Batch
     with Global => null, Pre => MJ.BLAS.In_Tier0 (Axis),
     Post => (Static => Well_Formed (Build_Ball_Row'Result) and then Build_Ball_Row'Result = Model.Ball_Row (Joint, Dof, Angle, Axis, Low, High, Margin));
   function Build_Ball (Joint, Dof : Index_Type; Q : Quaternion; Low, High : Tier0_Real;
                       Margin : Tier0_Real; Enabled : Boolean := True) return Batch
     with Global => null, Pre => MJ.BLAS.In_Tier0 (Q),
     Post => (Static => Well_Formed (Build_Ball'Result) and then Build_Ball'Result = Model.Ball (Joint, Dof, Q, Low, High, Margin, Enabled));
   --  Global limit/constraint disable flags, jnt_limited and sleeping state
   --  are combined by the caller in Enabled. Free joints always yield Empty.
   function Build (Kind : Joint_Kind; Joint, Dof : Index_Type; Position : Tier0_Real;
                   Q : Quaternion; Low, High : Tier0_Real; Margin : Tier0_Real;
                   Enabled : Boolean := True) return Batch
     with Global => null, Pre => MJ.BLAS.In_Tier0 (Q),
     Post => (Static => Well_Formed (Build'Result) and then Build'Result =
       (case Kind is when Free => Empty,
        when Ball => Model.Ball (Joint, Dof, Q, Low, High, Margin, Enabled),
        when Slide | Hinge => Model.Scalar (Joint, Dof, Position, Low, High, Margin, Enabled)));
   --  Map SOLVED nonnegative row forces into local generalized force/torque.
   --  Both active scalar sides are combined; they must be solved together.
   function Project_Forces (B : Batch; F : Forces) return Vector with Global => null,
     Pre => Well_Formed (B),
     Post => (Static => (for all A in 0 .. 2 => Project_Forces'Result (A) in Tier3_Real
       and then Project_Forces'Result (A) = Model.Projected_Component (B, F, A)));
end MJ.Joint_Limits;

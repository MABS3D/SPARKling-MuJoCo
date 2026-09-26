with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Smooth_Dynamics;
--  Proof facade for transient bounds. Arithmetic delegates to the original
--  kernels, whose exact floating-point contracts remain unchanged.
--  This facade proves storage/overflow invariants, not full rigid-body physics.
package MJ.Pose_Arithmetic with SPARK_Mode is
   function Sum_Matches (A, B : Vector; Value : Vector) return Boolean is
     (Value = MJ.Smooth_Math."+" (A, B))
     with Ghost => Static, Global => null, Pre => Bounded (A, 1.0e300) and then Bounded (B, 1.0e300),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function "+" (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e300) and then Bounded (B, 1.0e300),
     Post => Bounded ("+"'Result, 4.0e300)
       and then (if Bounded (A, 1.0e200) and then Bounded (B, 1.0e200)
         then Bounded ("+"'Result, 1.0e210))
       and then (if Bounded (A, 1.0e65) and then Bounded (B, 1.0e65)
         then Bounded ("+"'Result, 1.0e66))
       and then (if Bounded (A, 1.0e85) and then Bounded (B, 1.0e85)
         then Bounded ("+"'Result, 1.0e86))
       and then (if Bounded (A, 1.0e290) and then Bounded (B, 1.0e290)
         then Bounded ("+"'Result, 1.0e291));
   pragma Postcondition (Static => Sum_Matches (A, B, "+"'Result));
   function Difference_Matches (A, B : Vector; Value : Vector) return Boolean is
     (Value = MJ.Smooth_Math."-" (A, B))
     with Ghost => Static, Global => null, Pre => Bounded (A, 1.0e300) and then Bounded (B, 1.0e300),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function "-" (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e300) and then Bounded (B, 1.0e300),
     Post => Bounded ("-"'Result, 4.0e300)
       and then (if Bounded (A, 1.0e200) and then Bounded (B, 1.0e200)
         then Bounded ("-"'Result, 1.0e210))
       and then (if Bounded (A, 1.0e65) and then Bounded (B, 1.0e65)
         then Bounded ("-"'Result, 1.0e66))
       and then (if Bounded (A, 1.0e85) and then Bounded (B, 1.0e85)
         then Bounded ("-"'Result, 1.0e86))
       and then (if Bounded (A, 1.0e290) and then Bounded (B, 1.0e290)
         then Bounded ("-"'Result, 1.0e291));
   pragma Postcondition (Static => Difference_Matches (A, B, "-"'Result));
   function Scale_Matches (S : Real; V : Vector; Value : Vector) return Boolean is
     (Value = MJ.Smooth_Math."*" (S, V))
     with Ghost => Static, Global => null, Pre => S in -1.0e100 .. 1.0e100 and then Bounded (V, 1.0e200),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function "*" (S : Real; V : Vector) return Vector with Global => null,
     Pre => S in -1.0e100 .. 1.0e100 and then Bounded (V, 1.0e200),
     Post => Bounded ("*"'Result, 4.0e300)
       and then (if S in -2.0e10 .. 2.0e10 and then Bounded (V, 1.0e12)
         then Bounded ("*"'Result, 1.0e24))
       and then (if S in -2.0e10 .. 2.0e10 and then Bounded (V, 1.0e73)
         then Bounded ("*"'Result, 1.0e85));
   pragma Postcondition (Static => Scale_Matches (S, V, "*"'Result));
   function Cross_Matches (A, B : Vector; Value : Vector) return Boolean is
     (Value = MJ.Smooth_Math.Cross (A, B))
     with Ghost => Static, Global => null, Pre => Bounded (A, 1.0e150) and then Bounded (B, 1.0e150),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Cross (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A, 1.0e150) and then Bounded (B, 1.0e150),
     Post => Bounded (Cross'Result, 8.0e300)
       and then (if Bounded (A, 1.0e60) and then Bounded (B, 1.0e12)
         then Bounded (Cross'Result, 1.0e73))
       and then (if Bounded (A, 1.0e90) and then Bounded (B, 1.0e24)
         then Bounded (Cross'Result, 1.0e115))
       and then (if Bounded (A, 1.0e70) and then Bounded (B, 1.0e115)
         then Bounded (Cross'Result, 1.0e186));
   pragma Postcondition (Static => Cross_Matches (A, B, Cross'Result));
   function Apply_Matches (R : Matrix; V : Vector; Value : Vector) return Boolean is
     (Value = MJ.Smooth_Dynamics.Apply_Config (R, V))
     with Ghost => Static, Global => null, Pre => Bounded (R, 16.0) and then Bounded (V, Max_Val),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Apply_Config (R : Matrix; V : Vector) return Vector with Global => null,
     Pre => Bounded (R, 16.0) and then Bounded (V, Max_Val),
     Post => Bounded (Apply_Config'Result, 1.0e12);
   pragma Postcondition (Static => Apply_Matches (R, V, Apply_Config'Result));
   function Slide_Velocity (V, W, Shift, Direction : Vector; Qd : Real) return Vector is
     (V + Cross (W, Shift) + Qd * Direction)
     with Global => null, Pre => Bounded (V) and then Bounded (W) and then Bounded (Shift, 1.0e24) and then Bounded (Direction, 1.0e12) and then Qd in -Max_Val .. Max_Val,
       Post => Bounded (Slide_Velocity'Result, 1.0e301),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Slide_Bias (B, A, W, Shift, Direction : Vector; Qd : Real) return Vector is
     (B + Cross (A, Shift) + Cross (W, Cross (W, Shift)) + (2.0 * Qd) * Cross (W, Direction))
     with Global => null, Pre => Bounded (B) and then Bounded (A) and then Bounded (W) and then Bounded (Shift, 1.0e24) and then Bounded (Direction, 1.0e12) and then Qd in -Max_Val .. Max_Val,
       Post => Bounded (Slide_Bias'Result, 1.0e301),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Anchor_Velocity (V, W, Offset : Vector) return Vector is
     (V + Cross (W, Offset))
     with Global => null, Pre => Bounded (V) and then Bounded (W) and then Bounded (Offset, 1.0e12),
       Post => Bounded (Anchor_Velocity'Result, 1.0e86),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Anchor_Bias (B, A, W, Offset : Vector) return Vector is
     (B + Cross (A, Offset) + Cross (W, Cross (W, Offset)))
     with Global => null, Pre => Bounded (B) and then Bounded (A) and then Bounded (W) and then Bounded (Offset, 1.0e12),
       Post => Bounded (Anchor_Bias'Result, 1.0e210),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Hinge_Angular_Bias (B, W, Direction : Vector; Qd : Real) return Vector is
     (B + Qd * Cross (W, Direction))
     with Global => null, Pre => Bounded (B) and then Bounded (W) and then Bounded (Direction, 1.0e12) and then Qd in -Max_Val .. Max_Val,
       Post => Bounded (Hinge_Angular_Bias'Result, 1.0e86),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Hinge_Angular_Velocity (W, Direction : Vector; Qd : Real) return Vector is
     (W + Qd * Direction)
     with Global => null, Pre => Bounded (W) and then Bounded (Direction, 1.0e12) and then Qd in -Max_Val .. Max_Val,
       Post => Bounded (Hinge_Angular_Velocity'Result, 1.0e66),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Hinge_Linear_Velocity (V, W, Offset : Vector) return Vector is
     (V - Cross (W, Offset))
     with Global => null, Pre => Bounded (V, 1.0e86) and then Bounded (W, 1.0e66) and then Bounded (Offset, 1.0e12),
       Post => Bounded (Hinge_Linear_Velocity'Result, 1.0e210),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Hinge_Linear_Bias (B, A, W, Offset : Vector) return Vector is
     (B - Cross (A, Offset) - Cross (W, Cross (W, Offset)))
     with Global => null, Pre => Bounded (B, 1.0e210) and then Bounded (A, 1.0e86) and then Bounded (W, 1.0e66) and then Bounded (Offset, 1.0e12),
       Post => Bounded (Hinge_Linear_Bias'Result, 1.0e301),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
end MJ.Pose_Arithmetic;

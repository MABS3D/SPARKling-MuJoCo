with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;

--  Rounded spatial formulas from MuJoCo 3.14.0's inertCom/mulInertVec/dot6.
--  These bounds define a checked fast path; the caller retains its wide path.
package MJ.Spatial_Kernels with SPARK_Mode is
   type Motion is array (Natural range 0 .. 5) of Real;
   type Inertia is array (Natural range 0 .. 9) of Real;
   function Frame_Offset (Position, Origin : Vector) return Vector with Global => null,
     Pre => Bounded (Position, Max_Val) and then Bounded (Origin, Max_Val),
     Post => Bounded (Frame_Offset'Result, 1.0e11)
       and then Frame_Offset'Result = [Position (0)-Origin (0), Position (1)-Origin (1), Position (2)-Origin (2)];
   function Mass_Moment (Mass : Nonneg_Tier0; Position : Vector) return Vector with Global => null,
     Pre => Bounded (Position, Max_Val),
     Post => Bounded (Mass_Moment'Result, 1.0e22)
       and then Mass_Moment'Result = [Mass*Position (0), Mass*Position (1), Mass*Position (2)];
   function Bounded (V : Motion; Limit : Real) return Boolean is
     (V (0) in -Limit .. Limit
      and then V (1) in -Limit .. Limit
      and then V (2) in -Limit .. Limit
      and then V (3) in -Limit .. Limit
      and then V (4) in -Limit .. Limit
      and then V (5) in -Limit .. Limit) with Global => null, Pre => Limit >= 0.0;
   function Bounded (I : Inertia; Limit : Real) return Boolean is
     (I (0) in -Limit .. Limit
      and then I (1) in -Limit .. Limit
      and then I (2) in -Limit .. Limit
      and then I (3) in -Limit .. Limit
      and then I (4) in -Limit .. Limit
      and then I (5) in -Limit .. Limit
      and then I (6) in -Limit .. Limit
      and then I (7) in -Limit .. Limit
      and then I (8) in -Limit .. Limit
      and then I (9) in -Limit .. Limit) with Global => null, Pre => Limit >= 0.0;
   function Rotated_Entry (R : Matrix; Diagonal : Vector; Row, Col : Axis) return Real
     with Global => null,
     Pre => Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val),
     Post => Rotated_Entry'Result in -1.0e15 .. 1.0e15
       and then Rotated_Entry'Result =
         (R (Row, 0) * (R (Col, 0) * Diagonal (0))
          + R (Row, 1) * (R (Col, 1) * Diagonal (1)))
          + R (Row, 2) * (R (Col, 2) * Diagonal (2));
   function Shift_Diagonal (Rotated : Real; Mass : Nonneg_Tier0; A, B : Real) return Real
     with Global => null,
     Pre => Rotated in -1.0e15 .. 1.0e15 and then A in -1.0e12 .. 1.0e12
       and then B in -1.0e12 .. 1.0e12,
     Post => Shift_Diagonal'Result in -1.0e36 .. 1.0e36
       and then Shift_Diagonal'Result = Rotated + Mass * (A * A + B * B);
   function Shift_Offdiagonal (Rotated : Real; Mass : Nonneg_Tier0; A, B : Real) return Real
     with Global => null,
     Pre => Rotated in -1.0e15 .. 1.0e15 and then A in -1.0e12 .. 1.0e12
       and then B in -1.0e12 .. 1.0e12,
     Post => Shift_Offdiagonal'Result in -1.0e36 .. 1.0e36
       and then Shift_Offdiagonal'Result = Rotated - (Mass * A) * B;
   subtype Body_Inertia_Real is Real range -1.0e36 .. 1.0e36;
   function Pack_Inertia (E0, E1, E2, E3, E4, E5, E6, E7, E8, E9 : Body_Inertia_Real)
     return Inertia with Global => null,
     Post => Bounded (Pack_Inertia'Result, 1.0e36)
       and then Pack_Inertia'Result (0) = E0
       and then Pack_Inertia'Result (1) = E1
       and then Pack_Inertia'Result (2) = E2
       and then Pack_Inertia'Result (3) = E3
       and then Pack_Inertia'Result (4) = E4
       and then Pack_Inertia'Result (5) = E5
       and then Pack_Inertia'Result (6) = E6
       and then Pack_Inertia'Result (7) = E7
       and then Pack_Inertia'Result (8) = E8
       and then Pack_Inertia'Result (9) = E9;
   function Make_Inertia (R : Matrix; Diagonal : Vector; Mass : Nonneg_Tier0; Offset : Vector)
     return Inertia with Global => null,
     Pre => Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val)
       and then Bounded (Offset, 1.0e12),
     Post => Bounded (Make_Inertia'Result, 1.0e36)
       and then Make_Inertia'Result (0) = Shift_Diagonal (Rotated_Entry (R, Diagonal, 0, 0), Mass, Offset (1), Offset (2))
       and then Make_Inertia'Result (1) = Shift_Diagonal (Rotated_Entry (R, Diagonal, 1, 1), Mass, Offset (0), Offset (2))
       and then Make_Inertia'Result (2) = Shift_Diagonal (Rotated_Entry (R, Diagonal, 2, 2), Mass, Offset (0), Offset (1))
       and then Make_Inertia'Result (3) = Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 0, 1), Mass, Offset (0), Offset (1))
       and then Make_Inertia'Result (4) = Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 0, 2), Mass, Offset (0), Offset (2))
       and then Make_Inertia'Result (5) = Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 1, 2), Mass, Offset (1), Offset (2))
       and then Make_Inertia'Result (6) = Mass * Offset (0)
       and then Make_Inertia'Result (7) = Mass * Offset (1)
       and then Make_Inertia'Result (8) = Mass * Offset (2)
       and then Make_Inertia'Result (9) = Mass;
   function Add (A, B : Inertia) return Inertia with Global => null,
     Pre => Bounded (A, 1.0e40) and then Bounded (B, 1.0e40),
     Post => Bounded (Add'Result, 3.0e40)
       and then Add'Result (0) = A (0) + B (0)
       and then Add'Result (1) = A (1) + B (1)
       and then Add'Result (2) = A (2) + B (2)
       and then Add'Result (3) = A (3) + B (3)
       and then Add'Result (4) = A (4) + B (4)
       and then Add'Result (5) = A (5) + B (5)
       and then Add'Result (6) = A (6) + B (6)
       and then Add'Result (7) = A (7) + B (7)
       and then Add'Result (8) = A (8) + B (8)
       and then Add'Result (9) = A (9) + B (9);
   subtype Inertia_Real is Real range -1.0e40 .. 1.0e40;
   subtype Motion_Real is Real range -1.0e12 .. 1.0e12;
   subtype Product_Real is Real range -1.0e54 .. 1.0e54;
   function Angular_Component
     (A, B, C, D, E : Inertia_Real; X, Y, Z, U, V : Motion_Real; Reverse_Signs : Boolean)
     return Product_Real with Global => null,
     Post => Angular_Component'Result =
       (if Reverse_Signs then (((A*X + B*Y) + C*Z) + D*U) - E*V
        else (((A*X + B*Y) + C*Z) - D*U) + E*V);
   function Linear_Component (A, B, C : Inertia_Real; X, Y, Z : Motion_Real)
     return Product_Real with Global => null,
     Post => Linear_Component'Result = (A*X - B*Y) + C*Z;
   function Multiply (I : Inertia; V : Motion) return Motion with Global => null,
     Pre => Bounded (I, 1.0e40) and then Bounded (V, 1.0e12),
     Post => Bounded (Multiply'Result, 1.0e54)
       and then Multiply'Result (0) = Angular_Component
         (I (0), I (3), I (4), I (8), I (7), V (0), V (1), V (2), V (4), V (5), False)
       and then Multiply'Result (1) = Angular_Component
         (I (3), I (1), I (5), I (8), I (6), V (0), V (1), V (2), V (3), V (5), True)
       and then Multiply'Result (2) = Angular_Component
         (I (4), I (5), I (2), I (7), I (6), V (0), V (1), V (2), V (3), V (4), False)
       and then Multiply'Result (3) = Linear_Component (I (8), I (7), I (9), V (1), V (2), V (3))
       and then Multiply'Result (4) = Linear_Component (I (6), I (8), I (9), V (2), V (0), V (4))
       and then Multiply'Result (5) = Linear_Component (I (7), I (6), I (9), V (0), V (1), V (5));
   function Dot (A, B : Motion) return Real with Global => null,
     Pre => Bounded (A, 1.0e12) and then Bounded (B, 1.0e54),
     Post => Dot'Result in -1.0e68 .. 1.0e68 and then Dot'Result =
       ((A (0)*B (0) + A (2)*B (2)) + (A (1)*B (1) + A (3)*B (3)))
         + (A (4)*B (4) + A (5)*B (5));
   function Joint_Motion (Direction, Offset : Vector; Hinge : Boolean) return Motion
     with Global => null,
     Pre => Bounded (Direction, 2.0) and then Bounded (Offset, 1.0e11),
     Post => Bounded (Joint_Motion'Result, 1.0e12) and then Joint_Motion'Result =
       (if Hinge then
          [Direction (0), Direction (1), Direction (2),
           Direction (1)*Offset (2) - Direction (2)*Offset (1),
           Direction (2)*Offset (0) - Direction (0)*Offset (2),
           Direction (0)*Offset (1) - Direction (1)*Offset (0)]
        else [0.0, 0.0, 0.0, Direction (0), Direction (1), Direction (2)]);
   function Wrench (Force, Torque, Offset : Vector) return Motion with Global => null,
     Pre => Bounded (Force, 1.0e40) and then Bounded (Torque, 1.0e40)
       and then Bounded (Offset, 1.0e12),
     Post => Bounded (Wrench'Result, 1.0e54) and then Wrench'Result =
       [Torque (0) + (Offset (1)*Force (2) - Offset (2)*Force (1)),
        Torque (1) + (Offset (2)*Force (0) - Offset (0)*Force (2)),
        Torque (2) + (Offset (0)*Force (1) - Offset (1)*Force (0)),
        Force (0), Force (1), Force (2)];
   function Add_Wrenches (A, B : Motion) return Motion with Global => null,
     Pre => Bounded (A, 1.0e54) and then Bounded (B, 1.0e54),
     Post => Bounded (Add_Wrenches'Result, 3.0e54)
       and then (for all K in Motion'Range => Add_Wrenches'Result (K) = A (K) + B (K));
end MJ.Spatial_Kernels;

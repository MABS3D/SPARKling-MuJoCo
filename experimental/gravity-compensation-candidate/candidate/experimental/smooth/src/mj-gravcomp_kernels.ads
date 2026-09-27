with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;

package MJ.Gravcomp_Kernels with SPARK_Mode is
   --  C order: first mass * coefficient, then multiply each gravity axis.
   function Body_Force (Mass : Nonneg_Tier0; Coefficient : Tier0_Real; Gravity : Vector)
     return Vector with Global => null, Inline_Always,
     Pre => Bounded (Gravity, Max_Val),
     Post => Bounded (Body_Force'Result, 1.0e32)
       and then (for all K in Axis =>
         Body_Force'Result (K) = Gravity (K) * (-(Mass * Coefficient)));
   subtype Offset_Value is Real range -1.0e61 .. 1.0e61;
   subtype Column_Value is Real range -1.0e62 .. 1.0e62;
   function Difference (A, B : Real) return Offset_Value
     with Global => null, Inline_Always,
     Pre => A in -Work_Limit .. Work_Limit and then B in -Work_Limit .. Work_Limit,
     Post => Difference'Result = A - B;
   function Cross_Component (A, B : Real; X, Y : Offset_Value) return Column_Value
     with Global => null, Inline_Always,
     Pre => A in -1.00001 .. 1.00001 and then B in -1.00001 .. 1.00001,
     Post => Cross_Component'Result = A * X - B * Y;
   --  A transient Jacobian column need not fit the narrower stored-state bound.
   function Linear_Column (Hinge : Boolean; Center, Anchor, Direction : Vector)
     return Vector with Global => null, Inline_Always,
     Pre => Bounded (Center) and then Bounded (Anchor) and then Bounded (Direction, 1.00001),
     Post => Bounded (Linear_Column'Result, 1.0e62)
       and then Linear_Column'Result =
         (if Hinge then
            [Cross_Component (Direction (1), Direction (2), Difference (Center (2), Anchor (2)), Difference (Center (1), Anchor (1))),
             Cross_Component (Direction (2), Direction (0), Difference (Center (0), Anchor (0)), Difference (Center (2), Anchor (2))),
             Cross_Component (Direction (0), Direction (1), Difference (Center (1), Anchor (1)), Difference (Center (0), Anchor (0)))]
          else Direction);
end MJ.Gravcomp_Kernels;

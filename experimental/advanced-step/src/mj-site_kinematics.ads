with MJ.Types; use MJ.Types;
package MJ.Site_Kinematics with SPARK_Mode is
   --  Ordered point geometry used by the owned site transmission. Bounds are
   --  inherited from smooth work buffers; final Jacobian admission belongs
   --  to the caller's existing actuator input domain.
   function World_Coordinate
     (Origin, R0, R1, R2, X, Y, Z : Real) return Real with
     Global => null, Inline_Always,
     Pre => (Static => Origin in -1.0e60 .. 1.0e60
       and then R0 in -1.1 .. 1.1 and then R1 in -1.1 .. 1.1 and then R2 in -1.1 .. 1.1
       and then X in -1.0e60 .. 1.0e60 and then Y in -1.0e60 .. 1.0e60
       and then Z in -1.0e60 .. 1.0e60),
     Post => (Static => World_Coordinate'Result = ((R0 * X + R1 * Y) + R2 * Z) + Origin
       and then World_Coordinate'Result in -1.0e62 .. 1.0e62);

   function Point_Column
     (Linear, Angular_A, Angular_B, Offset_A, Offset_B : Real) return Real with
     Global => null, Inline_Always,
     Pre => (Static => Linear in -1.0e60 .. 1.0e60
       and then Angular_A in -1.0e60 .. 1.0e60 and then Angular_B in -1.0e60 .. 1.0e60
       and then Offset_A in -1.0e62 .. 1.0e62 and then Offset_B in -1.0e62 .. 1.0e62),
     Post => (Static => Point_Column'Result = Linear + (Angular_A * Offset_B - Angular_B * Offset_A)
       and then Point_Column'Result in -1.0e124 .. 1.0e124);
end MJ.Site_Kinematics;

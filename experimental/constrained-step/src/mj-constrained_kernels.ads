with MJ.Types; use MJ.Types;
package MJ.Constrained_Kernels with SPARK_Mode is
   subtype Small is Real range -1.0e10 .. 1.0e10;
   subtype Work is Real range -1.0e30 .. 1.0e30;
   function Point_Component (Linear, Angular_A, Angular_B, Offset_A, Offset_B : Small)
                            return Work
     with Global => null,
     Post => Point_Component'Result = Linear + (Angular_A * Offset_B - Angular_B * Offset_A);
   function Frame_Component (X, Y, Z : Work; A, B, C : Small) return Real
     with Global => null,
     Post => Frame_Component'Result = (A * X + B * Y) + C * Z;
   function Accumulate_Force (Previous : Work; Jacobian, Force : Small) return Real
     with Global => null,
     Post => Accumulate_Force'Result = Previous + Jacobian * Force;
   function Velocity_Update (Velocity, Acceleration : Small; H : Nonneg_Tier0) return Real
     with Global => null,
     Post => Velocity_Update'Result = Velocity + H * Acceleration;
end MJ.Constrained_Kernels;

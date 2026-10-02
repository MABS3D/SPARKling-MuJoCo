package body MJ.Constrained_Kernels with SPARK_Mode is
   function Point_Component (Linear, Angular_A, Angular_B, Offset_A, Offset_B : Small)
                            return Work is
     (Linear + (Angular_A * Offset_B - Angular_B * Offset_A));
   function Frame_Component (X, Y, Z : Work; A, B, C : Small) return Real is
     ((A * X + B * Y) + C * Z);
   function Accumulate_Force (Previous : Work; Jacobian, Force : Small) return Real is
     (Previous + Jacobian * Force);
   function Velocity_Update (Velocity, Acceleration : Small; H : Nonneg_Tier0) return Real is
     (Velocity + H * Acceleration);
end MJ.Constrained_Kernels;

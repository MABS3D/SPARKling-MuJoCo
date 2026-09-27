with MJ.Types; use MJ.Types;
with MJ.Spatial_Kernels;
package MJ.Composite_Bounds with SPARK_Mode, Ghost => Static is
   Max_Bodies : constant := 4_096;
   Quantum : constant Real := 2.0 ** 119;
   subtype Weight is Positive range 1 .. Max_Bodies;
   function Budget (N : Weight) return Real is (Real (3 * N - 1) * Quantum);
   procedure Bound_Sum (A, B : Real; NA, NB : Weight)
     with Global => null,
     Pre => NA <= Max_Bodies - NB
       and then A in -(Real (3 * NA - 1) * Quantum) .. (Real (3 * NA - 1) * Quantum)
       and then B in -(Real (3 * NB - 1) * Quantum) .. (Real (3 * NB - 1) * Quantum),
     Post => A + B in -(Real (3 * (NA + NB) - 1) * Quantum) .. (Real (3 * (NA + NB) - 1) * Quantum);
   procedure Budget_Bounds (N : Weight)
     with Global => null, Post => Budget (N) in 1.0e36 .. 1.0e40;
   procedure Bound_Inertia_Sum
     (A, B : MJ.Spatial_Kernels.Inertia; NA, NB : Weight)
     with Global => null,
     Pre => NA <= Max_Bodies - NB
       and then MJ.Spatial_Kernels.Bounded (A, Budget (NA))
       and then MJ.Spatial_Kernels.Bounded (B, Budget (NB))
       and then MJ.Spatial_Kernels.Bounded (A, 1.0e40)
       and then MJ.Spatial_Kernels.Bounded (B, 1.0e40),
     Post => MJ.Spatial_Kernels.Bounded
       (MJ.Spatial_Kernels.Add (A, B), Budget (NA + NB));
end MJ.Composite_Bounds;

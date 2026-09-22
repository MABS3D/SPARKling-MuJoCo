--  First bounded kernels from MuJoCo 3.12.0 engine_util_blas.c.
with MJ.Types; use MJ.Types;

package MJ.BLAS with SPARK_Mode is
   subtype Vector_3 is Real_Array (0 .. 2);

   function In_Tier0 (V : Vector_3) return Boolean is
     (for all I in V'Range => V (I) in Tier0_Real)
   with Global => null;

   function In_Tier1 (V : Vector_3) return Boolean is
     (for all I in V'Range => V (I) in Tier1_Real)
   with Global => null;

   function Add3 (A, B : Vector_3) return Vector_3 with
     Global => null,
     Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (Add3'Result)
       and then (for all I in A'Range => Add3'Result (I) = A (I) + B (I));

   function Sub3 (A, B : Vector_3) return Vector_3 with
     Global => null,
     Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => In_Tier1 (Sub3'Result)
       and then (for all I in A'Range => Sub3'Result (I) = A (I) - B (I));

   function Scl3 (A : Vector_3; Scale : Tier0_Real) return Vector_3 with
     Global => null,
     Pre => In_Tier0 (A),
     Post => In_Tier1 (Scl3'Result)
       and then (for all I in A'Range => Scl3'Result (I) = A (I) * Scale);

   function Dot3 (A, B : Vector_3) return Tier1_Real with
     Global => null,
     Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => Dot3'Result = ((A (0) * B (0)) + (A (1) * B (1))) + (A (2) * B (2));
end MJ.BLAS;

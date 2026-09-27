with MJ.Types; use MJ.Types;

package MJ.Bounds_Kernels with SPARK_Mode is
   --  The same universal predicate as an early-exit scan, expressed as a
   --  rejection count so valid numeric buffers can be checked with SIMD.
   function All_Within (Values : Real_Array; Limit : Real) return Boolean
     with Global => null, Pre => Limit >= 0.0,
     Post => All_Within'Result =
       (for all X of Values => X in -Limit .. Limit);
end MJ.Bounds_Kernels;

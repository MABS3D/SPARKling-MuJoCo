with MJ.Types; use MJ.Types;

--  Direct scalar implementation with the exact parent operation as its model.
package MJ.Spatial_Kernels.Direct with SPARK_Mode is
   function Multiply (I : Inertia; V : Motion) return Motion
     with Global => null,
     Pre => Bounded (I, 1.0e40) and then Bounded (V, 1.0e12),
     Post => Bounded (Multiply'Result, 1.0e54)
       and then Multiply'Result = MJ.Spatial_Kernels.Multiply (I, V);
end MJ.Spatial_Kernels.Direct;

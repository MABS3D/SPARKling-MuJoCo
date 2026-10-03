with MJ.Types; use MJ.Types;
package MJ.SDF_Kernels with SPARK_Mode is
   function Proxy_Extent (Center, Half : Real) return Real
     with Global => null,
       Pre => Center in -1.0e9 .. 1.0e9 and Half in 0.0 .. 1.0e9,
       Post => Proxy_Extent'Result = Real'Max (1.0e-10, abs Center + Half)
         and then Proxy_Extent'Result in 1.0e-10 .. 2.0e9;
   function Bounded_Index (First, Length, Total : Natural) return Boolean is
     (Length > 0 and then First < Total and then Length <= Total - First)
     with Global => null;
end MJ.SDF_Kernels;

package body MJ.SDF_Kernels with SPARK_Mode is
   function Proxy_Extent (Center, Half : Real) return Real is
   begin
      return Real'Max (1.0e-10, abs Center + Half);
   end Proxy_Extent;
end MJ.SDF_Kernels;

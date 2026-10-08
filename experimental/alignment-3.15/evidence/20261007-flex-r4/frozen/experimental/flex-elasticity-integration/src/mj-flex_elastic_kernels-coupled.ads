--  C 3.15 adds each edge row to its vertex accumulator before scattering.
package MJ.Flex_Elastic_Kernels.Coupled with SPARK_Mode is
   function Bending_Update
     (Previous : Force_Value; K : Four_Coefficients; X : Four;
      Beta : Coefficient; Normal : Real) return Real
     with Global => null, Pre => Normal in -1.0e22 .. 1.0e22,
       Post => Bending_Update'Result in -2.0e120 .. 2.0e120 and then
         Bending_Update'Result =
           ((((Previous + K (0)*X (0)) + K (1)*X (1))
             + K (2)*X (2)) + K (3)*X (3)) + Beta*Normal;
end MJ.Flex_Elastic_Kernels.Coupled;

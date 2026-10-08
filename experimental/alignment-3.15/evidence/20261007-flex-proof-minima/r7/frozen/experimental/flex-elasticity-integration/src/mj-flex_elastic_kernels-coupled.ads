--  C 3.15 adds each edge row to its vertex accumulator before scattering.
package MJ.Flex_Elastic_Kernels.Coupled with SPARK_Mode is
   --  World vertex velocity includes up to 256 ancestor contributions;
   --  it is wider than a single admitted generalized coordinate.
   subtype World_Component is Real range -1.0e40 .. 1.0e40;
   type Four_World is array (Integer range 0 .. 3) of World_Component;
   function Bending_Update
     (Previous : Force_Value; K : Four_Coefficients; X : Four_World;
      Beta : Coefficient; Normal : Real; Curved : Boolean := True) return Real
     with Global => null, Pre => Normal in -1.0e22 .. 1.0e22,
       Post => Bending_Update'Result in -2.0e120 .. 2.0e120 and then
         Bending_Update'Result =
           (if Curved then
             ((((Previous + K (0)*X (0)) + K (1)*X (1))
               + K (2)*X (2)) + K (3)*X (3)) + Beta*Normal
            else (((Previous + K (0)*X (0)) + K (1)*X (1))
               + K (2)*X (2)) + K (3)*X (3));
end MJ.Flex_Elastic_Kernels.Coupled;

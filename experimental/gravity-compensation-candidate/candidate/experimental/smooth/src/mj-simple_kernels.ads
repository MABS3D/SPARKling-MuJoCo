with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;

--  Conservative, exact-coordinate-axis specialization of C's simple-body test.
--  Approximate axes or frames keep the general path; no physical approximation
--  is made by treating a small nonzero component as zero.
package MJ.Simple_Kernels with SPARK_Mode is
   function Coordinate_Axis (Direction : Vector) return Integer with Global => null,
     Post => Coordinate_Axis'Result in -1 .. 2
       and then (if Coordinate_Axis'Result >= 0 then
         (Direction (Coordinate_Axis'Result) = 1.0 or else Direction (Coordinate_Axis'Result) = -1.0)
         and then (for all A in Axis => (if A /= Coordinate_Axis'Result then Direction (A) = 0.0)))
       and then (Coordinate_Axis'Result = -1) =
         (for all A in Axis => not
           ((Direction (A) = 1.0 or else Direction (A) = -1.0)
            and then (for all K in Axis => (if K /= A then Direction (K) = 0.0))));

   function Fixed_Diagonal (Mass, Principal, Armature : Real; Slide : Boolean) return Real with
     Global => null,
     Pre => Mass in 0.0 .. Max_Val and then Principal in 0.0 .. Max_Val
       and then Armature in 0.0 .. Max_Val,
     Post => Fixed_Diagonal'Result in 0.0 .. 2.0e10
       and then Fixed_Diagonal'Result = Armature + (if Slide then Mass else Principal);
end MJ.Simple_Kernels;

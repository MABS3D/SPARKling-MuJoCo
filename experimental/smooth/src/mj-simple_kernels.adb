package body MJ.Simple_Kernels with SPARK_Mode is
   function Coordinate_Axis (Direction : Vector) return Integer is
   begin
      for A in Axis loop
         if (Direction (A) = 1.0 or else Direction (A) = -1.0)
           and then (for all K in Axis => (if K /= A then Direction (K) = 0.0))
         then
            return A;
         end if;
         pragma Loop_Invariant (for all I in Axis'First .. A => not
           ((Direction (I) = 1.0 or else Direction (I) = -1.0)
            and then (for all K in Axis => (if K /= I then Direction (K) = 0.0))));
      end loop;
      return -1;
   end Coordinate_Axis;

   function Fixed_Diagonal (Mass, Principal, Armature : Real; Slide : Boolean) return Real is
     (Armature + (if Slide then Mass else Principal));
end MJ.Simple_Kernels;

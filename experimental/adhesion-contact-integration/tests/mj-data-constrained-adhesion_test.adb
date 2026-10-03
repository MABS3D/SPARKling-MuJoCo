with MJ.Data.Constrained.Body_Adhesion;
package body MJ.Data.Constrained.Adhesion_Test is
   procedure Check_Reduction is
      function Sparse_Value (M, V : Real_Array) return Real is
      begin
         return Body_Adhesion.Sparse_Velocity
           ([for I in M'Range => M (I)], V);
      end Sparse_Value;
   begin
      -- Products [1e16,1,-1e16,1]: the old left grouping returned 1.
      if Sparse_Value ([1.0e8, 1.0, -1.0e8, 1.0], [1.0e8, 1.0, 1.0e8, 1.0]) /= 2.0
        or else Sparse_Value ([1.0e8, 0.0, 1.0, -1.0e8, 1.0],
                     [1.0e8, 123.0, 1.0, 1.0e8, 1.0]) /= 2.0
        -- Sparse tail is sequential, unlike the dense mju_dot tail.
        or else Sparse_Value ([1.0e8, 1.0, 1.0, 1.0, -1.0e8, 1.0],
                     [1.0e8, 1.0, -1.0, -1.0, 1.0e8, 1.0]) /= 1.0
        or else Sparse_Value ([0.0, 0.0], [2.0, 3.0]) /= 0.0
      then raise Program_Error with "C sparse reduction order"; end if;
   end Check_Reduction;
end MJ.Data.Constrained.Adhesion_Test;

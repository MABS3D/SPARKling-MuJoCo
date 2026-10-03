package body MJ.Sleep_Kernels with SPARK_Mode is
   function Under_Tolerance (X : Samples; W : Weights; Tol : Nonneg_Tier0)
     return Boolean is
   begin
      for I in X'Range loop
         pragma Loop_Invariant
           (for all J in X'First .. I - 1 => Small (X (J), W (J), Tol));
         if not Small (X (I), W (I), Tol) then return False; end if;
      end loop;
      return True;
   end Under_Tolerance;
end MJ.Sleep_Kernels;

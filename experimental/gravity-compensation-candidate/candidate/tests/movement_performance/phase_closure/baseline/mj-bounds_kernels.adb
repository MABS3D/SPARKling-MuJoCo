package body MJ.Bounds_Kernels with SPARK_Mode is
   function All_Within (Values : Real_Array; Limit : Real) return Boolean is
      --  Integer counting avoids a GCC 16 SIMD Boolean-reduction miscompile.
      Rejected : Int64 := 0;
   begin
      for I in Values'Range loop
         Rejected := Rejected + Boolean'Pos (Values (I) not in -Limit .. Limit);
         pragma Loop_Invariant
           (Static => Rejected in 0 .. Int64 (I) - Int64 (Values'First) + 1);
         pragma Loop_Invariant
           (Static => (Rejected = 0) = (for all J in Values'First .. I =>
              Values (J) in -Limit .. Limit));
      end loop;
      return Rejected = 0;
   end All_Within;
end MJ.Bounds_Kernels;

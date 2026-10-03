package body MJ.Integration_PCG.Testing is
   procedure Check_Reduction is
   begin
      if Dot ([1.0e8, 1.0, -1.0e8, 1.0], [1.0e8, 1.0, 1.0e8, 1.0]) /= 2.0
        or else Dot ([1.0e8, 1.0, 1.0, 1.0, -1.0e8, 1.0],
                     [1.0e8, 1.0, -1.0, -1.0, 1.0e8, 1.0]) /= 0.0
        or else Dot ([1.0e8, 1.0, 1.0, 1.0, -1.0e8, 1.0, 1.0],
                     [1.0e8, 1.0, -1.0, -1.0, 1.0e8, 1.0, 1.0]) /= 0.0
      then raise Program_Error with "C dense reduction order"; end if;
   end Check_Reduction;
end MJ.Integration_PCG.Testing;

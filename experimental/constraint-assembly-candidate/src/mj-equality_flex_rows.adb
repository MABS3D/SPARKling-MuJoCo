with MJ.Equality_Flex;
package body MJ.Equality_Flex_Rows with SPARK_Mode is
   procedure Append
     (B : in out CA.Storage; Eq_Id : Natural; Chain : CA.Column_Array;
      Values : CA.Value_Array; Length, Rest : Nonneg_Tier0;
      Status : out CA.Result) is
      J : CA.Matrix (1 .. 1, 1 .. Chain'Length) with Relaxed_Initialization;
      Pos : constant CA.Parameter_Array := [1 => (MJ.Equality_Flex.Edge_Residual (Length, Rest), 0.0)];
      Initial_Used : constant Natural := B.Used with Ghost => Static;
   begin
      for K in Chain'Range loop
         J (1, K) := Values (K);
         pragma Loop_Invariant (for all C in 1 .. K => J (1, C)'Initialized);
         pragma Loop_Invariant (for all C in 1 .. K => J (1, C) = Values (C));
      end loop;
      pragma Assert (Static => (for all C in Chain'Range => J (1, C) = Values (C)));
      CA.Append (B, CA.Equality, Eq_Id, Chain, J, Pos, 0.0, Status);
      pragma Assert (Static => (if Status = CA.Success then
        (for all R in Pos'Range => (for all K in Chain'Range =>
          B.Columns ((Initial_Used + (R-1)*Chain'Length) + K) = Chain (K)))));
      pragma Assert (Static => (if Status = CA.Success then
        (for all K in Chain'Range => B.Columns (Initial_Used+K) = Chain (K))));
   end Append;
end MJ.Equality_Flex_Rows;

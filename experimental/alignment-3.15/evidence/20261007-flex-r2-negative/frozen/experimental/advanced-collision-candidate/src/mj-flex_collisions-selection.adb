package body MJ.Flex_Collisions.Selection with SPARK_Mode is
   procedure Compact (C : in out Batch; Start : Natural; Selected : Mask) is
      Kept : Natural := 0;
   begin
      for I in Selected'Range loop
         pragma Loop_Invariant (Static => Kept = Prefix_Count (Selected, I));
         pragma Loop_Invariant (Static =>
           (for all J in 0 .. Integer (Start)-1 => C.Items (J) = C.Items'Loop_Entry (J)));
         pragma Loop_Invariant (Static =>
           (for all J in 0 .. Integer (I)-1 =>
             (if Selected (J) then C.Items (Start+Prefix_Count (Selected, J)) = C.Items'Loop_Entry (Start+J))));
         pragma Loop_Invariant (Static =>
           (for all J in Start+Kept .. C.Items'Last => C.Items (J) = C.Items'Loop_Entry (J)));
         if Selected (I) then
            C.Items (Start+Kept) := C.Items (Start+I); Kept := Kept+1;
         end if;
      end loop;
      C.Length := Start+Kept;
   end Compact;
end MJ.Flex_Collisions.Selection;

package body MJ.Contact_Geometry with SPARK_Mode is
   procedure Reverse_Manifold (M : in out Manifold) is
   begin
      for I in 0 .. M.Length-1 loop
         pragma Loop_Invariant (M.Length = M.Length'Loop_Entry);
         pragma Loop_Invariant (Active_Initialized (M));
         pragma Loop_Invariant
           (for all K in 0 .. I-1 =>
              M.Items (K).Position = M.Items'Loop_Entry (K).Position
              and M.Items (K).Distance = M.Items'Loop_Entry (K).Distance
              and M.Items (K).Tangent = M.Items'Loop_Entry (K).Tangent
              and (for all J in Axis => M.Items (K).Normal (J) = -M.Items'Loop_Entry (K).Normal (J)));
         pragma Loop_Invariant (for all K in I .. M.Length-1 => M.Items (K) = M.Items'Loop_Entry (K));
         for J in Axis loop M.Items (I).Normal (J) := -M.Items (I).Normal (J); end loop;
      end loop;
   end Reverse_Manifold;
end MJ.Contact_Geometry;

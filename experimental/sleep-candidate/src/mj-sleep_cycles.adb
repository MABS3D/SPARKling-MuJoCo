package body MJ.Sleep_Cycles with SPARK_Mode is
   procedure Reveal_Cycle_Search
     (T : Tree_Array; Start, Current, Smallest : Integer;
      Remaining : Natural) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Cycle_Search);
   begin
      null;
   end Reveal_Cycle_Search;

   function Sleep_Cycle (T : Tree_Array; Start : Integer) return Integer is
      Current, Smallest : Integer := Start;
      Next : Integer;
      Remaining : Natural := T'Length+1;
   begin
      if Start not in T'Range then return -1; end if;
      while Remaining > 0 loop
         pragma Loop_Variant (Decreases => Remaining);
         pragma Loop_Invariant (Remaining <= T'Length+1);
         pragma Loop_Invariant (Current in T'Range and Smallest in T'Range);
         pragma Loop_Invariant (Static =>
           Cycle_Search (T, Start, Start, Start, T'Length+1) =
             Cycle_Search (T, Start, Current, Smallest, Remaining));
         Reveal_Cycle_Search (T, Start, Current, Smallest, Remaining);
         Next := T (Current);
         if Next not in T'Range then return -1; end if;
         Smallest := Integer'Min (Smallest, Next);
         Current := Next;
         if Current = Start then return Smallest; end if;
         Remaining := Remaining - 1;
      end loop;
      Reveal_Cycle_Search (T, Start, Current, Smallest, Remaining);
      return -1;
   end Sleep_Cycle;

end MJ.Sleep_Cycles;

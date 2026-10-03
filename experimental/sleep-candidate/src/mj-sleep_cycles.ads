--  Copyright 2025 DeepMind Technologies Limited.
--  Apache-2.0; see LICENSE. Modified: bounded native traversal and exact model.
with MJ.Sleep_Kernels;
package MJ.Sleep_Cycles with SPARK_Mode is
   Max_Trees : constant := 1024;
   subtype Tree_Value is Integer range MJ.Sleep_Kernels.Fully_Awake .. Max_Trees-1;
   type Tree_Array is array (Integer range <>) of Tree_Value;
   --  Ordered bounded traversal model. Each step follows one tree link and
   --  keeps the smallest visited ID; only a return to Start is a valid cycle.
   --  Static ghosts do not add executable traversal or stack use.
   function Cycle_Search
     (T : Tree_Array; Start, Current, Smallest : Integer;
      Remaining : Natural) return Integer is
     (if Remaining = 0 or else T (Current) not in T'Range then -1
      elsif T (Current) = Start then Integer'Min (Smallest, Start)
      else Cycle_Search (T, Start, T (Current),
        Integer'Min (Smallest, T (Current)), Remaining - 1))
     with Ghost => Static, Global => null,
     Pre => T'First = 0 and then T'Last in -1 .. Max_Trees-1
       and then Start in T'Range and then Current in T'Range
       and then Smallest in T'Range and then Remaining <= Max_Trees+1,
     Post => Cycle_Search'Result in -1 .. T'Last,
     Subprogram_Variant => (Decreases => Remaining),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   procedure Reveal_Cycle_Search
     (T : Tree_Array; Start, Current, Smallest : Integer;
      Remaining : Natural) with Ghost => Static, Global => null,
     Pre => T'First = 0 and then T'Last in -1 .. Max_Trees-1
       and then Start in T'Range and then Current in T'Range
       and then Smallest in T'Range and then Remaining <= Max_Trees+1,
     Post => Cycle_Search (T, Start, Current, Smallest, Remaining) =
       (if Remaining = 0 or else T (Current) not in T'Range then -1
        elsif T (Current) = Start then Integer'Min (Smallest, Start)
        else Cycle_Search (T, Start, T (Current),
          Integer'Min (Smallest, T (Current)), Remaining - 1));

   --  Failure returns -1; bounded traversal handles malformed/out-of-range cycles.
   function Sleep_Cycle (T : Tree_Array; Start : Integer) return Integer with
     Global => null, Pre => T'First = 0 and then T'Last in -1 .. Max_Trees-1,
     Post => (Static => Sleep_Cycle'Result in -1 .. T'Last
       and then Sleep_Cycle'Result =
         (if Start not in T'Range then -1
          else Cycle_Search (T, Start, Start, Start, T'Length+1)));
end MJ.Sleep_Cycles;

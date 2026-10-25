with MJ.Data.Composite_Assembly;
package body MJ.Data.Composite_Checks is
   package CA renames MJ.Data.Composite_Assembly;
   -- Powers of two give independent exact closed-form subtree expectations,
   -- rather than duplicating the accumulation loop in the test oracle.
   Unit : constant Real := 2.0 ** 119;
   procedure Tree (Count : Positive; Kind : Natural) is
      Bodies : Body_Parameter_Array (0 .. Count - 1);
      Source : Real_Array (0 .. 10 * Count - 1);
      Values : CA.Composite_Array (Bodies'Range) with Relaxed_Initialization;
      Weight : Natural;
      Expected : Real;
   begin
      for B in Bodies'Range loop
         Bodies (B).Parent :=
           (if B < 2 or else Kind = 2 then 0 elsif Kind = 0 then B - 1 else 1);
         for K in 0 .. 9 loop Source (10 * B + K) := (if K mod 2 = 0 then Unit else -Unit); end loop;
      end loop;
      CA.Load_Composite (Source, Values);
      CA.Accumulate_Composite (Bodies, Values);
      for B in Bodies'Range loop
         Weight := (if B = 0 or else Kind = 2 then 1
                    elsif Kind = 0 then Count - B
                    elsif B = 1 then Count - 1 else 1);
         for K in 0 .. 9 loop
            Expected := Real (Weight) * (if K mod 2 = 0 then Unit else -Unit);
            if Values (B) (K) /= Expected then raise Program_Error with "composite subtree count"; end if;
         end loop;
      end loop;
   end Tree;
   procedure Run is
      Bodies : Body_Parameter_Array (0 .. 3);
      Source : Real_Array (0 .. 39) := [others => 0.0];
      Values : CA.Composite_Array (0 .. 3) with Relaxed_Initialization;
   begin
      Tree (1, 0); Tree (Max_Bodies, 0); Tree (Max_Bodies, 1); Tree (Max_Bodies, 2);
      Bodies (1).Parent := 0; Bodies (2).Parent := 1; Bodies (3).Parent := 2;
      for K in 0 .. 9 loop
         Source (10 + K) := 1.0e36; Source (20 + K) := -1.0e36; Source (30 + K) := 1.0;
      end loop;
      CA.Load_Composite (Source, Values); CA.Accumulate_Composite (Bodies, Values);
      -- Descending order loses the tiny term before cancellation: result 0.
      -- Reassociating the root with its child first would instead produce 1.
      for K in 0 .. 9 loop
         if Values (0) (K) /= 0.0 or else Values (1) (K) /= 0.0
           or else Values (2) (K) /= -1.0e36 or else Values (3) (K) /= 1.0
         then raise Program_Error with "composite rounded order"; end if;
      end loop;
   end Run;
end MJ.Data.Composite_Checks;

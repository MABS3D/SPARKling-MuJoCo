package MJ.Flex_Collisions.Selection with SPARK_Mode is
   type Mask is array (Natural range <>) of Boolean;
   function Prefix_Count (Selected : Mask; N : Natural) return Natural is
     (if N = 0 then 0 else Prefix_Count (Selected, N-1) + (if Selected (N-1) then 1 else 0))
     with Ghost => Static, Global => null,
       Pre => Selected'First = 0 and then Selected'Length <= Natural'Last
         and then N <= Selected'Length,
       Post => Prefix_Count'Result <= N and then
         (for all I in 0 .. Integer (N)-1 =>
           (if Selected (I) then Prefix_Count (Selected, I) < Prefix_Count'Result)),
       Subprogram_Variant => (Decreases => N);
   procedure Compact (C : in out Batch; Start : Natural; Selected : Mask) with
     Global => null,
     Pre => Start <= C.Length and then C.Length <= C.Capacity
       and then Selected'First = 0 and then Selected'Length = C.Length-Start,
     Post => (Static => C.Length = Start + Prefix_Count (Selected, Selected'Length)
       and then (for all I in 0 .. Integer (Start)-1 => C.Items (I) = C.Items'Old (I))
       and then (for all I in Selected'Range =>
         (if Selected (I) then C.Items (Start + Prefix_Count (Selected, I)) = C.Items'Old (Start+I)))
       and then (for all I in C.Length .. C.Items'Last => C.Items (I) = C.Items'Old (I)));
end MJ.Flex_Collisions.Selection;

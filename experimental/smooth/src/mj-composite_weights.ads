package MJ.Composite_Weights with SPARK_Mode, Ghost => Static is
   Max_Bodies : constant := 4_096;
   subtype Weight is Natural range 0 .. Max_Bodies;
   subtype Sum_Count is Natural range 0 .. Max_Bodies * Max_Bodies;
   type Weight_Array is array (Natural range <>) of Weight;
   function Layout (W : Weight_Array) return Boolean is
     (W'First = 0 and then W'Length in 1 .. Max_Bodies);
   function Prefix_Sum (W : Weight_Array; Count : Natural) return Sum_Count is
     (if Count = 0 then 0 else Prefix_Sum (W, Count - 1) + W (Count - 1))
     with Global => null, Pre => Layout (W) and then Count <= W'Length,
     Post => Prefix_Sum'Result <= Count * Max_Bodies,
     Subprogram_Variant => (Decreases => Count);
   procedure Element_Bound (W : Weight_Array; Count : Natural; Index : Natural)
     with Global => null, Pre => Layout (W) and then Count <= W'Length and then Index < Count,
     Post => W (Index) <= Prefix_Sum (W, Count),
     Subprogram_Variant => (Decreases => Count);
   procedure Pair_Bound (W : Weight_Array; Count : Natural; I, J : Natural)
     with Global => null, Pre => Layout (W) and then Count <= W'Length and then I < J and then J < Count,
     Post => W (I) + W (J) <= Prefix_Sum (W, Count),
     Subprogram_Variant => (Decreases => Count);
   procedure Replacement_Sum (Before, After : Weight_Array; Count, Index : Natural)
     with Global => null,
     Pre => Layout (Before) and then Layout (After) and then Before'Last = After'Last
       and then Count <= Before'Length and then Index in Before'Range
       and then (for all K in Before'Range => (if K /= Index then Before (K) = After (K))),
     Post => (if Index < Count then Prefix_Sum (After, Count) + Before (Index)
       = Prefix_Sum (Before, Count) + After (Index)
       else Prefix_Sum (After, Count) = Prefix_Sum (Before, Count)),
     Subprogram_Variant => (Decreases => Count);
   procedure Sum_Ones (W : Weight_Array; Count : Natural)
     with Global => null,
     Pre => Layout (W) and then Count <= W'Length and then (for all X of W => X = 1),
     Post => Prefix_Sum (W, Count) = Count,
     Subprogram_Variant => (Decreases => Count);
   procedure Initialize (W : out Weight_Array)
     with Global => null, Pre => W'First = 0 and then W'Length in 1 .. Max_Bodies,
     Post => (for all X of W => X = 1) and then Prefix_Sum (W, W'Length) = W'Length;
   procedure Transfer (W : in out Weight_Array; Child, Parent : Natural)
     with Global => null,
     Pre => Layout (W) and then Parent < Child and then Child in W'Range
       and then W (Parent) > 0 and then W (Child) > 0
       and then Prefix_Sum (W, W'Length) <= Max_Bodies,
     Post => W (Child) = 0 and then W (Parent) = W'Old (Parent) + W'Old (Child)
       and then (for all K in W'Range => (if K /= Parent and then K /= Child then W (K) = W'Old (K)))
       and then Prefix_Sum (W, W'Length) = Prefix_Sum (W'Old, W'Length);
   procedure Discard (W : in out Weight_Array; Child : Natural)
     with Global => null, Pre => Layout (W) and then Child in W'Range,
     Post => W (Child) = 0
       and then (for all K in W'Range => (if K /= Child then W (K) = W'Old (K)))
       and then Prefix_Sum (W, W'Length) <= Prefix_Sum (W'Old, W'Length);
end MJ.Composite_Weights;

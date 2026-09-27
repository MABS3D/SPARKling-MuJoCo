package body MJ.Composite_Weights with SPARK_Mode is
   procedure Element_Bound (W : Weight_Array; Count : Natural; Index : Natural) is
   begin
      if Index < Count - 1 then Element_Bound (W, Count - 1, Index); end if;
   end Element_Bound;
   procedure Pair_Bound (W : Weight_Array; Count : Natural; I, J : Natural) is
   begin
      if J = Count - 1 then Element_Bound (W, Count - 1, I);
      else Pair_Bound (W, Count - 1, I, J); end if;
   end Pair_Bound;
   procedure Replacement_Sum (Before, After : Weight_Array; Count, Index : Natural) is
   begin
      if Count > 0 then Replacement_Sum (Before, After, Count - 1, Index); end if;
   end Replacement_Sum;
   procedure Sum_Ones (W : Weight_Array; Count : Natural) is
   begin
      if Count > 0 then Sum_Ones (W, Count - 1); end if;
   end Sum_Ones;
   procedure Initialize (W : out Weight_Array) is
   begin
      W := [others => 1];
      Sum_Ones (W, W'Length);
   end Initialize;
   procedure Transfer (W : in out Weight_Array; Child, Parent : Natural) is
      Before : constant Weight_Array := W;
   begin
      Pair_Bound (W, W'Length, Parent, Child);
      W (Parent) := W (Parent) + W (Child);
      Replacement_Sum (Before, W, W'Length, Parent);
      declare
         Middle : constant Weight_Array := W;
      begin
         W (Child) := 0;
         Replacement_Sum (Middle, W, W'Length, Child);
      end;
   end Transfer;
   procedure Discard (W : in out Weight_Array; Child : Natural) is
      Before : constant Weight_Array := W;
   begin
      W (Child) := 0;
      Replacement_Sum (Before, W, W'Length, Child);
   end Discard;
end MJ.Composite_Weights;

package body MJ.Native_Mass_Kernels with SPARK_Mode is
   procedure Zero (Mass : out Real_Array) is
   begin
      Mass := [others => 0.0];
   end Zero;
   procedure Update (Mass : in out Real_Array; Slot : Natural;
                     Change : Value; Assign : Boolean; Accepted : out Boolean) is
      Next : constant Real := (if Assign then Change else Mass (Slot) + Change);
   begin
      Accepted := Next in Value;
      if Accepted then Mass (Slot) := Next; end if;
   end Update;
   procedure Gather_Row
     (Dense : Real_Array; Columns : Int_Array; Nv, Row, First, Width : Natural;
      Mass : in out Real_Array) is
   begin
      for H in First .. (First + Width) - 1 loop
         Mass (H) := Dense (Row * Nv + Columns (H));
         pragma Loop_Invariant (for all K in Mass'Range => Mass (K) =
           (if K in First .. H then Dense (Row * Nv + Columns (K))
            else Mass'Loop_Entry (K)));
      end loop;
   end Gather_Row;
end MJ.Native_Mass_Kernels;

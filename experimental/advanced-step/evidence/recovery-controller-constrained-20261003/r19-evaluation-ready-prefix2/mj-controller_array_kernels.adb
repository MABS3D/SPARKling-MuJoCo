package body MJ.Controller_Array_Kernels with SPARK_Mode is
   procedure Copy_Prefix (Target : in out Real_Array; Source : Real_Array; Count : Natural) is
   begin
      Target (0 .. Integer (Count)-1) := Source (0 .. Integer (Count)-1);
   end Copy_Prefix;
end MJ.Controller_Array_Kernels;

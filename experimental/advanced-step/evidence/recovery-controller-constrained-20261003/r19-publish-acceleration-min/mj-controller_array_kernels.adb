package body MJ.Controller_Array_Kernels with SPARK_Mode is
   procedure Copy_Prefix (Target : in out Real_Array; Source : Real_Array; Count : Natural) is
   begin
      Target (0 .. Integer (Count)-1) := Source (0 .. Integer (Count)-1);
   end Copy_Prefix;
   procedure Publish_Acceleration
     (Target : in out Real_Array; Valid : out Boolean; Source : Real_Array; Count : Natural) is
   begin
      Copy_Prefix (Target, Source, Count);
      Valid := True;
   end Publish_Acceleration;
end MJ.Controller_Array_Kernels;

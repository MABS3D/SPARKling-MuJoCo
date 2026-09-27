package body MJ.Spatial_Storage with SPARK_Mode is
   function Load_Inertia (Source : Real_Array; Base : Natural) return Inertia is
   begin
      return [Source (Base + 0), Source (Base + 1), Source (Base + 2), Source (Base + 3), Source (Base + 4), Source (Base + 5), Source (Base + 6), Source (Base + 7), Source (Base + 8), Source (Base + 9)];
   end Load_Inertia;
   procedure Store_Inertia (Target : in out Real_Array; Base : Natural; Value : Inertia) is
   begin
      Target (Base + 0) := Value (0);
      Target (Base + 1) := Value (1);
      Target (Base + 2) := Value (2);
      Target (Base + 3) := Value (3);
      Target (Base + 4) := Value (4);
      Target (Base + 5) := Value (5);
      Target (Base + 6) := Value (6);
      Target (Base + 7) := Value (7);
      Target (Base + 8) := Value (8);
      Target (Base + 9) := Value (9);
   end Store_Inertia;
   function Load_Motion (Source : Real_Array; Base : Natural) return Motion is
   begin
      return [Source (Base + 0), Source (Base + 1), Source (Base + 2), Source (Base + 3), Source (Base + 4), Source (Base + 5)];
   end Load_Motion;
   procedure Store_Motion (Target : in out Real_Array; Base : Natural; Value : Motion) is
   begin
      Target (Base + 0) := Value (0);
      Target (Base + 1) := Value (1);
      Target (Base + 2) := Value (2);
      Target (Base + 3) := Value (3);
      Target (Base + 4) := Value (4);
      Target (Base + 5) := Value (5);
   end Store_Motion;
end MJ.Spatial_Storage;

package body MJ.Data.Group_Layout with SPARK_Mode is
   procedure Next_Start (Config : Joint_Parameter_Array; J : Natural) is
      N : constant Natural := J + Width (Config (J).Group_Type);
      H : constant Natural := Config (N).Group_Vadr;
   begin
      if H <= J then
         pragma Assert (Static => J in H .. H + Width (Config (N).Group_Type) - 1);
         pragma Assert (Static => Config (J).Group_Vadr = H);
      elsif H < N then
         pragma Assert (Static => H in J .. J + Width (Config (J).Group_Type) - 1);
         pragma Assert (Static => Config (H).Group_Vadr = J);
         pragma Assert (Static => Config (H).Group_Vadr = H);
      end if;
   end Next_Start;
end MJ.Data.Group_Layout;

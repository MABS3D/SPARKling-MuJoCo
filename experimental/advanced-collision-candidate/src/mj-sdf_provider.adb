package body MJ.SDF_Provider with SPARK_Mode is
   procedure Unavailable (Key : Natural; X : Vec; Need_Gradient : Boolean;
                          Value : out Real; Gradient : out Vec; Result : out Status) is
   begin
      Value := 0.0; Gradient := Zero; Result := Invalid_Input;
   end Unavailable;
end MJ.SDF_Provider;

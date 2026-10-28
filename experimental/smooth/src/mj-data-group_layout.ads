private package MJ.Data.Group_Layout with SPARK_Mode, Ghost => Static is
   function Width (Kind : Natural) return Positive is
     (if Kind = 0 then 6 elsif Kind = 1 then 3 else 1)
     with Global => null, Pre => Kind <= 3;
   function Uniform_Group (Config : Joint_Parameter_Array; J : Natural) return Boolean is
     (J in Config'Range
      and then Config (J).Group_Vadr in Config'Range
      and then Config (J).Group_Vadr <= Config'Last - (Width (Config (J).Group_Type) - 1)
      and then Config (J).Component < Width (Config (J).Group_Type)
      and then J = Config (J).Group_Vadr + Config (J).Component
      and then (for all A in 0 .. Width (Config (J).Group_Type) - 1 =>
        Config (Config (J).Group_Vadr + A).Group_Vadr = Config (J).Group_Vadr
        and then Config (Config (J).Group_Vadr + A).Group_Type = Config (J).Group_Type
        and then Config (Config (J).Group_Vadr + A).Component = A
        and then Config (Config (J).Group_Vadr + A).Body_Id = Config (J).Body_Id))
     with Global => null,
     Pre => Config'First = 0 and then Config'Length <= Max_Dofs;
   function Layout (Config : Joint_Parameter_Array) return Boolean is
     (for all J in Config'Range => Uniform_Group (Config, J))
     with Global => null,
     Pre => Config'First = 0 and then Config'Length <= Max_Dofs;
   procedure Next_Start (Config : Joint_Parameter_Array; J : Natural)
     with Global => null,
     Pre => Config'First = 0 and then Config'Length <= Max_Dofs
       and then Layout (Config) and then J in Config'Range
       and then Config (J).Group_Vadr = J
       and then J + Width (Config (J).Group_Type) in Config'Range,
     Post => Config (J + Width (Config (J).Group_Type)).Group_Vadr =
       J + Width (Config (J).Group_Type);
end MJ.Data.Group_Layout;

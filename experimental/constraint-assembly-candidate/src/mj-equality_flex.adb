package body MJ.Equality_Flex with SPARK_Mode is
   function Edge_Residual (Length, Rest : Nonneg_Tier0) return Tier1_Real is
     (Length-Rest);

   function Project_First (Value, Direction : Tier1_Real) return First_Value is
     (if Direction = 0.0 then 0.0 else 0.0 + Value*Direction);

   function Project_Second
     (Previous : First_Value; Value, Direction : Tier1_Real) return Second_Value is
     (if Direction = 0.0 then Previous else Previous + Value*Direction);

   function Project_Third
     (Previous : Second_Value; Value, Direction : Tier1_Real) return Projection_Value is
     (if Direction = 0.0 then Previous else Previous + Value*Direction);

   function Edge_Projection
     (J0, J1, J2, D0, D1, D2 : Tier1_Real) return Projection_Value is
     (Project_Third (Project_Second (Project_First (J0, D0), J1, D1), J2, D2));
end MJ.Equality_Flex;

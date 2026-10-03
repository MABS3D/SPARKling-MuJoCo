--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see repository LICENSE.
--  Modified: ordered flex-edge equality arithmetic, MuJoCo 3.14.0.
with MJ.Types; use MJ.Types;
package MJ.Equality_Flex with SPARK_Mode is
   subtype First_Value is Real range -1.1e60 .. 1.1e60;
   subtype Second_Value is Real range -2.2e60 .. 2.2e60;
   subtype Projection_Value is Real range -3.3e60 .. 3.3e60;

   function Edge_Residual (Length, Rest : Nonneg_Tier0) return Tier1_Real with
     Global => null, Inline_Always,
     Post => Edge_Residual'Result = Length-Rest;

   --  mj_flex uses mju_mulMatTVec, which starts from positive zero and
   --  skips an axis whose direction is zero. Preserve these branches and
   --  the ordered updates rather than substituting an unbranched dot3.
   function Project_First (Value, Direction : Tier1_Real) return First_Value with
     Global => null, Inline_Always,
     Post => Project_First'Result =
       (if Direction = 0.0 then 0.0 else 0.0 + Value*Direction);
   function Project_Second
     (Previous : First_Value; Value, Direction : Tier1_Real) return Second_Value with
     Global => null, Inline_Always,
     Post => Project_Second'Result =
       (if Direction = 0.0 then Previous else Previous + Value*Direction);
   function Project_Third
     (Previous : Second_Value; Value, Direction : Tier1_Real) return Projection_Value with
     Global => null, Inline_Always,
     Post => Project_Third'Result =
       (if Direction = 0.0 then Previous else Previous + Value*Direction);
   function Edge_Projection
     (J0, J1, J2, D0, D1, D2 : Tier1_Real) return Projection_Value with
     Global => null, Inline_Always,
     Post => Edge_Projection'Result = Project_Third
       (Project_Second (Project_First (J0, D0), J1, D1), J2, D2);
end MJ.Equality_Flex;

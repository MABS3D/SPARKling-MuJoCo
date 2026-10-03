with MJ.Types; use MJ.Types;

--  mj_fwdAcceleration, MuJoCo 3.14.0: the supplied bias includes gravity
--  evaluated within RNE. This does not replace the separate diagnostic forces.
package MJ.Force_Composition with SPARK_Mode is
   subtype Component is Real range -1.0e60 .. 1.0e60;
   subtype Wide_Sum is Real range -4.0e60 .. 4.0e60;
   function Bounded (A : Real_Array) return Boolean is
     (for all X of A => X in Component) with Global => null;
   function Smooth_Total (Passive, Full_Bias, Applied, Actuator : Real) return Wide_Sum
     with Global => null, Inline,
     Pre => (Static => Passive in Component and then Full_Bias in Component
       and then Applied in Component and then Actuator in Component),
     Post => Smooth_Total'Result = ((Passive-Full_Bias)+Applied)+Actuator;
   procedure Compose
     (Passive, Full_Bias, Applied, Actuator : Real_Array;
      Total : out Real_Array; Accepted : out Boolean)
     with Global => null, Relaxed_Initialization => Total,
     Pre => (Static => Passive'First = 0 and then Passive'Length <= 256
       and then Full_Bias'First = 0 and then Full_Bias'Last = Passive'Last
       and then Applied'First = 0 and then Applied'Last = Passive'Last
       and then Actuator'First = 0 and then Actuator'Last = Passive'Last
       and then Total'First = 0 and then Total'Last = Passive'Last
       and then Bounded (Passive) and then Bounded (Full_Bias)
       and then Bounded (Applied) and then Bounded (Actuator)),
     Post => (Static => (if Accepted then Total'Initialized and then Bounded (Total)
       and then (for all I in Total'Range => Total (I) =
         Smooth_Total (Passive (I), Full_Bias (I), Applied (I), Actuator (I)))));
end MJ.Force_Composition;

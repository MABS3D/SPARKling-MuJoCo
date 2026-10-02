with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
package MJ.Fluid_Transport with SPARK_Mode is
   subtype Contribution is Real range -1.0e130 .. 1.0e130;
   function Lever_Torque (Torque, Offset, Force : Vector) return Vector with
     Global => null, Pre => Bounded (Torque) and then Bounded (Force) and then Bounded (Offset, 1.0e66),
     Post => Bounded (Lever_Torque'Result, 1.0e128)
       and then Lever_Torque'Result =
        [Torque (0) + (Offset (1)*Force (2) - Offset (2)*Force (1)),
         Torque (1) + (Offset (2)*Force (0) - Offset (0)*Force (2)),
         Torque (2) + (Offset (0)*Force (1) - Offset (1)*Force (0))];
   pragma Inline_Always (Lever_Torque);
   function Project (Hinge : Boolean; Direction, Offset, Force, Torque : Vector) return Contribution with
     Global => null, Pre => Bounded (Direction, 2.0) and then Bounded (Offset, 1.0e66)
       and then Bounded (Force) and then Bounded (Torque),
     Post => Project'Result = Dot (Direction, (if Hinge then Lever_Torque (Torque, Offset, Force) else Force));
   pragma Inline_Always (Project);
   procedure Merge (Force, Torque : in out Vector; Child_Force, Child_Torque, Offset : Vector; Ok : out Boolean) with
     Global => null, Pre => Bounded (Force) and then Bounded (Torque)
       and then Bounded (Child_Force) and then Bounded (Child_Torque) and then Bounded (Offset, 1.0e66),
     Post => Bounded (Force) and then Bounded (Torque)
       and then (if Ok then Force = Force'Old + Child_Force
         and then Torque = Torque'Old + Lever_Torque (Child_Torque, Offset, Child_Force)
         else Force = Force'Old and then Torque = Torque'Old);
   pragma Inline_Always (Merge);
end MJ.Fluid_Transport;

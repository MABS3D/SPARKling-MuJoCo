with MJ.Types; use MJ.Types;
with MJ.Spatial_Kernels; use MJ.Spatial_Kernels;

--  Rounded scalar-joint comVel/RNE operations, in the common root COM frame.
package MJ.Spatial_Dynamics with SPARK_Mode is
   subtype Narrow is Real range -1.0e12 .. 1.0e12;
   subtype Wide is Real range -1.0e54 .. 1.0e54;
   subtype Cross_Real is Real range -1.0e68 .. 1.0e68;
   function Cross_Term (A, B : Narrow; C, D : Wide) return Cross_Real
     with Global => null,
     Post => Cross_Term'Result = (-A)*C + B*D;
   function Narrow_Term (A, B, C, D : Narrow) return Real
     with Global => null,
     Post => Narrow_Term'Result in -1.0e25 .. 1.0e25
       and then Narrow_Term'Result = (-A)*C + B*D;
   subtype Cross_Motion_Real is Real range -1.0e26 .. 1.0e26;
   subtype Scaled_Real is Real range -1.0e38 .. 1.0e38;
   subtype Cross_Force_Real is Real range -1.0e69 .. 1.0e69;
   function Pack (E0, E1, E2, E3, E4, E5 : Cross_Force_Real) return Motion
     with Global => null,
     Post => Bounded (Pack'Result, 1.0e69)
       and then Pack'Result (0) = E0 and then Pack'Result (1) = E1
       and then Pack'Result (2) = E2 and then Pack'Result (3) = E3
       and then Pack'Result (4) = E4 and then Pack'Result (5) = E5;
   function Scaled_Component (Base, Increment : Cross_Motion_Real; Scale : Tier0_Real)
     return Scaled_Real with Global => null,
     Post => Scaled_Component'Result = Base + Increment*Scale;
   function Cross_Motion (Velocity, Axis : Motion) return Motion
     with Global => null,
     Pre => Bounded (Velocity, 1.0e12) and then Bounded (Axis, 1.0e12),
     Post => Bounded (Velocity, 1.0e12) and then Bounded (Axis, 1.0e12)
       and then Bounded (Cross_Motion'Result, 1.0e26)
       and then Cross_Motion'Result (0) = Narrow_Term (Velocity (2), Velocity (1), Axis (1), Axis (2))
       and then Cross_Motion'Result (1) = Narrow_Term (Velocity (0), Velocity (2), Axis (2), Axis (0))
       and then Cross_Motion'Result (2) = Narrow_Term (Velocity (1), Velocity (0), Axis (0), Axis (1))
       and then Cross_Motion'Result (3) = Narrow_Term (Velocity (2), Velocity (1), Axis (4), Axis (5)) + Narrow_Term (Velocity (5), Velocity (4), Axis (1), Axis (2))
       and then Cross_Motion'Result (4) = Narrow_Term (Velocity (0), Velocity (2), Axis (5), Axis (3)) + Narrow_Term (Velocity (3), Velocity (5), Axis (2), Axis (0))
       and then Cross_Motion'Result (5) = Narrow_Term (Velocity (1), Velocity (0), Axis (3), Axis (4)) + Narrow_Term (Velocity (4), Velocity (3), Axis (0), Axis (1));
   function Add_Scaled (Base, Increment : Motion; Scale : Tier0_Real) return Motion
     with Global => null,
     Pre => Bounded (Base, 1.0e26) and then Bounded (Increment, 1.0e26),
     Post => Bounded (Base, 1.0e26) and then Bounded (Increment, 1.0e26)
       and then Bounded (Add_Scaled'Result, 1.0e38)
       and then Add_Scaled'Result (0) = Scaled_Component (Base (0), Increment (0), Scale)
       and then Add_Scaled'Result (1) = Scaled_Component (Base (1), Increment (1), Scale)
       and then Add_Scaled'Result (2) = Scaled_Component (Base (2), Increment (2), Scale)
       and then Add_Scaled'Result (3) = Scaled_Component (Base (3), Increment (3), Scale)
       and then Add_Scaled'Result (4) = Scaled_Component (Base (4), Increment (4), Scale)
       and then Add_Scaled'Result (5) = Scaled_Component (Base (5), Increment (5), Scale);
   function Cross_Force (Velocity, Force : Motion) return Motion
     with Global => null,
     Pre => Bounded (Velocity, 1.0e12) and then Bounded (Force, 1.0e54),
     Post => Bounded (Velocity, 1.0e12) and then Bounded (Force, 1.0e54)
       and then Bounded (Cross_Force'Result, 1.0e69)
       and then Cross_Force'Result (0) = Cross_Term (Velocity (2), Velocity (1), Force (1), Force (2)) + Cross_Term (Velocity (5), Velocity (4), Force (4), Force (5))
       and then Cross_Force'Result (1) = Cross_Term (Velocity (0), Velocity (2), Force (2), Force (0)) + Cross_Term (Velocity (3), Velocity (5), Force (5), Force (3))
       and then Cross_Force'Result (2) = Cross_Term (Velocity (1), Velocity (0), Force (0), Force (1)) + Cross_Term (Velocity (4), Velocity (3), Force (3), Force (4))
       and then Cross_Force'Result (3) = Cross_Term (Velocity (2), Velocity (1), Force (4), Force (5))
       and then Cross_Force'Result (4) = Cross_Term (Velocity (0), Velocity (2), Force (5), Force (3))
       and then Cross_Force'Result (5) = Cross_Term (Velocity (1), Velocity (0), Force (3), Force (4));
   subtype Gravity_Real is Real range -1.0e48 .. 1.0e48;
   function Gravity_Term (A, B : Body_Inertia_Real; C, D : Tier0_Real) return Gravity_Real
     with Global => null, Post => Gravity_Term'Result = (-A)*C + B*D;
   function Gravity_Linear (Mass : Body_Inertia_Real; G : Tier0_Real) return Gravity_Real
     with Global => null, Post => Gravity_Linear'Result = Mass*G;
   --  cinert times a pure linear acceleration: zero angular terms are omitted.
   function Gravity_Force (X, Y, Z, Mass : Body_Inertia_Real;
                           G0, G1, G2 : Tier0_Real) return Motion
     with Global => null,
     Post => Bounded (Gravity_Force'Result, 1.0e48)
       and then Gravity_Force'Result (0) = Gravity_Term (Z, Y, G1, G2)
       and then Gravity_Force'Result (1) = Gravity_Term (X, Z, G2, G0)
       and then Gravity_Force'Result (2) = Gravity_Term (Y, X, G0, G1)
       and then Gravity_Force'Result (3) = Gravity_Linear (Mass, G0)
       and then Gravity_Force'Result (4) = Gravity_Linear (Mass, G1)
       and then Gravity_Force'Result (5) = Gravity_Linear (Mass, G2);
end MJ.Spatial_Dynamics;

package body MJ.Spatial_Dynamics with SPARK_Mode is
   function Cross_Term (A, B : Narrow; C, D : Wide) return Cross_Real is
      AC : constant Real range -2.0e66 .. 2.0e66 := (-A)*C;
      BD : constant Real range -2.0e66 .. 2.0e66 := B*D;
   begin
      return AC + BD;
   end Cross_Term;
   function Narrow_Term (A, B, C, D : Narrow) return Real is
      AC : constant Real range -2.0e24 .. 2.0e24 := (-A)*C;
      BD : constant Real range -2.0e24 .. 2.0e24 := B*D;
   begin
      return AC + BD;
   end Narrow_Term;
   function Pack (E0, E1, E2, E3, E4, E5 : Cross_Force_Real) return Motion is
   begin
      return [E0, E1, E2, E3, E4, E5];
   end Pack;
   function Scaled_Component (Base, Increment : Cross_Motion_Real; Scale : Tier0_Real)
     return Scaled_Real is
      Product : constant Real range -2.0e36 .. 2.0e36 := Increment*Scale;
   begin
      return Base + Product;
   end Scaled_Component;
   function Cross_Motion (Velocity, Axis : Motion) return Motion is
      E0, E1, E2, E3, E4, E5 : Cross_Motion_Real;
   begin
      E0 := Narrow_Term (Velocity (2), Velocity (1), Axis (1), Axis (2));
      pragma Assert (Static => E0 = Narrow_Term (Velocity (2), Velocity (1), Axis (1), Axis (2)));
      E1 := Narrow_Term (Velocity (0), Velocity (2), Axis (2), Axis (0));
      pragma Assert (Static => E1 = Narrow_Term (Velocity (0), Velocity (2), Axis (2), Axis (0)));
      E2 := Narrow_Term (Velocity (1), Velocity (0), Axis (0), Axis (1));
      pragma Assert (Static => E2 = Narrow_Term (Velocity (1), Velocity (0), Axis (0), Axis (1)));
      E3 := Narrow_Term (Velocity (2), Velocity (1), Axis (4), Axis (5)) + Narrow_Term (Velocity (5), Velocity (4), Axis (1), Axis (2));
      pragma Assert (Static => E3 = Narrow_Term (Velocity (2), Velocity (1), Axis (4), Axis (5)) + Narrow_Term (Velocity (5), Velocity (4), Axis (1), Axis (2)));
      E4 := Narrow_Term (Velocity (0), Velocity (2), Axis (5), Axis (3)) + Narrow_Term (Velocity (3), Velocity (5), Axis (2), Axis (0));
      pragma Assert (Static => E4 = Narrow_Term (Velocity (0), Velocity (2), Axis (5), Axis (3)) + Narrow_Term (Velocity (3), Velocity (5), Axis (2), Axis (0)));
      E5 := Narrow_Term (Velocity (1), Velocity (0), Axis (3), Axis (4)) + Narrow_Term (Velocity (4), Velocity (3), Axis (0), Axis (1));
      pragma Assert (Static => E5 = Narrow_Term (Velocity (1), Velocity (0), Axis (3), Axis (4)) + Narrow_Term (Velocity (4), Velocity (3), Axis (0), Axis (1)));
      return Pack (E0, E1, E2, E3, E4, E5);
   end Cross_Motion;
   function Add_Scaled (Base, Increment : Motion; Scale : Tier0_Real) return Motion is
      E0 : constant Scaled_Real := Scaled_Component (Base (0), Increment (0), Scale);
      E1 : constant Scaled_Real := Scaled_Component (Base (1), Increment (1), Scale);
      E2 : constant Scaled_Real := Scaled_Component (Base (2), Increment (2), Scale);
      E3 : constant Scaled_Real := Scaled_Component (Base (3), Increment (3), Scale);
      E4 : constant Scaled_Real := Scaled_Component (Base (4), Increment (4), Scale);
      E5 : constant Scaled_Real := Scaled_Component (Base (5), Increment (5), Scale);
   begin
      return Pack (E0, E1, E2, E3, E4, E5);
   end Add_Scaled;
   function Cross_Force (Velocity, Force : Motion) return Motion is
      E0, E1, E2, E3, E4, E5 : Cross_Force_Real;
   begin
      E0 := Cross_Term (Velocity (2), Velocity (1), Force (1), Force (2)) + Cross_Term (Velocity (5), Velocity (4), Force (4), Force (5));
      pragma Assert (Static => E0 = Cross_Term (Velocity (2), Velocity (1), Force (1), Force (2)) + Cross_Term (Velocity (5), Velocity (4), Force (4), Force (5)));
      E1 := Cross_Term (Velocity (0), Velocity (2), Force (2), Force (0)) + Cross_Term (Velocity (3), Velocity (5), Force (5), Force (3));
      pragma Assert (Static => E1 = Cross_Term (Velocity (0), Velocity (2), Force (2), Force (0)) + Cross_Term (Velocity (3), Velocity (5), Force (5), Force (3)));
      E2 := Cross_Term (Velocity (1), Velocity (0), Force (0), Force (1)) + Cross_Term (Velocity (4), Velocity (3), Force (3), Force (4));
      pragma Assert (Static => E2 = Cross_Term (Velocity (1), Velocity (0), Force (0), Force (1)) + Cross_Term (Velocity (4), Velocity (3), Force (3), Force (4)));
      E3 := Cross_Term (Velocity (2), Velocity (1), Force (4), Force (5));
      pragma Assert (Static => E3 = Cross_Term (Velocity (2), Velocity (1), Force (4), Force (5)));
      E4 := Cross_Term (Velocity (0), Velocity (2), Force (5), Force (3));
      pragma Assert (Static => E4 = Cross_Term (Velocity (0), Velocity (2), Force (5), Force (3)));
      E5 := Cross_Term (Velocity (1), Velocity (0), Force (3), Force (4));
      pragma Assert (Static => E5 = Cross_Term (Velocity (1), Velocity (0), Force (3), Force (4)));
      return Pack (E0, E1, E2, E3, E4, E5);
   end Cross_Force;
   function Gravity_Term (A, B : Body_Inertia_Real; C, D : Tier0_Real) return Gravity_Real is
      AC : constant Real range -2.0e46 .. 2.0e46 := (-A)*C;
      BD : constant Real range -2.0e46 .. 2.0e46 := B*D;
   begin
      return AC + BD;
   end Gravity_Term;
   function Gravity_Linear (Mass : Body_Inertia_Real; G : Tier0_Real) return Gravity_Real is
   begin
      return Mass*G;
   end Gravity_Linear;
   function Gravity_Force (X, Y, Z, Mass : Body_Inertia_Real;
                           G0, G1, G2 : Tier0_Real) return Motion is
      E0 : constant Gravity_Real := Gravity_Term (Z, Y, G1, G2);
      E1 : constant Gravity_Real := Gravity_Term (X, Z, G2, G0);
      E2 : constant Gravity_Real := Gravity_Term (Y, X, G0, G1);
      E3 : constant Gravity_Real := Gravity_Linear (Mass, G0);
      E4 : constant Gravity_Real := Gravity_Linear (Mass, G1);
      E5 : constant Gravity_Real := Gravity_Linear (Mass, G2);
   begin
      return Pack (E0, E1, E2, E3, E4, E5);
   end Gravity_Force;
end MJ.Spatial_Dynamics;

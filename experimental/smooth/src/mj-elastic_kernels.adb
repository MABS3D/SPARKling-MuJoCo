package body MJ.Elastic_Kernels with SPARK_Mode is
   function Squared_Length (A, B : Particle) return Real is
      subtype Difference is Real range -2.0e10 .. 2.0e10;
      subtype Square is Real range 0.0 .. 5.0e20;
      X : constant Difference := B.Position (0) - A.Position (0);
      Y : constant Difference := B.Position (1) - A.Position (1);
      Z : constant Difference := B.Position (2) - A.Position (2);
      XX : constant Square := X * X;
      YY : constant Square := Y * Y;
      ZZ : constant Square := Z * Z;
      XY : constant Real range 0.0 .. 1.1e21 := XX + YY;
   begin
      return XY + ZZ;
   end Squared_Length;
   function Edge_Length (A, B : Particle) return Real is
     (Ada.Numerics.Long_Elementary_Functions.Sqrt (Squared_Length (A, B)));
   function Inverse_Length (Length : Real) return Reciprocal_Value is (1.0 / Length);
   function Direction_Component (A, B : Tier0_Real; Inv : Reciprocal_Value)
     return Direction_Value is
      Delta_Pos : constant Real range -2.0e10 .. 2.0e10 := B - A;
   begin
      return Delta_Pos * Inv;
   end Direction_Component;
   function Project_Force (D : Direction_Value; S : Scalar_Force) return Force_Value is
     (D * S);
   function Direction (A, B : Particle; Length : Real) return Vector is
   begin
      if Length < Min_Val then return [1.0, 0.0, 0.0]; end if;
      declare
         Inv : constant Reciprocal_Value := Inverse_Length (Length);
      begin
      return [Direction_Component (A.Position (0), B.Position (0), Inv),
              Direction_Component (A.Position (1), B.Position (1), Inv),
              Direction_Component (A.Position (2), B.Position (2), Inv)];
      end;
   end Direction;
   function Project_Velocity (P : Particle; D : Vector) return Real is
      subtype Product is Real range -3.1e35 .. 3.1e35;
      X : constant Product := D (0) * P.Velocity (0);
      Y : constant Product := D (1) * P.Velocity (1);
      Z : constant Product := D (2) * P.Velocity (2);
      XY : constant Real range -6.3e35 .. 6.3e35 := X + Y;
   begin
      if P.Pinned then return 0.0; end if;
      return XY + Z;
   end Project_Velocity;
   function Measure (A, B : Particle) return Geometry is
      L : constant Real := Edge_Length (A, B);
      D : Vector;
   begin
      if L > 1.0e11 then
         return (False, Zero, 0.0, 0.0);
      end if;
      D := Direction (A, B, L);
      return (True, D, L, -Project_Velocity (A, D) + Project_Velocity (B, D));
   end Measure;
   function Force (G : Geometry; Rest, Stiffness, Damping : Nonneg_Tier0)
     return Edge_Force is
      S : constant Real range -2.0e21 .. 2.0e21 := Stiffness * (Rest - G.Length);
      D : constant Real range -4.0e46 .. 4.0e46 := (-Damping) * G.Speed;
   begin
      return (Spring => [Project_Force (G.Direction (0), S), Project_Force (G.Direction (1), S), Project_Force (G.Direction (2), S)],
              Damper => [Project_Force (G.Direction (0), D), Project_Force (G.Direction (1), D), Project_Force (G.Direction (2), D)]);
   end Force;
   function Add_Force (A : Accumulated_Value; B : Force_Value) return Added_Value is (A + B);
   function Add_Vertex (Previous, Contribution : Edge_Force; Negative : Boolean)
     return Edge_Force is
      Result : Edge_Force;
   begin
      for K in Axis loop
         Result.Spring (K) := Add_Force (Previous.Spring (K),
           (if Negative then -Contribution.Spring (K) else Contribution.Spring (K)));
         Result.Damper (K) := Add_Force (Previous.Damper (K),
           (if Negative then -Contribution.Damper (K) else Contribution.Damper (K)));
      end loop;
      return Result;
   end Add_Vertex;
   function Advance_Position (Position, Velocity : Tier0_Real; Dt : Time_Step) return Real is
     (Position + Dt * Velocity);
   procedure Advance_Coordinate (Position, Velocity : in out Tier0_Real;
     Mass : Mass_Value; Spring, Damper : Accumulated_Value;
     Applied, Gravity : Tier0_Real; Dt : Time_Step; Accepted : out Boolean) is
      V : constant Real := Advance_Velocity (Velocity, Mass, Spring, Damper, Applied, Gravity, Dt);
      X : Real;
   begin
      Accepted := False;
      if V not in Tier0_Real then return; end if;
      X := Advance_Position (Position, V, Dt);
      if X not in Tier0_Real then return; end if;
      Position := X;
      Velocity := V;
      Accepted := True;
   end Advance_Coordinate;
end MJ.Elastic_Kernels;

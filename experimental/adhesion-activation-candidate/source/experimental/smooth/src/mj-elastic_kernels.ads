with MJ.Types; use MJ.Types;
with Ada.Numerics.Long_Elementary_Functions;

--  Cartesian particle/edge subset of MuJoCo flex. All formulas specify
--  binary64 evaluation order; sqrt uses the Ada runtime contract boundary.
package MJ.Elastic_Kernels with SPARK_Mode is
   subtype Axis is Integer range 0 .. 2;
   type Vector is array (Axis) of Real;
   type Input_Vector is array (Axis) of Tier0_Real;
   Zero : constant Vector := [others => 0.0];
   subtype Mass_Value is Real range Min_Val .. 1.0e10;
   subtype Time_Step is Real range 0.0 .. 1.0;
   type Particle is record
      Position, Velocity : Input_Vector := [others => 0.0];
      Mass : Mass_Value := 1.0;
      Pinned : Boolean := False;
   end record;
   function Bounded (V : Vector; Limit : Real) return Boolean is
     (V (0) in -Limit .. Limit and then V (1) in -Limit .. Limit
      and then V (2) in -Limit .. Limit)
     with Global => null, Pre => Limit >= 0.0;
   type Geometry is record
      Admissible : Boolean;
      Direction : Vector;
      Length : Real;
      Speed : Real;
   end record;
   function Squared_Length (A, B : Particle) return Real
     with Global => null,
     Post => Squared_Length'Result in 0.0 .. 2.0e21
       and then Squared_Length'Result =
       ((B.Position (0) - A.Position (0)) ** 2
        + (B.Position (1) - A.Position (1)) ** 2)
        + (B.Position (2) - A.Position (2)) ** 2;
   function Edge_Length (A, B : Particle) return Real
     with Global => null,
     Post => Edge_Length'Result >= 0.0 and then
       Edge_Length'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt
         (Squared_Length (A, B));
   subtype Direction_Value is Real range -3.0e25 .. 3.0e25;
   subtype Reciprocal_Value is Real range 0.0 .. 1.1e15;
   function Inverse_Length (Length : Real) return Reciprocal_Value
     with Global => null, Pre => Length in Min_Val .. 1.0e11,
     Post => Inverse_Length'Result = 1.0 / Length;
   function Direction_Component (A, B : Tier0_Real; Inv : Reciprocal_Value)
     return Direction_Value with Global => null,
     Post => Direction_Component'Result = (B - A) * Inv;
   subtype Scalar_Force is Real range -4.0e46 .. 4.0e46;
   subtype Force_Value is Real range -1.0e74 .. 1.0e74;
   function Project_Force (D : Direction_Value; S : Scalar_Force) return Force_Value
     with Global => null, Post => Project_Force'Result = D * S;
   function Direction (A, B : Particle; Length : Real) return Vector
     with Global => null, Pre => Length in 0.0 .. 1.0e11,
     Post => Bounded (Direction'Result, 3.0e25) and then
       (if Length < Min_Val then Direction'Result = [1.0, 0.0, 0.0]
        else (for all K in Axis => Direction'Result (K) =
          Direction_Component (A.Position (K), B.Position (K), Inverse_Length (Length))));
   function Project_Velocity (P : Particle; D : Vector) return Real
     with Global => null, Pre => Bounded (D, 3.0e25),
     Post => Project_Velocity'Result in -1.0e36 .. 1.0e36 and then
       Project_Velocity'Result = (if P.Pinned then 0.0 else
         (D (0) * P.Velocity (0) + D (1) * P.Velocity (1)) + D (2) * P.Velocity (2));
   function Measure (A, B : Particle) return Geometry
     with Global => null,
     Post => Bounded (Measure'Result.Direction, 3.0e25)
       and then Measure'Result.Length in 0.0 .. 1.0e11
       and then Measure'Result.Speed in -3.0e36 .. 3.0e36
       and then Measure'Result.Admissible = (Edge_Length (A, B) <= 1.0e11)
       and then (if Measure'Result.Admissible then
         Measure'Result.Length = Edge_Length (A, B)
         and then Measure'Result.Direction = Direction (A, B, Measure'Result.Length)
         and then Measure'Result.Speed =
           -Project_Velocity (A, Measure'Result.Direction)
           + Project_Velocity (B, Measure'Result.Direction)
         else Measure'Result.Direction = Zero and then Measure'Result.Length = 0.0
           and then Measure'Result.Speed = 0.0);
   type Edge_Force is record
      Spring, Damper : Vector;
   end record;
   function Force (G : Geometry; Rest, Stiffness, Damping : Nonneg_Tier0)
     return Edge_Force
     with Global => null,
     Pre => Bounded (G.Direction, 3.0e25) and then G.Length in 0.0 .. 1.0e11
       and then G.Speed in -3.0e36 .. 3.0e36,
     Post => Bounded (Force'Result.Spring, 1.0e74)
       and then Bounded (Force'Result.Damper, 1.0e74)
       and then (for all K in Axis =>
         Force'Result.Spring (K) = G.Direction (K) * (Stiffness * (Rest - G.Length))
         and then Force'Result.Damper (K) = G.Direction (K) * ((-Damping) * G.Speed));
   subtype Accumulated_Value is Real range -1.0e80 .. 1.0e80;
   subtype Added_Value is Real range -2.0e80 .. 2.0e80;
   function Add_Force (A : Accumulated_Value; B : Force_Value) return Added_Value
     with Global => null, Post => Add_Force'Result = A + B;
   function Add_Vertex (Previous, Contribution : Edge_Force; Negative : Boolean)
     return Edge_Force with Global => null,
     Pre => Bounded (Previous.Spring, 1.0e80) and then Bounded (Previous.Damper, 1.0e80)
       and then Bounded (Contribution.Spring, 1.0e74) and then Bounded (Contribution.Damper, 1.0e74),
     Post => Bounded (Add_Vertex'Result.Spring, 2.0e80)
       and then Bounded (Add_Vertex'Result.Damper, 2.0e80)
       and then (for all K in Axis =>
         Add_Vertex'Result.Spring (K) = Previous.Spring (K)
           + (if Negative then -Contribution.Spring (K) else Contribution.Spring (K))
         and then Add_Vertex'Result.Damper (K) = Previous.Damper (K)
           + (if Negative then -Contribution.Damper (K) else Contribution.Damper (K)));
   --  The expression is the ordered binary64 velocity model and its executable
   --  implementation. Hide only its expansion in callers, not its proof.
   subtype Passive_Value is Real range -3.0e80 .. 3.0e80;
   subtype Weight_Value is Real range -2.0e20 .. 2.0e20;
   subtype Internal_Value is Real range -4.0e80 .. 4.0e80;
   subtype Total_Value is Real range -5.0e80 .. 5.0e80;
   subtype Acceleration_Value is Real range -6.0e95 .. 6.0e95;
   subtype Delta_Value is Real range -7.0e95 .. 7.0e95;
   subtype Updated_Velocity is Real range -1.0e97 .. 1.0e97;
   function Apply_Delta (Velocity : Tier0_Real; Delta_V : Delta_Value) return Updated_Velocity is
     (Velocity + Delta_V)
     with Global => null, Post => Apply_Delta'Result = Velocity + Delta_V;
   function Advance_Velocity (Velocity : Tier0_Real; Mass : Mass_Value;
     Spring, Damper : Real; Applied, Gravity : Tier0_Real; Dt : Time_Step) return Real is
     (declare
        Passive : constant Passive_Value := Spring + Damper;
        Weight : constant Weight_Value := Mass * Gravity;
        Internal : constant Internal_Value := Passive + Weight;
        Total : constant Total_Value := Internal + Applied;
        Acceleration : constant Acceleration_Value := Total / Mass;
        Delta_V : constant Delta_Value := Dt * Acceleration;
      begin Apply_Delta (Velocity, Delta_V))
     with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body"),
     Pre => Spring in -1.0e80 .. 1.0e80 and then Damper in -1.0e80 .. 1.0e80,
     Post => Advance_Velocity'Result in -1.0e97 .. 1.0e97;
   function Advance_Position (Position, Velocity : Tier0_Real; Dt : Time_Step) return Real
     with Global => null, Post => Advance_Position'Result in -3.0e10 .. 3.0e10
       and then Advance_Position'Result = Position + Dt * Velocity;
   procedure Advance_Coordinate (Position, Velocity : in out Tier0_Real;
     Mass : Mass_Value; Spring, Damper : Accumulated_Value;
     Applied, Gravity : Tier0_Real; Dt : Time_Step; Accepted : out Boolean)
     with Global => null,
     Post => (if not Accepted then Position = Position'Old and then Velocity = Velocity'Old
       else Velocity = Advance_Velocity (Velocity'Old, Mass, Spring, Damper, Applied, Gravity, Dt)
         and then Position = Position'Old + Dt * Velocity);
end MJ.Elastic_Kernels;

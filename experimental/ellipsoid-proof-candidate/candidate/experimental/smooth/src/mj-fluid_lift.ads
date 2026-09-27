with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
package MJ.Fluid_Lift with SPARK_Mode is
   subtype Rate is Real range -1.0e12 .. 1.0e12;
   subtype Volume_Value is Real range 0.0 .. 1.0e32;
   subtype Area_Value is Real range 0.0 .. 1.0e98;
   subtype Inverse_Value is Real range 0.0 .. 2.0e15;
   subtype Normal_Value is Real range -1.0e44 .. 1.0e44;
   subtype Cross_Value is Real range -1.0e58 .. 1.0e58;
   subtype Magnus_Value is Real range -1.0e85 .. 1.0e85;
   subtype Circulation_Value is Real range -1.0e195 .. 1.0e195;
   subtype Lift_Value is Real range -1.0e210 .. 1.0e210;
   subtype Magnus_Scale is Real range 0.0 .. 1.0e54;
   subtype Rate_Cross_Value is Real range -1.0e26 .. 1.0e26;
   subtype Circulation_Scale is Real range 0.0 .. 1.0e135;
   function Magnus_Factor (Coefficient,Density : Nonneg_Tier0; Volume : Volume_Value) return Magnus_Scale
     with Global => null, Inline, Post => Magnus_Factor'Result = Coefficient*Density*Volume;
   function Rate_Cross (A1,A2,B1,B2 : Rate) return Rate_Cross_Value
     with Global => null, Inline, Post => Rate_Cross'Result = A1*B2-A2*B1;
   function Circulation_Factor (Coefficient,Density : Nonneg_Tier0; Cos_Alpha : Inverse_Value; Area : Area_Value) return Circulation_Scale
     with Global => null, Inline, Post => Circulation_Factor'Result = Coefficient*Density*Cos_Alpha*Area;
   function Normal_Cross (N1,N2 : Normal_Value; V1,V2 : Rate) return Cross_Value
     with Global => null, Inline, Post => Normal_Cross'Result = N1*V2-N2*V1;
   function Magnus_Component (Coefficient,Density : Nonneg_Tier0; Volume : Volume_Value; W1,W2,V1,V2 : Rate) return Magnus_Value
     with Global => null, Inline, Post => Magnus_Component'Result = Magnus_Factor(Coefficient,Density,Volume)*Rate_Cross(W1,W2,V1,V2);
   function Circulation_Component (Coefficient,Density : Nonneg_Tier0; Cos_Alpha : Inverse_Value; Area : Area_Value; N1,N2 : Normal_Value; V1,V2 : Rate) return Circulation_Value
     with Global => null, Inline, Post => Circulation_Component'Result = Circulation_Factor(Coefficient,Density,Cos_Alpha,Area)*Normal_Cross(N1,N2,V1,V2);
   function Kutta_Component (C1,C2 : Circulation_Value; V1,V2 : Rate) return Lift_Value
     with Global => null, Inline, Post => Kutta_Component'Result = C1*V2-C2*V1;
   function Magnus (Coefficient,Density : Nonneg_Tier0; Volume : Volume_Value; Linear,Angular : Vector) return Vector
     with Global => null, Inline, Pre => Bounded(Linear,1.0e12) and then Bounded(Angular,1.0e12),
     Post => Bounded(Magnus'Result,1.0e85)
       and then Magnus'Result(0) = Magnus_Component(Coefficient,Density,Volume,Angular(1),Angular(2),Linear(1),Linear(2))
       and then Magnus'Result(1) = Magnus_Component(Coefficient,Density,Volume,Angular(2),Angular(0),Linear(2),Linear(0))
       and then Magnus'Result(2) = Magnus_Component(Coefficient,Density,Volume,Angular(0),Angular(1),Linear(0),Linear(1));
   function Circulation (Coefficient,Density : Nonneg_Tier0; Cos_Alpha : Inverse_Value; Area : Area_Value; Normal,Linear : Vector) return Vector
     with Global => null, Inline, Pre => Bounded(Normal,1.0e44) and then Bounded(Linear,1.0e12),
     Post => Bounded(Circulation'Result,1.0e195)
       and then Circulation'Result(0) = Circulation_Component(Coefficient,Density,Cos_Alpha,Area,Normal(1),Normal(2),Linear(1),Linear(2))
       and then Circulation'Result(1) = Circulation_Component(Coefficient,Density,Cos_Alpha,Area,Normal(2),Normal(0),Linear(2),Linear(0))
       and then Circulation'Result(2) = Circulation_Component(Coefficient,Density,Cos_Alpha,Area,Normal(0),Normal(1),Linear(0),Linear(1));
   function Kutta (Circ,Linear : Vector) return Vector
     with Global => null, Inline, Pre => Bounded(Circ,1.0e195) and then Bounded(Linear,1.0e12),
     Post => Bounded(Kutta'Result,1.0e210)
       and then Kutta'Result(0) = Kutta_Component(Circ(1),Circ(2),Linear(1),Linear(2))
       and then Kutta'Result(1) = Kutta_Component(Circ(2),Circ(0),Linear(2),Linear(0))
       and then Kutta'Result(2) = Kutta_Component(Circ(0),Circ(1),Linear(0),Linear(1));
end MJ.Fluid_Lift;

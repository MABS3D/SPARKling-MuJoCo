with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Fluid_Box;
package MJ.Fluid_Added_Mass with SPARK_Mode is
   subtype Momentum_Value is Real range -1.0e34 .. 1.0e34;
   subtype Rate is Real range -1.0e12 .. 1.0e12;
   subtype Cross_Value is Real range -1.0e48 .. 1.0e48;
   subtype Wrench is MJ.Fluid_Box.Wrench;
   function Momentum (Density : Nonneg_Tier0; Virtual : Tier0_Real; V : Rate) return Momentum_Value
     with Global => null, Post => Momentum'Result = Density*Virtual*V;
   function Cross_Term (A1,A2 : Momentum_Value; B1,B2 : Rate) return Cross_Value
     with Global => null, Post => Cross_Term'Result = A1*B2-A2*B1;
   subtype Torque_Value is Real range -1.0e50 .. 1.0e50;
   function Torque_Sum (A,B : Cross_Value) return Torque_Value
     with Global => null, Inline, Post => Torque_Sum'Result = A+B;
   function Evaluate (Density : Nonneg_Tier0; Virtual_Mass, Virtual_Inertia, Linear, Angular : Vector) return Wrench
     with Global => null,
     Pre => Bounded(Virtual_Mass,Max_Val) and then Bounded(Virtual_Inertia,Max_Val)
       and then Bounded(Linear,1.0e12) and then Bounded(Angular,1.0e12),
     Post => Evaluate'Result.Force(0) in -1.0e50 .. 1.0e50;
   pragma Postcondition (Evaluate'Result.Force(1) in -1.0e50 .. 1.0e50);
   pragma Postcondition (Evaluate'Result.Force(2) in -1.0e50 .. 1.0e50);
   pragma Postcondition (Evaluate'Result.Torque(0) in -1.0e50 .. 1.0e50);
   pragma Postcondition (Evaluate'Result.Torque(1) in -1.0e50 .. 1.0e50);
   pragma Postcondition (Evaluate'Result.Torque(2) in -1.0e50 .. 1.0e50);
   pragma Postcondition (Evaluate'Result.Force(0) = Cross_Term(
     Momentum(Density,Virtual_Mass(1),Linear(1)),Momentum(Density,Virtual_Mass(2),Linear(2)),Angular(1),Angular(2)));
   pragma Postcondition (Evaluate'Result.Torque(0) = Cross_Term(
     Momentum(Density,Virtual_Mass(1),Linear(1)),Momentum(Density,Virtual_Mass(2),Linear(2)),Linear(1),Linear(2)) + Cross_Term(
     Momentum(Density,Virtual_Inertia(1),Angular(1)),Momentum(Density,Virtual_Inertia(2),Angular(2)),Angular(1),Angular(2)));
   pragma Postcondition (Evaluate'Result.Force(1) = Cross_Term(
     Momentum(Density,Virtual_Mass(2),Linear(2)),Momentum(Density,Virtual_Mass(0),Linear(0)),Angular(2),Angular(0)));
   pragma Postcondition (Evaluate'Result.Torque(1) = Cross_Term(
     Momentum(Density,Virtual_Mass(2),Linear(2)),Momentum(Density,Virtual_Mass(0),Linear(0)),Linear(2),Linear(0)) + Cross_Term(
     Momentum(Density,Virtual_Inertia(2),Angular(2)),Momentum(Density,Virtual_Inertia(0),Angular(0)),Angular(2),Angular(0)));
   pragma Postcondition (Evaluate'Result.Force(2) = Cross_Term(
     Momentum(Density,Virtual_Mass(0),Linear(0)),Momentum(Density,Virtual_Mass(1),Linear(1)),Angular(0),Angular(1)));
   pragma Postcondition (Evaluate'Result.Torque(2) = Cross_Term(
     Momentum(Density,Virtual_Mass(0),Linear(0)),Momentum(Density,Virtual_Mass(1),Linear(1)),Linear(0),Linear(1)) + Cross_Term(
     Momentum(Density,Virtual_Inertia(0),Angular(0)),Momentum(Density,Virtual_Inertia(1),Angular(1)),Angular(0),Angular(1)));
end MJ.Fluid_Added_Mass;

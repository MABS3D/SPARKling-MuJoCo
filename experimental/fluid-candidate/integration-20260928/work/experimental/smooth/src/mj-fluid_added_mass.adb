package body MJ.Fluid_Added_Mass with SPARK_Mode is
   function Momentum (Density : Nonneg_Tier0; Virtual : Tier0_Real; V : Rate) return Momentum_Value is
   begin
      return Density*Virtual*V;
   end Momentum;
   function Cross_Term (A1,A2 : Momentum_Value; B1,B2 : Rate) return Cross_Value is
   begin
      return A1*B2-A2*B1;
   end Cross_Term;
   function Evaluate (Density : Nonneg_Tier0; Virtual_Mass, Virtual_Inertia, Linear, Angular : Vector) return Wrench is
      type Moments is array (Axis) of Momentum_Value;
      LM : constant Moments := [Momentum(Density,Virtual_Mass(0),Linear(0)),Momentum(Density,Virtual_Mass(1),Linear(1)),Momentum(Density,Virtual_Mass(2),Linear(2))];
      AM : constant Moments := [Momentum(Density,Virtual_Inertia(0),Angular(0)),Momentum(Density,Virtual_Inertia(1),Angular(1)),Momentum(Density,Virtual_Inertia(2),Angular(2))];
   begin
      return (Force => [Cross_Term(LM(1),LM(2),Angular(1),Angular(2)),
                        Cross_Term(LM(2),LM(0),Angular(2),Angular(0)),
                        Cross_Term(LM(0),LM(1),Angular(0),Angular(1))],
              Torque => [Cross_Term(LM(1),LM(2),Linear(1),Linear(2))+Cross_Term(AM(1),AM(2),Angular(1),Angular(2)),
                         Cross_Term(LM(2),LM(0),Linear(2),Linear(0))+Cross_Term(AM(2),AM(0),Angular(2),Angular(0)),
                         Cross_Term(LM(0),LM(1),Linear(0),Linear(1))+Cross_Term(AM(0),AM(1),Angular(0),Angular(1))]);
   end Evaluate;
end MJ.Fluid_Added_Mass;

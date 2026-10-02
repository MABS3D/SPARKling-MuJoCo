package body MJ.Fluid_Lift with SPARK_Mode is
   function Magnus_Factor (Coefficient,Density : Nonneg_Tier0; Volume : Volume_Value) return Magnus_Scale is
   begin
      return Coefficient*Density*Volume;
   end Magnus_Factor;
   function Rate_Cross (A1,A2,B1,B2 : Rate) return Rate_Cross_Value is
   begin
      return A1*B2-A2*B1;
   end Rate_Cross;
   function Circulation_Factor (Coefficient,Density : Nonneg_Tier0; Cos_Alpha : Inverse_Value; Area : Area_Value) return Circulation_Scale is
   begin
      return Coefficient*Density*Cos_Alpha*Area;
   end Circulation_Factor;
   function Normal_Cross (N1,N2 : Normal_Value; V1,V2 : Rate) return Cross_Value is
   begin
      return N1*V2-N2*V1;
   end Normal_Cross;
   function Magnus_Component (Coefficient,Density : Nonneg_Tier0; Volume : Volume_Value; W1,W2,V1,V2 : Rate) return Magnus_Value is
   begin
      return Magnus_Factor(Coefficient,Density,Volume)*Rate_Cross(W1,W2,V1,V2);
   end Magnus_Component;
   function Circulation_Component (Coefficient,Density : Nonneg_Tier0; Cos_Alpha : Inverse_Value; Area : Area_Value; N1,N2 : Normal_Value; V1,V2 : Rate) return Circulation_Value is
   begin
      return Circulation_Factor(Coefficient,Density,Cos_Alpha,Area)*Normal_Cross(N1,N2,V1,V2);
   end Circulation_Component;
   function Kutta_Component (C1,C2 : Circulation_Value; V1,V2 : Rate) return Lift_Value is
   begin
      return C1*V2-C2*V1;
   end Kutta_Component;
   function Magnus (Coefficient,Density : Nonneg_Tier0; Volume : Volume_Value; Linear,Angular : Vector) return Vector is
   begin
      return [Magnus_Component(Coefficient,Density,Volume,Angular(1),Angular(2),Linear(1),Linear(2)),
              Magnus_Component(Coefficient,Density,Volume,Angular(2),Angular(0),Linear(2),Linear(0)),
              Magnus_Component(Coefficient,Density,Volume,Angular(0),Angular(1),Linear(0),Linear(1))];
   end Magnus;
   function Circulation (Coefficient,Density : Nonneg_Tier0; Cos_Alpha : Inverse_Value; Area : Area_Value; Normal,Linear : Vector) return Vector is
   begin
      return [Circulation_Component(Coefficient,Density,Cos_Alpha,Area,Normal(1),Normal(2),Linear(1),Linear(2)),
              Circulation_Component(Coefficient,Density,Cos_Alpha,Area,Normal(2),Normal(0),Linear(2),Linear(0)),
              Circulation_Component(Coefficient,Density,Cos_Alpha,Area,Normal(0),Normal(1),Linear(0),Linear(1))];
   end Circulation;
   function Kutta (Circ,Linear : Vector) return Vector is
   begin
      return [Kutta_Component(Circ(1),Circ(2),Linear(1),Linear(2)),
              Kutta_Component(Circ(2),Circ(0),Linear(2),Linear(0)),
              Kutta_Component(Circ(0),Circ(1),Linear(0),Linear(1))];
   end Kutta;
end MJ.Fluid_Lift;

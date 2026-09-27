package body MJ.Nonlinear_Passive with SPARK_Mode is
   function Polynomial (Linear : Nonneg_Tier0; Quadratic, Cubic : Polynomial_Input;
                        X : Displacement) return Coefficient is
   begin
      return (Linear + Quadratic * X) + Cubic * (X * X);
   end Polynomial;

   function Damping_Derivative
     (Linear : Nonneg_Tier0; Quadratic, Cubic, Velocity : Tier0_Real)
      return Coefficient is
      X : constant Tier0_Real := abs Velocity;
   begin
      return Polynomial (Linear, 2.0 * Quadratic, 3.0 * Cubic, X);
   end Damping_Derivative;

   function Force_Component (X : Displacement; Linear : Nonneg_Tier0;
                             Quadratic, Cubic : Tier0_Real) return Component is
   begin
      return -X * Polynomial (Linear, Quadratic, Cubic, X);
   end Force_Component;

   function Damper_Component (Velocity : Tier0_Real; Linear : Nonneg_Tier0;
                              Quadratic, Cubic : Tier0_Real) return Component is
   begin
      return -Velocity * Polynomial (Linear, Quadratic, Cubic, abs Velocity);
   end Damper_Component;

   function Passive_Force
     (Qpos, Reference, Velocity : Tier0_Real; Stiffness, Damping : Nonneg_Tier0;
      Stiffness_Quadratic, Stiffness_Cubic, Damping_Quadratic, Damping_Cubic : Tier0_Real;
      Spring_Enabled, Damper_Enabled : Boolean) return Force is
      Spring, Damper : Component := 0.0;
   begin
      if Spring_Enabled then
         Spring := Force_Component
           (Qpos - Reference, Stiffness, Stiffness_Quadratic, Stiffness_Cubic);
      end if;
      if Damper_Enabled then
         Damper := Damper_Component
           (Velocity, Damping, Damping_Quadratic, Damping_Cubic);
      end if;
      return Spring + Damper;
   end Passive_Force;
end MJ.Nonlinear_Passive;

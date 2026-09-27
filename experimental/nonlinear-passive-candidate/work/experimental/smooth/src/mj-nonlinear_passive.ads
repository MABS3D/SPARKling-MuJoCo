--  MuJoCo 3.14 scalar joint polynomial laws (mjNPOLY = 2).
--  Preserve C power accumulation and addition order, including the derivative.
with MJ.Types; use MJ.Types;
package MJ.Nonlinear_Passive with SPARK_Mode is
   subtype Displacement is Real range -2.0e10 .. 2.0e10;
   subtype Polynomial_Input is Real range -3.0e10 .. 3.0e10;
   subtype Component is Real range -3.0e42 .. 3.0e42;
   subtype Coefficient is Real range -1.0e32 .. 1.0e32;
   subtype Force is Real range -1.0e43 .. 1.0e43;
   function Polynomial (Linear : Nonneg_Tier0; Quadratic, Cubic : Polynomial_Input;
                        X : Displacement) return Coefficient with
     Global => null,
     Post => Polynomial'Result = (Linear + Quadratic * X) + Cubic * (X * X);
   pragma Inline_Always (Polynomial);
   function Damping_Derivative
     (Linear : Nonneg_Tier0; Quadratic, Cubic, Velocity : Tier0_Real)
      return Coefficient with Global => null,
     Post => Damping_Derivative'Result =
       Polynomial (Linear, 2.0 * Quadratic, 3.0 * Cubic, abs Velocity);
   pragma Inline_Always (Damping_Derivative);
   function Force_Component (X : Displacement; Linear : Nonneg_Tier0;
                             Quadratic, Cubic : Tier0_Real) return Component with
     Global => null,
     Post => Force_Component'Result = -X * Polynomial (Linear, Quadratic, Cubic, X);
   pragma Inline_Always (Force_Component);
   function Damper_Component (Velocity : Tier0_Real; Linear : Nonneg_Tier0;
                              Quadratic, Cubic : Tier0_Real) return Component with
     Global => null,
     Post => Damper_Component'Result =
       -Velocity * Polynomial (Linear, Quadratic, Cubic, abs Velocity);
   pragma Inline_Always (Damper_Component);
   function Passive_Force
     (Qpos, Reference, Velocity : Tier0_Real; Stiffness, Damping : Nonneg_Tier0;
      Stiffness_Quadratic, Stiffness_Cubic, Damping_Quadratic, Damping_Cubic : Tier0_Real;
      Spring_Enabled, Damper_Enabled : Boolean) return Force with Global => null,
     Post => Passive_Force'Result =
       (if Spring_Enabled then Force_Component
          (Qpos - Reference, Stiffness, Stiffness_Quadratic, Stiffness_Cubic) else 0.0)
       + (if Damper_Enabled then Damper_Component
          (Velocity, Damping, Damping_Quadratic, Damping_Cubic) else 0.0);
   pragma Inline_Always (Passive_Force);
end MJ.Nonlinear_Passive;

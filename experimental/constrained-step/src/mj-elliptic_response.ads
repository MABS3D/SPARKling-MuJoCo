with MJ.Types; use MJ.Types;

-- Ordered binary64 regularization from mj_makeImpedance, MuJoCo 3.14.0.
-- These contracts concern the implemented arithmetic, not a real-number
-- cone/convergence theorem. The master-mu sqrt remains the runtime boundary.
package MJ.Elliptic_Response with SPARK_Mode is
   function First_Tangent (Normal_R, Impratio : Real) return Real
     with Global => null,
     Pre => Normal_R in Min_Val .. 1.0e30
       and then Impratio in 1.0e-10 .. 1.0e10,
     Post => (Static => First_Tangent'Result in 1.0e-26 .. 1.0e41
       and then First_Tangent'Result = Normal_R / Real'Max (Min_Val, Impratio));

   function Other_Tangent (First_R, First_Friction, Component_Friction : Real) return Real
     with Global => null,
     Pre => First_R in 1.0e-26 .. 1.0e41
       and then First_Friction in 1.0e-5 .. 1.0e10
       and then Component_Friction in 1.0e-5 .. 1.0e10,
     Post => (Static => Other_Tangent'Result in 1.0e-60 .. 1.0e75
       and then Other_Tangent'Result =
         ((First_R * First_Friction) * First_Friction) /
           (Component_Friction * Component_Friction));
end MJ.Elliptic_Response;

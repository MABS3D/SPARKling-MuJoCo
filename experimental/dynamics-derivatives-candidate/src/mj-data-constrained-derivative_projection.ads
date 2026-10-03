with MJ.Types; use MJ.Types;

-- Read-only projection at an arbitrary acceleration, as mj_inverseConstraint.
-- Uses rows prepared by Evaluate; does not reuse the forward solved forces.
package MJ.Data.Constrained.Derivative_Projection with SPARK_Mode is
   function Actuation (E : Engine) return Real_Array
     with Global => null, Pre => Ready (E);
   procedure Evaluate (E : Engine; Acc : State_Vector; Sparse : Boolean;
                       Force : out Real_Array; Result : out Status)
     with Global => null, Pre => Ready (E);
end MJ.Data.Constrained.Derivative_Projection;

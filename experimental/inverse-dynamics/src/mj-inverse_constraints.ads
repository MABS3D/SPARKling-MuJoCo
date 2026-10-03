with MJ.Types; use MJ.Types;
with MJ.Constraint_Assembly;
with MJ.Constraint_Solvers;

-- Analytical mj_invConstraint: J*qacc-aref, local response, then J' * force.
-- No mass solve, Hessian, line search or forward constraint iteration.
package MJ.Inverse_Constraints with SPARK_Mode is
   procedure Evaluate
     (Jacobian : MJ.Constraint_Assembly.Storage;
      Rows : MJ.Constraint_Solvers.Rows; Aref : MJ.Constraint_Solvers.Vector;
      Qacc : Real_Array; Force, Generalized : in out Real_Array; Accepted : out Boolean;
      Sparse : Boolean := True)
     with Global => null,
       Post => (if not Accepted then Force = Force'Old and Generalized = Generalized'Old);
end MJ.Inverse_Constraints;

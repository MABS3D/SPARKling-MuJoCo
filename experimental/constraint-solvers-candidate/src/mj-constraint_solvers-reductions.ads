with MJ.Constraint_Solvers.Reduction_Models;

--  Ordered four-lane dense reductions for solver workspaces. The wider
--  operand domain includes Cholesky factors of stiff constraint Hessians.
package MJ.Constraint_Solvers.Reductions with SPARK_Mode is
   package Models renames MJ.Constraint_Solvers.Reduction_Models;
   function Same_Bounds (A, B : Vector) return Boolean is
     (A'First = B'First and then A'Last = B'Last) with Global => null;
   function In_Operand (A : Vector) return Boolean is
     (for all X of A => X in Models.Operand) with Global => null;
   function Dot (A, B : Vector) return Models.Dot_Real with
     Global => null,
     Pre => A'First = 1 and then A'Length <= Max_Rows and then Same_Bounds (A, B)
       and then In_Operand (A) and then In_Operand (B),
     Post => (Static => Dot'Result = Models.Dot_Value (A, B)
       and then (if A'Length = 0 then Dot'Result = 0.0)
       and then (if A = B then Dot'Result >= 0.0));
end MJ.Constraint_Solvers.Reductions;

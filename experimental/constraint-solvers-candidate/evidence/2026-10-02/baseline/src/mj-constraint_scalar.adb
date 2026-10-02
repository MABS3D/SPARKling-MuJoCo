package body MJ.Constraint_Scalar with SPARK_Mode is
   function Evaluate
     (Kind : Row_Kind; Jar, R, D, Bound : Real) return Response is
   begin
      if Kind = Unilateral and Jar >= 0.0 then
         return (0.0, 0.0, 0.0, Satisfied);
      elsif Kind = Friction and Jar <= -R * Bound then
         return (Bound, (((-0.5 * R) * Bound) * Bound) - Bound * Jar,
                 0.0, Linear_Negative);
      elsif Kind = Friction and Jar >= R * Bound then
         return (-Bound, (((-0.5 * R) * Bound) * Bound) + Bound * Jar,
                 0.0, Linear_Positive);
      else
         return (-D * Jar, (((0.5 * D) * Jar) * Jar), D, Quadratic);
      end if;
   end Evaluate;

   function Step (Kind : Row_Kind; Old_Force, Residual, Diagonal, Bound : Real)
     return Real is
   begin
      return Project (Kind, Old_Force - Residual / Diagonal, Bound);
   end Step;
end MJ.Constraint_Scalar;

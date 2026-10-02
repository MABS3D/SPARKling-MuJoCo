with MJ.Types; use MJ.Types;

--  Scalar branches of MuJoCo 3.14.0's constraint update and PGS projection.
--  Contracts describe binary64 evaluation, not exact real arithmetic.
package MJ.Constraint_Scalar with SPARK_Mode is
   type Row_Kind is (Equality, Friction, Unilateral);
   type Row_State is (Satisfied, Quadratic, Linear_Negative, Linear_Positive, Cone);
   type Response is record
      Force, Cost, Curvature : Real;
      State : Row_State;
   end record;

   function Cone_Zone (N, T, Mu : Real) return Row_State is
     (if N >= Mu * T then Satisfied
      elsif Mu * N + T <= 0.0 then Quadratic else Cone)
   with Pre => N in -1.0e100 .. 1.0e100 and T in 0.0 .. 1.0e100
       and Mu in 1.0e-5 .. 1.0e5,
     Post => (if N >= Mu * T then Cone_Zone'Result = Satisfied
              elsif Mu * N + T <= 0.0 then Cone_Zone'Result = Quadratic
              else Cone_Zone'Result = Cone);

   function Project (Kind : Row_Kind; Force, Bound : Real) return Real is
     (case Kind is
        when Equality => Force,
        when Friction => Real'Max (-Bound, Real'Min (Bound, Force)),
        when Unilateral => Real'Max (0.0, Force))
   with Pre => Force in -1.0e100 .. 1.0e100 and Bound in 0.0 .. 1.0e30,
     Post => (case Kind is
       when Equality => Project'Result = Force,
       when Friction => Project'Result in -Bound .. Bound,
       when Unilateral => Project'Result >= 0.0);

   function Evaluate
     (Kind : Row_Kind; Jar, R, D, Bound : Real) return Response
   with Pre => Jar in -1.0e30 .. 1.0e30 and R in 1.0e-30 .. 1.0e30
       and D in 1.0e-30 .. 1.0e30 and Bound in 0.0 .. 1.0e30,
     Post =>
       (if Kind = Unilateral and Jar >= 0.0 then
          Evaluate'Result = (0.0, 0.0, 0.0, Satisfied)
        elsif Kind = Friction and Jar <= -R * Bound then
          Evaluate'Result =
            (Bound, (((-0.5 * R) * Bound) * Bound) - Bound * Jar,
             0.0, Linear_Negative)
        elsif Kind = Friction and Jar >= R * Bound then
          Evaluate'Result =
            (-Bound, (((-0.5 * R) * Bound) * Bound) + Bound * Jar,
             0.0, Linear_Positive)
        else Evaluate'Result =
            (-D * Jar, (((0.5 * D) * Jar) * Jar), D, Quadratic));

   function Step (Kind : Row_Kind; Old_Force, Residual, Diagonal, Bound : Real)
     return Real
   with Pre => Old_Force in -1.0e30 .. 1.0e30
       and Residual in -1.0e30 .. 1.0e30
       and Diagonal in 1.0e-30 .. 1.0e30 and Bound in 0.0 .. 1.0e30,
     Post => Step'Result = Project (Kind, Old_Force - Residual / Diagonal, Bound);
end MJ.Constraint_Scalar;

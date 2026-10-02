with MJ.Types; use MJ.Types;
with MJ.Constraint_Scalar;

--  Standalone assembled dense problems. This candidate does not yet replace
--  the engine's constraint assembly or its smooth-step entry points.
package MJ.Constraint_Solvers with SPARK_Mode is
   Max_Dofs : constant := 128;
   Max_Rows : constant := 256;
   type Vector is array (Positive range <>) of Real;
   type Matrix is array (Positive range <>, Positive range <>) of Real;
   type Kind is (Equality, Friction, Unilateral, Elliptic);
   type Friction_Vector is array (Positive range 1 .. 5) of Real;
   type Row is record
      Form : Kind := Unilateral;
      --  Elliptic block: header has Dimension 3, 4 or 6; continuation rows 0.
      Dimension : Natural range 0 .. 6 := 1;
      R : Real := 1.0;
      D : Real := 1.0;
      Bound : Real := 0.0;
      Mu : Real := 1.0;
      Friction : Friction_Vector := (others => 1.0);
   end record;
   type Rows is array (Positive range <>) of Row;
   type Method is (PGS, CG, Newton);
   type Status is (Converged, Iteration_Limit, Line_Search_Limit,
                  Stalled, Invalid_Input, Not_Positive_Definite, Numeric_Limit);
   type Options is record
      Algorithm : Method := Newton;
      Iterations : Natural range 0 .. 100_000 := 100;
      LS_Iterations : Positive range 1 .. 1_000 := 50;
      Tolerance : Real := 1.0e-8;
      LS_Tolerance : Real := 0.01;
      --  MuJoCo monolithic scale = 1 / (meaninertia * max(1, nv)).
      Scale : Real := 1.0;
   end record;
   type Report is record
      Outcome : Status := Invalid_Input;
      Iterations, Evaluations, Restarts : Natural := 0;
      Line_Search_Limits, Curvature_Repairs : Natural := 0;
      Cost, Gradient, Improvement : Real := 0.0;
   end record;

   --  M is the effective SPD metric, J the assembled Jacobian. A_Free and
   --  Aref define residual J*a - Aref. Arrays must start at 1; zero rows are
   --  represented by 1 .. 0. A and Force are warm starts and final iterates.
   --  R and D must be reciprocal; elliptic R must have the MuJoCo ratio.
   --  Input/metric failures leave A and Force unchanged. Iteration_Limit
   --  publishes the last iterate. A line-search budget event is counted; the
   --  outer solve can continue if an improving step was found (as in C).
   --  Line_Search_Limit means no improving step was found before that limit.
   --  Global safety and functional proof of Solve is still OPEN.
   procedure Solve
     (M, J : Matrix; A_Free, Aref : Vector; Constraints : Rows;
      Settings : Options; A, Force : in out Vector; Result : out Report)
   with Post =>
     (if Result.Outcome in Invalid_Input | Not_Positive_Definite | Numeric_Limit
      then A = A'Old and Force = Force'Old);
end MJ.Constraint_Solvers;

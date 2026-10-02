with MJ.Types; use MJ.Types;
with MJ.Friction_Kernels; use MJ.Friction_Kernels;

--  Dense, already assembled regularized dual systems, without elliptic blocks.
--  This candidate does not assemble contacts or replace mj_step.
package MJ.Pyramidal_PGS with SPARK_Mode is
   Max_Rows : constant := 256;
   subtype Iteration_Count is Natural range 0 .. 100_000;
   type Vector is array (Positive range <>) of Real;
   type Matrix is array (Positive range <>, Positive range <>) of Real;
   type Kinds is array (Positive range <>) of Row_Kind;
   type Bounds is array (Positive range <>) of Bound_Value;
   type Status is (Converged, Iteration_Limit, Invalid_Input, Numeric_Limit);
   type Options is record
      Iterations : Iteration_Count := 100;
      Tolerance : Real range 0.0 .. 1.0e20 := 1.0e-8;
      Scale : Real range 1.0e-20 .. 1.0e20 := 1.0;
      Nesterov : Boolean := True;
   end record;
   type Report is record
      Outcome : Status := Invalid_Input;
      Iterations : Iteration_Count := 0;
      Restarts : Iteration_Count := 0;
      Improvement : Real range -1.0e115 .. 1.0e115 := 0.0;
   end record;

   --  AR includes regularization. The caller is responsible for its physical
   --  assembly and positive definiteness; only the positive diagonal is checked.
   --  Numeric/input failures leave Force unchanged. A limit returns the feasible
   --  last iterate. Converged means C's improvement test, not exact equilibrium.
   procedure Solve (AR : Matrix; B : Vector; Kind : Kinds; Loss : Bounds;
                    Settings : Options; Force : in out Vector; Result : out Report)
   with Global => null,
     Post => (Static =>
       (if Result.Outcome in Invalid_Input | Numeric_Limit then Force = Force'Old
        else Force'First = 1 and then Force'Length <= Max_Rows
          and then Kind'First = 1 and then Kind'Length = Force'Length
          and then Loss'First = 1 and then Loss'Length = Force'Length
          and then (for all I in Force'Range => Feasible (Kind (I), Force (I), Loss (I)))));
end MJ.Pyramidal_PGS;

--  Adapted from MuJoCo 3.14.0, Copyright 2021 DeepMind Technologies Limited.
--  SPDX-License-Identifier: Apache-2.0
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers;
package MJ.NoSlip with SPARK_Mode is
   subtype Vector is MJ.Constraint_Solvers.Vector;
   subtype Matrix is MJ.Constraint_Solvers.Matrix;
   use type Vector;
   Max_Rows : constant := MJ.Constraint_Solvers.Max_Rows;
   type Kind is (Equality, Dof_Friction, Tendon_Friction, Joint_Limit,
                 Tendon_Limit, Frictionless, Pyramidal, Elliptic);
   type Friction_Vector is array (Positive range 1 .. 5) of Real;
   type Row is record
      Form : Kind := Frictionless;
      --  Contact header: physical condim 3/4/6; continuation: 0.
      Dimension : Natural range 0 .. 6 := 1;
      R, Bound : Real := 0.0;
      Friction : Friction_Vector := (others => 1.0);
   end record;
   type Rows is array (Positive range <>) of Row;
   type Options is record
      Iterations : Natural range 0 .. 100_000 := 20;
      Tolerance : Real := 1.0e-6;
      Scale : Real := 1.0;
   end record;
   type Status is (Converged, Iteration_Limit, Disabled, Invalid_Input, Numeric_Limit);
   type Report is record
      Outcome : Status := Invalid_Input;
      Iterations, Restored_Blocks : Natural := 0;
      Improvement : Real := 0.0;
   end record;
   --  Post-pass on the REGULARIZED dual AR = J M^-1 J' + diag(R).
   --  B = J*a_smooth - aref. Force must be the primary solver's feasible result.
   --  Equality rows precede dry friction rows, then limits/contacts, as in C.
   --  NoSlip subtracts R in residuals and block diagonals, retains normal loads,
   --  and leaves equalities, limits and frictionless contacts unchanged.
   --  Failed validation/numeric growth publishes no force changes. The global
   --  algorithm/composition proof is pending; see separate kernel evidence.
   procedure Solve (AR : Matrix; B : Vector; Constraints : Rows;
                    Settings : Options; Force : in out Vector; Result : out Report)
     with Global => null,
       Post => (if Result.Outcome in Invalid_Input | Numeric_Limit | Disabled
         then Force = Force'Old);
   pragma Postcondition (Static =>
     (if Result.Outcome in Converged | Iteration_Limit then
       Force'First = 1 and then Force'Length = Constraints'Length
       and then (for all I in Force'Range =>
         Force (I) in -1.0e20 .. 1.0e20
         and then (if Constraints (I).Form in Equality | Joint_Limit | Tendon_Limit | Frictionless
           or else (Constraints (I).Form = Elliptic and then Constraints (I).Dimension > 0)
           then Force (I) = Force'Old (I)))));
end MJ.NoSlip;

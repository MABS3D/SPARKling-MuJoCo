with MJ.Types; use MJ.Types;
with MJ.Constraint_Scalar;

--  Assembled dense problem interface used by experimental constrained-step.
--  Global Solve proof remains separate from the local arithmetic kernels.
package MJ.Constraint_Solvers with SPARK_Mode is
   Max_Dofs : constant := 128;
   Max_Rows : constant := 256;
   type Vector is array (Positive range <>) of Real;
   Empty_Vector : constant Vector (1 .. 0) := (others => 0.0);
   type Matrix is array (Positive range <>, Positive range <>) of Real;
   Max_Jacobian_Entries : constant := 1_048_576;
   subtype Entry_Count is Natural range 0 .. Max_Jacobian_Entries;
   type Entry_Counts is array (Positive range <>) of Entry_Count;
   type Column_Indices is array (Positive range <>) of Positive;
   --  Native CSR storage: offsets are zero based, columns are one based.
   --  Each slot retains its own value. Rows may contain explicit zeros,
   --  repeated columns, and more slots than the number of DOFs. No sorting
   --  or coalescing is implied by this type.
   type Sparse_Jacobian (Row_Count, Stored : Natural) is record
      Offsets, Widths : Entry_Counts (1 .. Row_Count);
      Columns : Column_Indices (1 .. Stored);
      Values : Vector (1 .. Stored);
   end record;
   Empty_Jacobian : constant Sparse_Jacobian (0, 0) :=
     (0, 0, (others => 0), (others => 0), (others => 1), (others => 0.0));
   type Structural_Matrix is array (Positive range <>, Positive range <>) of Boolean;
   Empty_Structure : constant Structural_Matrix (1 .. 0, 1 .. 0) := (others => (others => False));
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
      Sparse : Boolean := False;
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

   function Smooth_Force_Valid (Value : Vector; N : Natural) return Boolean
     with Global => null,
       Post => Smooth_Force_Valid'Result =
         (Value'Length = 0 or else (Value'First = 1 and then Value'Length = N
           and then (for all X of Value => X in -1.0e100 .. 1.0e100)));

   --  A supplied Smooth_Force is the original generalized smooth force used
   --  to obtain A_Free, preserving its rounded value. Empty retains the
   --  historical assembled API which reconstructs M*A_Free. Shape/domain
   --  rejection preserves all published output vectors.
   --  M is the effective SPD metric, J the assembled Jacobian. A_Free and
   --  Aref define residual J*a - Aref. Arrays must start at 1; zero rows are
   --  represented by 1 .. 0. A and Force are warm starts and final iterates.
   --  Warm starts admit the published finite domain +/-1e100. Smooth free
   --  accelerations, matrix and Jacobian entries retain the +/-1e10 domain;
   --  reference acceleration accepts +/-1e30. Numeric rejection is atomic.
   --  R and D must be reciprocal; elliptic R must have the MuJoCo ratio.
   --  Input/metric failures leave A and Force unchanged. Iteration_Limit
   --  publishes the last iterate. A line-search budget event is counted; the
   --  outer solve can continue if an improving step was found (as in C).
   --  Line_Search_Limit means no improving step was found before that limit.
   --  Global safety and functional proof of Solve is still OPEN.
   --  Sparse Newton retains the supplied upper Hessian structure, including
   --  explicit zeros. Empty structure derives support from the numeric M/J.
   --  Ordered_Jacobian preserves native CSR for sparse J*x products. J must
   --  describe the same linear map for the current matrix/dual algorithms;
   --  their native slot-wise traversal is a separate, unfinished port step.
   --  Omitting CSR derives ordered nonzero slots from J for compatibility.
   --  Optional Native_Factor holds the current Ada LDL strict-lower CSR,
   --  with Native_Inverse holding reciprocals of its clamped diagonal.
   --  These must come from the factorization used for this M/A_Free pair;
   --  that provenance is a caller obligation, with its global proof OPEN.
   --  Shape/domain rejection is atomic. Empty preserves the assembled API.
   procedure Solve
     (M, J : Matrix; A_Free, Aref : Vector; Constraints : Rows;
      Settings : Options; A, Force : in out Vector; Result : out Report;
      Hessian_Pattern : Structural_Matrix := Empty_Structure;
      Ordered_Jacobian : Sparse_Jacobian := Empty_Jacobian;
      Smooth_Force : Vector := Empty_Vector;
      Native_Factor : Sparse_Jacobian := Empty_Jacobian;
      Native_Inverse : Vector := Empty_Vector)
   with Post =>
     (if Result.Outcome in Invalid_Input | Not_Positive_Definite | Numeric_Limit
      then A = A'Old and Force = Force'Old);

   --  Also publish the generalized force formed with the selected C method's
   --  order: primal uses the transposed CSR dot, PGS scatters rows. All three
   --  output vectors retain their incoming values on input/numeric failure.
   procedure Solve_With_Force
     (M, J : Matrix; A_Free, Aref : Vector; Constraints : Rows;
      Settings : Options; A, Force, Generalized_Force : in out Vector; Result : out Report;
      Hessian_Pattern : Structural_Matrix := Empty_Structure;
      Ordered_Jacobian : Sparse_Jacobian := Empty_Jacobian;
      Smooth_Force : Vector := Empty_Vector;
      Native_Factor : Sparse_Jacobian := Empty_Jacobian;
      Native_Inverse : Vector := Empty_Vector)
   with Post =>
     (if Result.Outcome in Invalid_Input | Not_Positive_Definite | Numeric_Limit
      then A = A'Old and Force = Force'Old and Generalized_Force = Generalized_Force'Old);
end MJ.Constraint_Solvers;

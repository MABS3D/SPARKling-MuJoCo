package MJ.Constraint_Solvers.Sparse_Kernels with SPARK_Mode is
   function Square (M : Matrix) return Boolean is
     (M'First (1) = 1 and then M'First (2) = 1
      and then M'Length (1) in 1 .. Max_Dofs
      and then M'Length (2) = M'Length (1))
     with Ghost => Static;

   --  Diagonal specialization of the official LDL mass solve. Keep the
   --  reciprocal separate from the multiply, as in qLDiagInv and mj_solveLD.
   function Inverse_Diagonal (Diagonal : Real) return Real
     with Global => null, Inline_Always,
     Pre => Diagonal in 1.0e-15 .. 1.0e10,
     Post => Inverse_Diagonal'Result = 1.0 / Diagonal
       and then Inverse_Diagonal'Result in 1.0e-11 .. 1.0e16;

   function Diagonal_Scale (RHS, Inverse : Real) return Real
     with Global => null, Inline_Always,
     Pre => (Static => RHS in -1.0e100 .. 1.0e100
       and then Inverse in 1.0e-11 .. 1.0e16),
     Post => Diagonal_Scale'Result = RHS * Inverse
       and then Diagonal_Scale'Result in -1.0e117 .. 1.0e117;

   --  The exact scalar-row Hessian update, retaining product/addition order.
   function Outer_Update (Previous, Left, Curvature, Right : Real) return Real
     with Global => null, Inline_Always,
     Pre => (Static => Previous in -1.0e100 .. 1.0e100
       and then Left in -1.0e10 .. 1.0e10
       and then Right in -1.0e10 .. 1.0e10
       and then Curvature in 0.0 .. 1.0e15),
     Post => Outer_Update'Result = Previous + (0.0 + (Left * Curvature) * Right)
       and then Outer_Update'Result in -2.0e100 .. 2.0e100;

   procedure Zero_Contribution (Previous, Left, Curvature, Right : Real)
     with Ghost => Static, Global => null,
     Pre => Previous in -1.0e100 .. 1.0e100
       and then Left in -1.0e10 .. 1.0e10
       and then Right in -1.0e10 .. 1.0e10
       and then Curvature in 0.0 .. 1.0e15
       and then (Left = 0.0 or else Right = 0.0 or else Curvature = 0.0),
     Post => Outer_Update (Previous, Left, Curvature, Right) = Previous;

   procedure Copy_Block (Input : Matrix; First : Positive; Part : out Matrix)
     with Global => null, Inline_Always, Relaxed_Initialization => Part,
     Pre => (Static => Square (Input)
       and then Part'First (1) = 1 and then Part'First (2) = 1
       and then Part'Length (1) in 1 .. Max_Dofs
       and then Part'Length (2) = Part'Length (1)
       and then First <= Input'Length (1)
       and then Part'Length (1) <= (Input'Length (1) - First) + 1),
     Post => (Static => Part'Initialized and then (for all P in Part'Range (1) =>
       (for all Q in Part'Range (2) =>
         Part (P, Q) = Input ((First + P) - 1, (First + Q) - 1))));
end MJ.Constraint_Solvers.Sparse_Kernels;

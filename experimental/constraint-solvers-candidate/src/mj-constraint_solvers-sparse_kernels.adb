package body MJ.Constraint_Solvers.Sparse_Kernels with SPARK_Mode is
   function Inverse_Diagonal (Diagonal : Real) return Real is (1.0 / Diagonal);

   function Diagonal_Scale (RHS, Inverse : Real) return Real is (RHS * Inverse);

   function Outer_Update (Previous, Left, Curvature, Right : Real) return Real is
     (Previous + (0.0 + (Left * Curvature) * Right));

   procedure Zero_Contribution (Previous, Left, Curvature, Right : Real) is
   begin
      null;
   end Zero_Contribution;

   procedure Copy_Block (Input : Matrix; First : Positive; Part : out Matrix) is
   begin
      for P in Part'Range (1) loop
         for Q in Part'Range (2) loop
            Part (P, Q) := Input ((First + P) - 1, (First + Q) - 1);
            pragma Loop_Invariant (Static => (for all C in 1 .. Q =>
              Part (P, C)'Initialized and then
              Part (P, C) = Input ((First + P) - 1, (First + C) - 1)));
         end loop;
         pragma Loop_Invariant (Static => (for all R in 1 .. P =>
           (for all C in Part'Range (2) =>
             Part (R, C)'Initialized and then
             Part (R, C) = Input ((First + R) - 1, (First + C) - 1))));
      end loop;
   end Copy_Block;
end MJ.Constraint_Solvers.Sparse_Kernels;

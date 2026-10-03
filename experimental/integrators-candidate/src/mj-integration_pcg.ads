with MJ.Types; use MJ.Types;
package MJ.Integration_PCG with SPARK_Mode is
   -- Dense representation of C's effective-metric PCG. Backbone is M plus
   -- diagonal metric terms and symmetric fluid blocks, including rank-one
   -- coupling diagonals. Matrix also contains the off-diagonal couplings.
   procedure Solve
     (Matrix, Backbone, Right : Real_Array; N, Iterations : Natural;
      Tolerance : Nonneg_Tier0; X : out Real_Array;
      Ok, Converged : out Boolean)
     with Global => null,
       Pre => N <= 1024 and then Matrix'First = 0 and then Matrix'Length = N*N
         and then Backbone'First = 0 and then Backbone'Length = N*N
         and then Right'First = 0 and then Right'Length = N
         and then X'First = 0 and then X'Length = N;
private
   function Dot (A, B : Real_Array) return Real
     with Global => null,
       Pre => A'First = 0 and then B'First = 0 and then A'Length = B'Length;
end MJ.Integration_PCG;

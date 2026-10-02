with Ada.Text_IO;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Cholesky; use MJ.Constraint_Solvers.Cholesky;

procedure Cholesky_Edges is
   Checks : Natural := 0;
   procedure Check (Condition : Boolean) is
   begin
      if not Condition then raise Program_Error with "Cholesky edge check failed"; end if;
      Checks := Checks + 1;
   end Check;
begin
   declare
      M : constant Matrix := ((4.0, 12.0, -16.0),
                              (12.0, 37.0, -43.0),
                              (-16.0, -43.0, 98.0));
      L : Matrix (1 .. 3, 1 .. 3);
      X : Vector (1 .. 3);
      R : Cholesky.Status;
   begin
      Factor (M, L, R);
      Check (R = Success);
      Check (L = Matrix'((2.0, 0.0, 0.0), (6.0, 1.0, 0.0), (-8.0, 5.0, 3.0)));
      Backsolve (L, Vector'(-20.0, -43.0, 192.0), X, R);
      Check (R = Success);
      Check (X = Vector'(1.0, 2.0, 3.0));
      Backsolve (L, Vector'(0.0, 0.0, 0.0), X, R);
      Check (R = Success and then X = Vector'(0.0, 0.0, 0.0));
   end;
   declare
      M, L : Matrix (1 .. 1, 1 .. 1);
      X : Vector (1 .. 1);
      R : Cholesky.Status;
   begin
      M (1, 1) := 4.0;
      Factor (M, L, R, Floor => 4.0);
      Check (R = Success and then L (1, 1) = 2.0);
      M (1, 1) := 3.0;
      Factor (M, L, R, Floor => 4.0);
      Check (R = Cholesky.Not_Positive_Definite and then L (1, 1) = 0.0);
      M (1, 1) := 1.0e101;
      Factor (M, L, R);
      Check (R = Cholesky.Numeric_Limit and then L (1, 1) = 0.0);
      L (1, 1) := 1.0;
      Backsolve (L, Vector'(1 => 1.0e101), X, R);
      Check (R = Cholesky.Numeric_Limit and then X (1) = 0.0);
      --  A valid forward quotient can exceed the accumulator domain. The
      --  backward phase must reject it before starting its ordered reduction.
      L (1, 1) := 1.0e-15;
      Backsolve (L, Vector'(1 => 1.0e100), X, R);
      Check (R = Cholesky.Numeric_Limit and then X (1) > 1.0e100);
   end;
   declare
      M : Matrix := ((4.0, 3.0), (3.0, 1.0));
      L : Matrix (1 .. 2, 1 .. 2);
      X : Vector (1 .. 2);
      R : Cholesky.Status;
   begin
      Factor (M, L, R);
      Check (R = Cholesky.Not_Positive_Definite);
      Check (L = Matrix'((2.0, 0.0), (1.5, 0.0)));
      M := ((1.0e-14, 1.0e100), (1.0e100, 1.0e100));
      Factor (M, L, R);
      Check (R = Cholesky.Numeric_Limit);
      Check (L (1, 2) = 0.0 and then L (2, 2) = 0.0);
      L := ((1.0, 0.0), (1.0e100, 1.0));
      Backsolve (L, Vector'(1.0e100, 1.0e100), X, R);
      Check (R = Cholesky.Numeric_Limit and then X = Vector'(1.0e100, 0.0));
      Backsolve (L, Vector'(0.0, 1.0e100), X, R);
      Check (R = Cholesky.Numeric_Limit and then X = Vector'(0.0, 1.0e100));
   end;
   declare
      M : Matrix (1 .. Max_Dofs, 1 .. Max_Dofs) := (others => (others => 0.0));
      L : Matrix (M'Range (1), M'Range (2));
      B, X : Vector (1 .. Max_Dofs);
      R : Cholesky.Status;
   begin
      for I in B'Range loop M (I, I) := 1.0; B (I) := Long_Float (I); end loop;
      Factor (M, L, R);
      Check (R = Success and then L = M);
      Backsolve (L, B, X, R);
      Check (R = Success and then X = B);
   end;
   Ada.Text_IO.Put_Line (Natural'Image (Checks) & " Cholesky edge checks passed");
end Cholesky_Edges;

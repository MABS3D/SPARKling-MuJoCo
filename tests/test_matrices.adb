with Check; use Check;
with MJ.Types; use MJ.Types;
with MJ.BLAS;
with MJ.Matrix_Types; use MJ.Matrix_Types;
with MJ.Matrices; use MJ.Matrices;
procedure Test_Matrices is
   A : constant Matrix_3 := [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 10.0]];
   Id, T, R : Matrix_3;
   V : constant MJ.BLAS.Vector_3 := [1.0, -2.0, 3.0];
   W : MJ.BLAS.Vector_3;
begin
   Eye (Id);
   Assert (Id = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]], "identity");
   Assert (Copy9 (A) = A, "copy9");
   MulMatVec3 (W, A, V);
   Assert (W = [6.0, 12.0, 21.0], "fixed mat vec");
   MulMatTVec3 (W, A, V);
   Assert (W = [14.0, 16.0, 21.0], "fixed transpose mat vec");
   Assert (MulMatMat3 (A, Id) = A and then MulMatMat3 (Id, A) = A, "fixed identity product");
   Transpose (T, A);
   Assert (T = [[1.0, 4.0, 7.0], [2.0, 5.0, 8.0], [3.0, 6.0, 10.0]], "transpose orientation");
   Assert (MulMatTMat3 (A, Id) = T, "fixed first transpose product");
   Assert (MulMatMatT3 (Id, A) = T, "fixed second transpose product");
   MulMatVec (W, A, V); Assert (W = [6.0, 12.0, 21.0], "generic mat vec");
   MulMatTVec (W, A, V); Assert (W = [14.0, 16.0, 21.0], "generic transpose mat vec");
   Assert (MulVecMatVec (V, A, V) = 45.0, "bilinear form");
   Symmetrize (R, A);
   Assert (R = [[1.0, 3.0, 5.0], [3.0, 5.0, 7.0], [5.0, 7.0, 10.0]], "symmetrize and preserve diagonal");
   MulMatMat (R, A, Id); Assert (R = A, "generic identity product");
   MulMatTMat (R, A, Id); Assert (R = T, "generic first transpose product");
   MulMatMatT (R, Id, A); Assert (R = T, "generic second transpose product");
   declare
      P : constant Matrix (0 .. 1, 0 .. 2) := [[1.0, 2.0, 3.0], [-1.0, 0.0, 2.0]];
      B : constant Matrix (0 .. 2, 0 .. 1) := [[2.0, -1.0], [0.0, 3.0], [4.0, 2.0]];
      C : Matrix (0 .. 1, 0 .. 1);
      PT : Matrix (0 .. 2, 0 .. 1);
      Q : Matrix (0 .. 1, 0 .. 2) := [others => [others => 1.0e300]];
   begin
      MulMatMat (C, P, B); Assert (C = [[14.0, 11.0], [6.0, 5.0]], "rectangular product");
      Transpose (PT, P);
      Assert (PT = [[1.0, -1.0], [2.0, 0.0], [3.0, 2.0]], "rectangular transpose");
      CopyRows (Q, P, Int_Array'(7 => 1, 8 => 1));
      Assert (Q = [[1.0e300, 1.0e300, 1.0e300], [-1.0, 0.0, 2.0]], "copy rows is scatter; repeated shifted indices");
      CopyRows (Q, P, Int_Array'(Natural'Last => 0));
      Assert (Q = P, "index array ending at Natural Last");
      Q := [others => [others => -7.0]];
      CopyRows (Q, P, Int_Array'(0 .. -2 => 0));
      Assert ((for all I in Q'Range (1) => (for all J in Q'Range (2) => Q (I,J) = -7.0)), "empty selection preserves all data");
      SqrMatTD (R, P);
      Assert (R = [[2.0, 2.0, 1.0], [2.0, 4.0, 6.0], [1.0, 6.0, 13.0]], "unweighted Gram");
      SqrMatTD (R, P, Upper => False);
      Assert (R = [[2.0, 0.0, 0.0], [2.0, 4.0, 0.0], [1.0, 6.0, 13.0]], "lower Gram clears upper triangle");
      SqrMatTD (R, P, [2.0, -1.0]);
      Assert (R = [[1.0, 4.0, 8.0], [4.0, 8.0, 12.0], [8.0, 12.0, 14.0]], "weighted Gram supports negative weights");
      SqrMatTD (R, P, [0.0, -1.0], Upper => False);
      Assert (R = [[-1.0, 0.0, 0.0], [0.0, 0.0, 0.0], [2.0, 0.0, -4.0]], "zero weight and lower-only Gram");
   end;
   declare
      P : constant Matrix (0 .. 0, 0 .. 3) := [[1.0e10, 1.0, -1.0e10, 1.0]];
      B : constant Matrix (0 .. 3, 0 .. 0) := [[1.0e10], [1.0], [1.0e10], [1.0]];
      BT : Matrix (0 .. 0, 0 .. 3);
      C : Matrix (0 .. 0, 0 .. 0);
      VV : constant Real_Array := [1.0e10, 1.0, 1.0e10, 1.0];
      RV : Real_Array (0 .. 0);
   begin
      MulMatVec (RV, P, VV); Assert (RV (0) = 2.0, "four-lane row dot order");
      MulMatMat (C, P, B); Assert (C (0,0) = 1.0, "sequential mat mat order");
      Transpose (BT, B);
      MulMatMatT (C, P, BT); Assert (C (0,0) = 2.0, "mat mat transpose uses four lanes");
   end;
   declare
      P : constant Matrix (0 .. 1, 0 .. 1) := [others => [others => 1.0e10]];
      C : Matrix (0 .. 1, 0 .. 1);
   begin
      Assert (MulVecMatVec ([1.0e10, 1.0e10], P, [1.0e10, 1.0e10]) > Tier1_Real'Last,
              "bilinear output can exceed Tier1");
      SqrMatTD (C, P, [1.0e10, 1.0e10]);
      Assert (C (0,0) > Tier1_Real'Last and then C (0,1) = C (1,0), "weighted output Tier2 and symmetry");
   end;
   declare
      Z, Z_Copy : Matrix (0 .. -1, 0 .. -1);
      Empty : Real_Array (0 .. -1);
      P : Matrix (0 .. 1, 0 .. -1);
      Q : Matrix (0 .. -1, 0 .. 2);
      C : Matrix (0 .. 1, 0 .. 2);
      V0 : Real_Array (0 .. 1);
      G : Matrix (0 .. 2, 0 .. 2);
   begin
      Eye (Z); Transpose (Z_Copy, Z); Symmetrize (Z, Z_Copy);
      Assert (MulVecMatVec (Empty, Z, Empty) = 0.0, "zero dimensional bilinear form");
      MulMatVec (V0, P, Empty); Assert (V0 = [0.0, 0.0], "zero columns yield zero vector");
      MulMatMat (C, P, Q);
      Assert ((for all I in C'Range (1) => (for all J in C'Range (2) => C(I,J)=0.0)), "zero inner dimension product");
      SqrMatTD (G, Q);
      Assert ((for all I in G'Range (1) => (for all J in G'Range (2) => G(I,J)=0.0)), "zero rows Gram");
   end;
   Report_And_Exit;
end Test_Matrices;

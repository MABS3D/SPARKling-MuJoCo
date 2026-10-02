--  Constraint formulas and iteration structure adapted from MuJoCo 3.14.0.
--  Copyright 2021 DeepMind Technologies Hit_Limit. SPDX-License-Identifier: Apache-2.0
with Ada.Numerics.Long_Elementary_Functions;
with Interfaces;
with MJ.Constraint_Order;
package body MJ.Constraint_Solvers with SPARK_Mode is
   package Math renames Ada.Numerics.Long_Elementary_Functions;
   package Scalar renames MJ.Constraint_Scalar;
   use type Scalar.Row_State;
   Tiny : constant Real := 1.0e-15;
   subtype Work is Real range -1.0e100 .. 1.0e100;
   type State is (Satisfied, Quadratic, Linear_Negative, Linear_Positive, Cone);
   subtype Small_Vector is Vector (1 .. 6);
   subtype Small_Matrix is Matrix (1 .. 6, 1 .. 6);
   type Block_Value is record
      F : Small_Vector := (others => 0.0);
      H : Small_Matrix := (others => (others => 0.0));
      Cost : Work := 0.0;
      Zone : State := Satisfied;
   end record;

   function Dot (X, Y : Vector) return Real is
      S : Work := 0.0;
   begin
      for I in X'Range loop S := S + X (I) * Y (I); end loop;
      return S;
   end Dot;

   function Norm (X : Vector) return Real is (Math.Sqrt (Dot (X, X)));

   procedure Multiply (M : Matrix; X : Vector; Y : out Vector) is
      S : Work;
   begin
      for I in Y'Range loop
         S := 0.0;
         for K in X'Range loop S := S + M (I, K) * X (K); end loop;
         Y (I) := S;
      end loop;
   end Multiply;

   procedure Factor (M : Matrix; L : out Matrix; OK : out Boolean; Floor : Real := Tiny) is
      S : Work;
   begin
      L := (others => (others => 0.0));
      OK := False;
      for I in M'Range (1) loop
         for K in 1 .. I loop
            S := M (I, K);
            for T in 1 .. K - 1 loop S := S - L (I, T) * L (K, T); end loop;
            if I = K then
               if S < Floor then return; end if;
               L (I, K) := Math.Sqrt (S);
            else L (I, K) := S / L (K, K);
            end if;
         end loop;
      end loop;
      OK := True;
   end Factor;

   procedure Backsolve (L : Matrix; B : Vector; X : out Vector) is
      S : Work;
   begin
      X := (others => 0.0);
      for I in B'Range loop
         S := B (I);
         for K in 1 .. I - 1 loop S := S - L (I, K) * X (K); end loop;
         X (I) := S / L (I, I);
      end loop;
      for I in reverse B'Range loop
         S := X (I);
         for K in I + 1 .. B'Last loop S := S - L (K, I) * X (K); end loop;
         X (I) := S / L (I, I);
      end loop;
   end Backsolve;

   function Scalar_Kind (K : Kind) return Scalar.Row_Kind is
     (case K is when Equality => Scalar.Equality, when Friction => Scalar.Friction,
       when others => Scalar.Unilateral);

   function Project_Row (K : Kind; Value, Bound : Real) return Real is
   begin
      if Value not in -1.0e100 .. 1.0e100 then raise Constraint_Error; end if;
      return Scalar.Project (Scalar_Kind (K), Value, Bound);
   end Project_Row;

   procedure Evaluate_Block
     (C : Rows; Start : Positive; X : Vector; Build_H : Boolean; B : out Block_Value) is
      R : constant Row := C (Start);
      S : Scalar.Response;
      U, Scaling : Small_Vector := (others => 0.0);
      N, T, Dm, Q, V : Work;
   begin
      B := (others => <>);
      if R.Form /= Elliptic then
         if X (Start) not in -1.0e30 .. 1.0e30 then raise Constraint_Error; end if;
         S := Scalar.Evaluate (Scalar_Kind (R.Form), X (Start), R.R, R.D, R.Bound);
         B.F (1) := S.Force; B.Cost := S.Cost; B.H (1, 1) := S.Curvature;
         B.Zone := State'Val (Scalar.Row_State'Pos (S.State));
         return;
      end if;
      Scaling (1) := R.Mu;
      U (1) := X (Start) * R.Mu;
      for K in 2 .. R.Dimension loop
         Scaling (K) := R.Friction (K - 1);
         U (K) := X (Start + K - 1) * Scaling (K);
      end loop;
      N := U (1); T := Norm (U (2 .. R.Dimension));
      if N >= R.Mu * T or else (T <= 0.0 and N >= 0.0) then
         return;
      elsif R.Mu * N + T <= 0.0 or else (T <= 0.0 and N < 0.0) then
         B.Zone := Quadratic;
         for K in 1 .. R.Dimension loop
            V := X (Start + K - 1);
            B.F (K) := -C (Start + K - 1).D * V;
            B.Cost := B.Cost + 0.5 * C (Start + K - 1).D * V * V;
            if Build_H then B.H (K, K) := C (Start + K - 1).D; end if;
         end loop;
      else
         B.Zone := Cone;
         Dm := R.D / (R.Mu * R.Mu * (1.0 + R.Mu * R.Mu));
         Q := N - R.Mu * T;
         B.Cost := 0.5 * Dm * Q * Q;
         B.F (1) := -Dm * Q * R.Mu;
         for K in 2 .. R.Dimension loop
            B.F (K) := -B.F (1) / T * U (K) * Scaling (K);
         end loop;
         if Build_H then
            B.H (1, 1) := 1.0;
            for K in 2 .. R.Dimension loop B.H (1, K) := -R.Mu / T * U (K); end loop;
            for K in 2 .. R.Dimension loop
               for Tj in K .. R.Dimension loop
                  B.H (K, Tj) := R.Mu * N / (T * T * T) * U (Tj) * U (K);
               end loop;
               B.H (K, K) := B.H (K, K) + R.Mu * R.Mu - R.Mu * N / T;
            end loop;
            for K in 1 .. R.Dimension loop
               for Tj in K .. R.Dimension loop
                  B.H (K, Tj) := B.H (K, Tj) * (Dm * Scaling (K)) * Scaling (Tj);
                  B.H (Tj, K) := B.H (K, Tj);
               end loop;
            end loop;
         end if;
      end if;
   end Evaluate_Block;

   --  Tangential QCQP: explicit 2/3 inverses and generic Cholesky, as in C.
   procedure QCQP
     (A : Matrix; B, D : Vector; Radius : Real; X : out Vector) is
      N : constant Natural := B'Length;
      Scaled, Shifted, L, P : Matrix (1 .. N, 1 .. N);
      Scaled_B, V, Tmp : Vector (1 .. N);
      Lambda, Val, Deriv, Delta_L, Det, Detinv : Work := 0.0;
      OK : Boolean;
   begin
      for I in 1 .. N loop
         Scaled_B (I) := -B (I) * D (I);
         for K in 1 .. N loop Scaled (I, K) := A (I, K) * D (I) * D (K); end loop;
      end loop;
      for Iter in 1 .. 20 loop
         Shifted := Scaled;
         for I in 1 .. N loop Shifted (I, I) := Shifted (I, I) + Lambda; end loop;
         if N = 2 or N = 3 then
            if N = 2 then
               Det := Shifted (1, 1) * Shifted (2, 2) - Shifted (1, 2)**2;
               P (1, 1) := Shifted (2, 2); P (2, 2) := Shifted (1, 1);
               P (1, 2) := -Shifted (1, 2); P (2, 1) := P (1, 2);
            else
               P (1, 1) := Shifted (2, 2) * Shifted (3, 3) - Shifted (2, 3)**2;
               P (2, 2) := Shifted (1, 1) * Shifted (3, 3) - Shifted (1, 3)**2;
               P (3, 3) := Shifted (1, 1) * Shifted (2, 2) - Shifted (1, 2)**2;
               P (1, 2) := Shifted (1, 3) * Shifted (2, 3) - Shifted (1, 2) * Shifted (3, 3);
               P (1, 3) := Shifted (1, 2) * Shifted (2, 3) - Shifted (1, 3) * Shifted (2, 2);
               P (2, 3) := Shifted (1, 2) * Shifted (1, 3) - Shifted (2, 3) * Shifted (1, 1);
               P (2, 1) := P (1, 2); P (3, 1) := P (1, 3); P (3, 2) := P (2, 3);
               Det := Shifted (1, 1) * P (1, 1) + Shifted (1, 2) * P (1, 2) + Shifted (1, 3) * P (1, 3);
            end if;
            if Det < 1.0e-10 then X := (others => 0.0); return; end if;
            Detinv := 1.0 / Det;
            for I in 1 .. N loop for J in 1 .. N loop P (I, J) := P (I, J) * Detinv; end loop; end loop;
            Multiply (P, Scaled_B, V);
         else
            Factor (Shifted, L, OK, 1.0e-10);
            if not OK then X := (others => 0.0); return; end if;
            Backsolve (L, Scaled_B, V);
         end if;
         Val := Dot (V, V) - Radius * Radius;
         exit when Val < 1.0e-10;
         if N = 2 then
            Deriv := -2.0 * (P (1, 1) * V (1) * V (1) + 2.0 * P (1, 2) * V (1) * V (2) + P (2, 2) * V (2) * V (2));
         elsif N = 3 then
            Deriv := -2.0 * (P (1, 1) * V (1) * V (1) + P (2, 2) * V (2) * V (2) + P (3, 3) * V (3) * V (3))
              - 4.0 * (P (1, 2) * V (1) * V (2) + P (1, 3) * V (1) * V (3) + P (2, 3) * V (2) * V (3));
         else
            Backsolve (L, V, Tmp);
            Deriv := -2.0 * Dot (V, Tmp);
         end if;
         if Deriv >= 0.0 then raise Constraint_Error; end if;
         Delta_L := -Val / Deriv;
         exit when Delta_L < 1.0e-10;
         Lambda := Lambda + Delta_L;
      end loop;
      --  C's solveQCQP helper restores exact feasibility on an active boundary.
      Val := Norm (V);
      if Lambda /= 0.0 and Val > Tiny then
         for I in V'Range loop V (I) := V (I) * (Radius / Val); end loop;
      end if;
      for I in X'Range loop X (I) := V (I) * D (I); end loop;
   end QCQP;

   procedure Solve
     (M, J : Matrix; A_Free, Aref : Vector; Constraints : Rows;
      Settings : Options; A, Force : in out Vector; Result : out Report) is
      N : constant Natural := A_Free'Length;
      K : constant Natural := Aref'Length;
      function Finite (X : Real) return Boolean is (X in -1.0e10 .. 1.0e10);
      I : Natural := 1;
   begin
      Result := (others => <>);
      if N not in 1 .. Max_Dofs or K > Max_Rows
        or M'First (1) /= 1 or M'First (2) /= 1
        or M'Length (1) /= N or M'Length (2) /= N
        or J'First (1) /= 1 or J'First (2) /= 1
        or J'Length (1) /= K or J'Length (2) /= N
        or A_Free'First /= 1 or Aref'First /= 1
        or A'First /= 1 or A'Length /= N or Force'First /= 1 or Force'Length /= K
        or Constraints'First /= 1 or Constraints'Length /= K
        or Settings.Tolerance not in 0.0 .. 1.0
        or Settings.LS_Tolerance not in 1.0e-12 .. 1.0
        or Settings.Scale not in 1.0e-12 .. 1.0e12 then return;
      end if;
      for P in 1 .. N loop
         if not Finite (A_Free (P)) or not Finite (A (P)) then return; end if;
         for Q in 1 .. N loop
            if not Finite (M (P, Q)) or M (P, Q) /= M (Q, P) then return; end if;
         end loop;
      end loop;
      for P in 1 .. K loop
         if not Finite (Aref (P)) or not Finite (Force (P))
           or Constraints (P).R not in 1.0e-12 .. 1.0e12
           or Constraints (P).D not in 1.0e-12 .. 1.0e12
           or abs (Constraints (P).R * Constraints (P).D - 1.0) > 1.0e-12
           or Constraints (P).Bound not in 0.0 .. 1.0e10 then return; end if;
         for Q in 1 .. N loop if not Finite (J (P, Q)) then return; end if; end loop;
      end loop;
      while I <= K loop
         if Constraints (I).Form = Elliptic then
            if Constraints (I).Dimension not in 3 | 4 | 6
              or Constraints (I).Dimension > K - I + 1
              or Constraints (I).Mu not in 1.0e-5 .. 1.0e5 then return; end if;
            for T in 1 .. Constraints (I).Dimension - 1 loop
               if Constraints (I + T).Form /= Elliptic
                 or Constraints (I + T).Dimension /= 0
                 or Constraints (I).Friction (T) not in 1.0e-5 .. 1.0e5
                 or abs (Constraints (I + T).R * Constraints (I).Friction (T)**2 /
                   (Constraints (I).R * Constraints (I).Mu**2) - 1.0) > 1.0e-10
               then return; end if;
            end loop;
         elsif Constraints (I).Dimension /= 1 then return;
         end if;
         I := I + Constraints (I).Dimension;
      end loop;
      declare
         L, HL : Matrix (1 .. N, 1 .. N);
         H : Matrix (1 .. N, 1 .. N) := M;
         Acc : Vector (1 .. N) := A;
         F : Vector (1 .. K) := Force;
         Jar, Jv : Vector (1 .. K);
         Grad, Mgrad, Oldgrad, Oldmg, Search, Ma, Smooth, Mv : Vector (1 .. N);
         Cost : Work := 0.0;
         OK : Boolean;
         type Block_List is array (Positive range <>) of Positive;
         Blocks : Block_List (1 .. K);
         Count : Natural := 0;

         procedure Residual is
         begin
            Multiply (M, Acc, Ma);
            Multiply (J, Acc, Jar);
            for R in Jar'Range loop Jar (R) := Jar (R) - Aref (R); end loop;
         end Residual;

         procedure Update (Build_H : Boolean) is
            B : Block_Value;
            R, Dim : Natural;
            V : Work;
         begin
            Cost := 0.0;
            Grad := Ma;
            for P in 1 .. N loop
               Grad (P) := Grad (P) - Smooth (P);
               Cost := Cost + 0.5 * Grad (P) * (Acc (P) - A_Free (P));
            end loop;
            if Build_H then H := M; end if;
            for Bi in 1 .. Count loop
               R := Blocks (Bi); Dim := Constraints (R).Dimension;
               Evaluate_Block (Constraints, R, Jar, Build_H, B);
               Cost := Cost + B.Cost;
               for T in 1 .. Dim loop F (R + T - 1) := B.F (T); end loop;
               for P in 1 .. N loop
                  for T in 1 .. Dim loop
                     Grad (P) := Grad (P) - J (R + T - 1, P) * B.F (T);
                  end loop;
                  if Build_H then
                     for Q in 1 .. N loop
                        V := 0.0;
                        for S in 1 .. Dim loop
                           for T in 1 .. Dim loop
                              V := V + J (R + S - 1, P) * B.H (S, T) * J (R + T - 1, Q);
                           end loop;
                        end loop;
                        H (P, Q) := H (P, Q) + V;
                     end loop;
                  end if;
               end loop;
            end loop;
            if Build_H then
               Factor (H, HL, OK);
               if not OK then raise Constraint_Error; end if;
            end if;
         end Update;

         procedure Precondition is
         begin
            if Settings.Algorithm = Newton then Backsolve (HL, Grad, Mgrad);
            else Backsolve (L, Grad, Mgrad); end if;
         end Precondition;

         procedure Project_Forces is
            R, Dim : Natural;
            V, S : Work;
         begin
            for Bi in 1 .. Count loop
               R := Blocks (Bi); Dim := Constraints (R).Dimension;
               if Constraints (R).Form /= Elliptic then
                  F (R) := Project_Row (Constraints (R).Form, F (R), Constraints (R).Bound);
               elsif F (R) < 0.0 then
                  for T in R .. R + Dim - 1 loop F (T) := 0.0; end loop;
               else
                  V := 0.0;
                  for T in 1 .. Dim - 1 loop V := V + (F (R + T) / Constraints (R).Friction (T))**2; end loop;
                  if V > F (R)**2 then
                     S := Math.Sqrt (F (R)**2 / Real'Max (Tiny, V));
                     for T in 1 .. Dim - 1 loop F (R + T) := F (R + T) * S; end loop;
                  end if;
               end if;
            end loop;
         end Project_Forces;

         procedure Run_PGS is
            use type Interfaces.Unsigned_32;
            AR : Matrix (1 .. K, 1 .. K);
            Inv_J : Matrix (1 .. N, 1 .. K);
            B, Previous, Momentum : Vector (1 .. K);
            Col, Sol : Vector (1 .. N);
            Old, Res, Change : Small_Vector := (others => 0.0);
            Ac : Matrix (1 .. 5, 1 .. 5);
            Bc, Dc, Xc : Vector (1 .. 5);
            Seed : Interfaces.Unsigned_64 := 0;
            Random : Interfaces.Unsigned_32;
            Nk : Natural := 0;
            R, Dim, Pick, Swap : Natural;
            Beta, Save, V, Den, Step, Delta_C, Restart : Work;
         begin
            for Rj in 1 .. K loop
               for P in 1 .. N loop Col (P) := J (Rj, P); end loop;
               Backsolve (L, Col, Sol);
               for P in 1 .. N loop Inv_J (P, Rj) := Sol (P); end loop;
               for Ri in 1 .. K loop
                  V := 0.0;
                  for P in 1 .. N loop V := V + J (Ri, P) * Sol (P); end loop;
                  AR (Ri, Rj) := V;
               end loop;
               AR (Rj, Rj) := AR (Rj, Rj) + Constraints (Rj).R;
               if AR (Rj, Rj) < Tiny then raise Constraint_Error; end if;
            end loop;
            Multiply (J, A_Free, B);
            for Ri in 1 .. K loop B (Ri) := B (Ri) - Aref (Ri); end loop;
            Project_Forces;
            Previous := F;
            MJ.Constraint_Order.Next (Seed, Random);
            Result.Outcome := Iteration_Limit;
            for Iter in 1 .. Settings.Iterations loop
               Beta := 0.0;
               if Iter > 1 then Beta := (Real (Nk) - 1.0) / (Real (Nk) + 2.0); end if;
               if Beta > 0.0 then
                  for Ri in F'Range loop
                     Save := F (Ri); F (Ri) := F (Ri) + Beta * (F (Ri) - Previous (Ri)); Previous (Ri) := Save;
                  end loop;
                  Project_Forces;
               else Previous := F; end if;
               Momentum := F;
               for Bi in reverse 2 .. Count loop
                  MJ.Constraint_Order.Next (Seed, Random);
                  Pick := Natural (Random mod Interfaces.Unsigned_32 (Bi)) + 1;
                  Swap := Blocks (Pick); Blocks (Pick) := Blocks (Bi); Blocks (Bi) := Swap;
               end loop;
               Result.Improvement := 0.0;
               for Bi in 1 .. Count loop
                  R := Blocks (Bi); Dim := Constraints (R).Dimension;
                  for T in 1 .. Dim loop
                     V := B (R + T - 1);
                     for Ri in F'Range loop V := V + AR (R + T - 1, Ri) * F (Ri); end loop;
                     Res (T) := V; Old (T) := F (R + T - 1);
                  end loop;
                  if Dim = 1 then
                     F (R) := Project_Row (Constraints (R).Form,
                       F (R) - Res (1) * (1.0 / AR (R, R)), Constraints (R).Bound);
                  else
                     if F (R) < Tiny then
                        F (R) := Real'Max (0.0, F (R) - Res (1) * (1.0 / AR (R, R)));
                        for T in 1 .. Dim - 1 loop F (R + T) := 0.0; end loop;
                     else
                        Den := 0.0;
                        for S in 1 .. Dim loop
                           V := 0.0;
                           for T in 1 .. Dim loop V := V + AR (R + S - 1, R + T - 1) * Old (T); end loop;
                           Den := Den + Old (S) * V;
                        end loop;
                        if Den >= Tiny then
                           Step := -Dot (Old (1 .. Dim), Res (1 .. Dim)) / Den;
                           if F (R) + Step * Old (1) < 0.0 then Step := -Old (1) / F (R); end if;
                           for T in 1 .. Dim loop F (R + T - 1) := F (R + T - 1) + Step * Old (T); end loop;
                        end if;
                     end if;
                     for S in 1 .. Dim - 1 loop
                        V := 0.0;
                        for T in 1 .. Dim - 1 loop
                           Ac (S, T) := AR (R + S, R + T);
                           V := V + Ac (S, T) * Old (T + 1);
                        end loop;
                        Bc (S) := Res (S + 1) - V + AR (R + S, R) * (F (R) - Old (1));
                        Dc (S) := Constraints (R).Friction (S);
                     end loop;
                     if F (R) < Tiny then
                        for T in 1 .. Dim - 1 loop F (R + T) := 0.0; end loop;
                     else
                        declare
                           Tangents : constant Natural := Dim - 1;
                           A_T : Matrix (1 .. Tangents, 1 .. Tangents);
                        begin
                           for S in A_T'Range (1) loop for T in A_T'Range (2) loop A_T (S, T) := Ac (S, T); end loop; end loop;
                           QCQP (A_T, Bc (1 .. Dim - 1), Dc (1 .. Dim - 1), F (R), Xc (1 .. Dim - 1));
                        end;
                        for T in 1 .. Dim - 1 loop F (R + T) := Xc (T); end loop;
                     end if;
                  end if;
                  for T in 1 .. Dim loop Change (T) := F (R + T - 1) - Old (T); end loop;
                  Delta_C := Dot (Change (1 .. Dim), Res (1 .. Dim));
                  for S in 1 .. Dim loop
                     V := 0.0;
                     for T in 1 .. Dim loop V := V + AR (R + S - 1, R + T - 1) * Change (T); end loop;
                     Delta_C := Delta_C + 0.5 * Change (S) * V;
                  end loop;
                  if Delta_C > 1.0e-10 then
                     for T in 1 .. Dim loop F (R + T - 1) := Old (T); end loop;
                     Delta_C := 0.0;
                  end if;
                  Result.Improvement := Result.Improvement - Delta_C;
               end loop;
               Result.Improvement := Result.Improvement * Settings.Scale;
               Restart := 0.0;
               if Iter > 1 then
                  for Ri in F'Range loop Restart := Restart + (F (Ri) - Momentum (Ri)) * (Momentum (Ri) - Previous (Ri)); end loop;
               end if;
               if Restart < 0.0 then Nk := 0; Result.Restarts := Result.Restarts + 1;
               else Nk := Nk + 1; end if;
               Result.Iterations := Iter;
               if Result.Improvement < Settings.Tolerance then Result.Outcome := Converged; exit; end if;
            end loop;
            Acc := A_Free;
            for P in 1 .. N loop
               V := 0.0;
               for Ri in F'Range loop V := V + Inv_J (P, Ri) * F (Ri); end loop;
               Acc (P) := Acc (P) + V;
            end loop;
         end Run_PGS;

         type Point is record
            Alpha, Cost, First, Second : Work := 0.0;
         end record;
         LS_Count : Natural := 0;
         G1, G2 : Work;

         type Polynomial is array (Natural range 0 .. 8) of Real;
         type Polynomials is array (Positive range <>) of Polynomial;
         Quad : Polynomials (1 .. K);

         procedure Prepare_Line is
            R, Dim : Natural;
            DJ, U, V : Work;
         begin
            Multiply (M, Search, Mv); Multiply (J, Search, Jv);
            G1 := Dot (Search, Ma) - Dot (Smooth, Search); G2 := 0.5 * Dot (Search, Mv);
            for Bi in 1 .. Count loop
               R := Blocks (Bi); Dim := Constraints (R).Dimension;
               Quad (Bi) := (others => 0.0);
               for T in R .. R + Dim - 1 loop
                  DJ := Constraints (T).D * Jar (T);
                  Quad (Bi) (0) := Quad (Bi) (0) + Jar (T) * DJ;
                  Quad (Bi) (1) := Quad (Bi) (1) + Jv (T) * DJ;
                  Quad (Bi) (2) := Quad (Bi) (2) + Jv (T) * Constraints (T).D * Jv (T);
               end loop;
               Quad (Bi) (0) := 0.5 * Quad (Bi) (0);
               Quad (Bi) (2) := 0.5 * Quad (Bi) (2);
               if Constraints (R).Form = Elliptic then
                  Quad (Bi) (3) := Jar (R) * Constraints (R).Mu;
                  Quad (Bi) (4) := Jv (R) * Constraints (R).Mu;
                  for T in 1 .. Dim - 1 loop
                     U := Jar (R + T) * Constraints (R).Friction (T);
                     V := Jv (R + T) * Constraints (R).Friction (T);
                     Quad (Bi) (5) := Quad (Bi) (5) + U * U;
                     Quad (Bi) (6) := Quad (Bi) (6) + U * V;
                     Quad (Bi) (7) := Quad (Bi) (7) + V * V;
                  end loop;
                  Quad (Bi) (8) := Constraints (R).D /
                    (Constraints (R).Mu**2 * (1.0 + Constraints (R).Mu**2));
               end if;
            end loop;
         end Prepare_Line;

         function Cone_Zone (N, T, Mu : Real) return State is
         begin
            if N not in -1.0e100 .. 1.0e100 or T not in 0.0 .. 1.0e100 then
               raise Constraint_Error;
            end if;
            return State'Val (Scalar.Row_State'Pos (Scalar.Cone_Zone (N, T, Mu)));
         end Cone_Zone;

         function Cone_Difference (Q : Polynomial; Alpha, Mu : Real) return Real is
            T0 : constant Real := Math.Sqrt (Real'Max (0.0, Q (5)));
            N1 : constant Real := Q (3) + Alpha * Q (4);
            T1 : constant Real := Math.Sqrt (Real'Max (0.0, Q (5) + Alpha * (2.0 * Q (6) + Alpha * Q (7))));
            Z0 : constant State := Cone_Zone (Q (3), T0, Mu);
            Z1 : constant State := Cone_Zone (N1, T1, Mu);
            TD, RD, R0, DQ, Boundary : Work;
         begin
            if Z0 = Satisfied and Z1 = Satisfied then return 0.0;
            elsif Z0 = Quadratic and Z1 = Quadratic then return Alpha * Alpha * Q (2) + Alpha * Q (1);
            elsif Z0 = Cone and Z1 = Cone then
               TD := Alpha * (2.0 * Q (6) + Alpha * Q (7)) / (T0 + T1);
               RD := Alpha * Q (4) - Mu * TD; R0 := Q (3) - Mu * T0;
               return 0.5 * Q (8) * RD * (2.0 * R0 + RD);
            elsif Z0 = Cone and Z1 = Quadratic then
               DQ := Alpha * (Alpha * Q (2) + Q (1)); Boundary := Mu * Q (3) + T0;
               return DQ + 0.5 * Q (8) * Boundary * Boundary;
            elsif Z0 = Quadratic and Z1 = Cone then
               DQ := Alpha * (Alpha * Q (2) + Q (1)); Boundary := Mu * N1 + T1;
               return DQ - 0.5 * Q (8) * Boundary * Boundary;
            elsif Z0 = Satisfied and Z1 = Quadratic then return Alpha * Alpha * Q (2) + Alpha * Q (1) + Q (0);
            elsif Z0 = Satisfied and Z1 = Cone then return 0.5 * Q (8) * (N1 - Mu * T1)**2;
            elsif Z0 = Cone and Z1 = Satisfied then return -0.5 * Q (8) * (Q (3) - Mu * T0)**2;
            else return -Q (0);
            end if;
         end Cone_Difference;

         procedure Evaluate_Line (P : in out Point) is
            Total : Polynomial := (0 => 0.0, 1 => G1, 2 => G2, others => 0.0);
            Q : Polynomial;
            R : Natural;
            X, Start, Dir, Rf, Bound, D, C0, Mu, Normal, T, T1, T2 : Work;
            Z : State;
            S0, S1 : Scalar.Response;
         begin
            LS_Count := LS_Count + 1;
            P.Cost := 0.0; P.First := 0.0; P.Second := 0.0;
            for Bi in 1 .. Count loop
               R := Blocks (Bi); Q := Quad (Bi);
               case Constraints (R).Form is
                  when Equality =>
                     Total (1) := Total (1) + Q (1); Total (2) := Total (2) + Q (2);
                  when Friction =>
                     Start := Jar (R); Dir := Jv (R); X := Start + P.Alpha * Dir;
                     Bound := Constraints (R).Bound; D := Constraints (R).D;
                     Rf := Constraints (R).R * Bound;
                     if abs Start > 1.0e30 or abs X > 1.0e30 then raise Constraint_Error; end if;
                     S0 := Scalar.Evaluate (Scalar.Friction, Start, Constraints (R).R, D, Bound);
                     S1 := Scalar.Evaluate (Scalar.Friction, X, Constraints (R).R, D, Bound);
                     if S0.State = Scalar.Quadratic and S1.State = Scalar.Quadratic then
                        P.Cost := P.Cost + 0.5 * D * (X - Start) * (X + Start);
                     elsif S0.State = Scalar.Linear_Negative and S1.State = Scalar.Linear_Negative then
                        P.Cost := P.Cost + Bound * (Start - X);
                     elsif S0.State = Scalar.Linear_Positive and S1.State = Scalar.Linear_Positive then
                        P.Cost := P.Cost + Bound * (X - Start);
                     else P.Cost := P.Cost + S1.Cost - S0.Cost; end if;
                     if -Rf < X and X < Rf then P.First := P.First + D * X * Dir; P.Second := P.Second + D * Dir * Dir;
                     elsif X <= -Rf then P.First := P.First - Bound * Dir;
                     else P.First := P.First + Bound * Dir; end if;
                  when Unilateral =>
                     X := Jar (R) + P.Alpha * Jv (R);
                     C0 := (if Jar (R) < 0.0 then Q (0) else 0.0);
                     if X < 0.0 then
                        Total (0) := Total (0) + (Q (0) - C0);
                        Total (1) := Total (1) + Q (1); Total (2) := Total (2) + Q (2);
                     else P.Cost := P.Cost - C0; end if;
                  when Elliptic =>
                     Mu := Constraints (R).Mu;
                     P.Cost := P.Cost + Cone_Difference (Q, P.Alpha, Mu);
                     Normal := Q (3) + P.Alpha * Q (4);
                     T := Math.Sqrt (Real'Max (0.0, Q (5) + P.Alpha * (2.0 * Q (6) + P.Alpha * Q (7))));
                     Z := Cone_Zone (Normal, T, Mu);
                     if Z = Quadratic then
                        P.First := P.First + 2.0 * P.Alpha * Q (2) + Q (1); P.Second := P.Second + 2.0 * Q (2);
                     elsif Z = Cone then
                        T1 := (Q (6) + P.Alpha * Q (7)) / T;
                        T2 := Q (7) / T - (Q (6) + P.Alpha * Q (7)) * T1 / (T * T);
                        P.First := P.First + Q (8) * (Normal - Mu * T) * (Q (4) - Mu * T1);
                        P.Second := P.Second + Q (8) * ((Q (4) - Mu * T1)**2 + (Normal - Mu * T) * (-Mu * T2));
                     end if;
               end case;
            end loop;
            P.Cost := P.Cost + P.Alpha * P.Alpha * Total (2) + P.Alpha * Total (1) + Total (0);
            P.First := P.First + 2.0 * P.Alpha * Total (2) + Total (1);
            P.Second := P.Second + 2.0 * Total (2);
            if P.Second <= 0.0 then
               P.Second := Tiny;
               Result.Curvature_Repairs := Result.Curvature_Repairs + 1;
            end if;
         end Evaluate_Line;

         procedure Line_Search (Alpha, Improvement : out Real; Hit_Limit : out Boolean) is
            P0, P1, P2, N1, N2, Mid : Point;
            Snorm : constant Real := Norm (Search);
            Gtol, Direction : Work;
            Changed_1, Changed_2 : Boolean;
            type Candidates is array (1 .. 3) of Point;
            Choices : Candidates;
            Best : Natural;
            procedure Bracket (P : in out Point; Next : in out Point; Changed : out Boolean) is
            begin
               Changed := False;
               for V of Choices loop
                  if (P.First < 0.0 and V.First < 0.0 and P.First < V.First)
                    or else (P.First > 0.0 and V.First > 0.0 and P.First > V.First)
                  then P := V; Changed := True; end if;
               end loop;
               if Changed then Next.Alpha := P.Alpha - P.First / P.Second; Evaluate_Line (Next); end if;
            end Bracket;
         begin
            Alpha := 0.0; Improvement := 0.0; Hit_Limit := False; LS_Count := 0;
            if Snorm < Tiny then return; end if;
            Prepare_Line;
            Gtol := Settings.Tolerance * Settings.LS_Tolerance * Snorm / Settings.Scale;
            Evaluate_Line (P0);
            P1.Alpha := -P0.First / P0.Second; Evaluate_Line (P1);
            if abs P1.First < Gtol and (P1.Alpha = 0.0 or P1.Cost < 0.0) then
               Alpha := P1.Alpha; Improvement := -P1.Cost; return;
            end if;
            Direction := (if P1.First < 0.0 then 1.0 else -1.0); P2 := P0;
            while P1.First * Direction <= -Gtol and LS_Count < Settings.LS_Iterations loop
               P2 := P1; P1.Alpha := P1.Alpha - P1.First / P1.Second; Evaluate_Line (P1);
               if abs P1.First < Gtol and P1.Cost < 0.0 then Alpha := P1.Alpha; Improvement := -P1.Cost; return; end if;
            end loop;
            if LS_Count >= Settings.LS_Iterations then
               Hit_Limit := True;
               if P1.Cost < 0.0 then Alpha := P1.Alpha; Improvement := -P1.Cost; end if;
               return;
            end if;
            N2 := P1; N1.Alpha := P1.Alpha - P1.First / P1.Second; Evaluate_Line (N1);
            while LS_Count < Settings.LS_Iterations loop
               Mid.Alpha := 0.5 * (P1.Alpha + P2.Alpha); Evaluate_Line (Mid);
               Choices := (N1, N2, Mid); Best := 0;
               for T in Choices'Range loop
                  if abs Choices (T).First < Gtol and then Choices (T).Cost < 0.0
                    and then (Best = 0 or else Choices (T).Cost < Choices (Best).Cost)
                  then Best := T; end if;
               end loop;
               if Best /= 0 then Alpha := Choices (Best).Alpha; Improvement := -Choices (Best).Cost; return; end if;
               Bracket (P1, N1, Changed_1); Bracket (P2, N2, Changed_2);
               if not Changed_1 and not Changed_2 then
                  if Mid.Cost < 0.0 then Alpha := Mid.Alpha; Improvement := -Mid.Cost; end if;
                  return;
               end if;
            end loop;
            Hit_Limit := True;
            if P1.Cost <= P2.Cost and P1.Cost < 0.0 then Alpha := P1.Alpha; Improvement := -P1.Cost;
            elsif P2.Cost < P1.Cost and P2.Cost < 0.0 then Alpha := P2.Alpha; Improvement := -P2.Cost; end if;
         end Line_Search;

         procedure Run_Primal is
            Y, MY : Vector (1 .. N);
            Gap, Decrement, Alpha, Improvement, Beta, DY, HZ, Eta : Work;
            Hit_Limit : Boolean;
         begin
            Residual; Update (False); Backsolve (L, Grad, Mgrad);
            Gap := Real'Max (0.0, 0.5 * Settings.Scale * Dot (Grad, Mgrad));
            Result.Gradient := Settings.Scale * Norm (Grad);
            if Gap < Settings.Tolerance and (Settings.Algorithm = CG or Result.Gradient < Settings.Tolerance) then
               Result.Outcome := Converged; return;
            end if;
            if Settings.Algorithm = Newton then Update (True); Precondition; end if;
            for P in 1 .. N loop Search (P) := -Mgrad (P); end loop;
            Result.Outcome := Iteration_Limit;
            for Iter in 1 .. Settings.Iterations loop
               Line_Search (Alpha, Improvement, Hit_Limit);
               Result.Evaluations := Result.Evaluations + LS_Count;
               if Alpha = 0.0 then
                  Result.Outcome := (if Hit_Limit then Line_Search_Limit else Stalled); exit;
               end if;
               for P in 1 .. N loop Acc (P) := Acc (P) + Alpha * Search (P); Ma (P) := Ma (P) + Alpha * Mv (P); end loop;
               for R in 1 .. K loop Jar (R) := Jar (R) + Alpha * Jv (R); end loop;
               Oldgrad := Grad; Oldmg := Mgrad;
               Update (Settings.Algorithm = Newton); Precondition;
               Result.Iterations := Iter;
               Result.Improvement := Improvement * Settings.Scale;
               Result.Gradient := Settings.Scale * Norm (Grad);
               Decrement := Real'Max (0.0, 0.5 * Settings.Scale * Dot (Grad, Mgrad));
               if Hit_Limit then Result.Line_Search_Limits := Result.Line_Search_Limits + 1; end if;
               if (Result.Improvement > 0.0 and Result.Improvement < Settings.Tolerance)
                 or Result.Gradient < Settings.Tolerance
                 or (Settings.Algorithm = Newton and Decrement < Settings.Tolerance)
               then Result.Outcome := Converged; exit; end if;
               Beta := 0.0;
               if Settings.Algorithm = CG then
                  for P in 1 .. N loop Y (P) := Grad (P) - Oldgrad (P); MY (P) := Mgrad (P) - Oldmg (P); end loop;
                  DY := Dot (Search, Y);
                  if DY >= Tiny then
                     HZ := (Dot (Y, Mgrad) - 2.0 * (Dot (Y, MY) / DY) * Dot (Search, Grad)) / DY;
                     Eta := -1.0 / Real'Max (Tiny, Norm (Search) * Real'Min (0.01, Norm (Grad)));
                     Beta := Real'Max (Eta, HZ);
                  else Result.Restarts := Result.Restarts + 1; end if;
               end if;
               for P in 1 .. N loop Search (P) := -Mgrad (P) + Beta * Search (P); end loop;
            end loop;
         end Run_Primal;
      begin
         Factor (M, L, OK);
         if not OK then Result.Outcome := Not_Positive_Definite; return; end if;
         I := 1;
         while I <= K loop Count := Count + 1; Blocks (Count) := I; I := I + Constraints (I).Dimension; end loop;
         Multiply (M, A_Free, Smooth);
         if K = 0 then Acc := A_Free; Result.Outcome := Converged; Grad := (others => 0.0);
         elsif Settings.Algorithm = PGS then
            Run_PGS;
            --  Compute primal diagnostic cost without replacing PGS's dual force.
            declare Saved : constant Vector := F; begin Residual; Update (False); F := Saved; end;
         else Run_Primal; end if;
         Result.Cost := Cost; Result.Gradient := Settings.Scale * Norm (Grad);
         for X of Acc loop if X not in -1.0e100 .. 1.0e100 then raise Constraint_Error; end if; end loop;
         for X of F loop if X not in -1.0e100 .. 1.0e100 then raise Constraint_Error; end if; end loop;
         A := Acc; Force := F;
      exception
         when Constraint_Error => Result.Outcome := Numeric_Limit;
      end;
   end Solve;
end MJ.Constraint_Solvers;

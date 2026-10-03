with Ada.Numerics.Long_Elementary_Functions;
with MJ.NoSlip_Kernels;
with MJ.Constraint_Solvers.Cholesky;
package body MJ.NoSlip with SPARK_Mode is
   package K renames MJ.NoSlip_Kernels;
   package Linear renames MJ.Constraint_Solvers.Cholesky;
   package Math renames Ada.Numerics.Long_Elementary_Functions;
   use type Linear.Status;
   subtype Work is Real range -1.0e100 .. 1.0e100;

   function Dot (A, B : Vector) return Work is
      S0, S1, S2, S3, S : Work := 0.0;
      I : Natural := 1;
   begin
      while I + 3 <= A'Length loop
         S0 := S0 + A (I) * B (I);
         S1 := S1 + A (I + 1) * B (I + 1);
         S2 := S2 + A (I + 2) * B (I + 2);
         S3 := S3 + A (I + 3) * B (I + 3);
         I := I + 4;
      end loop;
      S := (S0 + S2) + (S1 + S3);
      case A'Length - (I - 1) is
         when 3 => S := S + (A (I) * B (I) + A (I + 1) * B (I + 1) + A (I + 2) * B (I + 2));
         when 2 => S := S + (A (I) * B (I) + A (I + 1) * B (I + 1));
         when 1 => S := S + A (I) * B (I);
         when others => null;
      end case;
      return S;
   end Dot;

   function Row_Dot (A : Matrix; Row_Index : Positive; B : Vector) return Work is
      S0, S1, S2, S3, S : Work := 0.0;
      I : Natural := 1;
   begin
      while I + 3 <= B'Length loop
         S0 := S0 + A (Row_Index, I) * B (I);
         S1 := S1 + A (Row_Index, I + 1) * B (I + 1);
         S2 := S2 + A (Row_Index, I + 2) * B (I + 2);
         S3 := S3 + A (Row_Index, I + 3) * B (I + 3);
         I := I + 4;
      end loop;
      S := (S0 + S2) + (S1 + S3);
      case B'Length - (I - 1) is
         when 3 => S := S + (A (Row_Index, I) * B (I)
           + A (Row_Index, I + 1) * B (I + 1) + A (Row_Index, I + 2) * B (I + 2));
         when 2 => S := S + (A (Row_Index, I) * B (I) + A (Row_Index, I + 1) * B (I + 1));
         when 1 => S := S + A (Row_Index, I) * B (I);
         when others => null;
      end case;
      return S;
   end Row_Dot;

   --  Literal branch/order port of mju_QCQP2/3/generic and solveQCQP.
   --  The zero result on rank/determinant failure is C's fallback.
   procedure QCQP (A : Matrix; B, Mu : Vector; Radius : Real; X : out Vector) is
      N : constant Positive := B'Length;
      Scaled, Shifted, L, P : Matrix (1 .. N, 1 .. N);
      SB, V, Tmp : Vector (1 .. N);
      Lambda, Val, Deriv, Delta_L, Det, Detinv, S : Work := 0.0;
      Result : Linear.Status;
   begin
      X := [others => 0.0];
      for I in 1 .. N loop
         SB (I) := B (I) * Mu (I);
         for J in 1 .. N loop Scaled (I, J) := A (I, J) * Mu (I) * Mu (J); end loop;
      end loop;
      for Iter in 1 .. 20 loop
         Shifted := Scaled;
         for I in 1 .. N loop Shifted (I, I) := Shifted (I, I) + Lambda; end loop;
         if N = 2 or N = 3 then
            if N = 2 then
               Det := Shifted (1, 1) * Shifted (2, 2) - Shifted (1, 2) * Shifted (1, 2);
               if Det < 1.0e-10 then return; end if;
               Detinv := 1.0 / Det;
               P (1, 1) := Shifted (2, 2) * Detinv;
               P (2, 2) := Shifted (1, 1) * Detinv;
               P (1, 2) := -Shifted (1, 2) * Detinv; P (2, 1) := P (1, 2);
               V (1) := -P (1, 1) * SB (1) - P (1, 2) * SB (2);
               V (2) := -P (1, 2) * SB (1) - P (2, 2) * SB (2);
               Val := V (1) * V (1) + V (2) * V (2) - Radius * Radius;
            else
               P (1, 1) := Shifted (2, 2) * Shifted (3, 3) - Shifted (2, 3) * Shifted (2, 3);
               P (2, 2) := Shifted (1, 1) * Shifted (3, 3) - Shifted (1, 3) * Shifted (1, 3);
               P (3, 3) := Shifted (1, 1) * Shifted (2, 2) - Shifted (1, 2) * Shifted (1, 2);
               P (1, 2) := Shifted (1, 3) * Shifted (2, 3) - Shifted (1, 2) * Shifted (3, 3);
               P (1, 3) := Shifted (1, 2) * Shifted (2, 3) - Shifted (1, 3) * Shifted (2, 2);
               P (2, 3) := Shifted (1, 2) * Shifted (1, 3) - Shifted (2, 3) * Shifted (1, 1);
               P (2, 1) := P (1, 2); P (3, 1) := P (1, 3); P (3, 2) := P (2, 3);
               Det := Shifted (1, 1) * P (1, 1) + Shifted (1, 2) * P (1, 2) + Shifted (1, 3) * P (1, 3);
               if Det < 1.0e-10 then return; end if;
               Detinv := 1.0 / Det;
               for I in 1 .. N loop for J in 1 .. N loop P (I, J) := P (I, J) * Detinv; end loop; end loop;
               V (1) := -P (1, 1) * SB (1) - P (1, 2) * SB (2) - P (1, 3) * SB (3);
               V (2) := -P (1, 2) * SB (1) - P (2, 2) * SB (2) - P (2, 3) * SB (3);
               V (3) := -P (1, 3) * SB (1) - P (2, 3) * SB (2) - P (3, 3) * SB (3);
               Val := V (1) * V (1) + V (2) * V (2) + V (3) * V (3) - Radius * Radius;
            end if;
         else
            Linear.Factor (Shifted, L, Result, 1.0e-10);
            if Result = Linear.Not_Positive_Definite then return; end if;
            if Result /= Linear.Success then raise Constraint_Error; end if;
            Linear.Backsolve (L, SB, V, Result);
            if Result /= Linear.Success then raise Constraint_Error; end if;
            for I in 1 .. N loop V (I) := -V (I); end loop;
            Val := Dot (V, V) - Radius * Radius;
         end if;
         exit when Val < 1.0e-10;
         if N = 2 then
            Deriv := -2.0 * (P (1, 1) * V (1) * V (1) + 2.0 * P (1, 2) * V (1) * V (2) + P (2, 2) * V (2) * V (2));
         elsif N = 3 then
            Deriv := -2.0 * (P (1, 1) * V (1) * V (1) + P (2, 2) * V (2) * V (2) + P (3, 3) * V (3) * V (3))
              - 4.0 * (P (1, 2) * V (1) * V (2) + P (1, 3) * V (1) * V (3) + P (2, 3) * V (2) * V (3));
         else
            Linear.Backsolve (L, V, Tmp, Result);
            if Result /= Linear.Success then raise Constraint_Error; end if;
            Deriv := -2.0 * Dot (V, Tmp);
         end if;
         if Deriv >= 0.0 then raise Constraint_Error; end if;
         Delta_L := -Val / Deriv;
         exit when Delta_L < 1.0e-10;
         Lambda := Lambda + Delta_L;
      end loop;
      for I in 1 .. N loop X (I) := V (I) * Mu (I); end loop;
      if Lambda /= 0.0 then
         S := 0.0;
         for I in 1 .. N loop S := S + X (I) * X (I) / (Mu (I) * Mu (I)); end loop;
         Val := Math.Sqrt ((Radius * Radius) / Real'Max (Min_Val, S));
         if Val not in 0.0 .. 1.0e100 then raise Constraint_Error; end if;
         for I in 1 .. N loop X (I) := X (I) * Val; end loop;
      end if;
   end QCQP;

   procedure Solve (AR : Matrix; B : Vector; Constraints : Rows;
                    Settings : Options; Force : in out Vector; Result : out Report) is
      N : constant Natural := B'Length;
      I : Natural := 1;
      Dim, Width : Natural;
      Tail, Friction_Started : Boolean := False;
   begin
      Result := (others => <>);
      if N > Max_Rows or else B'First /= 1 or else Force'First /= 1
        or else Force'Length /= N or else Constraints'First /= 1 or else Constraints'Length /= N
        or else AR'First (1) /= 1 or else AR'First (2) /= 1
        or else AR'Length (1) /= N or else AR'Length (2) /= N
        or else Settings.Tolerance not in 0.0 .. 1.0e20
        or else Settings.Scale not in 1.0e-20 .. 1.0e20 then return; end if;
      for R in 1 .. N loop
         if B (R) not in K.Coefficient or else Force (R) not in K.Force_Value
           or else Constraints (R).R not in K.Regularization
           or else Constraints (R).Bound not in K.Regularization then return; end if;
         for C in 1 .. N loop if AR (R, C) not in K.Coefficient then return; end if; end loop;
      end loop;
      while I <= N loop
         case Constraints (I).Form is
            when Equality => if Friction_Started or Tail then return; end if;
            when Dof_Friction | Tendon_Friction =>
               if Tail then return; end if;
               Friction_Started := True;
               if abs Force (I) > Constraints (I).Bound then return; end if;
            when others => Tail := True;
         end case;
         if Constraints (I).Form in Pyramidal | Elliptic then
            Dim := Constraints (I).Dimension;
            if Dim not in 3 | 4 | 6 then return; end if;
            Width := (if Constraints (I).Form = Pyramidal then 2 * (Dim - 1) else Dim);
            if Width > N - I + 1 or else Force (I) < 0.0 then return; end if;
            for T in 1 .. Dim - 1 loop
               if Constraints (I).Friction (T) not in 1.0e-10 .. 1.0e10 then return; end if;
            end loop;
            for T in 1 .. Width - 1 loop
               if Constraints (I + T).Form /= Constraints (I).Form
                 or else Constraints (I + T).Dimension /= 0 then return; end if;
               if Constraints (I).Form = Pyramidal and then Force (I + T) < 0.0 then return; end if;
            end loop;
            I := I + Width;
         else
            if Constraints (I).Dimension /= 1 then return; end if;
            I := I + 1;
         end if;
      end loop;
      if Settings.Iterations = 0 then Result.Outcome := Disabled; return; end if;
      if N = 0 then Result.Outcome := Converged; return; end if;
      declare
         F : Vector (1 .. N) := Force;
         Inv : Vector (1 .. N);
         Improvement, Change : Work;
         Res : K.Residual_Value;
         Old, Proposed : K.Force_Value;
      begin
         for R in 1 .. N loop Inv (R) := K.Inverse_Diagonal (AR (R, R), Constraints (R).R); end loop;
         Result.Outcome := Iteration_Limit;
         for Iter in 1 .. Settings.Iterations loop
            Improvement := 0.0;
            if Iter = 1 then
               for R in 1 .. N loop Improvement := Improvement + 0.5 * F (R) * F (R) * Constraints (R).R; end loop;
            end if;
            for R in 1 .. N loop
               if Constraints (R).Form in Dof_Friction | Tendon_Friction then
                  Res := (B (R) + Row_Dot (AR, R, F)) - Constraints (R).R * F (R);
                  Old := F (R);
                  Proposed := K.Dry_Force (Old, Res, Inv (R), Constraints (R).Bound);
                  F (R) := Proposed;
                  Improvement := Improvement - K.Scalar_Change (Old, Proposed, Res, Inv (R));
               end if;
            end loop;
            I := 1;
            while I <= N loop
               if Constraints (I).Form = Pyramidal then
                  Dim := Constraints (I).Dimension;
                  for T in 0 .. Dim - 2 loop
                     declare
                        J : constant Positive := I + 2 * T;
                        R0 : constant K.Residual_Value := (B (J) + Row_Dot (AR, J, F)) - Constraints (J).R * F (J);
                        R1 : constant K.Residual_Value := (B (J + 1) + Row_Dot (AR, J + 1, F)) - Constraints (J + 1).R * F (J + 1);
                        A00 : constant Real := K.Block_Diagonal (AR (J, J), Constraints (J).R);
                        A11 : constant Real := K.Block_Diagonal (AR (J + 1, J + 1), Constraints (J + 1).R);
                        A01 : constant Real := AR (J, J + 1);
                        A10 : constant Real := AR (J + 1, J);
                        B0 : constant K.Residual_Value := R0 - (0.0 + (A00 * F (J) + A01 * F (J + 1)));
                        B1 : constant K.Residual_Value := R1 - (0.0 + (A10 * F (J) + A11 * F (J + 1)));
                        Old_Pair : constant K.Pair_Force := (F (J), F (J + 1));
                        P : constant K.Pair_Force := K.Propose_Pair (A00, A01, A10, A11, B0, B1, F (J), F (J + 1));
                        C : constant K.Cost_Value := K.Pair_Change (A00, A01, A10, A11, Old_Pair, P, R0, R1);
                        Accepted : constant K.Pair_Result := K.Accept_Pair (Old_Pair, P, C);
                     begin
                        if Accepted.Force.First not in K.Force_Value or Accepted.Force.Second not in K.Force_Value then raise Constraint_Error; end if;
                        F (J) := Accepted.Force.First; F (J + 1) := Accepted.Force.Second;
                        Improvement := Improvement - Accepted.Change;
                        if Accepted.Restored then Result.Restored_Blocks := Result.Restored_Blocks + 1; end if;
                     end;
                  end loop;
                  I := I + 2 * (Dim - 1);
               elsif Constraints (I).Form = Elliptic then
                  Dim := Constraints (I).Dimension - 1;
                  declare
                     Ac : Matrix (1 .. Dim, 1 .. Dim);
                     R, Old_F, BC, Mu, X, Delta_F : Vector (1 .. Dim);
                  begin
                     for T in 1 .. Dim loop
                        Old_F (T) := F (I + T); Mu (T) := Constraints (I).Friction (T);
                        R (T) := (B (I + T) + Row_Dot (AR, I + T, F)) - Constraints (I + T).R * F (I + T);
                        for U in 1 .. Dim loop
                           Ac (T, U) := (if T = U then K.Block_Diagonal (AR (I + T, I + U), Constraints (I + T).R)
                             else AR (I + T, I + U));
                        end loop;
                     end loop;
                     for T in 1 .. Dim loop BC (T) := R (T) - Row_Dot (Ac, T, Old_F); end loop;
                     if F (I) < Min_Val then X := [others => 0.0];
                     else QCQP (Ac, BC, Mu, F (I), X); end if;
                     for T in 1 .. Dim loop Delta_F (T) := X (T) - Old_F (T); end loop;
                     Change := 0.0;
                     for T in 1 .. Dim loop Change := Change + Delta_F (T) * Row_Dot (Ac, T, Delta_F); end loop;
                     Change := 0.5 * Change + Dot (Delta_F, R);
                     if Change > 1.0e-10 then
                        Result.Restored_Blocks := Result.Restored_Blocks + 1;
                     else
                        for T in 1 .. Dim loop
                           if X (T) not in K.Force_Value then raise Constraint_Error; end if;
                           F (I + T) := X (T);
                        end loop;
                        Improvement := Improvement - Change;
                     end if;
                  end;
                  I := I + Dim + 1;
               else I := I + 1; end if;
            end loop;
            Improvement := Improvement * Settings.Scale;
            Result.Iterations := Iter;
            Result.Improvement := Improvement;
            if Improvement < Settings.Tolerance then Result.Outcome := Converged; exit; end if;
         end loop;
         Force := F;
      end;
   exception
      when Constraint_Error => Result.Outcome := Numeric_Limit;
   end Solve;
end MJ.NoSlip;

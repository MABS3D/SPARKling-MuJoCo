with MJ.Constraint_Scalar;
with MJ.Joint_Limit_Math;
package body MJ.Inverse_Constraints with SPARK_Mode is
   procedure Evaluate
     (Jacobian : MJ.Constraint_Assembly.Storage;
      Rows : MJ.Constraint_Solvers.Rows; Aref : MJ.Constraint_Solvers.Vector;
      Qacc : Real_Array; Force, Generalized : in out Real_Array; Accepted : out Boolean;
      Sparse : Boolean := True) is
      package CA renames MJ.Constraint_Assembly;
      package CS renames MJ.Constraint_Solvers;
      package Scalar renames MJ.Constraint_Scalar;
      use type CS.Kind;
      N : constant Natural := Qacc'Length;
      Nr : constant Natural := Rows'Length;
   begin
      Accepted := False;
      if N > CS.Max_Dofs or else Nr > CS.Max_Rows
        or else Rows'First /= 1 or else Aref'First /= 1
        or else Aref'Length /= Nr or else Force'Length /= Nr
        or else Generalized'Length /= N or else Jacobian.Dofs /= N
        or else not CA.Valid (Jacobian) or else Jacobian.Rows /= Nr
        or else (for some X of Qacc => X not in -1.0e10 .. 1.0e10)
        or else (for some X of Aref => X not in -1.0e30 .. 1.0e30)
      then return; end if;
      declare
         Jar : Real_Array (1 .. Nr) := [others => 0.0];
         F : Real_Array (1 .. Nr) := [others => 0.0];
         G : Real_Array (0 .. N - 1) := [others => 0.0];
         R : Positive := 1;
      begin
         for I in 1 .. Nr loop
            declare
               Row : constant CA.Row := Jacobian.Descriptors (I);
               L : array (Natural range 0 .. 3) of Real := [others => 0.0];
               K : Natural := 0;
               S : Real;
            begin
               if Row.Offset > Jacobian.Used or else Row.Nonzeros > Jacobian.Used - Row.Offset
                 or else Rows (I).R not in 1.0e-30 .. 1.0e30
                 or else Rows (I).D not in 1.0e-30 .. 1.0e30
                 or else Rows (I).Bound not in 0.0 .. 1.0e30
               then return; end if;
               if Sparse then
                  -- Match the four-lane sparse dot, including structural zeros.
                  while K + 4 <= Row.Nonzeros loop
                     for Lane in 0 .. 3 loop
                        declare
                           E : constant Positive := Row.Offset + K + Lane + 1;
                           V : constant Natural := Jacobian.Columns (E);
                        begin
                           if V >= N then return; end if;
                           L (Lane) := L (Lane) + Jacobian.Values (E) * Qacc (Qacc'First + V);
                        end;
                     end loop;
                     K := K + 4;
                  end loop;
                  S := (L (0) + L (2)) + (L (1) + L (3));
                  while K < Row.Nonzeros loop
                     declare
                        E : constant Positive := Row.Offset + K + 1;
                        V : constant Natural := Jacobian.Columns (E);
                     begin
                        if V >= N then return; end if;
                        S := S + Jacobian.Values (E) * Qacc (Qacc'First + V);
                     end;
                     K := K + 1;
                  end loop;
               else
                  -- Dense C dot retains structural zeros and groups its tail.
                  declare
                     Dense : Real_Array (0 .. N - 1) := [others => 0.0];
                  begin
                     for E in Row.Offset + 1 .. Row.Offset + Row.Nonzeros loop
                        if Jacobian.Columns (E) >= N then return; end if;
                        Dense (Jacobian.Columns (E)) := Jacobian.Values (E);
                     end loop;
                     while K + 4 <= N loop
                        for Lane in 0 .. 3 loop
                           L (Lane) := L (Lane) + Dense (K+Lane) * Qacc (Qacc'First+K+Lane);
                        end loop;
                        K := K+4;
                     end loop;
                     S := (L (0) + L (2)) + (L (1) + L (3));
                     case N-K is
                        when 3 => S := S + ((Dense (K)*Qacc (Qacc'First+K)
                          + Dense (K+1)*Qacc (Qacc'First+K+1)) + Dense (K+2)*Qacc (Qacc'First+K+2));
                        when 2 => S := S + (Dense (K)*Qacc (Qacc'First+K)
                          + Dense (K+1)*Qacc (Qacc'First+K+1));
                        when 1 => S := S + Dense (K)*Qacc (Qacc'First+K);
                        when others => null;
                     end case;
                  end;
               end if;
               S := S - Aref (I);
               if S not in -1.0e30 .. 1.0e30 then return; end if;
               Jar (I) := S;
            end;
         end loop;
         while R <= Nr loop
            if Rows (R).Form /= CS.Elliptic then
               declare
                  Kind : constant Scalar.Row_Kind :=
                    (if Rows (R).Form = CS.Equality then Scalar.Equality
                     elsif Rows (R).Form = CS.Friction then Scalar.Friction
                     else Scalar.Unilateral);
               begin
                  F (R) := Scalar.Evaluate
                    (Kind, Jar (R), Rows (R).R, Rows (R).D, Rows (R).Bound).Force;
               end;
               R := R + 1;
            else
               declare
                  Dim : constant Natural := Rows (R).Dimension;
                  Mu : constant Real := Rows (R).Mu;
                  U : Real_Array (0 .. 5) := [others => 0.0];
                  Normal, Tangent, Sum : Real;
               begin
                  if Dim not in 3 | 4 | 6 or else Dim > Nr - R + 1
                    or else Mu not in 1.0e-5 .. 1.0e5
                    or else (for some X of Rows (R).Friction => X not in 1.0e-5 .. 1.0e5)
                  then return; end if;
                  for K in 1 .. Dim - 1 loop
                     if Rows (R + K).Form /= CS.Elliptic or else Rows (R + K).Dimension /= 0 then return; end if;
                  end loop;
                  U (0) := Jar (R) * Mu;
                  for K in 1 .. Dim - 1 loop U (K) := Jar (R + K) * Rows (R).Friction (K); end loop;
                  -- mju_norm uses the generic four-lane dot, then its remainder.
                  if Dim = 6 then
                     Sum := (U (1) * U (1) + U (3) * U (3)) + (U (2) * U (2) + U (4) * U (4));
                     Sum := Sum + U (5) * U (5);
                  else
                     Sum := 0.0;
                     for K in 1 .. Dim - 1 loop Sum := Sum + U (K) * U (K); end loop;
                  end if;
                  Tangent := MJ.Joint_Limit_Math.Sqrt (Sum);
                  if Tangent not in 0.0 .. 1.0e40 then return; end if;
                  Normal := U (0);
                  if Normal >= Mu * Tangent or else (Tangent <= 0.0 and Normal >= 0.0) then
                     null;
                  elsif Mu * Normal + Tangent <= 0.0 or else (Tangent <= 0.0 and Normal < 0.0) then
                     for K in 0 .. Dim - 1 loop F (R + K) := -Rows (R + K).D * Jar (R + K); end loop;
                  else
                     declare
                        Dm : constant Real := Rows (R).D / (Mu * Mu * (1.0 + Mu * Mu));
                        NmT : constant Real := Normal - Mu * Tangent;
                     begin
                        F (R) := -Dm * NmT * Mu;
                        for K in 1 .. Dim - 1 loop
                           F (R + K) := ((-F (R) / Tangent) * U (K)) * Rows (R).Friction (K);
                        end loop;
                     end;
                  end if;
                  R := R + Dim;
               end;
            end if;
         end loop;
         if (for some X of F => X not in -1.0e60 .. 1.0e60) then return; end if;
         for I in 1 .. Nr loop
            if F (I) /= 0.0 then
            for K in Jacobian.Descriptors (I).Offset + 1 ..
              Jacobian.Descriptors (I).Offset + Jacobian.Descriptors (I).Nonzeros
            loop
               declare
                  V : constant Natural := Jacobian.Columns (K);
                  Sum : constant Real := G (V) + Jacobian.Values (K) * F (I);
               begin
                  if Sum not in -1.0e60 .. 1.0e60 then return; end if;
                  G (V) := Sum;
               end;
            end loop;
            end if;
         end loop;
         Force := F;
         Generalized := G;
         Accepted := True;
      end;
   end Evaluate;
end MJ.Inverse_Constraints;

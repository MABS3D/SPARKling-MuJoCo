with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.SDF_Fields with SPARK_Mode is
   function Valid (F : Field; T : Octree) return Boolean is
      Last : Natural;
      C : Integer;
   begin
      if not MJ.BVH.Valid (F.Bounds) then return False; end if;
      if F.Kind = Analytic then return Valid_Shape (F.Geometry); end if;
      if F.Kind = Custom then return True; end if;
      if F.Length = 0 or else F.First not in T'Range or else F.Length - 1 > T'Last - F.First then return False; end if;
      Last := F.First + F.Length - 1;
      for I in F.First .. Last loop
         if not MJ.BVH.Valid (T (I).Bounds)
           or else (for some H of T (I).Bounds.Half => H <= 0.0)
           or else (for some Q of T (I).Coeff => Q not in -1.0e10 .. 1.0e10)
         then return False; end if;
         for J in 0 .. 7 loop
            C := T (I).Child (J);
            if C /= -1 and then (C < 0 or else C >= F.Length
              or else C + F.First <= I) then return False; end if;
         end loop;
      end loop;
      return True;
   end Valid;

   function Product (W, C : Real) return Tier2_Real with
     Global => null, Pre => W in -1.0e20 .. 1.0e20 and C in -1.0e20 .. 1.0e20,
     Post => Product'Result = W*C
   is
   begin
      return W*C;
   end Product;
   function Interpolate (W, C : Corner_Values) return Real is
      P0 : constant Tier2_Real := Product (W (0),C (0));
      P1 : constant Tier2_Real := Product (W (1),C (1));
      P2 : constant Tier2_Real := Product (W (2),C (2));
      P3 : constant Tier2_Real := Product (W (3),C (3));
      P4 : constant Tier2_Real := Product (W (4),C (4));
      P5 : constant Tier2_Real := Product (W (5),C (5));
      P6 : constant Tier2_Real := Product (W (6),C (6));
      P7 : constant Tier2_Real := Product (W (7),C (7));
      V : Real := 0.0;
   begin
      V := V+P0; V := V+P1; V := V+P2; V := V+P3;
      V := V+P4; V := V+P5; V := V+P6; V := V+P7;
      return V;
   end Interpolate;

   procedure Project (X : in out Vec; B : MJ.BVH.Box; Distance : out Real) is
      R, Q : Vec;
      Sum : Real := 0.0;
   begin
      R := Sub (X, B.Center);
      for K in Axis loop Q (K) := abs R (K) - B.Half (K); end loop;
      if (for all V of Q => V <= 0.0) then
         Distance := Real'Max (Q (0), Real'Max (Q (1), Q (2))); return;
      end if;
      for K in Axis loop
         if Q (K) >= 0.0 then
            Sum := Sum + Q (K)*Q (K);
            X (K) := X (K) - (if R (K) > 0.0 then Q (K) + 1.0e-6 else -(Q (K) + 1.0e-6));
         end if;
      end loop;
      Distance := Sqrt (Sum);
   end Project;

   procedure Locate (F : Field; T : Octree; X : Vec;
                     Leaf : out Natural; W : out Corner_Values;
                     DW : out Corner_Gradients; Result : out Status) is
      N : Natural := F.First;
      Lo, Hi, Coord, Factors, Inv : Vec := Zero;
      Signs : Vec;
      Child : Natural;
   begin
      W := [others => 0.0]; DW := [others => Zero]; Leaf := F.First; Result := Invalid_Input;
      for Step in 1 .. 100 loop
         for K in Axis loop
            Lo (K) := T (N).Bounds.Center (K) - T (N).Bounds.Half (K);
            Hi (K) := T (N).Bounds.Center (K) + T (N).Bounds.Half (K);
            if X (K) + 1.0e-8 < Lo (K) or X (K) - 1.0e-8 > Hi (K) then return; end if;
            if Hi (K)-Lo (K)<1.0e-20 then Result := Numeric_Limit; return; end if;
            Inv (K) := 1.0 / (Hi (K) - Lo (K));
            Coord (K) := (X (K) - Lo (K)) / (Hi (K) - Lo (K));
         end loop;
         if (for all C of T (N).Child => C = -1) then
            for J in 0 .. 7 loop
               for K in Axis loop
                  if (J / (2 ** K)) mod 2 = 1 then Factors (K) := Coord (K); Signs (K) := 1.0;
                  else Factors (K) := 1.0 - Coord (K); Signs (K) := -1.0; end if;
               end loop;
               W (J) := (Factors (0)*Factors (1))*Factors (2);
               DW (J) := [((Signs (0)*Factors (1))*Factors (2))*Inv (0),
                          ((Factors (0)*Signs (1))*Factors (2))*Inv (1),
                          ((Factors (0)*Factors (1))*Signs (2))*Inv (2)];
            end loop;
            Leaf := N; Result := Success; return;
         end if;
         Child := (if Coord (0) < 0.5 then 0 else 1)
           + (if Coord (1) < 0.5 then 0 else 2) + (if Coord (2) < 0.5 then 0 else 4);
         if T (N).Child (Child) = -1 then return; end if;
         N := F.First + T (N).Child (Child);
      end loop;
      Result := Iteration_Limit;
   end Locate;

   procedure Oct_Value (F : Field; T : Octree; X : Vec; Value : out Real; Result : out Status) is
      P : Vec := X;
      D : Real;
      W : Corner_Values;
      DW : Corner_Gradients;
      Leaf : Natural;
   begin
      Value := 0.0;
      Project (P, T (F.First).Bounds, D);
      if (for some Q of P => Q not in -1.0e10 .. 1.0e10) then Result := Numeric_Limit; return; end if;
      Locate (F, T, P, Leaf, W, DW, Result);
      if Result /= Success then return; end if;
      Value := Interpolate (W, T (Leaf).Coeff);
      if D > 0.0 then Value := Value + D; end if;
   end Oct_Value;

   procedure Evaluate (F : Field; T : Octree; X : Vec; Need_Gradient : Boolean;
                       Value : out Real; Gradient : out Vec; Result : out Status) is
      A, B, P, G0, G1 : Vec := Zero;
      N, M, R, E, C, DF0, DF1 : Real;
      W : Corner_Values;
      DW : Corner_Gradients;
      Leaf : Natural;
      S : constant Vec := F.Geometry.Size;
   begin
      Value := 0.0; Gradient := Zero; Result := Numeric_Limit;
      if (for some Q of X => Q not in -1.0e10 .. 1.0e10) then return; end if;
      if F.Kind = Custom then Result := Invalid_Input; return; end if;
      if F.Kind = Sampled then
         Oct_Value (F, T, X, Value, Result);
         if Result /= Success or not Need_Gradient then return; end if;
         P := X; Project (P, T (F.First).Bounds, R);
         if R <= 0.0 then
            Locate (F, T, P, Leaf, W, DW, Result);
            if Result /= Success then return; end if;
            for J in 0 .. 7 loop
               for K in Axis loop Gradient (K) := Gradient (K) + DW (J)(K)*T (Leaf).Coeff (J); end loop;
            end loop;
         else
            for K in Axis loop
               P := X; P (K) := P (K) + 1.0e-8;
               Oct_Value (F, T, P, C, Result);
               if Result /= Success then return; end if;
               Gradient (K) := (C - Value) / 1.0e-8;
            end loop;
         end if;
         return;
      end if;
      case F.Geometry.Kind is
         when Plane => Value := X (2); Gradient (2) := 1.0;
         when Sphere | Capsule =>
            A := X;
            if F.Geometry.Kind = Capsule then A (2) := X (2) - Clip (X (2), -S (1), S (1)); end if;
            N := Norm (A); Value := N - S (0);
            if Need_Gradient then
               if N = 0.0 then return; end if;
               if F.Geometry.Kind = Sphere then Gradient := Scale (A, 1.0 / N);
               else for K in Axis loop Gradient (K) := A (K) / N; end loop; end if;
            end if;
         when Ellipsoid =>
            if (for some Q of S => Q < 1.0e-10) then return; end if;
            for K in Axis loop A (K) := X (K)/S (K); B (K) := A (K)/S (K); end loop;
            N := Norm (A); M := Norm (B);
            if M = 0.0 then return; end if;
            Value := N * (N - 1.0) / M;
            if Need_Gradient then
               if N = 0.0 then return; end if;
               DF0 := (2.0 * N - 1.0) * (1.0/M);
               DF1 := ((N * (N - 1.0)) * (1.0/M)) * (1.0/M);
               for K in Axis loop
                  G0 (K) := B (K) * (1.0/N);
                  G1 (K) := B (K) * (1.0/M) / (S (K)*S (K));
                  Gradient (K) := G0 (K)*DF0 - G1 (K)*DF1;
               end loop;
               Gradient := Unit (Gradient);
            end if;
         when Cylinder =>
            R := Sqrt (X (0)*X (0) + X (1)*X (1)); E := abs X (2);
            A := [R - S (0), E - S (1), 0.0];
            B := [Real'Max (A (0), 0.0), Real'Max (A (1), 0.0), 0.0];
            Value := Real'Min (Real'Max (A (0), A (1)), 0.0) + Sqrt (B (0)*B (0) + B (1)*B (1));
            if Need_Gradient then
               G0 := [X (0)/Real'Max (R, 1.0/Max_Val), X (1)/Real'Max (R, 1.0/Max_Val),
                      X (2)/Real'Max (E, 1.0/Max_Val)];
               if Real'Max (A (0), A (1)) < 0.0 then
                  if A (0) > A (1) then Gradient := [G0 (0), G0 (1), 0.0];
                  else Gradient := [0.0, 0.0, G0 (2)]; end if;
               else
                  C := Real'Max (Sqrt (B (0)*B (0) + B (1)*B (1)), 1.0/Max_Val);
                  Gradient := [G0 (0)*B (0)/C, G0 (1)*B (0)/C, G0 (2)*B (1)/C];
               end if;
            end if;
         when Box =>
            for K in Axis loop A (K) := abs X (K) - S (K); B (K) := Real'Max (A (K), 0.0); end loop;
            if (for all Q of A => Q < 0.0) then
               for K in Axis loop B (K) := -S (K)/A (K); end loop;
               B := Unit (B);
               for K in Axis loop if X (K) < 0.0 then B (K) := -B (K); end if; end loop;
               if (for some Q of B => Q = 0.0) then return; end if;
               Value := -Real'Min (-A (0)/abs B (0), Real'Min (-A (1)/abs B (1), -A (2)/abs B (2))) * Norm (B);
               if Need_Gradient then Gradient := B; end if;
            else
               N := Norm (B); Value := N + Real'Min (Real'Max (A (0), Real'Max (A (1), A (2))), 0.0);
               if Need_Gradient then
                  if N = 0.0 then return; end if;
                  for K in Axis loop
                     if A (K) > 0.0 then Gradient (K) := (B (K)/N * X (K))/abs X (K); end if;
                  end loop;
               end if;
            end if;
      end case;
      if Value not in -1.0e100 .. 1.0e100 or else (for some Q of Gradient => Q not in -1.0e100 .. 1.0e100) then
         Value := 0.0; Gradient := Zero; return;
      end if;
      Result := Success;
   end Evaluate;
end MJ.SDF_Fields;

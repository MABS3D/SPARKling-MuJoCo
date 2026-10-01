with MJ.Rigid_Math; use MJ.Rigid_Math;

package body MJ.Rigid_Simplex with SPARK_Mode is
   function Same (A, B : Real) return Boolean is
     ((A > 0.0 and B > 0.0) or (A < 0.0 and B < 0.0));

   function Determinant (A, B, C : Vec) return Real is
     (A (0)*(B (1)*C (2)-B (2)*C (1))
      +A (1)*(B (2)*C (0)-B (0)*C (2))
      +A (2)*(B (0)*C (1)-B (1)*C (0)));

   procedure Projection (A, B, C : Vec; P : out Vec; Degenerate : out Boolean) is
      D21 : constant Vec := Sub (B, A);
      D31 : constant Vec := Sub (C, A);
      D32 : constant Vec := Sub (C, B);
      N : Vec;
      NV, NN : Real;
   begin
      P := Zero; Degenerate := False;
      N := Cross (D32, D21); NV := Dot (N, B); NN := Dot (N, N);
      if NN = 0.0 then Degenerate := True; return; end if;
      if NV /= 0.0 and NN > Min_Val then P := Scale (N, NV/NN); return; end if;
      N := Cross (D21, D31); NV := Dot (N, A); NN := Dot (N, N);
      if NN = 0.0 then Degenerate := True; return; end if;
      if NV /= 0.0 and NN > Min_Val then P := Scale (N, NV/NN); return; end if;
      N := Cross (D31, D32); NV := Dot (N, C); NN := Dot (N, N);
      if NN = 0.0 then Degenerate := True; return; end if;
      P := Scale (N, NV/NN);
   end Projection;

   function Combination (V : Vertices; L : Coefficients) return Vec is
     ([((L (0)*V (0) (0)+L (1)*V (1) (0))+L (2)*V (2) (0))+L (3)*V (3) (0),
       ((L (0)*V (0) (1)+L (1)*V (1) (1))+L (2)*V (2) (1))+L (3)*V (3) (1),
       ((L (0)*V (0) (2)+L (1)*V (1) (2))+L (2)*V (2) (2))+L (3)*V (3) (2)]);

   procedure Segment (A, B : Vec; L : out Coefficients) is
      D : constant Vec := Sub (B, A);
      DD : constant Real := Dot (D, D);
      P : Vec;
      Mu, C1, C2 : Real;
      K : Axis := 0;
   begin
      L := [0.0, 1.0, 0.0, 0.0];
      --  Duplicate vertices are retained as the newest vertex, without 0/0.
      if DD = 0.0 then return; end if;
      P := Add (B, Scale (D, -(Dot (B, D)/DD)));
      Mu := A (0)-B (0);
      for I in 1 .. 2 loop
         if abs (A (I)-B (I)) >= abs Mu then Mu := A (I)-B (I); K := I; end if;
      end loop;
      C1 := P (K)-B (K); C2 := A (K)-P (K);
      if Same (Mu, C1) and Same (Mu, C2) then L (0) := C1/Mu; L (1) := C2/Mu; end if;
   end Segment;

   procedure Affine (A, B, C, P : Vec; Cof : out Vec; Minor : out Real) is
      Minors : constant Vec :=
        [B (1)*C (2)-B (2)*C (1)-A (1)*C (2)+A (2)*C (1)+A (1)*B (2)-A (2)*B (1),
         B (0)*C (2)-B (2)*C (0)-A (0)*C (2)+A (2)*C (0)+A (0)*B (2)-A (2)*B (0),
         B (0)*C (1)-B (1)*C (0)-A (0)*C (1)+A (1)*C (0)+A (0)*B (1)-A (1)*B (0)];
      X, Y : Axis;
   begin
      if abs Minors (0) >= abs Minors (1) and abs Minors (0) >= abs Minors (2) then
         Minor := Minors (0); X := 1; Y := 2;
      elsif abs Minors (1) >= abs Minors (2) then Minor := Minors (1); X := 0; Y := 2;
      else Minor := Minors (2); X := 0; Y := 1; end if;
      Cof := [P (X)*B (Y)+P (Y)*C (X)+B (X)*C (Y)-P (X)*C (Y)-P (Y)*B (X)-C (X)*B (Y),
              P (X)*C (Y)+P (Y)*A (X)+C (X)*A (Y)-P (X)*A (Y)-P (Y)*C (X)-A (X)*C (Y),
              P (X)*A (Y)+P (Y)*B (X)+A (X)*B (Y)-P (X)*B (Y)-P (Y)*A (X)-B (X)*A (Y)];
   end Affine;

   procedure Triangle (A, B, C : Vec; L : out Coefficients) is
      P, Cof, X : Vec;
      M, Best, Dist : Real;
      Degenerate : Boolean;
      Trial : Coefficients;
   begin
      Projection (A, B, C, P, Degenerate);
      if Degenerate then Segment (A, B, L); return; end if;
      Affine (A, B, C, P, Cof, M);
      L := [others => 0.0];
      if Same (M, Cof (0)) and Same (M, Cof (1)) and Same (M, Cof (2)) then
         L := [Cof (0)/M, Cof (1)/M, Cof (2)/M, 0.0]; return;
      end if;
      Best := Real'Last;
      if not Same (M, Cof (0)) then
         Segment (B, C, Trial); X := Add (Scale (B, Trial (0)), Scale (C, Trial (1)));
         Best := Dot (X, X); L := [0.0, Trial (0), Trial (1), 0.0];
      end if;
      if not Same (M, Cof (1)) then
         Segment (A, C, Trial); X := Add (Scale (A, Trial (0)), Scale (C, Trial (1))); Dist := Dot (X, X);
         if Dist < Best then Best := Dist; L := [Trial (0), 0.0, Trial (1), 0.0]; end if;
      end if;
      if not Same (M, Cof (2)) then
         Segment (A, B, Trial); X := Add (Scale (A, Trial (0)), Scale (B, Trial (1))); Dist := Dot (X, X);
         if Dist < Best then L := [Trial (0), Trial (1), 0.0, 0.0]; end if;
      end if;
   end Triangle;

   procedure Closest (V : Vertices; N : Positive; L : out Coefficients) is
      Cof : Coefficients;
      Det, Best, Dist : Real;
      Trial : Coefficients;
      Face : Vertices := [others => Zero];
      X : Vec;
      K : Natural;
   begin
      if N = 1 then L := [1.0, 0.0, 0.0, 0.0]; return;
      elsif N = 2 then Segment (V (0), V (1), L); return;
      elsif N = 3 then Triangle (V (0), V (1), V (2), L); return; end if;
      Cof := [-Determinant (V (1), V (2), V (3)), Determinant (V (0), V (2), V (3)),
              -Determinant (V (0), V (1), V (3)), Determinant (V (0), V (1), V (2))];
      Det := ((Cof (0)+Cof (1))+Cof (2))+Cof (3);
      if (for all C0 of Cof => Same (Det, C0)) then
         L := [Cof (0)/Det, Cof (1)/Det, Cof (2)/Det, Cof (3)/Det]; return;
      end if;
      Best := Real'Last; L := [others => 0.0];
      for I in 0 .. 3 loop
         if not Same (Det, Cof (I)) then
            K := 0;
            for J in 0 .. 3 loop if J /= I then Face (K) := V (J); K := K+1; end if; end loop;
            Triangle (Face (0), Face (1), Face (2), Trial); X := Combination (Face, Trial); Dist := Dot (X, X);
            if Dist < Best then
               Best := Dist; K := 0;
               for J in 0 .. 3 loop
                  if J = I then L (J) := 0.0; else L (J) := Trial (K); K := K+1; end if;
               end loop;
            end if;
         end if;
      end loop;
   end Closest;

   function Same_Side (A, B, C, D : Vec) return Boolean is
      N : constant Vec := Cross (Sub (B, A), Sub (C, A));
   begin
      return Same (Dot (N, Sub (D, A)), Dot (N, Scale (A, -1.0)));
   end Same_Side;
   function Strict_Tetrahedron (A, B, C, D : Vec) return Boolean is
     (Same_Side (A, B, C, D) and Same_Side (B, C, D, A)
      and Same_Side (C, D, A, B) and Same_Side (D, A, B, C));
end MJ.Rigid_Simplex;

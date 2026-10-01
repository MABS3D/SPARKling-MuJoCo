--  Floating-point CCD adapted from MuJoCo 3.14.0 (Apache-2.0).
--  This API recovers the pair decision, not EPA witnesses or contact manifolds.
with MJ.Rigid_Math; use MJ.Rigid_Math;
with MJ.Rigid_Support; use MJ.Rigid_Support;
with MJ.Rigid_Simplex; use MJ.Rigid_Simplex;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;

package body MJ.Rigid_CCD with SPARK_Mode is
   type Simplex_Result is record
      V : Vertices := [others => Zero];
      N : Natural range 0 .. 4 := 0;
      Distance : Real := 0.0;
      Separated : Boolean := False;
      Exhausted : Boolean := False;
   end record;

   function Support_Point (S : Shape; P : Pose; D : Vec; Margin : Real; Shrink : Boolean) return Vec is
      V : Vec;
   begin
      if Shrink and S.Kind = Sphere then return P.Position;
      elsif Shrink and S.Kind = Capsule then
         V := Column (P.Rotation, 2);
         return Add (P.Position, Scale (V, (if Dot (V, D) >= 0.0 then S.Size (1) else -S.Size (1))));
      end if;
      V := Support (S, P, D);
      if Margin > 0.0 then V := Add (V, Scale (D, 0.5*Margin)); end if;
      return V;
   end Support_Point;

   function Minkowski (A, B : Shape; PA, PB : Pose; D : Vec; Margin : Real; Shrink : Boolean) return Vec is
     (Sub (Support_Point (A, PA, D, Margin, Shrink), Support_Point (B, PB, Scale (D, -1.0), Margin, Shrink)));

   procedure Intersection (A, B : Shape; PA, PB : Pose; Margin : Real;
                           V : in out Vertices; K : in out Natural; Kmax : Natural;
                           Result : out Integer) with Always_Terminates is
      type Index_Array is array (Natural range 0 .. 3) of Natural range 0 .. 3;
      S : Index_Array := [0, 1, 2, 3];
      Normals : Vertices := [others => Zero];
      Dist : Coefficients := [others => 0.0];
      I, J, Worst, Swap : Natural;
      procedure Signed_Distance (X, Y, Z : Vec; N : out Vec; Distance : out Real) is
         Len2 : Real;
      begin
         N := Cross (Sub (Z, X), Sub (Y, X)); Len2 := Dot (N, N);
         if Len2 > Min_Val*Min_Val and Len2 < 1.0e20 then
            N := Scale (N, 1.0/Sqrt (Len2)); Distance := Dot (N, X); return;
         end if;
         Distance := 1.0e100;
      end Signed_Distance;
   begin
      Result := -1;
      while K < Kmax loop
         pragma Loop_Variant (Increases => K);
         Signed_Distance (V (S (2)), V (S (1)), V (S (3)), Normals (0), Dist (0));
         Signed_Distance (V (S (0)), V (S (2)), V (S (3)), Normals (1), Dist (1));
         Signed_Distance (V (S (1)), V (S (0)), V (S (3)), Normals (2), Dist (2));
         Signed_Distance (V (S (0)), V (S (1)), V (S (2)), Normals (3), Dist (3));
         if (for some X of Dist => X = 0.0) then return; end if;
         I := (if Dist (0) < Dist (1) then 0 else 1); J := (if Dist (2) < Dist (3) then 2 else 3);
         Worst := (if Dist (I) < Dist (J) then I else J);
         if Dist (Worst) > 0.0 then
            V := [V (S (0)), V (S (1)), V (S (2)), V (S (3))]; Result := 1; return;
         end if;
         V (S (Worst)) := Minkowski (A, B, PA, PB, Normals (Worst), Margin, False);
         if Dot (Normals (Worst), V (S (Worst))) < 0.0 then Result := 0; return; end if;
         I := (Worst+1) mod 4; J := (Worst+2) mod 4; Swap := S (I); S (I) := S (J); S (J) := Swap;
         K := K+1;
      end loop;
   end Intersection;

   function GJK (A, B : Shape; PA, PB : Pose; Margin : Real; O : Options; Shrink : Boolean; Cutoff : Real)
     return Simplex_Result is
      R : Simplex_Result;
      L : Coefficients := [others => 0.0];
      X : Vec := Sub (PA.Position, PB.Position);
      W, D : Vec;
      Len : Real := Norm (X);
      Prev : Real := 0.0;
      NN : Natural range 0 .. 4;
      Lower : Real;
      K : Natural := 0;
      Backup : Boolean := Cutoff = 0.0;
      Ret : Integer;
      Vbackup : Vertices;
   begin
      while K < O.Iterations loop
         pragma Loop_Variant (Increases => K);
         exit when Len < O.Tolerance or else abs (Prev-Len) < Min_Val;
         D := Scale (Scale (X, 1.0/Len), -1.0);
         W := Minkowski (A, B, PA, PB, D, Margin, Shrink);
         exit when Dot (X, Sub (X, W)) < 0.5*O.Tolerance*O.Tolerance;
         Lower := Dot (X, W);
         if Lower > 0.0 and then (Cutoff = 0.0 or else Lower >= Cutoff*Len) then
            R.Separated := True; R.N := 0; R.Distance := 1.0e100; return R;
         end if;
         R.V (R.N) := W;
         if R.N = 3 and Backup then
            Vbackup := R.V;
            Intersection (A, B, PA, PB, Margin, Vbackup, K, O.Iterations, Ret);
            if Ret /= -1 then
               R.Separated := Ret = 0; R.N := (if Ret = 1 then 4 else 0);
               R.Distance := (if Ret = 1 then 0.0 else 1.0e100); R.V := Vbackup; return R;
            end if;
            Backup := False;
         end if;
         R.N := R.N+1;
         Closest (R.V, R.N, L); NN := 0;
         for I in 0 .. R.N-1 loop
            if L (I) /= 0.0 then R.V (NN) := R.V (I); L (NN) := L (I); NN := NN+1; end if;
         end loop;
         R.N := NN;
         if R.N = 0 then R.Separated := True; R.Distance := 1.0e100; return R; end if;
         for I in R.N .. 3 loop R.V (I) := Zero; L (I) := 0.0; end loop;
         X := Combination (R.V, L); Prev := Len; Len := Norm (X);
         exit when R.N = 4;
         K := K+1;
      end loop;
      R.Exhausted := K >= O.Iterations;
      if Len > 0.0 then
         W := Minkowski (A, B, PA, PB, Scale (Scale (X, 1.0/Len), -1.0), Margin, Shrink);
         R.Separated := Dot (X, W) > 0.0;
      end if;
      R.Distance := (if R.N = 4 and not R.Separated then 0.0 else Len);
      return R;
   end GJK;

   function Face_Distance (A, B, C : Vec) return Real is
      P : Vec;
      Degenerate : Boolean;
   begin
      Projection (C, B, A, P, Degenerate);
      return (if Degenerate then 0.0 else Dot (P, P));
   end Face_Distance;

   function Triangle_Point (A, B, C, P : Vec) return Boolean is
      Cof, X : Vec;
      M : Real;
   begin
      Affine (A, B, C, P, Cof, M);
      if M = 0.0 then return False; end if;
      Cof := [Cof (0)/M, Cof (1)/M, Cof (2)/M];
      if (for some F of Cof => F < 0.0) then return False; end if;
      X := Add (Add (Scale (A, Cof (0)), Scale (B, Cof (1))), Scale (C, Cof (2)));
      return Norm (Sub (X, P)) < Min_Val;
   end Triangle_Point;

   function Polytope_3 (A, B : Shape; PA, PB : Pose; V1, V2, V3 : Vec; Margin, Distance : Real) return Boolean is
      N : constant Vec := Cross (Sub (V2, V1), Sub (V3, V1));
      Len : constant Real := Norm (N);
      V4, V5 : Vec;
   begin
      if Len < Min_Val then return False; end if;
      V5 := Minkowski (A, B, PA, PB, Scale (Scale (N, -1.0), 1.0/Len), Margin, False);
      V4 := Minkowski (A, B, PA, PB, Scale (N, 1.0/Len), Margin, False);
      if Triangle_Point (V1, V2, V3, V4) or else Triangle_Point (V1, V2, V3, V5) then return False; end if;
      if Distance > 10.0*Min_Val and then
        not Strict_Tetrahedron (V1, V2, V3, V4) and then not Strict_Tetrahedron (V1, V2, V3, V5) then return False; end if;
      return Face_Distance (V4, V1, V2) >= Min_Val*Min_Val
        and then Face_Distance (V4, V3, V1) >= Min_Val*Min_Val
        and then Face_Distance (V4, V2, V3) >= Min_Val*Min_Val
        and then Face_Distance (V5, V2, V1) >= Min_Val*Min_Val
        and then Face_Distance (V5, V1, V3) >= Min_Val*Min_Val
        and then Face_Distance (V5, V3, V2) >= Min_Val*Min_Val;
   end Polytope_3;

   function Polytope_2 (A, B : Shape; PA, PB : Pose; V1, V2 : Vec; Margin, Distance : Real) return Boolean is
      Diff : constant Vec := Sub (V2, V1);
      Len : constant Real := Norm (Diff);
      K : Axis := 0;
      E : Vec := Zero;
      U, D1, D2, D3, V3, V4, V5 : Vec;
      R : Matrix;
      Vol1, Vol2, Vol3 : Real;
      function Check (X, Y, Z : Vec) return Boolean is
        (Face_Distance (X, Y, Z) >= Min_Val*Min_Val);
   begin
      if Len = 0.0 then return False; end if;
      for I in 1 .. 2 loop if abs Diff (I) < abs Diff (K) then K := I; end if; end loop;
      E (K) := 1.0; D1 := Cross (E, Diff); U := [Diff (0)/Len, Diff (1)/Len, Diff (2)/Len];
      R := [-0.5+U (0)*U (0)*1.5, U (0)*U (1)*1.5-U (2)*0.86602540378, U (0)*U (2)*1.5+U (1)*0.86602540378,
             U (1)*U (0)*1.5+U (2)*0.86602540378, -0.5+U (1)*U (1)*1.5, U (1)*U (2)*1.5-U (0)*0.86602540378,
             U (2)*U (0)*1.5-U (1)*0.86602540378, U (2)*U (1)*1.5+U (0)*0.86602540378, -0.5+U (2)*U (2)*1.5];
      D2 := Transform (R, D1); D3 := Transform (R, D2);
      V3 := Minkowski (A, B, PA, PB, Unit (D1), Margin, False);
      V4 := Minkowski (A, B, PA, PB, Unit (D2), Margin, False);
      V5 := Minkowski (A, B, PA, PB, Unit (D3), Margin, False);
      if not Check (V1, V3, V4) then return Polytope_3 (A, B, PA, PB, V1, V3, V4, Margin, Distance); end if;
      if not Check (V1, V5, V3) then return Polytope_3 (A, B, PA, PB, V1, V5, V3, Margin, Distance); end if;
      if not Check (V1, V4, V5) then return Polytope_3 (A, B, PA, PB, V1, V4, V5, Margin, Distance); end if;
      if not Check (V2, V4, V3) then return Polytope_3 (A, B, PA, PB, V2, V4, V3, Margin, Distance); end if;
      if not Check (V2, V3, V5) then return Polytope_3 (A, B, PA, PB, V2, V3, V5, Margin, Distance); end if;
      if not Check (V2, V5, V4) then return Polytope_3 (A, B, PA, PB, V2, V5, V4, Margin, Distance); end if;
      Vol1 := Determinant (Sub (V3, V1), Sub (V4, V1), Diff);
      Vol2 := Determinant (Sub (V4, V1), Sub (V5, V1), Diff);
      Vol3 := Determinant (Sub (V5, V1), Sub (V3, V1), Diff);
      return (Vol1 >= 0.0 and Vol2 >= 0.0 and Vol3 >= 0.0) or (Vol1 <= 0.0 and Vol2 <= 0.0 and Vol3 <= 0.0);
   end Polytope_2;

   function Convex (A, B : Shape; PA, PB : Pose; Margin : Real; O : Options) return Decision is
      R : Simplex_Result;
      Full_Margin : Real := 0.0;
      function P3 (I, J, K : Natural) return Boolean is
        (Polytope_3 (A, B, PA, PB, R.V (I), R.V (J), R.V (K), Margin, 0.0));
   begin
      --  All six bounded primitives contain their centre; positive dimensions
      --  make equal-centre non-plane pairs overlap in their interiors. Native
      --  3.14.0 CCD instead exits with no simplex here (upstream false negative).
      if PA.Position = PB.Position then return Contact; end if;
      if A.Kind in Sphere | Capsule or B.Kind in Sphere | Capsule then
         if A.Kind in Sphere | Capsule then Full_Margin := A.Size (0)+0.5*Margin; end if;
         if B.Kind in Sphere | Capsule then Full_Margin := Full_Margin+(B.Size (0)+0.5*Margin); end if;
         R := GJK (A, B, PA, PB, Margin, O, True, Full_Margin);
         if R.Exhausted and not R.Separated and R.N < 4 then return Unresolved; end if;
         if R.Distance > O.Tolerance then return (if R.Distance-Full_Margin < 0.0 then Contact else Separated); end if;
      end if;
      R := GJK (A, B, PA, PB, Margin, O, False, 0.0);
      if R.Exhausted and not R.Separated and R.N < 4 then return Unresolved; end if;
      if R.Distance > O.Tolerance or R.Separated or R.N <= 1 then return Separated; end if;
      if R.N = 2 then return (if Polytope_2 (A, B, PA, PB, R.V (0), R.V (1), Margin, 0.0) then Contact else Separated);
      elsif R.N = 3 then return (if P3 (0, 1, 2) then Contact else Separated); end if;
      if Face_Distance (R.V (0), R.V (1), R.V (2)) < Min_Val*Min_Val then return (if P3 (0, 1, 2) then Contact else Separated);
      elsif Face_Distance (R.V (0), R.V (3), R.V (1)) < Min_Val*Min_Val then return (if P3 (0, 3, 1) then Contact else Separated);
      elsif Face_Distance (R.V (0), R.V (2), R.V (3)) < Min_Val*Min_Val then return (if P3 (0, 2, 3) then Contact else Separated);
      elsif Face_Distance (R.V (3), R.V (2), R.V (1)) < Min_Val*Min_Val then return (if P3 (3, 2, 1) then Contact else Separated); end if;
      return (if Strict_Tetrahedron (R.V (0), R.V (1), R.V (2), R.V (3)) then Contact else Separated);
   end Convex;
end MJ.Rigid_CCD;

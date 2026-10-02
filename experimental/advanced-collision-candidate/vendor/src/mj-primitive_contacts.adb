--  Complete geometric precontacts, adapted from MuJoCo 3.14.0 (Apache-2.0).
with MJ.Rigid_Math; use MJ.Rigid_Math;
with MJ.Rigid_Support;
with MJ.Rigid_Primitives;
with MJ.Contact_Perturbations;
with Interfaces;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;

package body MJ.Primitive_Contacts with SPARK_Mode is
   procedure Spheres (A, B : Shape; PA, PB : Pose; Margin : Real; M : in out Manifold) is
      Diff : constant Vec := Sub (PA.Position, PB.Position);
      Length2 : constant Real := Dot (Diff, Diff);
      Limit : constant Real := (Margin+A.Size (0))+B.Size (0);
      Length, Distance : Real;
      Normal : Vec;
   begin
      M.Length := 0;
      if Length2 > Limit*Limit then return; end if;
      Length := Sqrt (Length2); Distance := (Length-A.Size (0))-B.Size (0);
      if Length < Min_Val then Normal := Unit (Cross (Column (PA.Rotation, 2), Column (PB.Rotation, 2)));
      else Normal := Scale (Scale (Diff, -1.0), 1.0/Length); end if;
      M.Items (0) := (Distance => Distance, Normal => Normal, Tangent => Zero,
                      Position => Add (Scale (Normal, A.Size (0)+Distance/2.0), PA.Position));
      M.Length := 1;
   end Spheres;

   procedure Plane_Sphere (PPlane, PSphere : Pose; Radius, Margin : Real; M : in out Manifold) is
      N : constant Vec := Column (PPlane.Rotation, 2);
      D : constant Real := Dot (Sub (PSphere.Position, PPlane.Position), N);
      Dist : constant Real := D-Radius;
   begin
      M.Length := 0;
      if D > Margin+Radius then return; end if;
      M.Items (0) := (Distance => Dist, Normal => N, Tangent => Zero,
                      Position => Add (PSphere.Position, Scale (N, -Dist/2.0-Radius)));
      M.Length := 1;
   end Plane_Sphere;

   procedure Plane_Shape (B : Shape; PA, PB : Pose; Margin : Real; M : in out Manifold) is
      Normal : constant Vec := Column (PA.Rotation, 2);
      Axis_Z, Segment, Vector, Sideways, Corner, Local_Corner, Point : Vec;
      Prj_Axis, Dist0, Len2, Prj_Vector, Dist, Prj_Side, Relative_Dist : Real;
      P : Pose;
      Trial : Manifold;
      procedure Emit (Position : Vec; Distance : Real; Tangent : Vec := Zero) is
      begin
         M.Items (M.Length) := (Distance => Distance, Position => Position, Normal => Normal, Tangent => Tangent);
         M.Length := M.Length+1;
      end Emit;
   begin
      M.Length := 0;
      case B.Kind is
         when Plane => null;
         when Sphere => Plane_Sphere (PA, PB, B.Size (0), Margin, M);
         when Capsule =>
            Axis_Z := Column (PB.Rotation, 2); Segment := Scale (Axis_Z, B.Size (1)); P := PB;
            for Sign in reverse -1 .. 1 loop
               if Sign /= 0 then
                  P.Position := (if Sign = 1 then Add (PB.Position, Segment) else Sub (PB.Position, Segment));
                  Plane_Sphere (PA, P, B.Size (0), Margin, Trial);
                  if Trial.Length > 0 then Trial.Items (0).Tangent := Axis_Z; M.Items (M.Length) := Trial.Items (0); M.Length := M.Length+1; end if;
               end if;
            end loop;
         when Cylinder =>
            Axis_Z := Column (PB.Rotation, 2); Prj_Axis := Dot (Normal, Axis_Z);
            if Prj_Axis > 0.0 then Axis_Z := Scale (Axis_Z, -1.0); Prj_Axis := -Prj_Axis; end if;
            Dist0 := Dot (Sub (PB.Position, PA.Position), Normal);
            Vector := Sub (Scale (Axis_Z, Prj_Axis), Normal); Len2 := Dot (Vector, Vector);
            if Len2 >= Min_Val*Min_Val then Vector := Scale (Vector, B.Size (0)/Sqrt (Len2));
            else Vector := Scale (Column (PB.Rotation, 0), B.Size (0)); end if;
            Prj_Vector := Dot (Vector, Normal); Axis_Z := Scale (Axis_Z, B.Size (1)); Prj_Axis := Prj_Axis*B.Size (1);
            Dist := (Dist0+Prj_Axis)+Prj_Vector;
            if Dist > Margin then return; end if;
            Emit (Add (Add (Add (PB.Position, Vector), Axis_Z), Scale (Normal, -Dist*0.5)), Dist);
            Dist := (Dist0-Prj_Axis)+Prj_Vector;
            if Dist <= Margin then Emit (Add (Sub (Add (PB.Position, Vector), Axis_Z), Scale (Normal, -Dist*0.5)), Dist); end if;
            Prj_Side := -Prj_Vector*0.5; Dist := (Dist0+Prj_Axis)+Prj_Side;
            if Dist <= Margin then
               Sideways := Scale (Unit (Cross (Vector, Axis_Z)), (B.Size (0)*Sqrt (3.0))/2.0);
               Emit (Add (Add (Add (Add (PB.Position, Sideways), Axis_Z), Scale (Vector, -0.5)), Scale (Normal, -Dist*0.5)), Dist);
               Emit (Add (Add (Add (Sub (PB.Position, Sideways), Axis_Z), Scale (Vector, -0.5)), Scale (Normal, -Dist*0.5)), Dist);
            end if;
         when Box =>
            Dist0 := Dot (Sub (PB.Position, PA.Position), Normal);
            for K in 0 .. 7 loop
               for J in Axis loop Local_Corner (J) := (if (K/(2**J)) mod 2 = 1 then B.Size (J) else -B.Size (J)); end loop;
               Corner := Transform (PB.Rotation, Local_Corner); Relative_Dist := Dot (Normal, Corner); Dist := Dist0+Relative_Dist;
               if Dist <= Margin and Relative_Dist <= 0.0 then
                  Emit (Add (Add (Corner, PB.Position), Scale (Normal, -Dist/2.0)), Dist);
                  exit when M.Length = 4;
               end if;
            end loop;
         when Ellipsoid =>
            Point := MJ.Rigid_Support.Support (B, PB, Scale (Normal, -1.0)); Dist := Dot (Normal, Sub (Point, PA.Position));
            if Dist <= Margin then Emit (Add (Point, Scale (Normal, -0.5*Dist)), Dist); end if;
      end case;
   end Plane_Shape;

   procedure Sphere_Capsule (A, B : Shape; PA, PB : Pose; Margin : Real; M : in out Manifold) is
      Axis_Z : constant Vec := Column (PB.Rotation, 2);
      X : constant Real := Clip (Dot (Axis_Z, Sub (PA.Position, PB.Position)), -B.Size (1), B.Size (1));
      P : Pose := PB;
   begin
      P.Position := Add (Scale (Axis_Z, X), PB.Position); Spheres (A, B, PA, P, Margin, M);
   end Sphere_Capsule;

   procedure Sphere_Cylinder (A, B : Shape; PA, PB : Pose; Margin : Real; M : in out Manifold) is
      Axis_Z : constant Vec := Column (PB.Rotation, 2);
      Diff : constant Vec := Sub (PA.Position, PB.Position);
      X : constant Real := Dot (Axis_Z, Diff);
      Along : constant Vec := Scale (Axis_Z, X);
      Radial : Vec := Sub (Diff, Along);
      Radial2 : constant Real := Dot (Radial, Radial);
      Side : Boolean := abs X < B.Size (1);
      Cap : Boolean := Radial2 < B.Size (0)*B.Size (0);
      P : Pose := PB;
      S : Shape := B;
   begin
      if Side and Cap then
         if B.Size (1)-abs X < B.Size (0)-Sqrt (Radial2) then Side := False; else Cap := False; end if;
      end if;
      if Side then P.Position := Add (Along, PB.Position); Spheres (A, B, PA, P, Margin, M);
      elsif Cap then
         P.Position := Add (PB.Position, Scale (Axis_Z, (if X > 0.0 then B.Size (1) else -B.Size (1))));
         if X <= 0.0 then for I in Axis loop P.Rotation (3*I) := -P.Rotation (3*I); P.Rotation (3*I+2) := -P.Rotation (3*I+2); end loop; end if;
         Plane_Sphere (P, PA, A.Size (0), Margin, M); Reverse_Manifold (M);
      else
         Radial := Scale (Radial, B.Size (0)/Sqrt (Radial2));
         P.Position := Add (Add (Scale (Axis_Z, (if X > 0.0 then B.Size (1) else -B.Size (1))), Radial), PB.Position);
         S.Size (0) := 0.0; Spheres (A, S, PA, P, Margin, M);
      end if;
   end Sphere_Cylinder;

   procedure Sphere_Box (A, B : Shape; PA, PB : Pose; Margin : Real; M : in out Manifold) is
      Center : constant Vec := Local (PB.Rotation, Sub (PA.Position, PB.Position));
      Clamped : Vec;
      Diff, Position, Deepest, Normal : Vec;
      Length, Closest, Dist, Candidate : Real;
      K : Natural := 0;
   begin
      M.Length := 0;
      for I in Axis loop Clamped (I) := Clip (Center (I), -B.Size (I), B.Size (I)); end loop;
      Diff := Sub (Clamped, Center); Length := Norm (Diff);
      Diff := (if Length < Min_Val then [1.0, 0.0, 0.0] else Scale (Diff, 1.0/Length));
      if Length-A.Size (0) > Margin then return; end if;
      if Length <= Min_Val then
         Closest := ((B.Size (0)+B.Size (1))+B.Size (2))*2.0;
         for I in 0 .. 5 loop
            Candidate := abs ((if I mod 2 = 1 then B.Size (I/2) else -B.Size (I/2))-Center (I/2));
            if Closest > Candidate then Closest := Candidate; K := I; end if;
         end loop;
         Normal := Zero; Normal (K/2) := (if K mod 2 = 1 then -1.0 else 1.0);
         Position := Add (Center, Scale (Normal, (A.Size (0)-Closest)/2.0)); Dist := -Closest;
      else
         Deepest := Add (Center, Scale (Diff, A.Size (0))); Position := Add (Scale (Clamped, 0.5), Scale (Deepest, 0.5));
         Normal := Diff; Dist := Length;
      end if;
      M.Items (0) := (Distance => Dist-A.Size (0), Normal => Transform (PB.Rotation, Normal), Tangent => Zero,
                      Position => Add (Transform (PB.Rotation, Position), PB.Position));
      M.Length := 1;
   end Sphere_Box;

   procedure Capsules (A, B : Shape; PA, PB : Pose; Margin : Real; M : in out Manifold) is
      Axis1 : constant Vec := Scale (Column (PA.Rotation, 2), A.Size (1));
      Axis2 : constant Vec := Scale (Column (PB.Rotation, 2), B.Size (1));
      Diff : constant Vec := Sub (PA.Position, PB.Position);
      MA : constant Real := Dot (Axis1, Axis1);
      MB : constant Real := -Dot (Axis1, Axis2);
      MC : constant Real := Dot (Axis2, Axis2);
      U : constant Real := -Dot (Axis1, Diff);
      V : constant Real := Dot (Axis2, Diff);
      Det : constant Real := MA*MC-MB*MB;
      X1, X2 : Real;
      P1 : Pose := PA; P2 : Pose := PB;
      Trial : Manifold;
      procedure Try (T1, T2 : Real) is
      begin
         P1.Position := Add (Scale (Axis1, T1), PA.Position); P2.Position := Add (Scale (Axis2, T2), PB.Position);
         Spheres (A, B, P1, P2, Margin, Trial);
         if Trial.Length > 0 then M.Items (M.Length) := Trial.Items (0); M.Length := M.Length+1; end if;
      end Try;
   begin
      M.Length := 0;
      if MA = 0.0 then Sphere_Capsule (A, B, PA, PB, Margin, M); return;
      elsif MC = 0.0 then Sphere_Capsule (B, A, PB, PA, Margin, M); Reverse_Manifold (M); return; end if;
      if abs Det >= Min_Val then
         X1 := (MC*U-MB*V)/Det; X2 := (MA*V-MB*U)/Det;
         if X1 > 1.0 then X1 := 1.0; X2 := (V-MB)/MC;
         elsif X1 < -1.0 then X1 := -1.0; X2 := (V+MB)/MC; end if;
         if X2 > 1.0 then X2 := 1.0; X1 := Clip ((U-MB)/MA, -1.0, 1.0);
         elsif X2 < -1.0 then X2 := -1.0; X1 := Clip ((U+MB)/MA, -1.0, 1.0); end if;
         Try (X1, X2);
      else
         Try (1.0, Clip ((V-MB)/MC, -1.0, 1.0)); Try (-1.0, Clip ((V+MB)/MC, -1.0, 1.0));
         if M.Length >= 2 then return; end if;
         Try (Clip ((U-MB)/MA, -1.0, 1.0), 1.0);
         if M.Length >= 2 then return; end if;
         Try (Clip ((U+MB)/MA, -1.0, 1.0), -1.0);
      end if;
   end Capsules;

   procedure Boxes (A, B : Shape; PA, PB : Pose; Margin : Real; M : in out Manifold) is
      R, RA : Matrix := [others => 0.0];
      T1 : constant Vec := Local (PA.Rotation, Sub (PB.Position, PA.Position));
      T2 : constant Vec := Local (PB.Rotation, Sub (PA.Position, PB.Position));
      Tol : constant Real := Margin+1.0e-13*(((((A.Size (0)+A.Size (1))+A.Size (2))+B.Size (0))+B.Size (1))+B.Size (2));
      Best, Face_Best : Real := -1.0e100;
      Code, Face_Code : Natural := 0;
      I1, I2, J1, J2 : Axis;
      AX1, AX2, N2, Inv, Rad1, Rad2, Sep, B1, B2 : Real;
      Ref_Size, Inc_Size, T, CX, DU, DV : Vec;
      Inc_R : Matrix := [others => 0.0];
      Ref_Axis, Inc_Axis, AX, AY, BU, BV : Axis;
      Sign, Inc_Sign : Real;
      Edge_Axis, A2, D2, C1, CC, C2, E, P1, P2, Gap, W1, W2 : Vec;
      Amb1, Amb2 : Integer;
      Edge_I, Edge_J : Axis;
      Face_Dot, Denom, S0, T0, Gap2, Best_Gap : Real;
      type Polygon is array (Natural range 0 .. 11) of Vec;
      Cur, Spare, Accepted : Polygon := [others => Zero];
      NAccept : Natural := 0;
      Duplicate : Boolean;
      Dupe2, DX, DY, Distance : Real;
      Ref_Rotation : Matrix;
      Ref_Position, Normal, Local_Position : Vec;
      NP : Natural := 4;

      procedure Clip_Polygon (Coord : Axis; Sgn, Limit : Real) is
         DS : array (Natural range 0 .. 11) of Real := [others => 0.0];
         All_In : Boolean := True;
         Out_N, Next : Natural;
         DP, DQ, F : Real;
      begin
         for K in 0 .. NP-1 loop DS (K) := Sgn*Cur (K) (Coord)-Limit; All_In := All_In and DS (K) <= 0.0; end loop;
         if All_In then return; end if;
         Out_N := 0;
         for K in 0 .. NP-1 loop
            Next := (if K+1 = NP then 0 else K+1); DP := DS (K); DQ := DS (Next);
            if DP <= 0.0 and Out_N < 12 then Spare (Out_N) := Cur (K); Out_N := Out_N+1; end if;
            if ((DP < 0.0 and DQ > 0.0) or (DP > 0.0 and DQ < 0.0)) and Out_N < 12 then
               F := DP/(DP-DQ);
               for I in Axis loop Spare (Out_N) (I) := Cur (K) (I)+F*(Cur (Next) (I)-Cur (K) (I)); end loop;
               Out_N := Out_N+1;
            end if;
         end loop;
         NP := Out_N;
         for K in 0 .. NP-1 loop Cur (K) := Spare (K); end loop;
      end Clip_Polygon;
   begin
      M.Length := 0;
      for I in Axis loop for J in Axis loop
         R (3*I+J) := Dot (Column (PA.Rotation, I), Column (PB.Rotation, J)); RA (3*I+J) := abs R (3*I+J);
      end loop; end loop;
      for I in Axis loop
         Rad2 := (RA (3*I)*B.Size (0)+RA (3*I+1)*B.Size (1))+RA (3*I+2)*B.Size (2);
         Sep := (abs T1 (I)-A.Size (I))-Rad2;
         if Sep > Tol then return; end if;
         if Sep > Best then Best := Sep; Code := I; end if;
      end loop;
      for J in Axis loop
         Rad1 := (RA (J)*A.Size (0)+RA (3+J)*A.Size (1))+RA (6+J)*A.Size (2);
         Sep := (abs T2 (J)-B.Size (J))-Rad1;
         if Sep > Tol then return; end if;
         if Sep > Best then Best := Sep; Code := 3+J; end if;
      end loop;
      Face_Best := Best; Face_Code := Code;
      for I in Axis loop for J in Axis loop
         I1 := (I+1) mod 3; I2 := (I+2) mod 3; J1 := (J+1) mod 3; J2 := (J+2) mod 3;
         AX1 := -R (3*I2+J); AX2 := R (3*I1+J); N2 := AX1*AX1+AX2*AX2;
         if N2 >= 1.0e-16 then
            Inv := 1.0/Sqrt (N2); AX1 := AX1*Inv; AX2 := AX2*Inv;
            Rad1 := A.Size (I1)*abs AX1+A.Size (I2)*abs AX2;
            B1 := AX1*R (3*I1+J1)+AX2*R (3*I2+J1); B2 := AX1*R (3*I1+J2)+AX2*R (3*I2+J2);
            Rad2 := B.Size (J1)*abs B1+B.Size (J2)*abs B2;
            Sep := (abs (AX1*T1 (I1)+AX2*T1 (I2))-Rad1)-Rad2;
            if Sep > Tol then return; end if;
            if Sep-1.0e-6*abs Sep > Best and Sep > Face_Best then Best := Sep; Code := 6+3*I+J; end if;
         end if;
      end loop; end loop;
      if Code >= 6 then
         Edge_I := (Code-6)/3; Edge_J := (Code-6) mod 3;
         I1 := (Edge_I+1) mod 3; I2 := (Edge_I+2) mod 3;
         Edge_Axis := Zero; Edge_Axis (I1) := -R (3*I2+Edge_J); Edge_Axis (I2) := R (3*I1+Edge_J);
         Edge_Axis := Unit (Edge_Axis);
         if Face_Code < 3 then Face_Dot := abs Edge_Axis (Face_Code);
         else Face_Dot := abs Dot (Edge_Axis, Column (R, Face_Code-3)); end if;
         if Face_Dot > 0.99 and Best < Face_Best+0.05*abs Face_Best+Min_Val then Code := Face_Code; Best := Face_Best; end if;
      end if;
      if Code >= 6 then
         Edge_I := (Code-6)/3; Edge_J := (Code-6) mod 3;
         I1 := (Edge_I+1) mod 3; I2 := (Edge_I+2) mod 3;
         J1 := (Edge_J+1) mod 3; J2 := (Edge_J+2) mod 3;
         Edge_Axis := Zero; Edge_Axis (I1) := -R (3*I2+Edge_J); Edge_Axis (I2) := R (3*I1+Edge_J);
         Edge_Axis := Unit (Edge_Axis);
         if Dot (Edge_Axis, T1) < 0.0 then Edge_Axis := Scale (Edge_Axis, -1.0); end if;
         A2 := Local (R, Edge_Axis); Amb1 := -1; Amb2 := -1;
         if abs Edge_Axis (I1) < 1.0e-9 then Amb1 := I1;
         elsif abs Edge_Axis (I2) < 1.0e-9 then Amb1 := I2; end if;
         if abs A2 (J1) < 1.0e-9 then Amb2 := J1;
         elsif abs A2 (J2) < 1.0e-9 then Amb2 := J2; end if;
         D2 := Column (R, Edge_J); B1 := D2 (Edge_I); Denom := 1.0-B1*B1;
         Best_Gap := Real'Last; W1 := Zero; W2 := Zero;
         for V1 in 0 .. (if Amb1 >= 0 then 1 else 0) loop
            for V2 in 0 .. (if Amb2 >= 0 then 1 else 0) loop
               C1 := Zero; C1 (I1) := (if Edge_Axis (I1) >= 0.0 then A.Size (I1) else -A.Size (I1));
               C1 (I2) := (if Edge_Axis (I2) >= 0.0 then A.Size (I2) else -A.Size (I2));
               if Amb1 >= 0 and V1 /= 0 then C1 (Amb1) := -C1 (Amb1); end if;
               CC := Zero; CC (J1) := (if A2 (J1) >= 0.0 then -B.Size (J1) else B.Size (J1));
               CC (J2) := (if A2 (J2) >= 0.0 then -B.Size (J2) else B.Size (J2));
               if Amb2 >= 0 and V2 /= 0 then CC (Amb2) := -CC (Amb2); end if;
               C2 := Add (Transform (R, CC), T1); E := Sub (C2, C1); B2 := Dot (D2, E);
               S0 := (if Denom < Min_Val then 0.0 else (E (Edge_I)-B1*B2)/Denom);
               S0 := Clip (S0, -A.Size (Edge_I), A.Size (Edge_I));
               T0 := Clip (B1*S0-B2, -B.Size (Edge_J), B.Size (Edge_J));
               S0 := Clip (E (Edge_I)+B1*T0, -A.Size (Edge_I), A.Size (Edge_I));
               P1 := C1; P1 (Edge_I) := P1 (Edge_I)+S0; P2 := Add (C2, Scale (D2, T0));
               Gap := Sub (P2, P1); Gap2 := Dot (Gap, Gap);
               if Gap2 < Best_Gap then Best_Gap := Gap2; W1 := P1; W2 := P2; end if;
            end loop;
         end loop;
         Distance := Dot (Sub (W2, W1), Edge_Axis);
         if Distance > Tol then return; end if;
         M.Items (0) := (Distance => Distance, Tangent => Zero,
           Position => Add (Transform (PA.Rotation, Scale (Add (W1, W2), 0.5)), PA.Position),
           Normal => Transform (PA.Rotation, Edge_Axis));
         M.Length := 1; return;
      end if;
      if Code < 3 then Ref_Size := A.Size; Inc_Size := B.Size; T := T1; Inc_R := R; Ref_Axis := Code;
      else
         Ref_Size := B.Size; Inc_Size := A.Size; T := T2; Ref_Axis := Code-3;
         for I in Axis loop for J in Axis loop Inc_R (3*I+J) := R (3*J+I); end loop; end loop;
      end if;
      Sign := (if T (Ref_Axis) >= 0.0 then 1.0 else -1.0); Inc_Axis := 0;
      for K in 1 .. 2 loop
         if abs Inc_R (3*Ref_Axis+K) > abs Inc_R (3*Ref_Axis+Inc_Axis) then Inc_Axis := K; end if;
      end loop;
      Inc_Sign := (if Sign*Inc_R (3*Ref_Axis+Inc_Axis) > 0.0 then -1.0 else 1.0);
      AX := (Ref_Axis+1) mod 3; AY := (Ref_Axis+2) mod 3; BU := (Inc_Axis+1) mod 3; BV := (Inc_Axis+2) mod 3;
      for I in Axis loop
         I1 := (if I = 0 then AX elsif I = 1 then AY else Ref_Axis);
         CX (I) := T (I1)+(Inc_Sign*Inc_Size (Inc_Axis))*Inc_R (3*I1+Inc_Axis);
         DU (I) := Inc_Size (BU)*Inc_R (3*I1+BU); DV (I) := Inc_Size (BV)*Inc_R (3*I1+BV);
      end loop;
      CX (2) := Sign*CX (2)-Ref_Size (Ref_Axis); DU (2) := DU (2)*Sign; DV (2) := DV (2)*Sign;
      for K in 0 .. 3 loop
         B1 := (if K = 0 or K = 3 then 1.0 else -1.0); B2 := (if K < 2 then 1.0 else -1.0);
         for I in Axis loop Cur (K) (I) := (CX (I)+B1*DU (I))+B2*DV (I); end loop;
      end loop;
      Clip_Polygon (0, 1.0, Ref_Size (AX)); Clip_Polygon (0, -1.0, Ref_Size (AX));
      Clip_Polygon (1, 1.0, Ref_Size (AY)); Clip_Polygon (1, -1.0, Ref_Size (AY));
      Dupe2 := 1.0e-14*(Ref_Size (AX)*Ref_Size (AX)+Ref_Size (AY)*Ref_Size (AY));
      for K in 0 .. NP-1 loop
         if Cur (K) (2) <= Margin then
            Duplicate := False;
            for Q in 0 .. NAccept-1 loop
               DX := Accepted (Q) (0)-Cur (K) (0); DY := Accepted (Q) (1)-Cur (K) (1);
               if DX*DX+DY*DY < Dupe2 then Duplicate := True; exit; end if;
            end loop;
            if not Duplicate then Accepted (NAccept) := Cur (K); NAccept := NAccept+1; end if;
         end if;
      end loop;
      Ref_Rotation := (if Code < 3 then PA.Rotation else PB.Rotation);
      Ref_Position := (if Code < 3 then PA.Position else PB.Position);
      Normal := Scale (Column (Ref_Rotation, Ref_Axis), (if Code < 3 then Sign else -Sign));
      for K in 0 .. NAccept-1 loop
         Local_Position := Zero; Local_Position (AX) := Accepted (K) (0); Local_Position (AY) := Accepted (K) (1);
         Local_Position (Ref_Axis) := Sign*(Ref_Size (Ref_Axis)+0.5*Accepted (K) (2));
         M.Items (K) := (Distance => Accepted (K) (2), Normal => Normal, Tangent => Zero,
           Position => Add (Transform (Ref_Rotation, Local_Position), Ref_Position));
      end loop;
      M.Length := NAccept;
   end Boxes;

   --  MuJoCo's endpoint/edge feature selection, omitting its dead diagnostic
   --  arithmetic.  Zero denominators mean no finite clipping bound.
   procedure Capsule_Box (A, B : Shape; PA, PB : Pose; Margin : Real;
                          O : Options; W : in out MJ.Convex_Contacts.Workspace;
                          M : in out Manifold; Result : out Status) is
      use type Interfaces.Unsigned_8;
      Center : constant Vec := Local (PB.Rotation, Sub (PA.Position, PB.Position));
      Direction : constant Vec := Local (PB.Rotation, Column (PA.Rotation, 2));
      Half : constant Vec := Scale (Direction, A.Size (1));
      Axisdir, Corner_Id, Bits : Interfaces.Unsigned_8 := 0;
      Best : Real := Margin+2.0*((((A.Size (0)+A.Size (1))+B.Size (0))+B.Size (1))+B.Size (2));
      Best_Segment, Best_Box : Real := 0.0;
      Second : Real := -4.0;
      Feature, Face : Integer := -4;
      Edge_Axis, AX, AX1, AX2 : Axis := 0;
      Outside, Outside_Axis, S1, S2 : Integer;
      X1, X2, MA, MB, MC, U, V, Det, Inv, Dist, Mul, DE, DP, Bound : Real;
      Point, Clamped, Corner, Diff : Vec;
      P : Pose := PA;
      Trial : Manifold;
      function Ratio (Numerator, Denominator : Real) return Real is
        (if Denominator = 0.0 then 1.0e100 else Numerator/Denominator);
      procedure Try (T : Real) is
      begin
         P.Position := Add (PB.Position, Transform (PB.Rotation, Add (Center, Scale (Half, T))));
         Sphere_Box (A, B, P, PB, Margin, Trial);
         if Trial.Length > 0 then M.Items (M.Length) := Trial.Items (0); M.Length := M.Length+1; end if;
      end Try;
   begin
      M.Length := 0; Result := Success;
      for J in Axis loop if Half (J) > 0.0 then Axisdir := Axisdir+2**J; end if; end loop;
      for Sign in -1 .. 1 loop
         if Sign /= 0 then
            Point := Add (Center, Scale (Half, Real (Sign))); Clamped := Point;
            Outside := 0; Outside_Axis := -1;
            for J in Axis loop
               if Point (J) < -B.Size (J) or Point (J) > B.Size (J) then
                  Outside := Outside+1; Outside_Axis := J; Clamped (J) := Clip (Point (J), -B.Size (J), B.Size (J));
               end if;
            end loop;
            if Outside <= 1 then
               Diff := Sub (Clamped, Point); Dist := Dot (Diff, Diff);
               if Dist < Best then Best := Dist; Best_Segment := Real (Sign); Feature := -2+Sign; Face := Outside_Axis; end if;
            end if;
         end if;
      end loop;
      for J in Axis loop
         for I in Interfaces.Unsigned_8 range 0 .. 7 loop
            if (I and 2**J) = 0 then
               for K in Axis loop Corner (K) := (if (I and 2**K) /= 0 then B.Size (K) else -B.Size (K)); end loop;
               Corner (J) := 0.0; Diff := Sub (Corner, Center);
               MA := B.Size (J)*B.Size (J); MB := -B.Size (J)*Half (J); MC := A.Size (1)*A.Size (1);
               U := -B.Size (J)*Diff (J); V := Dot (Half, Diff); Det := MA*MC-MB*MB;
               if abs Det >= Min_Val then
                  Inv := 1.0/Det; X1 := (MC*U-MB*V)*Inv; X2 := (MA*V-MB*U)*Inv; S1 := 1; S2 := 1;
                  if X1 > 1.0 then X1 := 1.0; S1 := 2; X2 := (V-MB)*(1.0/MC);
                  elsif X1 < -1.0 then X1 := -1.0; S1 := 0; X2 := (V+MB)*(1.0/MC); end if;
                  if X2 > 1.0 then X2 := 1.0; S2 := 2; X1 := (U-MB)*(1.0/MA);
                  elsif X2 < -1.0 then X2 := -1.0; S2 := 0; X1 := (U+MB)*(1.0/MA); end if;
                  if X1 > 1.0 then X1 := 1.0; S1 := 2; elsif X1 < -1.0 then X1 := -1.0; S1 := 0; end if;
                  Diff := Add (Sub (Corner, Center), Scale (Half, -X2)); Diff (J) := Diff (J)+B.Size (J)*X1;
                  Dist := Dot (Diff, Diff);
                  if Dist < Best-Min_Val then
                     Best := Dist; Best_Segment := X2; Best_Box := X1; Feature := S1*3+S2;
                     Corner_Id := I+2**J*Interfaces.Unsigned_8 (Feature/6); Edge_Axis := J;
                  end if;
               end if;
            end if;
         end loop;
      end loop;
      if Feature >= 0 and Feature/3 /= 1 then
         Bits := Axisdir xor Corner_Id;
         if Bits /= 0 and Bits /= 7 then
            if Bits in 1 | 2 | 4 then Mul := 1.0; DE := 1.0-Best_Segment; DP := 1.0+Best_Segment;
            else Mul := -1.0; Bits := 7-Bits; DP := 1.0-Best_Segment; DE := 1.0+Best_Segment; end if;
            AX := (if Bits = 1 then 0 elsif Bits = 2 then 1 else 2); AX1 := (AX+1) mod 3; AX2 := (AX+2) mod 3;
            if Direction (AX)*Direction (AX) > 0.5 then
               Second := Real'Min (DE, Ratio (2.0*B.Size (AX), abs Half (AX)))*Mul;
            else
               Second := Real'Min (Real'Min (DP, Ratio (2.0*B.Size (AX1), abs Half (AX1))), Ratio (2.0*B.Size (AX2), abs Half (AX2)))*(-Mul);
            end if;
         end if;
      elsif Feature >= 0 then
         Bits := (Axisdir xor Corner_Id) and (7-2**Edge_Axis);
         if Bits in 1 | 2 | 4 then
            AX := Edge_Axis; AX1 := (AX+1) mod 3; AX2 := (AX+2) mod 3;
            if abs Direction (AX1) > abs Direction (AX2) then AX1 := AX2; end if; AX2 := 3-AX-AX1;
            if (Bits and 2**AX2) /= 0 then Mul := 1.0; Second := 1.0-Best_Segment;
            else Mul := -1.0; Second := 1.0+Best_Segment; end if;
            Second := Real'Min (Second, Ratio (2.0*B.Size (AX2), abs Half (AX2)));
            Bound := (if ((Axisdir and 2**AX) /= 0) = ((Bits and 2**AX2) /= 0) then 1.0-Best_Box else 1.0+Best_Box);
            Second := Real'Min (Second, Ratio (B.Size (AX)*Bound, abs Half (AX)))*Mul;
         end if;
      elsif Feature /= -4 and Face /= -1 then
         Mul := (if Feature = -3 then 1.0 else -1.0); Second := 2.0; Point := Add (Center, Scale (Half, -Mul));
         for J in Axis loop
            if J /= Face and Half (J) /= 0.0 then
               for Sign in -1 .. 1 loop
                  if Sign /= 0 then
                     Bound := (Real (Sign)*B.Size (J)-Point (J))/Half (J)*Mul;
                     if Bound > 0.0 then Second := Real'Min (Second, Bound); end if;
                  end if;
               end loop;
            end if;
         end loop;
         Second := Second*Mul;
      end if;
      if Feature /= -4 then Try (Best_Segment); if Second > -3.0 then Try (Best_Segment+Second); end if; end if;
      --  Native 3.14.0's feature heuristic can miss an intersecting capsule.
      --  The exact piecewise quadratic admission already covers those cases.
      if M.Length = 0 and then MJ.Rigid_Primitives.Capsule_Box (A, B, PA, PB, Margin) then
         MJ.Convex_Contacts.Generate (As_Object (A), As_Object (B), PA, PB, Empty_Vertices, Margin, O, W, M, Result);
      end if;
   end Capsule_Box;

   procedure Generate (A, B : Shape; PA, PB : Pose; Margin : Real; O : Options;
                       W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status) is
      procedure Ordered (S1, S2 : Shape; P1, P2 : Pose) is
      begin
         if S1.Kind = Plane then Plane_Shape (S2, P1, P2, Margin, M);
         elsif S1.Kind = Sphere and S2.Kind = Sphere then Spheres (S1, S2, P1, P2, Margin, M);
         elsif S1.Kind = Sphere and S2.Kind = Capsule then Sphere_Capsule (S1, S2, P1, P2, Margin, M);
         elsif S1.Kind = Sphere and S2.Kind = Cylinder then Sphere_Cylinder (S1, S2, P1, P2, Margin, M);
         elsif S1.Kind = Sphere and S2.Kind = Box then Sphere_Box (S1, S2, P1, P2, Margin, M);
         elsif S1.Kind = Capsule and S2.Kind = Capsule then Capsules (S1, S2, P1, P2, Margin, M);
         elsif S1.Kind = Capsule and S2.Kind = Box then Capsule_Box (S1, S2, P1, P2, Margin, O, W, M, Result);
         elsif S1.Kind = Box and S2.Kind = Box then Boxes (S1, S2, P1, P2, Margin, M);
         else
            MJ.Convex_Contacts.Generate (As_Object (S1), As_Object (S2), P1, P2, Empty_Vertices, Margin, O, W, M, Result, Multiple => True);
            if Result = Success and M.Length = 1 and (S1.Kind = Capsule or Margin > 0.0) and S1.Kind not in Sphere | Ellipsoid and S2.Kind not in Sphere | Ellipsoid then
               MJ.Contact_Perturbations.Expand (As_Object (S1), As_Object (S2), P1, P2, Empty_Vertices,
                 Margin, MJ.Rigid_Support.Radius (S1), MJ.Rigid_Support.Radius (S2), O, W, M, Result);
            end if;
         end if;
      end Ordered;
   begin
      Result := Success; M.Length := 0;
      if A.Kind <= B.Kind then Ordered (A, B, PA, PB);
      else Ordered (B, A, PB, PA); Reverse_Manifold (M); end if;
      if Result /= Success then M.Length := 0; end if;
      for I in 0 .. M.Length-1 loop
         if not Finite (M.Items (I)) then M.Length := 0; Result := Numeric_Limit; return; end if;
      end loop;
   end Generate;
end MJ.Primitive_Contacts;

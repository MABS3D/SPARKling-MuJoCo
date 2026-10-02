with MJ.Rigid_Math; use MJ.Rigid_Math;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;

package body MJ.Rigid_Primitives with SPARK_Mode is
   function Sphere_Pair (A, B : Vec; RA, RB, Margin : Real) return Boolean is
      D : constant Vec := Sub (A, B);
      R : constant Real := (Margin+RA)+RB;
   begin
      return Dot (D, D) <= R*R;
   end Sphere_Pair;

   function Sphere_Cylinder (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean is
      Axis_B : constant Vec := Column (PB.Rotation, 2);
      V : constant Vec := Sub (PA.Position, PB.Position);
      X : constant Real := Dot (Axis_B, V);
      Axial : Vec := Scale (Axis_B, X);
      Radial : Vec := Sub (V, Axial);
      R2 : constant Real := Dot (Radial, Radial);
      Side : Boolean := abs X < B.Size (1);
      Cap : Boolean := R2 = 0.0 or else R2 < B.Size (0)*B.Size (0);
      Position, N : Vec;
   begin
      if Side and Cap then
         if B.Size (1)-abs X < B.Size (0)-Sqrt (R2) then Side := False; else Cap := False; end if;
      end if;
      if Side then
         return Sphere_Pair (PA.Position, Add (Axial, PB.Position), A.Size (0), B.Size (0), Margin);
      elsif Cap then
         N := (if X > 0.0 then Axis_B else Scale (Axis_B, -1.0));
         Position := Add (PB.Position, Scale (Axis_B, (if X > 0.0 then B.Size (1) else -B.Size (1))));
         return Dot (Sub (PA.Position, Position), N) <= Margin+A.Size (0);
      else
         Radial := Scale (Radial, B.Size (0)/Sqrt (R2));
         Position := Add (Add (Scale (Axis_B, (if X > 0.0 then B.Size (1) else -B.Size (1))), Radial), PB.Position);
         return Sphere_Pair (PA.Position, Position, A.Size (0), 0.0, Margin);
      end if;
   end Sphere_Cylinder;

   function Capsule_Capsule (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean is
      A1 : constant Vec := Scale (Column (PA.Rotation, 2), A.Size (1));
      A2 : constant Vec := Scale (Column (PB.Rotation, 2), B.Size (1));
      D : constant Vec := Sub (PA.Position, PB.Position);
      MA : constant Real := Dot (A1, A1);
      MB : constant Real := -Dot (A1, A2);
      MC : constant Real := Dot (A2, A2);
      U : constant Real := -Dot (A1, D);
      V : constant Real := Dot (A2, D);
      Det : constant Real := MA*MC-MB*MB;
      X1, X2 : Real;
   begin
      if MA = 0.0 then
         X2 := Clip (Dot (Column (PB.Rotation, 2), D), -B.Size (1), B.Size (1));
         return Sphere_Pair (PA.Position, Add (PB.Position, Scale (Column (PB.Rotation, 2), X2)), A.Size (0), B.Size (0), Margin);
      elsif MC = 0.0 then
         X1 := Clip (Dot (Column (PA.Rotation, 2), Scale (D, -1.0)), -A.Size (1), A.Size (1));
         return Sphere_Pair (PB.Position, Add (PA.Position, Scale (Column (PA.Rotation, 2), X1)), B.Size (0), A.Size (0), Margin);
      end if;
      if abs Det >= Min_Val then
         X1 := (MC*U-MB*V)/Det; X2 := (MA*V-MB*U)/Det;
         if X1 > 1.0 then X1 := 1.0; X2 := (V-MB)/MC;
         elsif X1 < -1.0 then X1 := -1.0; X2 := (V+MB)/MC; end if;
         if X2 > 1.0 then X2 := 1.0; X1 := Clip ((U-MB)/MA, -1.0, 1.0);
         elsif X2 < -1.0 then X2 := -1.0; X1 := Clip ((U+MB)/MA, -1.0, 1.0); end if;
         return Sphere_Pair (Add (Scale (A1, X1), PA.Position), Add (Scale (A2, X2), PB.Position), A.Size (0), B.Size (0), Margin);
      else
         X2 := Clip ((V-MB)/MC, -1.0, 1.0);
         if Sphere_Pair (Add (PA.Position, A1), Add (Scale (A2, X2), PB.Position), A.Size (0), B.Size (0), Margin) then return True; end if;
         X2 := Clip ((V+MB)/MC, -1.0, 1.0);
         if Sphere_Pair (Sub (PA.Position, A1), Add (Scale (A2, X2), PB.Position), A.Size (0), B.Size (0), Margin) then return True; end if;
         X1 := Clip ((U-MB)/MA, -1.0, 1.0);
         if Sphere_Pair (Add (Scale (A1, X1), PA.Position), Add (PB.Position, A2), A.Size (0), B.Size (0), Margin) then return True; end if;
         X1 := Clip ((U+MB)/MA, -1.0, 1.0);
         return Sphere_Pair (Add (Scale (A1, X1), PA.Position), Sub (PB.Position, A2), A.Size (0), B.Size (0), Margin);
      end if;
   end Capsule_Capsule;

   function Capsule_Box (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean is
      C : constant Vec := Local (PB.Rotation, Sub (PA.Position, PB.Position));
      D : constant Vec := Scale (Local (PB.Rotation, Column (PA.Rotation, 2)), A.Size (1));
      type Break_Array is array (Natural range 0 .. 7) of Real;
      Breaks : Break_Array := [-1.0, 1.0, others => 0.0];
      N : Natural := 2;
      T, Temp, Mid, Numerator, Denominator, Offset, Best, Dist : Real;
      V : Vec;
      J : Natural;
   begin
      for I in Axis loop
         if D (I) /= 0.0 then
            for Sign in -1 .. 1 loop
               if Sign /= 0 then
                  Temp := Real (Sign)*B.Size (I)-C (I);
                  if Temp >= -abs D (I) and Temp <= abs D (I) then
                     T := Temp/D (I);
                     if T > -1.0 and T < 1.0 then Breaks (N) := T; N := N+1; end if;
                  end if;
               end if;
            end loop;
         end if;
      end loop;
      for I in 1 .. N-1 loop
         Temp := Breaks (I); J := I;
         while J > 0 and then Breaks (J-1) > Temp loop
            pragma Loop_Variant (Decreases => J);
            Breaks (J) := Breaks (J-1); J := J-1;
         end loop;
         Breaks (J) := Temp;
      end loop;
      Best := Real'Last;
      for I in 0 .. N-2 loop
         Mid := 0.5*(Breaks (I)+Breaks (I+1)); Numerator := 0.0; Denominator := 0.0;
         for K in Axis loop
            T := C (K)+Mid*D (K);
            if T > B.Size (K) or T < -B.Size (K) then
               Offset := C (K)-(if T > 0.0 then B.Size (K) else -B.Size (K));
               Numerator := Numerator+D (K)*Offset; Denominator := Denominator+D (K)*D (K);
            end if;
         end loop;
         T := (if Denominator > 0.0 then Clip (-Numerator/Denominator, Breaks (I), Breaks (I+1)) else Mid);
         V := Add (C, Scale (D, T));
         for K in Axis loop V (K) := V (K)-Clip (V (K), -B.Size (K), B.Size (K)); end loop;
         Dist := Dot (V, V); Best := Real'Min (Best, Dist);
      end loop;
      return Sqrt (Best)-A.Size (0) <= Margin;
   end Capsule_Box;

   function Box_Box (A, B : Shape; PA, PB : Pose; Margin : Real) return Boolean is
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
      Cur, Spare : Polygon := [others => Zero];
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
      for I in Axis loop for J in Axis loop
         R (3*I+J) := Dot (Column (PA.Rotation, I), Column (PB.Rotation, J)); RA (3*I+J) := abs R (3*I+J);
      end loop; end loop;
      for I in Axis loop
         Rad2 := (RA (3*I)*B.Size (0)+RA (3*I+1)*B.Size (1))+RA (3*I+2)*B.Size (2);
         Sep := (abs T1 (I)-A.Size (I))-Rad2;
         if Sep > Tol then return False; end if;
         if Sep > Best then Best := Sep; Code := I; end if;
      end loop;
      for J in Axis loop
         Rad1 := (RA (J)*A.Size (0)+RA (3+J)*A.Size (1))+RA (6+J)*A.Size (2);
         Sep := (abs T2 (J)-B.Size (J))-Rad1;
         if Sep > Tol then return False; end if;
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
            if Sep > Tol then return False; end if;
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
         return Dot (Sub (W2, W1), Edge_Axis) <= Tol;
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
      for K in 0 .. NP-1 loop if Cur (K) (2) <= Margin then return True; end if; end loop;
      return False;
   end Box_Box;
end MJ.Rigid_Primitives;

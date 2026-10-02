with MJ.Collision_Poses;
with MJ.Rigid_Math; use MJ.Rigid_Math;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
package body MJ.Flex_Kernels with SPARK_Mode is
   type Vec2 is array (Natural range 0 .. 1) of Real;
   function Area (A, B, C : Vec2) return Real is
     (Sign ((A (0)-C (0))*(B (1)-C (1)) - (B (0)-C (0))*(A (1)-C (1))));
   procedure Segment (P, U, V : Vec2; X : out Vec2; D : out Real) is
      UV : constant Vec2 := [V (0)-U (0), V (1)-U (1)];
      UP : constant Vec2 := [P (0)-U (0), P (1)-U (1)];
      T : constant Real := (UV (0)*UP (0)+UV (1)*UP (1)) / Real'Max (Min_Val, UV (0)*UV (0)+UV (1)*UV (1));
   begin
      if T <= 0.0 then X := U; elsif T >= 1.0 then X := V;
      else X := [U (0)+UV (0)*T, U (1)+UV (1)*T]; end if;
      D := Sqrt ((X (0)-P (0))*(X (0)-P (0))+(X (1)-P (1))*(X (1)-P (1)));
   end Segment;

   procedure Sphere_Triangle (Center : Vec; Radius : Real; V : Triangle_Vertices;
                              Skin, Margin : Real; M : in out Manifold) is
      S : constant Vec := Sub (Center, V (0));
      A : constant Vec := Sub (V (1), V (0));
      B : constant Vec := Sub (V (2), V (0));
      N : constant Vec := Unit (Cross (A, B));
      Dist_S : constant Real := Dot (N, S);
      Bound : constant Real := (Margin+Radius)+Skin;
      Projected, V1, V2, X, Normal : Vec;
      Len, Dist : Real;
      O2 : constant Vec2 := [0.0, 0.0];
      A2, B2, P2 : Vec2;
      Close : array (Natural range 0 .. 2) of Vec2 := [others=>[others=>0.0]];
      D : array (Natural range 0 .. 2) of Real := [others=>0.0];
      Best : Natural;
   begin
      M.Length := 0; if abs Dist_S > Bound then return; end if;
      Projected := Add (S, Scale (N, -Dist_S));
      Len := Norm (A); V1 := Unit (A); V2 := Unit (Cross (N, A));
      A2 := [Len, 0.0]; B2 := [Dot (V1, B), Dot (V2, B)]; P2 := [Dot (V1, Projected), Dot (V2, Projected)];
      if Area (P2, O2, A2) = Area (P2, A2, B2) and Area (P2, A2, B2) = Area (P2, B2, O2) then
         X := Projected;
      else
         Segment (P2,O2,A2,Close (0),D (0)); Segment (P2,A2,B2,Close (1),D (1)); Segment (P2,B2,O2,Close (2),D (2));
         Best := (if D (0)<D (1) and D (0)<D (2) then 0 elsif D (1)<D (2) then 1 else 2);
         X := Add (Scale (V1,Close (Best)(0)),Scale (V2,Close (Best)(1)));
      end if;
      Normal := Sub (X,S); Dist := Norm (Normal); Normal := Unit (Normal);
      if Dist > Bound then return; end if;
      M.Items (0) := (Distance => (Dist-Radius)-Skin, Normal => Normal, Tangent => Zero,
         Position => Add (Center, Scale (Normal, Radius+((Dist-Radius)-Skin)/2.0)));
      M.Length := 1;
   end Sphere_Triangle;

   procedure Box_Triangle (P : Pose; Size : Vec; V : Triangle_Vertices;
                           Skin, Margin : Real; M : in out Manifold) is
      Local_Point, N, Corner : Vec;
      Val, Max_Value, Distance : Real;
      Max_Axis : Axis;
      Temp : Manifold;
   begin
      M.Length := 0;
      for Point of V loop
         Local_Point := Local (P.Rotation,Sub (Point,P.Position)); Max_Axis := 0; Max_Value := abs Local_Point (0)-Size (0);
         for K in 1 .. 2 loop
            Val := abs Local_Point (K)-Size (K);
            if Val > Max_Value then Max_Value := Val; Max_Axis := K; end if;
         end loop;
         if Max_Value-Skin <= Margin and then
           (for all K in Axis => abs Local_Point (K) <= (Size (K)+Margin)+Skin) then
            N := Zero; N (Max_Axis) := (if Local_Point (Max_Axis)>0.0 then 1.0 else -1.0);
            N := Transform (P.Rotation,N); Distance := Max_Value-Skin;
            M.Items (M.Length) := (Normal => N, Distance => Distance, Tangent => Zero,
               Position => Add (Point,Scale (N,-(Skin+Distance*0.5))));
            M.Length := M.Length+1;
         end if;
      end loop;
      for J in 0 .. 7 loop
         for K in Axis loop Corner (K) := (if (J/(2**K)) mod 2=1 then Size (K) else -Size (K)); end loop;
         Corner := Add (Transform (P.Rotation,Corner),P.Position);
         Sphere_Triangle (Corner,0.0,V,Skin,Margin,Temp);
         if Temp.Length>0 then M.Items (M.Length):=Temp.Items (0); M.Length:=M.Length+1; end if;
      end loop;
   end Box_Triangle;

   procedure Capsule_Triangle (P : Pose; Radius, Half_Length : Real; V : Triangle_Vertices;
                               Skin, Margin : Real; M : in out Manifold) is
      Axis_Z : constant Vec := Column (P.Rotation,2);
      P1 : constant Vec := Add (P.Position,Scale (Axis_Z,-Half_Length));
      P2 : constant Vec := Add (P.Position,Scale (Axis_Z,Half_Length));
      AB : constant Vec := Sub (P2,P1);
      Vector, Closest : Vec;
      T, Distance : Real;
      Temp : Manifold;
   begin
      Sphere_Triangle (P1,Radius,V,Skin,Margin,M);
      Sphere_Triangle (P2,Radius,V,Skin,Margin,Temp);
      if Temp.Length>0 then M.Items (M.Length):=Temp.Items (0); M.Length:=M.Length+1; end if;
      if Half_Length=0.0 then return; end if;
      for Point of V loop
         T := Dot (Sub (Point,P1),AB)/((4.0*Half_Length)*Half_Length);
         if T > Min_Val and T < 1.0-Min_Val then
            Closest := Add (P1,Scale (AB,T)); Vector := Sub (Point,Closest);
            Distance := Norm (Vector); Vector := Unit (Vector);
            if Distance <= (Radius+Skin)+Margin then
               M.Items (M.Length) := (Normal=>Vector, Distance=>(Distance-Radius)-Skin, Tangent=>Zero,
                 Position=>Scale (Add (Add (Closest,Point),Scale (Vector,Radius-Skin)),0.5));
               M.Length:=M.Length+1;
            end if;
         end if;
      end loop;
   end Capsule_Triangle;

   procedure Plane_Vertex (V : Triangle_Vertices; Point : Vec; Radius : Real;
                           C : out MJ.Contact_Geometry.Contact; Hit : out Boolean) is
      N : constant Vec := Unit (Cross (Sub (V (1),V (0)),Sub (V (2),V (0))));
      D : constant Real := Dot (Sub (Point,V (0)),N);
   begin
      Hit := D > -2.0*Radius;
      C := (Distance=> -D-2.0*Radius, Normal=>Scale (N,-1.0), Tangent=>Zero,
            Position=>Add (Point,Scale (N,-0.5*D)));
   end Plane_Vertex;

   procedure Capsule_From_Segment (A, B : Vec; Radius : Real; S : out Shape; P : out Pose) is
      D : constant Vec := Sub (A,B);
      VN : constant Vec := Unit (D);
      Axis_Raw : constant Vec := [-VN (1),VN (0),0.0];
      Axis_N : constant Vec := Unit (Axis_Raw);
      Sin_Angle : constant Real := Norm (Axis_Raw);
      Q : MJ.Collision_Poses.Quaternion := [1.0,0.0,0.0,0.0];
      Angle, V : Real;
   begin
      S := (Kind=>Capsule,Size=>[Radius,0.5*Norm (D),0.0],others=><>);
      P := (Position=>Scale (Add (A,B),0.5),others=><>);
      if Sin_Angle < Min_Val then
         if VN (2)<0.0 then Q := [0.0,1.0,0.0,0.0]; end if;
      else
         Angle := Arctan (Sin_Angle,VN (2)); V := Sin (Angle*0.5);
         Q := [Cos (Angle*0.5),Axis_N (0)*V,Axis_N (1)*V,Axis_N (2)*V];
      end if;
      P.Rotation := MJ.Collision_Poses.To_Matrix (Q);
   end Capsule_From_Segment;
end MJ.Flex_Kernels;

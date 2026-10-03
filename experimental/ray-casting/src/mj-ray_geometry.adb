--  Native translation of MuJoCo 3.14.0 engine_ray.c, Apache-2.0.
--  Copyright 2021 DeepMind Technologies Limited; modifications MABS3D.
with MJ.Quaternion_Math;
package body MJ.Ray_Geometry with SPARK_Mode is
   function Map (R : Matrix; V : Vector) return Vector is
     ([for I in Axis => Map_Component (R, V, I)]);
   function Rotate (R : Matrix; V : Vector) return Vector is
     ([for I in Axis => Rotate_Component (R, V, I)]);
   function Normalize (V : Vector) return Vector is
      Length : constant Real := MJ.Quaternion_Math.Sqrt (Dot (V, V));
   begin
      if Length < Min_Val then return [1.0, 0.0, 0.0]; end if;
      return [for I in Axis => V (I) / Length];
   end Normalize;
   function Cross (A, B : Vector) return Vector is
     ([A (1)*B (2) - A (2)*B (1), A (2)*B (0) - A (0)*B (2), A (0)*B (1) - A (1)*B (0)]);
   procedure Basis (Direction : Vector; B0, B1 : out Vector) is
      V : Vector := [1.0, 1.0, 1.0];
      Scale : Real;
   begin
      if abs Direction (0) >= abs Direction (1) and then abs Direction (0) >= abs Direction (2)
      then V (0) := 0.0;
      elsif abs Direction (1) >= abs Direction (2) then V (1) := 0.0;
      else V (2) := 0.0; end if;
      Scale := -Dot (Direction, V) / Dot (Direction, Direction);
      B1 := Normalize ([for I in Axis => V (I) + Direction (I)*Scale]);
      B0 := Normalize (Cross (B1, Direction));
   end Basis;
   function Discriminant (A, B, C : Real) return Real is
   begin return Product (B,B)-Product (A,C); end Discriminant;
   procedure Quadratic (A, B, C : Real; Low, High : out Real) is
      Det : Real := Discriminant (A,B,C);
   begin
      Low := -1.0; High := -1.0;
      if Det < 0.0 or else A < Min_Val then return; end if;
      Det := MJ.Quaternion_Math.Sqrt (Det);
      if Det not in 0.0 .. 1.0e100 then raise Constraint_Error with "ray sqrt outside numeric domain"; end if;
      Low := (-B - Det) / A; High := (-B + Det) / A;
      if Low not in -1.0e100 .. 1.0e100 or else High not in -1.0e100 .. 1.0e100
      then raise Constraint_Error with "ray root outside numeric domain"; end if;
   end Quadratic;
   function First_Root (A, B, C : Real) return Real is
      Low, High : Real;
   begin
      Quadratic (A, B, C, Low, High);
      if Low >= 0.0 then return Low; elsif High >= 0.0 then return High; else return -1.0; end if;
   end First_Root;
   function Sphere_Distance (Position, Point, Direction : Vector; Radius_Squared : Real) return Real is
      Dif : constant Vector := [for I in Axis => Point (I) - Position (I)];
   begin
      return First_Root (Dot (Direction, Direction), Dot (Direction, Dif), Dot (Dif, Dif) - Radius_Squared);
   end Sphere_Distance;
   function Sphere_Test (Position, Point, Direction : Vector; Radius_Squared : Real) return Hit is
      Result : Hit;
   begin
      Result.Distance := Sphere_Distance (Position, Point, Direction, Radius_Squared);
      if Result.Distance >= 0.0 then
         Result.Normal := Normalize ([for I in Axis => Along (Point (I), Direction (I), Result.Distance) - Position (I)]);
      end if;
      return Result;
   end Sphere_Test;
   procedure Box_Faces (Position : Vector; Rotation : Matrix;
                        Size, Point, Direction : Vector; Result : out Hit;
                        Faces : out Face_Hits) is
      P, V : Vector;
      T, P0, P1 : Real;
      J, K : Axis;
      N : Vector := Zero;
   begin
      Result := (others => <>); Faces := [others => -1.0];
      if Sphere_Distance (Position, Point, Direction, Dot (Size, Size)) < 0.0 then return; end if;
      P := Map (Rotation, [for I in Axis => Point (I) - Position (I)]);
      V := Map (Rotation, Direction);
      for I in Axis loop
         if abs V (I) > Min_Val then
            J := (if I = 0 then 1 else 0); K := (if I = 2 then 1 else 2);
            for Side in Integer range -1 .. 1 loop
               if Side /= 0 then
                  T := (Real (Side)*Size (I) - P (I)) / V (I);
                  if T >= 0.0 then
                     P0 := Along (P (J), V (J), T); P1 := Along (P (K), V (K), T);
                     if abs P0 <= Size (J) and then abs P1 <= Size (K) then
                        Faces (2*I + (Side+1)/2) := T;
                        if Better (T, Result.Distance) then
                           Result.Distance := T; N := Zero; N (I) := Real (Side);
                        end if;
                     end if;
                  end if;
               end if;
            end loop;
         end if;
      end loop;
      if Result.Distance >= 0.0 then Result.Normal := Rotate (Rotation, N); end if;
   end Box_Faces;
   function Intersect (Shape : Kind; Position : Vector; Rotation : Matrix;
                       Size, Point, Direction : Vector) return Hit is
      Result : Hit;
      P, V, S, Dif, N : Vector;
      T, Low, High, A, B, C : Real;
      Part : Integer := 0;
      Faces : Face_Hits;
   begin
      if Shape = Sphere then return Sphere_Test (Position, Point, Direction, Size (0)*Size (0)); end if;
      if Shape = Box then
         Box_Faces (Position, Rotation, Size, Point, Direction, Result, Faces); return Result;
      end if;
      if Shape = Capsule or else Shape = Cylinder then
         T := (if Shape = Capsule then (Size (0)+Size (1))*(Size (0)+Size (1))
               else Size (0)*Size (0) + Size (1)*Size (1));
         if Sphere_Distance (Position, Point, Direction, T) < 0.0 then return Result; end if;
      end if;
      P := Map (Rotation, [for I in Axis => Point (I) - Position (I)]); V := Map (Rotation, Direction);
      case Shape is
         when Plane =>
            if V (2) > -Min_Val then return Result; end if;
            T := -P (2) / V (2);
            if T >= 0.0 and then (Size (0) <= 0.0 or else abs Along (P (0), V (0), T) <= Size (0))
              and then (Size (1) <= 0.0 or else abs Along (P (1), V (1), T) <= Size (1))
            then Result := (T, [Rotation (0, 2), Rotation (1, 2), Rotation (2, 2)]); end if;
         when Ellipsoid =>
            S := [for I in Axis => 1.0 / (Size (I)*Size (I))];
            A := (S (0)*V (0)*V (0) + S (1)*V (1)*V (1)) + S (2)*V (2)*V (2);
            B := (S (0)*V (0)*P (0) + S (1)*V (1)*P (1)) + S (2)*V (2)*P (2);
            C := ((S (0)*P (0)*P (0) + S (1)*P (1)*P (1)) + S (2)*P (2)*P (2)) - 1.0;
            Result.Distance := First_Root (A, B, C);
            if Result.Distance >= 0.0 then
               N := [for I in Axis => S (I)*Along (P (I), V (I), Result.Distance)];
               Result.Normal := Rotate (Rotation, Normalize (N));
            end if;
         when Capsule | Cylinder =>
            if Shape = Cylinder and then abs V (2) > Min_Val then
               for Side in Integer range -1 .. 1 loop
                  if Side /= 0 then
                     T := (Real (Side)*Size (1) - P (2)) / V (2);
                     if T >= 0.0 and then Along (P (0), V (0), T)*Along (P (0), V (0), T)
                       + Along (P (1), V (1), T)*Along (P (1), V (1), T) <= Size (0)*Size (0)
                       and then Better (T, Result.Distance)
                     then Result.Distance := T; Part := Side; end if;
                  end if;
               end loop;
            end if;
            T := First_Root (V (0)*V (0)+V (1)*V (1), V (0)*P (0)+V (1)*P (1),
                             (P (0)*P (0)+P (1)*P (1)) - Size (0)*Size (0));
            if T >= 0.0 and then abs Along (P (2), V (2), T) <= Size (1)
              and then Better (T, Result.Distance) then Result.Distance := T; Part := 0; end if;
            if Shape = Capsule then
               for Side in reverse Integer range -1 .. 1 loop
                  if Side /= 0 then
                     Dif := [P (0), P (1), P (2)-Real (Side)*Size (1)];
                     Quadratic (Dot (V, V), Dot (V, Dif), Dot (Dif, Dif)-Size (0)*Size (0), Low, High);
                     for T_Of_Root of Vector'(Low, High, -1.0) loop
                        if T_Of_Root >= 0.0 and then
                          Real (Side)*Along (P (2), V (2), T_Of_Root) >= Size (1)
                          and then Better (T_Of_Root, Result.Distance)
                        then Result.Distance := T_Of_Root; Part := Side; end if;
                     end loop;
                  end if;
               end loop;
            end if;
            if Result.Distance >= 0.0 then
               if Shape = Cylinder and then Part /= 0 then N := [0.0, 0.0, Real (Part)];
               else
                  N := [Along (P (0), V (0), Result.Distance), Along (P (1), V (1), Result.Distance),
                        (if Part = 0 then 0.0 else Along (P (2), V (2), Result.Distance)-Size (1)*Real (Part))];
                  N := Normalize (N);
               end if;
               Result.Normal := Rotate (Rotation, N);
            end if;
         when others => raise Constraint_Error with "nonprimitive ray geometry";
      end case;
      return Result;
   end Intersect;
   function Intersect_Triangle (Vertices : Triangle; Point, Direction, B0, B1 : Vector) return Hit is
      D : Triangle := [for I in 0 .. 2 => [for J in Axis => Vertices (I) (J)-Point (J)]];
      X, Y : Vector;
      A0, A1, A2, A3, Det, T0, T1, Denom : Real;
      N : Vector;
      Result : Hit;
   begin
      X := [for I in Axis => Dot (B0, D (I))]; Y := [for I in Axis => Dot (B1, D (I))];
      if (X (0)>0.0 and then X (1)>0.0 and then X (2)>0.0)
        or else (X (0)<0.0 and then X (1)<0.0 and then X (2)<0.0)
        or else (Y (0)>0.0 and then Y (1)>0.0 and then Y (2)>0.0)
        or else (Y (0)<0.0 and then Y (1)<0.0 and then Y (2)<0.0) then return Result; end if;
      A0:=X (0)-X (2); A1:=X (1)-X (2); A2:=Y (0)-Y (2); A3:=Y (1)-Y (2);
      Det:=A0*A3-A1*A2;
      if abs Det < Min_Val then return Result; end if;
      T0:=(A3*(-X (2))-A1*(-Y (2)))/Det; T1:=(-A2*(-X (2))+A0*(-Y (2)))/Det;
      if T0<0.0 or else T1<0.0 or else T0+T1>1.0 then return Result; end if;
      D := [ [for J in Axis => Vertices (0) (J)-Vertices (2) (J)],
             [for J in Axis => Vertices (1) (J)-Vertices (2) (J)],
             [for J in Axis => Point (J)-Vertices (2) (J)] ];
      N:=Cross (D (0),D (1)); Denom:=Dot (Direction,N);
      if abs Denom < Min_Val then return Result; end if;
      Result.Distance := -Dot (D (2),N)/Denom;
      if Result.Distance >= 0.0 then Result.Normal:=Normalize (N); end if;
      return Result;
   end Intersect_Triangle;
   function Slab (Center, Half_Size, Point, Direction : Vector) return Boolean is
      Low : Real := 0.0; High : Real := Real'Last;
      T0, T1, Tmp : Real;
   begin
      for I in Axis loop
         if Direction (I) = 0.0 then
            if Point (I)<Center (I)-Half_Size (I) or else Point (I)>Center (I)+Half_Size (I) then return False; end if;
         else
            T0:=(Center (I)-Half_Size (I)-Point (I))*(1.0/Direction (I));
            T1:=(Center (I)+Half_Size (I)-Point (I))*(1.0/Direction (I));
            if T0>T1 then Tmp:=T0; T0:=T1; T1:=Tmp; end if;
            Low:=Real'Max (Low,T0); High:=Real'Min (High,T1);
         end if;
      end loop;
      return Low<High;
   end Slab;
end MJ.Ray_Geometry;

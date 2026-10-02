with MJ.Rigid_Math; use MJ.Rigid_Math;
with MJ.Rigid_CCD; use MJ.Rigid_CCD;
with MJ.Rigid_Primitives; use MJ.Rigid_Primitives;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;

package body MJ.Rigid_Narrowphase with SPARK_Mode is
   function Plane_Distance (A, B : Shape; PA, PB : Pose) return Real is
      N : constant Vec := Column (PA.Rotation, 2);
      D : constant Real := Dot (Sub (PB.Position, PA.Position), N);
      V : constant Vec := Local (PB.Rotation, N);
      E : Real;
   begin
      case B.Kind is
         when Sphere => E := B.Size (0);
         when Capsule => E := B.Size (0)+B.Size (1)*abs V (2);
         when Ellipsoid => E := Sqrt ((B.Size (0)*V (0))**2+(B.Size (1)*V (1))**2+(B.Size (2)*V (2))**2);
         when Cylinder => E := B.Size (0)*Sqrt (V (0)*V (0)+V (1)*V (1))+B.Size (1)*abs V (2);
         when Box => E := (B.Size (0)*abs V (0)+B.Size (1)*abs V (1))+B.Size (2)*abs V (2);
         when Plane => E := 0.0;
      end case;
      return D-E;
   end Plane_Distance;

   function Test (A, B : Shape; PA, PB : Pose; Margin : Real; O : Options) return Decision is
      D, V : Vec;
      X, R : Real;
   begin
      if A.Kind = Plane and B.Kind = Plane then return Separated;
      elsif A.Kind = Plane then
         return (if Plane_Distance (A, B, PA, PB) <= Margin then Contact else Separated);
      elsif B.Kind = Plane then
         return (if Plane_Distance (B, A, PB, PA) <= Margin then Contact else Separated);
      elsif A.Kind = Sphere and B.Kind = Sphere then
         D := Sub (PA.Position, PB.Position); R := (Margin+A.Size (0))+B.Size (0);
         return (if Dot (D, D) <= R*R then Contact else Separated);
      elsif A.Kind = Sphere and B.Kind = Capsule then
         D := Column (PB.Rotation, 2); X := Clip (Dot (D, Sub (PA.Position, PB.Position)), -B.Size (1), B.Size (1));
         V := Sub (PA.Position, Add (PB.Position, Scale (D, X)));
         R := (Margin+A.Size (0))+B.Size (0);
         return (if Dot (V, V) <= R*R then Contact else Separated);
      elsif B.Kind = Sphere and A.Kind = Capsule then
         D := Column (PA.Rotation, 2); X := Clip (Dot (D, Sub (PB.Position, PA.Position)), -A.Size (1), A.Size (1));
         V := Sub (PB.Position, Add (PA.Position, Scale (D, X)));
         R := (Margin+B.Size (0))+A.Size (0);
         return (if Dot (V, V) <= R*R then Contact else Separated);
      elsif A.Kind = Sphere and B.Kind = Cylinder then
         return (if Sphere_Cylinder (A, B, PA, PB, Margin) then Contact else Separated);
      elsif A.Kind = Sphere and B.Kind = Box then
         V := Local (PB.Rotation, Sub (PA.Position, PB.Position));
         D := [V (0)-Clip (V (0), -B.Size (0), B.Size (0)),
               V (1)-Clip (V (1), -B.Size (1), B.Size (1)),
               V (2)-Clip (V (2), -B.Size (2), B.Size (2))];
         return (if Norm (D)-A.Size (0) <= Margin then Contact else Separated);
      elsif B.Kind = Sphere and A.Kind = Cylinder then
         return (if Sphere_Cylinder (B, A, PB, PA, Margin) then Contact else Separated);
      elsif B.Kind = Sphere and A.Kind = Box then
         V := Local (PA.Rotation, Sub (PB.Position, PA.Position));
         D := [V (0)-Clip (V (0), -A.Size (0), A.Size (0)),
               V (1)-Clip (V (1), -A.Size (1), A.Size (1)),
               V (2)-Clip (V (2), -A.Size (2), A.Size (2))];
         return (if Norm (D)-B.Size (0) <= Margin then Contact else Separated);
      elsif A.Kind = Capsule and B.Kind = Capsule then
         return (if Capsule_Capsule (A, B, PA, PB, Margin) then Contact else Separated);
      elsif A.Kind = Capsule and B.Kind = Box then
         return (if Capsule_Box (A, B, PA, PB, Margin) then Contact else Separated);
      elsif A.Kind = Box and B.Kind = Capsule then
         return (if Capsule_Box (B, A, PB, PA, Margin) then Contact else Separated);
      elsif A.Kind = Box and B.Kind = Box then
         return (if Box_Box (A, B, PA, PB, Margin) then Contact else Separated);
      else
         return Convex (A, B, PA, PB, Margin, O);
      end if;
   end Test;
end MJ.Rigid_Narrowphase;

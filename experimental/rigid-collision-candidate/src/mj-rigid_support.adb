with MJ.Rigid_Math; use MJ.Rigid_Math;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;

package body MJ.Rigid_Support with SPARK_Mode is
   function Support (S : Shape; P : Pose; Direction : Vec) return Vec is
      D : constant Vec := Local (P.Rotation, Direction);
      V : Vec := Zero;
      L : Real;
   begin
      case S.Kind is
         when Sphere =>
            return Add (P.Position, Scale (Direction, S.Size (0)));
         when Capsule =>
            V := Scale (D, S.Size (0));
            V (2) := V (2) + (if D (2) >= 0.0 then S.Size (1) else -S.Size (1));
         when Ellipsoid =>
            V := [S.Size (0)*D (0), S.Size (1)*D (1), S.Size (2)*D (2)];
            L := Norm (V);
            if L >= Min_Val then
               L := 1.0/L;
               V := [V (0)*(L*S.Size (0)), V (1)*(L*S.Size (1)), V (2)*(L*S.Size (2))];
            else
               V := [S.Size (0), 0.0, 0.0];
            end if;
         when Cylinder =>
            L := Sqrt (D (0)*D (0)+D (1)*D (1));
            if L >= Min_Val then
               L := S.Size (0)/L;
               V (0) := L*D (0); V (1) := L*D (1);
            end if;
            V (2) := (if D (2) >= 0.0 then S.Size (1) else -S.Size (1));
         when Box =>
            for I in Axis loop
               V (I) := (if D (I) >= 0.0 then S.Size (I) else -S.Size (I));
            end loop;
         when Plane => null;
      end case;
      return Add (P.Position, Transform (P.Rotation, V));
   end Support;

   function Radius (S : Shape) return Real is
   begin
      case S.Kind is
         when Plane => return 0.0;
         when Sphere => return S.Size (0);
         when Capsule => return S.Size (0)+S.Size (1);
         when Ellipsoid => return Real'Max (S.Size (0), Real'Max (S.Size (1), S.Size (2)));
         when Cylinder => return Sqrt (S.Size (0)*S.Size (0)+S.Size (1)*S.Size (1));
         when Box => return Norm (S.Size);
      end case;
   end Radius;

   procedure Bounds (S : Shape; P : Pose; Lo, Hi : out Vec) is
      E : Vec := Zero;
      A, B, C : Real;
      Padding : constant Real := S.Margin+S.Gap;
   begin
      if S.Kind = Sphere then
         for I in Axis loop Lo (I) := P.Position (I)-(S.Size (0)+Padding); Hi (I) := P.Position (I)+(S.Size (0)+Padding); end loop;
         return;
      end if;
      for I in Axis loop
         A := abs P.Rotation (3*I); B := abs P.Rotation (3*I+1); C := abs P.Rotation (3*I+2);
         case S.Kind is
            when Sphere => E (I) := S.Size (0);
            when Capsule => E (I) := S.Size (0)+S.Size (1)*C;
            when Ellipsoid => E (I) := Sqrt ((A*S.Size (0))**2+(B*S.Size (1))**2+(C*S.Size (2))**2);
            when Cylinder => E (I) := S.Size (0)*Sqrt (A*A+B*B)+S.Size (1)*C;
            when Box => E (I) := (A*S.Size (0)+B*S.Size (1))+C*S.Size (2);
            when Plane => null;
         end case;
         Lo (I) := P.Position (I)-(E (I)+Padding);
         Hi (I) := P.Position (I)+(E (I)+Padding);
      end loop;
   end Bounds;
   --  Projection on (1,1,1), with an analytical radius. Projecting the
   --  corners of the world AABB instead would inflate a sphere by sqrt(3).
   procedure Projection_Bounds (S : Shape; P : Pose; Lo, Hi : out Real) is
      Root3 : constant Real := 1.7320508075688772935;
      Center : constant Real := (P.Position (0)+P.Position (1))+P.Position (2);
      D : Vec;
      E : Real;
   begin
      if S.Kind = Sphere then E := S.Size (0)*Root3;
      else
         D := Local (P.Rotation, [1.0, 1.0, 1.0]);
         case S.Kind is
            when Capsule => E := S.Size (0)*Root3+S.Size (1)*abs D (2);
            when Ellipsoid => E := Norm ([S.Size (0)*D (0), S.Size (1)*D (1), S.Size (2)*D (2)]);
            when Cylinder => E := S.Size (0)*Sqrt (D (0)*D (0)+D (1)*D (1))+S.Size (1)*abs D (2);
            when Box => E := (S.Size (0)*abs D (0)+S.Size (1)*abs D (1))+S.Size (2)*abs D (2);
            when Plane | Sphere => E := 0.0;
         end case;
      end if;
      E := E+(S.Margin+S.Gap)*Root3; Lo := Center-E; Hi := Center+E;
   end Projection_Bounds;
end MJ.Rigid_Support;

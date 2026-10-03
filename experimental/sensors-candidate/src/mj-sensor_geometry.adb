with Ada.Numerics.Long_Elementary_Functions;
package body MJ.Sensor_Geometry with SPARK_Mode is
   package EF renames Ada.Numerics.Long_Elementary_Functions;
   function Inside (Kind : Integer; Size, Point : Vector) return Boolean is
      P : Vector := Point;
   begin
      case Kind is
         when 2 => return Dot (P, P) <= Size (0) * Size (0);
         when 3 => P (2) := Real'Max (0.0, abs P (2) - Size (1)); return Dot (P, P) <= Size (0) * Size (0);
         when 4 =>
            for A in 0 .. 2 loop if Size (A) <= 0.0 then return False; end if; P (A) := P (A) / Size (A); end loop;
            return Dot (P, P) <= 1.0;
         when 5 => return P (0) * P (0) + P (1) * P (1) <= Size (0) * Size (0) and then abs P (2) <= Size (1);
         when 6 => return (for all A in 0 .. 2 => abs P (A) <= Size (A));
         when others => return False;
      end case;
   end Inside;
   function Distance (Kind : Integer; Size, Point : Vector) return Real is
      A, B : Vector := Zero;
      K0, K1, Length : Real;
   begin
      case Kind is
         when 0 => return Point (2);
         when 2 => return EF.Sqrt (Dot (Point, Point)) - Size (0);
         when 3 => A := Point; A (2) := A (2) - Real'Max (-Size (1), Real'Min (Size (1), A (2)));
            return EF.Sqrt (Dot (A, A)) - Size (0);
         when 4 =>
            for I in 0 .. 2 loop A (I) := Point (I) / Size (I); B (I) := A (I) / Size (I); end loop;
            K0 := EF.Sqrt (Dot (A, A)); K1 := EF.Sqrt (Dot (B, B));
            if K1 = 0.0 then return 0.0; end if; -- C's NaN at centre contributes no tactile depth
            return K0 * (K0 - 1.0) / K1;
         when 5 =>
            K0 := EF.Sqrt (Point (0) ** 2 + Point (1) ** 2) - Size (0); K1 := abs Point (2) - Size (1);
            return Real'Min (Real'Max (K0, K1), 0.0) + EF.Sqrt (Real'Max (K0, 0.0) ** 2 + Real'Max (K1, 0.0) ** 2);
         when 6 =>
            for I in 0 .. 2 loop A (I) := abs Point (I) - Size (I); end loop;
            if (for some X of A => X >= 0.0) then
               for I in 0 .. 2 loop B (I) := Real'Max (A (I), 0.0); end loop;
               return EF.Sqrt (Dot (B, B)) + Real'Min (Real'Max (A (0), Real'Max (A (1), A (2))), 0.0);
            end if;
            for I in 0 .. 2 loop B (I) := -Size (I) / A (I); end loop;
            Length := EF.Sqrt (Dot (B, B));
            if Length < Min_Val then B := [1.0, 0.0, 0.0]; else B := (1.0 / Length) * B; end if;
            for I in 0 .. 2 loop
               if B (I) = 0.0 then A (I) := 1.0e100; else A (I) := -A (I) / abs B (I); end if;
            end loop;
            return -Real'Min (A (0), Real'Min (A (1), A (2))) * EF.Sqrt (Dot (B, B));
         when others => raise Constraint_Error;
      end case;
   end Distance;
   procedure Ray (Kind : Integer; Size, Point, Direction : Vector;
                  Distance : out Real; Ok : out Boolean) is
      Best : Real := 1.0e100;
      procedure Keep (T : Real) is
      begin if T >= 0.0 and then T < Best then Best := T; end if; end Keep;
      procedure Quadratic (A, B, C : Real; Low, High : Real) is
         Disc, Root, T, Z : Real;
      begin
         if A < 1.0e-30 then return; end if;
         Disc := B * B - A * C;
         if Disc < 0.0 then return; end if;
         Root := EF.Sqrt (Disc);
         for Sign in -1 .. 1 loop
            if Sign /= 0 then
               T := (-B + Real (Sign) * Root) / A;
               Z := Point (2) + T * Direction (2);
               if Z >= Low and then Z <= High then Keep (T); end if;
            end if;
         end loop;
      end Quadratic;
      P, V : Vector;
      Near, Far, A, B, T, X, Y : Real;
      R, H : Real;
   begin
      Distance := -1.0; Ok := False;
      if not Bounded (Size, 1.0e10) or else not Bounded (Point, 1.0e20)
        or else not Bounded (Direction, 16.0) then return; end if;
      if Kind = 0 then
         if Direction (2) < -1.0e-15 then Keep (-Point (2) / Direction (2)); end if;
      elsif Kind = 6 then
         Near := -1.0e100; Far := 1.0e100;
         for I in 0 .. 2 loop
            if abs Direction (I) < 1.0e-15 then
               if abs Point (I) > Size (I) then Ok := True; return; end if;
            else
               A := (-Size (I) - Point (I)) / Direction (I);
               B := (Size (I) - Point (I)) / Direction (I);
               Near := Real'Max (Near, Real'Min (A, B)); Far := Real'Min (Far, Real'Max (A, B));
            end if;
         end loop;
         if Near <= Far then Keep (if Near >= 0.0 then Near else Far); end if;
      elsif Kind in 2 | 4 then
         P := Point; V := Direction;
         for I in 0 .. 2 loop
            R := (if Kind = 2 then Size (0) else Size (I));
            if R < 1.0e-15 then return; end if;
            P (I) := P (I) / R; V (I) := V (I) / R;
         end loop;
         Quadratic (Dot (V, V), Dot (P, V), Dot (P, P) - 1.0, -1.0e100, 1.0e100);
      elsif Kind in 3 | 5 then
         R := Size (0); H := Size (1);
         if R < 1.0e-15 or else H < 0.0 then return; end if;
         A := Direction (0) ** 2 + Direction (1) ** 2;
         B := Point (0) * Direction (0) + Point (1) * Direction (1);
         Quadratic (A, B, Point (0) ** 2 + Point (1) ** 2 - R * R, -H, H);
         for Sign in -1 .. 1 loop
            if Sign /= 0 then
               if Kind = 5 and then abs Direction (2) >= 1.0e-15 then
                  T := (Real (Sign) * H - Point (2)) / Direction (2);
                  X := Point (0) + T * Direction (0); Y := Point (1) + T * Direction (1);
                  if X * X + Y * Y <= R * R then Keep (T); end if;
               elsif Kind = 3 then
                  P := Point; P (2) := P (2) - Real (Sign) * H;
                  Quadratic (Dot (Direction, Direction), Dot (P, Direction), Dot (P, P) - R * R,
                    (if Sign < 0 then -1.0e100 else H), (if Sign < 0 then -H else 1.0e100));
               end if;
            end if;
         end loop;
      else return;
      end if;
      if Best < 1.0e100 then Distance := Best; end if;
      Ok := True;
   exception when Constraint_Error => Distance := -1.0; Ok := False;
   end Ray;
end MJ.Sensor_Geometry;

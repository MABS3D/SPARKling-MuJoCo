with Ada.Numerics;
with Ada.Numerics.Long_Elementary_Functions;

package body MJ.Tendon_Geometry with SPARK_Mode is
   package Math renames Ada.Numerics.Long_Elementary_Functions;
   Tiny : constant Real := 1.0e-15;
   Pi : constant Real := Ada.Numerics.Pi;
   type Pair is array (Positive range 1 .. 2) of Real;
   type Pair_Result is record
      Status : Wrap_Status := No_Wrap;
      A, B : Pair := (others => 0.0);
      Length : Real := 0.0;
   end record;

   function Norm (V : Vector) return Real is (Math.Sqrt (Dot (V, V)));
   function Unit (V : Vector) return Vector is
      N : constant Real := Norm (V);
   begin
      return (if N < Tiny then (1.0, 0.0, 0.0) else Scale (V, 1.0 / N));
   end Unit;
   function Pair_Bounded (A : Pair; Limit : Real) return Boolean is
     (A (1) in -Limit .. Limit and then A (2) in -Limit .. Limit);
   function Dot2 (A, B : Pair) return Real with
     Pre => Pair_Bounded (A, 1.0e100) and then Pair_Bounded (B, 1.0e100),
     Post => Dot2'Result = A (1) * B (1) + A (2) * B (2)
       and then Dot2'Result in -2.1e200 .. 2.1e200
       and then (if A = B then Dot2'Result >= 0.0)
   is
      X : constant Real range -1.01e200 .. 1.01e200 := A (1) * B (1);
      Y : constant Real range -1.01e200 .. 1.01e200 := A (2) * B (2);
   begin
      return X + Y;
   end Dot2;
   function Norm2 (A : Pair) return Real is (Math.Sqrt (Dot2 (A, A))) with
     Pre => Pair_Bounded (A, 1.0e100),
     Post => Norm2'Result >= 0.0;
   function Unit2 (A : Pair) return Pair with
     Pre => Pair_Bounded (A, 1.0e100),
     Post => Unit2'Result = (if Norm2 (A) < Tiny then (1.0, 0.0)
       else (A (1) * (1.0 / Norm2 (A)), A (2) * (1.0 / Norm2 (A))))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Norm2);
      N : constant Real := Norm2 (A);
      S : Real;
   begin
      if N < Tiny then
         return (1.0, 0.0);
      end if;
      S := 1.0 / N;
      return (A (1) * S, A (2) * S);
   end Unit2;

   subtype Determinant_Real is Real range -1.0e102 .. 1.0e102;
   function Determinant (A, B, C, D : Real) return Determinant_Real with
     Pre => A in -2.1e50 .. 2.1e50 and then B in -2.1e50 .. 2.1e50
       and then C in -2.1e50 .. 2.1e50 and then D in -2.1e50 .. 2.1e50,
     Post => Determinant'Result = A * B - C * D
   is
      X : constant Real range -5.0e100 .. 5.0e100 := A * B;
      Y : constant Real range -5.0e100 .. 5.0e100 := C * D;
   begin
      return X - Y;
   end Determinant;

   function Intersect (P1, P2, P3, P4 : Pair) return Boolean with
     Pre => Pair_Bounded (P1, 1.0e50) and then Pair_Bounded (P2, 1.0e50)
       and then Pair_Bounded (P3, 1.0e50) and then Pair_Bounded (P4, 1.0e50)
   is
      Det : constant Determinant_Real := Determinant
        (P4 (2) - P3 (2), P2 (1) - P1 (1), P4 (1) - P3 (1), P2 (2) - P1 (2));
      A, B : Real;
   begin
      if abs Det < Tiny then return False; end if;
      A := Determinant (P4 (1) - P3 (1), P1 (2) - P3 (2),
                        P4 (2) - P3 (2), P1 (1) - P3 (1)) / Det;
      B := Determinant (P2 (1) - P1 (1), P1 (2) - P3 (2),
                        P2 (2) - P1 (2), P1 (1) - P3 (1)) / Det;
      return A in 0.0 .. 1.0 and then B in 0.0 .. 1.0;
   end Intersect;

   function Circle (E0, E1 : Pair; Side : Pair; Has_Side : Boolean; R : Real)
     return Pair_Result is
      Sq0 : constant Real := Dot2 (E0, E0);
      Sq1 : constant Real := Dot2 (E1, E1);
      RR : constant Real := R * R;
      D : constant Pair := (E1 (1) - E0 (1), E1 (2) - E0 (2));
      DD : constant Real := Dot2 (D, D);
      A, Root0, Root1, S, Cosine, Angle, Cross_Value : Real;
      Tmp : Pair;
      Sol : array (Natural range 0 .. 1) of Pair_Result;
      Good : array (Natural range 0 .. 1) of Real := (others => 0.0);
      Choice : Natural range 0 .. 1;
   begin
      if Sq0 < RR or else Sq1 < RR or else R < Tiny or else DD < Tiny then
         return (others => <>);
      end if;
      A := Real'Max (0.0, Real'Min (1.0, -Dot2 (D, E0) / DD));
      Tmp := (A * D (1) + E0 (1), A * D (2) + E0 (2));
      if Dot2 (Tmp, Tmp) > RR and then
        (not Has_Side or else Dot2 (Side, Tmp) >= 0.0)
      then
         return (others => <>);
      end if;
      Root0 := Math.Sqrt (Sq0 - RR);
      Root1 := Math.Sqrt (Sq1 - RR);
      for I in 0 .. 1 loop
         S := (if I = 0 then 1.0 else -1.0);
         Sol (I).A :=
           ((E0 (1) * RR + ((S * R) * E0 (2)) * Root0) / Sq0,
            (E0 (2) * RR - ((S * R) * E0 (1)) * Root0) / Sq0);
         Sol (I).B :=
           ((E1 (1) * RR - ((S * R) * E1 (2)) * Root1) / Sq1,
            (E1 (2) * RR + ((S * R) * E1 (1)) * Root1) / Sq1);
         if Has_Side then
            Tmp := Unit2 ((Sol (I).A (1) + Sol (I).B (1),
                           Sol (I).A (2) + Sol (I).B (2)));
            Good (I) := Dot2 (Tmp, Side);
         else
            Tmp := (Sol (I).A (1) - Sol (I).B (1),
                    Sol (I).A (2) - Sol (I).B (2));
            Good (I) := -Dot2 (Tmp, Tmp);
         end if;
         if Intersect (E0, Sol (I).A, E1, Sol (I).B) then
            Good (I) := -10000.0;
         end if;
      end loop;
      Choice := (if Good (0) > Good (1) then 0 else 1);
      if Intersect (E0, Sol (Choice).A, E1, Sol (Choice).B) then
         return (others => <>);
      end if;
      Cosine := Dot2 (Unit2 (Sol (Choice).A), Unit2 (Sol (Choice).B));
      if Cosine not in -1.0 .. 1.0 then
         return (Status => Numeric_Limit, others => <>);
      end if;
      Angle := Math.Arccos (Cosine);
      Cross_Value := Sol (Choice).A (2) * Sol (Choice).B (1)
        - Sol (Choice).A (1) * Sol (Choice).B (2);
      if (Cross_Value > 0.0 and then Choice = 1)
        or else (Cross_Value < 0.0 and then Choice = 0)
      then
         Angle := 2.0 * Pi - Angle;
      end if;
      return (Wrapped, Sol (Choice).A, Sol (Choice).B, R * Angle);
   end Circle;

   function Inside (E0, E1 : Pair; R : Real) return Pair_Result is
      L0 : constant Real := Norm2 (E0);
      L1 : constant Real := Norm2 (E1);
      D : constant Pair := (E1 (1) - E0 (1), E1 (2) - E0 (2));
      DD : constant Real := Dot2 (D, D);
      A, B, CosG, G, T, Z, F, DF, Z1, Ang, Q0, Q1, Q2 : Real;
      Vec, P : Pair;
      Default : Pair_Result;
      Iter : Natural := 0;
      function Residual (X : Real) return Real is
        (((Math.Arcsin (A * X) + Math.Arcsin (B * X)) - 2.0 * Math.Arcsin (X)) + G);
   begin
      if L0 <= R or else L1 <= R or else R < Tiny
        or else L0 < Tiny or else L1 < Tiny
      then
         return (others => <>);
      end if;
      if DD > Tiny then
         T := -Dot2 (D, E0) / DD;
         if T > 0.0 and then T < 1.0
           and then Norm2 ((E0 (1) + T * D (1), E0 (2) + T * D (2))) <= R
         then
            return (others => <>);
         end if;
      end if;
      P := Unit2 ((0.5 * (E0 (1) + E1 (1)), 0.5 * (E0 (2) + E1 (2))));
      P := (P (1) * R, P (2) * R);
      Default := (Wrapped, P, P, 0.0);
      A := R / L0;
      B := R / L1;
      CosG := ((L0 * L0 + L1 * L1) - DD) / ((2.0 * L0) * L1);
      if CosG < -1.0 + Tiny then
         return (others => <>);
      elsif CosG > 1.0 - Tiny then
         return Default;
      end if;
      G := Math.Arccos (CosG);
      Z := 1.0 - 1.0e-7;
      F := Residual (Z);
      if F > 0.0 then
         return Default;
      end if;
      while Iter < 20 and then abs F > 1.0e-6 loop
         pragma Loop_Variant (Increases => Iter);
         Q0 := 1.0 - ((Z * Z) * A) * A;
         Q1 := 1.0 - ((Z * Z) * B) * B;
         Q2 := 1.0 - Z * Z;
         if Q0 < 0.0 or else Q1 < 0.0 or else Q2 < 0.0 then
            return (Status => Numeric_Limit, others => <>);
         end if;
         DF := (A / Real'Max (Tiny, Math.Sqrt (Q0))
           + B / Real'Max (Tiny, Math.Sqrt (Q1)))
           - 2.0 / Real'Max (Tiny, Math.Sqrt (Q2));
         if DF > -Tiny then
            return Default;
         end if;
         Z1 := Z - F / DF;
         if Z1 > Z then
            return Default;
         end if;
         Z := Z1;
         if Z not in -1.0 .. 1.0 or else A * Z not in -1.0 .. 1.0
           or else B * Z not in -1.0 .. 1.0
         then
            return (Status => Numeric_Limit, others => <>);
         end if;
         F := Residual (Z);
         if F > 1.0e-6 then
            return Default;
         end if;
         Iter := Iter + 1;
      end loop;
      if Iter >= 20 then
         return Default;
      end if;
      if E0 (1) * E1 (2) - E0 (2) * E1 (1) > 0.0 then
         Vec := Unit2 (E0);
         Ang := Math.Arcsin (Z) - Math.Arcsin (A * Z);
      else
         Vec := Unit2 (E1);
         Ang := Math.Arcsin (Z) - Math.Arcsin (B * Z);
      end if;
      P := (R * (Math.Cos (Ang) * Vec (1) - Math.Sin (Ang) * Vec (2)),
            R * (Math.Sin (Ang) * Vec (1) + Math.Cos (Ang) * Vec (2)));
      return (Wrapped, P, P, 0.0);
   end Inside;

   function Wrap
     (Start, Finish, Center : Vector; Orientation : Matrix; Radius : Real;
      Kind : Geometry_Kind; Has_Side : Boolean := False; Side : Vector := Zero)
      return Wrap_Result is
      P0 : constant Vector := Multiply (Orientation, Sub (Start, Center), True);
      P1 : constant Vector := Multiply (Orientation, Sub (Finish, Center), True);
      Axis0 : Vector := (1.0, 0.0, 0.0);
      Axis1 : Vector := (0.0, 1.0, 0.0);
      Normal, R0, R1 : Vector;
      S : Vector := Zero;
      D0, D1 : Pair;
      SD : Pair := (others => 0.0);
      W : Pair_Result;
      N, L0, L1, Total, Height : Real;
      K : Positive range 1 .. 3 := 1;
      Result : Wrap_Result;
   begin
      if Norm (P0) < Tiny or else Norm (P1) < Tiny then
         return (others => <>);
      end if;
      if Kind = Sphere then
         Axis0 := Unit (P0);
         Normal := Cross (P0, P1);
         N := Norm (Normal);
         Normal := Unit (Normal);
         if N < Tiny then
            if abs Axis0 (2) > abs Axis0 (1) and then abs Axis0 (2) > abs Axis0 (3) then
               K := 2;
            end if;
            if abs Axis0 (3) > abs Axis0 (1) and then abs Axis0 (3) > abs Axis0 (2) then
               K := 3;
            end if;
            Axis1 := (others => 1.0);
            Axis1 (K) := 0.0;
            Normal := Unit (Cross (Axis0, Axis1));
         end if;
         Axis1 := Unit (Cross (Normal, Axis0));
      end if;
      D0 := (Dot (P0, Axis0), Dot (P0, Axis1));
      D1 := (Dot (P1, Axis0), Dot (P1, Axis1));
      if Has_Side then
         S := Multiply (Orientation, Sub (Side, Center), True);
         SD := Unit2 ((Dot (S, Axis0), Dot (S, Axis1)));
         SD := (SD (1) * Radius, SD (2) * Radius);
      end if;
      W := (if Has_Side and then Norm (S) < Radius then Inside (D0, D1, Radius)
            else Circle (D0, D1, SD, Has_Side, Radius));
      if W.Status /= Wrapped then
         return (Status => W.Status, others => <>);
      end if;
      R0 := Add (Scale (Axis0, W.A (1)), Scale (Axis1, W.A (2)));
      R1 := Add (Scale (Axis0, W.B (1)), Scale (Axis1, W.B (2)));
      if Kind = Cylinder then
         L0 := Norm2 ((P0 (1) - R0 (1), P0 (2) - R0 (2)));
         L1 := Norm2 ((P1 (1) - R1 (1), P1 (2) - R1 (2)));
         Total := (L0 + W.Length) + L1;
         if Total <= 0.0 then
            return (Status => Numeric_Limit, others => <>);
         end if;
         R0 (3) := P0 (3) + ((P1 (3) - P0 (3)) * L0) / Total;
         R1 (3) := P0 (3) + ((P1 (3) - P0 (3)) * (L0 + W.Length)) / Total;
         Height := abs (R1 (3) - R0 (3));
         W.Length := Math.Sqrt (W.Length * W.Length + Height * Height);
      end if;
      Result := (Wrapped, Add (Multiply (Orientation, R0), Center),
                 Add (Multiply (Orientation, R1), Center), W.Length);
      if Result.Arc_Length not in 0.0 .. 1.0e100
        or else not Bounded (Result.First, 1.0e100)
        or else not Bounded (Result.Last, 1.0e100)
      then
         return (Status => Numeric_Limit, others => <>);
      end if;
      return Result;
   end Wrap;
end MJ.Tendon_Geometry;

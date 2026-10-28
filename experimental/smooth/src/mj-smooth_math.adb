with Ada.Numerics.Long_Elementary_Functions;

package body MJ.Smooth_Math with SPARK_Mode is
   package Math renames Ada.Numerics.Long_Elementary_Functions;

   function "+" (A, B : Vector) return Vector is
     ([A (0) + B (0), A (1) + B (1), A (2) + B (2)]);
   function "-" (A, B : Vector) return Vector is
     ([A (0) - B (0), A (1) - B (1), A (2) - B (2)]);
   function "-" (A : Vector) return Vector is ([-A (0), -A (1), -A (2)]);
   function "*" (S : Real; V : Vector) return Vector is
     ([S * V (0), S * V (1), S * V (2)]);
   function Dot (A, B : Vector) return Real is
     ((A (0) * B (0) + A (1) * B (1)) + A (2) * B (2));
   function Cross (A, B : Vector) return Vector is
      --  Preserve the six rounded products and the three ordered differences.
      --  Their local bounds are static consequences of the public precondition.
      P12 : constant Real := A (1) * B (2);
      P21 : constant Real := A (2) * B (1);
      P20 : constant Real := A (2) * B (0);
      P02 : constant Real := A (0) * B (2);
      P01 : constant Real := A (0) * B (1);
      P10 : constant Real := A (1) * B (0);
   begin
      pragma Assert (Static => P12 in -2.0e300 .. 2.0e300);
      pragma Assert (Static => P21 in -2.0e300 .. 2.0e300);
      pragma Assert (Static => P20 in -2.0e300 .. 2.0e300);
      pragma Assert (Static => P02 in -2.0e300 .. 2.0e300);
      pragma Assert (Static => P01 in -2.0e300 .. 2.0e300);
      pragma Assert (Static => P10 in -2.0e300 .. 2.0e300);
      declare
         Result : constant Vector := [P12 - P21, P20 - P02, P01 - P10];
      begin
         pragma Assert (Static => Bounded (Result, 8.0e300));
         pragma Assert (Result (0) = A (1)*B (2) - A (2)*B (1));
         pragma Assert (Result (1) = A (2)*B (0) - A (0)*B (2));
         pragma Assert (Result (2) = A (0)*B (1) - A (1)*B (0));
         pragma Assert (Static => (if Bounded (A, 1.0e60) and then Bounded (B, 1.0e12)
           then Result (0) in -1.0e73 .. 1.0e73));
         pragma Assert (Static => (if Bounded (A, 1.0e60) and then Bounded (B, 1.0e12)
           then Result (1) in -1.0e73 .. 1.0e73));
         pragma Assert (Static => (if Bounded (A, 1.0e60) and then Bounded (B, 1.0e12)
           then Result (2) in -1.0e73 .. 1.0e73));
         pragma Assert (Static => (if Bounded (A, 1.0e90) and then Bounded (B, 1.0e24)
           then Result (0) in -1.0e115 .. 1.0e115));
         pragma Assert (Static => (if Bounded (A, 1.0e90) and then Bounded (B, 1.0e24)
           then Result (1) in -1.0e115 .. 1.0e115));
         pragma Assert (Static => (if Bounded (A, 1.0e90) and then Bounded (B, 1.0e24)
           then Result (2) in -1.0e115 .. 1.0e115));
         pragma Assert (Static => (if Bounded (A, 1.0e70) and then Bounded (B, 1.0e115)
           then Result (0) in -1.0e186 .. 1.0e186));
         pragma Assert (Static => (if Bounded (A, 1.0e70) and then Bounded (B, 1.0e115)
           then Result (1) in -1.0e186 .. 1.0e186));
         pragma Assert (Static => (if Bounded (A, 1.0e70) and then Bounded (B, 1.0e115)
           then Result (2) in -1.0e186 .. 1.0e186));
         return Result;
      end;
   end Cross;

   function Apply (R : Matrix; V : Vector) return Vector is
      subtype Product is Real range -2.0e281 .. 2.0e281;
      P00 : constant Real'Base := R (0, 0)*V (0);
      P01 : constant Real'Base := R (0, 1)*V (1);
      P02 : constant Real'Base := R (0, 2)*V (2);
      P10 : constant Real'Base := R (1, 0)*V (0);
      P11 : constant Real'Base := R (1, 1)*V (1);
      P12 : constant Real'Base := R (1, 2)*V (2);
      P20 : constant Real'Base := R (2, 0)*V (0);
      P21 : constant Real'Base := R (2, 1)*V (1);
      P22 : constant Real'Base := R (2, 2)*V (2);
      subtype Row_Sum is Real range -1.0e282 .. 1.0e282;
      R0 : constant Real'Base := P00 + P01 + P02;
      R1 : constant Real'Base := P10 + P11 + P12;
      R2 : constant Real'Base := P20 + P21 + P22;
      Result : constant Vector := [R0, R1, R2];
   begin
      pragma Assert (Static => P00 in Product);
      pragma Assert (Static => P01 in Product);
      pragma Assert (Static => P02 in Product);
      pragma Assert (Static => P10 in Product);
      pragma Assert (Static => P11 in Product);
      pragma Assert (Static => P12 in Product);
      pragma Assert (Static => P20 in Product);
      pragma Assert (Static => P21 in Product);
      pragma Assert (Static => P22 in Product);
      pragma Assert (Static => R0 in Row_Sum);
      pragma Assert (Static => R1 in Row_Sum);
      pragma Assert (Static => R2 in Row_Sum);
      pragma Assert (Bounded (Result, 1.0e282));
      pragma Assert (Result (0) = R (0, 0)*V (0) + R (0, 1)*V (1) + R (0, 2)*V (2));
      pragma Assert (Result (1) = R (1, 0)*V (0) + R (1, 1)*V (1) + R (1, 2)*V (2));
      pragma Assert (Result (2) = R (2, 0)*V (0) + R (2, 1)*V (1) + R (2, 2)*V (2));
      return Result;
   end Apply;

   function Apply_Transpose (R : Matrix; V : Vector) return Vector is
      subtype Product is Real range -2.0e281 .. 2.0e281;
      P00 : constant Real'Base := R (0, 0)*V (0);
      P01 : constant Real'Base := R (1, 0)*V (1);
      P02 : constant Real'Base := R (2, 0)*V (2);
      P10 : constant Real'Base := R (0, 1)*V (0);
      P11 : constant Real'Base := R (1, 1)*V (1);
      P12 : constant Real'Base := R (2, 1)*V (2);
      P20 : constant Real'Base := R (0, 2)*V (0);
      P21 : constant Real'Base := R (1, 2)*V (1);
      P22 : constant Real'Base := R (2, 2)*V (2);
      subtype Row_Sum is Real range -1.0e282 .. 1.0e282;
      R0 : constant Real'Base := P00 + P01 + P02;
      R1 : constant Real'Base := P10 + P11 + P12;
      R2 : constant Real'Base := P20 + P21 + P22;
      Result : constant Vector := [R0, R1, R2];
   begin
      pragma Assert (Static => P00 in Product);
      pragma Assert (Static => P01 in Product);
      pragma Assert (Static => P02 in Product);
      pragma Assert (Static => P10 in Product);
      pragma Assert (Static => P11 in Product);
      pragma Assert (Static => P12 in Product);
      pragma Assert (Static => P20 in Product);
      pragma Assert (Static => P21 in Product);
      pragma Assert (Static => P22 in Product);
      pragma Assert (Static => R0 in Row_Sum);
      pragma Assert (Static => R1 in Row_Sum);
      pragma Assert (Static => R2 in Row_Sum);
      pragma Assert (Bounded (Result, 1.0e282));
      pragma Assert (Result (0) = R (0, 0)*V (0) + R (1, 0)*V (1) + R (2, 0)*V (2));
      pragma Assert (Result (1) = R (0, 1)*V (0) + R (1, 1)*V (1) + R (2, 1)*V (2));
      pragma Assert (Result (2) = R (0, 2)*V (0) + R (1, 2)*V (1) + R (2, 2)*V (2));
      return Result;
   end Apply_Transpose;

   --  Scalar-first Hamilton product. R(A*B) = R(A) R(B).
   --  Each product and accumulated component has its own proved static bound.
   function Multiply (A, B : Quaternion) return Quaternion is
      subtype Product is Real range -4.0 .. 4.0;
      P00 : constant Real'Base := A (0)*B (0);
      P11 : constant Real'Base := A (1)*B (1);
      P22 : constant Real'Base := A (2)*B (2);
      P33 : constant Real'Base := A (3)*B (3);
      P01 : constant Real'Base := A (0)*B (1);
      P10 : constant Real'Base := A (1)*B (0);
      P23 : constant Real'Base := A (2)*B (3);
      P32 : constant Real'Base := A (3)*B (2);
      P02 : constant Real'Base := A (0)*B (2);
      P13 : constant Real'Base := A (1)*B (3);
      P20 : constant Real'Base := A (2)*B (0);
      P31 : constant Real'Base := A (3)*B (1);
      P03 : constant Real'Base := A (0)*B (3);
      P12 : constant Real'Base := A (1)*B (2);
      P21 : constant Real'Base := A (2)*B (1);
      P30 : constant Real'Base := A (3)*B (0);
      subtype Component is Real range -32.0 .. 32.0;
      C0 : constant Real'Base := P00 - P11 - P22 - P33;
      C1 : constant Real'Base := P01 + P10 + P23 - P32;
      C2 : constant Real'Base := P02 - P13 + P20 + P31;
      C3 : constant Real'Base := P03 + P12 - P21 + P30;
      Result : constant Quaternion := [C0, C1, C2, C3];
   begin
      pragma Assert (Static => P00 in Product);
      pragma Assert (Static => P11 in Product);
      pragma Assert (Static => P22 in Product);
      pragma Assert (Static => P33 in Product);
      pragma Assert (Static => P01 in Product);
      pragma Assert (Static => P10 in Product);
      pragma Assert (Static => P23 in Product);
      pragma Assert (Static => P32 in Product);
      pragma Assert (Static => P02 in Product);
      pragma Assert (Static => P13 in Product);
      pragma Assert (Static => P20 in Product);
      pragma Assert (Static => P31 in Product);
      pragma Assert (Static => P03 in Product);
      pragma Assert (Static => P12 in Product);
      pragma Assert (Static => P21 in Product);
      pragma Assert (Static => P30 in Product);
      pragma Assert (Static => C0 in Component);
      pragma Assert (Static => C1 in Component);
      pragma Assert (Static => C2 in Component);
      pragma Assert (Static => C3 in Component);
      pragma Assert (Bounded (Result, 32.0));
      pragma Assert (Result (0) = A (0)*B (0) - A (1)*B (1) - A (2)*B (2) - A (3)*B (3));
      pragma Assert (Result (1) = A (0)*B (1) + A (1)*B (0) + A (2)*B (3) - A (3)*B (2));
      pragma Assert (Result (2) = A (0)*B (2) - A (1)*B (3) + A (2)*B (0) + A (3)*B (1));
      pragma Assert (Result (3) = A (0)*B (3) + A (1)*B (2) - A (2)*B (1) + A (3)*B (0));
      return Result;
   end Multiply;

   procedure Expose_Unit_Quaternion (Q : Quaternion) with Ghost => Static,
     Global => null, Pre => Unit_Quaternion (Q), Post => Bounded (Q, 1.000001)
   is
   begin
      null;
   end Expose_Unit_Quaternion;
   --  Preserve mju_quat2Mat's ordered binary64 diagonals. The algebraic
   --  unit-quaternion shortcut can perturb contact clipping by a few ULPs.
   function Rotation (Q : Quaternion) return Matrix is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
   begin
      Expose_Unit_Quaternion (Q);
      declare
      subtype Square is Real range 0.0 .. 2.0;
      subtype Product is Real range -2.0 .. 2.0;
      WW : constant Real'Base := Q (0)*Q (0);
      XX : constant Real'Base := Q (1)*Q (1);
      YY : constant Real'Base := Q (2)*Q (2);
      ZZ : constant Real'Base := Q (3)*Q (3);
      XY : constant Real'Base := Q (1)*Q (2);
      XZ : constant Real'Base := Q (1)*Q (3);
      YZ : constant Real'Base := Q (2)*Q (3);
      WX : constant Real'Base := Q (0)*Q (1);
      WY : constant Real'Base := Q (0)*Q (2);
      WZ : constant Real'Base := Q (0)*Q (3);
      subtype Component is Real range -8.0 .. 8.0;
      R00 : constant Real'Base := ((WW + XX) - YY) - ZZ;
      R01 : constant Real'Base := 2.0*(XY - WZ);
      R02 : constant Real'Base := 2.0*(XZ + WY);
      R10 : constant Real'Base := 2.0*(XY + WZ);
      R11 : constant Real'Base := ((WW - XX) + YY) - ZZ;
      R12 : constant Real'Base := 2.0*(YZ - WX);
      R20 : constant Real'Base := 2.0*(XZ - WY);
      R21 : constant Real'Base := 2.0*(YZ + WX);
      R22 : constant Real'Base := ((WW - XX) - YY) + ZZ;
      Result : constant Matrix :=
        [0 => [R00, R01, R02], 1 => [R10, R11, R12], 2 => [R20, R21, R22]];
   begin
      pragma Assert (Static => WW in Square);
      pragma Assert (Static => XX in Square);
      pragma Assert (Static => YY in Square);
      pragma Assert (Static => ZZ in Square);
      pragma Assert (Static => XY in Product);
      pragma Assert (Static => XZ in Product);
      pragma Assert (Static => YZ in Product);
      pragma Assert (Static => WX in Product);
      pragma Assert (Static => WY in Product);
      pragma Assert (Static => WZ in Product);
      pragma Assert (Static => R00 in Component);
      pragma Assert (Static => R01 in Component);
      pragma Assert (Static => R02 in Component);
      pragma Assert (Static => R10 in Component);
      pragma Assert (Static => R11 in Component);
      pragma Assert (Static => R12 in Component);
      pragma Assert (Static => R20 in Component);
      pragma Assert (Static => R21 in Component);
      pragma Assert (Static => R22 in Component);
      pragma Assert (Result (0, 0) = ((Q (0)*Q (0) + Q (1)*Q (1)) - Q (2)*Q (2)) - Q (3)*Q (3));
      pragma Assert (Result (0, 1) = 2.0*(Q (1)*Q (2) - Q (0)*Q (3)));
      pragma Assert (Result (0, 2) = 2.0*(Q (1)*Q (3) + Q (0)*Q (2)));
      pragma Assert (Result (1, 0) = 2.0*(Q (1)*Q (2) + Q (0)*Q (3)));
      pragma Assert (Result (1, 1) = ((Q (0)*Q (0) - Q (1)*Q (1)) + Q (2)*Q (2)) - Q (3)*Q (3));
      pragma Assert (Result (1, 2) = 2.0*(Q (2)*Q (3) - Q (0)*Q (1)));
      pragma Assert (Result (2, 0) = 2.0*(Q (1)*Q (3) - Q (0)*Q (2)));
      pragma Assert (Result (2, 1) = 2.0*(Q (2)*Q (3) + Q (0)*Q (1)));
      pragma Assert (Result (2, 2) = ((Q (0)*Q (0) - Q (1)*Q (1)) - Q (2)*Q (2)) + Q (3)*Q (3));
      return Result;
      end;
   end Rotation;

   function Axis_Angle (V : Vector; Angle : Real) return Quaternion is
      subtype Trig_Component is Real range -1.0 .. 1.0;
      subtype Axis_Component is Real range -1.000001 .. 1.000001;
      Half : constant Real := 0.5 * Angle;
      S : constant Trig_Component := Math.Sin (Half);
      C : constant Trig_Component := Math.Cos (Half);
      X : constant Axis_Component := S * V (0);
      Y : constant Axis_Component := S * V (1);
      Z : constant Axis_Component := S * V (2);
   begin
      return [C, X, Y, Z];
   end Axis_Angle;

   function Scaled_Vector (V : Vector) return Vector is
      Scale : constant Real := Scale_Of (V);
   begin
      pragma Assert (abs V (0) <= Scale and then abs V (1) <= Scale and then abs V (2) <= Scale);
      declare
         X : constant Unit_Component := Unit_Ratio (V (0), Scale);
         Y : constant Unit_Component := Unit_Ratio (V (1), Scale);
         Z : constant Unit_Component := Unit_Ratio (V (2), Scale);
      begin
         return [X, Y, Z];
      end;
   end Scaled_Vector;

   function Scaled_Quaternion (Q : Quaternion) return Quaternion is
      Scale : constant Real := Scale_Of (Q);
   begin
      pragma Assert (abs Q (0) <= Scale and then abs Q (1) <= Scale
                     and then abs Q (2) <= Scale and then abs Q (3) <= Scale);
      declare
         W : constant Unit_Component := Unit_Ratio (Q (0), Scale);
         X : constant Unit_Component := Unit_Ratio (Q (1), Scale);
         Y : constant Unit_Component := Unit_Ratio (Q (2), Scale);
         Z : constant Unit_Component := Unit_Ratio (Q (3), Scale);
      begin
         return [W, X, Y, Z];
      end;
   end Scaled_Quaternion;

   function Unit_Ratio (X, Scale : Real) return Unit_Component is (X / Scale);

   function Scaled_Norm (V : Vector) return Real is
      T : constant Vector := Scaled_Vector (V);
   begin
      return Math.Sqrt ((T (0)*T (0) + T (1)*T (1)) + T (2)*T (2));
   end Scaled_Norm;

   function Scaled_Norm (Q : Quaternion) return Real is
      T : constant Quaternion := Scaled_Quaternion (Q);
   begin
      return Math.Sqrt (((T (0)*T (0) + T (1)*T (1)) + T (2)*T (2)) + T (3)*T (3));
   end Scaled_Norm;

   procedure Normalize (V : in out Vector; Success : out Boolean) is
      Norm : Real;
      Temp : Vector := Zero;
   begin
      Success := False;
      if not Bounded (V) or else Scale_Of (V) = 0.0 then
         return;
      end if;
      Temp := Scaled_Vector (V);
      Norm := Scaled_Norm (V);
      if Norm < 1.0 or else Norm > 2.0 then
         return;
      end if;
      Temp := [Temp (0)/Norm, Temp (1)/Norm, Temp (2)/Norm];
      if not Unit_Vector (Temp) then
         return;
      end if;
      V := Temp;
      Success := True;
   end Normalize;

   procedure Normalize (Q : in out Quaternion; Success : out Boolean) is
      Norm : Real;
      Temp : Quaternion := [others => 0.0];
   begin
      Success := False;
      if not Bounded (Q, Work_Limit) or else Scale_Of (Q) < Min_Val then
         return;
      end if;
      Temp := Scaled_Quaternion (Q);
      Norm := Scaled_Norm (Q);
      if Norm < 1.0 or else Norm > 2.0 then
         return;
      end if;
      Temp := [Temp (0)/Norm, Temp (1)/Norm, Temp (2)/Norm, Temp (3)/Norm];
      if not Unit_Quaternion (Temp) then
         return;
      end if;
      Q := Temp;
      Success := True;
   end Normalize;

   function Read_Vector (A : Real_Array; Offset : Natural) return Vector is
     ([A (Offset), A (Offset + 1), A (Offset + 2)]);
   function Read_Quaternion (A : Real_Array; Offset : Natural) return Quaternion is
     ([A (Offset), A (Offset + 1), A (Offset + 2), A (Offset + 3)]);
   procedure Write_Vector (A : in out Real_Array; Offset : Natural; V : Vector) is
   begin
      for K in Axis loop
         A (Offset + K) := V (K);
         pragma Loop_Invariant
           (for all I in A'Range =>
              (if I in Offset .. Offset + K then A (I) = V (I - Offset)
               else A (I) = A'Loop_Entry (I)));
      end loop;
   end Write_Vector;
end MJ.Smooth_Math;

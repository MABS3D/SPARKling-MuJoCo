with Ada.Numerics.Long_Elementary_Functions;
with MJ.BLAS;
with MJ.Matrix_Types;
with MJ.Matrices;
with MJ.Quaternions;

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
      --  Typed intermediate products give each subtraction a local bound;
      --  they preserve the specified floating-point evaluation order.
      subtype Product is Real range -2.0e300 .. 2.0e300;
      P12 : constant Product := A (1) * B (2);
      P21 : constant Product := A (2) * B (1);
      P20 : constant Product := A (2) * B (0);
      P02 : constant Product := A (0) * B (2);
      P01 : constant Product := A (0) * B (1);
      P10 : constant Product := A (1) * B (0);
      Result : constant Vector := [P12 - P21, P20 - P02, P01 - P10];
   begin
      pragma Assert (Result (0) = A (1)*B (2) - A (2)*B (1));
      pragma Assert (Result (1) = A (2)*B (0) - A (0)*B (2));
      pragma Assert (Result (2) = A (0)*B (1) - A (1)*B (0));
      return Result;
   end Cross;

   function Apply (R : Matrix; V : Vector) return Vector is
      function Wide return Vector is
         subtype Product is Real range -2.0e281 .. 2.0e281;
         P00 : constant Product := R (0, 0)*V (0);
         P01 : constant Product := R (0, 1)*V (1);
         P02 : constant Product := R (0, 2)*V (2);
         P10 : constant Product := R (1, 0)*V (0);
         P11 : constant Product := R (1, 1)*V (1);
         P12 : constant Product := R (1, 2)*V (2);
         P20 : constant Product := R (2, 0)*V (0);
         P21 : constant Product := R (2, 1)*V (1);
         P22 : constant Product := R (2, 2)*V (2);
         subtype Row_Sum is Real range -1.0e282 .. 1.0e282;
         R0 : constant Row_Sum := P00 + P01 + P02;
         R1 : constant Row_Sum := P10 + P11 + P12;
         R2 : constant Row_Sum := P20 + P21 + P22;
         Result : constant Vector := [R0, R1, R2];
      begin
         pragma Assert (Bounded (Result, 1.0e282));
         pragma Assert (Result (0) = R (0, 0)*V (0) + R (0, 1)*V (1) + R (0, 2)*V (2));
         pragma Assert (Result (1) = R (1, 0)*V (0) + R (1, 1)*V (1) + R (1, 2)*V (2));
         pragma Assert (Result (2) = R (2, 0)*V (0) + R (2, 1)*V (1) + R (2, 2)*V (2));
         return Result;
      end Wide;
   begin
      --  Production contracts admit Tier0 inputs. Preserve the original wider
      --  domain without narrowing callers or suppressing precondition checks.
      if Bounded (V, Tier0_Real'Last) then
         declare
            Expected : constant Vector := Wide with Ghost => Static;
            Result : MJ.BLAS.Vector_3;
         begin
            MJ.Matrices.MulMatVec3
              (Result, MJ.Matrix_Types.Matrix_3 (R), MJ.BLAS.Vector_3 (V));
            pragma Assert (Static => Result (0) = Expected (0));
            pragma Assert (Static => Result (1) = Expected (1));
            pragma Assert (Static => Result (2) = Expected (2));
            return Vector (Result);
         end;
      end if;
      return Wide;
   end Apply;

   function Apply_Transpose (R : Matrix; V : Vector) return Vector is
      function Wide return Vector is
         subtype Product is Real range -2.0e281 .. 2.0e281;
         P00 : constant Product := R (0, 0)*V (0);
         P01 : constant Product := R (1, 0)*V (1);
         P02 : constant Product := R (2, 0)*V (2);
         P10 : constant Product := R (0, 1)*V (0);
         P11 : constant Product := R (1, 1)*V (1);
         P12 : constant Product := R (2, 1)*V (2);
         P20 : constant Product := R (0, 2)*V (0);
         P21 : constant Product := R (1, 2)*V (1);
         P22 : constant Product := R (2, 2)*V (2);
         subtype Row_Sum is Real range -1.0e282 .. 1.0e282;
         R0 : constant Row_Sum := P00 + P01 + P02;
         R1 : constant Row_Sum := P10 + P11 + P12;
         R2 : constant Row_Sum := P20 + P21 + P22;
         Result : constant Vector := [R0, R1, R2];
      begin
         pragma Assert (Bounded (Result, 1.0e282));
         pragma Assert (Result (0) = R (0, 0)*V (0) + R (1, 0)*V (1) + R (2, 0)*V (2));
         pragma Assert (Result (1) = R (0, 1)*V (0) + R (1, 1)*V (1) + R (2, 1)*V (2));
         pragma Assert (Result (2) = R (0, 2)*V (0) + R (1, 2)*V (1) + R (2, 2)*V (2));
         return Result;
      end Wide;
   begin
      --  Production contracts admit Tier0 inputs. Preserve the original wider
      --  domain without narrowing callers or suppressing precondition checks.
      if Bounded (V, Tier0_Real'Last) then
         declare
            Expected : constant Vector := Wide with Ghost => Static;
            Result : MJ.BLAS.Vector_3;
         begin
            MJ.Matrices.MulMatTVec3
              (Result, MJ.Matrix_Types.Matrix_3 (R), MJ.BLAS.Vector_3 (V));
            pragma Assert (Static => Result (0) = Expected (0));
            pragma Assert (Static => Result (1) = Expected (1));
            pragma Assert (Static => Result (2) = Expected (2));
            return Vector (Result);
         end;
      end if;
      return Wide;
   end Apply_Transpose;

   --  The production kernel uses the same rounded Hamilton expressions.
   function Multiply (A, B : Quaternion) return Quaternion is
      --  Ghost intermediate bounds retain the prototype's stronger range
      --  contract while the executable result comes from the Gold kernel.
      subtype Product is Real range -4.0 .. 4.0;
      P00 : constant Product := A (0)*B (0) with Ghost => Static;
      P11 : constant Product := A (1)*B (1) with Ghost => Static;
      P22 : constant Product := A (2)*B (2) with Ghost => Static;
      P33 : constant Product := A (3)*B (3) with Ghost => Static;
      P01 : constant Product := A (0)*B (1) with Ghost => Static;
      P10 : constant Product := A (1)*B (0) with Ghost => Static;
      P23 : constant Product := A (2)*B (3) with Ghost => Static;
      P32 : constant Product := A (3)*B (2) with Ghost => Static;
      P02 : constant Product := A (0)*B (2) with Ghost => Static;
      P13 : constant Product := A (1)*B (3) with Ghost => Static;
      P20 : constant Product := A (2)*B (0) with Ghost => Static;
      P31 : constant Product := A (3)*B (1) with Ghost => Static;
      P03 : constant Product := A (0)*B (3) with Ghost => Static;
      P12 : constant Product := A (1)*B (2) with Ghost => Static;
      P21 : constant Product := A (2)*B (1) with Ghost => Static;
      P30 : constant Product := A (3)*B (0) with Ghost => Static;
      subtype Component is Real range -32.0 .. 32.0;
      C0 : constant Component := P00 - P11 - P22 - P33 with Ghost => Static;
      C1 : constant Component := P01 + P10 + P23 - P32 with Ghost => Static;
      C2 : constant Component := P02 - P13 + P20 + P31 with Ghost => Static;
      C3 : constant Component := P03 + P12 - P21 + P30 with Ghost => Static;
      Result : constant Quaternion := [C0, C1, C2, C3] with Ghost => Static;
      Core_A : constant MJ.Quaternions.Quaternion := [A (0), A (1), A (2), A (3)];
      Core_B : constant MJ.Quaternions.Quaternion := [B (0), B (1), B (2), B (3)];
      R : constant MJ.Quaternions.Quaternion := MJ.Quaternions.Product (Core_A, Core_B);
   begin
      pragma Assert (Static => Bounded (Result, 32.0));
      pragma Assert (Static => Result (0) = A (0)*B (0) - A (1)*B (1) - A (2)*B (2) - A (3)*B (3));
      pragma Assert (Static => Result (1) = A (0)*B (1) + A (1)*B (0) + A (2)*B (3) - A (3)*B (2));
      pragma Assert (Static => Result (2) = A (0)*B (2) - A (1)*B (3) + A (2)*B (0) + A (3)*B (1));
      pragma Assert (Static => Result (3) = A (0)*B (3) + A (1)*B (2) - A (2)*B (1) + A (3)*B (0));
      pragma Assert (Static => R (0) = C0);
      pragma Assert (Static => R (1) = C1);
      pragma Assert (Static => R (2) = C2);
      pragma Assert (Static => R (3) = C3);
      return [R (0), R (1), R (2), R (3)];
   end Multiply;

   function Rotation (Q : Quaternion) return Matrix is
      subtype Square is Real range 0.0 .. 2.0;
      subtype Product is Real range -2.0 .. 2.0;
      XX : constant Square := Q (1)*Q (1);
      YY : constant Square := Q (2)*Q (2);
      ZZ : constant Square := Q (3)*Q (3);
      XY : constant Product := Q (1)*Q (2);
      XZ : constant Product := Q (1)*Q (3);
      YZ : constant Product := Q (2)*Q (3);
      WX : constant Product := Q (0)*Q (1);
      WY : constant Product := Q (0)*Q (2);
      WZ : constant Product := Q (0)*Q (3);
      subtype Component is Real range -8.0 .. 8.0;
      R00 : constant Component := 1.0 - 2.0*(YY + ZZ);
      R01 : constant Component := 2.0*(XY - WZ);
      R02 : constant Component := 2.0*(XZ + WY);
      R10 : constant Component := 2.0*(XY + WZ);
      R11 : constant Component := 1.0 - 2.0*(XX + ZZ);
      R12 : constant Component := 2.0*(YZ - WX);
      R20 : constant Component := 2.0*(XZ - WY);
      R21 : constant Component := 2.0*(YZ + WX);
      R22 : constant Component := 1.0 - 2.0*(XX + YY);
      Result : constant Matrix :=
        [0 => [R00, R01, R02], 1 => [R10, R11, R12], 2 => [R20, R21, R22]];
   begin
      pragma Assert (Result (0, 0) = 1.0 - 2.0*(Q (2)*Q (2) + Q (3)*Q (3)));
      pragma Assert (Result (0, 1) = 2.0*(Q (1)*Q (2) - Q (0)*Q (3)));
      pragma Assert (Result (0, 2) = 2.0*(Q (1)*Q (3) + Q (0)*Q (2)));
      pragma Assert (Result (1, 0) = 2.0*(Q (1)*Q (2) + Q (0)*Q (3)));
      pragma Assert (Result (1, 1) = 1.0 - 2.0*(Q (1)*Q (1) + Q (3)*Q (3)));
      pragma Assert (Result (1, 2) = 2.0*(Q (2)*Q (3) - Q (0)*Q (1)));
      pragma Assert (Result (2, 0) = 2.0*(Q (1)*Q (3) - Q (0)*Q (2)));
      pragma Assert (Result (2, 1) = 2.0*(Q (2)*Q (3) + Q (0)*Q (1)));
      pragma Assert (Result (2, 2) = 1.0 - 2.0*(Q (1)*Q (1) + Q (2)*Q (2)));
      return Result;
   end Rotation;

   function Axis_Angle (V : Vector; Angle : Real) return Quaternion is
      Half : constant Real := 0.5 * Angle;
      S : constant Real := Math.Sin (Half);
   begin
      return [Math.Cos (Half), S * V (0), S * V (1), S * V (2)];
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

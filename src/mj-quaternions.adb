package body MJ.Quaternions with SPARK_Mode is
   procedure Set_Identity (R : out Quaternion) is
   begin
      R := Identity;
   end Set_Identity;

   procedure Conjugate (R : out Quaternion; Q : Quaternion) is
   begin
      R := [Q (W), -Q (X), -Q (Y), -Q (Z)];
   end Conjugate;

   procedure Conjugate (Q : in out Quaternion) is
   begin
      Q (X) := -Q (X);
      Q (Y) := -Q (Y);
      Q (Z) := -Q (Z);
   end Conjugate;

   function Product_Component (A, B : Quaternion; I : Component) return Tier1_Real with
     Inline_Always, Global => null, Pre => In_Tier0 (A) and then In_Tier0 (B),
     Post => (Static => Product_Component'Result = Model.Product_Component (A, B, I))
   is
   begin
      case I is
         when W => return ((A (0)*B (0) - A (1)*B (1)) - A (2)*B (2)) - A (3)*B (3);
         when X => return ((A (0)*B (1) + A (1)*B (0)) + A (2)*B (3)) - A (3)*B (2);
         when Y => return ((A (0)*B (2) - A (1)*B (3)) + A (2)*B (0)) + A (3)*B (1);
         when Z => return ((A (0)*B (3) + A (1)*B (2)) - A (2)*B (1)) + A (3)*B (0);
      end case;
   end Product_Component;

   procedure Multiply (R : out Quaternion; A, B : Quaternion) is
   begin
      R := [Product_Component (A, B, W), Product_Component (A, B, X),
            Product_Component (A, B, Y), Product_Component (A, B, Z)];
   end Multiply;

   function Product (A, B : Quaternion) return Quaternion is
      R : Quaternion;
   begin
      Multiply (R, A, B);
      return R;
   end Product;

   procedure Multiply (Q : in out Quaternion; Right : Quaternion) is
      Previous : constant Quaternion := Q;
   begin
      Multiply (Q, Previous, Right);
   end Multiply;

   subtype Squared_Length is Tier2_Real range 0.0 .. Tier2_Real'Last;
   function Squared_Norm (Q : Quaternion) return Squared_Length with
     Inline_Always, Global => null, Pre => In_Tier1 (Q),
     Post => Squared_Norm'Result =
       (((Q (W)*Q (W) + Q (X)*Q (X)) + Q (Y)*Q (Y)) + Q (Z)*Q (Z))
   is
      subtype Square_Value is Real range 0.0 .. 2.0e60;
      type Square_Array is array (Component) of Square_Value;
      Squares : Square_Array;
   begin
      for I in Component loop
         pragma Loop_Optimize (Vector);
         Squares (I) := Q (I) * Q (I);
      end loop;
      --  The sum is nonnegative; abs also exposes that fact to the optimizer.
      return abs (((Squares (W) + Squares (X)) + Squares (Y)) + Squares (Z));
   end Squared_Norm;

   function Norm (Q : Quaternion) return Nonnegative_Real is
   begin
      return MJ.Quaternion_Math.Sqrt
        (((Q (W)*Q (W) + Q (X)*Q (X)) + Q (Y)*Q (Y)) + Q (Z)*Q (Z));
   end Norm;

   function Scale_Component (Value : Tier1_Real; Inv : Real) return Tier2_Real with
     Inline_Always, Global => null, Pre => Inv in 0.0 .. 1.0e15,
     Post => Scale_Component'Result = Value * Inv
       and then (if Value in Tier0_Real then Scale_Component'Result in Tier1_Real)
   is
   begin
      return Value * Inv;
   end Scale_Component;

   procedure Normalize (Q : in out Quaternion; Length : out Nonnegative_Real) is
      Original : constant Quaternion := Q;
      Squared : constant Squared_Length := Squared_Norm (Original);
      Inv : Real;
   begin
      --  Both identities are supplied by the standard runtime contract.
      if Squared = 0.0 then
         Length := 0.0;
         Q := Identity;
      elsif Squared = 1.0 then
         Length := 1.0;
      else
         Length := MJ.Quaternion_Math.Sqrt (Squared);
         if Length < Min_Val then
            Q := Identity;
         elsif abs (Length - 1.0) > Min_Val then
            Inv := 1.0 / Length;
            Q := [Scale_Component (Original (W), Inv), Scale_Component (Original (X), Inv),
                  Scale_Component (Original (Y), Inv), Scale_Component (Original (Z), Inv)];
         end if;
      end if;
      pragma Assert (Static => Q (W) in Tier2_Real);
      pragma Assert (Static => Q (X) in Tier2_Real);
      pragma Assert (Static => Q (Y) in Tier2_Real);
      pragma Assert (Static => Q (Z) in Tier2_Real);
   end Normalize;

   function Rotation_Intermediate (Q : Quaternion; V : Vector_3; I : Axis) return Tier1_Real with
     Inline_Always, Global => null, Pre => In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => Rotation_Intermediate'Result = Model.Rotation_Intermediate (Q, V, I))
   is
   begin
      case I is
         when 0 => return (Q (0)*V (0) + Q (2)*V (2)) - Q (3)*V (1);
         when 1 => return (Q (0)*V (1) + Q (3)*V (0)) - Q (1)*V (2);
         when 2 => return (Q (0)*V (2) + Q (1)*V (1)) - Q (2)*V (0);
      end case;
   end Rotation_Intermediate;

   function Complete_Rotation (Value, A, B : Tier0_Real; TA, TB : Tier1_Real) return Tier2_Real with
     Inline_Always, Global => null,
     Post => Complete_Rotation'Result = Value + 2.0 * (A * TA - B * TB)
   is
   begin
      return Value + 2.0 * (A * TA - B * TB);
   end Complete_Rotation;

   procedure Rotate (R : out Vector_3; Q : Quaternion; V : Vector_3) is
   begin
      if V (0) = 0.0 and then V (1) = 0.0 and then V (2) = 0.0 then
         R := [0.0, 0.0, 0.0];
      elsif Is_Identity (Q) then
         R := V;
      else
         declare
            T0 : constant Tier1_Real := Rotation_Intermediate (Q, V, 0);
            T1 : constant Tier1_Real := Rotation_Intermediate (Q, V, 1);
            T2 : constant Tier1_Real := Rotation_Intermediate (Q, V, 2);
         begin
            R := [Complete_Rotation (V (0), Q (2), Q (3), T2, T1),
                  Complete_Rotation (V (1), Q (3), Q (1), T0, T2),
                  Complete_Rotation (V (2), Q (1), Q (2), T1, T0)];
         end;
      end if;
      pragma Assert (Static => R (0) = Model.Rotated_Component (Q, V, 0));
      pragma Assert (Static => R (1) = Model.Rotated_Component (Q, V, 1));
      pragma Assert (Static => R (2) = Model.Rotated_Component (Q, V, 2));
   end Rotate;

   --  The public procedure handles identity before calling these scalar cells.
   --  Inlining folds I/J and lets the compiler share the ten pair products.
   function Matrix_Component (Q : Quaternion; I, J : Axis) return Tier1_Real with
     Inline_Always, Global => null, Pre => In_Tier0 (Q) and then not Is_Identity (Q),
     Post => (Static => Matrix_Component'Result = Model.Matrix_Component (Q, I, J))
   is
   begin
      case 3 * I + J is
         when 0 => return ((Q (0)*Q (0) + Q (1)*Q (1)) - Q (2)*Q (2)) - Q (3)*Q (3);
         when 1 => return 2.0 * (Q (1)*Q (2) - Q (0)*Q (3));
         when 2 => return 2.0 * (Q (1)*Q (3) + Q (0)*Q (2));
         when 3 => return 2.0 * (Q (1)*Q (2) + Q (0)*Q (3));
         when 4 => return ((Q (0)*Q (0) - Q (1)*Q (1)) + Q (2)*Q (2)) - Q (3)*Q (3);
         when 5 => return 2.0 * (Q (2)*Q (3) - Q (0)*Q (1));
         when 6 => return 2.0 * (Q (1)*Q (3) - Q (0)*Q (2));
         when 7 => return 2.0 * (Q (2)*Q (3) + Q (0)*Q (1));
         when others => return ((Q (0)*Q (0) - Q (1)*Q (1)) - Q (2)*Q (2)) + Q (3)*Q (3);
      end case;
   end Matrix_Component;

   procedure To_Matrix (R : out Matrix_3; Q : Quaternion) is
   begin
      if Is_Identity (Q) then
         R := [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]];
      else
         R := [[Matrix_Component (Q, 0, 0), Matrix_Component (Q, 0, 1), Matrix_Component (Q, 0, 2)],
               [Matrix_Component (Q, 1, 0), Matrix_Component (Q, 1, 1), Matrix_Component (Q, 1, 2)],
               [Matrix_Component (Q, 2, 0), Matrix_Component (Q, 2, 1), Matrix_Component (Q, 2, 2)]];
      end if;
   end To_Matrix;

   function Select_Matrix_Branch (D0, D1, D2 : Tier0_Real) return Component with
     Inline_Always, Global => null,
     Post => (Static => Select_Matrix_Branch'Result = Model.Matrix_Branch (D0, D1, D2))
   is
   begin
      if (D0 + D1) + D2 > 0.0 then
         return W;
      elsif D0 > D1 and then D0 > D2 then
         return X;
      elsif D1 > D2 then
         return Y;
      else
         return Z;
      end if;
   end Select_Matrix_Branch;

   function Conversion_Radicand (D0, D1, D2 : Tier0_Real;
                                Branch : Component) return Real with
     Inline_Always, Global => null,
     Pre => (Static => Branch = Model.Matrix_Branch (D0, D1, D2)),
     Post => (Static => Conversion_Radicand'Result = Model.Matrix_Radicand (D0, D1, D2, Branch))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Matrix_Radicand);
   begin
      case Branch is
         when W => return ((1.0 + D0) + D1) + D2;
         when X => return ((1.0 + D0) - D1) - D2;
         when Y => return ((1.0 - D0) + D1) - D2;
         when Z => return ((1.0 - D0) - D1) + D2;
      end case;
   end Conversion_Radicand;

   function Conversion_Quotient (Numerator, Denominator : Real) return Tier1_Real with
     Inline_Always, Global => null,
     Pre => Numerator in -1.0e15 .. 1.0e15 and then Denominator in Min_Val .. 1.0e15,
     Post => Conversion_Quotient'Result = Numerator / Denominator
       and then (if Denominator = 1.0 then Conversion_Quotient'Result = Numerator)
   is
   begin
      return Numerator / Denominator;
   end Conversion_Quotient;

   procedure Convert_Raw (R : out Quaternion; A : Matrix_3;
                          Branch : Component; Pivot : Real) with
     Inline_Always, Global => null,
     Pre => (Static => MJ.Matrix_Types.In_Tier0 (A) and then Pivot in Min_Val .. 1.0e15
       and then Branch = Model.Matrix_Branch (A (0, 0), A (1, 1), A (2, 2))),
     Post => (Static => In_Tier1 (R) and then R = Model.Matrix_Raw (A, Pivot))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Matrix_Raw);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Matrix_Quotient);
   begin
      declare
         subtype Numerator_Value is Real range -1.0e15 .. 1.0e15;
         subtype Denominator_Value is Real range Min_Val .. 1.0e15;
         type Numerator_Array is array (Component) of Numerator_Value;
         type Denominator_Array is array (Component) of Denominator_Value;
         Numerator : Numerator_Array;
         Denominator : Denominator_Array;
      begin
         case Branch is
            when W =>
               Numerator := [Pivot, 0.25 * (A (2, 1) - A (1, 2)),
                 0.25 * (A (0, 2) - A (2, 0)), 0.25 * (A (1, 0) - A (0, 1))];
               Denominator := [1.0, Pivot, Pivot, Pivot];
            when X =>
               Numerator := [0.25 * (A (2, 1) - A (1, 2)), Pivot,
                 0.25 * (A (0, 1) + A (1, 0)), 0.25 * (A (0, 2) + A (2, 0))];
               Denominator := [Pivot, 1.0, Pivot, Pivot];
            when Y =>
               Numerator := [0.25 * (A (0, 2) - A (2, 0)),
                 0.25 * (A (0, 1) + A (1, 0)), Pivot, 0.25 * (A (1, 2) + A (2, 1))];
               Denominator := [Pivot, Pivot, 1.0, Pivot];
            when Z =>
               Numerator := [0.25 * (A (1, 0) - A (0, 1)),
                 0.25 * (A (0, 2) + A (2, 0)), 0.25 * (A (1, 2) + A (2, 1)), Pivot];
               Denominator := [Pivot, Pivot, Pivot, 1.0];
         end case;
         --  The dominant lane divides Pivot by one; the other three retain
         --  C's multiplication-before-division expressions. Packing all four
         --  divisions allows SIMD without reciprocal approximations.
         for I in Component loop
            pragma Loop_Optimize (Vector);
            R (I) := Conversion_Quotient (Numerator (I), Denominator (I));
         end loop;
         pragma Assert (Static => In_Tier1 (R));
         declare
            Expected : constant Quaternion := Model.Matrix_Raw (A, Pivot) with Ghost => Static;
         begin
            pragma Assert (Static => R (W) = Expected (W));
            pragma Assert (Static => R (X) = Expected (X));
            pragma Assert (Static => R (Y) = Expected (Y));
            pragma Assert (Static => R (Z) = Expected (Z));
         end;
      end;
   end Convert_Raw;

   function Conversion_Length (Q : Quaternion) return Nonnegative_Real with
     Inline_Always, Global => null, Pre => In_Tier1 (Q),
     Post => (Static => Conversion_Length'Result = Model.Normalization_Length (Q))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalization_Length);
      Squares : Quaternion;
      Sum : Real;
   begin
      for I in Component loop
         pragma Loop_Optimize (Vector);
         Squares (I) := Q (I) * Q (I);
      end loop;
      Sum := ((Squares (W) + Squares (X)) + Squares (Y)) + Squares (Z);
      return MJ.Quaternion_Math.Sqrt (abs Sum);
   end Conversion_Length;

   --  Pack independent squares into SIMD lanes, but retain C's ordered sum
   --  and norm/threshold path. The public Normalize's additional zero/one
   --  dispatch costs more here. Both implement the same normalization model.
   procedure Normalize_Conversion (Q : in out Quaternion) with
     Inline_Always, Global => null, Pre => In_Tier1 (Q),
     Post => (Static => In_Tier2 (Q) and then Q = Model.Normalized (Q'Old))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalized);
      Original : constant Quaternion := Q;
      Expected : constant Quaternion := Model.Normalized (Original) with Ghost => Static;
      Length : constant Nonnegative_Real := Conversion_Length (Original);
      Inv : Real range 0.0 .. 1.0e15;
   begin
      if Length < Min_Val then
         Q := Identity;
      elsif abs (Length - 1.0) > Min_Val then
         Inv := 1.0 / Length;
         Q := [Scale_Component (Original (W), Inv), Scale_Component (Original (X), Inv),
               Scale_Component (Original (Y), Inv), Scale_Component (Original (Z), Inv)];
      end if;
      pragma Assert (Static => Q (W) = Expected (W));
      pragma Assert (Static => Q (X) = Expected (X));
      pragma Assert (Static => Q (Y) = Expected (Y));
      pragma Assert (Static => Q (Z) = Expected (Z));
   end Normalize_Conversion;

   --  Array equality is component-wise numerical equality, not identity of
   --  the prover's array objects. Prove that normalization respects it before
   --  substituting the independently specified raw quaternion at the caller.
   procedure Equal_Normalization (A, B : Quaternion) with
     Ghost => Static, Global => null,
     Pre => In_Tier1 (A) and then In_Tier1 (B) and then A = B,
     Post => Model.Normalized (A) = Model.Normalized (B)
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalized);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalization_Length);
   begin
      pragma Assert (Model.Normalization_Length (A) = Model.Normalization_Length (B));
      pragma Assert (Model.Normalized_Component (A, W) = Model.Normalized_Component (B, W));
      pragma Assert (Model.Normalized_Component (A, X) = Model.Normalized_Component (B, X));
      pragma Assert (Model.Normalized_Component (A, Y) = Model.Normalized_Component (B, Y));
      pragma Assert (Model.Normalized_Component (A, Z) = Model.Normalized_Component (B, Z));
   end Equal_Normalization;

   procedure From_Matrix (R : out Quaternion; A : Matrix_3;
                          Result : out Conversion_Status) is
      Branch : constant Component := Select_Matrix_Branch (A (0, 0), A (1, 1), A (2, 2));
      Radicand : constant Real := Conversion_Radicand (A (0, 0), A (1, 1), A (2, 2), Branch);
      --  Radicand is proved nonnegative. Abs is redundant numerically and lets
      --  the compiler discard the runtime elementary function's domain branch.
      Pivot : constant Nonnegative_Real := 0.5 * MJ.Quaternion_Math.Sqrt (abs Radicand);
      Raw : Quaternion;
   begin
      pragma Assert (Static => Pivot = Model.Matrix_Pivot (A));
      if Pivot not in Min_Val .. 1.0e15 then
         R := Identity;
         Result := Numeric_Limit;
         return;
      end if;
      Convert_Raw (Raw, A, Branch, Pivot);
      pragma Assert_And_Cut (Static => MJ.Matrix_Types.In_Tier0 (A)
        and then Model.Matrix_Conversion_Safe (A)
        and then In_Tier1 (Raw)
        and then Raw = Model.Matrix_Raw (A, Model.Matrix_Pivot (A)));
      Equal_Normalization (Raw, Model.Matrix_Raw (A, Model.Matrix_Pivot (A)));
      R := Raw;
      Normalize_Conversion (R);
      Result := Success;
   end From_Matrix;
end MJ.Quaternions;

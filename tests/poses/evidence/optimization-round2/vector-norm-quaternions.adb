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
      return MJ.Quaternion_Math.Sqrt (Squared_Norm (Q));
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
end MJ.Quaternions;

package body MJ.Poses with SPARK_Mode is

   function Intermediate (Q : Quaternion; V : Vector_3; I : Axis) return Tier1_Real with
     Inline_Always, Global => null,
     Pre => MJ.Quaternions.In_Tier0 (Q) and then MJ.BLAS.In_Tier0 (V),
     Post => (Static => Intermediate'Result = MJ.Quaternions.Model.Rotation_Intermediate (Q, V, I))
   is
   begin
      case I is
         when 0 => return (Q (0)*V (0) + Q (2)*V (2)) - Q (3)*V (1);
         when 1 => return (Q (0)*V (1) + Q (3)*V (0)) - Q (1)*V (2);
         when 2 => return (Q (0)*V (2) + Q (1)*V (1)) - Q (2)*V (0);
      end case;
   end Intermediate;

   function Complete_Transform
     (Value, Position, A, B : Tier0_Real; TA, TB : Tier1_Real) return Tier3_Real with
     Inline_Always, Global => null,
     Post => (Static => Complete_Transform'Result =
       (Value + 2.0 * (A * TA - B * TB)) + Position)
   is
   begin
      return (Value + 2.0 * (A * TA - B * TB)) + Position;
   end Complete_Transform;

   procedure Transform (R : out Vector_3; Position : Vector_3; Q : Quaternion; Point : Vector_3) is
      --  Intermediate proves the scalar formula separately; use its relation
      --  here without expanding that formula again in every caller check.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body",
                       MJ.Quaternions.Model.Rotation_Intermediate);
   begin
      --  The reference correction is zero for every finite scalar quaternion.
      if Q (1) = 0.0 and then Q (2) = 0.0 and then Q (3) = 0.0 then
         declare
            D0 : constant Tier3_Real := Point (0) + Position (0);
            D1 : constant Tier3_Real := Point (1) + Position (1);
            D2 : constant Tier3_Real := Point (2) + Position (2);
         begin
            R (0) := D0; R (1) := D1; R (2) := D2;
            pragma Assert (Static => R'Initialized);
            pragma Assert (Static => (for all I in Axis => R (I) in Tier3_Real));
            pragma Assert (Static => R (0) = Model.Transformed_Component (Position, Q, Point, 0));
            pragma Assert (Static => R (1) = Model.Transformed_Component (Position, Q, Point, 1));
            pragma Assert (Static => R (2) = Model.Transformed_Component (Position, Q, Point, 2));
         end;
      else
         --  Fused stores expose independent coordinates to SLP. The shared
         --  ghost model still fixes every operation and its evaluation order.
         declare
            T0 : constant Tier1_Real := Intermediate (Q, Point, 0);
            T1 : constant Tier1_Real := Intermediate (Q, Point, 1);
            T2 : constant Tier1_Real := Intermediate (Q, Point, 2);
            D0 : constant Tier3_Real := Complete_Transform (Point (0), Position (0), Q (2), Q (3), T2, T1);
            D1 : constant Tier3_Real := Complete_Transform (Point (1), Position (1), Q (3), Q (1), T0, T2);
            D2 : constant Tier3_Real := Complete_Transform (Point (2), Position (2), Q (1), Q (2), T1, T0);
         begin
            R (0) := D0; R (1) := D1; R (2) := D2;
            pragma Assert (Static => R'Initialized);
            pragma Assert (Static => (for all I in Axis => R (I) in Tier3_Real));
            pragma Assert (Static => R (0) = Model.Transformed_Component (Position, Q, Point, 0));
            pragma Assert (Static => R (1) = Model.Transformed_Component (Position, Q, Point, 1));
            pragma Assert (Static => R (2) = Model.Transformed_Component (Position, Q, Point, 2));
         end;
      end if;
   end Transform;

   procedure Transform (Point : in out Vector_3; Position : Vector_3; Q : Quaternion) is
      Previous : constant Vector_3 := Point;
   begin
      Transform (Point, Position, Q, Previous);
   end Transform;

   function Scaled_Value (Value : Tier1_Real; Inv : Real) return Tier2_Real with
     Inline_Always, Global => null, Pre => Inv in 0.0 .. 1.0e15,
     Post => (Static => Scaled_Value'Result = Value * Inv)
   is
   begin
      return Value * Inv;
   end Scaled_Value;

   procedure Normalize (Q : in out Quaternion) with
     Inline_Always, Global => null, Pre => MJ.Quaternions.In_Tier1 (Q),
     Post => (Static => MJ.Quaternions.In_Tier2 (Q) and then
       Q = Model.Normalized (Q'Old));
   procedure Normalize (Q : in out Quaternion) is
      Original : constant Quaternion := Q;
      Length : constant MJ.Quaternions.Nonnegative_Real := MJ.Quaternions.Norm (Original);
      Inv : Real range 0.0 .. 1.0e15;
   begin
      --  Composition already computes a product. Extra exact-length branches
      --  obstruct its combined SIMD path, so use the reference branch order.
      if Length < Min_Val then
         Q := MJ.Quaternions.Identity;
      elsif abs (Length - 1.0) > Min_Val then
         Inv := 1.0 / Length;
         Q := [Scaled_Value (Original (0), Inv), Scaled_Value (Original (1), Inv),
               Scaled_Value (Original (2), Inv), Scaled_Value (Original (3), Inv)];
      end if;
      pragma Assert (Static => Q (0) in Tier2_Real);
      pragma Assert (Static => Q (1) in Tier2_Real);
      pragma Assert (Static => Q (2) in Tier2_Real);
      pragma Assert (Static => Q (3) in Tier2_Real);
   end Normalize;

   procedure Compose
     (Position : out Vector_3; Q : out Quaternion;
      Position_1 : Vector_3; Q1 : Quaternion; Position_2 : Vector_3; Q2 : Quaternion) is
      --  The scalar product formulas are already proved in MJ.Quaternions.
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model.Normalized);
   begin
      Q := MJ.Quaternions.Product (Q1, Q2);
      Normalize (Q);
      Transform (Position, Position_1, Q1, Position_2);
   end Compose;

   procedure Compose
     (Position : in out Vector_3; Q : in out Quaternion; Right_Position : Vector_3; Right_Q : Quaternion) is
      Previous_Position : constant Vector_3 := Position;
      Previous_Q : constant Quaternion := Q;
   begin
      Compose (Position, Q, Previous_Position, Previous_Q, Right_Position, Right_Q);
   end Compose;

   procedure Inverse
     (Position : out Vector_3; Q : out Quaternion; Source_Position : Vector_3; Source_Q : Quaternion) is
      Rotated : Vector_3;
   begin
      Q := MJ.Rotations.Conjugated (Source_Q);
      MJ.Quaternions.Rotate (Rotated, Q, Source_Position);
      Position (0) := -Rotated (0);
      Position (1) := -Rotated (1);
      Position (2) := -Rotated (2);
   end Inverse;

   procedure Inverse (Position : in out Vector_3; Q : in out Quaternion) is
      Previous_Position : constant Vector_3 := Position;
      Previous_Q : constant Quaternion := Q;
   begin
      Inverse (Position, Q, Previous_Position, Previous_Q);
   end Inverse;
end MJ.Poses;

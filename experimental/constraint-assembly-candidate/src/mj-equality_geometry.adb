package body MJ.Equality_Geometry with SPARK_Mode is
   function Anchor_Component
     (R0, R1, R2 : Rotation_Element; L0, L1, L2, Translation : Tier0_Real)
      return Anchor_Value is
   begin
      return ((R0*L0 + R1*L1) + R2*L2) + Translation;
   end Anchor_Component;

   function Product_Term (A, B : Product_Operand) return Product_Term_Value is
   begin
      return A*B;
   end Product_Term;

   function Product_W
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real is
   begin
      return ((Product_Term (A0, B0) - Product_Term (A1, B1)) - Product_Term (A2, B2)) - Product_Term (A3, B3);
   end Product_W;

   function Product_X
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real is
   begin
      return ((Product_Term (A0, B1) + Product_Term (A1, B0)) + Product_Term (A2, B3)) - Product_Term (A3, B2);
   end Product_X;

   function Product_Y
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real is
   begin
      return ((Product_Term (A0, B2) - Product_Term (A1, B3)) + Product_Term (A2, B0)) + Product_Term (A3, B1);
   end Product_Y;

   function Product_Z
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real is
   begin
      return ((Product_Term (A0, B3) + Product_Term (A1, B2)) - Product_Term (A2, B1)) + Product_Term (A3, B0);
   end Product_Z;

   function Product_At
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand; I : Component)
      return Tier2_Real is
   begin
      return (case I is
         when 0 => Product_W (A0, A1, A2, A3, B0, B1, B2, B3),
         when 1 => Product_X (A0, A1, A2, A3, B0, B1, B2, B3),
         when 2 => Product_Y (A0, A1, A2, A3, B0, B1, B2, B3),
         when 3 => Product_Z (A0, A1, A2, A3, B0, B1, B2, B3));
   end Product_At;

   function Axis_At
     (Q0, Q1, Q2, Q3 : Rotation_Element;
      V0, V1, V2 : Axis_Operand; I : Component) return Axis_Value is
   begin
      return (case I is
         when 0 => (Product_Term (-Q1, V0) - Product_Term (Q2, V1)) - Product_Term (Q3, V2),
         when 1 => (Product_Term (Q0, V0) + Product_Term (Q2, V2)) - Product_Term (Q3, V1),
         when 2 => (Product_Term (Q0, V1) + Product_Term (Q3, V0)) - Product_Term (Q1, V2),
         when 3 => (Product_Term (Q0, V2) + Product_Term (Q1, V1)) - Product_Term (Q2, V0));
   end Axis_At;

   function Anchor (R : Rotation; Local, Translation : Vector) return Vector is
   begin
      return [for I in Axis =>
        Anchor_Component (R (I, 0), R (I, 1), R (I, 2), Local (0), Local (1), Local (2), Translation (I))];
   end Anchor;

   function Multiply (A, B : Quaternion) return Quaternion is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Product);
   begin
      return Quaternion_Product_Value (A, B);
   end Multiply;

   function Multiply_Axis (Q : Quaternion; V : Vector) return Quaternion is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Axis_Product);
   begin
      return Axis_Product_Value (Q, V);
   end Multiply_Axis;

   function Position_Scale (Q : Position_Product; Torque : Tier0_Real)
      return Position_Value is
   begin
      return Q*Torque;
   end Position_Scale;

   function Jacobian_Scale (Q : Jacobian_Product; Torque : Tier0_Real)
      return Jacobian_Value is
   begin
      return (0.5*Q)*Torque;
   end Jacobian_Scale;

   function Rotation_Position (A, B : Quaternion; Torque : Tier0_Real) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Position);
      Q : constant Quaternion := Quaternion_Product_Value (Conjugate (B), A);
   begin
      return [for I in Axis => Position_Scale (Q (I+1), Torque)];
   end Rotation_Position;

   function Rotation_Jacobian (A, B : Quaternion; Omega : Vector; Torque : Tier0_Real) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Jacobian);
      U : constant Quaternion := Axis_Product_Value (Conjugate (B), Omega);
      Q : constant Quaternion := Quaternion_Product_Value (U, A);
   begin
      return [for I in Axis => Jacobian_Scale (Q (I+1), Torque)];
   end Rotation_Jacobian;

   function Rotation_Column
     (A, B : Quaternion; J0, J1 : CA.Matrix; C : Positive; Torque : Tier0_Real)
      return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Column_Jacobian);
   begin
      return Rotation_Jacobian (A, B,
        Angular_Difference (J0 (4, C), J0 (5, C), J0 (6, C),
                            J1 (4, C), J1 (5, C), J1 (6, C)), Torque);
   end Rotation_Column;

   procedure Connect
     (P0, P1 : Vector; J0, J1 : CA.Matrix; J : out CA.Matrix; Pos : out CA.Parameter_Array) is
   begin
      for R in 1 .. 3 loop
         Pos (R) := (P0 (R - 1) - P1 (R - 1), 0.0);
         for C in J'Range (2) loop
            J (R, C) := J0 (R, C) - J1 (R, C);
            pragma Loop_Invariant (Static => (for all I in 1 .. R-1 =>
              (for all K in J'Range (2) => J (I, K)'Initialized
                and then J (I, K) = J0 (I, K) - J1 (I, K))));
            pragma Loop_Invariant (Static => (for all K in J'First (2) .. C =>
              J (R, K)'Initialized and then J (R, K) = J0 (R, K) - J1 (R, K)));
         end loop;
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           Pos (I)'Initialized and then Pos (I) = (P0 (I - 1) - P1 (I - 1), 0.0)));
         pragma Loop_Invariant (Static => (for all I in 1 .. R => (for all C in J'Range (2) =>
           J (I, C)'Initialized and then J (I, C) = J0 (I, C) - J1 (I, C))));
      end loop;
   end Connect;

   procedure Store_Column (J : in out CA.Matrix; C : Positive; V : Column_Values) is
   begin
      J (1, C) := V (1);
      J (2, C) := V (2);
      J (3, C) := V (3);
      J (4, C) := V (4);
      J (5, C) := V (5);
      J (6, C) := V (6);
   end Store_Column;

   procedure Weld
     (P0, P1 : Vector; A, B : Quaternion; Torque : Tier0_Real;
      J0, J1 : CA.Matrix; J : out CA.Matrix; Pos : out CA.Parameter_Array) is
      Expected : constant CA.Matrix (4 .. 6, J0'Range (2)) :=
        [for I in 4 .. 6 => [for K in J0'Range (2) =>
          Model.Column_Jacobian (A, B, J0, J1, K, Torque, I-4)]]
        with Ghost => Static;
      Error : constant Vector := Rotation_Position (A, B, Torque);
      Angular : Vector;
   begin
      Pos := [(P0 (0)-P1 (0), 0.0), (P0 (1)-P1 (1), 0.0), (P0 (2)-P1 (2), 0.0),
              (Error (0), 0.0), (Error (1), 0.0), (Error (2), 0.0)];
      for C in J'Range (2) loop
         Angular := Rotation_Column (A, B, J0, J1, C, Torque);
         pragma Assert (Static => Bounded (Angular, 1.0e37));
         Store_Column (J, C,
           [J0 (1, C)-J1 (1, C), J0 (2, C)-J1 (2, C), J0 (3, C)-J1 (3, C),
            Angular (0), Angular (1), Angular (2)]);
         pragma Assert (Static => (for all K in J'First (2) .. C-1 =>
           J (1, K) = J0 (1, K)-J1 (1, K)));
         pragma Assert (Static => (for all K in J'First (2) .. C-1 =>
           J (2, K) = J0 (2, K)-J1 (2, K)));
         pragma Assert (Static => (for all K in J'First (2) .. C-1 =>
           J (3, K) = J0 (3, K)-J1 (3, K)));
         pragma Assert (Static => J (1, C) = J0 (1, C)-J1 (1, C)
           and then J (2, C) = J0 (2, C)-J1 (2, C)
           and then J (3, C) = J0 (3, C)-J1 (3, C));
         pragma Assert (Static => (for all K in J'First (2) .. C-1 =>
           J (4, K) = Expected (4, K)));
         pragma Assert (Static => (for all K in J'First (2) .. C-1 =>
           J (5, K) = Expected (5, K)));
         pragma Assert (Static => (for all K in J'First (2) .. C-1 =>
           J (6, K) = Expected (6, K)));
         pragma Assert (Static => J (4, C) = Expected (4, C)
           and then J (5, C) = Expected (5, C) and then J (6, C) = Expected (6, C));
         pragma Loop_Invariant (Static => (for all I in 1 .. 6 =>
           (for all K in J'First (2) .. C => J (I, K)'Initialized)));
         pragma Loop_Invariant (Static => (for all K in J'First (2) .. C =>
           J (1, K)'Initialized and then J (1, K) = J0 (1, K) - J1 (1, K)));
         pragma Loop_Invariant (Static => (for all K in J'First (2) .. C =>
           J (2, K)'Initialized and then J (2, K) = J0 (2, K) - J1 (2, K)));
         pragma Loop_Invariant (Static => (for all K in J'First (2) .. C =>
           J (3, K)'Initialized and then J (3, K) = J0 (3, K) - J1 (3, K)));
         pragma Loop_Invariant (Static => (for all K in J'First (2) .. C =>
           J (4, K)'Initialized and then J (4, K) = Expected (4, K)));
         pragma Loop_Invariant (Static => (for all K in J'First (2) .. C =>
           J (5, K)'Initialized and then J (5, K) = Expected (5, K)));
         pragma Loop_Invariant (Static => (for all K in J'First (2) .. C =>
           J (6, K)'Initialized and then J (6, K) = Expected (6, K)));
      end loop;
      pragma Assert (Static => (for all I in 1 .. 6 =>
        (for all K in J'Range (2) => J (I, K)'Initialized)));
      pragma Assert (Static => J'Initialized);
   end Weld;
end MJ.Equality_Geometry;

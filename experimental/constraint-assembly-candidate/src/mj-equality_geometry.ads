--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see repository LICENSE.
--  Modified: Ada/SPARK translation of connect/weld geometry, MuJoCo 3.14.0.
with MJ.Types; use MJ.Types;
with MJ.Constraint_Assembly;
package MJ.Equality_Geometry with SPARK_Mode is
   package CA renames MJ.Constraint_Assembly;
   use type CA.Parameters;
   subtype Axis is Natural range 0 .. 2;
   subtype Component is Natural range 0 .. 3;
   type Vector is array (Axis) of Real;
   type Quaternion is array (Component) of Real;
   type Rotation is array (Axis, Axis) of Real;
   Identity : constant Quaternion := [1.0, 0.0, 0.0, 0.0];
   subtype Rotation_Element is Real range -32.0 .. 32.0;
   subtype Anchor_Value is Real range -1.0e13 .. 1.0e13;
   function Anchor_Component
     (R0, R1, R2 : Rotation_Element; L0, L1, L2, Translation : Tier0_Real)
      return Anchor_Value with Global => null,
      Post => Anchor_Component'Result = ((R0*L0 + R1*L1) + R2*L2) + Translation;
   subtype Product_Operand is Real range -1.0e30 .. 1.0e30;
   subtype Product_Term_Value is Real range -1.1e60 .. 1.1e60;
   function Product_Term (A, B : Product_Operand) return Product_Term_Value with
     Global => null, Inline_Always,
     Post => (Static => Product_Term'Result = A*B
       and then (if A in -32.0 .. 32.0 and then B in -32.0 .. 32.0
         then Product_Term'Result in -1.1e3 .. 1.1e3)
       and then (if A in -1.0e24 .. 1.0e24 and then B in -32.0 .. 32.0
         then Product_Term'Result in -3.3e25 .. 3.3e25)
       and then (if A in -32.0 .. 32.0 and then B in -1.0e21 .. 1.0e21
         then Product_Term'Result in -3.3e22 .. 3.3e22));
   function Product_W
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real with
      Global => null, Inline_Always, Post => Product_W'Result = ((Product_Term (A0, B0) - Product_Term (A1, B1)) - Product_Term (A2, B2)) - Product_Term (A3, B3);
   pragma Postcondition (Static =>
        (if A0 in -32.0 .. 32.0 and then A1 in -32.0 .. 32.0
          and then A2 in -32.0 .. 32.0 and then A3 in -32.0 .. 32.0
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_W'Result in -1.0e4 .. 1.0e4));
   pragma Postcondition (Static =>
        (if A0 in -1.0e24 .. 1.0e24 and then A1 in -1.0e24 .. 1.0e24
          and then A2 in -1.0e24 .. 1.0e24 and then A3 in -1.0e24 .. 1.0e24
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_W'Result in -1.0e27 .. 1.0e27));
   function Product_X
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real with
      Global => null, Inline_Always, Post => Product_X'Result = ((Product_Term (A0, B1) + Product_Term (A1, B0)) + Product_Term (A2, B3)) - Product_Term (A3, B2);
   pragma Postcondition (Static =>
        (if A0 in -32.0 .. 32.0 and then A1 in -32.0 .. 32.0
          and then A2 in -32.0 .. 32.0 and then A3 in -32.0 .. 32.0
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_X'Result in -1.0e4 .. 1.0e4));
   pragma Postcondition (Static =>
        (if A0 in -1.0e24 .. 1.0e24 and then A1 in -1.0e24 .. 1.0e24
          and then A2 in -1.0e24 .. 1.0e24 and then A3 in -1.0e24 .. 1.0e24
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_X'Result in -1.0e27 .. 1.0e27));
   function Product_Y
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real with
      Global => null, Inline_Always, Post => Product_Y'Result = ((Product_Term (A0, B2) - Product_Term (A1, B3)) + Product_Term (A2, B0)) + Product_Term (A3, B1);
   pragma Postcondition (Static =>
        (if A0 in -32.0 .. 32.0 and then A1 in -32.0 .. 32.0
          and then A2 in -32.0 .. 32.0 and then A3 in -32.0 .. 32.0
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_Y'Result in -1.0e4 .. 1.0e4));
   pragma Postcondition (Static =>
        (if A0 in -1.0e24 .. 1.0e24 and then A1 in -1.0e24 .. 1.0e24
          and then A2 in -1.0e24 .. 1.0e24 and then A3 in -1.0e24 .. 1.0e24
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_Y'Result in -1.0e27 .. 1.0e27));
   function Product_Z
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand) return Tier2_Real with
      Global => null, Inline_Always, Post => Product_Z'Result = ((Product_Term (A0, B3) + Product_Term (A1, B2)) - Product_Term (A2, B1)) + Product_Term (A3, B0);
   pragma Postcondition (Static =>
        (if A0 in -32.0 .. 32.0 and then A1 in -32.0 .. 32.0
          and then A2 in -32.0 .. 32.0 and then A3 in -32.0 .. 32.0
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_Z'Result in -1.0e4 .. 1.0e4));
   pragma Postcondition (Static =>
        (if A0 in -1.0e24 .. 1.0e24 and then A1 in -1.0e24 .. 1.0e24
          and then A2 in -1.0e24 .. 1.0e24 and then A3 in -1.0e24 .. 1.0e24
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_Z'Result in -1.0e27 .. 1.0e27));
   function Product_At
     (A0, A1, A2, A3, B0, B1, B2, B3 : Product_Operand; I : Component)
      return Tier2_Real with Global => null,
      Post => (Static => Product_At'Result =
        (case I is
           when 0 => Product_W (A0, A1, A2, A3, B0, B1, B2, B3),
           when 1 => Product_X (A0, A1, A2, A3, B0, B1, B2, B3),
           when 2 => Product_Y (A0, A1, A2, A3, B0, B1, B2, B3),
           when 3 => Product_Z (A0, A1, A2, A3, B0, B1, B2, B3)));
   pragma Postcondition (Static =>
        (if A0 in -32.0 .. 32.0 and then A1 in -32.0 .. 32.0
          and then A2 in -32.0 .. 32.0 and then A3 in -32.0 .. 32.0
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_At'Result in -1.0e4 .. 1.0e4));
   pragma Postcondition (Static =>
        (if A0 in -1.0e24 .. 1.0e24 and then A1 in -1.0e24 .. 1.0e24
          and then A2 in -1.0e24 .. 1.0e24 and then A3 in -1.0e24 .. 1.0e24
          and then B0 in -32.0 .. 32.0 and then B1 in -32.0 .. 32.0
          and then B2 in -32.0 .. 32.0 and then B3 in -32.0 .. 32.0
          then Product_At'Result in -1.0e27 .. 1.0e27));
   pragma Inline_Always (Product_At);
   subtype Axis_Operand is Real range -1.0e21 .. 1.0e21;
   subtype Axis_Value is Real range -1.0e24 .. 1.0e24;
   function Axis_At
     (Q0, Q1, Q2, Q3 : Rotation_Element;
      V0, V1, V2 : Axis_Operand; I : Component) return Axis_Value with
      Global => null, Inline_Always,
      Post => (Static => Axis_At'Result =
        (case I is
           when 0 => (Product_Term (-Q1, V0) - Product_Term (Q2, V1)) - Product_Term (Q3, V2),
           when 1 => (Product_Term (Q0, V0) + Product_Term (Q2, V2)) - Product_Term (Q3, V1),
           when 2 => (Product_Term (Q0, V1) + Product_Term (Q3, V0)) - Product_Term (Q1, V2),
           when 3 => (Product_Term (Q0, V2) + Product_Term (Q1, V1)) - Product_Term (Q2, V0)));
   subtype Position_Product is Real range -1.0e4 .. 1.0e4;
   subtype Position_Value is Real range -1.0e15 .. 1.0e15;
   subtype Jacobian_Product is Real range -1.0e27 .. 1.0e27;
   subtype Jacobian_Value is Real range -1.0e37 .. 1.0e37;
   function Position_Scale (Q : Position_Product; Torque : Tier0_Real)
      return Position_Value with Global => null, Inline_Always,
      Post => Position_Scale'Result = Q*Torque;
   function Jacobian_Scale (Q : Jacobian_Product; Torque : Tier0_Real)
      return Jacobian_Value with Global => null, Inline_Always,
      Post => Jacobian_Scale'Result = (0.5*Q)*Torque;
   function Bounded (V : Vector; Limit : Real) return Boolean is
     (for all X of V => X in -Limit .. Limit);
   function Bounded (Q : Quaternion; Limit : Real) return Boolean is
     (for all X of Q => X in -Limit .. Limit);
   function Bounded (J : CA.Matrix; Limit : Real) return Boolean is
     (for all R in J'Range (1) =>
       (for all C in J'Range (2) => J (R, C) in -Limit .. Limit));

   function Conjugate (Q : Quaternion) return Quaternion is
     ([Q (0), -Q (1), -Q (2), -Q (3)])
     with Global => null, Inline_Always,
       Pre => Bounded (Q, 1.0e30),
       Post => (Static => Conjugate'Result (0) = Q (0)
         and then Conjugate'Result (1) = -Q (1)
         and then Conjugate'Result (2) = -Q (2)
         and then Conjugate'Result (3) = -Q (3)
         and then Bounded (Conjugate'Result, 1.0e30)
         and then (if Bounded (Q, 32.0) then Bounded (Conjugate'Result, 32.0))),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   function Angular_Difference (X0, Y0, Z0, X1, Y1, Z1 : Real) return Vector is
     ([X0-X1, Y0-Y1, Z0-Z1])
     with Global => null, Inline_Always,
       Pre => X0 in -1.0e20 .. 1.0e20 and then Y0 in -1.0e20 .. 1.0e20
         and then Z0 in -1.0e20 .. 1.0e20 and then X1 in -1.0e20 .. 1.0e20
         and then Y1 in -1.0e20 .. 1.0e20 and then Z1 in -1.0e20 .. 1.0e20,
       Post => (Static => Angular_Difference'Result (0) = X0-X1
         and then Angular_Difference'Result (1) = Y0-Y1
         and then Angular_Difference'Result (2) = Z0-Z1
         and then Bounded (Angular_Difference'Result, 1.0e21)),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   function Quaternion_Product_Value (A, B : Quaternion) return Quaternion is
     ([for I in Component => Product_At
       (A (0), A (1), A (2), A (3), B (0), B (1), B (2), B (3), I)])
     with Global => null, Inline_Always,
       Pre => Bounded (A, 1.0e30) and then Bounded (B, 1.0e30),
       Post => (Static =>
         (for all I in Component => Quaternion_Product_Value'Result (I) = Product_At
           (A (0), A (1), A (2), A (3), B (0), B (1), B (2), B (3), I))
         and then Bounded (Quaternion_Product_Value'Result, 1.0e61)
         and then (if Bounded (A, 32.0) and then Bounded (B, 32.0)
           then Bounded (Quaternion_Product_Value'Result, 1.0e4))
         and then (if Bounded (A, 1.0e24) and then Bounded (B, 32.0)
           then Bounded (Quaternion_Product_Value'Result, 1.0e27))),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Axis_Product_Value (Q : Quaternion; V : Vector) return Quaternion is
     ([for I in Component => Axis_At
       (Q (0), Q (1), Q (2), Q (3), V (0), V (1), V (2), I)])
     with Global => null, Inline_Always,
       Pre => Bounded (Q, 32.0) and then Bounded (V, 1.0e21),
       Post => (Static =>
         (for all I in Component => Axis_Product_Value'Result (I) = Axis_At
           (Q (0), Q (1), Q (2), Q (3), V (0), V (1), V (2), I))
         and then Bounded (Axis_Product_Value'Result, 1.0e24)),
       Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   package Model with Ghost => Static is
      function Product (A, B : Quaternion) return Quaternion is
        ([for I in Component => Product_At
          (A (0), A (1), A (2), A (3), B (0), B (1), B (2), B (3), I)])
        with Pre => Bounded (A, 1.0e30) and then Bounded (B, 1.0e30),
          Post => Bounded (Product'Result, 1.0e61)
            and then (if Bounded (A, 32.0) and then Bounded (B, 32.0)
              then Bounded (Product'Result, 1.0e4))
            and then (if Bounded (A, 1.0e24) and then Bounded (B, 32.0)
              then Bounded (Product'Result, 1.0e27)),
          Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Axis_Product (Q : Quaternion; V : Vector) return Quaternion is
        ([for I in Component => Axis_At
          (Q (0), Q (1), Q (2), Q (3), V (0), V (1), V (2), I)])
        with Pre => Bounded (Q, 32.0) and then Bounded (V, 1.0e21),
          Post => Bounded (Axis_Product'Result, 1.0e24),
          Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Position
        (A, B : Quaternion; Torque : Tier0_Real; I : Axis) return Position_Value is
        (Position_Scale (Quaternion_Product_Value (Conjugate (B), A) (I + 1), Torque))
        with Pre => Bounded (A, 32.0) and then Bounded (B, 32.0),
          Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Jacobian
        (A, B : Quaternion; Omega : Vector;
         Torque : Tier0_Real; I : Axis) return Jacobian_Value is
        (Jacobian_Scale (Quaternion_Product_Value (Axis_Product_Value (Conjugate (B), Omega), A) (I + 1), Torque))
        with Pre => Bounded (A, 32.0) and then Bounded (B, 32.0)
          and then Bounded (Omega, 1.0e21),
          Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Column_Jacobian
        (A, B : Quaternion; J0, J1 : CA.Matrix; C : Positive;
         Torque : Tier0_Real; I : Axis) return Jacobian_Value is
        (Jacobian (A, B,
          Angular_Difference (J0 (4, C), J0 (5, C), J0 (6, C),
                              J1 (4, C), J1 (5, C), J1 (6, C)), Torque, I))
        with Pre => Bounded (A, 32.0) and then Bounded (B, 32.0)
          and then J0'First (1) = 1 and then J0'Length (1) = 6
          and then J1'First (1) = 1 and then J1'Length (1) = 6
          and then C in J0'Range (2) and then C in J1'Range (2)
          and then (for all R in 4 .. 6 =>
            J0 (R, C) in -1.0e20 .. 1.0e20 and then J1 (R, C) in -1.0e20 .. 1.0e20),
          Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;

   function Anchor (R : Rotation; Local, Translation : Vector) return Vector with
     Global => null,
     Pre => (for all I in Axis => (for all J in Axis => R (I, J) in -32.0 .. 32.0))
       and then Bounded (Local, 1.0e10) and then Bounded (Translation, 1.0e10),
     Post => (Static => Bounded (Anchor'Result, 1.0e13)
       and then (for all I in Axis => Anchor'Result (I) =
         Anchor_Component (R (I, 0), R (I, 1), R (I, 2), Local (0), Local (1), Local (2), Translation (I))));

   function Multiply (A, B : Quaternion) return Quaternion with
     Global => null,
     Pre => Bounded (A, 1.0e30) and then Bounded (B, 1.0e30),
     Post => (Static => Multiply'Result = Model.Product (A, B)
       and then Bounded (Multiply'Result, 1.0e61)
       and then (if Bounded (A, 32.0) and then Bounded (B, 32.0)
         then Bounded (Multiply'Result, 1.0e4))
       and then (if Bounded (A, 1.0e24) and then Bounded (B, 32.0)
         then Bounded (Multiply'Result, 1.0e27)));
   function Multiply_Axis (Q : Quaternion; V : Vector) return Quaternion with
     Global => null,
     Pre => Bounded (Q, 32.0) and then Bounded (V, 1.0e21),
     Post => (Static => Multiply_Axis'Result = Model.Axis_Product (Q, V)
       and then Bounded (Multiply_Axis'Result, 1.0e24));
   --  A is q0*relpose (body semantics) or qbody0*qsite0 (site semantics).
   --  B is qbody1 or qbody1*qsite1. No normalization or sign canonicalization.
   function Rotation_Position (A, B : Quaternion; Torque : Tier0_Real)
                               return Vector with
     Global => null, Pre => Bounded (A, 32.0) and then Bounded (B, 32.0),
     Post => (Static => Bounded (Rotation_Position'Result, 1.0e15)
       and then (for all I in Axis => Rotation_Position'Result (I) = Model.Position (A, B, Torque, I)));
   function Rotation_Jacobian (A, B : Quaternion; Omega : Vector; Torque : Tier0_Real)
                               return Vector with
     Global => null, Pre => Bounded (A, 32.0) and then Bounded (B, 32.0)
       and then Bounded (Omega, 1.0e21),
     Post => (Static => Bounded (Rotation_Jacobian'Result, 1.0e37)
       and then (for all I in Axis => Rotation_Jacobian'Result (I) = Model.Jacobian (A, B, Omega, Torque, I)));

   function Rotation_Column
     (A, B : Quaternion; J0, J1 : CA.Matrix; C : Positive; Torque : Tier0_Real)
      return Vector with Global => null, Inline_Always,
     Pre => Bounded (A, 32.0) and then Bounded (B, 32.0)
       and then J0'First (1) = 1 and then J0'Length (1) = 6
       and then J1'First (1) = 1 and then J1'Length (1) = 6
       and then C in J0'Range (2) and then C in J1'Range (2)
       and then (for all R in 4 .. 6 =>
         J0 (R, C) in -1.0e20 .. 1.0e20 and then J1 (R, C) in -1.0e20 .. 1.0e20),
     Post => (Static => Bounded (Rotation_Column'Result, 1.0e37)
       and then (for all I in Axis => Rotation_Column'Result (I) =
         Model.Column_Jacobian (A, B, J0, J1, C, Torque, I)));

   procedure Connect
     (P0, P1 : Vector; J0, J1 : CA.Matrix;
      J : out CA.Matrix; Pos : out CA.Parameter_Array) with
     Global => null, Relaxed_Initialization => (J, Pos),
     Pre => Bounded (P0, 1.0e20) and then Bounded (P1, 1.0e20)
       and then J0'First (1) = 1 and then J0'Length (1) = 3
       and then J0'First (2) = 1 and then J0'Length (2) <= CA.Max_Dofs
       and then J1'First (1) = 1 and then J1'Length (1) = 3
       and then J1'First (2) = 1 and then J1'Length (2) = J0'Length (2)
       and then Bounded (J0, 1.0e20) and then Bounded (J1, 1.0e20)
       and then J'First (1) = 1 and then J'Length (1) = 3
       and then J'First (2) = 1 and then J'Length (2) = J0'Length (2)
       and then Pos'First = 1 and then Pos'Length = 3,
     Post => (Static => J'Initialized and then Pos'Initialized
       and then (for all R in 1 .. 3 => Pos (R) = (P0 (R - 1) - P1 (R - 1), 0.0))
       and then (for all R in J'Range (1) => (for all C in J'Range (2) => J (R, C) = J0 (R, C) - J1 (R, C))));

   type Column_Values is array (Positive range 1 .. 6) of Tier2_Real;
   procedure Store_Column (J : in out CA.Matrix; C : Positive; V : Column_Values) with
     Global => null, Inline_Always, Relaxed_Initialization => J,
     Pre => J'First (1) = 1 and then J'Length (1) = 6 and then C in J'Range (2),
     Post => (Static =>
       (for all R in 1 .. 6 => (for all K in J'First (2) .. C => J (R, K)'Initialized))
       and then (for all R in 1 .. 6 => J (R, C) = V (R))
       and then (for all K in J'First (2) .. C-1 => (for all R in 1 .. 6 =>
         J (R, K) = J'Old (R, K))));
   pragma Precondition (Static =>
     (for all R in 1 .. 6 => (for all K in J'First (2) .. C-1 => J (R, K)'Initialized)));

   procedure Weld
     (P0, P1 : Vector; A, B : Quaternion; Torque : Tier0_Real;
      J0, J1 : CA.Matrix; J : out CA.Matrix; Pos : out CA.Parameter_Array) with
     Global => null, Relaxed_Initialization => (J, Pos),
     Pre => Bounded (P0, 1.0e20) and then Bounded (P1, 1.0e20)
       and then Bounded (A, 32.0) and then Bounded (B, 32.0)
       and then J0'First (1) = 1 and then J0'Length (1) = 6
       and then J0'First (2) = 1 and then J0'Length (2) <= CA.Max_Dofs
       and then J1'First (1) = 1 and then J1'Length (1) = 6
       and then J1'First (2) = 1 and then J1'Length (2) = J0'Length (2)
       and then Bounded (J0, 1.0e20) and then Bounded (J1, 1.0e20)
       and then J'First (1) = 1 and then J'Length (1) = 6
       and then J'First (2) = 1 and then J'Length (2) = J0'Length (2)
       and then Pos'First = 1 and then Pos'Length = 6,
     Post => (Static => J'Initialized and then Pos'Initialized
       and then (for all R in 1 .. 3 => Pos (R) = (P0 (R - 1) - P1 (R - 1), 0.0))
       and then (for all R in 4 .. 6 => Pos (R) = (Model.Position (A, B, Torque, R - 4), 0.0))
       and then (for all R in 1 .. 3 => (for all C in J'Range (2) => J (R, C) = J0 (R, C) - J1 (R, C)))
       and then (for all R in 4 .. 6 => (for all C in J'Range (2) =>
         J (R, C) = Model.Column_Jacobian (A, B, J0, J1, C, Torque, R - 4))));
end MJ.Equality_Geometry;

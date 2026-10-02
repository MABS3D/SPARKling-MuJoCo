with MJ.Types; use MJ.Types;

--  MuJoCo 3.14.0 pyramidal force coordinates and scalar PGS operations.
--  Functional contracts describe ordered binary64 arithmetic, not ideal reals.
package MJ.Friction_Kernels with SPARK_Mode is
   subtype Dimension is Positive range 1 .. 6;
   function Valid_Dimension (D : Dimension) return Boolean is (D in 1 | 3 | 4 | 6);
   function Edge_Count (D : Dimension) return Positive is
     (if D = 1 then 1 else 2 * (D - 1))
   with Pre => Valid_Dimension (D), Post => Edge_Count'Result in 1 .. 10;
   subtype Force_Value is Real range -1.0e20 .. 1.0e20;
   subtype Coefficient is Real range Min_Mu .. 1.0e10;
   subtype Decoded_Value is Real range -1.0e32 .. 1.0e32;
   subtype Residual_Value is Real range -1.0e45 .. 1.0e45;
   subtype Inverse_Diagonal is Real range 1.0e-20 .. 1.0e20;
   subtype Raw_Value is Real range -1.0e80 .. 1.0e80;
   subtype Difference_Value is Real range -2.0e20 .. 2.0e20;
   subtype Cost_Value is Real range -1.0e90 .. 1.0e90;
   subtype Bound_Value is Real range 0.0 .. 1.0e20;
   type Contact_Force is array (Positive range 1 .. 6) of Decoded_Value;
   type Pyramid is array (Positive range 1 .. 10) of Force_Value;
   type Friction is array (Positive range 1 .. 5) of Coefficient;
   type Row_Kind is (Equality, Dry_Friction, Nonnegative);
   function Feasible (Kind : Row_Kind; F : Real; Bound : Bound_Value) return Boolean is
     (F in Force_Value and then
       (case Kind is
          when Equality => True,
          when Dry_Friction => F in -Bound .. Bound,
          when Nonnegative => F >= 0.0))
   with Post => (if Feasible'Result then F in Force_Value),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   type Step_Result is record
      Accepted : Boolean;
      Force : Force_Value;
      Change : Cost_Value;
   end record;

   package Model with Ghost => Static is
      function Normal (P : Pyramid; D : Dimension) return Decoded_Value is
        (case D is
           when 1 => P (1),
           when 3 => ((((0.0 + P (1)) + P (2)) + P (3)) + P (4)),
           when 4 => ((((((0.0 + P (1)) + P (2)) + P (3)) + P (4)) + P (5)) + P (6)),
           when others => ((((((((((0.0 + P (1)) + P (2)) + P (3)) + P (4)) + P (5)) + P (6)) + P (7)) + P (8)) + P (9)) + P (10)))
      with Pre => Valid_Dimension (D),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Component (P : Pyramid; Mu : Friction; D : Dimension;
                          C : Positive) return Decoded_Value is
        (if C = 1 then Normal (P, D)
         elsif C <= D then (P (2 * (C - 1) - 1) - P (2 * (C - 1))) * Mu (C - 1)
         else 0.0)
      with Pre => Valid_Dimension (D) and C in 1 .. 6,
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Encoded_Edge (F : Contact_Force; Mu : Friction;
                             D : Dimension; E : Positive) return Force_Value is
        (if E > Edge_Count (D) then 0.0
         elsif D = 1 then F (1)
         else (declare A : constant Real := F (1) / Real (D - 1);
                       T : constant Real := F ((E + 1) / 2 + 1) / Mu ((E + 1) / 2);
                       B : constant Real := (if T < A then T else A);
               begin (if E mod 2 = 1 then 0.5 * (A + B) else 0.5 * (A - B))))
      with Pre => Valid_Dimension (D) and E in 1 .. 10
        and (for all C in 1 .. 6 => F (C) in -1.0e10 .. 1.0e10),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Projected (Kind : Row_Kind; F : Raw_Value; Bound : Bound_Value)
        return Raw_Value is
        (case Kind is
           when Equality => F,
           when Dry_Friction => (if F < -Bound then -Bound elsif F > Bound then Bound else F),
           when Nonnegative => (if F < 0.0 then 0.0 else F))
      with Post => (case Kind is
         when Equality => Projected'Result = F,
         when Dry_Friction => Projected'Result in -Bound .. Bound,
         when Nonnegative => Projected'Result >= 0.0),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Delta_Cost (Old_Force, New_Force : Force_Value;
                           Residual : Residual_Value; Inv : Inverse_Diagonal)
        return Cost_Value is
        (declare Difference : constant Difference_Value := New_Force - Old_Force;
         begin (((0.5 * Difference) * Difference) * (1.0 / Inv)) + (Difference * Residual))
      with Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Candidate (Kind : Row_Kind; Old_Force : Force_Value;
                          Residual : Residual_Value; Inv : Inverse_Diagonal;
                          Bound : Bound_Value) return Raw_Value is
        (Projected (Kind, Old_Force - Residual * Inv, Bound))
      with Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
      function Stored (Old_Force, Proposed : Force_Value; Change : Cost_Value)
        return Step_Result is
        (if Change > 1.0e-10 then (True, Old_Force, 0.0)
         else (True, Proposed, Change))
      with Post => Stored'Result.Accepted
          and (Stored'Result.Force = Old_Force or Stored'Result.Force = Proposed),
        Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;

   function Decode_Component (P : Pyramid; Mu : Friction; D : Dimension;
                              C : Positive) return Decoded_Value
   with Global => null, Inline_Always, Pre => Valid_Dimension (D) and C in 1 .. 6,
     Post => (Static => Decode_Component'Result = Model.Component (P, Mu, D, C));
   procedure Decode (P : Pyramid; Mu : Friction; D : Dimension; F : out Contact_Force)
   with Global => null, Pre => Valid_Dimension (D),
     Post => (Static => (for all C in 1 .. 6 => F (C) = Model.Component (P, Mu, D, C)));
   function Encode_Edge (F : Contact_Force; Mu : Friction;
                         D : Dimension; E : Positive) return Force_Value
   with Global => null, Inline_Always,
     Pre => Valid_Dimension (D) and E in 1 .. 10
       and (for all C in 1 .. 6 => F (C) in -1.0e10 .. 1.0e10),
     Post => (Static => Encode_Edge'Result = Model.Encoded_Edge (F, Mu, D, E));
   procedure Encode (F : Contact_Force; Mu : Friction; D : Dimension; P : out Pyramid)
   with Global => null, Pre => Valid_Dimension (D)
       and (for all C in 1 .. 6 => F (C) in -1.0e10 .. 1.0e10),
     Post => (Static => (for all E in 1 .. 10 => P (E) = Model.Encoded_Edge (F, Mu, D, E)));
   function Project (Kind : Row_Kind; F : Raw_Value; Bound : Bound_Value) return Raw_Value
   with Global => null, Inline_Always, Annotate => (GNATprove, Inline_For_Proof),
     Post => (Static => Project'Result = Model.Projected (Kind, F, Bound));
   function Cost_Change (Old_Force, New_Force : Force_Value;
                         Residual : Residual_Value; Inv : Inverse_Diagonal)
     return Cost_Value
   with Global => null, Inline_Always, Annotate => (GNATprove, Inline_For_Proof),
     Post => (Static => Cost_Change'Result = Model.Delta_Cost (Old_Force, New_Force, Residual, Inv));
   function Step (Kind : Row_Kind; Old_Force : Force_Value;
                  Residual : Residual_Value; Inv : Inverse_Diagonal;
                  Bound : Bound_Value) return Step_Result
   with Global => null,
     Post => (Static =>
       (declare Proposed : constant Raw_Value := Model.Candidate (Kind, Old_Force, Residual, Inv, Bound);
        begin Step'Result.Accepted = (Proposed in Force_Value)
         and then (if Proposed not in Force_Value then
           Step'Result = (False, Old_Force, 0.0)
         else Step'Result = Model.Stored (Old_Force, Proposed,
           Model.Delta_Cost (Old_Force, Proposed, Residual, Inv))))
       and then (if Feasible (Kind, Old_Force, Bound) then Feasible (Kind, Step'Result.Force, Bound)));
end MJ.Friction_Kernels;

with MJ.Types; use MJ.Types;

--  Parameter selection/assignment only. This does not replace collision
--  detection, contact-frame construction or the constraint solver.
package MJ.Contact_Materials with SPARK_Mode is
   subtype Dimension is Integer range 1 .. 6
     with Static_Predicate => Dimension in 1 | 3 | 4 | 6;
   subtype Ref_Index is Integer range 0 .. 1;
   subtype Imp_Index is Integer range 0 .. 4;
   subtype Friction_Index is Integer range 0 .. 4;
   subtype Surface_Friction_Index is Integer range 0 .. 2;
   subtype Wide_Value is Real range -3.0e10 .. 3.0e10;
   subtype Weight_Value is Real range 0.0 .. 1.0;
   type Reference_Input is array (Ref_Index) of Tier0_Real;
   type Impedance_Input is array (Imp_Index) of Tier0_Real;
   type Friction_Input is array (Friction_Index) of Tier0_Real;
   type Surface_Friction is array (Surface_Friction_Index) of Tier0_Real;
   type Reference_Values is array (Ref_Index) of Wide_Value;
   type Impedance_Values is array (Imp_Index) of Wide_Value;
   type Friction_Values is array (Friction_Index) of Wide_Value;
   type Surface_Kind is (Geom, Flex);
   type Surface is record
      Kind : Surface_Kind := Geom;
      Priority : Integer := 0;
      Condim : Dimension := 3;
      Solmix : Tier0_Real := 1.0;
      Solref : Reference_Input := [0.02, 1.0];
      Solimp : Impedance_Input := [0.9, 0.95, 0.001, 0.5, 2.0];
      Friction : Surface_Friction := [1.0, 0.005, 0.0001];
      Adhesion : Nonneg_Tier0 := 0.0;
      Margin, Gap : Tier0_Real := 0.0;
   end record;
   type Parameters is record
      Condim : Dimension := 3;
      Solref, Solref_Friction : Reference_Values := [others => 0.0];
      Solimp : Impedance_Values := [others => 0.0];
      Friction : Friction_Values := [others => 0.0];
      Adhesion : Real range 0.0 .. 2.0e10 := 0.0;
   end record;
   type Explicit_Pair is record
      Enabled : Boolean := False;
      Condim : Dimension := 3;
      Solref : Reference_Input := [0.02, 1.0];
      Solref_Friction : Reference_Input := [others => 0.0];
      Solimp : Impedance_Input := [0.9, 0.95, 0.001, 0.5, 2.0];
      Friction : Friction_Input := [1.0, 1.0, 0.005, 0.0001, 0.0001];
      Adhesion : Nonneg_Tier0 := 0.0;
      Margin, Gap : Tier0_Real := 0.0;
   end record;
   type Override_Options is record
      Enabled : Boolean := False;
      Solref : Reference_Input := [0.02, 1.0];
      Solimp : Impedance_Input := [0.9, 0.95, 0.001, 0.5, 2.0];
      Friction : Friction_Input := [1.0, 1.0, 0.005, 0.0001, 0.0001];
      Margin : Tier0_Real := 0.0;
   end record;
   type Prepared_Contact is record
      Values : Parameters;
      Include_Margin, Detection_Gap : Wide_Value := 0.0;
      Excluded : Boolean := False;
   end record;

   function Weight (A, B : Tier0_Real) return Weight_Value is
     (if A >= Min_Val and then B >= Min_Val then A / (A + B)
      elsif A < Min_Val and then B < Min_Val then 0.5
      elsif A < Min_Val then 0.0 else 1.0) with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Blend (A, B : Tier0_Real; W : Weight_Value) return Wide_Value is
     (W * A + (1.0 - W) * B) with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   --  Finite selectors with C's operand choice; no unordered-value handling
   --  is required in the supported scalar domain. Both bodies are proved.
   function Maximum (A, B : Wide_Value) return Wide_Value is
     (if A >= B then A else B)
     with Global => null, Inline_Always,
     Post => Maximum'Result = Real'Max (A, B),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   --  Preserve C's choice of the first operand on ties, including signed zero.
   function Minimum (A, B : Wide_Value) return Wide_Value is
     (if A <= B then A else B)
     with Global => null, Inline_Always,
     Post => Minimum'Result = Real'Min (A, B),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Effective_Adhesion (S : Surface) return Nonneg_Tier0 is
     (if S.Kind = Flex then 0.0 else S.Adhesion) with Global => null;
   function Mixed_Dimension (A, B : Surface) return Dimension is
     (if A.Priority > B.Priority then A.Condim
      elsif A.Priority < B.Priority then B.Condim
      else Integer'Max (A.Condim, B.Condim)) with Global => null;
   function Mixed_Adhesion (A, B : Surface) return Real is
     (if A.Priority > B.Priority then Effective_Adhesion (A)
      elsif A.Priority < B.Priority then Effective_Adhesion (B)
      else Effective_Adhesion (A) + Effective_Adhesion (B))
     with Global => null, Post => Mixed_Adhesion'Result in 0.0 .. 2.0e10;
   function Reference_Component
     (A, B : Surface; W : Weight_Value; K : Ref_Index) return Wide_Value is
     (if A.Priority > B.Priority then A.Solref (K)
      elsif A.Priority < B.Priority then B.Solref (K)
      elsif A.Solref (0) > 0.0 and then B.Solref (0) > 0.0 then
         Blend (A.Solref (K), B.Solref (K), W)
      else Minimum (A.Solref (K), B.Solref (K))) with Global => null;
   function Impedance_Component
     (A, B : Surface; W : Weight_Value; K : Imp_Index) return Wide_Value is
     (if A.Priority > B.Priority then A.Solimp (K)
      elsif A.Priority < B.Priority then B.Solimp (K)
      else Blend (A.Solimp (K), B.Solimp (K), W)) with Global => null;
   function Friction_Component
     (A, B : Surface; K : Friction_Index) return Wide_Value
     with Global => null,
     Post => Friction_Component'Result =
       (declare J : constant Surface_Friction_Index :=
         (if K < 2 then 0 elsif K = 2 then 1 else 2);
        begin (if A.Priority > B.Priority then A.Friction (J)
          elsif A.Priority < B.Priority then B.Friction (J)
          else Maximum (A.Friction (J), B.Friction (J))));
   function Raw_Model (A, B : Surface) return Parameters is
     (Condim => Mixed_Dimension (A, B),
      Solref => [for K in Ref_Index =>
        Reference_Component (A, B, Weight (A.Solmix, B.Solmix), K)],
      Solref_Friction => [others => 0.0],
      Solimp => [for K in Imp_Index =>
        Impedance_Component (A, B, Weight (A.Solmix, B.Solmix), K)],
      Friction => [for K in Friction_Index => Friction_Component (A, B, K)],
      Adhesion => Mixed_Adhesion (A, B)) with Ghost => Static, Global => null;
   function Mix (A, B : Surface) return Parameters with Global => null,
     Post => (Static => Mix'Result = Raw_Model (A, B));

   function Expected
     (A, B : Surface; Pair : Explicit_Pair; Override : Override_Options;
      Distance : Wide_Value; Self_Flex : Boolean) return Prepared_Contact
     with Ghost => Static, Global => null,
     Annotate => (GNATprove, Inline_For_Proof);
   function Prepare
     (A, B : Surface; Pair : Explicit_Pair; Override : Override_Options;
      Distance : Wide_Value; Self_Flex : Boolean := False)
     return Prepared_Contact
     with Global => null, Inline_Always,
     Pre => (not Pair.Enabled or else (A.Kind = Geom and then B.Kind = Geom))
       and then (not Self_Flex or else (A.Kind = Flex and then B.Kind = Flex)),
     Post => (Static =>
       (declare E : constant Prepared_Contact := Expected
          (A, B, Pair, Override, Distance, Self_Flex);
        begin Prepare'Result.Include_Margin = E.Include_Margin
          and then Prepare'Result.Detection_Gap = E.Detection_Gap
          and then Prepare'Result.Excluded = E.Excluded
          and then Prepare'Result.Values.Condim = E.Values.Condim
          and then Prepare'Result.Values.Adhesion = E.Values.Adhesion
          and then (for all K in Ref_Index =>
            Prepare'Result.Values.Solref (K) = E.Values.Solref (K)
            and then Prepare'Result.Values.Solref_Friction (K) = E.Values.Solref_Friction (K))
          and then (for all K in Imp_Index =>
            Prepare'Result.Values.Solimp (K) = E.Values.Solimp (K))
          and then (for all K in Friction_Index =>
            Prepare'Result.Values.Friction (K) = E.Values.Friction (K)))
       and then (for all F of Prepare'Result.Values.Friction => F >= Min_Mu)
       and then (if Prepare'Result.Values.Adhesion > 0.0 then
         not Prepare'Result.Excluded)
       and then (if Prepare'Result.Values.Adhesion > 0.0
           and then Distance >= Prepare'Result.Include_Margin then
         Prepare'Result.Values.Condim = 1));
end MJ.Contact_Materials;

package body MJ.Friction_Kernels with SPARK_Mode is
   function Decode_Component (P : Pyramid; Mu : Friction; D : Dimension;
                              C : Positive) return Decoded_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Component);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normal);
   begin
      if C = 1 then
         case D is
            when 1 => return P (1);
            when 3 => return ((((0.0 + P (1)) + P (2)) + P (3)) + P (4));
            when 4 => return ((((((0.0 + P (1)) + P (2)) + P (3)) + P (4)) + P (5)) + P (6));
            when others => return ((((((((((0.0 + P (1)) + P (2)) + P (3)) + P (4)) + P (5)) + P (6)) + P (7)) + P (8)) + P (9)) + P (10));
         end case;
      elsif C <= D then
         return (P (2 * (C - 1) - 1) - P (2 * (C - 1))) * Mu (C - 1);
      else
         return 0.0;
      end if;
   end Decode_Component;

   procedure Decode (P : Pyramid; Mu : Friction; D : Dimension; F : out Contact_Force) is
   begin
      F := (Decode_Component (P, Mu, D, 1), Decode_Component (P, Mu, D, 2),
            Decode_Component (P, Mu, D, 3), Decode_Component (P, Mu, D, 4),
            Decode_Component (P, Mu, D, 5), Decode_Component (P, Mu, D, 6));
   end Decode;

   function Encode_Edge (F : Contact_Force; Mu : Friction;
                         D : Dimension; E : Positive) return Force_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Encoded_Edge);
   begin
      if E > Edge_Count (D) then return 0.0; end if;
      if D = 1 then return F (1); end if;
      declare
         A : constant Real range -1.0e10 .. 1.0e10 := F (1) / Real (D - 1);
         T : constant Real range -1.0e16 .. 1.0e16 := F ((E + 1) / 2 + 1) / Mu ((E + 1) / 2);
         B : constant Real := (if T < A then T else A);
      begin
         if E mod 2 = 1 then return 0.5 * (A + B);
         else return 0.5 * (A - B); end if;
      end;
   end Encode_Edge;

   procedure Encode (F : Contact_Force; Mu : Friction; D : Dimension; P : out Pyramid) is
   begin
      P := (Encode_Edge (F, Mu, D, 1), Encode_Edge (F, Mu, D, 2),
            Encode_Edge (F, Mu, D, 3), Encode_Edge (F, Mu, D, 4),
            Encode_Edge (F, Mu, D, 5), Encode_Edge (F, Mu, D, 6),
            Encode_Edge (F, Mu, D, 7), Encode_Edge (F, Mu, D, 8),
            Encode_Edge (F, Mu, D, 9), Encode_Edge (F, Mu, D, 10));
   end Encode;

   function Project (Kind : Row_Kind; F : Raw_Value; Bound : Bound_Value) return Raw_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Projected);
   begin
      case Kind is
         when Equality => return F;
         when Dry_Friction =>
            if F < -Bound then return -Bound;
            elsif F > Bound then return Bound;
            else return F; end if;
         when Nonnegative =>
            if F < 0.0 then return 0.0; else return F; end if;
      end case;
   end Project;

   function Cost_Change (Old_Force, New_Force : Force_Value;
                         Residual : Residual_Value; Inv : Inverse_Diagonal)
     return Cost_Value is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Delta_Cost);
      Difference : constant Real range -2.0e20 .. 2.0e20 := New_Force - Old_Force;
   begin
      return (((0.5 * Difference) * Difference) * (1.0 / Inv)) + (Difference * Residual);
   end Cost_Change;

   function Store (Old_Force, Proposed : Force_Value; Change : Cost_Value) return Step_Result
   with Annotate => (GNATprove, Inline_For_Proof),
     Post => (Static => Store'Result = Model.Stored (Old_Force, Proposed, Change))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Stored);
   begin
      if Change > 1.0e-10 then return (True, Old_Force, 0.0); end if;
      return (True, Proposed, Change);
   end Store;

   function Step (Kind : Row_Kind; Old_Force : Force_Value;
                  Residual : Residual_Value; Inv : Inverse_Diagonal;
                  Bound : Bound_Value) return Step_Result is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Feasible);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Candidate);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Projected);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Delta_Cost);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Stored);
      Candidate : constant Raw_Value := Project (Kind, Old_Force - Residual * Inv, Bound);
      Change : Cost_Value;
   begin
      pragma Assert (Static => Candidate = Model.Candidate (Kind, Old_Force, Residual, Inv, Bound));
      if Candidate not in Force_Value then return (False, Old_Force, 0.0); end if;
      Change := Cost_Change (Old_Force, Candidate, Residual, Inv);
      pragma Assert (Static => Change = Model.Delta_Cost (Old_Force, Candidate, Residual, Inv));
      return Store (Old_Force, Candidate, Change);
   end Step;
end MJ.Friction_Kernels;

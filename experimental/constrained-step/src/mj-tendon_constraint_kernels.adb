package body MJ.Tendon_Constraint_Kernels with SPARK_Mode is
   use type CA.Limit_Side, CA.Result;
   function Distance (Length, Bound : Tier0_Real; Side : CA.Limit_Side)
     return Tier1_Real is
   begin
      return (if Side = CA.Lower then -1.0 else 1.0) * (Bound - Length);
   end Distance;
   function Signed_Value (Value : Tier2_Real; Side : CA.Limit_Side)
     return Tier2_Real is
   begin
      return (if Side = CA.Lower then Value else -Value);
   end Signed_Value;
   procedure Build_Row (Values : CA.Value_Array; Side : CA.Limit_Side;
                        J : out CA.Matrix) is
   begin
      for K in Values'Range loop
         J (1, K) := Signed_Value (Values (K), Side);
         pragma Loop_Invariant (for all C in 1 .. K =>
           J (1, C)'Initialized and then J (1, C) = Signed_Value (Values (C), Side));
      end loop;
   end Build_Row;
   procedure Add_Friction (B : in out CA.Storage; Id : Natural;
                           Chain : CA.Column_Array; Values : CA.Value_Array;
                           Loss : Nonneg_Tier0; Result : out CA.Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", CA.Row_Is);
      Initial_Rows : constant CA.Row_Count := B.Rows with Ghost => Static;
      Initial_Used : constant CA.Entry_Count := B.Used with Ghost => Static;
      J : CA.Matrix (1 .. 1, Values'Range);
   begin
      if Loss = 0.0 or else Chain'Length = 0 then Result := CA.Skipped; return; end if;
      if not CA.Fits (B, 1, Chain'Length) then Result := CA.Capacity_Limit; return; end if;
      Build_Row (Values, CA.Lower, J);
      CA.Append (B, CA.Friction_Tendon, Id, Chain, J, [1 => (0.0, 0.0)], Loss, Result);
      pragma Assert (Static => Result = CA.Success);
      pragma Assert (Static => (for all R in 1 .. 1 =>
        CA.Row_Is (B.Descriptors (Initial_Rows + R),
          Initial_Used + (R - 1) * Chain'Length, Chain'Length,
          (0.0, 0.0), Loss, CA.Friction_Tendon, Id)));
      pragma Assert (Static => (for all R in 1 .. 1 =>
        (for all C in Values'Range =>
          B.Values ((Initial_Used + (R - 1) * Chain'Length) + C) = J (R, C))));
   end Add_Friction;
   procedure Add_Limit (B : in out CA.Storage; Id : Natural;
                        Chain : CA.Column_Array; Values : CA.Value_Array;
                        Length, Bound, Margin : Tier0_Real;
                        Side : CA.Limit_Side; Result : out CA.Result) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", CA.Row_Is);
      Initial_Rows : constant CA.Row_Count := B.Rows with Ghost => Static;
      Initial_Used : constant CA.Entry_Count := B.Used with Ghost => Static;
      Pos : constant Tier1_Real := Distance (Length, Bound, Side);
      J : CA.Matrix (1 .. 1, Values'Range);
   begin
      if Pos >= Margin or else Chain'Length = 0 then Result := CA.Skipped; return; end if;
      if not CA.Fits (B, 1, Chain'Length) then Result := CA.Capacity_Limit; return; end if;
      Build_Row (Values, Side, J);
      CA.Append (B, CA.Limit_Tendon, Id, Chain, J, [1 => (Pos, Margin)], 0.0, Result);
      pragma Assert (Static => Result = CA.Success);
      pragma Assert (Static => (for all R in 1 .. 1 =>
        CA.Row_Is (B.Descriptors (Initial_Rows + R),
          Initial_Used + (R - 1) * Chain'Length, Chain'Length,
          (Pos, Margin), 0.0, CA.Limit_Tendon, Id)));
      pragma Assert (Static => (for all R in 1 .. 1 =>
        (for all C in Values'Range =>
          B.Values ((Initial_Used + (R - 1) * Chain'Length) + C) = J (R, C))));
   end Add_Limit;
end MJ.Tendon_Constraint_Kernels;

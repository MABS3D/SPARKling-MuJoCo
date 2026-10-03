package body MJ.Constraint_Solvers.Jacobian_Transpose with SPARK_Mode is
   procedure Unfold_Width (J : Sparse_Jacobian; R : Natural) with
     Ghost => Static, Global => null,
     Pre => Layout (J) and then R < J.Row_Count,
     Post => Width_Prefix (J, R+1) = Width_Prefix (J, R)+J.Widths (R+1)
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Width_Prefix);
   begin
      null;
   end Unfold_Width;

   function Total_Width (J : Sparse_Jacobian) return Natural is
      Sum : Natural := 0;
   begin
      for R in 1 .. J.Row_Count loop
         Unfold_Width (J, R-1);
         Sum := Sum+J.Widths (R);
         pragma Loop_Invariant (Static => Sum = Width_Prefix (J, R));
         pragma Loop_Invariant (Sum <= R*J.Stored);
      end loop;
      return Sum;
   end Total_Width;

   procedure Build (J : Sparse_Jacobian; T : out Sparse_Jacobian) is
      Columns : constant Natural := T.Row_Count;
      Cursor : Entry_Counts (1 .. Columns);
   begin
      T.Widths := (others => 0); T.Offsets := (others => 0);
      T.Columns := (others => 1); T.Values := (others => 0.0);
      --  Count, prefix, stable scatter: the input row/slot order is never
      --  sorted or coalesced, so duplicate column slots remain distinct.
      for R in 1 .. J.Row_Count loop
         for P in 1 .. J.Widths (R) loop
            declare C : constant Positive := J.Columns (J.Offsets (R)+P); begin
               T.Widths (C) := T.Widths (C)+1;
            end;
         end loop;
      end loop;
      for C in 2 .. T.Row_Count loop
         T.Offsets (C) := T.Offsets (C-1)+T.Widths (C-1);
      end loop;
      Cursor := T.Offsets;
      for R in 1 .. J.Row_Count loop
         for P in 1 .. J.Widths (R) loop
            declare C : constant Positive := J.Columns (J.Offsets (R)+P); begin
               Cursor (C) := Cursor (C)+1;
               T.Columns (Cursor (C)) := R;
               T.Values (Cursor (C)) := J.Values (J.Offsets (R)+P);
            end;
         end loop;
      end loop;
   end Build;
end MJ.Constraint_Solvers.Jacobian_Transpose;

package body MJ.Constraint_Solvers.Support_Counts with SPARK_Mode is
   procedure Support_Unfold (Widths : Lengths; Limit, Count : Natural) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Support_Prefix);
   begin
      null;
   end Support_Unfold;
   function Support_Total (Widths : Lengths; Limit : Natural) return Natural is
      Total : Natural := 0;
   begin
      Support_Unfold (Widths, Limit, 0);
      for R in Widths'Range loop
         Support_Unfold (Widths, Limit, R);
         Total := Total+Widths (R);
         pragma Loop_Invariant (Total <= R*Limit);
         pragma Loop_Invariant (Static => Total = Support_Prefix (Widths, Limit, R));
      end loop;
      return Total;
   end Support_Total;
end MJ.Constraint_Solvers.Support_Counts;

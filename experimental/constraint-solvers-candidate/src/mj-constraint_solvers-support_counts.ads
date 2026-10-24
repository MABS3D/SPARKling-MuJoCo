--  Exact integer sizing of coalesced numerical support; no matrix reread.
package MJ.Constraint_Solvers.Support_Counts with SPARK_Mode is
   type Lengths is array (Positive range <>) of Natural;
   function Widths_Valid (Widths : Lengths; Limit : Natural) return Boolean is
     (Widths'First = 1 and then Widths'Length <= Max_Rows
      and then Limit <= Max_Dofs and then (for all W of Widths => W <= Limit));
   function Support_Prefix (Widths : Lengths; Limit, Count : Natural) return Natural is
     (if Count = 0 then 0 else Support_Prefix (Widths, Limit, Count-1)+Widths (Count))
     with Ghost => Static, Global => null,
     Pre => Widths_Valid (Widths, Limit) and then Count <= Widths'Length,
     Post => Support_Prefix'Result <= Count*Limit,
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   procedure Support_Unfold (Widths : Lengths; Limit, Count : Natural) with
     Ghost => Static, Global => null,
     Pre => Widths_Valid (Widths, Limit) and then Count <= Widths'Length,
     Post => Support_Prefix (Widths, Limit, Count) =
       (if Count = 0 then 0 else Support_Prefix (Widths, Limit, Count-1)+Widths (Count));
   function Support_Total (Widths : Lengths; Limit : Natural) return Natural with
     Global => null, Pre => Widths_Valid (Widths, Limit),
     Post => Support_Total'Result <= Widths'Length*Limit;
   pragma Postcondition (Static => Support_Total'Result = Support_Prefix (Widths, Limit, Widths'Length));
end MJ.Constraint_Solvers.Support_Counts;

--  Stable slot-preserving CSR transpose, matching mju_transposeSparse 3.14.0.
with MJ.Constraint_Solvers.Jacobians;
package MJ.Constraint_Solvers.Jacobian_Transpose with SPARK_Mode is
   function Layout (J : Sparse_Jacobian) return Boolean is
     (J.Row_Count <= Max_Rows and then J.Stored <= Max_Jacobian_Entries
      and then (for all R in 1 .. J.Row_Count =>
        J.Offsets (R) <= J.Stored and then J.Widths (R) <= J.Stored-J.Offsets (R)))
     with Global => null;
   function Width_Prefix (J : Sparse_Jacobian; R : Natural) return Natural is
     (if R = 0 then 0 else Width_Prefix (J, R-1)+J.Widths (R))
     with Ghost => Static, Global => null,
     Pre => Layout (J) and then R <= J.Row_Count,
     Post => Width_Prefix'Result <= R*J.Stored,
     Subprogram_Variant => (Decreases => R),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Total_Width (J : Sparse_Jacobian) return Natural with
     Global => null, Pre => Layout (J),
     Post => (Static => Total_Width'Result = Width_Prefix (J, J.Row_Count)
       and then Total_Width'Result <= J.Row_Count*J.Stored);

   --  Number of occurrences of a column in preceding rows and the first
   --  Prefix slots of R. This defines the stable output location of each
   --  individual slot, including duplicates and explicit zero values.
   function Before (J : Sparse_Jacobian; Column, R : Positive; Prefix : Natural)
     return Natural is
     (if Prefix > 0 then Before (J, Column, R, Prefix-1)
        + (if J.Columns (J.Offsets (R)+Prefix) = Column then 1 else 0)
      elsif R > 1 then Before (J, Column, R-1, J.Widths (R-1)) else 0)
     with Ghost => Static, Global => null,
     Pre => Layout (J) and then R <= J.Row_Count and then Prefix <= J.Widths (R),
     Post => Before'Result <= (R-1)*J.Stored+Prefix,
     Subprogram_Variant => (Decreases => R, Decreases => Prefix),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   procedure Build (J : Sparse_Jacobian; T : out Sparse_Jacobian) with
     Global => null,
     Pre => J.Row_Count in 1 .. Max_Rows and then T.Row_Count in 1 .. Max_Dofs
       and then Jacobians.Valid (J, T.Row_Count)
       and then T.Stored = Total_Width (J) and then T.Stored <= Max_Jacobian_Entries,
     Post => (Static => Jacobians.Valid (T, J.Row_Count)
       and then T.Offsets (1) = 0
       and then (for all C in 2 .. T.Row_Count =>
         T.Offsets (C) = T.Offsets (C-1)+T.Widths (C-1))
       and then (for all C in 1 .. T.Row_Count =>
         T.Widths (C) = Before (J, C, J.Row_Count, J.Widths (J.Row_Count)))
       and then (for all R in 1 .. J.Row_Count =>
         (for all P in 1 .. J.Widths (R) =>
            T.Offsets (J.Columns (J.Offsets (R)+P))
              +Before (J, J.Columns (J.Offsets (R)+P), R, P-1)+1 in T.Values'Range
            and then T.Columns (T.Offsets (J.Columns (J.Offsets (R)+P))
              +Before (J, J.Columns (J.Offsets (R)+P), R, P-1)+1) = R
            and then T.Values (T.Offsets (J.Columns (J.Offsets (R)+P))
              +Before (J, J.Columns (J.Offsets (R)+P), R, P-1)+1)
                = J.Values (J.Offsets (R)+P))));
end MJ.Constraint_Solvers.Jacobian_Transpose;

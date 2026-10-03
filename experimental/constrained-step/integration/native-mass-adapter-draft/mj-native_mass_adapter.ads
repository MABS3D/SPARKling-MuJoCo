with MJ.Types; use MJ.Types;
with MJ.Ancestor_Rows;
with MJ.Constraint_Solvers;
with MJ.Constraint_Solvers.Native_Inertia;

--  Translate the owned Ada ancestor factor to the solver's ordered CSR.
--  No matrix arithmetic or factor provenance is assumed by this copy helper.
package MJ.Native_Mass_Adapter with SPARK_Mode is
   package AR renames MJ.Ancestor_Rows;
   package CS renames MJ.Constraint_Solvers;
   package NI renames MJ.Constraint_Solvers.Native_Inertia;

   procedure Copy_Row
     (Rows : AR.Pattern; Row : Natural; Factor : Real_Array;
      Columns : out CS.Column_Indices; Values : out CS.Vector; Inverse : out Real)
     with Global => null, Inline, Relaxed_Initialization => (Columns, Values),
     Pre => (Static => Row < AR.Size (Rows)
       and then Factor'First = 0 and then Factor'Last = AR.Count (Rows)-1
       and then Columns'First = AR.Start (Rows, Row)+1
       and then Columns'Length = AR.Length (Rows, Row)
       and then Values'First = Columns'First and then Values'Last = Columns'Last
       and then Factor (AR.Start (Rows, Row)+AR.Length (Rows, Row)-1) in 1.0e-15 .. 1.0e60),
     Post => (Static => Columns'Initialized and then Values'Initialized
       and then Inverse = NI.Reciprocal (Factor (AR.Start (Rows, Row)+AR.Length (Rows, Row)-1))
       and then Inverse in 1.0e-61 .. 1.0e16
       and then (for all S in Columns'Range =>
         Columns (S) = AR.Column (Rows, Row, S-Columns'First)+1
         and then Values (S) = Factor (S-1)
         and then (if S = Columns'Last then Columns (S) = Row+1 else Columns (S) < Row+1)
         and then (if S > Columns'First then Columns (S-1) < Columns (S))));

   procedure Mapping_Row (Rows : AR.Pattern; Native : CS.Sparse_Jacobian; Row : Positive) with
     Ghost => Static, Global => null,
     Pre => Row <= Native.Row_Count and then AR.Size (Rows) in 1 .. CS.Max_Dofs
       and then Native.Row_Count = AR.Size (Rows) and then Native.Stored = AR.Count (Rows)
       and then (for all Value of Native.Values => Value in NI.Operand)
       and then (for all R in 1 .. Native.Row_Count =>
         Native.Offsets (R) = AR.Start (Rows, R-1))
       and then (for all R in 1 .. Native.Row_Count =>
         Native.Widths (R) = AR.Length (Rows, R-1)-1)
       and then (for all R in 1 .. Native.Row_Count =>
         (for all K in 0 .. AR.Length (Rows, R-1)-1 =>
           Native.Columns (AR.Start (Rows, R-1)+K+1) = AR.Column (Rows, R-1, K)+1)),
     Post => (for all K in 0 .. AR.Length (Rows, Row-1)-1 =>
       Native.Columns (AR.Start (Rows, Row-1)+K+1) = AR.Column (Rows, Row-1, K)+1);

   procedure Finish_Lower (Rows : AR.Pattern; Native : CS.Sparse_Jacobian) with
     Ghost => Static, Global => null,
     Pre => AR.Size (Rows) in 1 .. CS.Max_Dofs
       and then Native.Row_Count = AR.Size (Rows) and then Native.Stored = AR.Count (Rows)
       and then (for all Value of Native.Values => Value in NI.Operand)
       and then (for all R in 1 .. Native.Row_Count =>
         Native.Offsets (R) = AR.Start (Rows, R-1))
       and then (for all R in 1 .. Native.Row_Count =>
         Native.Widths (R) = AR.Length (Rows, R-1)-1)
       and then (for all R in 1 .. Native.Row_Count =>
         (for all K in 0 .. AR.Length (Rows, R-1)-1 =>
           Native.Columns (AR.Start (Rows, R-1)+K+1) = AR.Column (Rows, R-1, K)+1)),
     Post => NI.Lower_Valid (Native);

   procedure Pack
     (Rows : AR.Pattern; Factor : Real_Array;
      Native : out CS.Sparse_Jacobian; Inverse : out CS.Vector; Accepted : out Boolean)
     with Global => null, Relaxed_Initialization => (Native, Inverse),
     Pre => (Static => AR.Size (Rows) in 1 .. CS.Max_Dofs
       and then Factor'First = 0 and then Factor'Last = AR.Count (Rows)-1
       and then (for all Value of Factor => Value in NI.Operand)
       and then Native.Row_Count = AR.Size (Rows) and then Native.Stored = AR.Count (Rows)
       and then Inverse'First = 1 and then Inverse'Length = AR.Size (Rows)),
     Post => (Static => (if Accepted then Native'Initialized and then Inverse'Initialized
       and then NI.Lower_Valid (Native) and then NI.Inverse_Valid (Inverse, AR.Size (Rows))
       and then (for all S in Native.Values'Range => Native.Values (S) = Factor (S-1))
       and then (for all R in 1 .. Native.Row_Count =>
         Native.Offsets (R) = AR.Start (Rows, R-1)
         and then Native.Widths (R) = AR.Length (Rows, R-1)-1
         and then Factor (AR.Start (Rows, R-1)+AR.Length (Rows, R-1)-1) in 1.0e-15 .. 1.0e60
         and then Inverse (R) = NI.Reciprocal (Factor (AR.Start (Rows, R-1)+AR.Length (Rows, R-1)-1))
         and then (for all K in 0 .. AR.Length (Rows, R-1)-1 =>
           Native.Columns (AR.Start (Rows, R-1)+K+1) = AR.Column (Rows, R-1, K)+1))));
end MJ.Native_Mass_Adapter;

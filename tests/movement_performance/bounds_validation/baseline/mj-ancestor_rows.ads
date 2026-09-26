with MJ.Types; use MJ.Types;
with MJ.Smooth_Kernels;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;

--  Immutable, full rows of the supplied parent forest: root first, diagonal
--  last. The caller may supply validated effective roots for simple DOFs.
package MJ.Ancestor_Rows with SPARK_Mode is
   Max_Dofs : constant := 256;
   Max_Entries : constant := Max_Dofs * (Max_Dofs + 1) / 2;
   subtype Dof_Count is Natural range 0 .. Max_Dofs;
   subtype Entry_Count is Natural range 0 .. Max_Entries;
   type Pattern is limited private;

   function Empty (P : Pattern) return Boolean with Global => null;
   function Size (P : Pattern) return Dof_Count with Global => null;
   function Count (P : Pattern) return Entry_Count with Global => null;
   function Start (P : Pattern; Row : Natural) return Entry_Count with
     Global => null, Pre => Row < Size (P),
     Post => Start'Result < Count (P);
   function Length (P : Pattern; Row : Natural) return Positive with
     Global => null, Pre => Row < Size (P),
     Post => Length'Result <= Row + 1
       and then Start (P, Row) + Length'Result <= Count (P);
   function Column (P : Pattern; Row, Offset : Natural) return Natural with
     Global => null, Pre => Row < Size (P) and then Offset < Length (P, Row),
     Post => Column'Result <= Row
       and then (if Offset = Length (P, Row) - 1 then Column'Result = Row
                 else Column'Result < Row)
       and then Length (P, Column'Result) = Offset + 1
       and then (if Length (P, Row) = Row + 1 then Column'Result = Offset);
   function Dense_Prefix_Start (P : Pattern; Row : Natural) return Entry_Count with
     Global => null, Pre => Row < Size (P) and then Length (P, Row) = Row + 1,
     Post => Dense_Prefix_Start'Result = Start (P, Row);
   function Parent (P : Pattern; Row : Natural) return Integer with
     Global => null, Pre => Row < Size (P),
     Post => Parent'Result in -1 .. Integer (Row) - 1;

   --  Expose the proved separation of packed rows sharing one factor buffer.
   procedure Rows_Disjoint (P : Pattern; Earlier, Later : Natural) with
     Ghost => Static, Global => null,
     Pre => Earlier < Later and then Later < Size (P),
     Post => Start (P, Earlier) + Length (P, Earlier) <= Start (P, Later);

   procedure Copy_Row (P : Pattern; Row : Natural; Dense : Real_Array;
                       Target : in out Real_Array) with
     Global => null,
     Pre => Row < Size (P) and then Dense'First = 0
       and then Dense'Last = Size (P) * Size (P) - 1
       and then Int64 (Target'Length) = Int64 (Length (P, Row)),
     Post => (for all A in Target'Range => Target (A) =
       Dense (MJ.Smooth_Kernels.Matrix_Offset (Size (P), Row, Column (P, Row, A - Target'First))));

   --  Pack the complete matrix without a separate memcpy/memmove call for
   --  every short row. Index storage is read once through this interface.
   procedure Copy_Matrix (P : Pattern; Dense : Real_Array; Target : in out Real_Array) with
     Global => null,
     Pre => Dense'First = 0 and then Dense'Last = Size (P) * Size (P) - 1
       and then Target'First = 0 and then Target'Last = Count (P) - 1
       and then Work_Array (Dense),
     Post => Work_Array (Target)
       and then (for all I in 0 .. Size (P) - 1 =>
         (for all A in 0 .. Length (P, I) - 1 => Target (Start (P, I) + A) =
           Dense (MJ.Smooth_Kernels.Matrix_Offset (Size (P), I, Column (P, I, A)))));
   pragma No_Inline (Copy_Matrix);

   function Valid_Parents (Parents : Int_Array) return Boolean is
     (Parents'First = 0 and then Parents'Length <= Max_Dofs
      and then (for all I in Parents'Range => Parents (I) in -1 .. Integer (I) - 1));
   procedure Build (P : in out Pattern; Parents : Int_Array) with
     Global => null, Pre => Empty (P) and then Valid_Parents (Parents),
     Post => not Empty (P) and then Size (P) = Parents'Length
       and then (for all I in Parents'Range => Parent (P, I) = Parents (I));
   procedure Free (P : in out Pattern) with Global => null,
     Post => Empty (P) and then Size (P) = 0 and then Count (P) = 0;

private
   --  The invariant is proved at construction and preserved by the only
   --  mutator (Free). Consumers cannot edit or borrow the owned index arrays.
   function Valid (P : Pattern) return Boolean with Global => null;
   type Pattern is limited record
      N : Dof_Count := 0;
      Starts, Columns : Int_Array_Access := null;
   end record with Type_Invariant => Valid (Pattern);

   function Row_OK (Starts, Columns : Int_Array; I : Natural) return Boolean is
     (Starts (I) >= 0 and then Starts (I + 1) > Starts (I)
      and then Starts (I + 1) <= Columns'Length
      and then Starts (I + 1) - Starts (I) <= I + 1
      and then Columns (Starts (I + 1) - 1) = I
      and then (if Starts (I + 1) - Starts (I) = I + 1 then Starts (I) = I * (I + 1) / 2)
      and then (for all A in Starts (I) .. Starts (I + 1) - 1 =>
        Columns (A) in 0 .. Integer (I)
        and then Starts (Columns (A) + 1) - Starts (Columns (A)) = A - Starts (I) + 1
        and then (if A < Starts (I + 1) - 1 then Columns (A) < I)
        and then (if A > Starts (I) then Columns (A - 1) < Columns (A))
        and then (if Starts (I + 1) - Starts (I) = I + 1 then Columns (A) = A - Starts (I)))
      and then (if Starts (I + 1) - Starts (I) > 1 then
        (for all A in Starts (I) .. Starts (I + 1) - 2 =>
          Columns (A) = Columns (Starts (Columns (Starts (I + 1) - 2)) + A - Starts (I)))))
     with Pre => Starts'First = 0 and then Starts'Length in 1 .. Max_Dofs + 1
       and then I < Starts'Last and then Columns'First = 0
       and then Columns'Length <= Max_Entries
       and then (for all S of Starts => S in 0 .. Columns'Length);

   function Valid (P : Pattern) return Boolean is
     (if P.Starts = null then P.N = 0 and then P.Columns = null
      else P.Columns /= null and then P.Starts'First = 0
        and then P.Starts'Last = P.N and then P.Starts (0) = 0
        and then P.Columns'First = 0 and then P.Columns'Length <= Max_Entries
        and then P.Starts (P.N) = P.Columns'Length
        and then (for all S of P.Starts.all => S in 0 .. P.Columns'Length)
        and then (for all I in 0 .. P.N =>
          (for all J in I .. P.N => P.Starts (I) <= P.Starts (J)))
        and then (for all I in 0 .. P.N - 1 => Row_OK (P.Starts.all, P.Columns.all, I)));

   function Empty (P : Pattern) return Boolean is (P.Starts = null);
   function Size (P : Pattern) return Dof_Count is (P.N);
   function Count (P : Pattern) return Entry_Count is
     (if P.Starts = null then 0 else P.Columns'Length);
   function Start (P : Pattern; Row : Natural) return Entry_Count is (P.Starts (Row));
   function Length (P : Pattern; Row : Natural) return Positive is
     (P.Starts (Row + 1) - P.Starts (Row));
   function Column (P : Pattern; Row, Offset : Natural) return Natural is
     (P.Columns (P.Starts (Row) + Offset));
   function Dense_Prefix_Start (P : Pattern; Row : Natural) return Entry_Count is (Row * (Row + 1) / 2);
   function Parent (P : Pattern; Row : Natural) return Integer is
     (if Length (P, Row) = 1 then -1 else Column (P, Row, Length (P, Row) - 2));
end MJ.Ancestor_Rows;

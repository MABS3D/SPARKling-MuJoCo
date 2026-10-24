with MJ.Types; use MJ.Types;

--  Admission kernels for the C 3.17 structural checks. Models describe the
--  actual integer/ordered scans. These new contracts are pending proof.
package MJ.Model_Structures with SPARK_Mode is
   type CSR_Code is (Valid, Shape_Error, Width_Error, Address_Error, Column_Error);
   type CSR_Result is record
      Code : CSR_Code := Valid;
      Row : Integer := -1;
   end record;

   function Shape (Values : Int_Array) return Boolean is
     (Values'First = 0 and then Values'Length <= Integer'Last);
   function Span (Values : Int_Array; Address, Width : Integer) return Boolean is
     (Width >= 0 and then Width <= Values'Length and then Address >= 0
      and then Int64 (Address) <= Int64 (Values'Length)-Int64 (Width))
     with Pre => Shape (Values);
   function Width_OK (Width : Integer; Ncols : Natural; Strict : Boolean) return Boolean is
     (Width >= 0 and then (not Strict or else Width <= Ncols));
   --  Nonstrict rows retain repeated fixed-tendon columns. The unconditional
   --  C3.17 width<=ncols check rejects compiler-produced Nv=1 duplicate rows;
   --  this deliberate correction is documented by the private regression.
   function Column_OK (Values : Int_Array; Address, Width : Integer;
                       Ncols : Natural; Strict : Boolean; Position : Natural) return Boolean is
     (Values (Address+Position) in 0 .. Ncols-1
      and then (Position = 0 or else
        (if Strict then Values (Address+Position-1) < Values (Address+Position)
         else Values (Address+Position-1) <= Values (Address+Position))))
     with Pre => Shape (Values) and then Span (Values, Address, Width) and then Position < Width;
   function Columns_OK (Values : Int_Array; Address, Width : Integer;
                        Ncols : Natural; Strict : Boolean) return Boolean is
     (for all K in 0 .. Width-1 => Column_OK (Values, Address, Width, Ncols, Strict, K))
     with Pre => Shape (Values) and then Span (Values, Address, Width);
   function Row_Valid (Values : Int_Array; Address, Width : Integer;
                       Ncols : Natural; Strict : Boolean := True) return Boolean is
     (Width_OK (Width, Ncols, Strict) and then Span (Values, Address, Width)
      and then Columns_OK (Values, Address, Width, Ncols, Strict))
     with Pre => Shape (Values);
   function Check_Row (Values : Int_Array; Address, Width : Integer;
                       Ncols : Natural; Strict : Boolean := True) return CSR_Code with
     Global => null, Pre => Shape (Values),
     Post => Check_Row'Result =
       (if not Width_OK (Width, Ncols, Strict) then Width_Error
        elsif not Span (Values, Address, Width) then Address_Error
        elsif not Columns_OK (Values, Address, Width, Ncols, Strict) then Column_Error
        else Valid);

   --  C's CSR domain allows unused storage, gaps, and shared row spans. The
   --  old compact CSR policy is kept separate in MJ.Models.Validity.CSR_OK.
   function Matrix_Shape (Widths, Addresses, Columns : Int_Array; Nrows, Nnz : Natural) return Boolean is
     (Shape (Widths) and then Shape (Addresses) and then Shape (Columns)
      and then Widths'Length = Nrows and then Addresses'Length = Nrows
      and then Columns'Length = Nnz);
   function Matrix_Valid (Widths, Addresses, Columns : Int_Array;
                          Nrows, Ncols, Nnz : Natural; Strict : Boolean := True) return Boolean is
     (Matrix_Shape (Widths, Addresses, Columns, Nrows, Nnz)
      and then (for all R in 0 .. Nrows-1 => Row_Valid (Columns, Addresses (R), Widths (R), Ncols, Strict)));
   function Check_CSR (Widths, Addresses, Columns : Int_Array;
                       Nrows, Ncols, Nnz : Natural; Strict : Boolean := True) return CSR_Result with
     Global => null,
     Post => (Check_CSR'Result.Code = Valid) = Matrix_Valid (Widths, Addresses, Columns, Nrows, Ncols, Nnz, Strict)
       and then (if Matrix_Shape (Widths, Addresses, Columns, Nrows, Nnz) then
         (if Check_CSR'Result.Code /= Valid then Check_CSR'Result.Row in 0 .. Nrows-1
          and then Check_CSR'Result.Code = Check_Row (Columns, Addresses (Check_CSR'Result.Row),
            Widths (Check_CSR'Result.Row), Ncols, Strict)
          and then (for all R in 0 .. Check_CSR'Result.Row-1 =>
            Row_Valid (Columns, Addresses (R), Widths (R), Ncols, Strict)))
         else Check_CSR'Result.Code = Shape_Error and then Check_CSR'Result.Row = -1);

   procedure Row_Entry (Columns : Int_Array; Address, Width : Integer; Ncols, Position : Natural) with
     Ghost => Static, Global => null,
     Pre => Shape (Columns) and then Row_Valid (Columns, Address, Width, Ncols)
       and then Position < Width,
     Post => Column_OK (Columns, Address, Width, Ncols, True, Position);
   procedure Ordered_Positions (Columns : Int_Array; Address, Width : Integer;
                                Ncols, First, Last : Natural) with
     Ghost => Static, Global => null,
     Pre => Shape (Columns) and then Row_Valid (Columns, Address, Width, Ncols)
       and then First <= Last and then Last < Width,
     Post => Columns (Address+First) <= Columns (Address+Last)
       and then (if First < Last then Columns (Address+First) < Columns (Address+Last)),
     Subprogram_Variant => (Decreases => Last);
   procedure Reject_Column (Columns : Int_Array; Address, Width : Integer;
                            Ncols, Cursor : Natural; Value : Integer) with
     Ghost => Static, Global => null,
     Pre => Shape (Columns) and then Row_Valid (Columns, Address, Width, Ncols)
       and then Cursor <= Width
       and then (for all K in 0 .. Cursor-1 => Columns (Address+K) < Value)
       and then (Cursor = Width or else Value < Columns (Address+Cursor)),
     Post => (for all K in 0 .. Width-1 => Columns (Address+K) /= Value);
   procedure Find_Column (Columns : Int_Array; Address, Width : Integer; Ncols : Natural;
                          Value : Integer; Cursor : in out Natural; Found : out Boolean) with
     Global => null,
     Pre => Shape (Columns) and then Row_Valid (Columns, Address, Width, Ncols)
       and then Cursor <= Width
       and then (for all K in 0 .. Cursor-1 => Columns (Address+K) < Value),
     Post => Cursor in Cursor'Old .. Width
       and then Found = (for some K in 0 .. Width-1 => Columns (Address+K) = Value)
       and then (for all K in 0 .. Cursor-1 => Columns (Address+K) < Value)
       and then (if Found then Cursor < Width and then Columns (Address+Cursor) = Value
         else Cursor = Width or else Value < Columns (Address+Cursor));
   function Subset_Model (Columns : Int_Array; Child_Address, Child_Width, Parent_Address, Parent_Width : Integer)
                          return Boolean is
     (for all K in 0 .. Child_Width-1 =>
       (for some J in 0 .. Parent_Width-1 => Columns (Child_Address+K) = Columns (Parent_Address+J)))
     with Ghost => Static,
     Pre => Shape (Columns) and then Span (Columns, Child_Address, Child_Width)
       and then Span (Columns, Parent_Address, Parent_Width);
   function Sorted_Subset (Columns : Int_Array; Child_Address, Child_Width, Parent_Address, Parent_Width : Integer;
                           Ncols : Natural) return Boolean with
     Global => null,
     Pre => Shape (Columns) and then Row_Valid (Columns, Child_Address, Child_Width, Ncols)
       and then Row_Valid (Columns, Parent_Address, Parent_Width, Ncols),
     Post => (Static => Sorted_Subset'Result = Subset_Model (Columns, Child_Address, Child_Width, Parent_Address, Parent_Width));

   function Body_Links (Parent, Weld, Width : Int_Array; Nv : Natural) return Boolean is
     (Shape (Parent) and then Shape (Weld) and then Shape (Width)
      and then Parent'Length in 1 .. Max_Size and then Weld'Length = Parent'Length
      and then Width'Length = Parent'Length and then Nv <= Max_Size
      and then Parent (0) = 0 and then Weld (0) = 0
      and then (for all B in Parent'Range => Width (B) in 0 .. Nv and then Weld (B) in 0 .. B
        and then (if B > 0 then Parent (B) in 0 .. B-1)));
   function Body_Count_Model (Parent, Weld, Width : Int_Array; Nv, Node : Natural) return Int64 is
     (if Node = 0 then 0 else Int64 (Width (Node)) +
       Body_Count_Model (Parent, Weld, Width, Nv, Weld (Parent (Node)))) with
     Ghost => Static, Global => null,
     Pre => Body_Links (Parent, Weld, Width, Nv) and then Node < Parent'Length,
     Post => Body_Count_Model'Result in 0 .. Int64 (Node)*Int64 (Nv),
     Subprogram_Variant => (Decreases => Node);
   procedure Unfold_Body_Count (Parent, Weld, Width : Int_Array; Nv, Node : Natural) with
     Ghost => Static, Global => null,
     Pre => Body_Links (Parent, Weld, Width, Nv) and then Node < Parent'Length,
     Post => Body_Count_Model (Parent, Weld, Width, Nv, Node) =
       (if Node = 0 then 0 else Int64 (Width (Node))+
         Body_Count_Model (Parent, Weld, Width, Nv, Weld (Parent (Node))));
   function Ancestor_Count (Parent, Weld, Width : Int_Array; Nv, Node : Natural) return Int64 with
     Global => null,
     Pre => Body_Links (Parent, Weld, Width, Nv) and then Node < Parent'Length,
     Post => (Static => Ancestor_Count'Result = Body_Count_Model (Parent, Weld, Width, Nv, Node));

   function Dof_Links (Parent : Int_Array) return Boolean is
     (Shape (Parent) and then Parent'Length <= Max_Size
      and then (for all D in Parent'Range => Parent (D) in -1 .. D-1));
   function Dof_Count_Model (Parent : Int_Array; Dof : Integer) return Natural is
     (if Dof < 0 then 0 else 1+Dof_Count_Model (Parent, Parent (Dof))) with
     Ghost => Static, Global => null,
     Pre => Dof_Links (Parent) and then Dof in -1 .. Parent'Length-1,
     Post => Dof_Count_Model'Result <= Dof+1,
     Subprogram_Variant => (Decreases => Dof);
   procedure Unfold_Dof_Count (Parent : Int_Array; Dof : Integer) with
     Ghost => Static, Global => null,
     Pre => Dof_Links (Parent) and then Dof in -1 .. Parent'Length-1,
     Post => Dof_Count_Model (Parent, Dof) =
       (if Dof < 0 then 0 else 1+Dof_Count_Model (Parent, Parent (Dof)));
   function Dof_Count (Parent : Int_Array; Dof : Integer) return Natural with
     Global => null, Pre => Dof_Links (Parent) and then Dof in -1 .. Parent'Length-1,
     Post => (Static => Dof_Count'Result = Dof_Count_Model (Parent, Dof));
   function Row_Length (Address : Int_Array; Nm : Natural; Dof : Natural) return Integer is
     ((if Dof = Address'Length-1 then Nm else Address (Dof+1))-Address (Dof)) with
     Pre => Shape (Address) and then Address'Length <= Max_Size and then Nm <= Max_Size
       and then Dof < Address'Length and then (for all A of Address => A in 0 .. Nm);
   function Mass_Links (Parent, Address : Int_Array; Nm : Natural) return Boolean is
     (Dof_Links (Parent) and then Shape (Address) and then Address'Length = Parent'Length and then Nm <= Max_Size
      and then (for all A of Address => A in 0 .. Nm)
      and then (if Address'Length = 0 then Nm = 0 else Address (0) = 0)
      and then (for all D in Address'Range => Row_Length (Address, Nm, D) >= 1
        and then Row_Length (Address, Nm, D) =
          (if Parent (D) = -1 then 1 else Row_Length (Address, Nm, Parent (D))+1)));
   procedure Mass_Ancestor_Equal (Parent, Address : Int_Array; Nm, Dof : Natural) with
     Ghost => Static, Global => null,
     Pre => Mass_Links (Parent, Address, Nm) and then Dof < Parent'Length,
     Post => Row_Length (Address, Nm, Dof) = Dof_Count_Model (Parent, Dof),
     Subprogram_Variant => (Decreases => Dof);
   function Diagonal_Valid (Columns : Int_Array; Address, Width, Position, Dof, Count : Integer) return Boolean is
     (Count >= 1 and then Position = Count-1 and then Span (Columns, Address, Width)
      and then Position in 0 .. Width-1 and then Columns (Address+Position) = Dof)
     with Pre => Shape (Columns);
   function Rows_Equal (Left : Int_Array; Left_Address, Left_Width : Integer;
                        Right : Int_Array; Right_Address, Right_Width : Integer) return Boolean with
     Global => null,
     Pre => Shape (Left) and then Shape (Right) and then Span (Left, Left_Address, Left_Width)
       and then Span (Right, Right_Address, Right_Width),
     Post => Rows_Equal'Result = (Left_Width = Right_Width and then
       (for all K in 0 .. Left_Width-1 => Left (Left_Address+K) = Right (Right_Address+K)));
end MJ.Model_Structures;

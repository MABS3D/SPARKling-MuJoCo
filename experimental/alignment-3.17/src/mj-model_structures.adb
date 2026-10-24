package body MJ.Model_Structures with SPARK_Mode is
   function Check_Row (Values : Int_Array; Address, Width : Integer;
                       Ncols : Natural; Strict : Boolean := True) return CSR_Code is
   begin
      if not Width_OK (Width, Ncols, Strict) then return Width_Error; end if;
      if not Span (Values, Address, Width) then return Address_Error; end if;
      for K in 0 .. Width-1 loop
         if not Column_OK (Values, Address, Width, Ncols, Strict, K) then return Column_Error; end if;
         pragma Loop_Invariant (for all J in 0 .. K => Column_OK (Values, Address, Width, Ncols, Strict, J));
      end loop;
      return Valid;
   end Check_Row;
   function Check_CSR (Widths, Addresses, Columns : Int_Array;
                       Nrows, Ncols, Nnz : Natural; Strict : Boolean := True) return CSR_Result is
      Code : CSR_Code;
   begin
      if not Matrix_Shape (Widths, Addresses, Columns, Nrows, Nnz) then return (Shape_Error, -1); end if;
      for R in 0 .. Nrows-1 loop
         Code := Check_Row (Columns, Addresses (R), Widths (R), Ncols, Strict);
         if Code /= Valid then return (Code, R); end if;
         pragma Loop_Invariant (for all I in 0 .. R => Row_Valid (Columns, Addresses (I), Widths (I), Ncols, Strict));
      end loop;
      return (Valid, -1);
   end Check_CSR;
   procedure Row_Entry (Columns : Int_Array; Address, Width : Integer; Ncols, Position : Natural) is
   begin null; end Row_Entry;
   procedure Ordered_Positions (Columns : Int_Array; Address, Width : Integer;
                                Ncols, First, Last : Natural) is
   begin
      if First < Last then
         if First+1 < Last then Ordered_Positions (Columns, Address, Width, Ncols, First, Last-1); end if;
         Row_Entry (Columns, Address, Width, Ncols, Last);
      end if;
   end Ordered_Positions;
   procedure Reject_Column (Columns : Int_Array; Address, Width : Integer;
                            Ncols, Cursor : Natural; Value : Integer) is
   begin
      for K in Cursor .. Width-1 loop
         Ordered_Positions (Columns, Address, Width, Ncols, Cursor, K);
         pragma Loop_Invariant (for all J in Cursor .. K => Columns (Address+J) /= Value);
      end loop;
   end Reject_Column;
   procedure Find_Column (Columns : Int_Array; Address, Width : Integer; Ncols : Natural;
                          Value : Integer; Cursor : in out Natural; Found : out Boolean) is
      Initial : constant Natural := Cursor with Ghost => Static;
   begin
      while Cursor < Width and then Columns (Address+Cursor) < Value loop
         Cursor := Cursor+1;
         pragma Loop_Invariant (Static => Cursor in Initial .. Width);
         pragma Loop_Invariant (for all K in 0 .. Cursor-1 => Columns (Address+K) < Value);
         pragma Loop_Variant (Increases => Cursor);
      end loop;
      Found := Cursor < Width and then Columns (Address+Cursor) = Value;
      if not Found then Reject_Column (Columns, Address, Width, Ncols, Cursor, Value); end if;
   end Find_Column;
   function Sorted_Subset (Columns : Int_Array; Child_Address, Child_Width, Parent_Address, Parent_Width : Integer;
                           Ncols : Natural) return Boolean is
      Cursor : Natural := 0;
      Found : Boolean;
      Last_Value : Integer := Integer'First with Ghost => Static;
   begin
      for K in 0 .. Child_Width-1 loop
         Row_Entry (Columns, Child_Address, Child_Width, Ncols, K);
         if K > 0 then pragma Assert (Static => Last_Value < Columns (Child_Address+K)); end if;
         Find_Column (Columns, Parent_Address, Parent_Width, Ncols, Columns (Child_Address+K), Cursor, Found);
         if not Found then return False; end if;
         Last_Value := Columns (Child_Address+K);
         pragma Loop_Invariant (Cursor < Parent_Width);
         pragma Loop_Invariant (Static => (for all J in 0 .. Cursor-1 => Columns (Parent_Address+J) < Last_Value));
         pragma Loop_Invariant (Static => Last_Value = Columns (Child_Address+K));
         pragma Loop_Invariant (for all I in 0 .. K =>
           (for some J in 0 .. Parent_Width-1 => Columns (Child_Address+I) = Columns (Parent_Address+J)));
      end loop;
      return True;
   end Sorted_Subset;
   procedure Unfold_Body_Count (Parent, Weld, Width : Int_Array; Nv, Node : Natural) is
   begin null; end Unfold_Body_Count;
   function Ancestor_Count (Parent, Weld, Width : Int_Array; Nv, Node : Natural) return Int64 is
      Cursor : Natural := Node;
      Total : Int64 := 0;
   begin
      while Cursor > 0 loop
         Unfold_Body_Count (Parent, Weld, Width, Nv, Cursor);
         Total := Total+Int64 (Width (Cursor));
         Cursor := Weld (Parent (Cursor));
         pragma Loop_Invariant (Cursor <= Node);
         pragma Loop_Invariant (Total in 0 .. Int64 (Node)*Int64 (Nv));
         pragma Loop_Invariant (Static => Total+Body_Count_Model (Parent, Weld, Width, Nv, Cursor) =
           Body_Count_Model (Parent, Weld, Width, Nv, Node));
         pragma Loop_Variant (Decreases => Cursor);
      end loop;
      Unfold_Body_Count (Parent, Weld, Width, Nv, Cursor);
      return Total;
   end Ancestor_Count;
   procedure Unfold_Dof_Count (Parent : Int_Array; Dof : Integer) is
   begin null; end Unfold_Dof_Count;
   function Dof_Count (Parent : Int_Array; Dof : Integer) return Natural is
      Cursor : Integer := Dof;
      Count : Natural := 0;
   begin
      while Cursor >= 0 loop
         Unfold_Dof_Count (Parent, Cursor);
         Count := Count+1;
         Cursor := Parent (Cursor);
         pragma Loop_Invariant (Cursor in -1 .. Dof);
         pragma Loop_Invariant (Static => Count+Dof_Count_Model (Parent, Cursor) = Dof_Count_Model (Parent, Dof));
         pragma Loop_Variant (Decreases => Cursor);
      end loop;
      Unfold_Dof_Count (Parent, Cursor);
      return Count;
   end Dof_Count;
   procedure Mass_Ancestor_Equal (Parent, Address : Int_Array; Nm, Dof : Natural) is
   begin
      if Parent (Dof) >= 0 then Mass_Ancestor_Equal (Parent, Address, Nm, Parent (Dof)); end if;
      Unfold_Dof_Count (Parent, Dof);
   end Mass_Ancestor_Equal;
   function Rows_Equal (Left : Int_Array; Left_Address, Left_Width : Integer;
                        Right : Int_Array; Right_Address, Right_Width : Integer) return Boolean is
   begin
      if Left_Width /= Right_Width then return False; end if;
      for K in 0 .. Left_Width-1 loop
         if Left (Left_Address+K) /= Right (Right_Address+K) then return False; end if;
         pragma Loop_Invariant (for all J in 0 .. K => Left (Left_Address+J) = Right (Right_Address+J));
      end loop;
      return True;
   end Rows_Equal;
end MJ.Model_Structures;

with MJ.Equality_Flex;
with MJ.Equality_Flex_Rows;
package body MJ.Data.Flex_Elasticity.Equalities with SPARK_Mode is
   use type CA.Result;
   function Edge_Chain (S : Storage; Index : Natural) return CA.Column_Array is
     ([for K in 1 .. S.Edges (Index).Rownnz =>
       S.Edge_Columns (S.Edges (Index).Rowadr+K-1)]) with
     Pre => (Static => Edge_Layout_Valid (S) and then Index in S.Edges'Range),
     Post => (Static => Edge_Chain'Result'First = 1
       and then Edge_Chain'Result'Length = S.Edges (Index).Rownnz
       and then (for all K in Edge_Chain'Result'Range =>
         Edge_Chain'Result (K) = S.Edge_Columns (S.Edges (Index).Rowadr+K-1)));
   procedure Append_Storage
     (S : Storage; Flex_Id, Eq_Id : Natural;
      Rows : in out CA.Storage; Responses : in out Response_Array;
      Result : out Status; Sparse : Boolean) with
     Pre => (Static => Edge_Layout_Valid (S) and then CA.Valid (Rows)
       and then Responses'First = 1 and then Responses'Length = Rows.Row_Cap),
     Post => (Static => CA.Valid (Rows) and then
       (if Result /= Success then Rows = Rows'Old and then Responses = Responses'Old)) is
      Needed_Rows, Needed_Entries : Natural := 0;
      function Include (C : Edge) return Boolean is
        (not C.Rigid and then C.Rownnz > 0 and then
         (Sparse or else (for some K in C.Rowadr .. C.Rowadr+C.Rownnz-1 => S.Edge_J (K) /= 0.0)));
   begin
      Result := Invalid_Size;
      if Rows.Dofs /= S.Nv or else Rows.Rows /= Rows.Ne
        or else Flex_Id >= S.Nf then return; end if;
      Result := Not_Allocated;
      if not S.Valid then return; end if;
      declare
         F : Flex renames S.Flexes (Flex_Id);
         type Budget_Array is array (Natural range <>) of Natural;
         Row_Prefix, Entry_Prefix : Budget_Array (0 .. F.Nedge) := [others => 0] with Ghost;
         Initial_Rows : constant Natural := Rows.Rows with Ghost;
         Initial_Used : constant Natural := Rows.Used with Ghost;
      begin
         --  Preflight the entire equality before writing any row. Empty and
         --  rigid edge rules match mj_addConstraint and mjEQ_FLEX; dense mode
         --  also discards numerically zero rows, as the C driver does.
         for I in F.First_Edge .. F.First_Edge+F.Nedge-1 loop
            pragma Loop_Invariant (Needed_Rows <= I-F.First_Edge);
            pragma Loop_Invariant (Needed_Entries <= (I-F.First_Edge)*Max_Dofs);
            pragma Loop_Invariant (Row_Prefix (I-F.First_Edge) = Needed_Rows);
            pragma Loop_Invariant (Entry_Prefix (I-F.First_Edge) = Needed_Entries);
            pragma Loop_Invariant (Row_Prefix (0) = 0 and then Entry_Prefix (0) = 0);
            pragma Loop_Invariant (for all K in 0 .. I-F.First_Edge =>
              Row_Prefix (K) <= Needed_Rows and then Entry_Prefix (K) <= Needed_Entries);
            pragma Loop_Invariant (for all K in 1 .. I-F.First_Edge =>
              Row_Prefix (K) = Row_Prefix (K-1)
                + (if Include (S.Edges (F.First_Edge+K-1)) then 1 else 0));
            pragma Loop_Invariant (for all K in 1 .. I-F.First_Edge =>
              Entry_Prefix (K) = Entry_Prefix (K-1)
                + (if Include (S.Edges (F.First_Edge+K-1)) then
                   S.Edges (F.First_Edge+K-1).Rownnz else 0));
            pragma Loop_Invariant (for all P in F.First_Edge .. I-1 =>
              (if Include (S.Edges (P)) then CA.Valid_Chain
                (Edge_Chain (S, P), S.Nv)));
            declare C : Edge renames S.Edges (I); begin
               if Include (C) then
                  declare
                     Chain : constant CA.Column_Array := Edge_Chain (S, I);
                  begin
                     if not CA.Valid_Chain (Chain, Rows.Dofs) then
                        Result := Invalid_Model; return;
                     end if;
                  end;
                  Needed_Rows := Needed_Rows+1;
                  Needed_Entries := Needed_Entries+C.Rownnz;
               end if;
            end;
            Row_Prefix (I-F.First_Edge+1) := Needed_Rows;
            Entry_Prefix (I-F.First_Edge+1) := Needed_Entries;
         end loop;
         Result := Capacity_Exceeded;
         if Needed_Rows > Rows.Row_Cap-Rows.Rows
           or else Needed_Entries > Rows.Entry_Cap-Rows.Used then return; end if;
         for I in F.First_Edge .. F.First_Edge+F.Nedge-1 loop
            pragma Loop_Invariant (CA.Valid (Rows));
            pragma Loop_Invariant (Rows.Dofs = S.Nv);
            pragma Loop_Invariant (Rows.Rows = Rows.Ne);
            pragma Loop_Invariant (Rows.Rows = Initial_Rows+Row_Prefix (I-F.First_Edge));
            pragma Loop_Invariant (Rows.Used = Initial_Used+Entry_Prefix (I-F.First_Edge));
            declare C : Edge renames S.Edges (I); begin
               if Include (C) then
                  declare
                     Chain : constant CA.Column_Array := Edge_Chain (S, I);
                     Values : constant CA.Value_Array :=
                       [for K in 1 .. C.Rownnz => S.Edge_J (C.Rowadr+K-1)];
                     Added : CA.Result;
                  begin
                     pragma Assert (Static => Chain'Length > 0);
                     pragma Assert (Static => Row_Prefix (I-F.First_Edge+1)
                       = Row_Prefix (I-F.First_Edge)+1);
                     pragma Assert (Static => Entry_Prefix (I-F.First_Edge+1)
                       = Entry_Prefix (I-F.First_Edge)+C.Rownnz);
                     pragma Assert (Static => Rows.Rows < Rows.Row_Cap);
                     pragma Assert (Static => C.Rownnz <= Rows.Entry_Cap-Rows.Used);
                     pragma Assert (Static => CA.Fits (Rows, 1, Chain'Length));
                     MJ.Equality_Flex_Rows.Append
                       (Rows, Eq_Id, Chain, Values, S.Length (I), C.Rest, Added);
                     --  The preflight guarantees this branch is unreachable.
                     pragma Assert (Static => Added = CA.Success);
                     Responses (Rows.Rows) :=
                       (Weight => C.Weight,
                        Position => MJ.Equality_Flex.Edge_Residual (S.Length (I), C.Rest));
                  end;
               end if;
            end;
         end loop;
      end;
      Result := Success;
   end Append_Storage;

   procedure Append_Edges
     (Model : Force_Model; Flex_Id, Eq_Id : Natural;
      Rows : in out CA.Storage; Responses : in out Response_Array;
      Result : out Status; Sparse : Boolean := True) is
   begin
      if Model.S = null then Result := Not_Allocated; return; end if;
      Append_Storage (Model.S.all, Flex_Id, Eq_Id, Rows, Responses, Result, Sparse);
   end Append_Edges;

   procedure Append_Edges
     (E : Engine; Flex_Id, Eq_Id : Natural;
      Rows : in out CA.Storage; Responses : in out Response_Array;
      Result : out Status; Sparse : Boolean := True) is
   begin
      if E.S = null then Result := Not_Allocated; return; end if;
      Append_Storage (E.S.all, Flex_Id, Eq_Id, Rows, Responses, Result, Sparse);
   end Append_Edges;
end MJ.Data.Flex_Elasticity.Equalities;

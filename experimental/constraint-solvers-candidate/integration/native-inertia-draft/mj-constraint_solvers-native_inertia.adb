package body MJ.Constraint_Solvers.Native_Inertia with SPARK_Mode is
   function Subtract_Product (Previous, Factor, Xi : Real) return Real is
     (Previous-Factor*Xi);
   function Scale_Value (Value, Inverse : Real) return Real is (Value*Inverse);
   function Reciprocal (Diagonal : Real) return Real is (1.0/Diagonal);
   function Subtract_Dot (Previous, Dot : Real) return Real is (Previous-Dot);

   procedure Store (X : in out Vector; Index : Positive; Value : Real) is
   begin
      X (Index) := Value;
   end Store;

   procedure Distinct_Prefix (L : Sparse_Jacobian; Row, Slot : Positive) is
   begin
      for T in reverse L.Offsets (Row)+1 .. Slot-1 loop
         pragma Loop_Invariant
           (for all P in T .. Slot-1 => L.Columns (P) < L.Columns (Slot));
      end loop;
   end Distinct_Prefix;

   procedure Scatter_Row (L : Sparse_Jacobian; X : in out Vector;
                          Row : Positive; Accepted : out Boolean) is
      Before : constant Vector := X with Ghost => Static;
      Xi : constant Real := X (Row);
      Value : Real;
   begin
      Accepted := True;
      if Xi = 0.0 then return; end if;
      for S in L.Offsets (Row)+1 .. L.Offsets (Row)+L.Widths (Row) loop
         Distinct_Prefix (L, Row, S);
         Value := Subtract_Product (X (L.Columns (S)), L.Values (S), Xi);
         if Value not in Operand then Accepted := False; return; end if;
         Store (X, L.Columns (S), Value);
         pragma Loop_Invariant (Bounded (X));
         pragma Loop_Invariant (Static => Xi = Before (Row));
         pragma Loop_Invariant (Static =>
           (for all T in L.Offsets (Row)+1 .. S =>
             X (L.Columns (T)) = Subtract_Product
               (Before (L.Columns (T)), L.Values (T), Xi)));
         pragma Loop_Invariant (Static =>
           (for all P in X'Range =>
             (if (for all T in L.Offsets (Row)+1 .. S => L.Columns (T) /= P)
              then X (P) = Before (P))));
      end loop;
   end Scatter_Row;

   procedure Scale_Vector (Inverse : Vector; X : in out Vector;
                           Accepted : out Boolean) is
      Value : Real;
   begin
      Accepted := True;
      for P in X'Range loop
         Value := Scale_Value (X (P), Inverse (P));
         if Value not in Operand then Accepted := False; return; end if;
         Store (X, P, Value);
         pragma Loop_Invariant (Bounded (X));
         pragma Loop_Invariant (Static =>
           (for all Q in X'First .. P => X (Q) = Scale_Value (X'Loop_Entry (Q), Inverse (Q))));
         pragma Loop_Invariant (Static =>
           (for all Q in X'Range => (if Q > P then X (Q) = X'Loop_Entry (Q))));
      end loop;
   end Scale_Vector;

   procedure Forward_Row (L : Sparse_Jacobian; X : in out Vector;
                          Row : Positive; Accepted : out Boolean) is
      Value : Real;
   begin
      Accepted := True;
      if L.Widths (Row) = 0 then return; end if;
      Value := Subtract_Dot (X (Row), Jacobians.Sparse_Row (L, X, Row));
      if Value not in Operand then Accepted := False; return; end if;
      Store (X, Row, Value);
   end Forward_Row;

   procedure Apply (L : Sparse_Jacobian; Inverse, RHS : Vector;
                    X : out Vector; Accepted : out Boolean) is
   begin
      X := RHS;
      for Row in reverse 1 .. L.Row_Count loop
         Scatter_Row (L, X, Row, Accepted);
         if not Accepted then return; end if;
         pragma Loop_Invariant (Bounded (X));
      end loop;
      Scale_Vector (Inverse, X, Accepted);
      if not Accepted then return; end if;
      for Row in 1 .. L.Row_Count loop
         Forward_Row (L, X, Row, Accepted);
         if not Accepted then return; end if;
         pragma Loop_Invariant (Bounded (X));
      end loop;
   end Apply;

   procedure Solve (L : Sparse_Jacobian; Inverse, RHS : Vector;
                    X : in out Vector; Result : out Status) is
   begin
      Result := Invalid_Input;
      if not Ready (L, RHS) or else not Inverse_Valid (Inverse, L.Row_Count)
        or else X'First /= 1 or else X'Length /= L.Row_Count then return; end if;
      declare
         Work : Vector (RHS'Range);
         Accepted : Boolean;
      begin
         Result := Numeric_Limit;
         Apply (L, Inverse, RHS, Work, Accepted);
         if not Accepted then return; end if;
         X := Work;
         Result := Success;
      end;
   end Solve;
end MJ.Constraint_Solvers.Native_Inertia;

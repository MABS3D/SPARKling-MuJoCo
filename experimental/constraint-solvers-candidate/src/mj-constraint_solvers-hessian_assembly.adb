package body MJ.Constraint_Solvers.Hessian_Assembly with SPARK_Mode is
   function Before (P : Pattern; C, R : Positive; Count : Natural) return Natural is
      Sum : Natural := 0;
   begin
      for Row in 1 .. R loop
         for K in 1 .. (if Row = R then Count else P.Width (Row)) loop
            if P.Column (P.Address (Row)+K) = C then Sum := Sum+1; end if;
            pragma Loop_Invariant (Sum <= P.Address (Row)+K);
         end loop;
         pragma Loop_Invariant (Sum <= P.Address (Row)+(if Row = R then Count else P.Width (Row)));
      end loop;
      return Sum;
   end Before;

   procedure Build_Transpose (P : in out Pattern) is
      Size : constant Positive := P.N;
      Cursor : Entry_Counts (1 .. Size);
      C : Positive;
   begin
      P.T_Width := (others => 0); P.T_Address := (others => 0);
      P.T_Row := (others => 1); P.T_Source := (others => 0);
      for R in 1 .. P.Rows loop
         for K in 1 .. P.Width (R) loop
            C := P.Column (P.Address (R)+K);
            P.T_Width (C) := P.T_Width (C)+1;
         end loop;
      end loop;
      for C in 2 .. P.N loop P.T_Address (C) := P.T_Address (C-1)+P.T_Width (C-1); end loop;
      Cursor := P.T_Address;
      for R in 1 .. P.Rows loop
         for K in 1 .. P.Width (R) loop
            C := P.Column (P.Address (R)+K);
            Cursor (C) := Cursor (C)+1;
            P.T_Row (Cursor (C)) := R;
            P.T_Source (Cursor (C)) := P.Address (R)+K;
         end loop;
      end loop;
   end Build_Transpose;

   function Trace_Step (T : Trace; Scale, Right : Real) return Trace is
      Value : Real;
   begin
      if not T.Accepted then return T; end if;
      Value := Cone.Gram_Scaled (T.Value, Scale, Right);
      return (Value, Value in Flat.Operand);
   end Trace_Step;

   function Term_Value (P : Pattern; Values : Vector; Initial : Trace;
                        R, Q : Positive; Scale : Real; Count : Natural) return Trace is
      Result : Trace := Initial;
   begin
      for K in 1 .. Count loop
         if P.Column (P.Address (R)+K) = Q then
            Result := Trace_Step (Result, Scale, Values (P.Address (R)+K));
         end if;
         pragma Loop_Invariant (Trace_Valid (Result));
      end loop;
      return Result;
   end Term_Value;

   function Row_Value (P : Pattern; Values, Weight : Vector;
                       R, Q : Positive; Count : Natural) return Trace is
      Result : Trace := (0.0, True);
      Source : Positive;
      Scale : Real;
   begin
      for K in 1 .. Count loop
         Source := P.T_Row (P.T_Address (R)+K);
         Scale := Cone.Gram_Scale (Values (P.T_Source (P.T_Address (R)+K)), Weight (Source));
         if Scale /= 0.0 then
            Result := Term_Value (P, Values, Result, Source, Q, Scale, P.Width (Source));
         end if;
         pragma Loop_Invariant (Trace_Valid (Result));
      end loop;
      return Result;
   end Row_Value;

   procedure Selection_Frame (F : Flat.Flat_Pattern; R, K : Positive) with
        Ghost => Static, Global => null,
        Pre => Flat.Valid_Flat (F) and then R <= F.N and then K <= F.Length (R),
        Post => (for all C in 1 .. F.N =>
          (if not Flat.Row_Selected (F, R, C, K) then
             not Flat.Row_Selected (F, R, C, K-1) and then F.Column (F.Address (R)+K) /= C))
      is
      begin
         for C in 1 .. F.N loop
            Flat.Selected_Step (F, R, C, K);
            pragma Loop_Invariant (for all J in 1 .. C =>
              (if not Flat.Row_Selected (F, R, J, K) then
                 not Flat.Row_Selected (F, R, J, K-1) and then F.Column (F.Address (R)+K) /= J));
         end loop;
      end Selection_Frame;

   procedure Scatter_Row (Scratch : in out Vector; F : Flat.Flat_Pattern;
                          R : Positive; H : in out Vector) is
      Before : constant Vector := Scratch with Ghost => Static;
      Original : constant Vector := H with Ghost => Static;
   begin
      for K in 1 .. F.Length (R) loop
         Flat.Flat_Column_Separate (F, R, K);
         Selection_Frame (F, R, K);
         H (F.Address (R)+K) := Scratch (F.Column (F.Address (R)+K));
         Scratch (F.Column (F.Address (R)+K)) := 0.0;
         pragma Loop_Invariant (Static => Flat.Valid_Flat (F));
         pragma Loop_Invariant (Static => Flat.Bounded (H) and then Flat.Bounded (Scratch));
         pragma Loop_Invariant (Static => (for all I in 1 .. K =>
           H (F.Address (R)+I) = Before (F.Column (F.Address (R)+I))
           and then Scratch (F.Column (F.Address (R)+I)) = 0.0));
         pragma Loop_Invariant (Static => (for all S in H'Range =>
           (if S <= F.Address (R) or else S > F.Address (R)+K then H (S) = Original (S))));
         pragma Loop_Invariant (Static => (for all C in Scratch'Range =>
           (if not Flat.Row_Selected (F, R, C, K) then Scratch (C) = Before (C))));
      end loop;
   end Scatter_Row;

   procedure Build_Gram (P : Pattern; Values, Weight : Vector; F : Flat.Flat_Pattern;
                         H : out Vector; Accepted : out Boolean) is
      Scratch : Vector (1 .. P.N) := (others => 0.0);
      Source, Q : Positive;
      Scale : Real;
   begin
      H := (others => 0.0); Accepted := False;
      for R in 1 .. P.N loop
         for T in P.T_Address (R)+1 .. P.T_Address (R)+P.T_Width (R) loop
            Source := P.T_Row (T);
            Scale := Cone.Gram_Scale (Values (P.T_Source (T)), Weight (Source));
            if Scale /= 0.0 then
               for S in P.Address (Source)+1 .. P.Address (Source)+P.Width (Source) loop
                  Q := P.Column (S);
                  exit when Q > R;
                  Cone.Gram_Element_Flat (Scratch, Q, Scale, Values (S), Accepted);
                  if not Accepted then return; end if;
                  pragma Loop_Invariant (Static => Flat.Bounded (Scratch));
               end loop;
            end if;
            pragma Loop_Invariant (Static => Flat.Bounded (Scratch));
         end loop;
         Scatter_Row (Scratch, F, R, H);
         pragma Loop_Invariant (Static => Flat.Bounded (H) and then Flat.Bounded (Scratch));
      end loop;
      Accepted := True;
   end Build_Gram;
end MJ.Constraint_Solvers.Hessian_Assembly;

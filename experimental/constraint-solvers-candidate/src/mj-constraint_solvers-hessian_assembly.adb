package body MJ.Constraint_Solvers.Hessian_Assembly with SPARK_Mode is
   function Slot_Prefixes (Columns : Column_Indices; Low, High : Natural)
     return Entry_Counts is
      Prefixes : Entry_Counts (1 .. Columns'Length+1) := (others => 0);
      S : Positive := 1;
   begin
      while S < Prefixes'Last loop
         Prefixes (S+1) := Prefixes (S)+(if Columns (S) in Low .. High then 1 else 0);
         pragma Loop_Invariant (S < Prefixes'Last);
         pragma Loop_Invariant (Prefixes (1) = 0);
         pragma Loop_Invariant (for all K in Prefixes'Range => Prefixes (K) <= K-1);
         pragma Loop_Invariant (for all K in 1 .. S => Prefixes (K+1) =
           Prefixes (K)+(if Columns (K) in Low .. High then 1 else 0));
         pragma Loop_Variant (Increases => S);
         S := S+1;
      end loop;
      return Prefixes;
   end Slot_Prefixes;

   procedure Slot_Count_Step (Columns : Column_Indices; Low, High, Count : Natural) with
     Ghost => Static, Global => null,
     Pre => Columns'First = 1 and then Columns'Length <= Max_Jacobian_Entries
       and then Count <= Columns'Length,
     Post => (if Count = 0 then Slot_Count (Columns, Low, High, Count) = 0 else
       Slot_Count (Columns, Low, High, Count) = Slot_Count (Columns, Low, High, Count-1)
         + (if Columns (Count) in Low .. High then 1 else 0))
   is
   begin
      null;
   end Slot_Count_Step;

   procedure Slot_Count_Columns_Step
     (Columns : Column_Indices; N : Positive; Count : Natural) with
     Ghost => Static, Global => null,
     Pre => Columns'First = 1 and then Columns'Length <= Max_Jacobian_Entries
       and then Count <= Columns'Length,
     Post => (for all C in 1 .. N =>
       (if Count = 0 then Slot_Count (Columns, C, C, Count) = 0 else
         Slot_Count (Columns, C, C, Count) = Slot_Count (Columns, C, C, Count-1)
           +(if Columns (Count) = C then 1 else 0)))
   is
   begin
      for C in 1 .. N loop
         Slot_Count_Step (Columns, C, C, Count);
         pragma Loop_Invariant (for all Q in 1 .. C =>
           (if Count = 0 then Slot_Count (Columns, Q, Q, Count) = 0 else
             Slot_Count (Columns, Q, Q, Count) = Slot_Count (Columns, Q, Q, Count-1)
               +(if Columns (Count) = Q then 1 else 0)));
      end loop;
   end Slot_Count_Columns_Step;

   procedure Slot_Count_Split (Columns : Column_Indices; C : Positive; Count : Natural) with
     Ghost => Static, Global => null,
     Pre => Columns'First = 1 and then Columns'Length <= Max_Jacobian_Entries
       and then Count <= Columns'Length,
     Post => Slot_Count (Columns, 1, C, Count) =
       Slot_Count (Columns, 1, C-1, Count)+Slot_Count (Columns, C, C, Count)
   is
   begin
      Slot_Count_Step (Columns, 1, C, 0);
      Slot_Count_Step (Columns, 1, C-1, 0);
      Slot_Count_Step (Columns, C, C, 0);
      for S in 1 .. Count loop
         Slot_Count_Step (Columns, 1, C, S);
         Slot_Count_Step (Columns, 1, C-1, S);
         Slot_Count_Step (Columns, C, C, S);
         pragma Loop_Invariant (Slot_Count (Columns, 1, C, S) =
           Slot_Count (Columns, 1, C-1, S)+Slot_Count (Columns, C, C, S));
      end loop;
   end Slot_Count_Split;

   procedure Slot_Count_Bounds (Columns : Column_Indices; N : Positive; Count : Natural) with
     Ghost => Static, Global => null,
     Pre => Columns'First = 1 and then Columns'Length <= Max_Jacobian_Entries
       and then Count <= Columns'Length and then (for all C of Columns => C <= N),
     Post => Slot_Count (Columns, 1, 0, Count) = 0
       and then Slot_Count (Columns, 1, N, Count) = Count
   is
   begin
      Slot_Count_Step (Columns, 1, 0, 0);
      Slot_Count_Step (Columns, 1, N, 0);
      for S in 1 .. Count loop
         Slot_Count_Step (Columns, 1, 0, S);
         Slot_Count_Step (Columns, 1, N, S);
         pragma Loop_Invariant (Slot_Count (Columns, 1, 0, S) = 0
           and then Slot_Count (Columns, 1, N, S) = S);
      end loop;
   end Slot_Count_Bounds;

   procedure Slot_Count_Monotone
     (Columns : Column_Indices; Low, High, First, Last : Natural) with
     Ghost => Static, Global => null,
     Pre => Columns'First = 1 and then Columns'Length <= Max_Jacobian_Entries
       and then First <= Last and then Last <= Columns'Length,
     Post => Slot_Count (Columns, Low, High, First) <= Slot_Count (Columns, Low, High, Last)
   is
   begin
      for S in First+1 .. Last loop
         Slot_Count_Step (Columns, Low, High, S);
         pragma Loop_Invariant (Slot_Count (Columns, Low, High, First) <=
           Slot_Count (Columns, Low, High, S));
      end loop;
   end Slot_Count_Monotone;

   function Before (P : Pattern; C, R : Positive; Count : Natural) return Natural is
   begin
      return Slot_Count (P.Column, C, C, P.Address (R)+Count);
   end Before;

   function Widths_Match (P : Pattern) return Boolean is
     (CSR_Valid (P) and then (for all C in 1 .. P.N =>
       P.T_Width (C) = Slot_Count (P.Column, C, C, P.Stored)))
     with Ghost => Static, Global => null;

   function Offsets_Match (P : Pattern) return Boolean is
     (Widths_Match (P) and then P.T_Address (1) = 0
       and then (for all C in 1 .. P.N =>
         P.T_Address (C) = Slot_Count (P.Column, 1, C-1, P.Stored)
         and then P.T_Address (C) <= P.Stored
         and then P.T_Width (C) <= P.Stored-P.T_Address (C))
       and then (for all C in 2 .. P.N =>
         P.T_Address (C) = P.T_Address (C-1)+P.T_Width (C-1))
       and then P.T_Address (P.N)+P.T_Width (P.N) = P.Stored)
     with Ghost => Static, Global => null;

   procedure Count_Transpose (P : in out Pattern) with Global => null, Inline_Always,
     Pre => (Static => CSR_Valid (P)),
     Post => (Static => Widths_Match (P)
       and then P.Width = P.Width'Old and then P.Address = P.Address'Old and then P.Column = P.Column'Old
       and then P.T_Address = P.T_Address'Old
       and then P.T_Row = P.T_Row'Old and then P.T_Source = P.T_Source'Old)
   is
      C : Positive;
   begin
      P.T_Width := (others => 0);
      Slot_Count_Columns_Step (P.Column, P.N, 0);
      for R in 1 .. P.Rows loop
         for K in 1 .. P.Width (R) loop
            Slot_Count_Columns_Step (P.Column, P.N, P.Address (R)+K);
            C := P.Column (P.Address (R)+K);
            P.T_Width (C) := P.T_Width (C)+1;
            pragma Loop_Invariant (Static => (for all Q in 1 .. P.N =>
              P.T_Width (Q) = Slot_Count (P.Column, Q, Q, P.Address (R)+K)));
         end loop;
         pragma Loop_Invariant (Static => (for all Q in 1 .. P.N =>
           P.T_Width (Q) = Slot_Count (P.Column, Q, Q, P.Address (R)+P.Width (R))));
      end loop;
   end Count_Transpose;

   procedure Offset_Transpose (P : in out Pattern) with Global => null, Inline_Always,
     Pre => (Static => Widths_Match (P) and then P.T_Address (1) = 0),
     Post => (Static => Offsets_Match (P)
       and then P.Width = P.Width'Old and then P.Address = P.Address'Old and then P.Column = P.Column'Old
       and then P.T_Width = P.T_Width'Old
       and then P.T_Row = P.T_Row'Old and then P.T_Source = P.T_Source'Old)
   is
   begin
      Slot_Count_Bounds (P.Column, P.N, P.Stored);
      for C in 2 .. P.N loop
         Slot_Count_Split (P.Column, C-1, P.Stored);
         P.T_Address (C) := P.T_Address (C-1)+P.T_Width (C-1);
         pragma Loop_Invariant (Static => (for all Q in 1 .. C =>
           P.T_Address (Q) = Slot_Count (P.Column, 1, Q-1, P.Stored)));
         pragma Loop_Invariant (Static => (for all Q in 2 .. C =>
           P.T_Address (Q) = P.T_Address (Q-1)+P.T_Width (Q-1)));
      end loop;
      for C in 1 .. P.N loop
         Slot_Count_Split (P.Column, C, P.Stored);
         pragma Loop_Invariant (Static => (for all Q in 1 .. C =>
           P.T_Address (Q)+P.T_Width (Q) = Slot_Count (P.Column, 1, Q, P.Stored)));
      end loop;
   end Offset_Transpose;

   procedure Offset_Ordered (P : Pattern; First, Last : Positive) with
     Ghost => Static, Global => null,
     Pre => Offsets_Match (P) and then First <= Last and then Last <= P.N,
     Post => P.T_Address (First) <= P.T_Address (Last)
       and then (if First < Last then P.T_Address (First)+P.T_Width (First) <= P.T_Address (Last))
   is
   begin
      for C in First+1 .. Last loop
         pragma Loop_Invariant (P.T_Address (First)+P.T_Width (First) <= P.T_Address (C));
      end loop;
   end Offset_Ordered;

   procedure Cursor_Separation (P : Pattern; Cursor : Entry_Counts; C : Positive) with
     Ghost => Static, Global => null,
     Pre => Offsets_Match (P) and then Cursor'First = 1 and then Cursor'Length = P.N
       and then C <= P.N
       and then (for all Q in 1 .. P.N => Cursor (Q) in P.T_Address (Q) .. P.T_Address (Q)+P.T_Width (Q))
       and then Cursor (C) < P.T_Address (C)+P.T_Width (C),
     Post => Cursor (C)+1 in P.T_Row'Range
       and then (for all Q in 1 .. P.N => (if Q /= C then
         Cursor (C)+1 <= P.T_Address (Q) or else Cursor (C)+1 > Cursor (Q)))
   is
   begin
      for Q in 1 .. P.N loop
         if Q < C then Offset_Ordered (P, Q, C);
         elsif C < Q then Offset_Ordered (P, C, Q); end if;
         pragma Loop_Invariant (for all J in 1 .. Q => (if J /= C then
           Cursor (C)+1 <= P.T_Address (J) or else Cursor (C)+1 > Cursor (J)));
      end loop;
   end Cursor_Separation;

   procedure Build_Transpose (P : in out Pattern) is
      Size : constant Positive := P.N;
      Cursor : Entry_Counts (1 .. Size);
      C : Positive;
   begin
      P.T_Address := (others => 0);
      P.T_Row := (others => 1); P.T_Source := (others => 0);
      Count_Transpose (P);
      Offset_Transpose (P);
      Cursor := P.T_Address;
      Slot_Count_Columns_Step (P.Column, P.N, 0);
      for R in 1 .. P.Rows loop
         for K in 1 .. P.Width (R) loop
            C := P.Column (P.Address (R)+K);
            Slot_Count_Columns_Step (P.Column, P.N, P.Address (R)+K);
            Slot_Count_Monotone (P.Column, C, C, P.Address (R)+K, P.Stored);
            Cursor_Separation (P, Cursor, C);
            Cursor (C) := Cursor (C)+1;
            P.T_Row (Cursor (C)) := R;
            P.T_Source (Cursor (C)) := P.Address (R)+K;
            pragma Loop_Invariant (Static => Offsets_Match (P));
            pragma Loop_Invariant (Static => (for all Q in 1 .. P.N =>
              Cursor (Q) = P.T_Address (Q)+Slot_Count (P.Column, Q, Q, P.Address (R)+K)
                and then Cursor (Q) in P.T_Address (Q) .. P.T_Address (Q)+P.T_Width (Q)));
            pragma Loop_Invariant (Static => (for all Q in 1 .. P.N =>
              (for all S in P.T_Address (Q)+1 .. Cursor (Q) =>
                P.T_Row (S) <= P.Rows
                and then P.T_Source (S) in P.Address (P.T_Row (S))+1 ..
                  P.Address (P.T_Row (S))+P.Width (P.T_Row (S))
                and then P.Column (P.T_Source (S)) = Q)));
            pragma Loop_Invariant (Static => (for all RR in 1 .. R =>
              (for all KK in 1 .. (if RR = R then K else P.Width (RR)) =>
                P.T_Address (P.Column (P.Address (RR)+KK))+
                  Before (P, P.Column (P.Address (RR)+KK), RR, KK-1)+1
                    in P.T_Address (P.Column (P.Address (RR)+KK))+1 .. Cursor (P.Column (P.Address (RR)+KK))
                and then P.T_Row (P.T_Address (P.Column (P.Address (RR)+KK))+
                  Before (P, P.Column (P.Address (RR)+KK), RR, KK-1)+1) = RR
                and then P.T_Source (P.T_Address (P.Column (P.Address (RR)+KK))+
                  Before (P, P.Column (P.Address (RR)+KK), RR, KK-1)+1) = P.Address (RR)+KK)));
         end loop;
         pragma Loop_Invariant (Static => Offsets_Match (P));
         pragma Loop_Invariant (Static => (for all Q in 1 .. P.N =>
           Cursor (Q) = P.T_Address (Q)+Slot_Count (P.Column, Q, Q, P.Address (R)+P.Width (R))
             and then Cursor (Q) in P.T_Address (Q) .. P.T_Address (Q)+P.T_Width (Q)));
         pragma Loop_Invariant (Static => (for all Q in 1 .. P.N =>
           (for all S in P.T_Address (Q)+1 .. Cursor (Q) =>
             P.T_Row (S) <= P.Rows
             and then P.T_Source (S) in P.Address (P.T_Row (S))+1 ..
               P.Address (P.T_Row (S))+P.Width (P.T_Row (S))
             and then P.Column (P.T_Source (S)) = Q)));
         pragma Loop_Invariant (Static => (for all RR in 1 .. R =>
           (for all KK in 1 .. P.Width (RR) =>
             P.T_Address (P.Column (P.Address (RR)+KK))+
               Before (P, P.Column (P.Address (RR)+KK), RR, KK-1)+1
                 in P.T_Address (P.Column (P.Address (RR)+KK))+1 .. Cursor (P.Column (P.Address (RR)+KK))
             and then P.T_Row (P.T_Address (P.Column (P.Address (RR)+KK))+
               Before (P, P.Column (P.Address (RR)+KK), RR, KK-1)+1) = RR
             and then P.T_Source (P.T_Address (P.Column (P.Address (RR)+KK))+
               Before (P, P.Column (P.Address (RR)+KK), RR, KK-1)+1) = P.Address (RR)+KK)));
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
         declare
            Slot : constant Positive := F.Address (R)+K;
            Column : constant Positive := F.Column (Slot);
         begin
            --  Retain the source index across the output write, as in C's
            --  scatter loop. This also avoids reloading the pattern through
            --  a potentially aliased record after updating H.
            H (Slot) := Scratch (Column);
            Scratch (Column) := 0.0;
         end;
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

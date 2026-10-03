package body MJ.Native_Mass_Adapter with SPARK_Mode is
   procedure Copy_Row
     (Rows : AR.Pattern; Row : Natural; Factor : Real_Array;
      Columns : out CS.Column_Indices; Values : out CS.Vector; Inverse : out Real) is
   begin
      AR.Row_Properties (Rows, Row);
      Inverse := NI.Reciprocal (Factor (AR.Start (Rows, Row)+AR.Length (Rows, Row)-1));
      for S in Columns'Range loop
         Columns (S) := AR.Column (Rows, Row, S-Columns'First)+1;
         Values (S) := Factor (S-1);
         pragma Loop_Invariant (Columns (Columns'First .. S)'Initialized);
         pragma Loop_Invariant (Values (Values'First .. S)'Initialized);
         pragma Loop_Invariant (Static =>
           (for all T in Columns'First .. S =>
             Columns (T) = AR.Column (Rows, Row, T-Columns'First)+1
             and then Values (T) = Factor (T-1)
             and then (if T = Columns'Last then Columns (T) = Row+1 else Columns (T) < Row+1)
             and then (if T > Columns'First then Columns (T-1) < Columns (T))));
      end loop;
   end Copy_Row;

   procedure Mapping_Row (Rows : AR.Pattern; Native : CS.Sparse_Jacobian; Row : Positive) is
   begin
      pragma Assert (Native.Offsets (Row) = AR.Start (Rows, Row-1));
      pragma Assert (Native.Widths (Row) = AR.Length (Rows, Row-1)-1);
   end Mapping_Row;

   procedure Finish_Lower (Rows : AR.Pattern; Native : CS.Sparse_Jacobian) is
      Filled : Natural := 0;
   begin
      for R in 1 .. Native.Row_Count loop
         Mapping_Row (Rows, Native, R);
         AR.Row_Properties (Rows, R-1);
         declare
            First : constant Natural := AR.Start (Rows, R-1);
            Last : constant Natural := First+AR.Length (Rows, R-1);
         begin
            pragma Assert (First = Filled);
            pragma Assert (for all K in 0 .. AR.Length (Rows, R-1)-1 =>
              Native.Columns (First+K+1) = AR.Column (Rows, R-1, K)+1);
            for K in 0 .. AR.Length (Rows, R-1)-1 loop
               declare
                  S : constant Positive := First+K+1;
               begin
               pragma Assert (Native.Columns (First+K+1) = AR.Column (Rows, R-1, K)+1);
               pragma Assert (Native.Columns (S) in 1 .. Native.Row_Count);
               if S < Last then
                  pragma Assert (Native.Columns (S) < R);
                  if S > First+1 then
                     pragma Assert (Native.Columns (First+(K-1)+1) = AR.Column (Rows, R-1, K-1)+1);
                     pragma Assert (Native.Columns (S-1) < Native.Columns (S));
                  end if;
               end if;
               end;
               pragma Loop_Invariant (for all T in 1 .. First+K+1 => Native.Columns (T) in 1 .. Native.Row_Count);
               pragma Loop_Invariant (for all T in First+1 .. Natural'Min (First+K+1, Last-1) =>
                 Native.Columns (T) < R and then (if T > First+1 then Native.Columns (T-1) < Native.Columns (T)));
            end loop;
            Filled := Last;
         end;
         pragma Loop_Invariant (Filled = AR.Start (Rows, R-1)+AR.Length (Rows, R-1));
         pragma Loop_Invariant (for all T in 1 .. Filled => Native.Columns (T) in 1 .. Native.Row_Count);
         pragma Loop_Invariant (for all P in 1 .. R =>
           (for all S in Native.Offsets (P)+1 .. Native.Offsets (P)+Native.Widths (P) =>
             Native.Columns (S) < P and then (if S > Native.Offsets (P)+1 then Native.Columns (S-1) < Native.Columns (S))));
      end loop;
   end Finish_Lower;

   procedure Pack
     (Rows : AR.Pattern; Factor : Real_Array;
      Native : out CS.Sparse_Jacobian; Inverse : out CS.Vector; Accepted : out Boolean) is
      Filled : Natural := 0;
   begin
      Accepted := False;
      for V in 1 .. AR.Size (Rows) loop
         AR.Row_Properties (Rows, V-1);
         declare
            First : constant Natural := AR.Start (Rows, V-1);
            Width : constant Positive := AR.Length (Rows, V-1);
         begin
            pragma Assert (Static => First = Filled);
            if Factor (First+Width-1) not in 1.0e-15 .. 1.0e60 then return; end if;
            Native.Offsets (V) := First;
            Native.Widths (V) := Width-1;
            Copy_Row (Rows, V-1, Factor,
              Native.Columns (First+1 .. First+Width),
              Native.Values (First+1 .. First+Width), Inverse (V));
            Filled := First+Width;
         end;
         pragma Loop_Invariant (Static => Filled = AR.Start (Rows, V-1)+AR.Length (Rows, V-1));
         pragma Loop_Invariant (Native.Offsets (1 .. V)'Initialized);
         pragma Loop_Invariant (Native.Widths (1 .. V)'Initialized);
         pragma Loop_Invariant (Native.Columns (1 .. Filled)'Initialized);
         pragma Loop_Invariant (Native.Values (1 .. Filled)'Initialized);
         pragma Loop_Invariant (Static => (for all R in 1 .. V =>
           Inverse (R)'Initialized and then Inverse (R) in 1.0e-61 .. 1.0e16));
         pragma Loop_Invariant (Static => (for all R in 1 .. V =>
           AR.Start (Rows, R-1)+AR.Length (Rows, R-1) <= Filled));
         pragma Loop_Invariant (Static => (for all S in 1 .. Filled =>
           Native.Values (S) = Factor (S-1) and then Native.Values (S) in NI.Operand
           and then Native.Columns (S) in 1 .. AR.Size (Rows)));
         pragma Loop_Invariant (Static => (for all R in 1 .. V =>
           Factor (AR.Start (Rows, R-1)+AR.Length (Rows, R-1)-1) in 1.0e-15 .. 1.0e60));
         pragma Loop_Invariant (Static => (for all R in 1 .. V =>
           Native.Offsets (R) = AR.Start (Rows, R-1)));
         pragma Loop_Invariant (Static => (for all R in 1 .. V =>
           Native.Widths (R) = AR.Length (Rows, R-1)-1));
         pragma Loop_Invariant (Static => (for all R in 1 .. V =>
           Inverse (R)'Initialized and then Inverse (R) =
             NI.Reciprocal (Factor (AR.Start (Rows, R-1)+AR.Length (Rows, R-1)-1))));
         pragma Loop_Invariant (Static => (for all R in 1 .. V =>
           AR.Start (Rows, R-1)+AR.Length (Rows, R-1) <= Filled
           and then (for all K in 0 .. AR.Length (Rows, R-1)-1 =>
             Native.Columns (AR.Start (Rows, R-1)+K+1)'Initialized
             and then Native.Columns (AR.Start (Rows, R-1)+K+1) = AR.Column (Rows, R-1, K)+1)));
      end loop;
      pragma Assert (Native'Initialized);
      pragma Assert (Static => (for all R in 1 .. Native.Row_Count =>
        Native.Offsets (R) = AR.Start (Rows, R-1)
        and then Native.Widths (R) = AR.Length (Rows, R-1)-1
        and then (for all K in 0 .. AR.Length (Rows, R-1)-1 =>
          Native.Columns (AR.Start (Rows, R-1)+K+1) = AR.Column (Rows, R-1, K)+1)));
      Finish_Lower (Rows, Native);
      Accepted := True;
   end Pack;
end MJ.Native_Mass_Adapter;

package body MJ.Cholesky_Sparse with SPARK_Mode is
   function Transpose_Valid (N : Size; Count, Adr, Col, TCount, TAdr,
                             TCol, Map : Indices) return Boolean is
      Total, TTotal : Natural := 0; C, P : Offset;
   begin
      if not CSR_Valid (N, Count, Adr, Col, Col'Length, True)
        or else TCount'First /= 0 or else TCount'Length /= N
        or else TAdr'First /= 0 or else TAdr'Length /= N
        or else TCol'First /= 0 or else Map'First /= 0 or else Map'Length /= TCol'Length
      then return False; end if;
      for R in 0 .. Integer (N) - 1 loop
         pragma Loop_Invariant (Total <= R * N and then TTotal <= R * N);
         if TCount (R) = 0 or else TCount (R) > N or else TAdr (R) > TCol'Length
           or else TCount (R) > TCol'Length - TAdr (R)
           or else (R < N - 1 and then TAdr (R + 1) < TAdr (R) + TCount (R))
           or else TCol (TAdr (R)) /= R
         then return False; end if;
         Total := Total + Count (R); TTotal := TTotal + TCount (R);
         for K in 0 .. Integer (TCount (R)) - 1 loop
            C := TCol (TAdr (R) + K); P := Map (TAdr (R) + K);
            if C >= N or else C < R or else (K > 0 and then C = R)
              or else P < Adr (C) or else P >= Adr (C) + Count (C) or else Col (P) /= R
            then return False; end if;
            for J in 0 .. K - 1 loop
               if TCol (TAdr (R) + J) = C then return False; end if;
            end loop;
         end loop;
      end loop;
      return Total = TTotal;
   end Transpose_Valid;

   procedure Symbolic_Count (N : Size; HCount, HAdr, HCol : Indices;
                             Count, Adr, TCount, TAdr : out Indices;
                             NNZ : out Offset) is
      type Integers is array (Natural range <>) of Integer;
      Parent, Flag : Integers (0 .. Integer (N) - 1) := (others => -1);
      I : Natural;
   begin
      Count := (others => 1); TCount := (others => 1);
      Adr := (others => 0); TAdr := (others => 0); NNZ := 0;
      for R in reverse 0 .. Integer (N) - 1 loop
         Parent (R) := -1; Flag (R) := R;
         for K in 0 .. Integer (HCount (R)) - 1 loop
            I := HCol (HAdr (R) + K);
            if I > R then
               while Flag (I) /= R loop
                  if Parent (I) = -1 then Parent (I) := R; end if;
                  Count (I) := Count (I) + 1; TCount (R) := TCount (R) + 1;
                  Flag (I) := R; I := Parent (I);
               end loop;
            end if;
         end loop;
      end loop;
      for R in 0 .. Integer (N) - 1 loop
         Adr (R) := NNZ; NNZ := NNZ + Count (R);
         if R > 0 then TAdr (R) := TAdr (R - 1) + TCount (R - 1); end if;
      end loop;
   end Symbolic_Count;

   procedure Symbolic_Fill (N : Size; HCount, HAdr, HCol : Indices;
                            Count, Adr, TCount, TAdr : Indices;
                            Col, TCol, Map : out Indices; Status : out Outcome) is
      type Integers is array (Natural range <>) of Integer;
      Parent, Flag, Cursor : Integers (0 .. Integer (N) - 1) := (others => -1);
      Write_Pos : Indices (0 .. Integer (N) - 1) := TAdr;
      I : Natural; P, TP : Offset;
   begin
      Col := (others => 0); TCol := (others => 0); Map := (others => 0);
      Status := Success;
      for R in 0 .. Integer (N) - 1 loop
         if Count (R) = 0 or else Count (R) > N or else Adr (R) > Col'Length
           or else Count (R) > Col'Length - Adr (R)
           or else TCount (R) = 0 or else TCount (R) > N or else TAdr (R) > TCol'Length
           or else TCount (R) > TCol'Length - TAdr (R)
         then Status := Insufficient_Capacity; return; end if;
         Cursor (R) := Adr (R) + Count (R) - 2;
      end loop;
      for R in reverse 0 .. Integer (N) - 1 loop
         Parent (R) := -1; Flag (R) := R;
         P := Adr (R) + Count (R) - 1; Col (P) := R;
         TP := Write_Pos (R); TCol (TP) := R; Map (TP) := P; Write_Pos (R) := TP + 1;
         for K in 0 .. Integer (HCount (R)) - 1 loop
            I := HCol (HAdr (R) + K);
            if I > R then
               while Flag (I) /= R loop
                  if Parent (I) = -1 then Parent (I) := R; end if;
                  if Cursor (I) < Adr (I) or else Write_Pos (R) >= TAdr (R) + TCount (R)
                  then Status := Invalid_Pattern; return; end if;
                  P := Cursor (I); Cursor (I) := Cursor (I) - 1; Col (P) := R;
                  TP := Write_Pos (R); TCol (TP) := I; Map (TP) := P;
                  Write_Pos (R) := TP + 1; Flag (I) := R; I := Parent (I);
               end loop;
            end if;
         end loop;
      end loop;
      if not CSR_Valid (N, Count, Adr, Col, Col'Length, True)
        or else not Transpose_Valid (N, Count, Adr, Col, TCount, TAdr, TCol, Map)
      then Status := Invalid_Pattern; end if;
   end Symbolic_Fill;

   procedure Factor (A : in out Values; N : Size; Count : in out Indices;
                     Adr : Indices; Col : in out Indices; Minimum : Scalar;
                     Rank : out Size; Status : out Outcome) is
      Merge : Values (0 .. Integer (N) - 1) with Relaxed_Initialization;
      Merge_Col : Indices (0 .. Integer (N) - 1) with Relaxed_Initialization;
      D, C, Limit, P, Q, Used : Offset;
      Pivot, Scale, Tmp, Mult : Scalar;
      Clamped : Boolean;
   begin
      Rank := N; Status := Success;
      for R in reverse 0 .. Integer (N) - 1 loop
         pragma Loop_Invariant (Rank <= N and then Rank > R);
         D := Adr (R) + Count (R) - 1; Pivot := A (D);
         Factor_Pivot (Pivot, Minimum, Tmp, Clamped, Status);
         if Clamped then Rank := Rank - 1; end if;
         if Status /= Success then return; end if;
         A (D) := Tmp; Divide (1.0, Tmp, Scale, Status);
         if Status /= Success then return; end if;
         for K in 0 .. Integer (Count (R)) - 2 loop
            Multiply (A (Adr (R) + K), Scale, Tmp, Status);
            if Status /= Success then return; end if;
            A (Adr (R) + K) := Tmp;
         end loop;
         for K in 0 .. Integer (Count (R)) - 2 loop
            C := Col (Adr (R) + K); Mult := -A (Adr (R) + K);
            if C + 1 < N then Limit := Adr (C + 1); else Limit := A'Length; end if;
            P := 0; Q := 0; Used := 0;
            while P < Count (C) or else Q <= K loop
               pragma Loop_Invariant (Used <= N);
               pragma Loop_Invariant
                 (for all I in 0 .. Integer (Used) - 1 =>
                    Merge (I)'Initialized and then Merge_Col (I)'Initialized);
               if Used = N or else Used >= Limit - Adr (C) then
                  Status := Insufficient_Capacity; return;
               end if;
               if P < Count (C) and then
                 (Q > K or else Col (Adr (C) + P) < Col (Adr (R) + Q))
               then
                  Merge (Used) := A (Adr (C) + P);
                  Merge_Col (Used) := Col (Adr (C) + P); P := P + 1;
               elsif P < Count (C) and then Q <= K
                 and then Col (Adr (C) + P) = Col (Adr (R) + Q)
               then
                  Add_Product (A (Adr (C) + P), Mult, A (Adr (R) + Q), Tmp, Status);
                  if Status /= Success then return; end if;
                  Merge (Used) := Tmp; Merge_Col (Used) := Col (Adr (C) + P);
                  P := P + 1; Q := Q + 1;
               else
                  Multiply (Mult, A (Adr (R) + Q), Tmp, Status);
                  if Status /= Success then return; end if;
                  Merge (Used) := Tmp; Merge_Col (Used) := Col (Adr (R) + Q); Q := Q + 1;
               end if;
               Used := Used + 1;
            end loop;
            for I in 0 .. Integer (Used) - 1 loop
               A (Adr (C) + I) := Merge (I); Col (Adr (C) + I) := Merge_Col (I);
            end loop;
            Count (C) := Used;
         end loop;
      end loop;
   end Factor;

   procedure Numeric (H : Values; N : Size; HCount, HAdr, HCol : Indices;
                      Count, Adr, Col, TCount, TAdr, TCol, Map : Indices;
                      Minimum : Scalar; A : in out Values;
                      Workspace : in out Values; Rank : out Size;
                      Status : out Outcome) is
      Present : array (0 .. Integer (N) - 1) of Boolean := (others => False);
      D, C, P, J : Offset; Pivot, Root_Value, Inv, Tmp, Mult : Scalar;
      Deficient : Boolean;
   begin
      Workspace := (others => 0.0); Rank := N; Status := Success;
      for R in reverse 0 .. Integer (N) - 1 loop
         pragma Loop_Invariant (Rank <= N and then Rank > R);
         for K in 0 .. Integer (Count (R)) - 1 loop Present (Col (Adr (R) + K)) := True; end loop;
         for K in 0 .. Integer (HCount (R)) - 1 loop
            J := HCol (HAdr (R) + K);
            if not Present (J) then Status := Missing_Fill; return; end if;
            Workspace (J) := H (HAdr (R) + K);
         end loop;
         for K in 1 .. Integer (TCount (R)) - 1 loop
            P := Map (TAdr (R) + K); C := TCol (TAdr (R) + K); Mult := A (P);
            for I in Adr (C) .. P loop
               J := Col (I);
               if not Present (J) then Status := Missing_Fill; return; end if;
               Add_Product (Workspace (J), -Mult, A (I), Tmp, Status);
               if Status /= Success then return; end if;
               Workspace (J) := Tmp;
            end loop;
         end loop;
         Pivot := Workspace (R);
         Factor_Pivot (Pivot, Minimum, Root_Value, Deficient, Status);
         if Deficient then Rank := Rank - 1; end if;
         if Status /= Success then return; end if;
         Divide (1.0, Root_Value, Inv, Status);
         if Status /= Success then return; end if;
         for K in 0 .. Integer (Count (R)) - 2 loop
            if not Deficient then
               Multiply (Workspace (Col (Adr (R) + K)), Inv, Tmp, Status);
               if Status /= Success then return; end if;
               A (Adr (R) + K) := Tmp;
            else
               A (Adr (R) + K) := 0.0;
            end if;
         end loop;
         D := Adr (R) + Count (R) - 1; A (D) := Root_Value;
         for K in 0 .. Integer (Count (R)) - 1 loop
            J := Col (Adr (R) + K); Workspace (J) := 0.0; Present (J) := False;
         end loop;
      end loop;
   end Numeric;

   procedure Solve (A, RHS : Values; N : Size; Count, Adr, Col : Indices;
                    X : out Values; Status : out Outcome) is
      D, C : Offset; Tmp, Sum, XR : Scalar;
   begin
      X := RHS; Status := Success;
      for R in reverse 0 .. Integer (N) - 1 loop
         D := Adr (R) + Count (R) - 1;
         if X (R) /= 0.0 then
            Divide (X (R), A (D), Tmp, Status);
            if Status /= Success then return; end if;
            X (R) := Tmp; XR := Tmp;
            for K in 0 .. Integer (Count (R)) - 2 loop
               C := Col (Adr (R) + K);
               Add_Product (X (C), -A (Adr (R) + K), XR, Tmp, Status);
               if Status /= Success then return; end if;
               X (C) := Tmp;
            end loop;
         end if;
      end loop;
      for R in 0 .. Integer (N) - 1 loop
         if Count (R) > 1 then
            Dot_Sparse (A, X, Col, Adr (R), Count (R) - 1, Sum, Status);
            if Status /= Success then return; end if;
            Add_Product (X (R), -1.0, Sum, Tmp, Status);
            if Status /= Success then return; end if;
            X (R) := Tmp;
         end if;
         Divide (X (R), A (Adr (R) + Count (R) - 1), Tmp, Status);
         if Status /= Success then return; end if;
         X (R) := Tmp;
      end loop;
   end Solve;

   function Update_Closed (N : Size; Count, Adr, Col, XCol : Indices)
                          return Boolean is
      Active : array (0 .. Integer (N) - 1) of Boolean := (others => False);
      In_Row : array (0 .. Integer (N) - 1) of Boolean := (others => False);
   begin
      if not CSR_Valid (N, Count, Adr, Col, Col'Length, True) or else XCol'First /= 0
      then return False; end if;
      for K in XCol'Range loop
         if XCol (K) >= N then return False; end if;
         Active (XCol (K)) := True;
      end loop;
      for R in reverse 0 .. Integer (N) - 1 loop
         if Active (R) then
            In_Row := (others => False);
            for K in 0 .. Integer (Count (R)) - 1 loop In_Row (Col (Adr (R) + K)) := True; end loop;
            for C in 0 .. R - 1 loop
               if Active (C) and then not In_Row (C) then return False; end if;
            end loop;
            for K in 0 .. Integer (Count (R)) - 2 loop Active (Col (Adr (R) + K)) := True; end loop;
         end if;
      end loop;
      return True;
   end Update_Closed;

   procedure Update (A : in out Values; N : Size; Count, Adr, Col : Indices;
                     X : Values; XCol : Indices; Plus : Boolean;
                     Workspace : in out Values; Rank : out Size;
                     Status : out Outcome) is
      D, J : Offset; Pivot, Sq, XR, Root_Value, C, S, SS, Old, New_A, New_X, Tmp : Scalar;
      Clamped : Boolean;
   begin
      Rank := N; Status := Success;
      if X'Length = 0 then return; end if;
      for I in 0 .. XCol (XCol'Last) loop Workspace (I) := 0.0; end loop;
      for I in X'Range loop Workspace (XCol (I)) := X (I); end loop;
      for R in reverse 0 .. XCol (XCol'Last) loop
         pragma Loop_Invariant (Rank <= N and then Rank > R);
         if Workspace (R) /= 0.0 then
            D := Adr (R) + Count (R) - 1; XR := Workspace (R);
            Multiply (A (D), A (D), Sq, Status);
            if Status /= Success then return; end if;
            Add_Product (Sq, (if Plus then XR else -XR), XR, Pivot, Status);
            if Status /= Success then return; end if;
            Factor_Pivot (Pivot, Min_Diag, Root_Value, Clamped, Status);
            if Clamped then Rank := Rank - 1; end if;
            if Status /= Success then return; end if;
            Divide (A (D), Root_Value, C, Status);
            if Status /= Success then return; end if;
            Divide (-XR, Root_Value, S, Status);
            if Status /= Success then return; end if;
            SS := (if Plus then -S else S); A (D) := Root_Value;
            for K in 0 .. Integer (Count (R)) - 2 loop
               J := Col (Adr (R) + K); Old := A (Adr (R) + K);
               Multiply (C, Old, Tmp, Status);
               if Status /= Success then return; end if;
               Add_Product (Tmp, SS, Workspace (J), New_A, Status);
               if Status /= Success then return; end if;
               Multiply (S, Old, Tmp, Status);
               if Status /= Success then return; end if;
               Add_Product (Tmp, C, Workspace (J), New_X, Status);
               if Status /= Success then return; end if;
               A (Adr (R) + K) := New_A; Workspace (J) := New_X;
            end loop;
         end if;
      end loop;
   end Update;
end MJ.Cholesky_Sparse;

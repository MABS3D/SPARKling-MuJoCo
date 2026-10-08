with MJ.Quaternion_Math;
package body MJ.Constraint_Solvers.Packed_Cholesky with SPARK_Mode is
   use type Sparse.Status;

   procedure Set_Offset (Address : in out Offsets; R : Positive; Value : Natural)
     with Global => null, Inline_Always,
     Pre => (Static => R in Address'Range),
     Post => (Static => Address (R) = Value and then
       (for all I in Address'Range => (if I /= R then Address (I) = Address'Old (I))))
   is
   begin
      Address (R) := Value;
   end Set_Offset;

   procedure Build_Offsets (P : Pattern; Address : out Offsets) is
      Total : Natural := 0;
   begin
      Address := (others => 0);
      for R in 1 .. P.N loop
         Set_Offset (Address, R, Total);
         Total := Total+P.Length (R);
         pragma Loop_Invariant (Total <= R*(R+1)/2);
         pragma Loop_Invariant (Static => Address (1) = 0);
         pragma Loop_Invariant (Static => Total = Address (R)+P.Length (R));
         pragma Loop_Invariant (Static => (for all I in 1 .. R => Address (I) <= I*(I-1)/2
           and then (if I > 1 then Address (I) = Address (I-1)+P.Length (I-1))));
      end loop;
   end Build_Offsets;

   procedure Pack_Row (L : Matrix; P : Pattern; Address : Offsets;
                       R : Positive; Values : in out Vector) is
      Before : constant Vector := Values with Ghost => Static;
   begin
      for K in 1 .. P.Length (R) loop
         Values (Slot (P, Address, R, K)) := L (R, P.Column (R, K));
         pragma Loop_Invariant (Static => Bounded (Values));
         pragma Loop_Invariant (Static => (for all I in 1 .. K =>
           Values (Slot (P, Address, R, I)) = L (R, P.Column (R, I))));
         pragma Loop_Invariant (Static => (for all S in Values'Range =>
           (if S <= Address (R) or else S > Address (R)+P.Length (R) then Values (S) = Before (S))));
      end loop;
   end Pack_Row;

   procedure Offsets_Ordered (P : Pattern; Address : Offsets; First, Last : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then First < Last and then Last <= P.N,
     Post => Address (First)+P.Length (First) <= Address (Last),
     Subprogram_Variant => (Decreases => Last)
   is
   begin
      if First+1 < Last then Offsets_Ordered (P, Address, First, Last-1); end if;
   end Offsets_Ordered;

   procedure Prior_Rows (P : Pattern; Address : Offsets; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then R <= P.N,
     Post => (for all I in 1 .. R-1 => Address (I)+P.Length (I) <= Address (R))
   is
   begin
      for I in 1 .. R-1 loop
         Offsets_Ordered (P, Address, I, R);
         pragma Loop_Invariant (for all J in 1 .. I => Address (J)+P.Length (J) <= Address (R));
      end loop;
   end Prior_Rows;

   procedure Pack (L : Matrix; P : Pattern; Address : Offsets; Values : out Vector) is
   begin
      Values := (others => 0.0);
      for R in 1 .. P.N loop
         Prior_Rows (P, Address, R);
         Pack_Row (L, P, Address, R, Values);
         pragma Loop_Invariant (Static => Bounded (Values));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. P.Length (I) => Values (Slot (P, Address, I, K)) = L (I, P.Column (I, K)))));
      end loop;
   end Pack;

   procedure Ordered (P : Pattern; R, First, Last : Positive)
     with Ghost => Static, Global => null,
     Pre => Sparse.Valid (P) and then R <= P.N and then First <= Last and then Last <= P.Length (R),
     Post => P.Column (R, First) <= P.Column (R, Last)
       and then (if First < Last then P.Column (R, First) < P.Column (R, Last)),
     Subprogram_Variant => (Decreases => Last)
   is
   begin
      if First < Last then Ordered (P, R, First, Last-1); end if;
   end Ordered;

   procedure Separate_Column (P : Pattern; R, Position : Positive)
     with Ghost => Static, Global => null,
     Pre => Sparse.Valid (P) and then R <= P.N and then Position <= P.Length (R),
     Post => (for all K in 1 .. P.Length (R) =>
       (if K /= Position then P.Column (R, K) /= P.Column (R, Position)))
   is
   begin
      for K in 1 .. P.Length (R) loop
         if K < Position then Ordered (P, R, K, Position);
         elsif K > Position then Ordered (P, R, Position, K); end if;
         pragma Loop_Invariant (for all Q in 1 .. K =>
           (if Q /= Position then P.Column (R, Q) /= P.Column (R, Position)));
      end loop;
   end Separate_Column;

   procedure Expand (Values : Vector; P : Pattern; Address : Offsets; L : out Matrix) is
   begin
      L := (others => (others => 0.0));
      for R in 1 .. P.N loop
         for K in 1 .. P.Length (R) loop
            Separate_Column (P, R, K);
            L (R, P.Column (R, K)) := Values (Slot (P, Address, R, K));
            pragma Loop_Invariant (Static => Dense.Bounded (L));
            pragma Loop_Invariant (Static => (for all Q in 1 .. K =>
              L (R, P.Column (R, Q)) = Values (Slot (P, Address, R, Q))));
            pragma Loop_Invariant (Static => (for all I in 1 .. R-1 =>
              (for all Q in 1 .. P.Length (I) => L (I, P.Column (I, Q)) = Values (Slot (P, Address, I, Q)))));
         end loop;
         pragma Loop_Invariant (Static => Dense.Bounded (L));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. P.Length (I) => L (I, P.Column (I, K)) = Values (Slot (P, Address, I, K)))));
      end loop;
   end Expand;

   procedure Bound_Monotone (Budget : Natural)
     with Ghost => Static, Global => null,
     Pre => Budget < Sparse.Max_Updates,
     Post => Sparse.Scratch_Bound (Budget) <= Sparse.Scratch_Bound (Budget+1)
   is
   begin
      pragma Assert (Real (Budget) <= Real (Budget+1));
   end Bound_Monotone;

   procedure Set_Scratch (Scratch : in out Vector; J : Positive; Value : Real; Budget : Natural)
     with Global => null, Inline_Always,
     Pre => (Static => J in Scratch'Range and then Budget <= Sparse.Max_Updates
       and then abs Value <= Sparse.Scratch_Bound (Budget)
       and then (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget))),
     Post => (Static => Scratch (J) = Value
       and then (for all I in Scratch'Range => (if I /= J then Scratch (I) = Scratch'Old (I)))
       and then (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget)))
   is
   begin
      Scratch (J) := Value;
   end Set_Scratch;

   procedure Prefix_Progress (Original, Previous, After, L : Vector;
                              P : Pattern; Address : Offsets; C, Q, Position : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then C <= P.N
       and then Q <= Position and then Position <= P.Length (C)
       and then L'First = 1 and then L'Length = P.N*(P.N+1)/2 and then Bounded (L)
       and then Original'First = 1 and then Original'Length = P.N
       and then (for all V of Original => V in Sparse.Residual)
       and then Previous'First = 1 and then Previous'Length = P.N
       and then After'First = 1 and then After'Length = P.N
       and then (for all K in 1 .. Q-1 => Previous (P.Column (C, K)) = Sparse.Update
         (Original (P.Column (C, K)), L (Slot (P, Address, C, Position)), L (Slot (P, Address, C, K))))
       and then After (P.Column (C, Q)) = Sparse.Update
         (Original (P.Column (C, Q)), L (Slot (P, Address, C, Position)), L (Slot (P, Address, C, Q)))
       and then (for all I in After'Range =>
         (if I /= P.Column (C, Q) then After (I) = Previous (I))),
     Post => (for all K in 1 .. Q => After (P.Column (C, K)) = Sparse.Update
       (Original (P.Column (C, K)), L (Slot (P, Address, C, Position)), L (Slot (P, Address, C, K))))
   is
   begin
      Separate_Column (P, C, Q);
      for K in 1 .. Q loop
         if K < Q then
            pragma Assert (After (P.Column (C, K)) = Previous (P.Column (C, K)));
         end if;
         pragma Loop_Invariant (for all I in 1 .. K => After (P.Column (C, I)) = Sparse.Update
           (Original (P.Column (C, I)), L (Slot (P, Address, C, Position)), L (Slot (P, Address, C, I))));
      end loop;
   end Prefix_Progress;

   procedure Update_Row (L : Vector; P : Pattern; Address : Offsets; C, Position : Positive;
                         Scratch : in out Vector; Budget : Natural)
     with Global => null, Inline_Always,
     Pre => (Static => Valid_Offsets (P, Address) and then C <= P.N and then Position <= P.Length (C)
       and then L'First = 1 and then L'Length = P.N*(P.N+1)/2 and then Bounded (L)
       and then Scratch'First = 1 and then Scratch'Length = P.N and then Budget < Sparse.Max_Updates
       and then (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget))),
     Post => (Static => (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget+1))
       and then (for all K in 1 .. Position => Scratch (P.Column (C, K)) = Sparse.Update
         (Scratch'Old (P.Column (C, K)), L (Slot (P, Address, C, Position)), L (Slot (P, Address, C, K))))
       and then (for all J in Scratch'Range =>
         (if (for all K in 1 .. Position => P.Column (C, K) /= J) then Scratch (J) = Scratch'Old (J))))
   is
      Before : constant Vector := Scratch with Ghost => Static;
      Iteration_Before : Vector (Scratch'Range) with Ghost => Static;
      First : constant Positive := Slot (P, Address, C, 1);
      Row_L : Vector renames L (First .. Slot (P, Address, C, Position));
      Multiplier : constant Real := L (Slot (P, Address, C, Position));
      J, Q : Positive;
      Value : Real;
   begin
      Bound_Monotone (Budget);
      for S in Row_L'Range loop
         Q := S-First+1;
         Iteration_Before := Scratch;
         Separate_Column (P, C, Q);
         J := P.Column (C, Q);
         pragma Assert (Static => Scratch (J) = Before (J));
         pragma Assert (Static => First+Q-1 = Slot (P, Address, C, Q));
         Value := Sparse.Update (Scratch (J), Multiplier, Row_L (S));
         pragma Assert (Static => Value = Sparse.Headroom_Update
           (Before (J), Multiplier, L (Slot (P, Address, C, Q)), Budget));
         Set_Scratch (Scratch, J, Value, Budget+1);
         Prefix_Progress (Before, Iteration_Before, Scratch, L, P, Address, C, Q, Position);
         pragma Loop_Invariant (Static => Q = S-First+1);
         pragma Loop_Invariant (Static => (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget+1)));
         pragma Loop_Invariant (Static => (for all K in 1 .. Q => Scratch (P.Column (C, K)) = Sparse.Update
           (Before (P.Column (C, K)), Multiplier, L (Slot (P, Address, C, K)))));
         pragma Loop_Invariant (Static => (for all K in Q+1 .. Position =>
           Scratch (P.Column (C, K)) = Before (P.Column (C, K))));
         pragma Loop_Invariant (Static => (for all I in Scratch'Range =>
           (if (for all K in 1 .. Q => P.Column (C, K) /= I) then Scratch (I) = Before (I))));
      end loop;
   end Update_Row;

   function Valid_Transpose_Offsets (P : Pattern; Address : Offsets) return Boolean is
     (Sparse.Valid (P) and then Address'First = 1 and then Address'Length = P.N
       and then Address (1) = 0
       and then (for all R in 1 .. P.N =>
         Address (R) <= (R-1)*(2*P.N-R+2)/2
         and then Address (R)+P.Transpose_Length (R) <= P.N*(P.N+1)/2
         and then (if R > 1 then Address (R) = Address (R-1)+P.Transpose_Length (R-1))))
     with Ghost => Static, Global => null;

   procedure Transpose_Envelope (N, R : Positive)
     with Ghost => Static, Global => null,
     Pre => N <= Max_Dofs and then R <= N,
     Post => (R-1)*(2*N-R+2)/2+(N-R+1) = R*(2*N-R+1)/2
       and then R*(2*N-R+1)/2 <= N*(N+1)/2
   is
   begin
      pragma Assert ((R-1)*(2*N-R+2)+2*(N-R+1) = R*(2*N-R+1));
      pragma Assert (N*(N+1)-R*(2*N-R+1) = (N-R)*(N-R+1));
   end Transpose_Envelope;

   procedure Build_Transpose_Offsets (P : Pattern; Address : out Offsets)
     with Global => null,
     Pre => (Static => Sparse.Valid (P) and then Address'First = 1 and then Address'Length = P.N),
     Post => (Static => Valid_Transpose_Offsets (P, Address))
   is
      Total : Natural := 0;
   begin
      Address := (others => 0);
      for R in 1 .. P.N loop
         Transpose_Envelope (P.N, R);
         pragma Assert (Static => Total <= (R-1)*(2*P.N-R+2)/2);
         Set_Offset (Address, R, Total);
         Total := Total+P.Transpose_Length (R);
         pragma Loop_Invariant (Total <= R*(2*P.N-R+1)/2 and then Total <= P.N*(P.N+1)/2);
         pragma Loop_Invariant (Static => Address (1) = 0);
         pragma Loop_Invariant (Static => Total = Address (R)+P.Transpose_Length (R));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           Address (I) <= (I-1)*(2*P.N-I+2)/2
           and then Address (I)+P.Transpose_Length (I) <= P.N*(P.N+1)/2
           and then (if I > 1 then Address (I) = Address (I-1)+P.Transpose_Length (I-1))));
      end loop;
   end Build_Transpose_Offsets;

   procedure Copy_Flat_Columns (P : Pattern; Address : Offsets; R : Positive;
                                Columns : in out Dof_List)
     with Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then R <= P.N
       and then Columns'First = 1 and then Columns'Length = P.N*(P.N+1)/2),
     Post => (Static => (for all K in 1 .. P.Length (R) =>
       Columns (Address (R)+K) = P.Column (R, K))
       and then (for all S in Columns'Range =>
         (if S <= Address (R) or else S > Address (R)+P.Length (R) then Columns (S) = Columns'Old (S))))
   is
      Before : constant Dof_List := Columns with Ghost => Static;
   begin
      for K in 1 .. P.Length (R) loop
         Columns (Slot (P, Address, R, K)) := P.Column (R, K);
         pragma Loop_Invariant (Static => (for all I in 1 .. K => Columns (Address (R)+I) = P.Column (R, I)));
         pragma Loop_Invariant (Static => (for all S in Columns'Range =>
           (if S <= Address (R) or else S > Address (R)+P.Length (R) then Columns (S) = Before (S))));
      end loop;
   end Copy_Flat_Columns;

   procedure Transpose_Offsets_Ordered (P : Pattern; Address : Offsets; First, Last : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Transpose_Offsets (P, Address) and then First < Last and then Last <= P.N,
     Post => Address (First)+P.Transpose_Length (First) <= Address (Last),
     Subprogram_Variant => (Decreases => Last)
   is
   begin
      if First+1 < Last then Transpose_Offsets_Ordered (P, Address, First, Last-1); end if;
   end Transpose_Offsets_Ordered;

   procedure Transpose_Prior_Rows (P : Pattern; Address : Offsets; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Transpose_Offsets (P, Address) and then R <= P.N,
     Post => (for all I in 1 .. R-1 => Address (I)+P.Transpose_Length (I) <= Address (R))
   is
   begin
      for I in 1 .. R-1 loop
         Transpose_Offsets_Ordered (P, Address, I, R);
         pragma Loop_Invariant (for all J in 1 .. I => Address (J)+P.Transpose_Length (J) <= Address (R));
      end loop;
   end Transpose_Prior_Rows;

   procedure Copy_Flat_Transpose (P : Pattern; Address, Transpose_Address : Offsets; R : Positive;
                                  Rows : in out Dof_List; Slots : in out Offsets)
     with Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then Valid_Transpose_Offsets (P, Transpose_Address)
       and then R <= P.N and then Rows'First = 1 and then Rows'Length = P.N*(P.N+1)/2
       and then Slots'First = 1 and then Slots'Length = Rows'Length),
     Post => (Static => (for all K in 1 .. P.Transpose_Length (R) =>
       Rows (Transpose_Address (R)+K) = P.Transpose_Row (R, K)
       and then Slots (Transpose_Address (R)+K) = Address (P.Transpose_Row (R, K))+P.Transpose_Position (R, K))
       and then (for all S in Rows'Range =>
         (if S <= Transpose_Address (R) or else S > Transpose_Address (R)+P.Transpose_Length (R)
          then Rows (S) = Rows'Old (S) and then Slots (S) = Slots'Old (S))))
   is
      Before_Rows : constant Dof_List := Rows with Ghost => Static;
      Before_Slots : constant Offsets := Slots with Ghost => Static;
   begin
      for K in 1 .. P.Transpose_Length (R) loop
         Rows (Transpose_Address (R)+K) := P.Transpose_Row (R, K);
         Slots (Transpose_Address (R)+K) := Slot (P, Address, P.Transpose_Row (R, K), P.Transpose_Position (R, K));
         pragma Loop_Invariant (Static => (for all I in 1 .. K =>
           Rows (Transpose_Address (R)+I) = P.Transpose_Row (R, I)
           and then Slots (Transpose_Address (R)+I) = Address (P.Transpose_Row (R, I))+P.Transpose_Position (R, I)));
         pragma Loop_Invariant (Static => (for all S in Rows'Range =>
           (if S <= Transpose_Address (R) or else S > Transpose_Address (R)+P.Transpose_Length (R)
            then Rows (S) = Before_Rows (S) and then Slots (S) = Before_Slots (S))));
      end loop;
   end Copy_Flat_Transpose;

   procedure Build_Flat (P : Pattern; F : out Flat_Pattern) is
   begin
      F.Length := P.Length;
      F.Transpose_Length := P.Transpose_Length;
      F.Column := (others => 1);
      F.Transpose_Row := (others => 1);
      F.Transpose_Slot := (others => 1);
      Build_Offsets (P, F.Address);
      Build_Transpose_Offsets (P, F.Transpose_Address);
      for R in 1 .. P.N loop
         Prior_Rows (P, F.Address, R);
         Transpose_Prior_Rows (P, F.Transpose_Address, R);
         Copy_Flat_Columns (P, F.Address, R, F.Column);
         Copy_Flat_Transpose (P, F.Address, F.Transpose_Address, R, F.Transpose_Row, F.Transpose_Slot);
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. P.Length (I) => F.Column (F.Address (I)+K) = P.Column (I, K))));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. P.Transpose_Length (I) =>
             F.Transpose_Row (F.Transpose_Address (I)+K) = P.Transpose_Row (I, K)
             and then F.Transpose_Slot (F.Transpose_Address (I)+K) =
               F.Address (P.Transpose_Row (I, K))+P.Transpose_Position (I, K))));
      end loop;
   end Build_Flat;

   function Ordered_Flat (Columns : Dof_List; First, Last, N : Positive) return Boolean is
     (First in Columns'Range and then Last in Columns'Range and then First <= Last
       and then (for all K in First .. Last => Columns (K) <= N
         and then (if K > First then Columns (K-1) < Columns (K))))
     with Ghost => Static, Global => null;

   procedure Flat_Ordered (Columns : Dof_List; First, Last, A, B, N : Positive)
     with Ghost => Static, Global => null,
     Pre => Ordered_Flat (Columns, First, Last, N) and then A in First .. Last and then B in A .. Last,
     Post => Columns (A) <= Columns (B) and then (if A < B then Columns (A) < Columns (B)),
     Subprogram_Variant => (Decreases => B)
   is
   begin
      if A < B then Flat_Ordered (Columns, First, Last, A, B-1, N); end if;
   end Flat_Ordered;

   procedure Flat_Separate (Columns : Dof_List; First, Last, Position, N : Positive)
     with Ghost => Static, Global => null,
     Pre => Ordered_Flat (Columns, First, Last, N) and then Position in First .. Last,
     Post => (for all K in First .. Last => (if K /= Position then Columns (K) /= Columns (Position)))
   is
   begin
      for K in First .. Last loop
         if K < Position then Flat_Ordered (Columns, First, Last, K, Position, N);
         elsif K > Position then Flat_Ordered (Columns, First, Last, Position, K, N); end if;
         pragma Loop_Invariant (for all I in First .. K =>
           (if I /= Position then Columns (I) /= Columns (Position)));
      end loop;
   end Flat_Separate;

   procedure Flat_Prefix_Progress (Original, Previous, After, L : Vector;
                                   Columns : Dof_List; First, Last, Position : Positive)
     with Ghost => Static, Global => null,
     Pre => Original'First = 1 and then Original'Length in 1 .. Max_Dofs
       and then (for all V of Original => V in Sparse.Residual)
       and then Previous'First = Original'First and then Previous'Last = Original'Last and then After'First = Original'First and then After'Last = Original'Last
       and then L'First = Columns'First and then L'Last = Columns'Last and then Bounded (L)
       and then Ordered_Flat (Columns, First, Last, Original'Length) and then Position in First .. Last
       and then (for all K in First .. Position-1 => Previous (Columns (K)) =
         Sparse.Update (Original (Columns (K)), L (Last), L (K)))
       and then After (Columns (Position)) = Sparse.Update (Original (Columns (Position)), L (Last), L (Position))
       and then (for all J in After'Range => (if J /= Columns (Position) then After (J) = Previous (J))),
     Post => (for all K in First .. Position => After (Columns (K)) =
       Sparse.Update (Original (Columns (K)), L (Last), L (K)))
   is
   begin
      Flat_Separate (Columns, First, Last, Position, Original'Length);
      for K in First .. Position loop
         if K < Position then pragma Assert (After (Columns (K)) = Previous (Columns (K))); end if;
         pragma Loop_Invariant (for all I in First .. K => After (Columns (I)) =
           Sparse.Update (Original (Columns (I)), L (Last), L (I)));
      end loop;
   end Flat_Prefix_Progress;

   procedure Flat_Update_Row (L : Vector; Columns : Dof_List; First, Last : Positive;
                              Scratch : in out Vector; Budget : Natural)
     with Global => null, Inline_Always,
     Pre => (Static => Scratch'First = 1 and then Scratch'Length in 1 .. Max_Dofs
       and then L'First = Columns'First and then L'Last = Columns'Last and then Bounded (L)
       and then Ordered_Flat (Columns, First, Last, Scratch'Length) and then Budget < Sparse.Max_Updates
       and then (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget))),
     Post => (Static => (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget+1))
       and then (for all K in First .. Last => Scratch (Columns (K)) =
         Sparse.Update (Scratch'Old (Columns (K)), L (Last), L (K)))
       and then (for all J in Scratch'Range =>
         (if (for all K in First .. Last => Columns (K) /= J) then Scratch (J) = Scratch'Old (J))))
   is
      Before : constant Vector := Scratch with Ghost => Static;
      Iteration_Before : Vector (Scratch'Range) with Ghost => Static;
      Row_L : Vector renames L (First .. Last);
      Row_Column : Dof_List renames Columns (First .. Last);
      Multiplier : constant Real := L (Last);
      J : Dof_Index;
      Value : Real;
   begin
      Bound_Monotone (Budget);
      for S in Row_L'Range loop
         Iteration_Before := Scratch;
         Flat_Separate (Columns, First, Last, S, Scratch'Length);
         J := Row_Column (S);
         pragma Assert (Static => Scratch (J) = Before (J));
         Value := Sparse.Update (Scratch (J), Multiplier, Row_L (S));
         pragma Assert (Static => Value = Sparse.Headroom_Update (Before (J), Multiplier, L (S), Budget));
         Set_Scratch (Scratch, J, Value, Budget+1);
         Flat_Prefix_Progress (Before, Iteration_Before, Scratch, L, Columns, First, Last, S);
         pragma Loop_Invariant (Static => (for all V of Scratch => abs V <= Sparse.Scratch_Bound (Budget+1)));
         pragma Loop_Invariant (Static => (for all K in First .. S => Scratch (Columns (K)) =
           Sparse.Update (Before (Columns (K)), Multiplier, L (K))));
         pragma Loop_Invariant (Static => (for all K in S+1 .. Last => Scratch (Columns (K)) = Before (Columns (K))));
         pragma Loop_Invariant (Static => (for all J in Scratch'Range =>
           (if (for all K in First .. S => Columns (K) /= J) then Scratch (J) = Before (J))));
      end loop;
   end Flat_Update_Row;

   procedure Factor_Flat (H : Matrix; F : Flat_Pattern; L : in out Vector;
                          Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) is
      Scratch : Vector (1 .. Max_Dofs) := (others => 0.0);
      C, Last, J, First : Positive;
      Value, Root, Inverse : Real;
      Deficient : Boolean;
   begin
      Rank := F.N; Result := Sparse.Numeric_Limit;
      for R in reverse 1 .. F.N loop
         First := F.Address (R)+1;
         for S in First .. F.Address (R)+F.Length (R) loop
            J := F.Column (S); Scratch (J) := H (R, J);
         end loop;
         for K in 2 .. F.Transpose_Length (R) loop
            C := F.Transpose_Row (F.Transpose_Address (R)+K);
            Last := F.Transpose_Slot (F.Transpose_Address (R)+K);
            Flat_Update_Row (L, F.Column, F.Address (C)+1, Last, Scratch, (F.N-R)*Max_Dofs+K-1);
         end loop;
         Value := Scratch (R); Deficient := Value < Floor;
         if Deficient then Value := Floor; Rank := Rank-1; end if;
         Root := MJ.Quaternion_Math.Sqrt (Value);
         if Root not in Pivot then return; end if;
         Inverse := Dense.Inverse_Pivot (Root);
         for S in First .. F.Address (R)+F.Length (R)-1 loop
            Value := (if Deficient then 0.0 else Sparse.Scale (Scratch (F.Column (S)), Inverse));
            if Value not in Operand then return; end if;
            L (S) := Value;
         end loop;
         L (F.Address (R)+F.Length (R)) := Root;
         for S in First .. F.Address (R)+F.Length (R) loop Scratch (F.Column (S)) := 0.0; end loop;
         pragma Loop_Invariant (Static => Bounded (L));
         pragma Loop_Invariant (Rank in R-1 .. F.N);
      end loop;
      Result := Sparse.Success;
   end Factor_Flat;

   procedure Backsolve_Flat (L : Vector; F : Flat_Pattern; B : Vector; X : out Vector;
                             Result : out Status) is
      Value, Sum, S0, S1, S2, S3, Multiplier : Real;
      J, First, Offset, Count : Natural;
   begin
      X := B; Result := Sparse.Numeric_Limit;
      for I in reverse 1 .. F.N loop
         if X (I) /= 0.0 then
            Value := X (I)/L (F.Address (I)+F.Length (I));
            if Value not in Operand then return; end if;
            X (I) := Value; Multiplier := Value; First := F.Address (I);
            for K in 1 .. F.Length (I)-1 loop
               J := F.Column (First+K); Value := Sparse.Update (X (J), L (First+K), Multiplier);
               if Value not in Operand then return; end if;
               X (J) := Value;
            end loop;
         end if;
      end loop;
      for I in 1 .. F.N loop
         Count := F.Length (I)-1; First := F.Address (I);
         if Count > 0 then
            S0 := 0.0; S1 := 0.0; S2 := 0.0; S3 := 0.0; Offset := 0;
            while Offset+4 <= Count loop
               J := F.Column (First+Offset+1); S0 := S0+L (First+Offset+1)*X (J);
               J := F.Column (First+Offset+2); S1 := S1+L (First+Offset+2)*X (J);
               J := F.Column (First+Offset+3); S2 := S2+L (First+Offset+3)*X (J);
               J := F.Column (First+Offset+4); S3 := S3+L (First+Offset+4)*X (J);
               Offset := Offset+4;
               pragma Loop_Variant (Increases => Offset);
            end loop;
            Sum := (S0+S2)+(S1+S3);
            for K in Offset+1 .. Count loop
               J := F.Column (First+K); Sum := Sum+L (First+K)*X (J);
            end loop;
            Value := X (I)-Sum;
         else Value := X (I); end if;
         Value := Value/L (F.Address (I)+F.Length (I));
         if Value not in Operand then return; end if;
         X (I) := Value;
      end loop;
      Result := Sparse.Success;
   end Backsolve_Flat;

   procedure Factor (H : Matrix; P : Pattern; Address : Offsets; L : in out Vector;
                     Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) is
      Scratch : Vector (1 .. P.N) := (others => 0.0);
      C, Pos, J, First : Positive;
      Value, Root, Inverse : Real;
      Deficient : Boolean;
   begin
      Rank := P.N; Result := Sparse.Numeric_Limit;
      for R in reverse 1 .. P.N loop
         for K in 1 .. P.Length (R) loop
            J := P.Column (R, K); Scratch (J) := H (R, J);
         end loop;
         for K in 2 .. P.Transpose_Length (R) loop
            C := P.Transpose_Row (R, K); Pos := P.Transpose_Position (R, K);
            Update_Row (L, P, Address, C, Pos, Scratch, (P.N-R)*Max_Dofs+K-1);
         end loop;
         Value := Scratch (R); Deficient := Value < Floor;
         if Deficient then Value := Floor; Rank := Rank-1; end if;
         Root := MJ.Quaternion_Math.Sqrt (Value);
         if Root not in Pivot then return; end if;
         Inverse := Dense.Inverse_Pivot (Root);
         First := Slot (P, Address, R, 1);
         for K in 1 .. P.Length (R)-1 loop
            Value := (if Deficient then 0.0 else Sparse.Scale (Scratch (P.Column (R, K)), Inverse));
            if Value not in Operand then return; end if;
            L (First+K-1) := Value;
         end loop;
         L (Slot (P, Address, R, P.Length (R))) := Root;
         for K in 1 .. P.Length (R) loop Scratch (P.Column (R, K)) := 0.0; end loop;
         pragma Loop_Invariant (Static => Bounded (L));
         pragma Loop_Invariant (Rank in R-1 .. P.N);
      end loop;
      Result := Sparse.Success;
   end Factor;

   procedure Backsolve (L : Vector; P : Pattern; Address : Offsets; B : Vector; X : out Vector;
                        Result : out Status) is
      Value, S, S0, S1, S2, S3, Multiplier : Real;
      J, First, Offset, Count : Natural;
   begin
      X := B; Result := Sparse.Numeric_Limit;
      for I in reverse 1 .. P.N loop
         if X (I) /= 0.0 then
            Value := X (I)/L (Slot (P, Address, I, P.Length (I)));
            if Value not in Operand then return; end if;
            X (I) := Value; Multiplier := Value; First := Address (I);
            for K in 1 .. P.Length (I)-1 loop
               J := P.Column (I, K); Value := Sparse.Update (X (J), L (First+K), Multiplier);
               if Value not in Operand then return; end if;
               X (J) := Value;
            end loop;
         end if;
      end loop;
      for I in 1 .. P.N loop
         Count := P.Length (I)-1; First := Address (I);
         if Count > 0 then
            S0 := 0.0; S1 := 0.0; S2 := 0.0; S3 := 0.0; Offset := 0;
            while Offset+4 <= Count loop
               J := P.Column (I, Offset+1); S0 := S0+L (First+Offset+1)*X (J);
               J := P.Column (I, Offset+2); S1 := S1+L (First+Offset+2)*X (J);
               J := P.Column (I, Offset+3); S2 := S2+L (First+Offset+3)*X (J);
               J := P.Column (I, Offset+4); S3 := S3+L (First+Offset+4)*X (J);
               Offset := Offset+4;
               pragma Loop_Variant (Increases => Offset);
            end loop;
            S := (S0+S2)+(S1+S3);
            for K in Offset+1 .. Count loop
               J := P.Column (I, K); S := S+L (First+K)*X (J);
            end loop;
            Value := X (I)-S;
         else Value := X (I); end if;
         Value := Value/L (Slot (P, Address, I, P.Length (I)));
         if Value not in Operand then return; end if;
         X (I) := Value;
      end loop;
      Result := Sparse.Success;
   end Backsolve;
end MJ.Constraint_Solvers.Packed_Cholesky;

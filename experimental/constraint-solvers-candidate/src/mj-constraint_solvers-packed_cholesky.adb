with MJ.Quaternion_Math;
package body MJ.Constraint_Solvers.Packed_Cholesky with SPARK_Mode is
   use type Sparse.Status;
   use type Sparse.Counts;

   function Symbolic_Mask (H : Sparse.Mask) return Sparse.Mask is
      Support : Sparse.Mask (1 .. H'Length (1), 1 .. H'Length (1)) :=
        (others => (others => False));
   begin
      for R in Support'Range (1) loop
         for C in 1 .. R loop
            Support (R, C) := R = C or else H (C, R);
         end loop;
      end loop;
      --  Independent elimination model: eliminating R connects every pair
      --  of its remaining neighbours. Only the upper input triangle is read.
      for R in reverse Support'Range (1) loop
         for I in 1 .. R-1 loop
            for J in I+1 .. R-1 loop
               if Support (R, I) and then Support (R, J) then
                  Support (J, I) := True;
               end if;
            end loop;
         end loop;
      end loop;
      return Support;
   end Symbolic_Mask;

   function Row_Nonzeros (H : Sparse.Mask; R : Positive) return Natural is
      Support : constant Sparse.Mask := Symbolic_Mask (H);
      Count : Natural := 0;
   begin
      for C in 1 .. R loop
         if Support (R, C) then Count := Count+1; end if;
         pragma Loop_Invariant (Count <= C);
      end loop;
      return Count;
   end Row_Nonzeros;

   function Column_Nonzeros (H : Sparse.Mask; R : Positive) return Natural is
      Support : constant Sparse.Mask := Symbolic_Mask (H);
      Count : Natural := 0;
   begin
      for C in R .. H'Length (1) loop
         if Support (C, R) then Count := Count+1; end if;
         pragma Loop_Invariant (Count <= C-R+1);
      end loop;
      return Count;
   end Column_Nonzeros;

   function Matches_Symbolic_Counts (H : Sparse.Mask; P : Symbolic_Plan) return Boolean is
   begin
      return (for all R in 1 .. P.N => P.Length (R) = Row_Nonzeros (H, R)
        and then P.Transpose_Length (R) = Column_Nonzeros (H, R));
   end Matches_Symbolic_Counts;

   function Count_Bounds (P : Symbolic_Plan) return Boolean is
     (P.N <= Max_Dofs and then P.Stored in P.N .. P.N*(P.N+1)/2
       and then (for all R in 1 .. P.N => P.Length (R) in 1 .. R
         and then P.Transpose_Length (R) in 1 .. P.N-R+1))
     with Ghost => Static, Global => null;

   procedure Count_Link (P : in out Symbolic_Plan; R, I : Positive)
     with Global => null, Inline_Always,
     Pre => (Static => Count_Bounds (P) and then R < I and then I <= P.N
       and then P.Length (I) < I and then P.Transpose_Length (R) < P.N-R+1
       and then P.Stored < P.N*(P.N+1)/2),
     Post => (Static => Count_Bounds (P) and then P.Stored = P.Stored'Old+1
       and then P.Length (I) = P.Length'Old (I)+1
       and then P.Transpose_Length (R) = P.Transpose_Length'Old (R)+1
       and then (for all Q in 1 .. P.N =>
         (if Q /= I then P.Length (Q) = P.Length'Old (Q))
         and then (if Q /= R then P.Transpose_Length (Q) = P.Transpose_Length'Old (Q)))
       and then P.Address = P.Address'Old and then P.Transpose_Address = P.Transpose_Address'Old)
   is
   begin
      P.Length (I) := P.Length (I)+1;
      P.Transpose_Length (R) := P.Transpose_Length (R)+1;
      P.Stored := P.Stored+1;
   end Count_Link;

   procedure Count_Symbolic (H : Sparse.Mask; P : out Symbolic_Plan; Result : out Status) is
      Parent, Flag : Offsets (1 .. H'Length (1)) := (others => 0);
      I : Positive;
      Total, Transpose_Total : Natural := 0;
   begin
      P.Length := (others => 1); P.Transpose_Length := (others => 1);
      P.Address := (others => 0); P.Transpose_Address := (others => 0);
      P.Stored := P.N; Result := Sparse.Invalid_Pattern;
      for R in reverse 1 .. P.N loop
         Parent (R) := 0; Flag (R) := R;
         for C in R+1 .. P.N loop
            if H (R, C) then
               I := C;
               while Flag (I) /= R loop
                  pragma Loop_Invariant (Static => Count_Bounds (P));
                  pragma Loop_Invariant (I in R+1 .. P.N);
                  pragma Loop_Invariant (Flag (R) = R);
                  pragma Loop_Variant (Decreases => I);
                  if Parent (I) = 0 then Parent (I) := R; end if;
                  if P.Length (I) >= I or else P.Transpose_Length (R) >= P.N-R+1
                    or else P.Stored >= P.N*(P.N+1)/2
                  then return; end if;
                  Count_Link (P, R, I);
                  Flag (I) := R;
                  if Parent (I) not in R .. I-1 then return; end if;
                  I := Parent (I);
               end loop;
            end if;
            pragma Loop_Invariant (Static => Count_Bounds (P));
            pragma Loop_Invariant (Flag (R) = R);
         end loop;
         pragma Loop_Invariant (Static => Count_Bounds (P));
      end loop;
      for R in 1 .. P.N loop
         P.Address (R) := Total; P.Transpose_Address (R) := Transpose_Total;
         Total := Total+P.Length (R);
         Transpose_Total := Transpose_Total+P.Transpose_Length (R);
         pragma Loop_Invariant (Total <= R*(R+1)/2);
         pragma Loop_Invariant (Transpose_Total <= R*(2*P.N-R+1)/2);
         pragma Loop_Invariant (Static => Count_Bounds (P));
      end loop;
      if Total /= P.Stored or else Transpose_Total /= P.Stored then return; end if;
      Result := Sparse.Success;
   end Count_Symbolic;

   function Symbolic_Support (H : Sparse.Mask; F : Flat_Pattern) return Boolean is
      Support : constant Sparse.Mask := Symbolic_Mask (H);
   begin
      return (for all R in 1 .. F.N =>
        F.Length (R) = Row_Nonzeros (H, R)
        and then F.Transpose_Length (R) = Column_Nonzeros (H, R)
        and then (for all K in 1 .. F.Length (R) => Support (R, F.Column (F.Address (R)+K)))
        and then (for all K in 1 .. F.Transpose_Length (R) =>
          F.Transpose_Row (F.Transpose_Address (R)+K) <= F.N and then
          Support (F.Transpose_Row (F.Transpose_Address (R)+K), R))
        and then (for all C in 1 .. R =>
          (if Support (R, C) then
            (for some K in 1 .. F.Length (R) => F.Column (F.Address (R)+K) = C))));
   end Symbolic_Support;

   procedure Fill_Symbolic (H : Sparse.Mask; P : Symbolic_Plan;
                            F : out Flat_Pattern; Result : out Status) is
      Parent, Flag, Cursor, Transpose_Write : Offsets (1 .. P.N) := (others => 0);
      I : Positive;
      L_Slot, T_Slot : Positive;
   begin
      F.Length := P.Length; F.Transpose_Length := P.Transpose_Length;
      F.Address := P.Address; F.Transpose_Address := P.Transpose_Address;
      F.Column := (others => 1); F.Transpose_Row := (others => 1);
      F.Transpose_Slot := (others => 1); Result := Sparse.Invalid_Pattern;
      for R in 1 .. P.N loop
         Cursor (R) := P.Address (R)+P.Length (R)-1;
         Transpose_Write (R) := P.Transpose_Address (R)+1;
         pragma Loop_Invariant (for all Q in 1 .. R =>
           Cursor (Q) = P.Address (Q)+P.Length (Q)-1
           and then Transpose_Write (Q) = P.Transpose_Address (Q)+1);
      end loop;
      for R in reverse 1 .. P.N loop
         pragma Loop_Invariant (for all Q in 1 .. R =>
           Cursor (Q) = P.Address (Q)+P.Length (Q)-1
           and then Transpose_Write (Q) = P.Transpose_Address (Q)+1);
         Parent (R) := 0; Flag (R) := R;
         L_Slot := P.Address (R)+P.Length (R);
         T_Slot := Transpose_Write (R);
         F.Column (L_Slot) := R;
         F.Transpose_Row (T_Slot) := R;
         F.Transpose_Slot (T_Slot) := L_Slot;
         Transpose_Write (R) := T_Slot+1;
         for C in R+1 .. P.N loop
            if H (R, C) then
               I := C;
               while Flag (I) /= R loop
                  pragma Loop_Invariant (I in R+1 .. P.N);
                  pragma Loop_Invariant (Flag (R) = R);
                  pragma Loop_Invariant (for all Q in 1 .. R =>
                    Cursor (Q) = P.Address (Q)+P.Length (Q)-1);
                  pragma Loop_Invariant (for all Q in 1 .. R-1 =>
                    Transpose_Write (Q) = P.Transpose_Address (Q)+1);
                  pragma Loop_Variant (Decreases => I);
                  if Parent (I) = 0 then Parent (I) := R; end if;
                  if Cursor (I) not in P.Address (I)+1 .. P.Address (I)+P.Length (I)-1
                    or else Transpose_Write (R) not in
                      P.Transpose_Address (R)+1 .. P.Transpose_Address (R)+P.Transpose_Length (R)
                  then return; end if;
                  L_Slot := Cursor (I); Cursor (I) := L_Slot-1;
                  T_Slot := Transpose_Write (R); Transpose_Write (R) := T_Slot+1;
                  F.Column (L_Slot) := R;
                  F.Transpose_Row (T_Slot) := I;
                  F.Transpose_Slot (T_Slot) := L_Slot;
                  Flag (I) := R;
                  if Parent (I) not in R .. I-1 then return; end if;
                  I := Parent (I);
               end loop;
            end if;
            pragma Loop_Invariant (Flag (R) = R);
            pragma Loop_Invariant (for all Q in 1 .. R =>
              Cursor (Q) = P.Address (Q)+P.Length (Q)-1);
            pragma Loop_Invariant (for all Q in 1 .. R-1 =>
              Transpose_Write (Q) = P.Transpose_Address (Q)+1);
         end loop;
      end loop;
      --  Counts and writes must agree. These O(N) checks are pending removal
      --  when the new tree traversal's functional obligations are closed.
      for R in 1 .. P.N loop
         if Cursor (R) /= P.Address (R) or else Transpose_Write (R) /=
           P.Transpose_Address (R)+P.Transpose_Length (R)+1 then return; end if;
      end loop;
      Result := Sparse.Success;
   end Fill_Symbolic;

   procedure Legacy_Pattern (F : Flat_Pattern; P : out Pattern) is
   begin
      P.Length := F.Length; P.Transpose_Length := F.Transpose_Length;
      P.Column := (others => (others => 0));
      P.Transpose_Row := (others => (others => 0));
      P.Transpose_Position := (others => (others => 0));
      for R in 1 .. F.N loop
         for K in 1 .. F.Length (R) loop
            P.Column (R, K) := F.Column (F.Address (R)+K);
            pragma Loop_Invariant (Static => (for all Q in 1 .. K =>
              P.Column (R, Q) = F.Column (F.Address (R)+Q)));
            pragma Loop_Invariant (Static => (for all I in 1 .. R-1 =>
              (for all Q in 1 .. F.Length (I) => P.Column (I, Q) = F.Column (F.Address (I)+Q))));
         end loop;
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all Q in 1 .. F.Length (I) => P.Column (I, Q) = F.Column (F.Address (I)+Q))));
         pragma Loop_Invariant (Static => P.Length = F.Length and then P.Transpose_Length = F.Transpose_Length);
      end loop;
      for R in 1 .. F.N loop
         for K in 1 .. F.Transpose_Length (R) loop
            declare
               T : constant Positive := F.Transpose_Address (R)+K;
               C : constant Positive := F.Transpose_Row (T);
            begin
               P.Transpose_Row (R, K) := C;
               P.Transpose_Position (R, K) := F.Transpose_Slot (T)-F.Address (C);
            end;
            pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
              (for all Q in 1 .. F.Length (I) => P.Column (I, Q) = F.Column (F.Address (I)+Q))));
            pragma Loop_Invariant (Static => (for all Q in 1 .. K =>
              P.Transpose_Row (R, Q) = F.Transpose_Row (F.Transpose_Address (R)+Q)
              and then F.Transpose_Slot (F.Transpose_Address (R)+Q) =
                F.Address (P.Transpose_Row (R, Q))+P.Transpose_Position (R, Q)));
            pragma Loop_Invariant (Static => (for all I in 1 .. R-1 =>
              (for all Q in 1 .. F.Transpose_Length (I) =>
                P.Transpose_Row (I, Q) = F.Transpose_Row (F.Transpose_Address (I)+Q)
                and then F.Transpose_Slot (F.Transpose_Address (I)+Q) =
                  F.Address (P.Transpose_Row (I, Q))+P.Transpose_Position (I, Q))));
         end loop;
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all Q in 1 .. F.Length (I) => P.Column (I, Q) = F.Column (F.Address (I)+Q))));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all Q in 1 .. F.Transpose_Length (I) =>
             P.Transpose_Row (I, Q) = F.Transpose_Row (F.Transpose_Address (I)+Q)
             and then F.Transpose_Slot (F.Transpose_Address (I)+Q) =
               F.Address (P.Transpose_Row (I, Q))+P.Transpose_Position (I, Q))));
         pragma Loop_Invariant (Static => P.Length = F.Length and then P.Transpose_Length = F.Transpose_Length);
      end loop;
   end Legacy_Pattern;

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
         and then (if R > 1 then Address (R-1) <= (R-2)*(2*P.N-R+3)/2
           and then Address (R) = Address (R-1)+P.Transpose_Length (R-1))))
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

   procedure Set_Transpose_Offset (P : Pattern; Address : in out Offsets; R : Positive; Value : Natural)
     with Global => null, Inline_Always,
     Pre => (Static => Sparse.Valid (P) and then Address'First = 1 and then Address'Length = P.N
       and then R <= P.N and then Value <= (R-1)*(2*P.N-R+2)/2
       and then Value+P.Transpose_Length (R) <= P.N*(P.N+1)/2
       and then (for all I in 1 .. R-1 => Address (I) <= (I-1)*(2*P.N-I+2)/2
         and then Address (I)+P.Transpose_Length (I) <= P.N*(P.N+1)/2)
       and then (if R > 1 then Value = Address (R-1)+P.Transpose_Length (R-1))
       and then (for all I in 2 .. R-1 => Address (I) = Address (I-1)+P.Transpose_Length (I-1))),
     Post => (Static => Address (R) = Value
       and then (for all I in Address'Range => (if I /= R then Address (I) = Address'Old (I)))
       and then (for all I in 1 .. R => Address (I) <= (I-1)*(2*P.N-I+2)/2
         and then Address (I)+P.Transpose_Length (I) <= P.N*(P.N+1)/2)
       and then (for all I in 2 .. R => Address (I) = Address (I-1)+P.Transpose_Length (I-1)))
   is
   begin
      Address (R) := Value;
   end Set_Transpose_Offset;

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
         Set_Transpose_Offset (P, Address, R, Total);
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



   function Columns_Prefix (P : Pattern; Address : Offsets; Columns : Dof_List;
                            Through : Natural) return Boolean is
     (for all R in 1 .. Through => (for all K in 1 .. P.Length (R) =>
       Columns (Slot (P, Address, R, K)) = P.Column (R, K)))
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then Through <= P.N
       and then Columns'First = 1 and then Columns'Length = P.N*(P.N+1)/2;

   procedure Columns_Prefix_Progress (P : Pattern; Address : Offsets;
                                      Before, After : Dof_List; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then R <= P.N
       and then Before'First = 1 and then Before'Length = P.N*(P.N+1)/2
       and then After'First = 1 and then After'Length = Before'Length
       and then Columns_Prefix (P, Address, Before, R-1)
       and then (for all I in 1 .. R-1 => Address (I)+P.Length (I) <= Address (R))
       and then (for all K in 1 .. P.Length (R) =>
         After (Slot (P, Address, R, K)) = P.Column (R, K))
       and then (for all S in After'Range =>
         (if S <= Address (R) or else S > Address (R)+P.Length (R)
          then After (S) = Before (S))),
     Post => Columns_Prefix (P, Address, After, R)
   is
   begin
      for I in 1 .. R loop
         if I < R then
            for K in 1 .. P.Length (I) loop
               pragma Assert (Slot (P, Address, I, K) <= Address (R));
               pragma Assert (After (Slot (P, Address, I, K)) = Before (Slot (P, Address, I, K)));
               pragma Loop_Invariant (for all J in 1 .. K =>
                 After (Slot (P, Address, I, J)) = P.Column (I, J));
            end loop;
         end if;
         pragma Loop_Invariant (Columns_Prefix (P, Address, After, I));
      end loop;
   end Columns_Prefix_Progress;

   function Transpose_Row_Matches (P : Pattern; Address, Transpose_Address : Offsets;
      Rows : Dof_List; Slots : Offsets; R : Positive) return Boolean is
     ((for all K in 1 .. P.Transpose_Length (R) =>
        Rows (Transpose_Address (R)+K) = P.Transpose_Row (R, K))
       and then (for all K in 1 .. P.Transpose_Length (R) =>
         Slots (Transpose_Address (R)+K) = Address (P.Transpose_Row (R, K))+P.Transpose_Position (R, K)))
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then Valid_Transpose_Offsets (P, Transpose_Address)
       and then R <= P.N and then Rows'First = 1 and then Rows'Length = P.N*(P.N+1)/2
       and then Slots'First = 1 and then Slots'Length = Rows'Length;

   function Transpose_Prefix (P : Pattern; Address, Transpose_Address : Offsets;
                              Rows : Dof_List; Slots : Offsets; Through : Natural) return Boolean is
     (for all R in 1 .. Through => Transpose_Row_Matches (P, Address, Transpose_Address, Rows, Slots, R))
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then Valid_Transpose_Offsets (P, Transpose_Address)
       and then Through <= P.N and then Rows'First = 1 and then Rows'Length = P.N*(P.N+1)/2
       and then Slots'First = 1 and then Slots'Length = Rows'Length;

   procedure Transpose_Prefix_Row (P : Pattern; Address, Transpose_Address : Offsets;
      Rows : Dof_List; Slots : Offsets; Through : Natural; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then Valid_Transpose_Offsets (P, Transpose_Address)
       and then Through <= P.N and then R <= Through
       and then Rows'First = 1 and then Rows'Length = P.N*(P.N+1)/2
       and then Slots'First = 1 and then Slots'Length = Rows'Length
       and then Transpose_Prefix (P, Address, Transpose_Address, Rows, Slots, Through),
     Post => Transpose_Row_Matches (P, Address, Transpose_Address, Rows, Slots, R)
   is
   begin
      for K in 1 .. P.Transpose_Length (R) loop
         pragma Assert (Rows (Transpose_Address (R)+K) = P.Transpose_Row (R, K));
         pragma Assert (Slots (Transpose_Address (R)+K) =
           Address (P.Transpose_Row (R, K))+P.Transpose_Position (R, K));
         pragma Loop_Invariant (for all J in 1 .. K =>
           Rows (Transpose_Address (R)+J) = P.Transpose_Row (R, J));
         pragma Loop_Invariant (for all J in 1 .. K =>
           Slots (Transpose_Address (R)+J) = Address (P.Transpose_Row (R, J))+P.Transpose_Position (R, J));
      end loop;
   end Transpose_Prefix_Row;

   procedure Transpose_Row_Unchanged (P : Pattern; Address, Transpose_Address : Offsets;
      Before_Rows, After_Rows : Dof_List; Before_Slots, After_Slots : Offsets; I, R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then Valid_Transpose_Offsets (P, Transpose_Address)
       and then I < R and then R <= P.N
       and then Before_Rows'First = 1 and then Before_Rows'Length = P.N*(P.N+1)/2
       and then After_Rows'First = 1 and then After_Rows'Length = Before_Rows'Length
       and then Before_Slots'First = 1 and then Before_Slots'Length = Before_Rows'Length
       and then After_Slots'First = 1 and then After_Slots'Length = Before_Rows'Length
       and then Transpose_Row_Matches (P, Address, Transpose_Address, Before_Rows, Before_Slots, I)
       and then Transpose_Address (I)+P.Transpose_Length (I) <= Transpose_Address (R)
       and then (for all S in After_Rows'Range =>
         (if S <= Transpose_Address (R) or else S > Transpose_Address (R)+P.Transpose_Length (R)
          then After_Rows (S) = Before_Rows (S) and then After_Slots (S) = Before_Slots (S))),
     Post => Transpose_Row_Matches (P, Address, Transpose_Address, After_Rows, After_Slots, I)
   is
   begin
      for K in 1 .. P.Transpose_Length (I) loop
         pragma Assert (Transpose_Address (I)+K <= Transpose_Address (R));
         pragma Assert (After_Rows (Transpose_Address (I)+K) = Before_Rows (Transpose_Address (I)+K));
         pragma Assert (After_Slots (Transpose_Address (I)+K) = Before_Slots (Transpose_Address (I)+K));
         pragma Loop_Invariant (for all J in 1 .. K =>
           After_Rows (Transpose_Address (I)+J) = P.Transpose_Row (I, J));
         pragma Loop_Invariant (for all J in 1 .. K =>
           After_Slots (Transpose_Address (I)+J) = Address (P.Transpose_Row (I, J))+P.Transpose_Position (I, J));
      end loop;
   end Transpose_Row_Unchanged;

   procedure Transpose_Prefix_Progress (P : Pattern; Address, Transpose_Address : Offsets;
      Before_Rows, After_Rows : Dof_List; Before_Slots, After_Slots : Offsets; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, Address) and then Valid_Transpose_Offsets (P, Transpose_Address)
       and then R <= P.N
       and then Before_Rows'First = 1 and then Before_Rows'Length = P.N*(P.N+1)/2
       and then After_Rows'First = 1 and then After_Rows'Length = Before_Rows'Length
       and then Before_Slots'First = 1 and then Before_Slots'Length = Before_Rows'Length
       and then After_Slots'First = 1 and then After_Slots'Length = Before_Rows'Length
       and then Transpose_Prefix (P, Address, Transpose_Address, Before_Rows, Before_Slots, R-1)
       and then (for all I in 1 .. R-1 =>
         Transpose_Address (I)+P.Transpose_Length (I) <= Transpose_Address (R))
       and then Transpose_Row_Matches (P, Address, Transpose_Address, After_Rows, After_Slots, R)
       and then (for all S in After_Rows'Range =>
         (if S <= Transpose_Address (R) or else S > Transpose_Address (R)+P.Transpose_Length (R)
          then After_Rows (S) = Before_Rows (S) and then After_Slots (S) = Before_Slots (S))),
     Post => Transpose_Prefix (P, Address, Transpose_Address, After_Rows, After_Slots, R)
   is
   begin
      for I in 1 .. R loop
         if I < R then
            Transpose_Prefix_Row (P, Address, Transpose_Address, Before_Rows, Before_Slots, R-1, I);
            Transpose_Row_Unchanged (P, Address, Transpose_Address,
              Before_Rows, After_Rows, Before_Slots, After_Slots, I, R);
         end if;
         pragma Loop_Invariant (Transpose_Prefix (P, Address, Transpose_Address, After_Rows, After_Slots, I));
      end loop;
   end Transpose_Prefix_Progress;


   procedure Copy_Flat_Transpose (P : Pattern; Address, Transpose_Address : Offsets; R : Positive;
                                  Rows : in out Dof_List; Slots : in out Offsets)
     with Global => null,
     Pre => (Static => Valid_Offsets (P, Address) and then Valid_Transpose_Offsets (P, Transpose_Address)
       and then R <= P.N and then Rows'First = 1 and then Rows'Length = P.N*(P.N+1)/2
       and then Slots'First = 1 and then Slots'Length = Rows'Length),
     Post => (Static => Transpose_Row_Matches (P, Address, Transpose_Address, Rows, Slots, R)
       and then (for all K in 1 .. P.Transpose_Length (R) =>
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

   procedure Flat_Column_From_Pattern (P : Pattern; F : Flat_Pattern; R, K : Positive)
     with Ghost => Static, Global => null,
     Pre => Flat_Bounds (F) and then P.N = F.N and then R <= P.N
       and then F.Stored = P.N*(P.N+1)/2 and then F.Length = P.Length
       and then Valid_Offsets (P, F.Address)
       and then Columns_Prefix (P, F.Address, F.Column, P.N)
       and then K <= P.Length (R),
     Post => F.Column (F.Address (R)+K) = P.Column (R, K)
       and then F.Column (F.Address (R)+K) <= R and then (if K > 1 then
       F.Column (F.Address (R)+K-1) < F.Column (F.Address (R)+K))
   is
   begin
      pragma Assert (F.Column (F.Address (R)+K) = P.Column (R, K));
      if K > 1 then
         pragma Assert (F.Column (F.Address (R)+K-1) = P.Column (R, K-1));
      end if;
   end Flat_Column_From_Pattern;

   procedure Flat_Entry_From_Pattern (P : Pattern; F : Flat_Pattern; R, K : Positive)
     with Ghost => Static, Global => null,
     Pre => Flat_Bounds (F) and then P.N = F.N and then R <= P.N
       and then F.Stored = P.N*(P.N+1)/2
       and then F.Length = P.Length and then F.Transpose_Length = P.Transpose_Length
       and then Valid_Offsets (P, F.Address) and then Valid_Transpose_Offsets (P, F.Transpose_Address)
       and then Columns_Prefix (P, F.Address, F.Column, P.N)
       and then Transpose_Prefix (P, F.Address, F.Transpose_Address, F.Transpose_Row, F.Transpose_Slot, P.N)
       and then K in 2 .. P.Transpose_Length (R),
     Post => Flat_Entry_Valid (F, R, K) and then F.Transpose_Row (F.Transpose_Address (R)+K) = P.Transpose_Row (R, K)
       and then F.Transpose_Slot (F.Transpose_Address (R)+K) =
         Slot (P, F.Address, P.Transpose_Row (R, K), P.Transpose_Position (R, K))
       and then F.Transpose_Row (F.Transpose_Address (R)+K) in R+1 .. F.N
       and then F.Transpose_Slot (F.Transpose_Address (R)+K) in
         F.Address (F.Transpose_Row (F.Transpose_Address (R)+K))+1 ..
         F.Address (F.Transpose_Row (F.Transpose_Address (R)+K))+
           F.Length (F.Transpose_Row (F.Transpose_Address (R)+K))
       and then F.Column (F.Transpose_Slot (F.Transpose_Address (R)+K)) = R
   is
      C : constant Positive := P.Transpose_Row (R, K);
      Position : constant Positive := P.Transpose_Position (R, K);
      S : constant Positive := F.Transpose_Address (R)+K;
   begin
      pragma Assert (F.Transpose_Row (S) = C);
      pragma Assert (F.Transpose_Slot (S) = Slot (P, F.Address, C, Position));
      pragma Assert (F.Column (Slot (P, F.Address, C, Position)) = P.Column (C, Position));
      pragma Assert (F.Column (F.Transpose_Slot (S)) = R);
   end Flat_Entry_From_Pattern;

   procedure Flat_Row_From_Pattern (P : Pattern; F : Flat_Pattern; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Flat_Bounds (F) and then P.N = F.N and then R <= P.N
       and then F.Stored = P.N*(P.N+1)/2
       and then F.Length = P.Length and then F.Transpose_Length = P.Transpose_Length
       and then Valid_Offsets (P, F.Address) and then Valid_Transpose_Offsets (P, F.Transpose_Address)
       and then Columns_Prefix (P, F.Address, F.Column, P.N)
       and then Transpose_Prefix (P, F.Address, F.Transpose_Address, F.Transpose_Row, F.Transpose_Slot, P.N),
     Post => Flat_Row_Valid (F, R)
       and then (for all K in 1 .. P.Length (R) => F.Column (F.Address (R)+K) = P.Column (R, K))
       and then (for all K in 1 .. P.Transpose_Length (R) =>
         F.Transpose_Row (F.Transpose_Address (R)+K) = P.Transpose_Row (R, K)
         and then F.Transpose_Slot (F.Transpose_Address (R)+K) =
           F.Address (P.Transpose_Row (R, K))+P.Transpose_Position (R, K))
   is
   begin
      pragma Assert (F.Column (F.Address (R)+F.Length (R)) = R);
      for K in 1 .. P.Length (R) loop
         Flat_Column_From_Pattern (P, F, R, K);
         pragma Loop_Invariant (for all J in 1 .. K =>
           F.Column (F.Address (R)+J) = P.Column (R, J) and then F.Column (F.Address (R)+J) <= R
           and then (if J > 1 then F.Column (F.Address (R)+J-1) < F.Column (F.Address (R)+J)));
      end loop;
      pragma Assert (F.Transpose_Row (F.Transpose_Address (R)+1) = R);
      pragma Assert (F.Transpose_Slot (F.Transpose_Address (R)+1) = F.Address (R)+F.Length (R));
      for K in 1 .. P.Transpose_Length (R) loop
         if K > 1 then Flat_Entry_From_Pattern (P, F, R, K); end if;
         pragma Loop_Invariant (for all J in 1 .. K =>
           F.Transpose_Row (F.Transpose_Address (R)+J) = P.Transpose_Row (R, J)
           and then F.Transpose_Slot (F.Transpose_Address (R)+J) =
             F.Address (P.Transpose_Row (R, J))+P.Transpose_Position (R, J));
         pragma Loop_Invariant (for all J in 2 .. K => Flat_Entry_Valid (F, R, J));
      end loop;
   end Flat_Row_From_Pattern;


   procedure Flat_Validity (P : Pattern; F : Flat_Pattern)
     with Ghost => Static, Global => null,
     Pre => Valid_Offsets (P, F.Address) and then Valid_Transpose_Offsets (P, F.Transpose_Address)
       and then P.N = F.N and then F.Stored = P.N*(P.N+1)/2
       and then F.Length = P.Length and then F.Transpose_Length = P.Transpose_Length
       and then Valid_Offsets (P, F.Address) and then Valid_Transpose_Offsets (P, F.Transpose_Address)
       and then Columns_Prefix (P, F.Address, F.Column, P.N)
       and then Transpose_Prefix (P, F.Address, F.Transpose_Address, F.Transpose_Row, F.Transpose_Slot, P.N),
     Post => Matches_Flat (P, F)
   is
   begin
      for R in 1 .. P.N loop
         pragma Assert (Slot (P, F.Address, R, P.Length (R)) <= F.Stored);
         pragma Assert (F.Address (R) <= F.Stored-F.Length (R));
         pragma Assert (F.Transpose_Address (R) <= F.Stored-F.Transpose_Length (R));
         pragma Loop_Invariant (for all I in 1 .. R =>
           F.Address (I) <= F.Stored-F.Length (I)
           and then F.Transpose_Address (I) <= F.Stored-F.Transpose_Length (I));
      end loop;
      pragma Assert (Flat_Bounds (F));
      for R in 1 .. P.N loop
         Flat_Row_From_Pattern (P, F, R);
         pragma Assert (Flat_Row_Valid (F, R));
         pragma Loop_Invariant (for all I in 1 .. R => F.Column (F.Address (I)+F.Length (I)) = I);
         pragma Loop_Invariant (for all I in 1 .. R =>
           (for all K in 1 .. F.Length (I) => F.Column (F.Address (I)+K) <= I
             and then (if K > 1 then F.Column (F.Address (I)+K-1) < F.Column (F.Address (I)+K))));
         pragma Loop_Invariant (for all I in 1 .. R => F.Transpose_Row (F.Transpose_Address (I)+1) = I);
         pragma Loop_Invariant (for all I in 1 .. R =>
           F.Transpose_Slot (F.Transpose_Address (I)+1) = F.Address (I)+F.Length (I));
         pragma Loop_Invariant (for all I in 1 .. R =>
           (for all K in 2 .. F.Transpose_Length (I) => Flat_Entry_Valid (F, I, K)));
         pragma Loop_Invariant (for all I in 1 .. R =>
           (for all K in 1 .. P.Length (I) => F.Column (F.Address (I)+K) = P.Column (I, K)));
         pragma Loop_Invariant (for all I in 1 .. R =>
           (for all K in 1 .. P.Transpose_Length (I) =>
             F.Transpose_Row (F.Transpose_Address (I)+K) = P.Transpose_Row (I, K)
             and then F.Transpose_Slot (F.Transpose_Address (I)+K) =
               F.Address (P.Transpose_Row (I, K))+P.Transpose_Position (I, K)));
      end loop;
   end Flat_Validity;


   procedure Build_Flat (P : Pattern; F : out Flat_Pattern) is
   begin
      F.Length := P.Length;
      F.Transpose_Length := P.Transpose_Length;
      F.Column := (others => 1);
      F.Transpose_Row := (others => 1);
      F.Transpose_Slot := (others => 1);
      Build_Offsets (P, F.Address);
      Build_Transpose_Offsets (P, F.Transpose_Address);
      declare
         Saved_Address : constant Offsets := F.Address with Ghost => Static;
         Saved_Transpose_Address : constant Offsets := F.Transpose_Address with Ghost => Static;
         Before_Columns, Before_Rows : Dof_List (1 .. P.N*(P.N+1)/2) with Ghost => Static;
         Before_Slots : Offsets (1 .. P.N*(P.N+1)/2) with Ghost => Static;
      begin
      for R in 1 .. P.N loop
         Prior_Rows (P, F.Address, R);
         Transpose_Prior_Rows (P, F.Transpose_Address, R);
         Before_Columns := F.Column;
         Before_Rows := F.Transpose_Row;
         Before_Slots := F.Transpose_Slot;
         Copy_Flat_Columns (P, F.Address, R, F.Column);
         Columns_Prefix_Progress (P, F.Address, Before_Columns, F.Column, R);
         Copy_Flat_Transpose (P, F.Address, F.Transpose_Address, R, F.Transpose_Row, F.Transpose_Slot);
         Transpose_Prefix_Progress (P, F.Address, F.Transpose_Address,
           Before_Rows, F.Transpose_Row, Before_Slots, F.Transpose_Slot, R);
         pragma Loop_Invariant (Static => F.Address = Saved_Address and then F.Transpose_Address = Saved_Transpose_Address);
         pragma Loop_Invariant (Static => F.Length = P.Length and then F.Transpose_Length = P.Transpose_Length);
         pragma Loop_Invariant (Static => Valid_Offsets (P, F.Address));
         pragma Loop_Invariant (Static => Valid_Transpose_Offsets (P, F.Transpose_Address));
         pragma Loop_Invariant (Static => Columns_Prefix (P, F.Address, F.Column, R));
         pragma Loop_Invariant (Static => Transpose_Prefix
           (P, F.Address, F.Transpose_Address, F.Transpose_Row, F.Transpose_Slot, R));
      end loop;
      end;
      Flat_Validity (P, F);
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

   procedure Flat_Validity_Equivalent (F : Flat_Pattern)
     with Ghost => Static, Global => null,
     Pre => Flat_Bounds (F),
     Post => Valid_Flat (F) = (for all R in 1 .. F.N => Flat_Row_Valid (F, R))
   is
   begin
      if (for all R in 1 .. F.N => Flat_Row_Valid (F, R)) then
         for R in 1 .. F.N loop
            pragma Assert (Flat_Row_Valid (F, R));
            for K in 1 .. F.Length (R) loop
               pragma Assert (F.Column (F.Address (R)+K) <= R);
               pragma Assert (if K > 1 then F.Column (F.Address (R)+K-1) < F.Column (F.Address (R)+K));
               pragma Loop_Invariant (for all Q in 1 .. F.N => Flat_Row_Valid (F, Q));
               pragma Loop_Invariant (for all Q in 1 .. K => F.Column (F.Address (R)+Q) <= R
                 and then (if Q > 1 then F.Column (F.Address (R)+Q-1) < F.Column (F.Address (R)+Q)));
            end loop;
            pragma Loop_Invariant (for all Q in 1 .. F.N => Flat_Row_Valid (F, Q));
            pragma Loop_Invariant (for all I in 1 .. R =>
              (for all Q in 1 .. F.Length (I) => F.Column (F.Address (I)+Q) <= I
                and then (if Q > 1 then F.Column (F.Address (I)+Q-1) < F.Column (F.Address (I)+Q))));
         end loop;
      end if;
   end Flat_Validity_Equivalent;

   procedure Flat_Row_Ordered (F : Flat_Pattern; R, A, B : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N and then A <= B and then B <= F.Length (R),
     Post => F.Column (F.Address (R)+A) <= F.Column (F.Address (R)+B)
       and then (if A < B then F.Column (F.Address (R)+A) < F.Column (F.Address (R)+B)),
     Subprogram_Variant => (Decreases => B)
   is
   begin
      if A < B then Flat_Row_Ordered (F, R, A, B-1); end if;
   end Flat_Row_Ordered;

   procedure Flat_Column_Separate (F : Flat_Pattern; R, Position : Positive)
   is
   begin
      for Q in 1 .. F.Length (R) loop
         if Q < Position then Flat_Row_Ordered (F, R, Q, Position);
         elsif Q > Position then Flat_Row_Ordered (F, R, Position, Q); end if;
         pragma Loop_Invariant (for all K in 1 .. Q =>
           (if K /= Position then F.Column (F.Address (R)+K) /= F.Column (F.Address (R)+Position)));
      end loop;
   end Flat_Column_Separate;

   procedure Flat_Rows_Ordered (F : Flat_Pattern; First, Last : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then First < Last and then Last <= F.N,
     Post => F.Address (First)+F.Length (First) <= F.Address (Last),
     Subprogram_Variant => (Decreases => Last)
   is
   begin
      if First+1 < Last then Flat_Rows_Ordered (F, First, Last-1); end if;
   end Flat_Rows_Ordered;

   procedure Flat_Prior_Rows (F : Flat_Pattern; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N,
     Post => (for all I in 1 .. R-1 => F.Address (I)+F.Length (I) <= F.Address (R))
   is
   begin
      for I in 1 .. R-1 loop
         Flat_Rows_Ordered (F, I, R);
         pragma Loop_Invariant (for all J in 1 .. I =>
           F.Address (J)+F.Length (J) <= F.Address (R));
      end loop;
   end Flat_Prior_Rows;

   procedure Expand_Flat (Values : Vector; F : Flat_Pattern; L : out Matrix) is
   begin
      L := (others => (others => 0.0));
      for R in 1 .. F.N loop
         for K in 1 .. F.Length (R) loop
            Flat_Column_Separate (F, R, K);
            L (R, F.Column (F.Address (R)+K)) := Values (F.Address (R)+K);
            pragma Loop_Invariant (Static => Dense.Bounded (L));
            pragma Loop_Invariant (Static => (for all Q in 1 .. K =>
              L (R, F.Column (F.Address (R)+Q)) = Values (F.Address (R)+Q)));
            pragma Loop_Invariant (Static => (for all I in 1 .. R-1 =>
              (for all Q in 1 .. F.Length (I) =>
                L (I, F.Column (F.Address (I)+Q)) = Values (F.Address (I)+Q))));
         end loop;
         pragma Loop_Invariant (Static => Dense.Bounded (L));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. F.Length (I) =>
             L (I, F.Column (F.Address (I)+K)) = Values (F.Address (I)+K))));
      end loop;
   end Expand_Flat;

   procedure Pack_Flat_Row (L : Matrix; F : Flat_Pattern; R : Positive; Values : in out Vector)
     with Global => null, Inline_Always,
     Pre => (Static => Valid_Flat (F) and then R <= F.N
       and then Dense.Square (L) and then Dense.Bounded (L) and then L'Length (1) = F.N
       and then Values'First = 1 and then Values'Length = F.Stored and then Bounded (Values)
       and then (for all I in 1 .. R-1 => F.Address (I)+F.Length (I) <= F.Address (R))),
     Post => (Static => Bounded (Values)
       and then (for all K in 1 .. F.Length (R) =>
         Values (F.Address (R)+K) = L (R, F.Column (F.Address (R)+K)))
       and then (for all S in Values'Range =>
         (if S <= F.Address (R) or else S > F.Address (R)+F.Length (R)
          then Values (S) = Values'Old (S)))
       and then (for all I in 1 .. R-1 => (for all K in 1 .. F.Length (I) =>
         Values (F.Address (I)+K) = Values'Old (F.Address (I)+K))))
   is
      Before : constant Vector := Values with Ghost => Static;
   begin
      for K in 1 .. F.Length (R) loop
         Values (F.Address (R)+K) := L (R, F.Column (F.Address (R)+K));
         pragma Loop_Invariant (Static => Bounded (Values));
         pragma Loop_Invariant (Static => (for all Q in 1 .. K =>
           Values (F.Address (R)+Q) = L (R, F.Column (F.Address (R)+Q))));
         pragma Loop_Invariant (Static => (for all S in Values'Range =>
           (if S <= F.Address (R) or else S > F.Address (R)+F.Length (R)
            then Values (S) = Before (S))));
         pragma Loop_Invariant (Static => (for all I in 1 .. R-1 =>
           (for all Q in 1 .. F.Length (I) => Values (F.Address (I)+Q) = Before (F.Address (I)+Q))));
      end loop;
   end Pack_Flat_Row;

   procedure Pack_Flat (L : Matrix; F : Flat_Pattern; Values : out Vector) is
   begin
      Values := (others => 0.0);
      for R in 1 .. F.N loop
         Flat_Prior_Rows (F, R);
         Pack_Flat_Row (L, F, R, Values);
         pragma Loop_Invariant (Static => Bounded (Values));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. F.Length (I) =>
             Values (F.Address (I)+K) = L (I, F.Column (F.Address (I)+K)))));
      end loop;
   end Pack_Flat;

   procedure Selected_Step (F : Flat_Pattern; R, J, K : Positive)
   is
   begin
      Flat_Column_Separate (F, R, K);
   end Selected_Step;

   procedure Mass_Value_Progress (Original, Previous, After, Mass : Real;
                                  Was_Selected, Is_Selected, Updated : Boolean)
     with Ghost => Static, Global => null,
     Pre => Original in -1.0e100 .. 1.0e100 and then Mass in -1.0e100 .. 1.0e100
       and then Previous in -2.0e100 .. 2.0e100
       and then Is_Selected = (Was_Selected or Updated) and then not (Was_Selected and Updated)
       and then Previous = (if Was_Selected then Original+Mass else Original)
       and then After = (if Updated then Previous+Mass else Previous),
     Post => After in -2.0e100 .. 2.0e100
       and then After = (if Is_Selected then Original+Mass else Original)
   is
   begin
      if Updated then pragma Assert (Previous = Original); end if;
   end Mass_Value_Progress;

   function Mass_Sum (A, B : Real) return Real is (A+B)
     with Global => null, Inline_Always,
     Pre => (Static => A in -1.0e100 .. 1.0e100 and then B in -1.0e100 .. 1.0e100),
     Post => (Static => Mass_Sum'Result in -2.0e100 .. 2.0e100 and then Mass_Sum'Result = A+B);

   procedure Mass_Prefix_Point (Original, Previous, After, M : Matrix;
                                F : Flat_Pattern; R, K, I, J : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N and then K <= F.Length (R)
       and then I <= F.N and then J <= F.N
       and then Dense.Square (Original) and then Dense.Square (Previous)
       and then Dense.Square (After) and then Dense.Square (M)
       and then Original'Length (1) = F.N and then Previous'Length (1) = F.N
       and then After'Length (1) = F.N and then M'Length (1) = F.N
       and then Original (I, J) in -2.0e100 .. 2.0e100
       and then (if I = R then Original (I, J) in -1.0e100 .. 1.0e100)
       and then M (I, J) in -1.0e100 .. 1.0e100 and then Previous (I, J) in -2.0e100 .. 2.0e100
       and then Previous (I, J) =
         (if I = R and then Row_Selected (F, R, J, K-1) then Original (I, J)+M (I, J) else Original (I, J))
       and then After (I, J) =
         (if I = R and then J = F.Column (F.Address (R)+K) then Previous (I, J)+M (I, J) else Previous (I, J)),
     Post => After (I, J) in -2.0e100 .. 2.0e100 and then After (I, J) =
       (if I = R and then Row_Selected (F, R, J, K) then Original (I, J)+M (I, J) else Original (I, J))
   is
   begin
      if I = R then
         Selected_Step (F, R, J, K);
         Mass_Value_Progress (Original (I, J), Previous (I, J), After (I, J), M (I, J),
           Row_Selected (F, R, J, K-1), Row_Selected (F, R, J, K), J = F.Column (F.Address (R)+K));
      end if;
   end Mass_Prefix_Point;

   procedure Mass_Prefix_Progress (Original, Previous, After, M : Matrix;
                                   F : Flat_Pattern; R, K : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N and then K <= F.Length (R)
       and then Dense.Square (Original) and then Dense.Square (Previous)
       and then Dense.Square (After) and then Dense.Square (M)
       and then Original'Length (1) = F.N and then Previous'Length (1) = F.N
       and then After'Length (1) = F.N and then M'Length (1) = F.N
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N =>
         Original (I, J) in -2.0e100 .. 2.0e100
         and then (if I = R then Original (I, J) in -1.0e100 .. 1.0e100)
         and then M (I, J) in -1.0e100 .. 1.0e100 and then Previous (I, J) in -2.0e100 .. 2.0e100
         and then Previous (I, J) =
           (if I = R and then Row_Selected (F, R, J, K-1) then Original (I, J)+M (I, J) else Original (I, J))
         ))
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N => After (I, J) =
         (if I = R and then J = F.Column (F.Address (R)+K) then Previous (I, J)+M (I, J) else Previous (I, J)))),
     Post => (for all I in 1 .. F.N => (for all J in 1 .. F.N =>
       After (I, J) in -2.0e100 .. 2.0e100 and then After (I, J) =
         (if I = R and then Row_Selected (F, R, J, K) then Original (I, J)+M (I, J) else Original (I, J))))
   is
   begin
      for I in 1 .. F.N loop
         for J in 1 .. F.N loop
            Mass_Prefix_Point (Original, Previous, After, M, F, R, K, I, J);
            pragma Loop_Invariant (for all Q in 1 .. J => After (I, Q) in -2.0e100 .. 2.0e100
              and then After (I, Q) = (if I = R and then Row_Selected (F, R, Q, K)
                then Original (I, Q)+M (I, Q) else Original (I, Q)));
         end loop;
         pragma Loop_Invariant (for all P in 1 .. I => (for all Q in 1 .. F.N =>
           After (P, Q) in -2.0e100 .. 2.0e100 and then After (P, Q) =
             (if P = R and then Row_Selected (F, R, Q, K) then Original (P, Q)+M (P, Q) else Original (P, Q))));
      end loop;
   end Mass_Prefix_Progress;

   procedure Add_Mass_Flat_Row (H : in out Matrix; M : Matrix; F : Flat_Pattern; R : Positive)
     with Global => null, Inline_Always,
     Pre => (Static => Valid_Flat (F) and then R <= F.N
       and then Dense.Square (H) and then Dense.Square (M)
       and then H'Length (1) = F.N and then M'Length (1) = F.N
       and then (for all I in H'Range (1) => (for all J in H'Range (2) => H (I, J) in -2.0e100 .. 2.0e100))
       and then (for all I in M'Range (1) => (for all J in M'Range (2) => M (I, J) in -1.0e100 .. 1.0e100))
       and then (for all J in H'Range (2) => H (R, J) in -1.0e100 .. 1.0e100)),
     Post => (Static => (for all I in 1 .. F.N => (for all J in 1 .. F.N =>
       H (I, J) in -2.0e100 .. 2.0e100))
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N => H (I, J) =
         (if I = R and then Row_Selected (F, R, J, F.Length (R))
          then H'Old (I, J)+M (I, J) else H'Old (I, J)))))
   is
      Before : constant Matrix := H with Ghost => Static;
      Previous : Matrix := H with Ghost => Static;
   begin
      for K in 1 .. F.Length (R) loop
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => H (I, J) in -2.0e100 .. 2.0e100)));
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => H (I, J) =
             (if I = R and then Row_Selected (F, R, J, K-1)
              then Before (I, J)+M (I, J) else Before (I, J)))));
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => M (I, J) in -1.0e100 .. 1.0e100)));
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => Before (I, J) in -2.0e100 .. 2.0e100)));
         pragma Loop_Invariant (Static => (for all J in 1 .. F.N => Before (R, J) in -1.0e100 .. 1.0e100));
         Selected_Step (F, R, F.Column (F.Address (R)+K), K);
         pragma Assert (Static => not Row_Selected (F, R, F.Column (F.Address (R)+K), K-1));
         pragma Assert (Static => H (R, F.Column (F.Address (R)+K)) = Before (R, F.Column (F.Address (R)+K)));
         Previous := H;
         H (R, F.Column (F.Address (R)+K)) :=
           Mass_Sum (H (R, F.Column (F.Address (R)+K)), M (R, F.Column (F.Address (R)+K)));
         Mass_Prefix_Progress (Before, Previous, H, M, F, R, K);
         pragma Assert (Static =>
           (for all I in 1 .. F.N => (for all J in 1 .. F.N =>
             H (I, J) in -2.0e100 .. 2.0e100 and then H (I, J) =
               (if I = R and then Row_Selected (F, R, J, K)
                then Before (I, J)+M (I, J) else Before (I, J)))));
      end loop;
   end Add_Mass_Flat_Row;

   procedure Mass_Row_Point (Original, Previous, After, M : Matrix;
                             F : Flat_Pattern; R, I, J : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N and then I <= F.N and then J <= F.N
       and then Dense.Square (Original) and then Dense.Square (Previous)
       and then Dense.Square (After) and then Dense.Square (M)
       and then Original'Length (1) = F.N and then Previous'Length (1) = F.N
       and then After'Length (1) = F.N and then M'Length (1) = F.N
       and then Original (I, J) in -1.0e100 .. 1.0e100 and then M (I, J) in -1.0e100 .. 1.0e100
       and then Previous (I, J) in -2.0e100 .. 2.0e100
       and then Previous (I, J) =
         (if I < R and then Row_Selected (F, I, J, F.Length (I)) then Original (I, J)+M (I, J) else Original (I, J))
       and then After (I, J) =
         (if I = R and then Row_Selected (F, R, J, F.Length (R)) then Previous (I, J)+M (I, J) else Previous (I, J)),
     Post => After (I, J) in -2.0e100 .. 2.0e100 and then After (I, J) =
       (if I <= R and then Row_Selected (F, I, J, F.Length (I)) then Original (I, J)+M (I, J) else Original (I, J))
   is
   begin
      Mass_Value_Progress (Original (I, J), Previous (I, J), After (I, J), M (I, J),
        I < R and then Row_Selected (F, I, J, F.Length (I)),
        I <= R and then Row_Selected (F, I, J, F.Length (I)),
        I = R and then Row_Selected (F, R, J, F.Length (R)));
   end Mass_Row_Point;

   procedure Mass_Progress_Row (Original, Previous, After, M : Matrix; F : Flat_Pattern; R, I : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N and then I <= F.N
       and then Dense.Square (Original) and then Dense.Square (Previous)
       and then Dense.Square (After) and then Dense.Square (M)
       and then Original'Length (1) = F.N and then Previous'Length (1) = F.N
       and then After'Length (1) = F.N and then M'Length (1) = F.N
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N =>
         Original (I, J) in -1.0e100 .. 1.0e100 and then M (I, J) in -1.0e100 .. 1.0e100
         and then Previous (I, J) in -2.0e100 .. 2.0e100))
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N => Previous (I, J) =
         (if I < R and then Row_Selected (F, I, J, F.Length (I))
          then Original (I, J)+M (I, J) else Original (I, J))))
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N => After (I, J) =
         (if I = R and then Row_Selected (F, R, J, F.Length (R))
          then Previous (I, J)+M (I, J) else Previous (I, J)))),
     Post => (for all J in 1 .. F.N => After (I, J) in -2.0e100 .. 2.0e100
       and then After (I, J) = (if I <= R and then Row_Selected (F, I, J, F.Length (I))
         then Original (I, J)+M (I, J) else Original (I, J)))
   is
   begin
      for J in 1 .. F.N loop
         Mass_Row_Point (Original, Previous, After, M, F, R, I, J);
         pragma Loop_Invariant (for all Q in 1 .. J => After (I, Q) in -2.0e100 .. 2.0e100
           and then After (I, Q) = (if I <= R and then Row_Selected (F, I, Q, F.Length (I))
             then Original (I, Q)+M (I, Q) else Original (I, Q)));
      end loop;
   end Mass_Progress_Row;

   procedure Flat_Mass_Progress (Original, Previous, After, M : Matrix; F : Flat_Pattern; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N
       and then Dense.Square (Original) and then Dense.Square (Previous)
       and then Dense.Square (After) and then Dense.Square (M)
       and then Original'Length (1) = F.N and then Previous'Length (1) = F.N
       and then After'Length (1) = F.N and then M'Length (1) = F.N
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N =>
         Original (I, J) in -1.0e100 .. 1.0e100 and then M (I, J) in -1.0e100 .. 1.0e100
         and then Previous (I, J) in -2.0e100 .. 2.0e100))
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N => Previous (I, J) =
         (if I < R and then Row_Selected (F, I, J, F.Length (I))
          then Original (I, J)+M (I, J) else Original (I, J))))
       and then (for all I in 1 .. F.N => (for all J in 1 .. F.N => After (I, J) =
         (if I = R and then Row_Selected (F, R, J, F.Length (R))
          then Previous (I, J)+M (I, J) else Previous (I, J)))),
     Post => (for all I in 1 .. F.N => (for all J in 1 .. F.N =>
       After (I, J) in -2.0e100 .. 2.0e100 and then After (I, J) =
         (if I <= R and then Row_Selected (F, I, J, F.Length (I))
          then Original (I, J)+M (I, J) else Original (I, J))))
   is
   begin
      for I in 1 .. F.N loop
         Mass_Progress_Row (Original, Previous, After, M, F, R, I);
         pragma Loop_Invariant (for all P in 1 .. I => (for all Q in 1 .. F.N =>
           After (P, Q) in -2.0e100 .. 2.0e100 and then After (P, Q) =
             (if P <= R and then Row_Selected (F, P, Q, F.Length (P))
              then Original (P, Q)+M (P, Q) else Original (P, Q))));
      end loop;
   end Flat_Mass_Progress;

   procedure Add_Mass_Flat (H : in out Matrix; M : Matrix; F : Flat_Pattern) is
      Before : constant Matrix := H with Ghost => Static;
      Previous : Matrix := H with Ghost => Static;
   begin
      for R in 1 .. F.N loop
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => H (I, J) in -2.0e100 .. 2.0e100)));
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => H (I, J) =
             (if I < R and then Row_Selected (F, I, J, F.Length (I))
              then Before (I, J)+M (I, J) else Before (I, J)))));
         pragma Loop_Invariant (Static => (for all I in R .. F.N =>
           (for all J in 1 .. F.N => H (I, J) = Before (I, J))));
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => M (I, J) in -1.0e100 .. 1.0e100)));
         pragma Loop_Invariant (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => Before (I, J) in -1.0e100 .. 1.0e100)));
         Previous := H;
         Add_Mass_Flat_Row (H, M, F, R);
         Flat_Mass_Progress (Before, Previous, H, M, F, R);
         pragma Assert (Static => (for all I in 1 .. F.N =>
           (for all J in 1 .. F.N => H (I, J) in -2.0e100 .. 2.0e100)));
         pragma Assert (Static =>
           (for all I in 1 .. F.N => (for all J in 1 .. F.N => H (I, J) =
               (if I <= R and then Row_Selected (F, I, J, F.Length (I))
                then Before (I, J)+M (I, J) else Before (I, J)))));
      end loop;
   end Add_Mass_Flat;

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
         pragma Loop_Invariant (Static => (for all K in First .. Last =>
           (if K > S then Scratch (Columns (K)) = Before (Columns (K)))));
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

   procedure Factor_Values (H : Vector; F : Flat_Pattern; L : in out Vector;
                          Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) is
      Scratch : Vector (1 .. Max_Dofs) := (others => 0.0);
      Size : constant Positive := F.N;
      Columns : Dof_List renames F.Column;
      C, Last, J : Positive;
      Value, Root, Inverse : Real;
      Deficient : Boolean;
   begin
      Rank := Size; Result := Sparse.Numeric_Limit;
      for R in reverse 1 .. Size loop
         declare
            --  Keep row metadata across writes to L. In C these are local
            --  offsets/pointers; re-reading the discriminated pattern here
            --  otherwise prevents the compiler from retaining its layout.
            First : constant Positive := F.Address (R)+1;
            Diagonal : constant Positive := F.Address (R)+F.Length (R);
            Transpose_First : constant Natural := F.Transpose_Address (R);
            Transpose_Count : constant Natural := F.Transpose_Length (R);
         begin
            for S in First .. Diagonal loop
               J := Columns (S); Scratch (J) := H (S);
            end loop;
            for K in 2 .. Transpose_Count loop
               C := F.Transpose_Row (Transpose_First+K);
               Last := F.Transpose_Slot (Transpose_First+K);
               Flat_Update_Row (L, Columns, F.Address (C)+1, Last, Scratch, (Size-R)*Max_Dofs+K-1);
            end loop;
            Value := Scratch (R); Deficient := Value < Floor;
            if Deficient then Value := Floor; Rank := Rank-1; end if;
            Root := MJ.Quaternion_Math.Sqrt (Value);
            if Root not in Pivot then return; end if;
            Inverse := Dense.Inverse_Pivot (Root);
            for S in First .. Diagonal-1 loop
               Value := (if Deficient then 0.0 else Sparse.Scale (Scratch (Columns (S)), Inverse));
               if Value not in Operand then return; end if;
               L (S) := Value;
            end loop;
            L (Diagonal) := Root;
            for S in First .. Diagonal loop Scratch (Columns (S)) := 0.0; end loop;
         end;
         pragma Loop_Invariant (Static => Bounded (L));
         pragma Loop_Invariant (Rank in R-1 .. F.N);
      end loop;
      Result := Sparse.Success;
   end Factor_Values;

   function Mass_Value_Sum (Left, Right : Real) return Real
     with Global => null, Inline_Always,
     Pre => (Static => Left in Operand and then Right in Operand),
     Post => Mass_Value_Sum'Result = Left+Right
       and then Mass_Value_Sum'Result in -2.0e120 .. 2.0e120
   is
   begin
      return Left+Right;
   end Mass_Value_Sum;

   procedure Flat_Following_Rows (F : Flat_Pattern; R : Positive)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N,
     Post => (for all I in R+1 .. F.N => F.Address (R)+F.Length (R) <= F.Address (I))
   is
   begin
      for I in R+1 .. F.N loop
         Flat_Rows_Ordered (F, R, I);
         pragma Loop_Invariant (for all J in R+1 .. I =>
           F.Address (R)+F.Length (R) <= F.Address (J));
      end loop;
   end Flat_Following_Rows;

   procedure Mass_Values_Progress
     (M : Matrix; F : Flat_Pattern; R : Positive;
      Original, Previous, After : Vector; Adding : Boolean)
     with Ghost => Static, Global => null,
     Pre => Valid_Flat (F) and then R <= F.N and then Dense.Square (M)
       and then Dense.Bounded (M) and then M'Length (1) = F.N
       and then Original'First = 1 and then Original'Length = F.Stored and then Bounded (Original)
       and then Previous'First = 1 and then Previous'Length = F.Stored
       and then After'First = 1 and then After'Length = F.Stored
       and then (for all I in 1 .. R-1 => F.Address (I)+F.Length (I) <= F.Address (R))
       and then (for all I in 1 .. R-1 => (for all K in 1 .. F.Length (I) =>
         Previous (F.Address (I)+K) =
           (if Adding then Original (F.Address (I)+K)+M (I, F.Column (F.Address (I)+K))
            else M (I, F.Column (F.Address (I)+K)))))
       and then (for all K in 1 .. F.Length (R) => After (F.Address (R)+K) =
         (if Adding then Previous (F.Address (R)+K)+M (R, F.Column (F.Address (R)+K))
          else M (R, F.Column (F.Address (R)+K))))
       and then (if Adding then (for all K in 1 .. F.Length (R) =>
         Previous (F.Address (R)+K) = Original (F.Address (R)+K)))
       and then (for all S in After'Range =>
         (if S <= F.Address (R) or else S > F.Address (R)+F.Length (R) then After (S) = Previous (S))),
     Post => (for all I in 1 .. R => (for all K in 1 .. F.Length (I) =>
       After (F.Address (I)+K) =
         (if Adding then Original (F.Address (I)+K)+M (I, F.Column (F.Address (I)+K))
          else M (I, F.Column (F.Address (I)+K)))))
   is
   begin
      for I in 1 .. R loop
         for K in 1 .. F.Length (I) loop
            if I < R then
               pragma Assert (After (F.Address (I)+K) = Previous (F.Address (I)+K));
            elsif Adding then
               pragma Assert (Previous (F.Address (I)+K) = Original (F.Address (I)+K));
            end if;
            pragma Loop_Invariant (for all Q in 1 .. K => After (F.Address (I)+Q) =
              (if Adding then Original (F.Address (I)+Q)+M (I, F.Column (F.Address (I)+Q))
               else M (I, F.Column (F.Address (I)+Q))));
         end loop;
         pragma Loop_Invariant (for all J in 1 .. I => (for all K in 1 .. F.Length (J) =>
           After (F.Address (J)+K) =
             (if Adding then Original (F.Address (J)+K)+M (J, F.Column (F.Address (J)+K))
              else M (J, F.Column (F.Address (J)+K)))));
      end loop;
   end Mass_Values_Progress;

   procedure Load_Mass_Row (M : Matrix; F : Flat_Pattern; R : Positive; H : in out Vector) is
      Before : constant Vector := H with Ghost => Static;
   begin
      for K in 1 .. F.Length (R) loop
         H (F.Address (R)+K) := M (R, F.Column (F.Address (R)+K));
         pragma Loop_Invariant (Static => Valid_Flat (F));
         pragma Loop_Invariant (Static => Bounded (H));
         pragma Loop_Invariant (Static => (for all Q in 1 .. K =>
           H (F.Address (R)+Q) = M (R, F.Column (F.Address (R)+Q))));
         pragma Loop_Invariant (Static => (for all S in H'Range =>
           (if S <= F.Address (R) or else S > F.Address (R)+K then H (S) = Before (S))));
      end loop;
   end Load_Mass_Row;

   procedure Load_Mass_Values (M : Matrix; F : Flat_Pattern; H : out Vector) is
      Original : constant Vector (H'Range) := (others => 0.0) with Ghost => Static;
      Previous : Vector (H'Range) := (others => 0.0) with Ghost => Static;
   begin
      H := (others => 0.0);
      for R in 1 .. F.N loop
         Previous := H;
         Flat_Prior_Rows (F, R);
         Load_Mass_Row (M, F, R, H);
         Mass_Values_Progress (M, F, R, Original, Previous, H, False);
         pragma Loop_Invariant (Static => Valid_Flat (F));
         pragma Loop_Invariant (Static => Bounded (H));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. F.Length (I) => H (F.Address (I)+K) = M (I, F.Column (F.Address (I)+K)))));
      end loop;
   end Load_Mass_Values;

   procedure Add_Mass_Values_Row (M : Matrix; F : Flat_Pattern; R : Positive; H : in out Vector) is
      Before : constant Vector := H with Ghost => Static;
   begin
      for K in 1 .. F.Length (R) loop
         H (F.Address (R)+K) := Mass_Value_Sum (H (F.Address (R)+K), M (R, F.Column (F.Address (R)+K)));
         pragma Loop_Invariant (Static => Valid_Flat (F));
         pragma Loop_Invariant (Static => (for all V of H => V in -2.0e120 .. 2.0e120));
         pragma Loop_Invariant (Static => (for all Q in 1 .. K =>
           H (F.Address (R)+Q) = Before (F.Address (R)+Q)+M (R, F.Column (F.Address (R)+Q))));
         pragma Loop_Invariant (Static => (for all S in H'Range =>
           (if S <= F.Address (R) or else S > F.Address (R)+K then H (S) = Before (S))));
         pragma Loop_Invariant (Static => (for all Q in K+1 .. F.Length (R) => H (F.Address (R)+Q) in Operand));
      end loop;
   end Add_Mass_Values_Row;

   procedure Add_Mass_Values (M : Matrix; F : Flat_Pattern; H : in out Vector) is
      Before : constant Vector := H with Ghost => Static;
      Previous : Vector := H with Ghost => Static;
   begin
      for R in 1 .. F.N loop
         Previous := H;
         Flat_Prior_Rows (F, R);
         Flat_Following_Rows (F, R);
         Add_Mass_Values_Row (M, F, R, H);
         Mass_Values_Progress (M, F, R, Before, Previous, H, True);
         pragma Loop_Invariant (Static => Valid_Flat (F));
         pragma Loop_Invariant (Static => (for all V of H => V in -2.0e120 .. 2.0e120));
         pragma Loop_Invariant (Static => (for all I in 1 .. R =>
           (for all K in 1 .. F.Length (I) => H (F.Address (I)+K) = Before (F.Address (I)+K)+M (I, F.Column (F.Address (I)+K)))));
         pragma Loop_Invariant (Static => (for all I in R+1 .. F.N =>
           (for all K in 1 .. F.Length (I) => H (F.Address (I)+K) = Before (F.Address (I)+K))));
         pragma Loop_Invariant (Static => (for all I in R+1 .. F.N =>
           (for all K in 1 .. F.Length (I) => H (F.Address (I)+K) in Operand)));
      end loop;
   end Add_Mass_Values;

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

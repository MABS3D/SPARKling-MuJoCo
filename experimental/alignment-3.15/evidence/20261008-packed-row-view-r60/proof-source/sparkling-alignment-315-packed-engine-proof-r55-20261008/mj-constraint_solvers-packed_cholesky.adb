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
      First : constant Positive := Slot (P, Address, C, 1);
      Row_L : Vector renames L (First .. Slot (P, Address, C, Position));
      Multiplier : constant Real := L (Slot (P, Address, C, Position));
      J, Q : Positive;
      Value : Real;
   begin
      Bound_Monotone (Budget);
      for S in Row_L'Range loop
         Q := S-First+1;
         Separate_Column (P, C, Q);
         J := P.Column (C, Q);
         pragma Assert (Static => Scratch (J) = Before (J));
         pragma Assert (Static => First+Q-1 = Slot (P, Address, C, Q));
         Value := Sparse.Update (Scratch (J), Multiplier, Row_L (S));
         pragma Assert (Static => Value = Sparse.Headroom_Update
           (Before (J), Multiplier, L (Slot (P, Address, C, Q)), Budget));
         Scratch (J) := Value;
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

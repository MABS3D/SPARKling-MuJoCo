with MJ.Quaternion_Math;
package body MJ.Constraint_Solvers.Sparse_Cholesky with SPARK_Mode is
   procedure Symbolic (H : Mask; P : out Pattern; Result : out Status) is
      N : constant Positive := P.N;
      Parent, Flag : Counts (1 .. N);
      Cursor : Counts (1 .. N) := (others => 0);
      Written : Counts (1 .. N) := (others => 1);
      I, Pos : Natural;
   begin
      Result := Invalid_Pattern;
      P.Length := (others => 1); P.Transpose_Length := (others => 1);
      P.Column := (others => (others => 0));
      P.Transpose_Row := (others => (others => 0));
      P.Transpose_Position := (others => (others => 0));
      for Phase in 1 .. 2 loop
         Parent := (others => 0); Flag := (others => 0);
         if Phase = 2 then
            for R in 1 .. P.N loop
               if P.Length (R) not in 1 .. P.N then return; end if;
               Cursor (R) := P.Length (R)-1;
            end loop;
         end if;
         for R in reverse 1 .. P.N loop
            Parent (R) := 0; Flag (R) := R;
            if Phase = 2 then
               if P.Length (R) not in 1 .. P.N or else Written (R) not in 1 .. P.N then return; end if;
               P.Column (R, P.Length (R)) := R;
               P.Transpose_Row (R, Written (R)) := R;
               P.Transpose_Position (R, Written (R)) := P.Length (R);
               Written (R) := Written (R)+1;
            end if;
            for C in R+1 .. P.N loop
               if H (R, C) then
                  I := C;
                  while I in 1 .. P.N and then Flag (I) /= R loop
                     if I <= R then return; end if;
                     if Parent (I) = 0 then Parent (I) := R; end if;
                     if Phase = 1 then
                        if P.Length (I) >= P.N or else P.Transpose_Length (R) >= P.N then return; end if;
                        P.Length (I) := P.Length (I)+1;
                        P.Transpose_Length (R) := P.Transpose_Length (R)+1;
                     else
                        Pos := Cursor (I);
                        if Pos not in 1 .. P.N or else Written (R) not in 1 .. P.N then return; end if;
                        P.Column (I, Pos) := R;
                        Cursor (I) := Pos-1;
                        P.Transpose_Row (R, Written (R)) := I;
                        P.Transpose_Position (R, Written (R)) := Pos;
                        Written (R) := Written (R)+1;
                     end if;
                     if Parent (I) not in 1 .. I-1 then return; end if;
                     Flag (I) := R; I := Parent (I);
                     pragma Loop_Variant (Decreases => I);
                  end loop;
                  if I not in 1 .. P.N then return; end if;
               end if;
            end loop;
         end loop;
      end loop;
      if not Valid (P) then return; end if;
      Result := Success;
   end Symbolic;

   function Update (Value : Residual; A, B : Operand) return Real is
   begin return Value - A * B; end Update;

   function Scale (Value : Residual; Inverse : Real) return Real is
   begin return Value * Inverse; end Scale;

   --  One CSC contribution, with a component relation and a frame property.
   --  The strictly ordered row indices ensure each target is visited once.
   procedure Update_Row
     (L : Matrix; P : Pattern; C, Position : Positive;
      Scratch : in out Vector; Result : out Status)
     with Global => null, Inline_Always,
     Pre => Valid (P) and then Dense.Square (L) and then Dense.Bounded (L)
       and then L'Length (1) = P.N and then C <= P.N
       and then Position <= P.Length (C)
       and then Scratch'First = 1 and then Scratch'Length = P.N
       and then (for all V of Scratch => V in Residual),
     Post => (Static => (for all V of Scratch => V in Residual)
       and then (if Result = Success then
         (for all K in 1 .. Position => Scratch (P.Column (C, K)) =
           Update (Scratch'Old (P.Column (C, K)),
             L (C, P.Column (C, Position)), L (C, P.Column (C, K))))
         and then (for all J in Scratch'Range =>
           (if (for all K in 1 .. Position => P.Column (C, K) /= J)
            then Scratch (J) = Scratch'Old (J)))))
   is
      Before : constant Vector := Scratch with Ghost => Static;
      R : constant Positive := P.Column (C, Position);
      J : Natural;
      Value : Real;
   begin
      Result := Numeric_Limit;
      for Q in 1 .. Position loop
         J := P.Column (C, Q);
         Value := Update (Scratch (J), L (C, R), L (C, J));
         if Value not in Residual then return; end if;
         Scratch (J) := Value;
         pragma Loop_Invariant (for all V of Scratch => V in Residual);
         pragma Loop_Invariant (Static => (for all K in 1 .. Q =>
           Scratch (P.Column (C, K)) =
             Update (Before (P.Column (C, K)), L (C, R), L (C, P.Column (C, K)))));
         pragma Loop_Invariant (Static => (for all K in Q+1 .. Position =>
           Scratch (P.Column (C, K)) = Before (P.Column (C, K))));
         pragma Loop_Invariant (Static => (for all I in Scratch'Range =>
           (if (for all K in 1 .. Q => P.Column (C, K) /= I)
            then Scratch (I) = Before (I))));
      end loop;
      Result := Success;
   end Update_Row;

   procedure Factor (H : Matrix; P : Pattern; L : out Matrix;
                     Rank : out Natural; Result : out Status; Floor : Pivot := 1.0e-15) is
      Scratch : Vector (1 .. P.N) := (others => 0.0);
      Value, Root, Inverse : Real;
      C, Pos, J : Natural;
      Deficient : Boolean;
   begin
      Result := Numeric_Limit; Rank := P.N;
      L := (others => (others => 0.0));
      for R in reverse 1 .. P.N loop
         --  Scattering all structural factor columns also writes explicit
         --  zero fill slots. The unused upper triangle is never read.
         for K in 1 .. P.Length (R) loop
            J := P.Column (R, K); Scratch (J) := H (R, J);
            pragma Loop_Invariant (for all V of Scratch => V in Residual);
         end loop;
         for K in 2 .. P.Transpose_Length (R) loop
            C := P.Transpose_Row (R, K); Pos := P.Transpose_Position (R, K);
            for Q in 1 .. Pos loop
               J := P.Column (C, Q);
               Value := Update (Scratch (J), L (C, R), L (C, J));
               if Value not in Residual then return; end if;
               Scratch (J) := Value;
               pragma Loop_Invariant (for all V of Scratch => V in Residual);
            end loop;
            pragma Loop_Invariant (for all V of Scratch => V in Residual);
         end loop;
         Value := Scratch (R); Deficient := Value < Floor;
         if Deficient then Value := Floor; Rank := Rank-1; end if;
         Root := MJ.Quaternion_Math.Sqrt (Value);
         if Root not in Pivot then return; end if;
         Inverse := Dense.Inverse_Pivot (Root);
         for K in 1 .. P.Length (R)-1 loop
            J := P.Column (R, K);
            Value := (if Deficient then 0.0 else Scale (Scratch (J), Inverse));
            if Value not in Operand then return; end if;
            L (R, J) := Value;
            pragma Loop_Invariant (Dense.Bounded (L));
            pragma Loop_Invariant (for all I in R+1 .. P.N => L (I, I) in Pivot);
         end loop;
         L (R, R) := Root;
         for K in 1 .. P.Length (R) loop
            Scratch (P.Column (R, K)) := 0.0;
            pragma Loop_Invariant (for all V of Scratch => V in Residual);
         end loop;
         pragma Loop_Invariant (Dense.Bounded (L));
         pragma Loop_Invariant (for all V of Scratch => V in Residual);
         pragma Loop_Invariant (for all I in R .. P.N => L (I, I) in Pivot);
         pragma Loop_Invariant (Rank in R-1 .. P.N);
      end loop;
      Result := Success;
   end Factor;

   procedure Backsolve (L : Matrix; P : Pattern; B : Vector; X : out Vector;
                        Result : out Status) is
      Value, S, S0, S1, S2, S3 : Real;
      J, Offset, Count : Natural;
   begin
      X := B; Result := Numeric_Limit;
      for I in reverse 1 .. P.N loop
         if X (I) /= 0.0 then
            Value := X (I) / L (I, I);
            if Value not in Operand then return; end if;
            X (I) := Value;
            for K in 1 .. P.Length (I)-1 loop
               J := P.Column (I, K);
               Value := Update (X (J), L (I, J), X (I));
               if Value not in Operand then return; end if;
               X (J) := Value;
            end loop;
         end if;
      end loop;
      for I in 1 .. P.N loop
         Count := P.Length (I)-1;
         if Count > 0 then
            S0 := 0.0; S1 := 0.0; S2 := 0.0; S3 := 0.0; Offset := 0;
            --  mju_dotSparse has a sequential scalar tail, unlike mju_dot.
            while Offset+4 <= Count loop
               J := P.Column (I, Offset+1); S0 := S0 + L (I, J)*X (J);
               J := P.Column (I, Offset+2); S1 := S1 + L (I, J)*X (J);
               J := P.Column (I, Offset+3); S2 := S2 + L (I, J)*X (J);
               J := P.Column (I, Offset+4); S3 := S3 + L (I, J)*X (J);
               Offset := Offset+4;
               pragma Loop_Variant (Increases => Offset);
            end loop;
            S := (S0+S2)+(S1+S3);
            for K in Offset+1 .. Count loop
               J := P.Column (I, K); S := S + L (I, J)*X (J);
            end loop;
            Value := X (I)-S;
         else Value := X (I);
         end if;
         Value := Value/L (I, I);
         if Value not in Operand then return; end if;
         X (I) := Value;
      end loop;
      Result := Success;
   end Backsolve;
end MJ.Constraint_Solvers.Sparse_Cholesky;

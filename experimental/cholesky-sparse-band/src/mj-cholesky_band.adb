package body MJ.Cholesky_Band with SPARK_Mode is
   procedure Factor (A : in out Values; N, Band, Dense : Size;
                     Diag_Add, Diag_Mul : Scalar;
                     Min_Pivot : out Scalar; Status : out Outcome) is
      Sparse : constant Size := N - Dense;
      D, Entry_Adr : Offset;
      Width, Height, Overlap : Size;
      Sum, Pivot, Root_Value, Scale, Tmp, Entry_Value : Scalar;
   begin
      Min_Pivot := -1.0; Status := Success;
      for J in 0 .. Integer (N) - 1 loop
         pragma Loop_Invariant (Shape (A, N, Band, Dense));
         pragma Loop_Invariant
           (for all R in 0 .. J - 1 => A (Diagonal (R, N, Band, Dense)) >= Min_Diag);
         D := Diagonal (J, N, Band, Dense);
         if J < Sparse then Width := Size'Min (J, Band - 1);
         else Width := J; end if;
         Dot (A, A, D - Width, D - Width, Width, Sum, Status);
         if Status /= Success then return; end if;
         Add_Product (Diag_Add, Diag_Mul, A (D), Tmp, Status);
         if Status /= Success then return; end if;
         Add_Product (Tmp, 1.0, A (D), Pivot, Status);
         if Status /= Success then return; end if;
         Add_Product (Pivot, -1.0, Sum, Tmp, Status); Pivot := Tmp;
         if Status /= Success then return; end if;
         if Min_Pivot < 0.0 or else Pivot < Min_Pivot then Min_Pivot := Pivot; end if;
         if Pivot < Min_Diag then
            Min_Pivot := 0.0; Status := Not_Positive_Definite; return;
         end if;
         Root (Pivot, Root_Value, Status);
         if Status /= Success then return; end if;
         Divide (1.0, Root_Value, Scale, Status);
         if Status /= Success then return; end if;
         if J < Sparse then Height := Size'Min (Sparse - J - 1, Band - 1);
         else Height := N - J - 1; end if;
         for I in J + 1 .. J + Integer (Height) loop
            pragma Loop_Invariant (Shape (A, N, Band, Dense));
            pragma Loop_Invariant
              (for all R in 0 .. J - 1 => A (Diagonal (R, N, Band, Dense)) >= Min_Diag);
            if J < Sparse then
               Entry_Adr := (I + 1) * Band - 1 - (I - J);
               Overlap := Size'Min (J, Band - 1 - (I - J));
            else
               Entry_Adr := D + N * (I - J); Overlap := J;
            end if;
            Dot (A, A, D - Overlap, Entry_Adr - Overlap, Overlap, Sum, Status);
            if Status /= Success then return; end if;
            Add_Product (A (Entry_Adr), -1.0, Sum, Tmp, Status);
            if Status /= Success then return; end if;
            MJ.Cholesky_Arithmetic.Multiply (Scale, Tmp, Entry_Value, Status);
            if Status /= Success then return; end if;
            A (Entry_Adr) := Entry_Value;
         end loop;
         if J < Sparse then
            for I in Sparse .. Integer (N) - 1 loop
               pragma Loop_Invariant (Shape (A, N, Band, Dense));
               pragma Loop_Invariant
                 (for all R in 0 .. J - 1 => A (Diagonal (R, N, Band, Dense)) >= Min_Diag);
               Entry_Adr := Sparse * Band + (I - Sparse) * N + J;
               Dot (A, A, D - Width, Entry_Adr - Width, Width, Sum, Status);
               if Status /= Success then return; end if;
               Add_Product (A (Entry_Adr), -1.0, Sum, Tmp, Status);
               if Status /= Success then return; end if;
               MJ.Cholesky_Arithmetic.Multiply (Scale, Tmp, Entry_Value, Status);
               if Status /= Success then return; end if;
               A (Entry_Adr) := Entry_Value;
            end loop;
         end if;
         A (D) := Root_Value;
      end loop;
   end Factor;

   procedure Solve (A : Values; RHS : Values; N, Band, Dense : Size;
                    X : out Values; Status : out Outcome) is
      Sparse : constant Size := N - Dense;
      D, E : Offset;
      Width, Height : Size;
      Sum, Tmp : Scalar;
   begin
      X := RHS; Status := Success;
      for I in 0 .. Integer (N) - 1 loop
         D := Diagonal (I, N, Band, Dense);
         if I < Sparse then Width := Size'Min (I, Band - 1);
         else Width := I; end if;
         Dot (A, X, D - Width, I - Width, Width, Sum, Status);
         if Status /= Success then return; end if;
         Add_Product (X (I), -1.0, Sum, Tmp, Status);
         if Status /= Success then return; end if;
         Divide (Tmp, A (D), X (I), Status);
         if Status /= Success then return; end if;
      end loop;
      for I in reverse 0 .. Integer (N) - 1 loop
         D := Diagonal (I, N, Band, Dense);
         if I < Sparse then Height := Size'Min (Sparse - I - 1, Band - 1);
         else Height := N - I - 1; end if;
         for J in I + 1 .. I + Integer (Height) loop
            if I < Sparse then E := (J + 1) * Band - 1 - (J - I);
            else E := Sparse * Band + (J - Sparse) * N + I; end if;
            Add_Product (X (I), -A (E), X (J), Tmp, Status);
            if Status /= Success then return; end if;
            X (I) := Tmp;
         end loop;
         if I < Sparse then
            for J in Sparse .. Integer (N) - 1 loop
               E := Sparse * Band + (J - Sparse) * N + I;
               Add_Product (X (I), -A (E), X (J), Tmp, Status);
               if Status /= Success then return; end if;
               X (I) := Tmp;
            end loop;
         end if;
         Divide (X (I), A (D), Tmp, Status);
         if Status /= Success then return; end if;
         X (I) := Tmp;
      end loop;
   end Solve;

   procedure To_Dense (A : Values; N, Band, Dense : Size; Symmetric : Boolean;
                       Matrix : out Values) is
      Width : Size; D : Offset;
   begin
      Matrix := (others => 0.0);
      for I in 0 .. Integer (N) - 1 loop
         pragma Loop_Invariant
           (for all R in 0 .. Integer (N) - 1 =>
              (for all C in 0 .. Integer (N) - 1 =>
                 (if R < I and then (not Symmetric or else C < I) then
                    Matrix (R * N + C) = Element (A, N, Band, Dense, R, C, Symmetric)
                  else Matrix (R * N + C) = 0.0)));
         D := Diagonal (I, N, Band, Dense);
         if I < N - Dense then Width := Size'Min (I, Band - 1);
         else Width := I; end if;
         for J in I - Width .. I loop
            Matrix (I * N + J) := A (D - (I - J));
            if Symmetric then Matrix (J * N + I) := A (D - (I - J)); end if;
            pragma Loop_Invariant
              (for all R in 0 .. Integer (N) - 1 =>
                 (for all C in 0 .. Integer (N) - 1 =>
                    (if (R < I and then (not Symmetric or else C < I))
                        or else (R = I and then C <= J)
                        or else (Symmetric and then C = I and then R <= J)
                     then Matrix (R * N + C) = Element (A, N, Band, Dense, R, C, Symmetric)
                     else Matrix (R * N + C) = 0.0)));
         end loop;
      end loop;
   end To_Dense;
   procedure From_Dense (Matrix : Values; N, Band, Dense : Size; A : in out Values) is
      Width : Size; D : Offset;
   begin
      From_Dense_Rows : for I in 0 .. Integer (N) - 1 loop
         pragma Loop_Invariant
           (for all K in A'Range =>
              (if Stored (K, N, Band, Dense) and then Storage_Row (K, N, Band, Dense) < I then
                 A (K) = Matrix (Storage_Row (K, N, Band, Dense) * N
                                  + Storage_Column (K, N, Band, Dense))
               else A (K) = A'Loop_Entry (K)));
         D := Diagonal (I, N, Band, Dense);
         if I < N - Dense then Width := Size'Min (I, Band - 1);
         else Width := I; end if;
         Copy (Matrix, I * N + I - Width, A, D - Width, Width + 1);
      end loop From_Dense_Rows;
   end From_Dense;
   procedure Multiply (A, V : Values; N, Band, Dense : Size;
                       Vectors : Size; Symmetric : Boolean;
                       R : out Values; Status : out Outcome) is
      D : Offset; Width : Size; Tmp : Scalar;
   begin
      R := (others => 0.0); Status := Success;
      for K in 0 .. Integer (Vectors) - 1 loop
         for I in 0 .. Integer (N) - 1 loop
            pragma Loop_Invariant (Shape (A, N, Band, Dense));
            D := Diagonal (I, N, Band, Dense);
            if I < N - Dense then Width := Size'Min (I, Band - 1);
            else Width := I; end if;
            Dot (A, V, D - Width, K * N + I - Width, Width + 1, R (K * N + I), Status);
            if Status /= Success then return; end if;
            if Symmetric then
               for J in I - Width .. I - 1 loop
                  Add_Product (R (K * N + J), A (D - (I - J)), V (K * N + I), Tmp, Status);
                  if Status /= Success then return; end if;
                  R (K * N + J) := Tmp;
               end loop;
            end if;
         end loop;
      end loop;
   end Multiply;
end MJ.Cholesky_Band;

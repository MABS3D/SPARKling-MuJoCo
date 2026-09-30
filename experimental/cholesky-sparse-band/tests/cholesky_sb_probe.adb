with Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types;
with MJ.Cholesky_Arithmetic;
with MJ.Cholesky_Band;
with MJ.Cholesky_Sparse;
procedure Cholesky_SB_Probe is
   use Ada.Text_IO;
   use MJ.Cholesky_Arithmetic;
   package Real_IO is new Ada.Text_IO.Float_IO (MJ.Types.Real);
   function Read_Natural return Natural is
      X : Integer;
   begin Ada.Integer_Text_IO.Get (X); return X; end Read_Natural;
   function Read_Real return Scalar is
      X : Scalar;
   begin Real_IO.Get (X); return X; end Read_Real;
   function Read_Values (Length : Natural) return Values is
      A : Values (0 .. Integer (Length) - 1);
   begin for K in A'Range loop A (K) := Read_Real; end loop; return A; end Read_Values;
   function Read_Indices (Length : Natural) return Indices is
      A : Indices (0 .. Integer (Length) - 1);
   begin for K in A'Range loop A (K) := Read_Natural; end loop; return A; end Read_Indices;
   procedure Put_Int (X : Natural) is
   begin Ada.Integer_Text_IO.Put (X, 0); Put (' '); end Put_Int;
   procedure Put_Real (X : Scalar) is
   begin Real_IO.Put (X, Fore => 1, Aft => 17, Exp => 3); Put (' '); end Put_Real;
   procedure Put_Values (A : Values) is
   begin for X of A loop Put_Real (X); end loop; end Put_Values;
   procedure Put_Indices (A : Indices) is
   begin for X of A loop Put_Int (X); end loop; end Put_Indices;
   Op : Natural;
begin
   while not End_Of_File loop
      Op := Read_Natural;
      exit when Op = 0;
      declare
         N : constant Size := Read_Natural;
         Status : Outcome := Success;
      begin
         if Op in 1 .. 5 then
            declare
               Band : constant Size := Read_Natural;
               Dense : constant Size := Read_Natural;
               A : Values := Read_Values (MJ.Cholesky_Band.Storage_Length (N, Band, Dense));
               Pivot : Scalar;
            begin
               case Op is
                  when 1 =>
                     declare
                        Add : constant Scalar := Read_Real;
                        Mul : constant Scalar := Read_Real;
                     begin
                        MJ.Cholesky_Band.Factor (A, N, Band, Dense, Add, Mul, Pivot, Status);
                        Put_Int (Outcome'Pos (Status)); Put_Real (Pivot); Put_Values (A);
                     end;
                  when 2 =>
                     declare
                        RHS : constant Values := Read_Values (N);
                        X : Values (0 .. Integer (N) - 1);
                     begin
                        MJ.Cholesky_Band.Solve (A, RHS, N, Band, Dense, X, Status);
                        Put_Int (Outcome'Pos (Status)); Put_Values (X);
                     end;
                  when 3 =>
                     declare
                        Sym : constant Boolean := Read_Natural /= 0;
                        Matrix : Values (0 .. Integer (N * N) - 1);
                     begin
                        MJ.Cholesky_Band.To_Dense (A, N, Band, Dense, Sym, Matrix);
                        Put_Values (Matrix);
                     end;
                  when 4 =>
                     declare Matrix : constant Values := Read_Values (N * N);
                     begin
                        MJ.Cholesky_Band.From_Dense (Matrix, N, Band, Dense, A); Put_Values (A);
                     end;
                  when 5 =>
                     declare
                        NV : constant Size := Read_Natural;
                        Sym : constant Boolean := Read_Natural /= 0;
                        V : constant Values := Read_Values (N * NV);
                        R : Values (0 .. Integer (N * NV) - 1);
                     begin
                        MJ.Cholesky_Band.Multiply (A, V, N, Band, Dense, NV, Sym, R, Status);
                        Put_Int (Outcome'Pos (Status)); Put_Values (R);
                     end;
                  when others => null;
               end case;
            end;
         elsif Op = 6 then
            declare
               Len : constant Natural := Read_Natural;
               HC : constant Indices := Read_Indices (N);
               HA : constant Indices := Read_Indices (N);
               HI : constant Indices := Read_Indices (Len);
               C, A, TC, TA : Indices (0 .. Integer (N) - 1);
               NNZ : Offset;
            begin
               MJ.Cholesky_Sparse.Symbolic_Count (N, HC, HA, HI, C, A, TC, TA, NNZ);
               declare
                  I, TI, Map : Indices (0 .. Integer (NNZ) - 1);
               begin
                  MJ.Cholesky_Sparse.Symbolic_Fill (N, HC, HA, HI, C, A, TC, TA, I, TI, Map, Status);
                  Put_Int (Outcome'Pos (Status)); Put_Int (NNZ);
                  Put_Indices (C); Put_Indices (A); Put_Indices (I);
                  Put_Indices (TC); Put_Indices (TA); Put_Indices (TI); Put_Indices (Map);
               end;
            end;
         elsif Op in 7 .. 10 then
            declare
               Len : constant Natural := Read_Natural;
               Count : Indices := Read_Indices (N);
               Adr : constant Indices := Read_Indices (N);
               Col : Indices := Read_Indices (Len);
               A : Values := Read_Values (Len);
               Rank : Size;
            begin
               case Op is
                  when 7 =>
                     declare Minimum : constant Scalar := Read_Real;
                     begin
                        MJ.Cholesky_Sparse.Factor (A, N, Count, Adr, Col, Minimum, Rank, Status);
                        Put_Int (Outcome'Pos (Status)); Put_Int (Rank);
                        Put_Indices (Count); Put_Indices (Col); Put_Values (A);
                     end;
                  when 8 =>
                     declare
                        RHS : constant Values := Read_Values (N);
                        X : Values (0 .. Integer (N) - 1);
                     begin
                        MJ.Cholesky_Sparse.Solve (A, RHS, N, Count, Adr, Col, X, Status);
                        Put_Int (Outcome'Pos (Status)); Put_Values (X);
                     end;
                  when 9 =>
                     declare
                        Len_X : constant Natural := Read_Natural;
                        XC : constant Indices := Read_Indices (Len_X);
                        X : constant Values := Read_Values (Len_X);
                        Plus : constant Boolean := Read_Natural /= 0;
                        Work : Values := Read_Values (N);
                     begin
                        MJ.Cholesky_Sparse.Update (A, N, Count, Adr, Col, X, XC, Plus, Work, Rank, Status);
                        Put_Int (Outcome'Pos (Status)); Put_Int (Rank); Put_Values (A); Put_Values (Work);
                     end;
                  when 10 =>
                     declare
                        TC : constant Indices := Read_Indices (N);
                        TA : constant Indices := Read_Indices (N);
                        TI : constant Indices := Read_Indices (Len);
                        Map : constant Indices := Read_Indices (Len);
                        HLen : constant Natural := Read_Natural;
                        HC : constant Indices := Read_Indices (N);
                        HA : constant Indices := Read_Indices (N);
                        HI : constant Indices := Read_Indices (HLen);
                        H : constant Values := Read_Values (HLen);
                        Minimum : constant Scalar := Read_Real;
                        Work : Values := Read_Values (N);
                     begin
                        MJ.Cholesky_Sparse.Numeric (H, N, HC, HA, HI, Count, Adr, Col,
                          TC, TA, TI, Map, Minimum, A, Work, Rank, Status);
                        Put_Int (Outcome'Pos (Status)); Put_Int (Rank); Put_Values (A); Put_Values (Work);
                     end;
                  when others => null;
               end case;
            end;
         elsif Op = 11 then
            --  Rejection paths have no safe C counterpart (C assumes capacity).
            declare
               C : Indices := (0 => 1, 1 => 1, 2 => 3);
               Adr : constant Indices := (0 => 0, 1 => 1, 2 => 2);
               Col : Indices := (0 => 0, 1 => 1, 2 => 0, 3 => 1, 4 => 2);
               A : Values := (0 => 2.0, 1 => 2.0, 2 => 0.2, 3 => 0.3, 4 => 2.0);
               Rank : Size;
            begin
               MJ.Cholesky_Sparse.Factor (A, 3, C, Adr, Col, Min_Diag, Rank, Status);
               Put_Int (Outcome'Pos (Status));
            end;
            declare
               C : constant Indices := (0 => 1, 1 => 1);
               Adr : constant Indices := (0 => 0, 1 => 1);
               Col : constant Indices := (0 => 0, 1 => 1);
               HC : constant Indices := (0 => 1, 1 => 2);
               HA : constant Indices := (0 => 0, 1 => 1);
               HI : constant Indices := (0 => 0, 1 => 0, 2 => 1);
               H : constant Values := (0 => 2.0, 1 => 0.2, 2 => 2.0);
               A, Work : Values (0 .. 1) := (others => 3.75);
               Rank : Size;
            begin
               MJ.Cholesky_Sparse.Numeric (H, 2, HC, HA, HI, C, Adr, Col,
                 C, Adr, Col, Col, Min_Diag, A, Work, Rank, Status);
               Put_Int (Outcome'Pos (Status));
               Put_Int (Boolean'Pos (MJ.Cholesky_Sparse.Update_Closed (2, C, Adr, Col, Col)));
               Put_Int (Boolean'Pos (MJ.Cholesky_Sparse.Update_Closed (2, C, Adr, Col, (0 => 0))));
               Put_Int (Boolean'Pos (MJ.Cholesky_Sparse.CSR_Valid
                 (2, (0 => 0, 1 => 1), Adr, Col, 2, True)));
            end;
            declare
               HC : constant Indices := (0 => 2, 1 => 1);
               HA : constant Indices := (0 => 0, 1 => 2);
               HI : constant Indices := (0 => 0, 1 => 1, 2 => 1);
               C : constant Indices := (0 => 1, 1 => 2);
               A : constant Indices := (0 => 0, 1 => 1);
               TC : constant Indices := (0 => 2, 1 => 1);
               TA : constant Indices := (0 => 0, 1 => 2);
               Col, TI, Map : Indices (0 .. 0);
            begin
               MJ.Cholesky_Sparse.Symbolic_Fill (2, HC, HA, HI, C, A, TC, TA, Col, TI, Map, Status);
               Put_Int (Outcome'Pos (Status));
            end;
         else
            raise Program_Error with "unknown probe operation";
         end if;
         New_Line;
      end;
   end loop;
end Cholesky_SB_Probe;

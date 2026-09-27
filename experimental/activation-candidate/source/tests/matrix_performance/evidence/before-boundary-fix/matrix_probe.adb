with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with MJ.Types; use MJ.Types;
with MJ.BLAS;
with MJ.Matrix_Types; use MJ.Matrix_Types;
with MJ.Matrices; use MJ.Matrices;
procedure Matrix_Probe is
   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   package Int_IO is new Ada.Text_IO.Integer_IO (Integer);
   NR, NC, NK, NI : Integer;
   Transpose_Only : constant Boolean := Ada.Command_Line.Argument_Count = 1
     and then Ada.Command_Line.Argument (1) = "--transpose-only";
   procedure Get (A : out Real_Array) is
   begin
      for X of A loop Real_IO.Get (X); end loop;
   end Get;
   procedure Get (A : out Matrix) is
   begin
      for I in A'Range (1) loop
         for J in A'Range (2) loop Real_IO.Get (A (I, J)); end loop;
      end loop;
   end Get;
   procedure Put (X : Real) is
   begin
      Real_IO.Put (X, Fore => 1, Aft => 17, Exp => 3); Ada.Text_IO.Put (' ');
   end Put;
   procedure Put (A : Real_Array) is
   begin
      for X of A loop Put (X); end loop;
   end Put;
   procedure Put (A : Matrix) is
   begin
      for I in A'Range (1) loop
         for J in A'Range (2) loop Put (A (I, J)); end loop;
      end loop;
   end Put;
begin
   if Ada.Command_Line.Argument_Count /= 0 and then not Transpose_Only then
      raise Constraint_Error;
   end if;
   while not End_Of_File loop
      Int_IO.Get (NR); Int_IO.Get (NC); Int_IO.Get (NK); Int_IO.Get (NI);
      if NR not in 0 .. 128 or NC not in 0 .. 128 or NK not in 0 .. 128 or NI not in 0 .. 128 then
         raise Constraint_Error;
      end if;
      declare
         A : Matrix (0 .. NR - 1, 0 .. NC - 1);
         B : Matrix (0 .. NC - 1, 0 .. NK - 1);
         C : Matrix (0 .. NK - 1, 0 .. NC - 1);
         E : Matrix (0 .. NR - 1, 0 .. NK - 1);
         V : Real_Array (0 .. NC - 1);
         U, D : Real_Array (0 .. NR - 1);
         Ind : Int_Array (0 .. NI - 1);
         RV : Real_Array (U'Range);
         RT : Real_Array (V'Range);
         T : Matrix (0 .. NC - 1, 0 .. NR - 1);
         MM : Matrix (0 .. NR - 1, 0 .. NK - 1);
         TM : Matrix (0 .. NC - 1, 0 .. NK - 1);
         G : Matrix (0 .. NC - 1, 0 .. NC - 1);
         Copy : Matrix (A'Range (1), A'Range (2)) := [others => [others => -7.0]];
      begin
         Get (A); Get (B); Get (C); Get (E); Get (V); Get (U); Get (D);
         for I of Ind loop Int_IO.Get (I); end loop;
         Skip_Line;
         if Transpose_Only then
            Transpose (T, A); Put (T);
         else
            MulMatVec (RV, A, V); Put (RV);
            MulMatTVec (RT, A, U); Put (RT);
            Transpose (T, A); Put (T);
            Eye (G); Put (G);
            CopyRows (Copy, A, Ind); Put (Copy);
            MulMatMat (MM, A, B); Put (MM);
            MulMatMatT (MM, A, C); Put (MM);
            MulMatTMat (TM, A, E); Put (TM);
            SqrMatTD (G, A); Put (G);
            SqrMatTD (G, A, Upper => False); Put (G);
            SqrMatTD (G, A, D); Put (G);
            SqrMatTD (G, A, D, Upper => False); Put (G);
            if NR = NC then
               declare
                  S : Matrix (A'Range (1), A'Range (2));
               begin
                  Symmetrize (S, A); Put (S);
                  Put (MulVecMatVec (U, A, V));
               end;
            end if;
            if NR = 3 and NC = 3 and NK = 3 then
               declare
                  A3 : constant Matrix_3 := A;
                  B3 : constant Matrix_3 := B;
                  V3 : constant MJ.BLAS.Vector_3 := V;
                  R3 : MJ.BLAS.Vector_3;
               begin
                  Put (Copy9 (A3));
                  MulMatVec3 (R3, A3, V3); Put (R3);
                  MulMatTVec3 (R3, A3, V3); Put (R3);
                  Put (MulMatMat3 (A3, B3)); Put (MulMatTMat3 (A3, B3)); Put (MulMatMatT3 (A3, B3));
               end;
            end if;
         end if;
         New_Line;
      end;
   end loop;
end Matrix_Probe;

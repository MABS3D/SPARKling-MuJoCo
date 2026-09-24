with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types;    use MJ.Types;
with MJ.BLAS;     use MJ.BLAS;

--  Differential test I/O, outside SPARK. The first bound exercises Ada slices.
procedure Vector_Probe is
   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   package Int_IO is new Ada.Text_IO.Integer_IO (Integer);
   N, First : Integer;
   procedure Put (X : Real) is
   begin
      Real_IO.Put (X, Fore => 1, Aft => 17, Exp => 3);
      Ada.Text_IO.Put (' ');
   end Put;
   procedure Put (A : Real_Array) is
   begin
      for X of A loop Put (X); end loop;
   end Put;
begin
   while not End_Of_File loop
      Int_IO.Get (N);
      Int_IO.Get (First);
      if N not in 0 .. 4096 or else First < 0 or else First > Integer'Last - N then
         --  The final nonempty component may also be at Integer'Last.
         if N not in 1 .. 4096 or else First < 0 or else First > Integer'Last - (N - 1) then
            raise Constraint_Error;
         end if;
      end if;
      declare
         A, B, R : Real_Array (First .. First + (N - 1));
         Scale : Real;
         Length : Nonnegative_Real;
      begin
         for I in A'Range loop Real_IO.Get (A (I)); end loop;
         for I in B'Range loop Real_IO.Get (B (I)); end loop;
         Real_IO.Get (Scale);
         Skip_Line;
         Zero (R); Put (R);
         Fill (R, Scale); Put (R);
         Copy (R, A); Put (R);
         Scl (R, A, Scale); Put (R);
         Add (R, A, B); Put (R);
         Sub (R, A, B); Put (R);
         R := A; AddTo (R, B); Put (R);
         R := A; SubFrom (R, B); Put (R);
         R := A; AddToScl (R, B, Scale); Put (R);
         AddScl (R, A, B, Scale); Put (R);
         Put (Sum (A)); Put (L1 (A)); Put (Dot (A, B)); Put (Norm (A));
         R := A;
         Length := 0.0;
         if N > 0 then Normalize (R, Length); end if;
         Put (R); Put (Length);
         if N = 3 then
            declare
               X : constant Vector_3 := A;
               Y : constant Vector_3 := B;
               V : Vector_3;
            begin
               Put (Zero3); Put (Copy3 (X));
               Put (Real (Boolean'Pos (Equal3 (X, Y))));
               Put (Add3 (X, Y)); Put (Sub3 (X, Y)); Put (Scl3 (X, Scale));
               Put (AddScl3 (X, Y, Scale));
               V := X; AddTo3 (V, Y); Put (V);
               V := X; SubFrom3 (V, Y); Put (V);
               V := X; AddToScl3 (V, Y, Scale); Put (V);
               Put (Cross3 (X, Y)); Put (Norm3 (X)); Put (Dist3 (X, Y));
               V := X; Normalize3 (V, Length); Put (V); Put (Length);
            end;
         elsif N = 4 then
            declare
               X : constant Vector_4 := A;
               V : Vector_4 := X;
            begin
               Put (Zero4); Put (Unit4); Put (Copy4 (X)); Put (Norm4 (X));
               Normalize4 (V, Length); Put (V); Put (Length);
            end;
         end if;
         New_Line;
      end;
   end loop;
end Vector_Probe;

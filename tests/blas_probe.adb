with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types;    use MJ.Types;
with MJ.BLAS;     use MJ.BLAS;

--  Text protocol used by tools/compare_blas.py. Test I/O is outside SPARK.
procedure BLAS_Probe is
   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   A, B, V : Vector_3;
   Scale   : Real;
   procedure Put (X : Real) is
   begin
      Real_IO.Put (X, Fore => 1, Aft => 17, Exp => 3);
      Ada.Text_IO.Put (' ');
   end Put;
begin
   while not End_Of_File loop
      for I in A'Range loop
         Real_IO.Get (A (I));
      end loop;
      for I in B'Range loop
         Real_IO.Get (B (I));
      end loop;
      Real_IO.Get (Scale);
      Skip_Line;
      V := Add3 (A, B);
      for X of V loop Put (X); end loop;
      V := Sub3 (A, B);
      for X of V loop Put (X); end loop;
      V := Scl3 (A, Scale);
      for X of V loop Put (X); end loop;
      Put (Dot3 (A, B));
      New_Line;
   end loop;
end BLAS_Probe;

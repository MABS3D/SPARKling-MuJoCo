with Ada.Integer_Text_IO;
with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Model_Structures; use MJ.Model_Structures;
procedure Structures_Probe is
   use Ada.Integer_Text_IO;
   Cases, Nrows, Ncols, Nnz, Strict, Lw, La, Lc, Fw, Fa, Fc : Integer;
begin
   Get (Cases);
   for Test in 1 .. Cases loop
      Get (Nrows); Get (Ncols); Get (Nnz); Get (Strict);
      Get (Lw); Get (La); Get (Lc); Get (Fw); Get (Fa); Get (Fc);
      declare
         Widths : Int_Array (Fw .. Fw+Lw-1);
         Addresses : Int_Array (Fa .. Fa+La-1);
         Columns : Int_Array (Fc .. Fc+Lc-1);
         Result : CSR_Result;
      begin
         for V of Widths loop Get (V); end loop;
         for V of Addresses loop Get (V); end loop;
         for V of Columns loop Get (V); end loop;
         Result := Check_CSR (Widths, Addresses, Columns, Nrows, Ncols, Nnz, Strict /= 0);
         Put (CSR_Code'Pos (Result.Code), Width => 0);
         Ada.Text_IO.Put (" ");
         Put (Result.Row, Width => 0);
         Ada.Text_IO.New_Line;
      end;
   end loop;
end Structures_Probe;

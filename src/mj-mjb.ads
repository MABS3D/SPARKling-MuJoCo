--  The .mjb loader (spec 6). Parse_Raw reads the byte image into a Model
--  without judging its contents; Parse adds validation; Load reads the file.
with MJ.Types;           use MJ.Types;
with MJ.Fields;          use MJ.Fields;
with MJ.Models;          use MJ.Models;
with MJ.Models.Validity; use MJ.Models.Validity;
with MJ.Validation;      use MJ.Validation;
with MJ.File_IO;

package MJ.MJB with SPARK_Mode is

   MJB_ID        : constant := 54321;   --  engine_io.c: static const int ID
   MJB_Precision : constant := 8;       --  sizeof(mjtNum)
   Header_Bytes  : constant := 20;      --  five int32

   procedure Parse_Raw (B : Byte_Array; M : in out Model; Result : out Load_Result) with
     Pre  => B'First = 0 and then All_Null (M),
     Post => (if Result.Status = OK then Valid_Layout (M) else All_Null (M));

   --  Parse_Raw followed by validation; the model returned on OK is a Valid_Model.
   procedure Parse (B : Byte_Array; Options : Validate_Options; M : in out Model; Result : out Load_Result) with
     Pre  => B'First = 0 and then All_Null (M),
     Post => (if Result.Status = OK then Valid_Layout (M) and then Is_Valid (M) else All_Null (M));

   procedure Load (Path : String; Options : Validate_Options; M : in out Model; Result : out Load_Result) with
     Global => (In_Out => MJ.File_IO.File_System),
     Pre    => All_Null (M),
     Post   => (if Result.Status = OK then Valid_Layout (M) and then Is_Valid (M) else All_Null (M));

end MJ.MJB;

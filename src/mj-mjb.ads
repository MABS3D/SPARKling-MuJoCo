--  The .mjb loader (spec 6). Parse_Raw reads the byte image into a Model
--  without judging its contents; Parse (Task 9) adds validation.
with MJ.Types;  use MJ.Types;
with MJ.Fields; use MJ.Fields;
with MJ.Models;  use MJ.Models;

package MJ.MJB with SPARK_Mode is

   MJB_ID        : constant := 54321;   --  engine_io.c: static const int ID
   MJB_Precision : constant := 8;       --  sizeof(mjtNum)
   Header_Bytes  : constant := 20;      --  five int32

   procedure Parse_Raw (B : Byte_Array; M : in out Model; Result : out Load_Result) with
     Pre  => B'First = 0 and then All_Null (M),
     Post => (if Result.Status = OK then Valid_Layout (M) else All_Null (M));

end MJ.MJB;

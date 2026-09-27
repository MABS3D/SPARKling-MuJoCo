with Ada.Unchecked_Conversion;

package body MJ.Bytes with SPARK_Mode is

   function Get_U32 (B : Byte_Array; Pos : Natural) return Unsigned_32 is
     (Unsigned_32 (B (Pos))
      or Shift_Left (Unsigned_32 (B (Pos + 1)), 8)
      or Shift_Left (Unsigned_32 (B (Pos + 2)), 16)
      or Shift_Left (Unsigned_32 (B (Pos + 3)), 24));

   function Get_U64 (B : Byte_Array; Pos : Natural) return Unsigned_64 is
     (Unsigned_64 (Get_U32 (B, Pos))
      or Shift_Left (Unsigned_64 (Get_U32 (B, Pos + 4)), 32));

   function Bits_To_Real (U : Unsigned_64) return Real with SPARK_Mode => Off is
      function Conv is new Ada.Unchecked_Conversion (Unsigned_64, Real);
   begin
      return Conv (U);
   end Bits_To_Real;

   function Bits_To_Float (U : Unsigned_32) return Float with SPARK_Mode => Off is
      function Conv is new Ada.Unchecked_Conversion (Unsigned_32, Float);
   begin
      return Conv (U);
   end Bits_To_Float;

end MJ.Bytes;

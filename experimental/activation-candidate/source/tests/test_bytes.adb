with Check;      use Check;
with Interfaces; use Interfaces;
with MJ.Types;   use MJ.Types;
with MJ.Bytes;   use MJ.Bytes;

procedure Test_Bytes is
   B : constant Byte_Array (0 .. 23) :=
     (1, 0, 0, 0,                                   --  int32 1
      16#FF#, 16#FF#, 16#FF#, 16#FF#,               --  int32 -1
      0, 0, 0, 0, 0, 0, 16#F0#, 16#3F#,             --  double 1.0 = 0x3FF0000000000000
      16#FE#, 16#FF#, 16#FF#, 16#FF#, 16#FF#, 16#FF#, 16#FF#, 16#FF#);   --  int64 -2
begin
   Assert_Eq (Get_I32 (B, 0), 1, "little-endian int32 1");
   Assert_Eq (Get_I32 (B, 4), -1, "int32 -1");
   Assert_Eq64 (Get_I64 (B, 16), -2, "int64 -2");
   Assert (Get_U64 (B, 8) = 16#3FF0_0000_0000_0000#, "raw bits of 1.0");
   Assert (Is_Finite_F64 (Get_U64 (B, 8)), "1.0 is finite");
   Assert (Bits_To_Real (Get_U64 (B, 8)) = 1.0, "bits to real 1.0");
   Assert (not Is_Finite_F64 (16#7FF8_0000_0000_0000#), "quiet NaN is not finite");
   Assert (not Is_Finite_F64 (16#7FF0_0000_0000_0000#), "+inf is not finite");
   Assert (not Is_Finite_F64 (16#FFF0_0000_0000_0000#), "-inf is not finite");
   Assert (Is_Finite_F64 (1), "smallest denormal is finite");
   Assert (Is_Finite_F64 (16#7FEF_FFFF_FFFF_FFFF#), "largest double is finite");
   Assert (Bits_To_Real (16#8000_0000_0000_0000#) = 0.0, "-0.0 casts to zero");
   Assert (not Is_Finite_F32 (16#7FC0_0000#), "float NaN is not finite");
   Assert (not Is_Finite_F32 (16#7F80_0000#), "float +inf is not finite");
   Assert (Is_Finite_F32 (16#3F80_0000#) and then Bits_To_Float (16#3F80_0000#) = 1.0, "float 1.0");
   Assert_Eq (To_I32 (16#8000_0000#), Integer'First, "int32 minimum");
   Assert_Eq64 (To_I64 (16#8000_0000_0000_0000#), Int64'First, "int64 minimum");
   Assert_Eq64 (To_I64 (16#7FFF_FFFF_FFFF_FFFF#), Int64'Last, "int64 maximum");
   Report_And_Exit;
end Test_Bytes;

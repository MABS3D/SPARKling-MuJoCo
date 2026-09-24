--  Little-endian decoding of the .mjb byte image and the finiteness tests that
--  keep NaN and infinity out of the engine (spec 6.3).
with Interfaces; use Interfaces;
with MJ.Types;   use MJ.Types;

package MJ.Bytes with SPARK_Mode is

   function Get_U8 (B : Byte_Array; Pos : Natural) return Unsigned_8 is (B (Pos))
     with Pre => Pos in B'Range;

   function Get_U32 (B : Byte_Array; Pos : Natural) return Unsigned_32
     with Pre => Pos in B'Range and then B'Last - Pos >= 3;

   function Get_U64 (B : Byte_Array; Pos : Natural) return Unsigned_64
     with Pre => Pos in B'Range and then B'Last - Pos >= 7;

   --  Two's complement reinterpretation without Unchecked_Conversion.
   function To_I32 (U : Unsigned_32) return Integer is
     (if U >= 2**31 then Integer (Int64 (U) - 2**32) else Integer (U));

   function To_I64 (U : Unsigned_64) return Int64 is
     (if U >= 2**63 then (Int64 (U - 2**63) - 2**62) - 2**62 else Int64 (U));

   function Get_I32 (B : Byte_Array; Pos : Natural) return Integer is (To_I32 (Get_U32 (B, Pos)))
     with Pre => Pos in B'Range and then B'Last - Pos >= 3;

   function Get_I64 (B : Byte_Array; Pos : Natural) return Int64 is (To_I64 (Get_U64 (B, Pos)))
     with Pre => Pos in B'Range and then B'Last - Pos >= 7;

   --  IEEE-754: a pattern is finite exactly when its exponent field is not all ones.
   function Is_Finite_F64 (U : Unsigned_64) return Boolean is
     ((Shift_Right (U, 52) and 16#7FF#) /= 16#7FF#);

   function Is_Finite_F32 (U : Unsigned_32) return Boolean is
     ((Shift_Right (U, 23) and 16#FF#) /= 16#FF#);

   --  The only two SPARK_Mode => Off subprogram bodies in the engine. Their
   --  preconditions exclude every non-finite pattern, so the results are
   --  ordinary finite values and SPARK's finite-float model holds downstream.
   function Bits_To_Real (U : Unsigned_64) return Real
     with Pre => Is_Finite_F64 (U), Global => null;

   function Bits_To_Float (U : Unsigned_32) return Float
     with Pre => Is_Finite_F32 (U), Global => null;

end MJ.Bytes;

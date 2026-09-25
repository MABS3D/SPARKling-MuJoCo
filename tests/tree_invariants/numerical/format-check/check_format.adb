with Ada.Text_IO;
procedure Check_Format is
   pragma Compile_Time_Error
     (Long_Float'Size /= 64 or else Long_Float'Machine_Radix /= 2
      or else Long_Float'Machine_Mantissa /= 53
      or else Long_Float'Model_Epsilon /= 2.0 ** (-52),
      "Tree error certificates require IEEE binary64");
begin
   Ada.Text_IO.Put_Line ("Long_Float: 64 bits, radix 2, 53 significand bits, epsilon 2^-52");
end Check_Format;

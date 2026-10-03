with Ada.Numerics.Long_Elementary_Functions;
package body MJ.Integration_Duals with SPARK_Mode is
   function "+" (A, B : Dual) return Dual is
   begin return (A.Value+B.Value, A.Rate+B.Rate); end "+";
   function "-" (A, B : Dual) return Dual is
   begin return (A.Value-B.Value, A.Rate-B.Rate); end "-";
   function "*" (A, B : Dual) return Dual is
   begin return (A.Value*B.Value, A.Rate*B.Value+A.Value*B.Rate); end "*";
   function Inv (A : Dual) return Dual is
      R : Real;
   begin
      if A.Value <= Min_Val then return (0.0,0.0); end if;
      R := 1.0/A.Value;
      return (R, (-A.Rate*R)*R);
   end Inv;
   function Root (A : Dual) return Dual is
      R : constant Real := Ada.Numerics.Long_Elementary_Functions.Sqrt (A.Value);
   begin
      return (R, (if R = 0.0 then 0.0 else A.Rate/(2.0*R)));
   end Root;
   function Cross (A, B : Triple) return Triple is
   begin return [A (1)*B (2)-A (2)*B (1), A (2)*B (0)-A (0)*B (2), A (0)*B (1)-A (1)*B (0)]; end Cross;
   function Norm (A : Triple) return Dual is
   begin return Root ((A (0)*A (0)+A (1)*A (1))+A (2)*A (2)); end Norm;
end MJ.Integration_Duals;

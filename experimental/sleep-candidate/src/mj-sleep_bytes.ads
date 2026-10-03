with MJ.Types; use MJ.Types;
package MJ.Sleep_Bytes with SPARK_Mode is
   --  Preserve C's byte-zero rule, including signed zero. No imported body,
   --  Assume or SPARK_Mode Off. GNATprove 16.1 currently has an unbound
   --  Float64.copy_sign symbol when this attribute is used in an inlined model;
   --  this unit remains an explicitly open proof boundary, not Gold evidence.
   function Positive_Zero (X : Tier0_Real) return Boolean is
     (X = 0.0 and then Real'Copy_Sign (1.0, X) > 0.0);
end MJ.Sleep_Bytes;

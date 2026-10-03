with MJ.Types; use MJ.Types;
package MJ.Sensor_Kernels with SPARK_Mode is
   subtype Value is Real range -1.0e100 .. 1.0e100;
   subtype Weight is Real range -1.0e40 .. 1.0e40;
   subtype Bound is Real range 0.0 .. 1.0e100;
   subtype Ray_Mask is Natural range 1 .. 63;
   function Range_Width (Mask : Ray_Mask) return Positive
     with Global => null,
       Post => Range_Width'Result in 1 .. 14 and then Range_Width'Result =
         (Mask mod 2) + 3 * ((Mask / 2) mod 2) + 3 * ((Mask / 4) mod 2)
         + 3 * ((Mask / 8) mod 2) + 3 * ((Mask / 16) mod 2) + ((Mask / 32) mod 2);
   function Clip (X : Value; Cutoff : Bound; Datatype, Kind : Natural) return Value
     with Global => null,
       Post => Clip'Result =
         (if Cutoff <= 0.0 or else Kind in 42 | 41 then X
          elsif Datatype = 0 then Real'Max (-Cutoff, Real'Min (Cutoff, X))
          elsif Datatype = 1 then Real'Min (Cutoff, X) else X);
   function Sum3 (A, B, C, X, Y, Z : Weight) return Value
     with Global => null, Post => Sum3'Result = (A * X + B * Y) + C * Z;
   function Relative (V, Reference, Cross_Term : Weight) return Value
     with Global => null, Post => Relative'Result = (V - Reference) + Cross_Term;
   function Accumulate (Total : Value; Coefficient, X : Weight) return Value
     with Global => null, Pre => abs Total <= 1.0e99,
       Post => Accumulate'Result = Total + Coefficient * X;
   function Projection (X, Z, Focal, Center : Weight) return Value
     with Global => null, Pre => abs Z >= 1.0e-15,
       Post => Projection'Result = Focal * (X / Z) + Center;
end MJ.Sensor_Kernels;

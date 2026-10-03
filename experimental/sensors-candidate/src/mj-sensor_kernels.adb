package body MJ.Sensor_Kernels with SPARK_Mode is
   function Range_Width (Mask : Ray_Mask) return Positive is
     ((Mask mod 2) + 3 * ((Mask / 2) mod 2) + 3 * ((Mask / 4) mod 2)
      + 3 * ((Mask / 8) mod 2) + 3 * ((Mask / 16) mod 2) + ((Mask / 32) mod 2));
   function Clip (X : Value; Cutoff : Bound; Datatype, Kind : Natural) return Value is
   begin
      if Cutoff <= 0.0 or else Kind in 42 | 41 then return X;
      elsif Datatype = 0 then return Real'Max (-Cutoff, Real'Min (Cutoff, X));
      elsif Datatype = 1 then return Real'Min (Cutoff, X);
      else return X; end if;
   end Clip;
   function Sum3 (A, B, C, X, Y, Z : Weight) return Value is
   begin return (A * X + B * Y) + C * Z; end Sum3;
   function Relative (V, Reference, Cross_Term : Weight) return Value is
   begin return (V - Reference) + Cross_Term; end Relative;
   function Accumulate (Total : Value; Coefficient, X : Weight) return Value is
   begin return Total + Coefficient * X; end Accumulate;
   function Projection (X, Z, Focal, Center : Weight) return Value is
   begin return Focal * (X / Z) + Center; end Projection;
end MJ.Sensor_Kernels;

package body MJ.Plugin_Protocol with SPARK_Mode is
   function Cutoff (X : Value; Limit : Value; Positive : Boolean) return Value is
     (if Limit = 0.0 then X
      elsif Positive then Real'Min (Limit, X)
      else Real'Max (-Limit, Real'Min (Limit, X)));
   procedure Add (A, B : Value; Sum : in out Value; Accepted : out Boolean) is
      V : constant Real := A + B;
   begin
      Accepted := V in Value;
      if Accepted then Sum := V; end if;
   end Add;
   procedure Multiply (A, B : Value; Product : in out Value; Accepted : out Boolean) is
      V : constant Real := A * B;
   begin
      Accepted := V in Value;
      if Accepted then Product := V; end if;
   end Multiply;
end MJ.Plugin_Protocol;

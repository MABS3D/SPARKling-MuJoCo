package body MJ.Inverse_Kernels with SPARK_Mode is
   function Product (Coefficient, Acceleration : Real) return Real is
     (Coefficient * Acceleration);
   function Accumulate (Previous, Coefficient, Acceleration : Real) return Real is
     (Previous + Coefficient * Acceleration);
   function Required (Inertial, Bias, Gravity, Passive, Constraint : Real) return Real is
     ((Bias - Gravity) + ((Inertial - Passive) - Constraint));
   procedure Initialize_Entry
     (Values : in out Real_Array; Index : Natural; Coefficient, Acceleration : Real) is
   begin
      Values (Index) := Product (Coefficient, Acceleration);
   end Initialize_Entry;
   procedure Scatter (Values : in out Real_Array; Index : Natural;
                      Coefficient, Acceleration : Real; Accepted : out Boolean) is
      Candidate : constant Real := Accumulate (Values (Index), Coefficient, Acceleration);
   begin
      Accepted := Candidate in -1.0e100 .. 1.0e100;
      if Accepted then Values (Index) := Candidate; end if;
   end Scatter;
end MJ.Inverse_Kernels;

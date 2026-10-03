package body MJ.Derivative_Kernels with SPARK_Mode is
   function Scaled_Difference (Left, Right : Operand; Scale : Reciprocal)
     return Slope is (Scale * (Right - Left));
   function Smooth_Force (Actuator, Passive, Bias : Operand) return Real is
     ((Actuator + Passive) - Bias);
   function Control_Stencil
     (Value : Operand; Eps : Increment; Is_Limited, Centered : Boolean;
      Low, High : Operand) return Stencil
   is
      Plus : constant Boolean := not Is_Limited or else
        Within (Value, Value + Eps, Low, High);
      Minus : constant Boolean := (Centered or else not Plus) and then
        (not Is_Limited or else Within (Value - Eps, Value, Low, High));
   begin
      return (if Plus and Minus then Central elsif Plus then Forward
              elsif Minus then Backward else Zero);
   end Control_Stencil;
   procedure Store_Column
     (Target : in out Matrix; Column : Natural; Values : Real_Array) is
   begin
      for R in Target'Range (1) loop
         Target (R, Column) := Values (R);
         pragma Loop_Invariant
           (for all I in Target'First (1) .. R => Target (I, Column) = Values (I));
         pragma Loop_Invariant
           (for all I in Target'Range (1) =>
             (for all C in Target'Range (2) =>
               (if C /= Column then Target (I, C) = Target'Loop_Entry (I, C))));
      end loop;
   end Store_Column;
   procedure Store_Row
     (Target : in out Matrix; Row : Natural; Values : Real_Array) is
   begin
      for C in Target'Range (2) loop
         Target (Row, C) := Values (C);
         pragma Loop_Invariant
           (for all J in Target'First (2) .. C => Target (Row, J) = Values (J));
         pragma Loop_Invariant
           (for all R in Target'Range (1) =>
             (for all J in Target'Range (2) =>
               (if R /= Row then Target (R, J) = Target'Loop_Entry (R, J))));
      end loop;
   end Store_Row;
   procedure Differentiate
     (Left, Right : Real_Array; Scale : Reciprocal; Values : out Real_Array) is
   begin
      Values := [for I in Values'Range =>
        Scaled_Difference (Left (I), Right (I), Scale)];
   end Differentiate;
   function Product_Update (Previous, Coefficient, Value : Real) return Real is
     (Previous + Coefficient * Value);
end MJ.Derivative_Kernels;

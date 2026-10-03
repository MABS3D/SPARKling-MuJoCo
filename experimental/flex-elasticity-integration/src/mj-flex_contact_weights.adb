package body MJ.Flex_Contact_Weights with SPARK_Mode is
   function Distance (A, B : Point) return Real is
      subtype Difference is Real range -2.1e100 .. 2.1e100;
      subtype Square is Real range 0.0 .. 4.5e200;
      X : constant Difference := A (0)-B (0);
      Y : constant Difference := A (1)-B (1);
      Z : constant Difference := A (2)-B (2);
      XX : constant Square := X*X;
      YY : constant Square := Y*Y;
      ZZ : constant Square := Z*Z;
      XY : constant Real range 0.0 .. 9.1e200 := XX+YY;
   begin
      return Ada.Numerics.Long_Elementary_Functions.Sqrt (XY+ZZ);
   end Distance;
   function Inverse_Distance (A, B : Point) return Real is
   begin return 1.0 / Real'Max (Min_Val, Distance (A, B)); end Inverse_Distance;
   function Reciprocal (Sum : Real) return Real
     with Global => null, Pre => Sum in Min_Val .. 4.0e15,
       Post => Reciprocal'Result in 0.0 .. 1.1e15 and then Reciprocal'Result = 1.0/Sum
   is
   begin return 1.0/Sum; end Reciprocal;
   function Scaled_Weight (Value, Scale : Real) return Real
     with Global => null, Pre => Value in 0.0 .. 1.0e15 and Scale in 0.0 .. 1.1e15,
       Post => Scaled_Weight'Result in 0.0 .. 1.2e30 and then Scaled_Weight'Result = Value*Scale
   is
   begin return Value*Scale; end Scaled_Weight;
   procedure Normalize (W : in out Weights; Count : Positive; Success : out Boolean) is
      Sum : constant Real := Ordered_Sum (W, Count);
      Scale : Real;
   begin
      Success := Sum >= Min_Val;
      if not Success then return; end if;
      Scale := Reciprocal (Sum);
      W (1) := Scaled_Weight (W (1),Scale);
      if Count >= 2 then W (2) := Scaled_Weight (W (2),Scale); end if;
      if Count >= 3 then W (3) := Scaled_Weight (W (3),Scale); end if;
      if Count = 4 then W (4) := Scaled_Weight (W (4),Scale); end if;
   end Normalize;
end MJ.Flex_Contact_Weights;

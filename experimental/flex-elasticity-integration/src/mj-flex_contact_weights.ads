with MJ.Types; use MJ.Types;
with Ada.Numerics.Long_Elementary_Functions;
package MJ.Flex_Contact_Weights with SPARK_Mode is
   subtype Axis is Natural range 0 .. 2;
   type Point is array (Axis) of Real;
   type Weights is array (Positive range 1 .. 4) of Real;
   function Bounded (P : Point) return Boolean is
     (for all X of P => X in -1.0e100 .. 1.0e100) with Ghost;
   function Distance (A, B : Point) return Real with Global => null,
     Pre => Bounded (A) and Bounded (B),
     Post => Distance'Result >= 0.0 and then Distance'Result =
       Ada.Numerics.Long_Elementary_Functions.Sqrt
         (((A (0)-B (0))*(A (0)-B (0)) + (A (1)-B (1))*(A (1)-B (1)))
           + (A (2)-B (2))*(A (2)-B (2)));
   function Inverse_Distance (A, B : Point) return Real with Global => null,
     Pre => Bounded (A) and Bounded (B),
     Post => Inverse_Distance'Result in 0.0 .. 1.0e15
       and then Inverse_Distance'Result = 1.0 / Real'Max (Min_Val, Distance (A, B));
   -- The C loop starts at zero and accumulates vertices in element order.
   function Ordered_Sum (W : Weights; Count : Positive) return Real is
     (case Count is
        when 1 => 0.0+W (1),
        when 2 => (0.0+W (1))+W (2),
        when 3 => ((0.0+W (1))+W (2))+W (3),
        when others => (((0.0+W (1))+W (2))+W (3))+W (4))
     with Global => null, Pre => Count <= 4 and (for all X of W => X in 0.0 .. 1.0e15),
       Post => Ordered_Sum'Result in 0.0 .. 4.0e15;
   procedure Normalize (W : in out Weights; Count : Positive; Success : out Boolean)
     with Global => null, Pre => Count <= 4 and (for all X of W => X in 0.0 .. 1.0e15),
       Post => Success = (Ordered_Sum (W'Old, Count) >= Min_Val)
         and then (if Success then
           W (1) = W'Old (1)*(1.0/Ordered_Sum (W'Old,Count))
           and then (if Count >= 2 then W (2) = W'Old (2)*(1.0/Ordered_Sum (W'Old,Count)) else W (2) = W'Old (2))
           and then (if Count >= 3 then W (3) = W'Old (3)*(1.0/Ordered_Sum (W'Old,Count)) else W (3) = W'Old (3))
           and then (if Count = 4 then W (4) = W'Old (4)*(1.0/Ordered_Sum (W'Old,Count)) else W (4) = W'Old (4))
           else W = W'Old);
end MJ.Flex_Contact_Weights;

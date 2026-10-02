with Ada.Numerics.Long_Elementary_Functions;

package body MJ.Rigid_Math with SPARK_Mode is
   function Add (A, B : Vec) return Vec is
     ([A (0)+B (0), A (1)+B (1), A (2)+B (2)]);
   function Sub (A, B : Vec) return Vec is
     ([A (0)-B (0), A (1)-B (1), A (2)-B (2)]);
   function Scale (A : Vec; S : Real) return Vec is
     ([A (0)*S, A (1)*S, A (2)*S]);
   function Dot (A, B : Vec) return Real is
      P0 : constant Tier3_Real := A (0)*B (0);
      P1 : constant Tier3_Real := A (1)*B (1);
      P2 : constant Tier3_Real := A (2)*B (2);
   begin
      return (P0+P1)+P2;
   end Dot;
   function Cross (A, B : Vec) return Vec is
      P0 : constant Tier3_Real := A (1)*B (2);
      P1 : constant Tier3_Real := A (2)*B (1);
      P2 : constant Tier3_Real := A (2)*B (0);
      P3 : constant Tier3_Real := A (0)*B (2);
      P4 : constant Tier3_Real := A (0)*B (1);
      P5 : constant Tier3_Real := A (1)*B (0);
   begin
      return [P0-P1, P2-P3, P4-P5];
   end Cross;
   function Norm (A : Vec) return Real is
     (Ada.Numerics.Long_Elementary_Functions.Sqrt (Dot (A, A)));
   function Unit (A : Vec) return Vec is
      N : constant Real := Norm (A);
   begin
      return (if N < Min_Val then [1.0, 0.0, 0.0] else Scale (A, 1.0/N));
   end Unit;
   function Transform (R : Matrix; A : Vec) return Vec is
     ([Dot ([R (0), R (1), R (2)], A), Dot ([R (3), R (4), R (5)], A), Dot ([R (6), R (7), R (8)], A)]);
   function Local (R : Matrix; A : Vec) return Vec is
     ([Dot ([R (0), R (3), R (6)], A), Dot ([R (1), R (4), R (7)], A), Dot ([R (2), R (5), R (8)], A)]);
end MJ.Rigid_Math;

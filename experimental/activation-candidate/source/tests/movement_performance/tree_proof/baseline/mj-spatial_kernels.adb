package body MJ.Spatial_Kernels with SPARK_Mode is
   function Frame_Offset (Position, Origin : Vector) return Vector is
   begin
      return [Position (0)-Origin (0), Position (1)-Origin (1), Position (2)-Origin (2)];
   end Frame_Offset;
   function Mass_Moment (Mass : Nonneg_Tier0; Position : Vector) return Vector is
   begin
      return [Mass*Position (0), Mass*Position (1), Mass*Position (2)];
   end Mass_Moment;
   function Rotated_Entry (R : Matrix; Diagonal : Vector; Row, Col : Axis) return Real is
      subtype Weighted is Real range -2.0e11 .. 2.0e11;
      X : constant Weighted := R (Col, 0) * Diagonal (0);
      Y : constant Weighted := R (Col, 1) * Diagonal (1);
      Z : constant Weighted := R (Col, 2) * Diagonal (2);
      subtype Product is Real range -4.0e12 .. 4.0e12;
      RX : constant Product := R (Row, 0) * X;
      RY : constant Product := R (Row, 1) * Y;
      RZ : constant Product := R (Row, 2) * Z;
      Pair : constant Real range -9.0e12 .. 9.0e12 := RX + RY;
   begin
      return Pair + RZ;
   end Rotated_Entry;
   function Shift_Diagonal (Rotated : Real; Mass : Nonneg_Tier0; A, B : Real) return Real is
      subtype Square is Real range 0.0 .. 2.0e24;
      AA : constant Square := A * A;
      BB : constant Square := B * B;
      Sum : constant Real range 0.0 .. 5.0e24 := AA + BB;
      Shift : constant Real range 0.0 .. 6.0e34 := Mass * Sum;
   begin
      return Rotated + Shift;
   end Shift_Diagonal;
   function Shift_Offdiagonal (Rotated : Real; Mass : Nonneg_Tier0; A, B : Real) return Real is
      subtype Moment is Real range -2.0e22 .. 2.0e22;
      MA : constant Moment := Mass * A;
      Shift : constant Real range -3.0e34 .. 3.0e34 := MA * B;
   begin
      return Rotated - Shift;
   end Shift_Offdiagonal;
   function Pack_Inertia (E0, E1, E2, E3, E4, E5, E6, E7, E8, E9 : Body_Inertia_Real)
     return Inertia is
   begin
      return [E0, E1, E2, E3, E4, E5, E6, E7, E8, E9];
   end Pack_Inertia;
   function Make_Inertia (R : Matrix; Diagonal : Vector; Mass : Nonneg_Tier0; Offset : Vector)
     return Inertia is
      E0, E1, E2, E3, E4, E5 : Body_Inertia_Real;
      E6 : constant Body_Inertia_Real := Mass * Offset (0);
      E7 : constant Body_Inertia_Real := Mass * Offset (1);
      E8 : constant Body_Inertia_Real := Mass * Offset (2);
   begin
      E0 := Shift_Diagonal (Rotated_Entry (R, Diagonal, 0, 0), Mass, Offset (1), Offset (2));
      pragma Assert (Static => E0 = Shift_Diagonal (Rotated_Entry (R, Diagonal, 0, 0), Mass, Offset (1), Offset (2)));
      E1 := Shift_Diagonal (Rotated_Entry (R, Diagonal, 1, 1), Mass, Offset (0), Offset (2));
      pragma Assert (Static => E1 = Shift_Diagonal (Rotated_Entry (R, Diagonal, 1, 1), Mass, Offset (0), Offset (2)));
      E2 := Shift_Diagonal (Rotated_Entry (R, Diagonal, 2, 2), Mass, Offset (0), Offset (1));
      pragma Assert (Static => E2 = Shift_Diagonal (Rotated_Entry (R, Diagonal, 2, 2), Mass, Offset (0), Offset (1)));
      E3 := Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 0, 1), Mass, Offset (0), Offset (1));
      pragma Assert (Static => E3 = Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 0, 1), Mass, Offset (0), Offset (1)));
      E4 := Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 0, 2), Mass, Offset (0), Offset (2));
      pragma Assert (Static => E4 = Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 0, 2), Mass, Offset (0), Offset (2)));
      E5 := Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 1, 2), Mass, Offset (1), Offset (2));
      pragma Assert (Static => E5 = Shift_Offdiagonal (Rotated_Entry (R, Diagonal, 1, 2), Mass, Offset (1), Offset (2)));
      return Pack_Inertia (E0, E1, E2, E3, E4, E5, E6, E7, E8, Mass);
   end Make_Inertia;
   function Add (A, B : Inertia) return Inertia is
   begin
      return [A (0)+B (0), A (1)+B (1), A (2)+B (2), A (3)+B (3), A (4)+B (4),
              A (5)+B (5), A (6)+B (6), A (7)+B (7), A (8)+B (8), A (9)+B (9)];
   end Add;
   function Angular_Component
     (A, B, C, D, E : Inertia_Real; X, Y, Z, U, V : Motion_Real; Reverse_Signs : Boolean)
     return Product_Real is
      subtype Term is Real range -2.0e52 .. 2.0e52;
      AX : constant Term := A*X;
      BY : constant Term := B*Y;
      CZ : constant Term := C*Z;
      DU : constant Term := D*U;
      EV : constant Term := E*V;
      Pair : constant Real range -5.0e52 .. 5.0e52 := AX + BY;
      Triple : constant Real range -8.0e52 .. 8.0e52 := Pair + CZ;
   begin
      if Reverse_Signs then return (Triple + DU) - EV;
      else return (Triple - DU) + EV; end if;
   end Angular_Component;
   function Linear_Component (A, B, C : Inertia_Real; X, Y, Z : Motion_Real)
     return Product_Real is
      subtype Term is Real range -2.0e52 .. 2.0e52;
      AX : constant Term := A*X;
      BY : constant Term := B*Y;
      CZ : constant Term := C*Z;
   begin
      return (AX - BY) + CZ;
   end Linear_Component;
   function Multiply (I : Inertia; V : Motion) return Motion is
      X : constant Product_Real := Angular_Component
        (I (0), I (3), I (4), I (8), I (7), V (0), V (1), V (2), V (4), V (5), False);
      Y : constant Product_Real := Angular_Component
        (I (3), I (1), I (5), I (8), I (6), V (0), V (1), V (2), V (3), V (5), True);
      Z : constant Product_Real := Angular_Component
        (I (4), I (5), I (2), I (7), I (6), V (0), V (1), V (2), V (3), V (4), False);
      U : constant Product_Real := Linear_Component (I (8), I (7), I (9), V (1), V (2), V (3));
      W : constant Product_Real := Linear_Component (I (6), I (8), I (9), V (2), V (0), V (4));
      T : constant Product_Real := Linear_Component (I (7), I (6), I (9), V (0), V (1), V (5));
   begin
      return [X, Y, Z, U, W, T];
   end Multiply;
   function Dot (A, B : Motion) return Real is
      subtype Product is Real range -2.0e66 .. 2.0e66;
      P0 : constant Product := A (0) * B (0);
      P1 : constant Product := A (1) * B (1);
      P2 : constant Product := A (2) * B (2);
      P3 : constant Product := A (3) * B (3);
      P4 : constant Product := A (4) * B (4);
      P5 : constant Product := A (5) * B (5);
   begin
      return ((P0 + P2) + (P1 + P3))
        + (P4 + P5);
   end Dot;
   function Joint_Motion (Direction, Offset : Vector; Hinge : Boolean) return Motion is
   begin
      if Hinge then
         declare
            X : constant Motion_Real := Direction (1)*Offset (2) - Direction (2)*Offset (1);
            Y : constant Motion_Real := Direction (2)*Offset (0) - Direction (0)*Offset (2);
            Z : constant Motion_Real := Direction (0)*Offset (1) - Direction (1)*Offset (0);
         begin
            return [Direction (0), Direction (1), Direction (2), X, Y, Z];
         end;
      else
         return [0.0, 0.0, 0.0, Direction (0), Direction (1), Direction (2)];
      end if;
   end Joint_Motion;
   function Wrench (Force, Torque, Offset : Vector) return Motion is
      subtype Product is Real range -2.0e52 .. 2.0e52;
      P12 : constant Product := Offset (1)*Force (2);
      P21 : constant Product := Offset (2)*Force (1);
      P20 : constant Product := Offset (2)*Force (0);
      P02 : constant Product := Offset (0)*Force (2);
      P01 : constant Product := Offset (0)*Force (1);
      P10 : constant Product := Offset (1)*Force (0);
   begin
      return [Torque (0) + (P12 - P21), Torque (1) + (P20 - P02),
              Torque (2) + (P01 - P10), Force (0), Force (1), Force (2)];
   end Wrench;
   function Add_Wrenches (A, B : Motion) return Motion is
   begin
      return [A (0)+B (0), A (1)+B (1), A (2)+B (2),
              A (3)+B (3), A (4)+B (4), A (5)+B (5)];
   end Add_Wrenches;
end MJ.Spatial_Kernels;

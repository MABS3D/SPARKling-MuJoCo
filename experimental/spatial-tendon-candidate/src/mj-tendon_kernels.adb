package body MJ.Tendon_Kernels with SPARK_Mode is
   function Polynomial_First (Linear : Nonneg_Tier0; P : Tier0_Real; X : Coordinate)
     return Real is
   begin
      return Linear + P * X;
   end Polynomial_First;
   function Polynomial_Second (P : Tier0_Real; X : Coordinate) return Real is
      X2 : constant Real := X * X;
   begin
      pragma Assert (Static => X2 in 0.0 .. 1.1e60);
      return P * X2;
   end Polynomial_Second;
   function Poly_Value (Linear : Nonneg_Tier0; P : Polynomial;
                        X : Coordinate; Odd : Boolean) return Force_Coefficient is
   begin
      return Polynomial_First (Linear, P (0), (if Odd then abs X else X))
        + Polynomial_Second (P (1), X);
   end Poly_Value;

   procedure Spring_Damper
     (C : Parameters; Length, Velocity : Coordinate;
      Spring_Enabled, Damper_Enabled : Boolean; Spring, Damper : out Tendon_Force)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Displacement);
      X : Coordinate;
   begin
      Spring := 0.0;
      Damper := 0.0;
      if Spring_Enabled and then
        (C.Stiffness /= 0.0 or else C.Spring_Poly /= Polynomial'[0.0, 0.0])
      then
         X := Displacement (Length, C.Lower, C.Upper);
         Spring := -X * Poly_Value (C.Stiffness, C.Spring_Poly, X, False);
      end if;
      if Damper_Enabled and then
        (C.Damping /= 0.0 or else C.Damper_Poly /= Polynomial'[0.0, 0.0])
      then
         Damper := -Velocity * Poly_Value (C.Damping, C.Damper_Poly, Velocity, True);
      end if;
   end Spring_Damper;

   function Sum_Step (Acc : Coordinate; Coefficient, Q : Tier0_Real;
                      Count : Natural) return Coordinate is
   begin
      return Acc + Coefficient * Q;
   end Sum_Step;

   procedure Reduced_Bound (Value : Coordinate; Count : Natural) is
   begin
      pragma Assert (Static => Real (Count) <= Real (Max_Terms));
      pragma Assert (Static => Real (Count) * Step_Bound <= 2.0 ** 84);
   end Reduced_Bound;

   function Dot (R : Row; Q : Real_Array) return Reduced_Coordinate is
      Acc : Coordinate := 0.0;
   begin
      for I in 0 .. R'Length - 1 loop
         Acc := Sum_Step (Acc, R (R'First + I).Coefficient, Q (R (R'First + I).Dof), I);
         pragma Loop_Invariant (abs Acc <= Real (I + 1) * Step_Bound);
         pragma Loop_Invariant (Static => Acc = Reduction (R, Q, I + 1));
      end loop;
      Reduced_Bound (Acc, R'Length);
      return Acc;
   end Dot;

   function Combine (A, B, C, D : Coordinate; Blocks : Natural) return Coordinate is
      AC : constant Real := A + C;
      BD : constant Real := B + D;
   begin
      pragma Assert (Static => abs A <= 2.0 ** 83 and then abs B <= 2.0 ** 83
        and then abs C <= 2.0 ** 83 and then abs D <= 2.0 ** 83);
      pragma Assert (Static => abs AC <= 2.0 ** 84 and then abs BD <= 2.0 ** 84);
      return AC + BD;
   end Combine;
   function Tail_Add (Acc : Coordinate; Coefficient, Q : Tier0_Real; Count : Natural)
     return Coordinate is
   begin
      return Acc + Coefficient * Q;
   end Tail_Add;
   procedure Unfold_Lane (R : Row; Q : Real_Array; Count, Lane : Natural) is
   begin
      null;
   end Unfold_Lane;
   procedure Unfold_Sparse (R : Row; Q : Real_Array; Tail : Natural) is
   begin
      null;
   end Unfold_Sparse;
   procedure Advance_Lane (R : Row; Q : Real_Array; Count, Lane : Natural; Acc : in out Coordinate) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Lane_Value);
      Offset : constant Natural := R'First + (4 * Count + Lane);
   begin
      Unfold_Lane (R, Q, Count, Lane);
      pragma Assert (Static => Sum_Step (Acc, R (Offset).Coefficient, Q (R (Offset).Dof), Count)
        = Lane_Value (R, Q, Count + 1, Lane));
      Acc := Sum_Step (Acc, R (Offset).Coefficient, Q (R (Offset).Dof), Count);
   end Advance_Lane;
   procedure Advance_Tail (R : Row; Q : Real_Array; Count : Natural; Acc : in out Coordinate) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_Model);
      Offset : constant Natural := R'First + (4 * (R'Length / 4) + Count);
   begin
      Unfold_Sparse (R, Q, Count + 1);
      pragma Assert (Static => Tail_Add (Acc, R (Offset).Coefficient, Q (R (Offset).Dof), Count)
        = Sparse_Model (R, Q, Count + 1));
      Acc := Tail_Add (Acc, R (Offset).Coefficient, Q (R (Offset).Dof), Count);
   end Advance_Tail;
   procedure Tail_Bound (Value : Coordinate; Count : Natural) is
   begin
      pragma Assert (Static => Real (Count) <= 3.0);
      pragma Assert (Static => 2.0 ** 85 + Real (Count) * Step_Bound <= 1.0e27);
   end Tail_Bound;
   function Sparse_Dot (R : Row; Q : Real_Array) return Coordinate is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Lane_Value);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Sparse_Model);
      A, B, C, D : Coordinate := 0.0;
      Value : Coordinate;
      Blocks : constant Natural := R'Length / 4;
   begin
      for K in 0 .. Blocks - 1 loop
         Advance_Lane (R, Q, K, 0, A); Advance_Lane (R, Q, K, 1, B);
         Advance_Lane (R, Q, K, 2, C); Advance_Lane (R, Q, K, 3, D);
         pragma Loop_Invariant (abs A <= Real (K + 1) * Step_Bound and then abs B <= Real (K + 1) * Step_Bound
           and then abs C <= Real (K + 1) * Step_Bound and then abs D <= Real (K + 1) * Step_Bound);
         pragma Loop_Invariant (Static => A = Lane_Value (R, Q, K + 1, 0)
           and then B = Lane_Value (R, Q, K + 1, 1) and then C = Lane_Value (R, Q, K + 1, 2)
           and then D = Lane_Value (R, Q, K + 1, 3));
      end loop;
      Unfold_Sparse (R, Q, 0);
      pragma Assert (Static => Combine (A, B, C, D, Blocks) = Sparse_Model (R, Q, 0));
      Value := Combine (A, B, C, D, Blocks);
      for K in 0 .. R'Length mod 4 - 1 loop
         Advance_Tail (R, Q, K, Value);
         pragma Loop_Invariant (abs Value <= 2.0 ** 85 + Real (K + 1) * Step_Bound);
         pragma Loop_Invariant (Static => Value = Sparse_Model (R, Q, K + 1));
      end loop;
      Tail_Bound (Value, R'Length mod 4);
      return Value;
   end Sparse_Dot;

   procedure Fixed_Kinematics
     (Terms, Jacobian : Row; Q, V : Real_Array; Length, Velocity : out Coordinate)
   is
   begin
      Length := Dot (Terms, Q);
      Velocity := Sparse_Dot (Jacobian, V);
   end Fixed_Kinematics;

   function Project (Previous : Real; J : Tier0_Real; Force : Tendon_Force)
     return Real is
   begin
      return Previous + J * Force;
   end Project;

   function Mass_Entry (Previous : Real; Armature : Nonneg_Tier0;
                        Ji, Jj : Tier0_Real) return Real is
   begin
      return Previous + Jj * (Armature * Ji);
   end Mass_Entry;
   function Accumulate_Mass (Previous : Mass_Value; Change : Mass_Change)
     return Mass_Value is
   begin
      return Previous + Change;
   end Accumulate_Mass;
   function Project_Small (Previous : Mass_Value; J : Tier0_Real; Force : Small_Force)
     return Mass_Value is
   begin
      return Previous + J * Force;
   end Project_Small;
end MJ.Tendon_Kernels;

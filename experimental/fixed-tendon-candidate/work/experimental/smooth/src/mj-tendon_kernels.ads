with MJ.Types; use MJ.Types;

--  MuJoCo 3.14.0 tendon arithmetic. No allocation or validation scans in the
--  hot path: the owner validates indices and bounds when constructing a row.
package MJ.Tendon_Kernels with SPARK_Mode is
   Max_Terms : constant := 65_536;
   subtype Coordinate is Real range -1.0e30 .. 1.0e30;
   subtype Reduced_Coordinate is Coordinate range -5.0e29 .. 5.0e29;
   subtype Force_Coefficient is Real range -3.0e70 .. 3.0e70;
   subtype Tendon_Force is Real range -1.0e103 .. 1.0e103;
   type Polynomial is array (0 .. 1) of Tier0_Real;
   type Parameters is record
      Lower, Upper : Tier0_Real := 0.0;
      Stiffness, Damping, Armature : Nonneg_Tier0 := 0.0;
      Spring_Poly, Damper_Poly : Polynomial := [others => 0.0];
   end record;
   type Term is record
      Dof : Natural := 0;
      Coefficient : Tier0_Real := 0.0;
   end record;
   type Row is array (Natural range <>) of Term;

   function Displacement (Length : Coordinate; Lower, Upper : Tier0_Real)
     return Coordinate is
     (if Length > Upper then Length - Upper
      elsif Length < Lower then Length - Lower else 0.0)
     with Global => null, Pre => Lower <= Upper
       and then Length in -5.0e29 .. 5.0e29;

   function Polynomial_First (Linear : Nonneg_Tier0; P : Tier0_Real; X : Coordinate)
     return Real with Global => null,
     Post => Polynomial_First'Result = Linear + P * X
       and then Polynomial_First'Result in -1.2e40 .. 1.2e40;
   function Polynomial_Second (P : Tier0_Real; X : Coordinate) return Real
     with Global => null,
     Post => Polynomial_Second'Result = P * (X * X)
       and then Polynomial_Second'Result in -1.2e70 .. 1.2e70;
   function Poly_Value (Linear : Nonneg_Tier0; P : Polynomial;
                        X : Coordinate; Odd : Boolean) return Force_Coefficient
     with Global => null,
     Post => Poly_Value'Result =
       (Polynomial_First (Linear, P (0), (if Odd then abs X else X))
        + Polynomial_Second (P (1), X));

   function Spring_Model (C : Parameters; Length : Coordinate;
                          Enabled : Boolean) return Tendon_Force is
     (if not Enabled or else
          (C.Stiffness = 0.0 and then C.Spring_Poly = Polynomial'[0.0, 0.0])
      then 0.0 else
        -Displacement (Length, C.Lower, C.Upper) *
          Poly_Value (C.Stiffness, C.Spring_Poly,
                      Displacement (Length, C.Lower, C.Upper), False))
     with Ghost => Static, Global => null,
     Pre => C.Lower <= C.Upper and then Length in -5.0e29 .. 5.0e29;

   function Damper_Model (C : Parameters; Velocity : Coordinate;
                          Enabled : Boolean) return Tendon_Force is
     (if not Enabled or else
          (C.Damping = 0.0 and then C.Damper_Poly = Polynomial'[0.0, 0.0])
      then 0.0 else -Velocity * Poly_Value (C.Damping, C.Damper_Poly, Velocity, True))
     with Ghost => Static, Global => null;

   procedure Spring_Damper
     (C : Parameters; Length, Velocity : Coordinate;
      Spring_Enabled, Damper_Enabled : Boolean; Spring, Damper : out Tendon_Force)
     with Global => null,
     Pre => C.Lower <= C.Upper and then Length in -5.0e29 .. 5.0e29,
     Post => (Static => Spring = Spring_Model (C, Length, Spring_Enabled)
       and then Damper = Damper_Model (C, Velocity, Damper_Enabled));

   function Valid_Row (R : Row; Q : Real_Array) return Boolean is
     (R'Length <= Max_Terms
      and then (for all E of R => E.Dof in Q'Range)
      and then (for all X of Q => X in Tier0_Real)) with Global => null;
   Step_Bound : constant Real := 2.0 ** 68;
   function Sum_Step (Acc : Coordinate; Coefficient, Q : Tier0_Real;
                      Count : Natural) return Coordinate
     with Global => null,
     Pre => Count < Max_Terms and then abs Acc <= Real (Count) * Step_Bound,
     Post => Sum_Step'Result = Acc + Coefficient * Q
       and then abs Sum_Step'Result <= Real (Count + 1) * Step_Bound;
   function Reduction (R : Row; Q : Real_Array; Count : Natural) return Coordinate is
     (if Count = 0 then 0.0 else
        Sum_Step (Reduction (R, Q, Count - 1), R (R'First + (Count - 1)).Coefficient,
                  Q (R (R'First + (Count - 1)).Dof), Count - 1))
     with Ghost => Static, Global => null,
     Pre => Valid_Row (R, Q) and then Count <= R'Length,
     Post => abs Reduction'Result <= Real (Count) * Step_Bound,
     Subprogram_Variant => (Decreases => Count);
   procedure Reduced_Bound (Value : Coordinate; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Count <= Max_Terms and then abs Value <= Real (Count) * Step_Bound,
     Post => Value in Reduced_Coordinate;
   function Dot (R : Row; Q : Real_Array) return Reduced_Coordinate
     with Global => null, Pre => Valid_Row (R, Q),
     Post => (Static => Dot'Result = Reduction (R, Q, R'Length)
       and then abs Dot'Result <= Real (R'Length) * Step_Bound);

   function Lane_Value (R : Row; Q : Real_Array; Count, Lane : Natural) return Coordinate is
     (if Count = 0 then 0.0 else
        Sum_Step (Lane_Value (R, Q, Count - 1, Lane),
          R (R'First + (4 * (Count - 1) + Lane)).Coefficient,
          Q (R (R'First + (4 * (Count - 1) + Lane)).Dof), Count - 1))
     with Ghost => Static, Global => null,
     Pre => Valid_Row (R, Q) and then Lane < 4 and then Count <= R'Length / 4,
     Post => abs Lane_Value'Result <= Real (Count) * Step_Bound
       and then (if Count = 0 then Lane_Value'Result = 0.0),
     Subprogram_Variant => (Decreases => Count);
   function Combine (A, B, C, D : Coordinate; Blocks : Natural) return Coordinate
     with Global => null,
     Pre => Blocks <= Max_Terms / 4
       and then abs A <= Real (Blocks) * Step_Bound and then abs B <= Real (Blocks) * Step_Bound
       and then abs C <= Real (Blocks) * Step_Bound and then abs D <= Real (Blocks) * Step_Bound,
     Post => Combine'Result = (A + C) + (B + D)
       and then abs Combine'Result <= 2.0 ** 85;
   function Tail_Add (Acc : Coordinate; Coefficient, Q : Tier0_Real; Count : Natural)
     return Coordinate with Global => null,
     Pre => Count < 3 and then abs Acc <= 2.0 ** 85 + Real (Count) * Step_Bound,
     Post => Tail_Add'Result = Acc + Coefficient * Q
       and then abs Tail_Add'Result <= 2.0 ** 85 + Real (Count + 1) * Step_Bound;
   pragma Inline_Always (Tail_Add);
   function Sparse_Model (R : Row; Q : Real_Array; Tail : Natural) return Coordinate is
     (if Tail = 0 then
        Combine (Lane_Value (R, Q, R'Length / 4, 0), Lane_Value (R, Q, R'Length / 4, 1),
                 Lane_Value (R, Q, R'Length / 4, 2), Lane_Value (R, Q, R'Length / 4, 3), R'Length / 4)
      else Tail_Add (Sparse_Model (R, Q, Tail - 1),
        R (R'First + (4 * (R'Length / 4) + Tail - 1)).Coefficient,
        Q (R (R'First + (4 * (R'Length / 4) + Tail - 1)).Dof), Tail - 1))
     with Ghost => Static, Global => null,
     Pre => Valid_Row (R, Q) and then Tail <= R'Length mod 4,
     Post => abs Sparse_Model'Result <= 2.0 ** 85 + Real (Tail) * Step_Bound,
     Subprogram_Variant => (Decreases => Tail);
   procedure Unfold_Lane (R : Row; Q : Real_Array; Count, Lane : Natural)
     with Ghost => Static, Global => null,
     Pre => Valid_Row (R, Q) and then Lane < 4 and then Count < R'Length / 4,
     Post => Lane_Value (R, Q, Count + 1, Lane) = Sum_Step
       (Lane_Value (R, Q, Count, Lane), R (R'First + (4 * Count + Lane)).Coefficient,
        Q (R (R'First + (4 * Count + Lane)).Dof), Count);
   procedure Unfold_Sparse (R : Row; Q : Real_Array; Tail : Natural)
     with Ghost => Static, Global => null,
     Pre => Valid_Row (R, Q) and then Tail <= R'Length mod 4,
     Post => Sparse_Model (R, Q, Tail) =
       (if Tail = 0 then
          Combine (Lane_Value (R, Q, R'Length / 4, 0), Lane_Value (R, Q, R'Length / 4, 1),
                   Lane_Value (R, Q, R'Length / 4, 2), Lane_Value (R, Q, R'Length / 4, 3), R'Length / 4)
        else Tail_Add (Sparse_Model (R, Q, Tail - 1),
          R (R'First + (4 * (R'Length / 4) + Tail - 1)).Coefficient,
          Q (R (R'First + (4 * (R'Length / 4) + Tail - 1)).Dof), Tail - 1));
   procedure Advance_Lane (R : Row; Q : Real_Array; Count, Lane : Natural; Acc : in out Coordinate)
     with Global => null,
     Pre => Valid_Row (R, Q) and then Lane < 4 and then Count < R'Length / 4
       and then abs Acc <= Real (Count) * Step_Bound,
     Post => abs Acc <= Real (Count + 1) * Step_Bound;
   pragma Precondition (Static => Acc = Lane_Value (R, Q, Count, Lane));
   pragma Postcondition (Static => Acc = Lane_Value (R, Q, Count + 1, Lane));
   pragma Inline_Always (Advance_Lane);
   procedure Advance_Tail (R : Row; Q : Real_Array; Count : Natural; Acc : in out Coordinate)
     with Global => null,
     Pre => Valid_Row (R, Q) and then Count < R'Length mod 4
       and then abs Acc <= 2.0 ** 85 + Real (Count) * Step_Bound,
     Post => abs Acc <= 2.0 ** 85 + Real (Count + 1) * Step_Bound;
   pragma Precondition (Static => Acc = Sparse_Model (R, Q, Count));
   pragma Postcondition (Static => Acc = Sparse_Model (R, Q, Count + 1));
   pragma Inline_Always (Advance_Tail);
   procedure Tail_Bound (Value : Coordinate; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Count <= 3 and then abs Value <= 2.0 ** 85 + Real (Count) * Step_Bound,
     Post => abs Value <= 1.0e27;
   function Sparse_Dot (R : Row; Q : Real_Array) return Coordinate
     with Global => null, Pre => Valid_Row (R, Q),
     Post => abs Sparse_Dot'Result <= 1.0e27;
   pragma Postcondition (Static => Sparse_Dot'Result = Sparse_Model (R, Q, R'Length mod 4));
   pragma Inline_Always (Combine);

   --  Length uses the original wrap order; velocity uses the sorted,
   --  sparse Jacobian row (including zero duplicate slots). They cannot in general share one reduction.
   procedure Fixed_Kinematics
     (Terms, Jacobian : Row; Q, V : Real_Array; Length, Velocity : out Coordinate)
     with Global => null, Pre => Valid_Row (Terms, Q) and then Valid_Row (Jacobian, V),
     Post => (Static => Length = Reduction (Terms, Q, Terms'Length)
       and then Velocity = Sparse_Model (Jacobian, V, Jacobian'Length mod 4)
       and then abs Length <= Real (Terms'Length) * Step_Bound
       and then abs Velocity <= 1.0e27
       and then Length in -5.0e29 .. 5.0e29);

   --  Scalars below preserve C's multiplication order. Bounds leave room for
   --  accumulation; the caller's reduction proves its own tighter envelope.
   function Project (Previous : Real; J : Tier0_Real; Force : Tendon_Force)
     return Real with Global => null, Pre => Previous in -1.0e120 .. 1.0e120,
     Post => Project'Result = Previous + J * Force
       and then Project'Result in -2.0e120 .. 2.0e120;
   function Mass_Entry (Previous : Real; Armature : Nonneg_Tier0;
                        Ji, Jj : Tier0_Real) return Real
     with Global => null, Pre => Previous in -1.0e120 .. 1.0e120,
     Post => Mass_Entry'Result = Previous + Jj * (Armature * Ji)
       and then Mass_Entry'Result in -2.0e120 .. 2.0e120;
   subtype Mass_Value is Real range -1.0e60 .. 1.0e60;
   subtype Mass_Change is Real range -1.0e31 .. 1.0e31;
   subtype Small_Force is Real range -1.0e30 .. 1.0e30;
   function Project_Small (Previous : Mass_Value; J : Tier0_Real; Force : Small_Force)
     return Mass_Value with Global => null,
     Post => Project_Small'Result = Previous + J * Force;
   pragma Inline_Always (Project_Small);
   function Accumulate_Mass (Previous : Mass_Value; Change : Mass_Change)
     return Mass_Value with Global => null,
     Post => Accumulate_Mass'Result = Previous + Change;
   pragma Inline_Always (Polynomial_First);
   pragma Inline_Always (Polynomial_Second);
   pragma Inline_Always (Accumulate_Mass);
   pragma Inline_Always (Sum_Step);
   pragma Inline_Always (Project);
   pragma Inline_Always (Mass_Entry);
end MJ.Tendon_Kernels;

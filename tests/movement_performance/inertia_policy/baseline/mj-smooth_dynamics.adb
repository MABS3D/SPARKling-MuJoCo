package body MJ.Smooth_Dynamics with SPARK_Mode is
   procedure Quaternion_Bounds (Q : Quaternion) is null;
   function Apply_Config (R : Matrix; V : Vector) return Vector is
      subtype Component is Real range -1.0e12 .. 1.0e12;
      Reference : constant Vector := Apply (R, V) with Ghost => Static;
      X : constant Component := (R (0, 0) * V (0) + R (0, 1) * V (1)) + R (0, 2) * V (2);
      Y : constant Component := (R (1, 0) * V (0) + R (1, 1) * V (1)) + R (1, 2) * V (2);
      Z : constant Component := (R (2, 0) * V (0) + R (2, 1) * V (1)) + R (2, 2) * V (2);
   begin
      pragma Assert (Static => Reference (0) = X);
      pragma Assert (Static => Reference (1) = Y);
      pragma Assert (Static => Reference (2) = Z);
      return [X, Y, Z];
   end Apply_Config;
   function Cross_Local (A, B : Vector) return Vector is
      subtype Component is Real range -4.0e120 .. 4.0e120;
      Reference : constant Vector := Cross (A, B) with Ghost => Static;
      X : constant Component := A (1) * B (2) - A (2) * B (1);
      Y : constant Component := A (2) * B (0) - A (0) * B (2);
      Z : constant Component := A (0) * B (1) - A (1) * B (0);
   begin
      pragma Assert (Static => Reference (0) = X);
      pragma Assert (Static => Reference (1) = Y);
      pragma Assert (Static => Reference (2) = Z);
      return [X, Y, Z];
   end Cross_Local;
   function Cross_Transport (A, B : Vector) return Vector is
      subtype Component is Real range -4.0e190 .. 4.0e190;
      Reference : constant Vector := Cross (A, B) with Ghost => Static;
      X : constant Component := A (1) * B (2) - A (2) * B (1);
      Y : constant Component := A (2) * B (0) - A (0) * B (2);
      Z : constant Component := A (0) * B (1) - A (1) * B (0);
   begin
      pragma Assert (Static => Reference (0) = X);
      pragma Assert (Static => Reference (1) = Y);
      pragma Assert (Static => Reference (2) = Z);
      return [X, Y, Z];
   end Cross_Transport;
   function Dot_Motion (A, B : Vector) return Dot_Real is
      subtype Product_Real is Real range -2.0e150 .. 2.0e150;
      subtype Pair_Real is Real range -4.0e150 .. 4.0e150;
      X : constant Product_Real := A (0) * B (0);
      Y : constant Product_Real := A (1) * B (1);
      Z : constant Product_Real := A (2) * B (2);
      XY : constant Pair_Real := X + Y;
   begin
      return XY + Z;
   end Dot_Motion;
   function Center_Acceleration (Linear_Bias, Angular_Bias, Angular_Velocity, Offset : Vector)
     return Vector is
      Local : constant Vector := Cross_Local (Angular_Bias, Offset);
      Transport : constant Vector := Cross_Transport
        (Angular_Velocity, Cross_Local (Angular_Velocity, Offset));
      subtype Partial_Real is Real range -1.0e122 .. 1.0e122;
      X : constant Partial_Real := Linear_Bias (0) + Local (0);
      Y : constant Partial_Real := Linear_Bias (1) + Local (1);
      Z : constant Partial_Real := Linear_Bias (2) + Local (2);
   begin
      return [X + Transport (0), Y + Transport (1), Z + Transport (2)];
   end Center_Acceleration;
   function Mass_Force (Mass : Nonneg_Tier0; Acceleration : Vector) return Vector is
   begin
      return [Mass * Acceleration (0), Mass * Acceleration (1), Mass * Acceleration (2)];
   end Mass_Force;
   function Inertial_Torque (R : Matrix; Diagonal, Angular_Bias, Angular_Velocity : Vector)
     return Vector is
      Angular : constant Vector := MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Bias);
      Transport : constant Vector := Cross_Transport
        (Angular_Velocity, MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Velocity));
   begin
      return [Angular (0) + Transport (0), Angular (1) + Transport (1), Angular (2) + Transport (2)];
   end Inertial_Torque;
   function Mass_Contribution
     (Previous : Work_Real; Mass : Nonneg_Tier0; Li, Lj, Ai, Aj : Vector;
      R : Matrix; Diagonal : Vector) return Contribution_Real is
      subtype Linear_Real is Real range -2.0e161 .. 2.0e161;
      subtype Partial_Real is Real range -3.0e161 .. 3.0e161;
      Linear : constant Linear_Real := Mass * Dot_Motion (Li, Lj);
      Partial : constant Partial_Real := Previous + Linear;
      Angular : constant Dot_Real := Dot_Motion (Ai, MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Aj));
   begin
      return Partial + Angular;
   end Mass_Contribution;
   function Prepared_Mass_Contribution
     (Previous : Work_Real; Mass : Nonneg_Tier0; Li, Lj, Ai, Inertia_Aj : Vector)
     return Contribution_Real is
      subtype Linear_Real is Real range -2.0e161 .. 2.0e161;
      subtype Partial_Real is Real range -3.0e161 .. 3.0e161;
      Linear : constant Linear_Real := Mass * Dot_Motion (Li, Lj);
      Partial : constant Partial_Real := Previous + Linear;
      Angular : constant Dot_Real := Dot_Motion (Ai, Inertia_Aj);
   begin
      return Partial + Angular;
   end Prepared_Mass_Contribution;
   function Gravity_Contribution (Previous : Work_Real; Linear, Gravity : Vector)
     return Contribution_Real is (Previous + Dot_Motion (Linear, Gravity));
   function Bias_Contribution (Previous : Work_Real; Linear, Force, Angular, Torque : Vector)
     return Contribution_Real is
      subtype Partial_Real is Real range -2.0e151 .. 2.0e151;
      Partial : constant Partial_Real := Previous + Dot_Motion (Linear, Force);
   begin
      return Partial + Dot_Motion (Angular, Torque);
   end Bias_Contribution;
   function Total_Force (Gravity, Bias, Passive, Actuator : Work_Real; Applied : Tier0_Real)
     return Contribution_Real is ((((Gravity - Bias) + Passive) + Actuator) + Applied);
   function Read_Motion (A : Real_Array; Offset : Natural) return Vector is (Read_Vector (A, Offset));
   function Scaled_Pivot (Value : Work_Real; Scale : Real) return Scaled_Pivot_Real is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Scaled_Pivot_Model);
   begin
      return Value / Scale;
   end Scaled_Pivot;
   procedure Prepare_Scaled_Diagonal
     (Factor : Real_Array; N : Natural; Scale : Real; Pivots : out Real_Array)
   is
   begin
      Pivots := [others => 0.0];
      for I in Pivots'Range loop
         Pivots (I) := Scaled_Pivot (Factor (MJ.Smooth_Kernels.Matrix_Offset (N, I, I)), Scale);
         pragma Loop_Invariant (for all K in Pivots'First .. I =>
           Pivots (K) in -1.0e76 .. 1.0e76 and then Pivots (K) =
             Scaled_Pivot_Model (Factor (MJ.Smooth_Kernels.Matrix_Offset (N, K, K)), Scale));
      end loop;
   end Prepare_Scaled_Diagonal;
   procedure Offset_Identity (N, I, J, Row, Column : Natural) is
   begin
      pragma Assert ((I * N + J) / N = I);
      pragma Assert ((Row * N + Column) / N = Row);
   end Offset_Identity;
   procedure Prove_Symmetric_Element
     (A, Original : Real_Array; N, Row, Column, I, J : Natural; Value : Work_Real)
     with Ghost => Static, Global => null,
     Pre => Square_Layout (A, N) and then Square_Layout (Original, N)
       and then Row < N and then Column < N and then I < N and then J < N
       and then Symmetric (Original, N)
       and then (for all K in A'Range => A (K) =
         (if K = Row * N + Column or else K = Column * N + Row then Value else Original (K))),
     Post => A (I * N + J) = A (J * N + I)
   is
      IJ : constant Natural := MJ.Smooth_Kernels.Matrix_Offset (N, I, J);
      JI : constant Natural := MJ.Smooth_Kernels.Matrix_Offset (N, J, I);
   begin
      Offset_Identity (N, I, J, Row, Column);
      Offset_Identity (N, I, J, Column, Row);
      Offset_Identity (N, J, I, Row, Column);
      Offset_Identity (N, J, I, Column, Row);
      pragma Assert (Original (IJ) = Original (JI));
      if (I = Row and then J = Column) or else (I = Column and then J = Row) then
         pragma Assert (A (I * N + J) = Value);
         pragma Assert (A (J * N + I) = Value);
      else
         pragma Assert (A (I * N + J) = Original (I * N + J));
         pragma Assert (A (J * N + I) = Original (J * N + I));
      end if;
   end Prove_Symmetric_Element;
   procedure Prove_Symmetry_After_Update
     (A, Original : Real_Array; N, Row, Column : Natural; Value : Work_Real)
     with Ghost => Static, Global => null,
     Pre => Square_Layout (A, N) and then Square_Layout (Original, N)
       and then Row < N and then Column < N and then Symmetric (Original, N)
       and then (for all K in A'Range => A (K) =
         (if K = Row * N + Column or else K = Column * N + Row then Value else Original (K))),
     Post => Symmetric (A, N)
   is
   begin
      for I in 0 .. N - 1 loop
         for J in 0 .. N - 1 loop
            Prove_Symmetric_Element (A, Original, N, Row, Column, I, J, Value);
            pragma Loop_Invariant (for all K in 0 .. J => A (MJ.Smooth_Kernels.Matrix_Offset (N, I, K)) = A (MJ.Smooth_Kernels.Matrix_Offset (N, K, I)));
         end loop;
         pragma Loop_Invariant (for all H in 0 .. I =>
           (for all K in 0 .. N - 1 => A (MJ.Smooth_Kernels.Matrix_Offset (N, H, K)) = A (MJ.Smooth_Kernels.Matrix_Offset (N, K, H))));
      end loop;
   end Prove_Symmetry_After_Update;
   procedure Store_Symmetric (A : in out Real_Array; N, Row, Column : Natural; Value : Work_Real) is
      Original : constant Real_Array := A with Ghost => Static;
   begin
      A (Row * N + Column) := Value;
      A (Column * N + Row) := Value;
      Prove_Symmetry_After_Update (A, Original, N, Row, Column, Value);
   end Store_Symmetric;
   function Body_Entry
     (Previous : Work_Real; N, Row, Column : Natural; Linear, Angular : Real_Array;
      Mass : Nonneg_Tier0; R : Matrix; Diagonal : Vector) return Contribution_Real is
   begin
      return Mass_Contribution (Previous, Mass,
        Read_Motion (Linear, Linear'First + 3 * Row), Read_Motion (Linear, Linear'First + 3 * Column),
        Read_Motion (Angular, Angular'First + 3 * Row), Read_Motion (Angular, Angular'First + 3 * Column),
        R, Diagonal);
   end Body_Entry;
   procedure Prepare_Mass_Columns
     (Angular : Real_Array; R : Matrix; Diagonal : Vector;
      Columns : out Inertia_Column_Array)
   is
   begin
      Columns := [others => Zero];
      for J in Columns'Range loop
         Columns (J) := MJ.Smooth_Kernels.Inertia_Times
           (R, Diagonal, Read_Motion (Angular, Angular'First + 3 * J));
         pragma Loop_Invariant (for all K in Columns'First .. J =>
           Bounded (Columns (K), 1.0e75) and then Columns (K) =
             MJ.Smooth_Kernels.Inertia_Times
               (R, Diagonal, Read_Motion (Angular, Angular'First + 3 * K)));
      end loop;
   end Prepare_Mass_Columns;
   procedure Add_Mass_Body
     (A : in out Real_Array; N : Natural; Linear, Angular : Real_Array;
      Mass : Nonneg_Tier0; R : Matrix; Diagonal : Vector; Ok : out Boolean)
   is
      Original : constant Real_Array := A with Ghost => Static;
      Value : Contribution_Real;
   begin
      Ok := False;
      for I in 0 .. N - 1 loop
         pragma Loop_Invariant (Work_Array (A) and then Symmetric (A, N));
         pragma Loop_Invariant (Static => (for all Row in 0 .. N - 1 => (for all Column in 0 .. Row =>
           (if Row < I then A (Row * N + Column) =
              Body_Entry (Original (Row * N + Column), N, Row, Column, Linear, Angular, Mass, R, Diagonal)
            else A (Row * N + Column) = Original (Row * N + Column)))));
         for J in 0 .. I loop
            pragma Loop_Invariant (Work_Array (A) and then Symmetric (A, N));
            pragma Loop_Invariant (Static => (for all Row in 0 .. N - 1 => (for all Column in 0 .. Row =>
              (if Row < I or else (Row = I and then Column < J) then A (Row * N + Column) =
                 Body_Entry (Original (Row * N + Column), N, Row, Column, Linear, Angular, Mass, R, Diagonal)
               else A (Row * N + Column) = Original (Row * N + Column)))));
            Value := Body_Entry (A (I * N + J), N, I, J, Linear, Angular, Mass, R, Diagonal);
            if Value not in Work_Real then return; end if;
            Store_Symmetric (A, N, I, J, Value);
         end loop;
      end loop;
      Ok := True;
   end Add_Mass_Body;
end MJ.Smooth_Dynamics;

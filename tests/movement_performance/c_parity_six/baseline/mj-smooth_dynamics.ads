with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Smooth_Kernels;

--  Local floating-point laws used by the articulated-body loops. The order
--  below is intentional; no associativity of rounded sums is assumed.
package MJ.Smooth_Dynamics with SPARK_Mode is
   subtype Work_Real is Real range -Work_Limit .. Work_Limit;
   subtype Dot_Real is Real range -1.0e151 .. 1.0e151;
   subtype Contribution_Real is Real range -1.0e163 .. 1.0e163;
   procedure Quaternion_Bounds (Q : Quaternion) with Ghost => Static, Global => null,
     Pre => Unit_Quaternion (Q), Post => Bounded (Q, 1.000001);
   function Apply_Config (R : Matrix; V : Vector) return Vector with Global => null,
     Pre => Bounded (R, 16.0) and then Bounded (V, Max_Val),
     Post => Bounded (Apply_Config'Result, 1.0e12) and then Apply_Config'Result = Apply (R, V);
   function Cross_Local (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A) and then Bounded (B),
     Post => Bounded (Cross_Local'Result, 4.0e120) and then Cross_Local'Result = Cross (A, B);
   function Cross_Transport (A, B : Vector) return Vector with Global => null,
     Pre => Bounded (A) and then Bounded (B, 1.0e130),
     Post => Bounded (Cross_Transport'Result, 4.0e190) and then Cross_Transport'Result = Cross (A, B);
   function Dot_Motion (A, B : Vector) return Dot_Real with Global => null,
     Pre => Bounded (A, 1.0e75) and then Bounded (B, 1.0e75),
     Post => Dot_Motion'Result = Dot (A, B);
   function Center_Acceleration (Linear_Bias, Angular_Bias, Angular_Velocity, Offset : Vector)
     return Vector with Global => null,
     Pre => Bounded (Linear_Bias) and then Bounded (Angular_Bias)
       and then Bounded (Angular_Velocity) and then Bounded (Offset),
     Post => Bounded (Center_Acceleration'Result, 1.0e192)
       and then Center_Acceleration'Result (0) =
         (Linear_Bias (0) + Cross_Local (Angular_Bias, Offset) (0))
           + Cross_Transport (Angular_Velocity, Cross_Local (Angular_Velocity, Offset)) (0)
       and then Center_Acceleration'Result (1) =
         (Linear_Bias (1) + Cross_Local (Angular_Bias, Offset) (1))
           + Cross_Transport (Angular_Velocity, Cross_Local (Angular_Velocity, Offset)) (1)
       and then Center_Acceleration'Result (2) =
         (Linear_Bias (2) + Cross_Local (Angular_Bias, Offset) (2))
           + Cross_Transport (Angular_Velocity, Cross_Local (Angular_Velocity, Offset)) (2);
   function Mass_Force (Mass : Nonneg_Tier0; Acceleration : Vector) return Vector
     with Global => null, Pre => Bounded (Acceleration, 1.0e192),
     Post => Bounded (Mass_Force'Result, 1.0e204)
       and then (for all K in Axis => Mass_Force'Result (K) = Mass * Acceleration (K));
   function Inertial_Torque (R : Matrix; Diagonal, Angular_Bias, Angular_Velocity : Vector)
     return Vector with Global => null,
     Pre => Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val)
       and then Bounded (Angular_Bias) and then Bounded (Angular_Velocity),
     Post => Bounded (Inertial_Torque'Result, 1.0e192)
       and then Inertial_Torque'Result (0) =
         MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Bias) (0)
           + Cross_Transport (Angular_Velocity, MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Velocity)) (0)
       and then Inertial_Torque'Result (1) =
         MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Bias) (1)
           + Cross_Transport (Angular_Velocity, MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Velocity)) (1)
       and then Inertial_Torque'Result (2) =
         MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Bias) (2)
           + Cross_Transport (Angular_Velocity, MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Angular_Velocity)) (2);
   function Mass_Contribution
     (Previous : Work_Real; Mass : Nonneg_Tier0; Li, Lj, Ai, Aj : Vector;
      R : Matrix; Diagonal : Vector) return Contribution_Real with Global => null,
     Pre => Bounded (Li) and then Bounded (Lj) and then Bounded (Ai) and then Bounded (Aj)
       and then Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val),
     Post => Mass_Contribution'Result =
       (Previous + Mass * Dot_Motion (Li, Lj))
         + Dot_Motion (Ai, MJ.Smooth_Kernels.Inertia_Times (R, Diagonal, Aj));
   --  Same rounded contribution with the column's inertia product prepared
   --  once per body. Neither addition nor dot-product order is changed.
   function Prepared_Mass_Contribution
     (Previous : Work_Real; Mass : Nonneg_Tier0; Li, Lj, Ai, Inertia_Aj : Vector)
     return Contribution_Real with Global => null,
     Pre => Bounded (Li) and then Bounded (Lj) and then Bounded (Ai)
       and then Bounded (Inertia_Aj, 1.0e75),
     Post => Prepared_Mass_Contribution'Result =
       (Previous + Mass * Dot_Motion (Li, Lj)) + Dot_Motion (Ai, Inertia_Aj);
   function Gravity_Contribution (Previous : Work_Real; Linear, Gravity : Vector)
     return Contribution_Real with Global => null,
     Pre => Bounded (Linear) and then Bounded (Gravity),
     Post => Gravity_Contribution'Result = Previous + Dot_Motion (Linear, Gravity);
   function Bias_Contribution (Previous : Work_Real; Linear, Force, Angular, Torque : Vector)
     return Contribution_Real with Global => null,
     Pre => Bounded (Linear) and then Bounded (Force) and then Bounded (Angular) and then Bounded (Torque),
     Post => Bias_Contribution'Result =
       (Previous + Dot_Motion (Linear, Force)) + Dot_Motion (Angular, Torque);
   function Total_Force (Gravity, Bias, Passive, Actuator : Work_Real; Applied : Tier0_Real)
     return Contribution_Real with Global => null,
     Post => Total_Force'Result = (((Gravity - Bias) + Passive) + Actuator) + Applied;

   function Work_Array (A : Real_Array) return Boolean is
     (for all X of A => X in Work_Real) with Global => null;
   function Read_Motion (A : Real_Array; Offset : Natural) return Vector with Global => null,
     Pre => Work_Array (A) and then Offset >= A'First and then Int64 (Offset) + 2 <= Int64 (A'Last),
     Post => Bounded (Read_Motion'Result) and then Read_Motion'Result = Read_Vector (A, Offset);
   function Square_Layout (A : Real_Array; N : Natural) return Boolean is
     (N <= 256 and then A'First = 0 and then A'Last = N * N - 1) with Global => null;
   subtype Scaled_Pivot_Real is Real range -1.0e76 .. 1.0e76;
   function Scaled_Pivot_Model (Value : Work_Real; Scale : Real) return Scaled_Pivot_Real is (Value / Scale)
     with Global => null, Pre => Scale in Min_Val .. 1.0e100,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Scaled_Pivot (Value : Work_Real; Scale : Real) return Scaled_Pivot_Real
     with Global => null, Pre => Scale in Min_Val .. 1.0e100,
     Post => Scaled_Pivot'Result = Scaled_Pivot_Model (Value, Scale);
   procedure Prepare_Scaled_Diagonal
     (Factor : Real_Array; N : Natural; Scale : Real; Pivots : out Real_Array)
     with Global => null,
     Pre => Square_Layout (Factor, N) and then Work_Array (Factor)
       and then Scale in Min_Val .. 1.0e100
       and then Pivots'First = 0 and then Pivots'Last = N - 1,
     Post => (for all I in Pivots'Range => Pivots (I) in -1.0e76 .. 1.0e76
       and then Pivots (I) = Scaled_Pivot_Model (Factor (MJ.Smooth_Kernels.Matrix_Offset (N, I, I)), Scale));
   function Symmetric (A : Real_Array; N : Natural) return Boolean is
     (for all I in 0 .. N - 1 => (for all J in 0 .. N - 1 => A (MJ.Smooth_Kernels.Matrix_Offset (N, I, J)) = A (MJ.Smooth_Kernels.Matrix_Offset (N, J, I))))
     with Global => null, Pre => Square_Layout (A, N);
   procedure Offset_Identity (N, I, J, Row, Column : Natural) with Ghost => Static, Global => null,
     Pre => N <= 256 and then I < N and then J < N and then Row < N and then Column < N,
     Post => (I * N + J = Row * N + Column) = (I = Row and then J = Column);
   procedure Store_Symmetric (A : in out Real_Array; N, Row, Column : Natural; Value : Work_Real)
     with Global => null,
     Pre => Square_Layout (A, N) and then Row < N and then Column < N
       and then Work_Array (A) and then Symmetric (A, N),
     Post => Work_Array (A) and then Symmetric (A, N)
       and then (for all K in A'Range =>
         A (K) = (if K = Row * N + Column or else K = Column * N + Row then Value else A'Old (K)));
   function Jacobian_Layout (A : Real_Array; N : Natural) return Boolean is
     (N <= 256 and then Int64 (A'Length) = 3 * Int64 (N)) with Global => null;
   type Inertia_Column_Array is array (Natural range <>) of Vector;
   procedure Prepare_Mass_Columns
     (Angular : Real_Array; R : Matrix; Diagonal : Vector;
      Columns : out Inertia_Column_Array)
     with Global => null,
     Pre => Columns'First = 0 and then Columns'Length <= 256
       and then Jacobian_Layout (Angular, Columns'Length) and then Work_Array (Angular)
       and then Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val),
     Post => (for all J in Columns'Range => Bounded (Columns (J), 1.0e75)
       and then Columns (J) = MJ.Smooth_Kernels.Inertia_Times
         (R, Diagonal, Read_Motion (Angular, Angular'First + 3 * J)));
   function Body_Entry
     (Previous : Work_Real; N, Row, Column : Natural; Linear, Angular : Real_Array;
      Mass : Nonneg_Tier0; R : Matrix; Diagonal : Vector) return Contribution_Real with Global => null,
     Pre => Jacobian_Layout (Linear, N) and then Jacobian_Layout (Angular, N)
       and then Work_Array (Linear) and then Work_Array (Angular)
       and then Row < N and then Column < N
       and then Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val),
     Post => Body_Entry'Result = Mass_Contribution (Previous, Mass,
       Read_Motion (Linear, Linear'First + 3 * Row), Read_Motion (Linear, Linear'First + 3 * Column),
       Read_Motion (Angular, Angular'First + 3 * Row), Read_Motion (Angular, Angular'First + 3 * Column),
       R, Diagonal);
   procedure Add_Mass_Body
     (A : in out Real_Array; N : Natural; Linear, Angular : Real_Array;
      Mass : Nonneg_Tier0; R : Matrix; Diagonal : Vector; Ok : out Boolean)
     with Global => null,
     Pre => Square_Layout (A, N) and then Work_Array (A) and then Symmetric (A, N)
       and then Jacobian_Layout (Linear, N) and then Jacobian_Layout (Angular, N)
       and then Work_Array (Linear) and then Work_Array (Angular)
       and then Bounded (R, 16.0) and then Bounded (Diagonal, Max_Val),
     Post => Work_Array (A) and then Symmetric (A, N)
       and then (if Ok then (for all I in 0 .. N - 1 => (for all J in 0 .. I =>
         A (I * N + J) = Body_Entry (A'Old (I * N + J), N, I, J, Linear, Angular, Mass, R, Diagonal))));
end MJ.Smooth_Dynamics;

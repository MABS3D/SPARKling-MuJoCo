with Ada.Numerics.Generic_Elementary_Functions;
with MJ.Types;

package MJ.Cholesky_Arithmetic with SPARK_Mode is
   subtype Size is Natural range 0 .. 4096;
   subtype Offset is Natural range 0 .. 4096 * 4096;
   subtype Position is Offset range 0 .. Offset'Last - 1;
   subtype Scalar is MJ.Types.Real range -1.0E100 .. 1.0E100;
   type Values is array (Position range <>) of Scalar;
   type Indices is array (Position range <>) of Offset;
   type Outcome is (Success, Not_Positive_Definite, Insufficient_Capacity,
                    Missing_Fill, Invalid_Pattern, Numeric_Limit);
   Min_Diag : constant Scalar := MJ.Types.Min_Val;
   package Elementary is new Ada.Numerics.Generic_Elementary_Functions
     (MJ.Types.Real);

   --  Every successful primitive has an exact binary64 operation contract.
   --  Numeric_Limit is an explicit rejection, never a silently clipped value.
   procedure Add_Product (A, B, C : Scalar; R : out Scalar; Status : out Outcome)
     with Post => (if Status = Success then R = A + B * C)
       and then Status in Success | Numeric_Limit;
   procedure Multiply (A, B : Scalar; R : out Scalar; Status : out Outcome)
     with Post => (if Status = Success then R = A * B)
       and then Status in Success | Numeric_Limit;
   procedure Divide (A, B : Scalar; R : out Scalar; Status : out Outcome)
     with Pre => abs B >= Min_Diag,
       Post => (if Status = Success then R = A / B)
         and then Status in Success | Numeric_Limit;
   procedure Root (A : Scalar; R : out Scalar; Status : out Outcome)
     with Pre => A >= Min_Diag,
       Post => (if Status = Success then
                  R = Elementary.Sqrt (A) and then R >= Min_Diag)
         and then Status in Success | Numeric_Limit;
   procedure Factor_Pivot (Value, Minimum : Scalar; R : out Scalar;
                           Clamped : out Boolean; Status : out Outcome)
     with Pre => Minimum >= Min_Diag,
       Post => Clamped = (Value < Minimum)
         and then (if Status = Success then
           R = Elementary.Sqrt ((if Clamped then Minimum else Value))
           and then R >= Min_Diag)
         and then Status in Success | Numeric_Limit;
   procedure Copy (Source : Values; Source_At : Offset;
                   Destination : in out Values; Destination_At : Offset; Count : Size)
     with Pre => Source'First = 0 and then Destination'First = 0
       and then Source'Length <= Offset'Last and then Destination'Length <= Offset'Last
       and then Source_At <= Source'Length and then Count <= Source'Length - Source_At
       and then Destination_At <= Destination'Length
       and then Count <= Destination'Length - Destination_At,
       Post => (for all K in Destination'Range =>
                  (if K >= Destination_At and then K - Destination_At < Count then
                     Destination (K) = Source (Source_At + (K - Destination_At))
                   else Destination (K) = Destination'Old (K)));

   --  MuJoCo's four-lane reduction and its different dense/sparse tails.
   procedure Dot (A, B : Values; A0, B0 : Offset; Count : Size;
                  R : out Scalar; Status : out Outcome)
     with Pre => A'First = 0 and then B'First = 0
       and then A'Length <= Offset'Last and then B'Length <= Offset'Last
       and then A0 <= A'Length and then Count <= A'Length - A0
       and then B0 <= B'Length and then Count <= B'Length - B0;
   procedure Dot_Sparse (A, B : Values; Col : Indices; A0 : Offset;
                         Count : Size; R : out Scalar; Status : out Outcome)
     with Pre => A'First = 0 and then B'First = 0 and then Col'First = 0
       and then A'Length <= Offset'Last and then B'Length <= Offset'Last
       and then Col'Length <= Offset'Last
       and then A0 <= A'Length and then Count <= A'Length - A0
       and then A0 <= Col'Length and then Count <= Col'Length - A0
       and then (for all K in Col'Range =>
                   (if K >= A0 and then K - A0 < Count then Col (K) < B'Length));
end MJ.Cholesky_Arithmetic;

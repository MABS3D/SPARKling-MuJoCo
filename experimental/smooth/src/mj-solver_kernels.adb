package body MJ.Solver_Kernels with SPARK_Mode is
   function Clamp_Pivot (Value : Work_Real) return Positive_Pivot is
     (if Value < Min_Val then Min_Val else Value);
   function Reciprocal (Value : Positive_Pivot) return Inverse_Real is (1.0 / Value);
   function Scale (Value : Work_Real; Inverse : Inverse_Real) return Scale_Real is
     (Value * Inverse);
   function Add_Product (Previous, Value : Work_Real; Multiplier : Scale_Real)
     return Update_Real is (Previous + Value * Multiplier);

   procedure Add_Row
     (Target : in out Real_Array; Source : Real_Array;
      Multiplier : Scale_Real; Ok : out Boolean)
   is
      Rejected : Int64 := 0;
   begin
      for I in Target'Range loop
         Target (I) := Add_Product
           (Target (I), Source (Source'First + (I - Target'First)), Multiplier);
         --  Count rejected entries: the fused Boolean reduction is miscompiled
         --  by this GNAT/GCC 16 toolchain at complete SIMD blocks. Integer
         --  accumulation retains SIMD and the exact rejection predicate.
         Rejected := Rejected + Boolean'Pos (Target (I) not in Work_Real);
         pragma Loop_Invariant
           (Static => Rejected in 0 .. Int64 (I) - Int64 (Target'First) + 1);
         pragma Loop_Invariant
           (Static => (Rejected = 0) = (for all J in Target'First .. I => Target (J) in Work_Real));
         pragma Loop_Invariant
           (Static => (for all J in Target'Range =>
             Target (J) = (if J <= I then Add_Product (Target'Loop_Entry (J),
               Source (Source'First + (J - Target'First)), Multiplier)
               else Target'Loop_Entry (J))));
      end loop;
      Ok := Rejected = 0;
   end Add_Row;

   procedure Scale_Row
     (Target : in out Real_Array; Inverse : Inverse_Real; Ok : out Boolean)
   is
      Rejected : Int64 := 0;
   begin
      for I in Target'Range loop
         Target (I) := Scale (Target (I), Inverse);
         Rejected := Rejected + Boolean'Pos (Target (I) not in Work_Real);
         pragma Loop_Invariant
           (Static => Rejected in 0 .. Int64 (I) - Int64 (Target'First) + 1);
         pragma Loop_Invariant
           (Static => (Rejected = 0) = (for all J in Target'First .. I => Target (J) in Work_Real));
         pragma Loop_Invariant
           (Static => (for all J in Target'Range =>
             Target (J) = (if J <= I then Scale (Target'Loop_Entry (J), Inverse)
               else Target'Loop_Entry (J))));
      end loop;
      Ok := Rejected = 0;
   end Scale_Row;

   type Rejection_Flags is mod 2 ** 64;

   procedure Flag_Rejection (Flags : in out Rejection_Flags; Reject_Entry : Boolean)
     with Global => null, Pre => Flags in 0 .. 1,
     Post => Flags in 0 .. 1
       and then Flags = (Flags'Old or Rejection_Flags (Boolean'Pos (Reject_Entry)))
       and then (Flags = 0) = (Flags'Old = 0 and then not Reject_Entry)
   is
   begin
      Flags := Flags or Rejection_Flags (Boolean'Pos (Reject_Entry));
   end Flag_Rejection;
   pragma Inline_Always (Flag_Rejection);

   procedure Add_Long_Row
     (Buffer : in out Real_Array;
      Target_First, Source_First : Natural; Count : Positive;
      Multiplier : Scale_Real; Ok : out Boolean)
     with Global => null,
     Pre => Target_First in Buffer'Range and then Source_First in Buffer'Range
       and then Target_First < Source_First
       and then Count <= Source_First - Target_First
       and then Count - 1 <= Buffer'Last - Source_First
       and then Work_Array (Buffer),
     Post => Ok = Work_Array (Buffer)
       and then (for all I in Buffer'Range =>
         Buffer (I) =
           (if I in Target_First .. Target_First + Count - 1 then
              Add_Product (Buffer'Old (I),
                Buffer'Old (Source_First + (I - Target_First)), Multiplier)
            else Buffer'Old (I)))
   is
      Rejected : Rejection_Flags := 0;
   begin
      for I in Target_First .. Target_First + Count - 1 loop
         --  Preserve the ordered scalar expression and its exact rejection
         --  predicate. An integer bit reduction avoids both the checked sum
         --  and the toolchain's previously observed Boolean SIMD reduction bug.
         --  Widen before index arithmetic: Natural operands cannot overflow
         --  Int64. The final conversion and array access remain checked.
         Buffer (I) := Buffer (I)
           + Buffer (Natural ((Int64 (Source_First) + Int64 (I))
               - Int64 (Target_First))) * Multiplier;
         Flag_Rejection (Rejected, Buffer (I) not in Work_Real);
         pragma Loop_Invariant (Static => Rejected in 0 .. 1);
         pragma Loop_Invariant
           (Static => (Rejected = 0) =
              (for all J in Target_First .. I => Buffer (J) in Work_Real));
         pragma Loop_Invariant
           (Static => (for all J in Buffer'Range =>
             Buffer (J) =
               (if J in Target_First .. I then
                  Add_Product (Buffer'Loop_Entry (J),
                    Buffer'Loop_Entry (Source_First + (J - Target_First)), Multiplier)
                else Buffer'Loop_Entry (J))));
      end loop;
      Ok := Rejected = 0;
   end Add_Long_Row;
   pragma No_Inline (Add_Long_Row);

   procedure Add_Row_Disjoint
     (Buffer : in out Real_Array;
      Target_First, Source_First : Natural; Count : Positive;
      Multiplier : Scale_Real; Ok : out Boolean)
   is
      Rejected : Rejection_Flags := 0;
   begin
      --  Keep long-row vector setup out of the short scalar caller.
      if Count >= 16 then
         Add_Long_Row (Buffer, Target_First, Source_First, Count, Multiplier, Ok);
         return;
      end if;
      for I in Target_First .. Target_First + Count - 1 loop
         --  Preserve the ordered scalar expression and its exact rejection
         --  predicate. An integer bit reduction avoids both the checked sum
         --  and the toolchain's previously observed Boolean SIMD reduction bug.
         Buffer (I) := Buffer (I)
           + Buffer (Source_First + (I - Target_First)) * Multiplier;
         Flag_Rejection (Rejected, Buffer (I) not in Work_Real);
         pragma Loop_Invariant (Static => Rejected in 0 .. 1);
         pragma Loop_Invariant
           (Static => (Rejected = 0) =
              (for all J in Target_First .. I => Buffer (J) in Work_Real));
         pragma Loop_Invariant
           (Static => (for all J in Buffer'Range =>
             Buffer (J) =
               (if J in Target_First .. I then
                  Add_Product (Buffer'Loop_Entry (J),
                    Buffer'Loop_Entry (Source_First + (J - Target_First)), Multiplier)
                else Buffer'Loop_Entry (J))));
      end loop;
      Ok := Rejected = 0;
   end Add_Row_Disjoint;
end MJ.Solver_Kernels;

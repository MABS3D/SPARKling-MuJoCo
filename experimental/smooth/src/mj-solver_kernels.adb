package body MJ.Solver_Kernels with SPARK_Mode is
   function In_Work_Domain (Value : Real) return Boolean is
     (abs Value <= Work_Real'Last)
     with Global => null,
     Post => In_Work_Domain'Result = (Value in Work_Real);
   function Clamp_Pivot (Value : Work_Real) return Positive_Pivot is
     (if Value < Min_Val then Min_Val else Value);
   function Reciprocal (Value : Positive_Pivot) return Inverse_Real is (1.0 / Value);
   function Scale (Value : Real; Inverse : Inverse_Real) return Real is
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
         declare
            Previous : constant Real := Target (I);
            Operand : constant Real := Source (Source'First + (I - Target'First));
         begin
            --  The original Pre and unchanged tail imply these input bounds.
            --  Keep them proved statically instead of reconverting every scalar.
            pragma Assert (Static => Previous in Work_Real);
            pragma Assert (Static => Operand in Work_Real);
            declare
               Expected : constant Update_Real :=
                 Add_Product (Previous, Operand, Multiplier) with Ghost => Static;
            begin
               Target (I) := Previous + Operand * Multiplier;
               pragma Assert (Static => Target (I) = Expected);
               pragma Assert (Static => Target (I) in Update_Real);
            end;
         end;
         --  Count rejected entries: the fused Boolean reduction is miscompiled
         --  by this GNAT/GCC 16 toolchain at complete SIMD blocks. Integer
         --  accumulation retains SIMD and the exact rejection predicate.
         Rejected := Rejected + Boolean'Pos (not In_Work_Domain (Target (I)));
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

   procedure Scale_Row
     (Target : in out Real_Array; Inverse : Inverse_Real; Ok : out Boolean)
   is
      Rejected : Rejection_Flags := 0;
   begin
      for I in Target'Range loop
         Target (I) := Target (I) * Inverse;
         Flag_Rejection (Rejected, not In_Work_Domain (Target (I)));
         pragma Loop_Invariant (Static => Rejected in 0 .. 1);
         pragma Loop_Invariant
           (Static => (Rejected = 0) = (for all J in Target'First .. I => Target (J) in Work_Real));
         pragma Loop_Invariant
           (Static => (for all J in Target'Range =>
             Target (J) = (if J <= I then Scale (Target'Loop_Entry (J), Inverse)
               else Target'Loop_Entry (J))));
      end loop;
      Ok := Rejected = 0;
   end Scale_Row;

   procedure Add_Long_Row
     (Buffer : in out Real_Array;
      Target_First, Source_First : Natural; Count : Positive;
      Multiplier : Real; Ok : out Boolean)
     with Global => null,
     Pre => Multiplier in Scale_Real
       and then Target_First in Buffer'Range and then Source_First in Buffer'Range
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
      Shift : constant Positive := Source_First - Target_First;
      Span_Last : constant Natural := Shift + (Count - 1);
      subtype Zero_Window is Real_Array (0 .. Span_Last);
      procedure Update_Window (Window : in out Zero_Window; Accepted : out Boolean)
        with Global => (Input => (Shift, Span_Last, Multiplier), Proof_In => Count),
        Pre => Shift in Window'Range
          and then Count - 1 = Window'Last - Shift
          and then Count <= Shift
          and then Multiplier in Scale_Real
          and then Work_Array (Window),
        Post => Accepted = Work_Array (Window)
          and then (for all J in Window'Range => Window (J) =
            (if J < Count then Add_Product (Window'Old (J),
              Window'Old (Shift + J), Multiplier) else Window'Old (J)))
      is
         Before : constant Zero_Window := Window with Ghost;
         Expected : constant Zero_Window :=
           [for J in Window'Range =>
             (if J <= Window'Last - Shift then Add_Product (Before (J), Before (Shift + J), Multiplier)
              else Before (J))] with Ghost;
         Rejected : Rejection_Flags := 0;
      begin
         --  One writable array formal; ordinary checked parameter sliding
         --  provides a zero origin without a borrowed pointer or conversion.
         for I in Shift .. Window'Last loop
            pragma Assert (Static => Window (I - Shift) = Before (I - Shift));
            pragma Assert (Static => Window (I) = Before (I));
            pragma Assert (Static => Window (I - Shift) in Work_Real);
            pragma Assert (Static => Window (I) in Work_Real);
            pragma Assert (Static => Expected (I - Shift) =
              Add_Product (Before (I - Shift), Before (I), Multiplier));
            Window (I - Shift) := Window (I - Shift) + Window (I) * Multiplier;
            pragma Assert (Static => Window (I - Shift) =
              Add_Product (Before (I - Shift), Before (I), Multiplier));
            pragma Assert (Static => Window (I - Shift) = Expected (I - Shift));
            Flag_Rejection (Rejected, not In_Work_Domain (Window (I - Shift)));
            pragma Loop_Invariant (Static => Rejected in 0 .. 1);
            pragma Loop_Invariant
              (Static => (Rejected = 0) =
                (for all J in 0 .. I - Shift => Window (J) in Work_Real));
            pragma Loop_Invariant
              (Static => (for all J in 0 .. I - Shift => Window (J) = Expected (J)));
            pragma Loop_Invariant
              (Static => (for all J in Window'Range =>
                (if J > I - Shift then Window (J) = Before (J))));
         end loop;
         Accepted := Rejected = 0;
      end Update_Window;
   begin
      Update_Window (Buffer (Target_First .. Source_First + (Count - 1)), Ok);
   end Add_Long_Row;
   pragma No_Inline (Add_Long_Row);

   procedure Add_Row_Disjoint
     (Buffer : in out Real_Array;
      Target_First, Source_First : Natural; Count : Positive;
      Multiplier : Real; Ok : out Boolean)
   is
      Rejected : Rejection_Flags := 0;
   begin
      --  Keep long-row vector setup out of the short scalar caller.
      if Count >= 8 then
         Add_Long_Row (Buffer, Target_First, Source_First, Count, Multiplier, Ok);
         return;
      end if;
      for I in Target_First .. Target_First + Count - 1 loop
         --  Preserve the ordered scalar expression and its exact rejection
         --  predicate. An integer bit reduction avoids both the checked sum
         --  and the toolchain's previously observed Boolean SIMD reduction bug.
         Buffer (I) := Buffer (I)
           + Buffer (Source_First + (I - Target_First)) * Multiplier;
         Flag_Rejection (Rejected, not In_Work_Domain (Buffer (I)));
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

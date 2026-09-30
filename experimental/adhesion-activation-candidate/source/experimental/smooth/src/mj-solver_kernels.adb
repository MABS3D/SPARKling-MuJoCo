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

   procedure Add_Row_Disjoint
     (Buffer : in out Real_Array;
      Target_First, Source_First : Natural; Count : Positive;
      Multiplier : Scale_Real; Ok : out Boolean)
   is
      Rejected : Int64 := 0;
   begin
      for I in Target_First .. Target_First + Count - 1 loop
         Buffer (I) := Add_Product
           (Buffer (I), Buffer (Source_First + (I - Target_First)), Multiplier);
         Rejected := Rejected + Boolean'Pos (Buffer (I) not in Work_Real);
         pragma Loop_Invariant
           (Static => Rejected in 0 .. Int64 (I) - Int64 (Target_First) + 1);
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

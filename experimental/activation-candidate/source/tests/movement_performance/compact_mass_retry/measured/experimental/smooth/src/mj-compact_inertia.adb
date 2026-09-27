package body MJ.Compact_Inertia with SPARK_Mode is
   function Lower_Entry (P : AR.Pattern; Mass : Real_Array;
                         Row, Col : Natural) return Real is
      A : constant Natural := AR.Length (P, Col) - 1;
   begin
      --  An ancestor's own row length determines its only possible offset.
      --  One membership check gives O(1) access without searching the row.
      pragma Assert (Static => (for all B in 0 .. AR.Length (P, Row) - 1 =>
        (if AR.Column (P, Row, B) = Col then B = A)));
      if A < AR.Length (P, Row) and then AR.Column (P, Row, A) = Col then
         return Mass (AR.Start (P, Row) + A);
      end if;
      return 0.0;
   end Lower_Entry;

   procedure Ordered_Rows (N, Earlier, Later : Natural) is
   begin
      pragma Assert (Static => Earlier * N + N <= Later * N);
      for J in 0 .. N - 1 loop
         pragma Assert (Static => Earlier * N + J < Later * N);
         pragma Assert (Static => Offset (N, Earlier, J) < Offset (N, Later, 0));
         pragma Loop_Invariant (Static => (for all K in 0 .. J =>
           Offset (N, Earlier, K) < Offset (N, Later, 0)));
      end loop;
   end Ordered_Rows;

   procedure Expand_Row
     (P : AR.Pattern; Mass : Real_Array; Row : Natural; Target : out Real_Array) is
   begin
      Target := [others => 0.0];
      for J in 0 .. AR.Size (P) - 1 loop
         Target (Target'First + J) := Value_At (P, Mass, Row, J);
         pragma Loop_Invariant (Static => (for all K in 0 .. J =>
           Target (Target'First + K) = Value_At (P, Mass, Row, K)));
      end loop;
   end Expand_Row;

   procedure Expand (P : AR.Pattern; Mass : Real_Array; Dense : out Real_Array) is
      N : constant Natural := AR.Size (P);
      Before : Real_Array (Dense'Range) with Ghost => Static;
   begin
      Dense := [others => 0.0];
      for I in 0 .. N - 1 loop
         for K in 0 .. I - 1 loop
            Ordered_Rows (N, K, I);
            pragma Loop_Invariant (Static => (for all R in 0 .. K =>
              (for all L in 0 .. N - 1 => Offset (N, R, L) < Offset (N, I, 0))));
         end loop;
         Before := Dense;
         Expand_Row (P, Mass, I,
           Dense (Dense'First + Offset (N, I, 0) .. Dense'First + Offset (N, I, N - 1)));
         pragma Assert (Static => (for all A in Dense'First .. Dense'First + Offset (N, I, 0) - 1 =>
           Dense (A) = Before (A)));
         pragma Assert (Static => (for all K in 0 .. I - 1 =>
           (for all L in 0 .. N - 1 => Dense (Dense'First + Offset (N, K, L)) =
             Before (Dense'First + Offset (N, K, L)))));
         pragma Assert (Static => (for all L in 0 .. N - 1 =>
           Dense (Dense'First + Offset (N, I, L)) = Value_At (P, Mass, I, L)));
         pragma Loop_Invariant (Static => (for all K in 0 .. I =>
           (for all L in 0 .. N - 1 =>
             Dense (Dense'First + Offset (N, K, L)) = Value_At (P, Mass, K, L))));
      end loop;
   end Expand;

   function Projected (Motion, Product : SK.Motion; Armature : Real;
                       Diagonal : Boolean) return Real is
   begin
      return (if Diagonal then Armature else 0.0) + SK.Dot (Motion, Product);
   end Projected;

   procedure Project_Row
     (P : AR.Pattern; Row : Natural; Motions : Real_Array; Product : SK.Motion;
      Armature : Real; Target : in out Real_Array; Ok : out Boolean) is
      Value : Real;
   begin
      Ok := False;
      for A in reverse 0 .. AR.Length (P, Row) - 1 loop
         Value := Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)),
                             Product, Armature, A = AR.Length (P, Row) - 1);
         if Value not in Work_Real then return; end if;
         Target (Target'First + A) := Value;
         pragma Loop_Invariant (Static => Work_Array (Target));
         pragma Loop_Invariant (Static => (for all B in A .. AR.Length (P, Row) - 1 =>
           Target (Target'First + B) = Projected
             (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, B)), Product,
              Armature, B = AR.Length (P, Row) - 1)));
      end loop;
      Ok := True;
   end Project_Row;
end MJ.Compact_Inertia;

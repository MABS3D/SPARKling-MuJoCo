package body MJ.Compact_Inertia with SPARK_Mode is
   procedure Clear (Mass : out Real_Array) is
   begin
      Mass := [others => 0.0];
   end Clear;
   procedure Store (Mass : in out Real_Array; Index : Natural; Value : Work_Real) is
   begin
      Mass (Index) := Value;
   end Store;

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
         pragma Loop_Invariant (Static => (if Work_Array (Mass) then Work_Array (Target)));
      end loop;
   end Expand_Row;

   --  Pure quantifier composition, separate from mutation of the dense slab.
   procedure Join_Expanded_Rows
     (P : AR.Pattern; Mass, Dense : Real_Array; Through : Natural)
     with Ghost => Static, Global => null,
     Pre => Through < AR.Size (P) and then Mass'First = 0
       and then Mass'Last >= AR.Count (P) - 1
       and then Int64 (Dense'Length) = Int64 (AR.Size (P)) * Int64 (AR.Size (P))
       and then (for all K in 0 .. Through - 1 =>
         (for all L in 0 .. AR.Size (P) - 1 =>
           Dense (Dense'First + Offset (AR.Size (P), K, L)) = Value_At (P, Mass, K, L)))
       and then (for all L in 0 .. AR.Size (P) - 1 =>
         Dense (Dense'First + Offset (AR.Size (P), Through, L)) =
           Value_At (P, Mass, Through, L)),
     Post => (for all K in 0 .. Through =>
       (for all L in 0 .. AR.Size (P) - 1 =>
         Dense (Dense'First + Offset (AR.Size (P), K, L)) = Value_At (P, Mass, K, L)))
   is
   begin
      null;
   end Join_Expanded_Rows;

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
         pragma Assert (Static => (for all K in 0 .. I - 1 =>
           (for all L in 0 .. N - 1 => Before (Dense'First + Offset (N, K, L)) =
             Value_At (P, Mass, K, L))));
         Expand_Row (P, Mass, I,
           Dense (Dense'First + Offset (N, I, 0) .. Dense'First + Offset (N, I, N - 1)));
         pragma Assert (Static => (for all L in 0 .. N - 1 =>
           Dense (Dense'First + Offset (N, I, L)) = Value_At (P, Mass, I, L)));
         pragma Assert (Static => (for all A in Dense'First .. Dense'First + Offset (N, I, 0) - 1 =>
           Dense (A) = Before (A)));
         pragma Assert (Static => (for all K in 0 .. I - 1 =>
           (for all L in 0 .. N - 1 => Dense (Dense'First + Offset (N, K, L)) =
             Before (Dense'First + Offset (N, K, L)))));
         pragma Assert (Static => (for all K in 0 .. I - 1 =>
           (for all L in 0 .. N - 1 => Dense (Dense'First + Offset (N, K, L)) =
             Value_At (P, Mass, K, L))));
         pragma Assert (Static => (for all L in 0 .. N - 1 =>
           Dense (Dense'First + Offset (N, I, L)) = Value_At (P, Mass, I, L)));
         Join_Expanded_Rows (P, Mass, Dense, I);
         pragma Loop_Invariant (Static => (if Work_Array (Mass) then Work_Array (Dense)));
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

   procedure Join_Projected_Entries
     (P : AR.Pattern; Row, First_Offset : Natural;
      Motions : Real_Array; Product : SK.Motion; Armature : Real;
      Target : Real_Array)
     with Ghost => Static, Global => null,
     Pre => Row < AR.Size (P) and then First_Offset < AR.Length (P, Row)
       and then Motions'First = 0 and then Motions'Last = 6 * AR.Size (P) - 1
       and then (for all X of Motions => X in -1.0e12 .. 1.0e12)
       and then SK.Bounded (Product, 1.0e54) and then Armature in 0.0 .. 1.0e10
       and then Int64 (Target'Length) = Int64 (AR.Length (P, Row))
       and then Target (Target'First + First_Offset) = Projected
         (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, First_Offset)), Product,
          Armature, First_Offset = AR.Length (P, Row) - 1)
       and then (for all K in Target'Range =>
         (if K > Target'First + First_Offset then Target (K) = Projected
           (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, K - Target'First)),
            Product, Armature, K = Target'Last))),
     Post => (for all K in Target'First + First_Offset .. Target'Last =>
       Target (K) = Projected
         (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, K - Target'First)),
          Product, Armature, K = Target'Last))
   is
   begin
      null;
   end Join_Projected_Entries;

   procedure Project_Row
     (P : AR.Pattern; Row : Natural; Motions : Real_Array; Product : SK.Motion;
      Armature : Real; Target : in out Real_Array; Ok : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Work_Array);
      Value : Real;
   begin
      Ok := False;
      for A in reverse 0 .. AR.Length (P, Row) - 1 loop
         Value := Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)),
                             Product, Armature, A = AR.Length (P, Row) - 1);
         if Value not in Work_Real then return; end if;
         pragma Assert (Static => (for all K in Target'Range =>
           (if K > Target'First + A then Target (K) = Projected
             (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, K - Target'First)),
              Product, Armature, K = Target'Last))));
         Store (Target, Target'First + A, Value);
         pragma Assert (Static => Target (Target'First + A) = Projected
           (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)), Product,
            Armature, A = AR.Length (P, Row) - 1));
         pragma Assert (Static => (for all K in Target'Range =>
           (if K > Target'First + A then Target (K) = Projected
             (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, K - Target'First)),
              Product, Armature, K = Target'Last))));
         Join_Projected_Entries (P, Row, A, Motions, Product, Armature, Target);
         pragma Loop_Invariant (Static => Work_Array (Target));
         pragma Loop_Invariant
           (Static => (for all K in Target'First + A .. Target'Last =>
             Target (K) = Projected
               (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, K - Target'First)),
                Product, Armature, K = Target'Last)));
      end loop;
      Ok := True;
   end Project_Row;
   procedure Project_Into_Row
     (P : AR.Pattern; Row : Natural; Motions : Real_Array; Product : SK.Motion;
      Armature : Real; Mass : in out Real_Array; Ok : out Boolean) is
      First : constant Natural := AR.Start (P, Row);
      Last : constant Natural := First + AR.Length (P, Row) - 1;
   begin
      Project_Row (P, Row, Motions, Product, Armature, Mass (First .. Last), Ok);
   end Project_Into_Row;

   procedure Assemble_Row
     (P : AR.Pattern; Row : Natural; Motions : Real_Array;
      Composite : SK.Inertia; Armature, Fixed : Real; Simple : Boolean;
      Target : in out Real_Array; Ok : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Work_Array);
   begin
      if Simple then
         Clear (Target);
         Store (Target, Target'Last, Fixed);
         Ok := True;
      else
         declare
            Product : constant SK.Motion := SK.Multiply
              (Composite, SS.Load_Motion (Motions, 6 * Row));
         begin
            Project_Row (P, Row, Motions, Product, Armature, Target, Ok);
         end;
      end if;
   end Assemble_Row;
   procedure Assemble_Into_Row
     (P : AR.Pattern; Row : Natural; Motions : Real_Array;
      Composite : SK.Inertia; Armature, Fixed : Real; Simple : Boolean;
      Mass : in out Real_Array; Ok : out Boolean) is
      First : constant Natural := AR.Start (P, Row);
      Last : constant Natural := First + (AR.Length (P, Row) - 1);
   begin
      Assemble_Row (P, Row, Motions, Composite, Armature, Fixed, Simple,
                    Mass (First .. Last), Ok);
   end Assemble_Into_Row;
end MJ.Compact_Inertia;

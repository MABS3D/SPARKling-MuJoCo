with MJ.Spatial_Kernels.Direct;

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

   procedure Prove_Projection_Equality
     (Motion, Left, Right : SK.Motion; Armature : Real; Diagonal : Boolean)
     with Ghost => Static, Global => null,
     Pre => SK.Bounded (Motion, 1.0e12) and then SK.Bounded (Left, 1.0e54)
       and then SK.Bounded (Right, 1.0e54) and then SK."=" (Left, Right)
       and then Armature in 0.0 .. 1.0e10,
     Post => Projected (Motion, Left, Armature, Diagonal) =
       Projected (Motion, Right, Armature, Diagonal)
   is
   begin
      declare
         L0 : constant Real range -2.0e66 .. 2.0e66 := Motion (0) * Left (0);
         R0 : constant Real range -2.0e66 .. 2.0e66 := Motion (0) * Right (0);
      begin
         pragma Assert (Static => L0 = R0);
         declare
            L1 : constant Real range -2.0e66 .. 2.0e66 := Motion (1) * Left (1);
            R1 : constant Real range -2.0e66 .. 2.0e66 := Motion (1) * Right (1);
         begin
            pragma Assert (Static => L1 = R1);
            declare
               L2 : constant Real range -2.0e66 .. 2.0e66 := Motion (2) * Left (2);
               R2 : constant Real range -2.0e66 .. 2.0e66 := Motion (2) * Right (2);
            begin
               pragma Assert (Static => L2 = R2);
               declare
                  L3 : constant Real range -2.0e66 .. 2.0e66 := Motion (3) * Left (3);
                  R3 : constant Real range -2.0e66 .. 2.0e66 := Motion (3) * Right (3);
               begin
                  pragma Assert (Static => L3 = R3);
                  declare
                     L4 : constant Real range -2.0e66 .. 2.0e66 := Motion (4) * Left (4);
                     R4 : constant Real range -2.0e66 .. 2.0e66 := Motion (4) * Right (4);
                  begin
                     pragma Assert (Static => L4 = R4);
                     declare
                        L5 : constant Real range -2.0e66 .. 2.0e66 := Motion (5) * Left (5);
                        R5 : constant Real range -2.0e66 .. 2.0e66 := Motion (5) * Right (5);
                     begin
                        pragma Assert (Static => L5 = R5);
                        declare
                           L02 : constant Real range -5.0e66 .. 5.0e66 := L0 + L2;
                           L13 : constant Real range -5.0e66 .. 5.0e66 := L1 + L3;
                           L45 : constant Real range -5.0e66 .. 5.0e66 := L4 + L5;
                           LQuad : constant Real range -1.0e67 .. 1.0e67 := L02 + L13;
                           LSum : constant Real range -1.0e68 .. 1.0e68 := LQuad + L45;
                           R02 : constant Real range -5.0e66 .. 5.0e66 := R0 + R2;
                           R13 : constant Real range -5.0e66 .. 5.0e66 := R1 + R3;
                           R45 : constant Real range -5.0e66 .. 5.0e66 := R4 + R5;
                           RQuad : constant Real range -1.0e67 .. 1.0e67 := R02 + R13;
                           RSum : constant Real range -1.0e68 .. 1.0e68 := RQuad + R45;
                        begin
                           pragma Assert (Static => L02 = R02);
                           pragma Assert (Static => L13 = R13);
                           pragma Assert (Static => L45 = R45);
                           pragma Assert (Static => LQuad = RQuad);
                           pragma Assert (Static => LSum = RSum);
                           pragma Assert (Static => SK.Dot (Motion, Left) = LSum);
                           pragma Assert (Static => SK.Dot (Motion, Right) = RSum);
                           pragma Assert (Static => SK.Dot (Motion, Left) = SK.Dot (Motion, Right));
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;
   end Prove_Projection_Equality;
   procedure Prove_Row_Projection_Equality
     (P : AR.Pattern; Row : Natural; Motions : Real_Array;
      Left, Right : SK.Motion; Armature : Real)
     with Ghost => Static, Global => null,
     Pre => Row < AR.Size (P) and then Motions'First = 0
       and then Motions'Last = 6 * AR.Size (P) - 1
       and then (for all X of Motions => X in -1.0e12 .. 1.0e12)
       and then SK.Bounded (Left, 1.0e54) and then SK.Bounded (Right, 1.0e54)
       and then SK."=" (Left, Right) and then Armature in 0.0 .. 1.0e10,
     Post => (for all A in 0 .. AR.Length (P, Row) - 1 =>
       Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)),
         Left, Armature, A = AR.Length (P, Row) - 1) =
       Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)),
         Right, Armature, A = AR.Length (P, Row) - 1))
   is
   begin
      for A in 0 .. AR.Length (P, Row) - 1 loop
         Prove_Projection_Equality
           (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)),
            Left, Right, Armature, A = AR.Length (P, Row) - 1);
         pragma Loop_Invariant (Static => (for all K in 0 .. A =>
           Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, K)),
             Left, Armature, K = AR.Length (P, Row) - 1) =
           Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, K)),
             Right, Armature, K = AR.Length (P, Row) - 1)));
      end loop;
   end Prove_Row_Projection_Equality;
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
            Product : constant SK.Motion := MJ.Spatial_Kernels.Direct.Multiply
              (Composite, SS.Load_Motion (Motions, 6 * Row));
            Expected : constant SK.Motion := SK.Multiply
              (Composite, SS.Load_Motion (Motions, 6 * Row)) with Ghost => Static;
         begin
            pragma Assert (Static => SK."=" (Product, Expected));
            Prove_Row_Projection_Equality (P, Row, Motions, Product, Expected, Armature);
            Project_Row (P, Row, Motions, Product, Armature, Target, Ok);
            pragma Assert (Static => Work_Array (Target));
            pragma Assert (Static => (if not Ok then
              (for some A in 0 .. AR.Length (P, Row) - 1 =>
                Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)),
                  Expected, Armature, A = AR.Length (P, Row) - 1) not in Work_Real)));
            pragma Assert (Static => (if Ok then
              (for all A in 0 .. AR.Length (P, Row) - 1 =>
                Target (Target'First + A) = Projected
                  (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)),
                   Expected, Armature, A = AR.Length (P, Row) - 1))));
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

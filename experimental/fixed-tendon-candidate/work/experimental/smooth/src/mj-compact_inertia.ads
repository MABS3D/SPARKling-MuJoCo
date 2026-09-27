with MJ.Types; use MJ.Types;
with MJ.Ancestor_Rows;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;
with MJ.Smooth_Kernels;
with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;

--  Values in full ancestor rows, root first and diagonal last. Expansion
--  belongs at the public dense API boundary, outside the stepping path.
package MJ.Compact_Inertia with SPARK_Mode is
   package AR renames MJ.Ancestor_Rows;
   package SK renames MJ.Spatial_Kernels;
   package SS renames MJ.Spatial_Storage;

   procedure Clear (Mass : out Real_Array) with Global => null,
     Post => Work_Array (Mass) and then (for all X of Mass => X = 0.0);
   pragma Inline_Always (Clear);
   procedure Store (Mass : in out Real_Array; Index : Natural; Value : Work_Real) with
     Global => null, Pre => Index in Mass'Range and then Work_Array (Mass),
     Post => Work_Array (Mass) and then Mass (Index) = Value
       and then (for all K in Mass'Range => (if K /= Index then Mass (K) = Mass'Old (K)));
   pragma Inline_Always (Store);

   function Lower_Entry (P : AR.Pattern; Mass : Real_Array;
                         Row, Col : Natural) return Real with
     Global => null,
     Pre => Row < AR.Size (P) and then Col <= Row
       and then Mass'First = 0 and then Mass'Last >= AR.Count (P) - 1,
     Post => (for all A in 0 .. AR.Length (P, Row) - 1 =>
                (if AR.Column (P, Row, A) = Col then
                   Lower_Entry'Result = Mass (AR.Start (P, Row) + A)))
       and then (if (for all A in 0 .. AR.Length (P, Row) - 1 =>
                       AR.Column (P, Row, A) /= Col) then Lower_Entry'Result = 0.0);

   --  Canonical indices make structural zeros and symmetry exact; this
   --  performs no floating-point arithmetic on stored mass entries.
   function Value_At (P : AR.Pattern; Mass : Real_Array;
                   Row, Col : Natural) return Real is
     (Lower_Entry (P, Mass, Natural'Max (Row, Col), Natural'Min (Row, Col))) with
     Global => null,
     Pre => Row < AR.Size (P) and then Col < AR.Size (P)
       and then Mass'First = 0 and then Mass'Last >= AR.Count (P) - 1;

   function Offset (N, Row, Col : Natural) return Natural
     renames MJ.Smooth_Kernels.Matrix_Offset;

   procedure Ordered_Rows (N, Earlier, Later : Natural) with
     Ghost => Static, Global => null,
     Pre => N <= AR.Max_Dofs and then Earlier < Later and then Later < N,
     Post => (for all J in 0 .. N - 1 => Offset (N, Earlier, J) < Offset (N, Later, 0));

   procedure Expand_Row
     (P : AR.Pattern; Mass : Real_Array; Row : Natural; Target : out Real_Array) with
     Global => null,
     Pre => Row < AR.Size (P) and then Mass'First = 0
       and then Mass'Last >= AR.Count (P) - 1
       and then Int64 (Target'Length) = Int64 (AR.Size (P)),
     Post => (for all J in 0 .. AR.Size (P) - 1 =>
       Target (Target'First + J) = Value_At (P, Mass, Row, J));

   procedure Expand (P : AR.Pattern; Mass : Real_Array; Dense : out Real_Array) with
     Global => null,
     Pre => Mass'First = 0 and then Mass'Last >= AR.Count (P) - 1
       and then Int64 (Dense'Length) = Int64 (AR.Size (P)) * Int64 (AR.Size (P)),
     Post => (for all I in 0 .. AR.Size (P) - 1 =>
       (for all J in 0 .. AR.Size (P) - 1 =>
         Dense (Dense'First + Offset (AR.Size (P), I, J)) = Value_At (P, Mass, I, J)))
       and then (for all I in 0 .. AR.Size (P) - 1 =>
         (for all J in 0 .. AR.Size (P) - 1 =>
           Dense (Dense'First + Offset (AR.Size (P), I, J)) =
             Dense (Dense'First + Offset (AR.Size (P), J, I))));

   function Projected (Motion, Product : SK.Motion; Armature : Real;
                       Diagonal : Boolean) return Real with
     Global => null,
     Pre => SK.Bounded (Motion, 1.0e12) and then SK.Bounded (Product, 1.0e54)
       and then Armature in 0.0 .. 1.0e10,
     Post => Projected'Result in -2.0e68 .. 2.0e68
       and then Projected'Result = (if Diagonal then Armature else 0.0)
         + SK.Dot (Motion, Product);
   pragma Inline (Projected);

   procedure Project_Row
     (P : AR.Pattern; Row : Natural; Motions : Real_Array; Product : SK.Motion;
      Armature : Real; Target : in out Real_Array; Ok : out Boolean) with
     Global => null,
     Pre => Row < AR.Size (P) and then Motions'First = 0
       and then Motions'Last = 6 * AR.Size (P) - 1
       and then (for all X of Motions => X in -1.0e12 .. 1.0e12)
       and then SK.Bounded (Product, 1.0e54) and then Armature in 0.0 .. 1.0e10
       and then Int64 (Target'Length) = Int64 (AR.Length (P, Row)) and then Work_Array (Target),
     Post => Work_Array (Target)
       and then (if not Ok then (for some A in 0 .. AR.Length (P, Row) - 1 =>
         Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)), Product,
                    Armature, A = AR.Length (P, Row) - 1) not in Work_Real))
       and then (if Ok then (for all A in 0 .. AR.Length (P, Row) - 1 =>
         Target (Target'First + A) = Projected
           (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)), Product,
            Armature, A = AR.Length (P, Row) - 1)));

   procedure Project_Into_Row
     (P : AR.Pattern; Row : Natural; Motions : Real_Array; Product : SK.Motion;
      Armature : Real; Mass : in out Real_Array; Ok : out Boolean) with
     Global => null,
     Pre => Row < AR.Size (P) and then Motions'First = 0
       and then Motions'Last = 6 * AR.Size (P) - 1
       and then (for all X of Motions => X in -1.0e12 .. 1.0e12)
       and then SK.Bounded (Product, 1.0e54) and then Armature in 0.0 .. 1.0e10
       and then Mass'First = 0 and then Mass'Last = AR.Count (P) - 1 and then Work_Array (Mass),
     Post => Work_Array (Mass)
       and then (for all K in Mass'Range =>
         (if K < AR.Start (P, Row) or else K >= AR.Start (P, Row) + AR.Length (P, Row)
          then Mass (K) = Mass'Old (K)))
       and then (if not Ok then (for some A in 0 .. AR.Length (P, Row) - 1 =>
         Projected (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)), Product,
                    Armature, A = AR.Length (P, Row) - 1) not in Work_Real))
       and then (if Ok then (for all A in 0 .. AR.Length (P, Row) - 1 =>
         Mass (AR.Start (P, Row) + A) = Projected
           (SS.Load_Motion (Motions, 6 * AR.Column (P, Row, A)), Product,
            Armature, A = AR.Length (P, Row) - 1)));
   pragma Inline_Always (Project_Into_Row);
end MJ.Compact_Inertia;

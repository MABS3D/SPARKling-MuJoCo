with MJ.Types; use MJ.Types;
with MJ.Native_Mass_Kernels;

-- Owned model image. Predicates concern used row spans; unused column values
-- are copied exactly and need not be valid DOF indices.
package MJ.Native_Mass_Patterns with SPARK_Mode is
   Max_Dofs : constant := 256;
   Max_Entries : constant := Max_Dofs * (Max_Dofs + 1) / 2;
   type Row_Descriptor is record
      First, Width : Natural := 0;
      Simple : Boolean := False;
      Fixed, Armature : Real := 0.0;
   end record;
   type Row_Array is array (Natural range 0 .. Max_Dofs - 1) of Row_Descriptor;
   subtype Column_Array is Int_Array (0 .. Max_Entries - 1);
   type Pattern is record
      Nv, Nc : Natural := 0;
      Shared : Boolean := False;
      Rows : Row_Array;
      Columns : Column_Array := [others => -1];
   end record;
   function Overlap (A, B : Row_Descriptor) return Boolean is
     (A.Width > 0 and then B.Width > 0
      and then Int64 (A.First) < Int64 (B.First) + Int64 (B.Width)
      and then Int64 (B.First) < Int64 (A.First) + Int64 (A.Width)) with Global => null;
   function Sharing_Model (Rows : Row_Array; Count : Natural) return Boolean is
     (for some I in 0 .. Count - 1 =>
       (for some J in 0 .. I - 1 => Overlap (Rows (I), Rows (J))))
     with Ghost => Static, Global => null, Pre => Count <= Max_Dofs;
   function Has_Sharing (Rows : Row_Array; Count : Natural) return Boolean with
     Global => null, Pre => Count <= Max_Dofs,
     Post => (Static => Has_Sharing'Result = Sharing_Model (Rows, Count));
   function Row_Valid (R : Row_Descriptor; Nc : Natural) return Boolean is
     (Nc <= Max_Entries and then R.Width in 1 .. Nc
      and then R.First <= Nc - R.Width) with Global => null;
   function Valid (P : Pattern) return Boolean is
     (P.Nv in 1 .. Max_Dofs and then P.Nc <= Max_Entries
      and then (for all R in 0 .. P.Nv - 1 => Row_Valid (P.Rows (R), P.Nc)
        and then (for all H in P.Rows (R).First ..
          (P.Rows (R).First + P.Rows (R).Width) - 1 => P.Columns (H) in 0 .. P.Nv - 1)))
     with Global => null;
   function Input_Layout
     (Widths, Addresses, Columns, Simple : Int_Array; Fixed, Arms : Real_Array;
      Nv, Nc : Natural) return Boolean is
     (Nv in 1 .. Max_Dofs and then Nc <= Max_Entries
      and then Widths'First = 0 and then Int64 (Widths'Length) = Int64 (Nv)
      and then Addresses'First = 0 and then Int64 (Addresses'Length) = Int64 (Nv)
      and then Columns'First = 0 and then Int64 (Columns'Length) = Int64 (Nc)
      and then Simple'First = 0 and then Int64 (Simple'Length) = Int64 (Nv)
      and then Fixed'First = 0 and then Int64 (Fixed'Length) = Int64 (Nv)
      and then Arms'First = 0 and then Int64 (Arms'Length) = Int64 (Nv)) with Global => null;
   function Input_Valid
     (Widths, Addresses, Columns, Simple : Int_Array; Fixed, Arms : Real_Array;
      Nv, Nc : Natural) return Boolean is
     (Input_Layout (Widths, Addresses, Columns, Simple, Fixed, Arms, Nv, Nc)
      and then (for all R in 0 .. Nv - 1 => Widths (R) in 1 .. Nc
        and then Addresses (R) in 0 .. Nc - Widths (R)
        and then (for all H in Addresses (R) .. (Addresses (R) + Widths (R)) - 1 =>
          Columns (H) in 0 .. Nv - 1))) with Global => null;
   function Matches
     (P : Pattern; Widths, Addresses, Columns, Simple : Int_Array;
      Fixed, Arms : Real_Array; Nv, Nc : Natural) return Boolean is
     (P.Nv = Nv and then P.Nc = Nc
      and then (for all R in 0 .. Nv - 1 =>
        P.Rows (R) = Row_Descriptor'(Addresses (R), Widths (R), Simple (R) > 0, Fixed (R), Arms (R)))
      and then (for all H in 0 .. Nc - 1 => P.Columns (H) = Columns (H)))
     with Ghost => Static, Global => null,
       Pre => Input_Valid (Widths, Addresses, Columns, Simple, Fixed, Arms, Nv, Nc);
   procedure Copy
     (Widths, Addresses, Columns, Simple : Int_Array; Fixed, Arms : Real_Array;
      Nv, Nc : Natural; P : out Pattern) with Global => null,
     Pre => Input_Valid (Widths, Addresses, Columns, Simple, Fixed, Arms, Nv, Nc),
     Post => Valid (P);
   pragma Postcondition (Static => Matches (P, Widths, Addresses, Columns, Simple, Fixed, Arms, Nv, Nc)
     and then P.Shared = Sharing_Model (P.Rows, Nv));

   function Used (P : Pattern; Count, Slot : Natural) return Boolean is
     (for some R in 0 .. Count - 1 =>
       Slot in P.Rows (R).First .. (P.Rows (R).First + P.Rows (R).Width) - 1)
     with Ghost => Static, Global => null, Pre => Valid (P) and then Count <= P.Nv;
   procedure Disjoint_Prefix (P : Pattern; Row : Natural) with
     Ghost => Static, Global => null,
     Pre => Valid (P) and then not Sharing_Model (P.Rows, P.Nv) and then Row < P.Nv,
     Post => (for all Earlier in 0 .. Row - 1 => not Overlap (P.Rows (Row), P.Rows (Earlier)));
   function Dense_Offset (Nv, Row, Column : Natural) return Natural is (Row * Nv + Column)
     with Global => null, Pre => Nv in 1 .. Max_Dofs and then Row < Nv and then Column < Nv,
       Post => Dense_Offset'Result < Nv * Nv and then Dense_Offset'Result = Row * Nv + Column;
   procedure Gather (P : Pattern; Dense : Real_Array; Mass : out Real_Array) with
     Global => null,
     Pre => Valid (P) and then not P.Shared
       and then Dense'First = 0 and then Dense'Last = P.Nv * P.Nv - 1
       and then Mass'First = 0 and then Int64 (Mass'Length) = Int64 (P.Nc),
     Post => (Static =>
       (for all R in 0 .. P.Nv - 1 => (for all H in P.Rows (R).First ..
         (P.Rows (R).First + P.Rows (R).Width) - 1 =>
           Mass (H) = Dense (Dense_Offset (P.Nv, R, P.Columns (H)))))
       and then (for all H in Mass'Range => (if not Used (P, P.Nv, H) then Mass (H) = 0.0)));
   pragma Precondition (Static => not Sharing_Model (P.Rows, P.Nv));
end MJ.Native_Mass_Patterns;

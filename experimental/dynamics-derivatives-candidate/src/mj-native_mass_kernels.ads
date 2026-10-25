with MJ.Types; use MJ.Types;

-- Exact storage operations used by the native CSR CRB reader. The contract
-- distinguishes assignment from accumulation: aliased row spans need both.
package MJ.Native_Mass_Kernels with SPARK_Mode is
   subtype Value is Real range -1.0e100 .. 1.0e100;
   function Bounded (Mass : Real_Array) return Boolean is
     (for all X of Mass => X in Value) with Global => null;
   procedure Zero (Mass : out Real_Array) with Global => null,
     Post => Bounded (Mass) and then (for all X of Mass => X = 0.0);
   procedure Update (Mass : in out Real_Array; Slot : Natural;
                     Change : Value; Assign : Boolean; Accepted : out Boolean)
     with Global => null, Pre => Slot in Mass'Range and then Bounded (Mass),
     Post => Bounded (Mass)
       and then Accepted = ((if Assign then Change else Mass'Old (Slot) + Change) in Value)
       and then (for all K in Mass'Range => Mass (K) =
         (if Accepted and then K = Slot then
            (if Assign then Change else Mass'Old (Slot) + Change)
          else Mass'Old (K)));
   procedure Gather_Row
     (Dense : Real_Array; Columns : Int_Array; Nv, Row, First, Width : Natural;
      Mass : in out Real_Array)
     with Global => null,
       Pre => Nv in 1 .. 256 and then Row < Nv
         and then Dense'First = 0 and then Dense'Last = Nv * Nv - 1
         and then Mass'First = 0 and then Mass'Length <= 32_896
         and then First <= Mass'Length and then Width <= Mass'Length - First
         and then Columns'First = 0 and then Columns'Length >= Mass'Length
         and then (for all H in First .. (First + Width) - 1 => Columns (H) in 0 .. Nv - 1),
       Post => (for all H in Mass'Range => Mass (H) =
         (if H in First .. (First + Width) - 1 then Dense (Row * Nv + Columns (H))
          else Mass'Old (H)));
end MJ.Native_Mass_Kernels;

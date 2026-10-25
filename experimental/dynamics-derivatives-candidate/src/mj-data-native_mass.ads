with MJ.Native_Mass_Patterns;
with MJ.Native_Mass_Models;
with MJ.Models.Validity;
-- Native storage image for inverseFD. No model pointer survives Capture.
-- The owned image and disjoint gather have exact functional models. The shared
-- CRB reader and full workspace composition remain separate proof obligations.
package MJ.Data.Native_Mass with SPARK_Mode is
   package NP renames MJ.Native_Mass_Patterns;
   package NM renames MJ.Native_Mass_Models;
   Max_Entries : constant := NP.Max_Entries;
   type Pattern is private;
   function Has_Shared_Slots (P : Pattern) return Boolean with Global => null;
   function Snapshot (P : Pattern) return NP.Pattern with Ghost => Static, Global => null;
   function Matches_Model (P : Pattern; M : MJ.Models.Model) return Boolean
     with Ghost => Static, Global => null;
   procedure Capture (M : MJ.Models.Model; P : out Pattern; Result : out Status)
     with Post => (Static => (if Result = Success then Matches_Model (P, M)));
   procedure Capture_Validated (M : MJ.Models.Model; P : out Pattern; Result : out Status)
     with Pre => MJ.Models.Valid_Layout (M) and then MJ.Models.Validity.Is_Valid (M),
       Post => (Static => (if Result = Success then Matches_Model (P, M)));
   procedure Evaluate (D : Simulation; P : Pattern; Mass : out Real_Array;
                       Result : out Status)
     with Global => null, Pre => Is_Ready (D) and then Mass_Current (D),
       Post => (Static => (if not Has_Shared_Slots (P) then
         (if Snapshot (P).Nv in 1 .. Max_Dofs
            and then Snapshot (P).Nv = Velocity_Count (D)
            and then Mass'First = 0
            and then Int64 (Mass'Length) = Int64 (Snapshot (P).Nc)
          then Result = Success and then NP.Valid (Snapshot (P))
            and then (for all R in 0 .. Snapshot (P).Nv - 1 =>
              (for all H in Snapshot (P).Rows (R).First ..
                (Snapshot (P).Rows (R).First + Snapshot (P).Rows (R).Width) - 1 =>
                  Mass (H) = Mass_Entry (D, R, Snapshot (P).Columns (H))))
            and then (for all H in Mass'Range =>
              (if not NP.Used (Snapshot (P), Snapshot (P).Nv, H) then Mass (H) = 0.0))
          else Result = Invalid_Size and then (for all X of Mass => X = 0.0))));
private
   function Consistent (P : Pattern) return Boolean with Global => null;
   type Pattern is record
      Value : NP.Pattern;
   end record with Type_Invariant => Consistent (Pattern);
   function Has_Shared_Slots (P : Pattern) return Boolean is (P.Value.Shared);
   function Snapshot (P : Pattern) return NP.Pattern is (P.Value);
   function Consistent (P : Pattern) return Boolean is (NM.Consistent (P.Value));
   function Matches_Model (P : Pattern; M : MJ.Models.Model) return Boolean is (NM.Matches_Model (P.Value, M));
end MJ.Data.Native_Mass;

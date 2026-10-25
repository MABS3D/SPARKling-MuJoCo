with MJ.Types; use MJ.Types;
with MJ.Ancestor_Rows;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;
with MJ.Spatial_Tendon_Models;
with MJ.Tendon_Kernels;

--  Apply the captured C tendon-mass plan in its original order, directly to
--  compact ancestor rows. Missing structural entries report an unusable plan;
--  callers may then retain the dense compatibility path without dropping terms.
package MJ.Compact_Tendon_Mass with SPARK_Mode is
   package AR renames MJ.Ancestor_Rows;
   package TM renames MJ.Spatial_Tendon_Models;
   package TK renames MJ.Tendon_Kernels;
   function Slot (P : AR.Pattern; Row, Col : Natural) return Integer with
     Global => null, Pre => Row < AR.Size (P) and then Col <= Row,
     Post => Slot'Result in -1 .. Integer (AR.Count (P)) - 1
       and then (for all A in 0 .. AR.Length (P, Row) - 1 =>
         (if AR.Column (P, Row, A) = Col then Slot'Result = AR.Start (P, Row) + A))
       and then (if Slot'Result >= 0 then
         Slot'Result = AR.Start (P, Row) + (AR.Length (P, Col) - 1)
         and then AR.Length (P, Col) <= AR.Length (P, Row)
         and then AR.Column (P, Row, AR.Length (P, Col) - 1) = Col)
       and then (if (for all A in 0 .. AR.Length (P, Row) - 1 =>
         AR.Column (P, Row, A) /= Col) then Slot'Result = -1);
   pragma Inline (Slot);
   function Matrix_Slot (P : AR.Pattern; Index : Natural) return Integer is
     (Slot (P, Natural'Max (Index / AR.Size (P), Index mod AR.Size (P)),
               Natural'Min (Index / AR.Size (P), Index mod AR.Size (P)))) with
     Global => null,
     Pre => AR.Size (P) > 0 and then Index < AR.Size (P) * AR.Size (P),
     Post => Matrix_Slot'Result in -1 .. Integer (AR.Count (P)) - 1;
   pragma Inline (Matrix_Slot);

   procedure Add (Mass : in out Real_Array; Index : Natural; Change : TK.Mass_Change)
     with Global => null, Pre => Index in Mass'Range and then Work_Array (Mass),
     Post => Work_Array (Mass)
       and then Mass (Index) = TK.Accumulate_Mass (Mass'Old (Index), Change)
       and then (for all K in Mass'Range =>
         (if K /= Index then Mass (K) = Mass'Old (K)));
   pragma Inline_Always (Add);

   function Model (C : TM.Description; P : AR.Pattern; Initial : Real_Array;
                   Index, Count : Natural) return TK.Mass_Value is
     (if Count = 0 then Initial (Index)
      elsif Matrix_Slot (P, C.Mass (Count).Index) = Index then
        TK.Accumulate_Mass (Model (C, P, Initial, Index, Count - 1), C.Mass (Count).Value)
      else Model (C, P, Initial, Index, Count - 1))
     with Ghost => Static, Global => null,
     Pre => TM.Mass_Ready (C, AR.Size (P)) and then Count <= C.Nm
       and then Initial'First = 0 and then Initial'Last = AR.Count (P) - 1
       and then Index in Initial'Range and then Work_Array (Initial),
     Post => Model'Result in TK.Mass_Value
       and then (if Count = 0 then Model'Result = Initial (Index)),
     Subprogram_Variant => (Decreases => Count);
   procedure Unfold_Model
     (C : TM.Description; P : AR.Pattern; Initial : Real_Array; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => TM.Mass_Ready (C, AR.Size (P)) and then Count in 1 .. C.Nm
       and then Initial'First = 0 and then Initial'Last = AR.Count (P) - 1
       and then Work_Array (Initial),
     Post => (for all H in Initial'Range => Model (C, P, Initial, H, Count) =
       (if Matrix_Slot (P, C.Mass (Count).Index) = H then
          TK.Accumulate_Mass (Model (C, P, Initial, H, Count - 1), C.Mass (Count).Value)
        else Model (C, P, Initial, H, Count - 1)));
   procedure Accumulate (C : TM.Description; P : AR.Pattern;
                         Mass : in out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => TM.Mass_Ready (C, AR.Size (P))
       and then Mass'First = 0 and then Mass'Last = AR.Count (P) - 1
       and then Work_Array (Mass),
     Post => Work_Array (Mass)
       and then Ok = (for all K in 1 .. C.Nm => Matrix_Slot (P, C.Mass (K).Index) >= 0);
   pragma Postcondition (Static => (if Ok then (for all H in Mass'Range =>
     Mass (H) = Model (C, P, Mass'Old, H, C.Nm))));
end MJ.Compact_Tendon_Mass;

with MJ.Types; use MJ.Types;
package MJ.Advanced_State with SPARK_Mode is
   function Clip (Value, Lower, Upper : Tier0_Real; Apply_Limit : Boolean) return Tier0_Real
     with Global => null, Pre => Lower <= Upper,
     Post => Clip'Result = (if Apply_Limit then Real'Min (Upper, Real'Max (Lower, Value)) else Value);
   function Next_Value (Value : Tier0_Real; Rate : Real; H : Nonneg_Tier0) return Real
     with Global => null, Pre => Rate in -1.0e100 .. 1.0e100,
     Post => Next_Value'Result = Value + Rate * H;
   function PID_Count (Slew, Integral : Tier0_Real) return Natural
     with Global => null, Post => PID_Count'Result = Boolean'Pos (Slew > 0.0) + Boolean'Pos (Integral > 0.0);
   --  Activation staging keeps the C clamp order. Even an invalid value
   --  may be admitted for evaluation: it clears Can_Advance without writing.
   function Staged_Value (Value : Real; Lower, Upper : Tier0_Real;
                          Apply_Limit : Boolean) return Real is
     (if Apply_Limit then Real'Min (Upper, Real'Max (Lower, Value)) else Value)
     with Global => null,
       Post => Staged_Value'Result =
         (if Apply_Limit then Real'Min (Upper, Real'Max (Lower, Value)) else Value)
         and then (if Apply_Limit then Staged_Value'Result in Tier0_Real);

   procedure Stage_Activation
     (Next_Act : in out Real_Array; Can_Advance : in out Boolean;
      Base, Offset : Natural; Value : Real; Lower, Upper : Tier0_Real;
      Apply_Limit : Boolean)
     with Global => null,
       --  Static admission preserves the existing Constraint_Error boundary
       --  for an invalid private index; the caller must still prove this VC.
       Pre => (Static => (if Staged_Value (Value, Lower, Upper, Apply_Limit) in Tier0_Real then
         Base <= Natural'Last - Offset and then Base + Offset in Next_Act'Range)),
       Post => Can_Advance =
         (Can_Advance'Old and then Staged_Value (Value, Lower, Upper, Apply_Limit) in Tier0_Real)
         and then (for all I in Next_Act'Range => Next_Act (I) =
           (if Staged_Value (Value, Lower, Upper, Apply_Limit) in Tier0_Real
              and then I = Base + Offset
            then Staged_Value (Value, Lower, Upper, Apply_Limit)
            else Next_Act'Old (I)));
end MJ.Advanced_State;

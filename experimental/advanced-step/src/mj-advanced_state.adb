package body MJ.Advanced_State with SPARK_Mode is
   function Clip (Value, Lower, Upper : Tier0_Real; Apply_Limit : Boolean) return Tier0_Real is
   begin
      return (if Apply_Limit then Real'Min (Upper, Real'Max (Lower, Value)) else Value);
   end Clip;
   function Next_Value (Value : Tier0_Real; Rate : Real; H : Nonneg_Tier0) return Real is
   begin
      return Value + Rate * H;
   end Next_Value;
   function PID_Count (Slew, Integral : Tier0_Real) return Natural is
   begin
      return Boolean'Pos (Slew > 0.0) + Boolean'Pos (Integral > 0.0);
   end PID_Count;
end MJ.Advanced_State;

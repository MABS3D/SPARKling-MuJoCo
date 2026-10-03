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
end MJ.Advanced_State;

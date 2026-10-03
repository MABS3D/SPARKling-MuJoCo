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
   procedure Stage_Activation
     (Next_Act : in out Real_Array; Can_Advance : in out Boolean;
      Base, Offset : Natural; Value : Real; Lower, Upper : Tier0_Real;
      Apply_Limit : Boolean) is
      X : constant Real := Staged_Value (Value, Lower, Upper, Apply_Limit);
   begin
      if X not in Tier0_Real then
         Can_Advance := False;
      else
         Next_Act (Base + Offset) := X;
      end if;
   end Stage_Activation;
end MJ.Advanced_State;

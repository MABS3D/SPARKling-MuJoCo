with Ada.Numerics.Long_Elementary_Functions;
package body MJ.Activation with SPARK_Mode is
   function Exact_Factor (H : Nonneg_Tier0; Tau : Time_Constant) return Decay_Factor is
      X : constant Real := H / Tau;
      E : Real;
   begin
      if H = 0.0 then return 0.0; end if;
      --  exp(-40) is below half an ulp at one: the C factor rounds to 1.
      --  This also keeps the elementary-function argument in a small domain.
      if X > 40.0 then return 1.0; end if;
      declare
         subtype Small_Exponent is Real range -40.0 .. 0.0;
         Argument : constant Small_Exponent := -X;
      begin
         E := Ada.Numerics.Long_Elementary_Functions.Exp (Argument);
      end;
      if E in Decay_Factor then return 1.0 - E; end if;
      return (if E < 0.0 then 1.0 else 0.0);
   end Exact_Factor;
   function Next_Value (Kind : Dynamics; Act : Tier0_Real; Dot : Rate;
      H : Nonneg_Tier0; Tau : Time_Constant; Factor : Decay_Factor;
      Has_Limit : Boolean; Lower, Upper : Tier0_Real) return Update_Value is
      Value : constant Update_Value := Raw_Next (Kind, Act, Dot, H, Tau, Factor);
   begin
      if Has_Limit then return Real'Max (Lower, Real'Min (Upper, Value)); end if;
      return Value;
   end Next_Value;
   procedure Prepare (Kind : Dynamics; U, Act : Tier0_Real;
      H : Nonneg_Tier0; Tau : Time_Constant; Factor : Decay_Factor;
      Enabled, Early, Has_Limit : Boolean; Lower, Upper : Tier0_Real;
      Dot : out Rate; Next, Drive : out Tier0_Real; Ok : out Boolean) is
      Candidate : Update_Value;
   begin
      Dot := 0.0; Next := Act; Drive := Act; Ok := True;
      if Enabled then
         Dot := Derivative (Kind, U, Act, Tau);
         Candidate := Next_Value (Kind, Act, Dot, H, Tau, Factor, Has_Limit, Lower, Upper);
         Ok := Candidate in Tier0_Real;
         if not Ok then return; end if;
         Next := Candidate;
      end if;
      if Early then Drive := Next; end if;
   end Prepare;
end MJ.Activation;

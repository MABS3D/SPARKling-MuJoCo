with MJ.Types; use MJ.Types;
package MJ.Activation with SPARK_Mode is
   type Dynamics is (None, Integrator, Filter, Filter_Exact);
   subtype Time_Constant is Real range 1.0e-15 .. 1.0e10;
   subtype Decay_Factor is Real range 0.0 .. 1.0;
   subtype Rate is Real range -2.1e25 .. 2.1e25;
   type Value_Array is array (Natural range <>) of Tier0_Real;
   type Rate_Array is array (Natural range <>) of Rate;
   subtype Update_Value is Real range -5.0e35 .. 5.0e35;
   function Exact_Factor (H : Nonneg_Tier0; Tau : Time_Constant) return Decay_Factor
     with Global => null;
   --  Exp is evaluated once at model creation; the hot path retains C's
   --  multiply order: (derivative * tau) * (1 - exp(-h/tau)).
   function Derivative (Kind : Dynamics; U, Act : Tier0_Real; Tau : Time_Constant) return Rate is
     (case Kind is when None => 0.0, when Integrator => U,
       when Filter | Filter_Exact => (U - Act) / Tau) with Global => null;
   function Raw_Next (Kind : Dynamics; Act : Tier0_Real; Dot : Rate;
      H : Nonneg_Tier0; Tau : Time_Constant; Factor : Decay_Factor) return Update_Value is
     (if Kind = None then Act
      elsif Kind = Filter_Exact then Act + (Dot * Tau) * Factor
      else Act + Dot * H) with Global => null;
   function Next_Value (Kind : Dynamics; Act : Tier0_Real; Dot : Rate;
      H : Nonneg_Tier0; Tau : Time_Constant; Factor : Decay_Factor;
      Has_Limit : Boolean; Lower, Upper : Tier0_Real) return Update_Value
     with Global => null, Pre => (if Has_Limit then Lower <= Upper),
     Post => Next_Value'Result =
       (if Has_Limit then Real'Max (Lower, Real'Min (Upper,
         Raw_Next (Kind, Act, Dot, H, Tau, Factor)))
        else Raw_Next (Kind, Act, Dot, H, Tau, Factor));
   procedure Prepare (Kind : Dynamics; U, Act : Tier0_Real;
      H : Nonneg_Tier0; Tau : Time_Constant; Factor : Decay_Factor;
      Enabled, Early, Has_Limit : Boolean; Lower, Upper : Tier0_Real;
      Dot : out Rate; Next, Drive : out Tier0_Real; Ok : out Boolean)
     with Global => null, Pre => (if Has_Limit then Lower <= Upper),
     Post => Dot = (if Enabled then Derivative (Kind, U, Act, Tau) else 0.0)
       and then Ok = (not Enabled or else
         Next_Value (Kind, Act, Dot, H, Tau, Factor, Has_Limit, Lower, Upper) in Tier0_Real)
       and then Next = (if Enabled and then Ok then
         Next_Value (Kind, Act, Dot, H, Tau, Factor, Has_Limit, Lower, Upper) else Act)
       and then Drive = (if Early and then Ok then Next else Act);
end MJ.Activation;

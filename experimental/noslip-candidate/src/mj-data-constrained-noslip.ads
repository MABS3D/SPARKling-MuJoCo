with MJ.NoSlip;
package MJ.Data.Constrained.NoSlip with SPARK_Mode is
   --  Additive opt-in entry: no shared parent engine source is replaced.
   type Engine is limited private;
   subtype Trace is MJ.Data.Constrained.Trace;
   function Ready (E : Engine) return Boolean with Global => null;
   function State (E : Engine) return Real_Array with Global => null;
   function Complete_State (E : Engine) return Real_Array with Global => null;
   function Activation_Count (E : Engine) return Natural with Global => null;
   function Activation_Values (E : Engine) return Real_Array with Global => null;
   function Activation_Rates (E : Engine) return Real_Array with Global => null;
   function Diagnostics (E : Engine) return Trace with Global => null;
   function NoSlip_Diagnostics (E : Engine) return MJ.NoSlip.Report with Global => null;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status)
     with Post => M.Opt.Disableflags = M.Opt.Disableflags'Old
       and then M.Opt.Noslip_Iterations = M.Opt.Noslip_Iterations'Old
       and then (if Result = Success then Ready (E));
   procedure Free (E : in out Engine; Result : out Status);
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Status);
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status);
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => Complete_State (E) = Complete_State (E)'Old);
   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => (if Result /= Success then Complete_State (E) = Complete_State (E)'Old));
private
   type Engine is limited record
      Base : MJ.Data.Constrained.Engine;
      Settings : MJ.NoSlip.Options;
      Report : MJ.NoSlip.Report;
   end record;
end MJ.Data.Constrained.NoSlip;

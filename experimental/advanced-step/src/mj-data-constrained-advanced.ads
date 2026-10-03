with MJ.Data.Advanced_Control;
package MJ.Data.Constrained.Advanced with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   type Engine is limited private;
   function Ready (E : Engine) return Boolean with Global => null;
   function State (E : Engine) return Real_Array with Global => null;
   function Inputs (E : Engine) return Real_Array with Global => null;
   function Activation (E : Engine) return Real_Array with Global => null;
   function Rates (E : Engine) return Real_Array with Global => null;
   function Control_Count (E : Engine) return Natural with Global => null;
   function Output_Count (E : Engine) return Natural with Global => null;
   function Position_Count (E : Engine) return Natural with Global => null;
   function Velocity_Count (E : Engine) return Natural with Global => null;
   function Lengths (E : Engine) return Real_Array with Global => null;
   function Velocities (E : Engine) return Real_Array with Global => null;
   function Forces (E : Engine) return Real_Array with Global => null;
   function Generalized (E : Engine) return Real_Array with Global => null;
   function Accelerations (E : Engine) return Real_Array with Global => null;
   function Diagnostics (E : Engine) return Trace with Global => null;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status)
     with Post => M.Opt.Disableflags = M.Opt.Disableflags'Old
       and then M.Flg_Adhesion = M.Flg_Adhesion'Old
       and then (if Result = Success then Ready (E));
   procedure Free (E : in out Engine) with Post => not Ready (E);
   procedure Reset (E : in out Engine; Result : out Status);
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        Clock : Nonneg_Tier0; Result : out Status);
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status);
   procedure Set_Applied (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   procedure Evaluate (E : in out Engine; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => State (E) = State (E)'Old and then Inputs (E) = Inputs (E)'Old);
   procedure Step (E : in out Engine; Result : out Status;
                  External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => Inputs (E) = Inputs (E)'Old
       and then (if Result /= Success then State (E) = State (E)'Old));
private
   package AC renames MJ.Data.Advanced_Control;
   type Engine is limited record
      Base : MJ.Data.Constrained.Engine;
      Control : AC.Controller;
   end record;
end MJ.Data.Constrained.Advanced;

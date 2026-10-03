with MJ.Plugin_Protocol;
with MJ.Plugin_Runtime;
with MJ.External_Forces;
generic
   with procedure Invoke
     (H : MJ.Plugin_Protocol.Hook; Kind : MJ.Plugin_Protocol.Capability;
      Instance : Natural; C : MJ.Plugin_Protocol.Configuration;
      F : MJ.Plugin_Protocol.Frame; State : in out MJ.Plugin_Protocol.Values;
      Output : in out MJ.Plugin_Protocol.Outputs; Accepted : out Boolean);
package MJ.Data.Plugin_Engine with SPARK_Mode is
   package P renames MJ.Plugin_Protocol;
   package R is new MJ.Plugin_Runtime (Invoke);
   type Engine is limited private;
   procedure Create (M : MJ.Models.Model; Config : P.Configurations;
                     E : in out Engine; Result : out Status);
   procedure Free (E : in out Engine; Result : out Status);
   procedure Reset (E : in out Engine; Result : out Status);
   procedure Set_State (E : in out Engine; Q, V : State_Vector;
                        Clock : Nonneg_Tier0; Result : out Status);
   procedure Set_Control (E : in out Engine; I : Natural; V : Tier0_Real; Result : out Status);
   procedure Set_Activation (E : in out Engine; A : State_Vector; Result : out Status);
   procedure Set_Applied_Force (E : in out Engine; I : Natural; V : Tier0_Real; Result : out Status);
   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
   function Ready (E : Engine) return Boolean;
   function State (E : Engine) return Real_Array;
   function Activation (E : Engine) return Real_Array;
   function Diagnostics (E : Engine) return P.Outputs;
   function Plugin_State (E : Engine; Instance : Natural) return P.Values;
   function Acceleration (E : Engine) return Real_Array;
   procedure SDF_Query (E : in out Engine; Instance : Natural; Point : P.Values;
                        Distance : out P.Value; Gradient : out P.Values; Result : out Status);
   procedure Copy_State (Source : Engine; Dest : in out Engine; Result : out Status);
private
   type Owners is array (Natural range 0 .. P.Max_Outputs - 1) of Integer range -1 .. P.Max_Instances - 1;
   type Stages is array (Natural range 0 .. P.Max_Outputs - 1) of P.Stage;
   type Flags is array (Natural range 0 .. P.Max_Outputs - 1) of Boolean;
   type Engine is limited record
      D : Simulation;
      Plugins : R.Runtime;
      Actuator_Owner, Sensor_Owner : Owners := [others => -1];
      Sensor_Stage : Stages := [others => P.None];
      Sensor_Positive : Flags := [others => False];
      Sensor_Cutoff : P.Values (0 .. P.Max_Outputs - 1) := [others => 0.0];
      Ns : Natural range 0 .. P.Max_Outputs := 0;
      Sensor_Enabled, Passive_Enabled : Boolean := True;
   end record;
   function Context (E : Engine) return P.Frame;
   procedure Evaluate_Internal (E : in out Engine; Result : out Status;
                               External : MJ.External_Forces.Wrench_Array);
end MJ.Data.Plugin_Engine;

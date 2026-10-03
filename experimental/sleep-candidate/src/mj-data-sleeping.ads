with MJ.Models;
with MJ.External_Forces;
with MJ.Sleep_Manager;
--  Opt-in owned smooth simulation with native sleep management. This separate
--  entry does not change the concurrently edited ordinary/constrained engines.
package MJ.Data.Sleeping with SPARK_Mode is
   type Engine is limited private;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status);
   procedure Free (E : in out Engine);
   procedure Reset (E : in out Engine; Result : out Status);
   procedure Step (E : in out Engine; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
     New_Time : Nonneg_Tier0; Result : out Status);
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   procedure Enable (E : in out Engine; Value : Boolean);
   function Ready (E : Engine) return Boolean;
   function State (E : Engine) return Real_Array;
   function Tree_Asleep (E : Engine; Tree : Natural) return Integer;
   function Awake_Dofs (E : Engine) return Natural;
private
   package SM renames MJ.Sleep_Manager;
   type Topology_Access is access SM.Topology;
   type Sleep_Access is access SM.State;
   type Islands_Access is access SM.Islands;
   type Positions is array (Natural range <>) of Vector;
   type Orientations is array (Natural range <>) of Quaternion;
   type Engine is limited record
      D : Simulation;
      M : Topology_Access := null;
      S : Sleep_Access := null;
      I : Islands_Access := null;
      Enabled : Boolean := False;
      Tolerance : Nonneg_Tier0 := 0.0;
      Previous_Pos : Positions (0 .. Max_Bodies-1);
      Previous_Quat : Orientations (0 .. Max_Bodies-1);
      Have_Frame : Boolean := False;
   end record;
end MJ.Data.Sleeping;

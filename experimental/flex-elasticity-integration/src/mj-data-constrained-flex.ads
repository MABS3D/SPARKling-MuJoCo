with MJ.Data.Flex_Elasticity;
with MJ.Flex_State;

-- Shared rigid state, elastic forces and constraint response. Vertex sides
-- use a single real body; non-interpolated element sides use ordered weights.
package MJ.Data.Constrained.Flex with SPARK_Mode is
   type Engine is limited private;
   subtype Trace is MJ.Data.Constrained.Trace;
   function Ready (E : Engine) return Boolean with Global => null;
   function State (E : Engine) return Real_Array with Global => null;
   function Complete_State (E : Engine) return Real_Array with Global => null;
   function Diagnostics (E : Engine) return Trace with Global => null;
   function Passive (E : Engine) return Real_Array with Global => null;
   function Contacts (E : Engine) return MJ.Flex_State.Contact_Array;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status);
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
   package FE renames MJ.Data.Flex_Elasticity;
   package FS renames MJ.Flex_State;
   type Vertex_Body_Array is array (Natural range 0 .. FE.Max_Vertices - 1) of Natural;
   type Flex_Address_Array is array (Natural range 0 .. FE.Max_Flexes - 1) of Natural;
   type Engine is limited record
      Base : MJ.Data.Constrained.Engine;
      Elastic : FE.Force_Model;
      Scene : FS.State;
      Pending : FS.Contact_List (Max_C);
      Bodies : Vertex_Body_Array := [others => 0];
      Address, Count : Flex_Address_Array := [others => 0];
      Nf, Nv : Natural := 0;
   end record;
end MJ.Data.Constrained.Flex;

with MJ.Data.Advanced_Control;
with MJ.Actuator_Math;
with MJ.Actuator_Transmissions;
with MJ.Transmissions;
with MJ.External_Forces;
package MJ.Data.Advanced with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   Max_Controls : constant := 4 * Max_Actuators;
   Max_Outputs : constant := 3 * Max_Actuators;
   type Engine is limited private;
   function Ready (E : Engine) return Boolean with Global => null;
   function State (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Inputs (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Activation (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Rates (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Control_Count (E : Engine) return Natural with Global => null;
   function Output_Count (E : Engine) return Natural with Global => null;
   function Position_Count (E : Engine) return Natural with Global => null;
   function Velocity_Count (E : Engine) return Natural with Global => null;
   function Lengths (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Velocities (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Forces (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Generalized (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   function Accelerations (E : Engine) return Real_Array with Global => null, Pre => Ready (E);
   procedure Create (M : MJ.Models.Model; E : in out Engine; Result : out Status)
     with Global => null, Post => (if Result = Success then Ready (E));
   procedure Free (E : in out Engine) with Global => null, Post => not Ready (E);
   procedure Reset (E : in out Engine; Result : out Status) with Global => null;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        Clock : Nonneg_Tier0; Result : out Status) with Global => null;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real;
                          Result : out Status) with Global => null;
   procedure Set_Activation (E : in out Engine; Values : State_Vector;
                            Result : out Status) with Global => null;
   procedure Set_Applied (E : in out Engine; Index : Natural; Value : Tier0_Real;
                         Result : out Status) with Global => null;
   procedure Evaluate (E : in out Engine; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Global => null,
       Post => (if Ready (E)'Old then Ready (E)
         and then State (E) = State (E)'Old and then Inputs (E) = Inputs (E)'Old);
   procedure Step (E : in out Engine; Result : out Status;
                  External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Global => null,
       Post => (if Ready (E)'Old then Ready (E) and then Inputs (E) = Inputs (E)'Old
         and then (if Result /= Success then State (E) = State (E)'Old));
private
   package AC renames MJ.Data.Advanced_Control;
   type Engine is limited record
      D : Simulation;
      C : AC.Controller;
   end record;
end MJ.Data.Advanced;

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
   package AM renames MJ.Actuator_Math;
   package TX renames MJ.Actuator_Transmissions;
   type Configuration is record
      Dyn_Kind, Gain_Kind, Bias_Kind : Natural := 0;
      Trn, Joint_Kind, Qadr, Vadr : Natural := 0;
      Uadr, Oadr, Aadr, Nu, No, Na, Spec, Group : Natural := 0;
      Gain, Dyn, Bias : AM.Parameters := [others => 0.0];
      Gear : TX.Gear_Vector := [others => 0.0];
      Early, Force_Limited, Act_Limited : Boolean := False;
      Force_Lo, Force_Hi, Act_Lo, Act_Hi, Period : Tier0_Real := 0.0;
      Length_Lo, Length_Hi, Acc0 : Tier0_Real := 0.0;
      Site_Body, Reference_Body : Natural := 0;
      Site_Quat, Reference_Quat : AM.Quaternion := AM.Identity;
      Site_SO3 : Boolean := False;
      Common : MJ.Transmissions.Mask (0 .. Max_Dofs - 1) := [others => False];
   end record;
   type Config_Array is array (Natural range <>) of Configuration;
   type Bool_Array is array (Natural range <>) of Boolean;
   type Engine is limited record
      D : Simulation;
      Initialized, Valid, Can_Advance, Has_Sites : Boolean := False;
      Nu : Natural range 0 .. Max_Controls := 0;
      No : Natural range 0 .. Max_Outputs := 0;
      Na, Nactuator : Natural range 0 .. Max_Actuators := 0;
      Disabled_Groups : Natural := 0;
      Config : Config_Array (0 .. Max_Actuators - 1);
      Control : Real_Array (0 .. Max_Controls - 1) := [others => 0.0];
      Control_Lo, Control_Hi : State_Vector (0 .. Max_Controls - 1) := [others => 0.0];
      Control_Limited : Bool_Array (0 .. Max_Controls - 1) := [others => False];
      Act, Next_Act, Dot : Real_Array (0 .. Max_Actuators - 1) := [others => 0.0];
      L, V, F : Real_Array (0 .. Max_Outputs - 1) := [others => 0.0];
      Qforce, Acc : Real_Array (0 .. Max_Dofs - 1) := [others => 0.0];
      Rows : TX.Result (3 * Max_Dofs - 1);
   end record;
end MJ.Data.Advanced;

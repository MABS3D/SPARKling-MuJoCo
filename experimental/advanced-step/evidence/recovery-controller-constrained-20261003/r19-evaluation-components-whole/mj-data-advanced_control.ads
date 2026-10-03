with MJ.Controller_Array_Kernels;
with MJ.Actuator_Math;
with MJ.Actuator_Transmissions;
with MJ.Transmissions;
with MJ.External_Forces;
--  Controller configuration and activation state; Simulation is supplied by
--  the caller, so smooth and constrained pipelines share one owned state.
package MJ.Data.Advanced_Control with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   Max_Controls : constant := 4 * Max_Actuators;
   Max_Outputs : constant := 3 * Max_Actuators;
   type Controller is limited private;
   function Ready (E : Controller) return Boolean with Global => null;
   function Inputs (E : Controller) return Real_Array with Global => null;
   function Activation (E : Controller) return Real_Array with Global => null;
   function Rates (E : Controller) return Real_Array with Global => null;
   function Control_Count (E : Controller) return Natural with Global => null;
   function Output_Count (E : Controller) return Natural with Global => null;
   function Position_Count (E : Controller) return Natural with Global => null;
   function Velocity_Count (E : Controller) return Natural with Global => null;
   function Lengths (E : Controller) return Real_Array with Global => null;
   function Velocities (E : Controller) return Real_Array with Global => null;
   function Forces (E : Controller) return Real_Array with Global => null;
   function Generalized (E : Controller) return Real_Array with Global => null;
   function Accelerations (E : Controller) return Real_Array with Global => null;
   subtype Output_Width is Natural range 0 .. Max_Outputs;
   subtype Activation_Width is Natural range 0 .. Max_Actuators;
   subtype Dof_Width is Natural range 0 .. Max_Dofs;
   --  Mutable evaluation outputs and staged activation; configuration, user
   --  control and published activation are never changed by evaluation.
   type Evaluation_State (No : Output_Width; Na : Activation_Width; Nv : Dof_Width) is private;
   function Capture_Evaluation (E : Controller) return Evaluation_State with Global => null,
     Post => Capture_Evaluation'Result.No = Output_Count (E)
       and then Capture_Evaluation'Result.Na = Activation (E)'Length
       and then Capture_Evaluation'Result.Nv = Velocity_Count (E);
   procedure Restore_Evaluation (E : in out Controller; Saved : Evaluation_State)
     with Global => null,
       Pre => Saved.No = Output_Count (E) and then Saved.Na = Activation (E)'Length
         and then Saved.Nv = Velocity_Count (E),
       Post => Capture_Evaluation (E) = Saved and then Inputs (E) = Inputs (E)'Old
         and then Activation (E) = Activation (E)'Old and then Ready (E) = Ready (E)'Old;
   procedure Configure (M : MJ.Models.Model; E : in out Controller; Result : out Status)
     with Global => null, Post => (if Result = Success then Ready (E));
   procedure Free (E : in out Controller) with Global => null, Post => not Ready (E);
   procedure Reset (E : in out Controller) with Global => null;
   procedure Invalidate (E : in out Controller) with Global => null;
   procedure Set_Control (E : in out Controller; Index : Natural; Value : Tier0_Real;
                          Result : out Status) with Global => null;
   procedure Set_Activation (E : in out Controller; Values : State_Vector;
                            Result : out Status) with Global => null,
     Post => (Static => Ready (E) = Ready (E)'Old
       and then Inputs (E) = Inputs (E)'Old
       and then Control_Count (E) = Control_Count (E)'Old
       and then Output_Count (E) = Output_Count (E)'Old
       and then Position_Count (E) = Position_Count (E)'Old
       and then Velocity_Count (E) = Velocity_Count (E)'Old
       and then Activation (E)'Length = Activation (E)'Old'Length
       and then (if Result = Success then Ready (E)
         and then Activation (E) = As_Reals (Values)
         else Activation (E) = Activation (E)'Old
           and then Capture_Evaluation (E) = Capture_Evaluation (E)'Old));
   procedure Evaluate (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Global => null,
       Post => (Static => State_Values (D) = State_Values (D)'Old
         and then Input_Values (D) = Input_Values (D)'Old
         and then Activation (E) = Activation (E)'Old and then Inputs (E) = Inputs (E)'Old
         and then Output_Count (E) = Output_Count (E)'Old
         and then Activation (E)'Length = Activation (E)'Old'Length
         and then Velocity_Count (E) = Velocity_Count (E)'Old
         and then (if Result /= Success then
           Capture_Evaluation (E) = Capture_Evaluation (E)'Old));
   --  Stage performs every activation admission before the caller publishes
   --  its position/velocity/time. Publish is called only after step success.
   procedure Stage_Advance (D : Simulation; E : in out Controller; Result : out Status)
     with Global => null;
   procedure Publish (E : in out Controller) with Global => null;
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
   type Evaluation_State (No : Output_Width; Na : Activation_Width; Nv : Dof_Width) is record
      Valid, Can_Advance : Boolean;
      Next_Act, Dot : Real_Array (1 .. Na);
      L, V, F : Real_Array (1 .. No);
      Qforce, Acc : Real_Array (1 .. Nv);
   end record;
   --  Both records remain limited, preserving by-reference calls. Evaluation
   --  receives Source as an in parameter and changes only Work.
   type Input_Storage is limited record
      Nq : Natural range 0 .. Max_Positions := 0;
      Nv : Dof_Width := 0;
      Nb : Natural range 0 .. Max_Bodies := 0;
      Initialized, Has_Sites : Boolean := False;
      Nu : Natural range 0 .. Max_Controls := 0;
      No : Natural range 0 .. Max_Outputs := 0;
      Na, Nactuator : Natural range 0 .. Max_Actuators := 0;
      Disabled_Groups : Natural := 0;
      Config : Config_Array (0 .. Max_Actuators - 1);
      Control : Real_Array (0 .. Max_Controls - 1) := [others => 0.0];
      Control_Lo, Control_Hi : State_Vector (0 .. Max_Controls - 1) := [others => 0.0];
      Control_Limited : Bool_Array (0 .. Max_Controls - 1) := [others => False];
      Act : Real_Array (0 .. Max_Actuators - 1) := [others => 0.0];
   end record;
   type Evaluation_Storage is limited record
      Valid, Can_Advance : Boolean := False;
      Next_Act, Dot : Real_Array (0 .. Max_Actuators - 1) := [others => 0.0];
      L, V, F : Real_Array (0 .. Max_Outputs - 1) := [others => 0.0];
      Qforce, Acc : Real_Array (0 .. Max_Dofs - 1) := [others => 0.0];
      Rows : TX.Result (3 * Max_Dofs - 1);
   end record;
   type Controller is limited record
      Source : Input_Storage;
      Work : Evaluation_Storage;
   end record;
   function Ready (E : Controller) return Boolean is (E.Source.Initialized);
   function Inputs (E : Controller) return Real_Array is (MJ.Controller_Array_Kernels.Prefix (E.Source.Control,E.Source.Nu));
   function Activation (E : Controller) return Real_Array is (MJ.Controller_Array_Kernels.Prefix (E.Source.Act,E.Source.Na));
   function Rates (E : Controller) return Real_Array is (E.Work.Dot (0 .. Integer (E.Source.Na)-1));
   function Control_Count (E : Controller) return Natural is (E.Source.Nu);
   function Output_Count (E : Controller) return Natural is (E.Source.No);
   function Position_Count (E : Controller) return Natural is (E.Source.Nq);
   function Velocity_Count (E : Controller) return Natural is (E.Source.Nv);
   function Lengths (E : Controller) return Real_Array is (E.Work.L (0 .. Integer (E.Source.No)-1));
   function Velocities (E : Controller) return Real_Array is (E.Work.V (0 .. Integer (E.Source.No)-1));
   function Forces (E : Controller) return Real_Array is (E.Work.F (0 .. Integer (E.Source.No)-1));
   function Generalized (E : Controller) return Real_Array is (E.Work.Qforce (0 .. Integer (E.Source.Nv)-1));
   function Accelerations (E : Controller) return Real_Array is (E.Work.Acc (0 .. Integer (E.Source.Nv)-1));

end MJ.Data.Advanced_Control;

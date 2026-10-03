with MJ.Types; use MJ.Types;
package MJ.Plugin_Protocol with SPARK_Mode is
   Max_Instances : constant := 64;
   Max_State : constant := 64;
   Max_Positions : constant := 512;
   Max_Dofs : constant := 256;
   Max_Outputs : constant := 1_024;
   subtype Value is Tier0_Real;
   type Values is array (Natural range <>) of Value;
   type Capability is (Actuator, Sensor, Passive, SDF);
   subtype Capability_Mask is Natural range 0 .. 15;
   type Stage is (None, Position, Velocity, Acceleration);
   type Hook is (Initialize, Reset, Copy, Destroy, Compute, Act_Dot, Advance,
                 Distance, Gradient);
   type Result is (Success, Not_Initialized, Already_Initialized, Invalid_Config,
                   Unsupported, Callback_Failure, Numeric_Limit);
   type Configuration is record
      Slot : Natural range 0 .. 65_535 := 0;
      Capabilities : Capability_Mask := 0;
      Need_Stage : Stage := None;
      State_Count : Natural range 0 .. Max_State := 0;
      Has_Advance, Has_Act_Dot : Boolean := False;
      Parameters : Values (0 .. 15) := [others => 0.0];
   end record;
   type Configurations is array (Natural range <>) of Configuration;
   type Frame is record
      Nq : Natural range 0 .. Max_Positions := 0;
      Nv : Natural range 0 .. Max_Dofs := 0;
      Nu, Na, Ns : Natural range 0 .. Max_Outputs := 0;
      Time, Timestep : Value := 0.0;
      Qpos : Values (0 .. Max_Positions - 1) := [others => 0.0];
      Qvel, Qacc : Values (0 .. Max_Dofs - 1) := [others => 0.0];
      Control, Activation, Length, Velocity : Values (0 .. Max_Outputs - 1) := [others => 0.0];
      Point : Values (0 .. 2) := [others => 0.0];
   end record;
   type Outputs is record
      Passive : Values (0 .. Max_Dofs - 1) := [others => 0.0];
      Force, Act_Dot, Sensor : Values (0 .. Max_Outputs - 1) := [others => 0.0];
      Distance : Value := 0.0;
      Gradient : Values (0 .. 2) := [others => 0.0];
   end record;
   function Has (Mask : Capability_Mask; Kind : Capability) return Boolean is
     ((Mask / (2 ** Capability'Pos (Kind))) mod 2 = 1) with Global => null;
   function Matches (Needed, Requested : Stage) return Boolean is
     (Needed = Requested or else (Requested = Position and then Needed = None))
     with Global => null;
   function Eligible (C : Configuration; H : Hook; Kind : Capability;
                      Requested : Stage) return Boolean is
     (case H is
         when Compute => Has (C.Capabilities, Kind)
           and then (Kind /= Sensor or else Matches (C.Need_Stage, Requested)),
         when Act_Dot => Has (C.Capabilities, Actuator) and then C.Has_Act_Dot,
         when Advance => C.Has_Advance,
         when Distance | Gradient => Has (C.Capabilities, SDF),
         when others => True) with Global => null;
   function Cutoff (X : Value; Limit : Value; Positive : Boolean) return Value
     with Global => null, Pre => Limit >= 0.0,
     Post => Cutoff'Result =
       (if Limit = 0.0 then X
        elsif Positive then Real'Min (Limit, X)
        else Real'Max (-Limit, Real'Min (Limit, X)));
   procedure Add (A, B : Value; Sum : in out Value; Accepted : out Boolean)
     with Global => null,
     Post => (if A + B in Value then Accepted and then Sum = A + B
              else not Accepted and then Sum = Sum'Old);
   procedure Multiply (A, B : Value; Product : in out Value; Accepted : out Boolean)
     with Global => null,
     Post => (if A * B in Value then Accepted and then Product = A * B
              else not Accepted and then Product = Product'Old);
end MJ.Plugin_Protocol;

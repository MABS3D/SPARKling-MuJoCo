with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Smooth_Dynamics;

--  Like xfrc_applied: world-frame force followed by world-frame torque,
--  applied at the body's centre of mass. The world body's load is ignored.
--  Supply a 0-based Body_Count-sized array to each Forward/Euler call.
--  Loads are not retained in Simulation; an omitted/empty array means none.
package MJ.External_Forces with SPARK_Mode is
   type Input_Vector is array (Axis) of Tier0_Real;
   type Wrench is record
      Force, Torque : Input_Vector := [others => 0.0];
   end record;
   type Wrench_Array is array (Natural range <>) of Wrench;
   No_Loads : constant Wrench_Array := [1 .. 0 => <>];
   function Is_Zero (Load : Wrench) return Boolean is
     (Load.Force = Input_Vector'(others => 0.0)
      and then Load.Torque = Input_Vector'(others => 0.0)) with Global => null;
   subtype Projection_Real is Real range -1.0e72 .. 1.0e72;
   subtype Contribution_Real is Real range -1.0e73 .. 1.0e73;
   function Dot_Load (Column : Vector; Load : Input_Vector) return Projection_Real
     with Global => null, Pre => Bounded (Column),
     Post => Dot_Load'Result =
       (Column (0) * Load (0) + Column (1) * Load (1)) + Column (2) * Load (2);
   function Contribution
     (Previous : MJ.Smooth_Dynamics.Work_Real;
      Linear, Angular : Vector; Load : Wrench) return Contribution_Real
     with Global => null, Pre => Bounded (Linear) and then Bounded (Angular),
     Post => Contribution'Result =
       (Previous + Dot_Load (Linear, Load.Force)) + Dot_Load (Angular, Load.Torque);
end MJ.External_Forces;

with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Elastic_Network; use MJ.Elastic_Network;
with MJ.Elastic_Contact_Math;

--  Cartesian slide coordinates: world position = model origin + displacement.
--  The displacement is persistent state, not reconstructed by subtraction.
package MJ.Elastic_Coordinates with SPARK_Mode is
   subtype Shift is Real range -2.0e10 .. 2.0e10;
   type Shift_Vector is array (Axis) of Shift;
   type Frame is record
      Origin : Input_Vector := [others => 0.0];
      Offset : Shift_Vector := [others => 0.0];
   end record;
   type Frame_Array is array (Vertex range <>) of Frame;
   function World (Origin : Tier0_Real; Offset : Shift) return Real
     with Global => null, Post => World'Result in -4.0e10 .. 4.0e10
       and then World'Result = Origin+Offset;
   function Next_Velocity (Velocity : Tier0_Real;
     Acceleration : MJ.Elastic_Contact_Math.Scalar; Dt : Time_Step) return Real
     with Global => null, Post => Next_Velocity'Result in -2.0e100 .. 2.0e100
       and then Next_Velocity'Result = Velocity+Dt*Acceleration;
   function Next_Offset (Offset : Shift; Velocity : Tier0_Real; Dt : Time_Step) return Real
     with Global => null, Post => Next_Offset'Result in -4.0e10 .. 4.0e10
       and then Next_Offset'Result = Offset+Dt*Velocity;
   function Admissible (Origin : Tier0_Real; Offset : Shift; Velocity : Tier0_Real;
     Acceleration : MJ.Elastic_Contact_Math.Scalar; Dt : Time_Step) return Boolean is
     (Next_Velocity (Velocity, Acceleration, Dt) in Tier0_Real
      and then Next_Offset (Offset, Next_Velocity (Velocity, Acceleration, Dt), Dt) in Shift
      and then World (Origin,
        Next_Offset (Offset, Next_Velocity (Velocity, Acceleration, Dt), Dt)) in Tier0_Real)
     with Ghost => Static, Global => null;
   procedure Reset (P : Particle_Array; Coordinates : out Frame_Array)
     with Global => null,
     Pre => P'First = Coordinates'First and then P'Last = Coordinates'Last,
     Post => (for all I in P'Range => Coordinates (I).Origin = P (I).Position
       and then Coordinates (I).Offset = Shift_Vector'[others => 0.0]);
   procedure Integrate (Position, Velocity : in out Tier0_Real;
     Origin : Tier0_Real; Offset : in out Shift;
     Acceleration : MJ.Elastic_Contact_Math.Scalar; Dt : Time_Step;
     Accepted : out Boolean)
     with Global => null,
     Pre => Position = World (Origin, Offset),
     Post => (if not Accepted then Position = Position'Old
       and then Velocity = Velocity'Old and then Offset = Offset'Old
       else Velocity = Next_Velocity (Velocity'Old, Acceleration, Dt)
         and then Offset = Next_Offset (Offset'Old, Velocity, Dt)
         and then Position = World (Origin, Offset));
   pragma Postcondition (Static => Accepted = Admissible
     (Origin, Offset'Old, Velocity'Old, Acceleration, Dt));
end MJ.Elastic_Coordinates;

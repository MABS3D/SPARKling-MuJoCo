package body MJ.Fluid_Transport with SPARK_Mode is
   subtype Work_Scalar is Real range -Work_Limit .. Work_Limit;
   subtype Offset_Scalar is Real range -1.0e66 .. 1.0e66;
   subtype Moment_Scalar is Real range -1.0e128 .. 1.0e128;
   function Lever_Component (T, F1, F2 : Work_Scalar; R1, R2 : Offset_Scalar) return Moment_Scalar
     with Global => null, Post => Lever_Component'Result = T + (R1*F2 - R2*F1)
   is
      P : constant Real := R1*F2;
      Q : constant Real := R2*F1;
      Delta_T : constant Real := P-Q;
   begin
      return T+Delta_T;
   end Lever_Component;
   pragma Inline_Always (Lever_Component);
   function Lever_Torque (Torque, Offset, Force : Vector) return Vector is
   begin
      return [Lever_Component (Torque (0), Force (1), Force (2), Offset (1), Offset (2)),
              Lever_Component (Torque (1), Force (2), Force (0), Offset (2), Offset (0)),
              Lever_Component (Torque (2), Force (0), Force (1), Offset (0), Offset (1))];
   end Lever_Torque;
   function Project (Hinge : Boolean; Direction, Offset, Force, Torque : Vector) return Contribution is
      V : constant Vector := (if Hinge then Lever_Torque (Torque, Offset, Force) else Force);
   begin
      return Dot (Direction, V);
   end Project;
   procedure Merge (Force, Torque : in out Vector; Child_Force, Child_Torque, Offset : Vector; Ok : out Boolean) is
      F : constant Vector := Force + Child_Force;
      T : constant Vector := Torque + Lever_Torque (Child_Torque, Offset, Child_Force);
   begin
      Ok := Bounded (F) and then Bounded (T);
      if Ok then Force := F; Torque := T; end if;
   end Merge;
end MJ.Fluid_Transport;

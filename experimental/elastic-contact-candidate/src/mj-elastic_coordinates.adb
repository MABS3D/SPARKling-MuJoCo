package body MJ.Elastic_Coordinates with SPARK_Mode is
   function World (Origin : Tier0_Real; Offset : Shift) return Real is
   begin return Origin+Offset; end World;
   function Next_Velocity (Velocity : Tier0_Real;
     Acceleration : MJ.Elastic_Contact_Math.Scalar; Dt : Time_Step) return Real is
   begin return Velocity+Dt*Acceleration; end Next_Velocity;
   function Next_Offset (Offset : Shift; Velocity : Tier0_Real; Dt : Time_Step) return Real is
   begin return Offset+Dt*Velocity; end Next_Offset;
   procedure Reset (P : Particle_Array; Coordinates : out Frame_Array) is
   begin
      Coordinates := [others => (others => <>)];
      for I in P'Range loop
         Coordinates (I) := (Origin => P (I).Position, Offset => [others => 0.0]);
         pragma Loop_Invariant (for all J in P'First .. I =>
           Coordinates (J).Origin = P (J).Position and then Coordinates (J).Offset = Shift_Vector'[others => 0.0]);
      end loop;
   end Reset;
   procedure Integrate (Position, Velocity : in out Tier0_Real;
     Origin : Tier0_Real; Offset : in out Shift;
     Acceleration : MJ.Elastic_Contact_Math.Scalar; Dt : Time_Step;
     Accepted : out Boolean)
   is
      U : constant Real := Next_Velocity (Velocity, Acceleration, Dt);
      Q, X : Real;
   begin
      Accepted := False;
      if U not in Tier0_Real then return; end if;
      Q := Next_Offset (Offset, U, Dt);
      if Q not in Shift then return; end if;
      X := World (Origin, Q);
      if X not in Tier0_Real then return; end if;
      Velocity := U; Offset := Q; Position := X; Accepted := True;
   end Integrate;
end MJ.Elastic_Coordinates;

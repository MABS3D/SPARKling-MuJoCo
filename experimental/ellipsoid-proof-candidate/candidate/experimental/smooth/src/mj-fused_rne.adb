package body MJ.Fused_RNE with SPARK_Mode is
   use type SK.Motion;

   function World_Acceleration
     (G0, G1, G2 : Tier0_Real; Gravity_Enabled : Boolean) return SK.Motion is
     (if Gravity_Enabled then [0.0, 0.0, 0.0, -G0, -G1, -G2]
      else [others => 0.0]);

   procedure Try_Body_Force
     (I : SK.Inertia; Velocity, Acceleration : SK.Motion;
      Force : out SK.Motion; Ok : out Boolean)
   is
      Inertial : constant SK.Motion := SK.Multiply (I, Acceleration);
      Momentum : constant SK.Motion := SK.Multiply (I, Velocity);
      Gyroscopic : constant SK.Motion := SD.Cross_Force (Velocity, Momentum);
      Candidate : SK.Motion;
   begin
      Force := [others => 0.0];
      Ok := False;
      if not SK.Bounded (Gyroscopic, 1.0e54) then return; end if;
      Candidate := SK.Add_Wrenches (Inertial, Gyroscopic);
      if not SK.Bounded (Candidate, 1.0e54) then return; end if;
      Force := Candidate;
      Ok := True;
   end Try_Body_Force;
end MJ.Fused_RNE;

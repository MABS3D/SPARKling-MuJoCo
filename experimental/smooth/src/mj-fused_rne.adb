with MJ.Spatial_Kernels.Direct;

package body MJ.Fused_RNE with SPARK_Mode is
   use type SK.Motion;

   function World_Acceleration
     (G0, G1, G2 : Tier0_Real; Gravity_Enabled : Boolean) return SK.Motion is
     (if Gravity_Enabled then [0.0, 0.0, 0.0, -G0, -G1, -G2]
      else [others => 0.0]);

   --  Numerical FP equality (including either sign of zero) is preserved by
   --  these bounded multiply/add expressions. Each bridge is proved separately.
   procedure Prove_Cross_Term_Equality
     (A, B : SD.Narrow; C, D, E, F : SD.Wide)
     with Ghost => Static, Global => null,
     Pre => C = E and then D = F,
     Post => SD.Cross_Term (A, B, C, D) = SD.Cross_Term (A, B, E, F)
   is
      AC : constant SD.Cross_Real := (-A)*C;
      AE : constant SD.Cross_Real := (-A)*E;
      BD : constant SD.Cross_Real := B*D;
      BF : constant SD.Cross_Real := B*F;
   begin
      pragma Assert (Static => AC = AE);
      pragma Assert (Static => BD = BF);
      pragma Assert (Static => AC + BD = AE + BF);
   end Prove_Cross_Term_Equality;

   procedure Prove_Cross_Force_Equality (Velocity, Left, Right : SK.Motion)
     with Ghost => Static, Global => null,
     Pre => SK.Bounded (Velocity, 1.0e12) and then SK.Bounded (Left, 1.0e54)
       and then SK.Bounded (Right, 1.0e54) and then Left = Right,
     Post => SD.Cross_Force (Velocity, Left) = SD.Cross_Force (Velocity, Right)
   is
      L : constant SK.Motion := SD.Cross_Force (Velocity, Left);
      R : constant SK.Motion := SD.Cross_Force (Velocity, Right);
   begin
      Prove_Cross_Term_Equality (Velocity (2), Velocity (1),
        Left (1), Left (2), Right (1), Right (2));
      Prove_Cross_Term_Equality (Velocity (5), Velocity (4),
        Left (4), Left (5), Right (4), Right (5));
      Prove_Cross_Term_Equality (Velocity (0), Velocity (2),
        Left (2), Left (0), Right (2), Right (0));
      Prove_Cross_Term_Equality (Velocity (3), Velocity (5),
        Left (5), Left (3), Right (5), Right (3));
      Prove_Cross_Term_Equality (Velocity (1), Velocity (0),
        Left (0), Left (1), Right (0), Right (1));
      Prove_Cross_Term_Equality (Velocity (4), Velocity (3),
        Left (3), Left (4), Right (3), Right (4));
      Prove_Cross_Term_Equality (Velocity (2), Velocity (1),
        Left (4), Left (5), Right (4), Right (5));
      Prove_Cross_Term_Equality (Velocity (0), Velocity (2),
        Left (5), Left (3), Right (5), Right (3));
      Prove_Cross_Term_Equality (Velocity (1), Velocity (0),
        Left (3), Left (4), Right (3), Right (4));
      pragma Assert (Static => L (0) = R (0));
      pragma Assert (Static => L (1) = R (1));
      pragma Assert (Static => L (2) = R (2));
      pragma Assert (Static => L (3) = R (3));
      pragma Assert (Static => L (4) = R (4));
      pragma Assert (Static => L (5) = R (5));
   end Prove_Cross_Force_Equality;

   procedure Prove_Add_Equality (A, B, C, D : SK.Motion)
     with Ghost => Static, Global => null,
     Pre => SK.Bounded (A, 1.0e54) and then SK.Bounded (B, 1.0e54)
       and then SK.Bounded (C, 1.0e54) and then SK.Bounded (D, 1.0e54)
       and then A = C and then B = D,
     Post => SK.Add_Wrenches (A, B) = SK.Add_Wrenches (C, D)
   is
      L : constant SK.Motion := SK.Add_Wrenches (A, B);
      R : constant SK.Motion := SK.Add_Wrenches (C, D);
   begin
      pragma Assert (Static => L (0) = R (0));
      pragma Assert (Static => L (1) = R (1));
      pragma Assert (Static => L (2) = R (2));
      pragma Assert (Static => L (3) = R (3));
      pragma Assert (Static => L (4) = R (4));
      pragma Assert (Static => L (5) = R (5));
   end Prove_Add_Equality;

   procedure Try_Body_Force
     (I : SK.Inertia; Velocity, Acceleration : SK.Motion;
      Force : out SK.Motion; Ok : out Boolean)
   is
      Inertial : constant SK.Motion := SK.Direct.Multiply (I, Acceleration);
      Momentum : constant SK.Motion := SK.Direct.Multiply (I, Velocity);
      Gyroscopic : constant SK.Motion := SD.Cross_Force (Velocity, Momentum);
      Candidate : SK.Motion;
      Parent_Inertial : constant SK.Motion := SK.Multiply (I, Acceleration) with Ghost => Static;
      Parent_Momentum : constant SK.Motion := SK.Multiply (I, Velocity) with Ghost => Static;
      Expected_Gyroscopic : constant SK.Motion := Gyroscopic_Model (I, Velocity) with Ghost => Static;
   begin
      pragma Assert (Static => Inertial = Parent_Inertial);
      pragma Assert (Static => Momentum = Parent_Momentum);
      Prove_Cross_Force_Equality (Velocity, Momentum, Parent_Momentum);
      pragma Assert (Static => Gyroscopic = Expected_Gyroscopic);
      Force := [others => 0.0];
      Ok := False;
      if not SK.Bounded (Gyroscopic, 1.0e54) then return; end if;
      Candidate := SK.Add_Wrenches (Inertial, Gyroscopic);
      Prove_Add_Equality (Inertial, Gyroscopic, Parent_Inertial, Expected_Gyroscopic);
      pragma Assert (Static => Candidate = Body_Force_Model (I, Velocity, Acceleration));
      if not SK.Bounded (Candidate, 1.0e54) then return; end if;
      Force := Candidate;
      Ok := True;
   end Try_Body_Force;
end MJ.Fused_RNE;

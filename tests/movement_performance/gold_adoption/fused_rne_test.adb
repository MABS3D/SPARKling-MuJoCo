with Ada.Text_IO;
with MJ.Fused_RNE;
with MJ.Spatial_Kernels;
with MJ.Spatial_Dynamics;
with MJ.Types; use MJ.Types;

procedure Fused_RNE_Test is
   package F renames MJ.Fused_RNE;
   package SK renames MJ.Spatial_Kernels;
   package SD renames MJ.Spatial_Dynamics;
   use type SK.Motion;
   I : SK.Inertia := [2.0, 3.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0];
   V : SK.Motion := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
   A : SK.Motion;
   Force : SK.Motion;
   Ok : Boolean;
   Expected_Last : Real;
   procedure Check (Condition : Boolean; Message : String) is
   begin
      if not Condition then raise Program_Error with Message; end if;
   end Check;
begin
   Check (F.World_Acceleration (1.0, -2.0, 3.0, True) =
     SK.Motion'(0.0, 0.0, 0.0, -1.0, 2.0, -3.0), "world gravity sign");
   Check (F.World_Acceleration (Max_Val, -Max_Val, Max_Val, False) =
     SK.Motion'(others => 0.0), "disabled gravity");
   A := F.World_Acceleration (0.0, 0.0, -9.81, True);
   F.Try_Body_Force (I, V, A, Force, Ok);
   Check (Ok, "ordinary body accepted");
   --  Use rounded Real operations, not Ada universal-real static folding.
   Expected_Last := I (9) * A (5);
   Expected_Last := Expected_Last - 15.0;
   Check (Force = SK.Motion'(6.0, -6.0, 2.0, -15.0, 30.0, Expected_Last),
     "combined inertial and gyroscopic components");

   I := [1.0e40, 5.0e39, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
   V := [0.0, 1.0e12, 1.0e12, 0.0, 0.0, 0.0];
   A := [others => 0.0];
   F.Try_Body_Force (I, V, A, Force, Ok);
   Check (not Ok and then Force = SK.Motion'(others => 0.0), "gyroscopic rejection");

   V := [0.0, 1.0e7, 1.999e7, 0.0, 0.0, 0.0];
   A := [-1.0e12, 0.0, 0.0, 0.0, 0.0, 0.0];
   Check (SK.Bounded (SD.Cross_Force (V, SK.Multiply (I, V)), 1.0e54),
     "candidate rejection reaches final addition");
   F.Try_Body_Force (I, V, A, Force, Ok);
   Check (not Ok and then Force = SK.Motion'(others => 0.0), "summed-force rejection");

   I := [others => 0.0]; V := [others => 1.0e12]; A := [others => -1.0e12];
   F.Try_Body_Force (I, V, A, Force, Ok);
   Check (Ok and then Force = SK.Motion'(others => 0.0), "zero inertia at motion bounds");
   Ada.Text_IO.Put_Line ("PASS: fused RNE world seed, ordinary body, both rejection branches, zero inertia");
end Fused_RNE_Test;

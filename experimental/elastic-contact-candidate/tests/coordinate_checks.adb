with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Elastic_Network; use MJ.Elastic_Network;
with MJ.Elastic_Contacts; use MJ.Elastic_Contacts;
with MJ.Elastic_Coordinates; use MJ.Elastic_Coordinates;

--  Public API lifecycle tests: caller edits, mismatched arrays and rollback
--  after a previous accepted step. Checks remain active in release builds.
procedure Coordinate_Checks is
   P : Particle_Array (1 .. 2) := [others => (others => <>)];
   C : Frame_Array (P'Range);
   E : Edge_Array (1 .. 0);
   B : Body_Array (1 .. 1) := [others => (others => <>)];
   Links : Attachment_Array (P'Range) := [others => (others => <>)];
   Shapes : Shape_Array (1 .. 0);
   Applied : Input_Array (P'Range) := [others => [others => 0.0]];
   Wrenches : Wrench_Array (B'Range) := [others => (others => <>)];
   PC : Particle_Loads (P'Range);
   BC : Body_Loads (B'Range);
   Info : Report (0);
   Options : Settings;
   procedure Check (OK : Boolean; Message : String) is
   begin
      if not OK then raise Program_Error with Message; end if;
   end Check;
   procedure Advance is
   begin
      MJ.Elastic_Contacts.Step (P, C, E, B, Links, Shapes, Applied, Wrenches,
        [others => 0.0], 0.01, Options, PC, BC, Info);
   end Advance;
   procedure Rejected (Expected : MJ.Elastic_Contacts.Status) is
      Old_P : constant Particle_Array := P;
      Old_C : constant Frame_Array := C;
      Old_B : constant Body_Array := B;
   begin
      Advance;
      Check (Info.Result = Expected, "wrong rejection status");
      Check (P = Old_P and then C = Old_C and then B = Old_B, "rollback lost state");
      Check ((for all F of PC => F = Zero) and then
        (for all F of BC => F = (Zero, Zero)), "rejection retained contact loads");
   end Rejected;
begin
   P (1).Position := [3.0, 2.0, 1.0];
   P (2).Position := [-3.0, 2.0, 1.0];
   P (1).Velocity := [0.25, -0.5, 0.75];
   Reset (P, C);
   for I in 1 .. 3 loop
      Advance;
      Check (Info.Result = MJ.Elastic_Contacts.Success, "valid step rejected");
   end loop;
   Check (C (1).Origin = Input_Vector'[3.0, 2.0, 1.0]
     and then C (1).Offset (0) > 0.0, "origin or accumulated offset lost");
   Put_Line ("persistent_coordinates PASS");

   P (1).Position (0) := P (1).Position (0)+1.0;
   Rejected (Invalid_Input);
   Put_Line ("stale_world_position PASS");
   Reset (P, C);
   Advance;
   Check (Info.Result = MJ.Elastic_Contacts.Success, "explicit rebase rejected");
   Put_Line ("explicit_rebase PASS");

   declare
      Wrong : Frame_Array (2 .. 3) := [others => (others => <>)];
      Old_Wrong : constant Frame_Array := Wrong;
      Old_P : constant Particle_Array := P;
      Old_B : constant Body_Array := B;
   begin
      MJ.Elastic_Contacts.Step (P, Wrong, E, B, Links, Shapes, Applied, Wrenches,
        [others => 0.0], 0.01, Options, PC, BC, Info);
      Check (Info.Result = Invalid_Input and then P = Old_P and then B = Old_B
        and then Wrong = Old_Wrong, "coordinate bounds not rejected atomically");
   end;
   Put_Line ("mismatched_coordinate_bounds PASS");

   B (1).Mass := 1.0e-15;
   Wrenches (1).Force := [1.0e10, 0.0, 0.0];
   --  The particle offsets are already nonzero. Their tentative update precedes
   --  the body's velocity limit failure, and must not escape from Step.
   Rejected (MJ.Elastic_Contacts.Numeric_Limit);
   Put_Line ("late_failure_preserves_nonzero_offsets PASS");
end Coordinate_Checks;

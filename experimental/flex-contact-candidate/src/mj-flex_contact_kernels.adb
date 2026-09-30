package body MJ.Flex_Contact_Kernels with SPARK_Mode is
   function Diagonal_Component (N : Normal_Component; Inv_M : MJ.Contact_Rows.Inverse_Mass)
     return Real is
      X : constant Real := N * Inv_M;
   begin
      if N >= 0.0 then
         pragma Assert (X >= 0.0);
      else
         pragma Assert (X <= 0.0);
      end if;
      return X * N;
   end Diagonal_Component;
   function Normal_Load (C : Configuration; P : Particle; H : Time_Step;
     A : Free_Vector) return Load_Result is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Load);
      use MJ.Contact_Rows;
   begin
      if P.Pinned or else not Included (C, P.Position)
        or else Distance (C, P.Position) >= C.Margin then
         return (True, 0.0);
      end if;
      declare
         I : constant Raw_Impedance := Impedance (C.Solver, Distance (C, P.Position), C.Margin);
      begin
         if I not in Checked_Impedance then return (False, 0.0); end if;
         return (True, Response (C, P, H, A, I));
      end;
   end Normal_Load;

   procedure Evaluate (C : Configuration; P : Particle; F : Edge_Force;
     Applied, Gravity : Input_Vector; H : Time_Step; Selected_Rank : Contact_Rank; R : out Evaluation) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Matches);
      A : constant Free_Vector := [
        Free_Acceleration (P.Mass, F.Spring (0), F.Damper (0), Applied (0), Gravity (0)),
        Free_Acceleration (P.Mass, F.Spring (1), F.Damper (1), Applied (1), Gravity (1)),
        Free_Acceleration (P.Mass, F.Spring (2), F.Damper (2), Applied (2), Gravity (2))];
      L : constant Load_Result := (if Selected_Rank = 0 then (True, 0.0) else Normal_Load (C, P, H, A));
      Inv : constant MJ.Contact_Rows.Inverse_Mass := 1.0 / P.Mass;
   begin
      R := (Accepted => L.Accepted, Contact => Included (C, P.Position),
        Retained_Rank => Selected_Rank,
        Active => Selected_Rank > 0 and then Included (C, P.Position) and then Distance (C, P.Position) < C.Margin and then not P.Pinned,
        Separation => Distance (C, P.Position), Force => L.Force, Free => A,
        Acceleration => (if P.Pinned then [others => 0.0] else
          [Accelerated (A (0), L.Force, C.Normal (0), Inv),
           Accelerated (A (1), L.Force, C.Normal (1), Inv),
           Accelerated (A (2), L.Force, C.Normal (2), Inv)]));
   end Evaluate;

   procedure Integrate (P : in out Particle; A : Acceleration_Vector;
     H : Time_Step; Accepted : out Boolean) is
      Candidate : Particle := P;
      V : Next_Velocity;
      X : Real range -3.0e10 .. 3.0e10;
   begin
      Accepted := True;
      if P.Pinned then return; end if;
      for K in Axis loop
         V := Velocity_After (P.Velocity (K), A (K), H);
         if V not in Tier0_Real then Accepted := False; return; end if;
         X := Advance_Position (P.Position (K), V, H);
         if X not in Tier0_Real then Accepted := False; return; end if;
         Candidate.Velocity (K) := V;
         Candidate.Position (K) := X;
         pragma Loop_Invariant (Candidate.Mass = P.Mass and then Candidate.Pinned = P.Pinned);
         pragma Loop_Invariant (for all J in Axis'First .. K =>
           Candidate.Velocity (J) = Velocity_After (P.Velocity (J), A (J), H)
           and then Candidate.Position (J) = P.Position (J) + H * Candidate.Velocity (J));
      end loop;
      P := Candidate;
   end Integrate;
end MJ.Flex_Contact_Kernels;

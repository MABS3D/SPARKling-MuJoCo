with MJ.Contact_Rows;

package body MJ.Flex_Contact_Network with SPARK_Mode is
   procedure Relate_Acceleration (A, B : Free_Value; F, G : Load_Value;
     N : Normal_Component; Inv : MJ.Contact_Rows.Inverse_Mass)
     with Ghost => Static, Global => null, Pre => A = B and then F = G,
     Post => Accelerated (A, F, N, Inv) = Accelerated (B, G, N, Inv);
   procedure Relate_Acceleration (A, B : Free_Value; F, G : Load_Value;
     N : Normal_Component; Inv : MJ.Contact_Rows.Inverse_Mass) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Accelerated);
   begin
      pragma Assert (N * F = N * G);
      pragma Assert ((N * F) * Inv = (N * G) * Inv);
   end Relate_Acceleration;
   procedure Preserve_Acceleration (C : Configuration; P : Particle_Array;
     Before, After : Evaluation_Array; Last : Count; K : Axis)
     with Ghost => Static, Global => null,
     Pre => P'First = 1 and then Before'First = 1 and then After'First = 1
       and then Before'Length = P'Length and then After'Length = P'Length
       and then Last <= P'Length
       and then (for all W in 1 .. Last => Before (W) = After (W))
       and then (for all W in 1 .. Last => Before (W).Acceleration (K) =
         (if P (W).Pinned then 0.0 else Accelerated
           (Before (W).Free (K), Before (W).Force, C.Normal (K), 1.0 / P (W).Mass))),
     Post => (for all W in 1 .. Last => After (W).Acceleration (K) =
       (if P (W).Pinned then 0.0 else Accelerated
         (After (W).Free (K), After (W).Force, C.Normal (K), 1.0 / P (W).Mass)));
   procedure Preserve_Acceleration (C : Configuration; P : Particle_Array;
     Before, After : Evaluation_Array; Last : Count; K : Axis) is
   begin
      for W in 1 .. Last loop
         pragma Assert (Before (W).Acceleration (K) = After (W).Acceleration (K));
         pragma Assert (Before (W).Free (K) = After (W).Free (K));
         pragma Assert (Before (W).Force = After (W).Force);
         if not P (W).Pinned then
            Relate_Acceleration (Before (W).Free (K), After (W).Free (K),
              Before (W).Force, After (W).Force, C.Normal (K), 1.0 / P (W).Mass);
         end if;
         pragma Loop_Invariant (for all J in 1 .. W => After (J).Acceleration (K) =
           (if P (J).Pinned then 0.0 else Accelerated
             (After (J).Free (K), After (J).Force, C.Normal (K), 1.0 / P (J).Mass)));
      end loop;
   end Preserve_Acceleration;
   procedure Relate_Forces (C : Configuration; P : Particle; F, Expected : Edge_Force;
     Applied, Gravity : Input_Vector; H : Time_Step; Selected_Rank : Contact_Rank; Info : Evaluation)
     with Ghost => Static, Global => null,
     Pre => Bounded (F.Spring, 1.0e80) and then Bounded (F.Damper, 1.0e80)
       and then Bounded (Expected.Spring, 1.0e80) and then Bounded (Expected.Damper, 1.0e80)
       and then F = Expected and then Matches (C, P, F, Applied, Gravity, H, Selected_Rank, Info),
     Post => Matches (C, P, Expected, Applied, Gravity, H, Selected_Rank, Info);
   procedure Relate_Forces (C : Configuration; P : Particle; F, Expected : Edge_Force;
     Applied, Gravity : Input_Vector; H : Time_Step; Selected_Rank : Contact_Rank; Info : Evaluation) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Matches);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Free_Acceleration);
   begin
      for K in Axis loop
         pragma Assert (Info.Free (K) = Free_Acceleration
           (P.Mass, F.Spring (K), F.Damper (K), Applied (K), Gravity (K)));
         pragma Assert (F.Spring (K) = Expected.Spring (K) and then F.Damper (K) = Expected.Damper (K));
         pragma Assert (Info.Free (K) = Free_Acceleration
           (P.Mass, Expected.Spring (K), Expected.Damper (K), Applied (K), Gravity (K)));
         pragma Loop_Invariant (for all J in Axis'First .. K => Info.Free (J) = Free_Acceleration
           (P.Mass, Expected.Spring (J), Expected.Damper (J), Applied (J), Gravity (J)));
      end loop;
   end Relate_Forces;

   procedure Evaluate (C : Configuration; P : Particle_Array; E : Edge_Array;
     Applied : Input_Array; Gravity : Input_Vector; H : Time_Step;
     Info : out Evaluation_Array; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Elastic_Network.Component);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Matches);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Accelerated);
      F : Force_Array (P'Range);
      Force_Status : MJ.Elastic_Network.Status;
      Ranks : MJ.Flex_Contact_Filter.Rank_Array (P'Range);
      One : Evaluation;
      Previous : Evaluation_Array (P'Range) with Ghost => Static;
   begin
      Info := [others => (False, False, False, 0, 0.0, 0.0, [others => 0.0], [others => 0.0])];
      Result := Numeric_Limit;
      Forces (P, E, F, Force_Status);
      if Force_Status /= MJ.Elastic_Network.Success then return; end if;
      MJ.Flex_Contact_Filter.Select_Contacts (C, P, Ranks);
      Result := Success;
      for V in P'Range loop
         Previous := Info;
         pragma Assert (Static => F (V) = Model_Force (P, E, V));
         MJ.Flex_Contact_Kernels.Evaluate (C, P (V), F (V), Applied (V), Gravity, H, Ranks (V), One);
         Relate_Forces (C, P (V), F (V), Model_Force (P, E, V), Applied (V), Gravity, H, Ranks (V), One);
         if not One.Accepted then Result := Numeric_Limit; return; end if;
         Info (V) := One;
         Preserve_Acceleration (C, P, Previous, Info, V - 1, 0);
         Preserve_Acceleration (C, P, Previous, Info, V - 1, 1);
         Preserve_Acceleration (C, P, Previous, Info, V - 1, 2);
         pragma Assert (Static => Info (V).Acceleration (0) =
           (if P (V).Pinned then 0.0 else Accelerated
             (Info (V).Free (0), Info (V).Force, C.Normal (0), 1.0 / P (V).Mass)));
         pragma Assert (Static => Info (V).Acceleration (1) =
           (if P (V).Pinned then 0.0 else Accelerated
             (Info (V).Free (1), Info (V).Force, C.Normal (1), 1.0 / P (V).Mass)));
         pragma Assert (Static => Info (V).Acceleration (2) =
           (if P (V).Pinned then 0.0 else Accelerated
             (Info (V).Free (2), Info (V).Force, C.Normal (2), 1.0 / P (V).Mass)));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Accepted));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Retained_Rank = Ranks (W)));
         pragma Loop_Invariant (Static => (for all W in 1 .. V =>
           Info (W).Contact = Included (C, P (W).Position)));
         pragma Loop_Invariant (Static => (for all W in 1 .. V =>
           Info (W).Active = (Ranks (W) > 0 and then Info (W).Contact
             and then Distance (C, P (W).Position) < C.Margin and then not P (W).Pinned)));
         pragma Loop_Invariant (Static => (for all W in 1 .. V =>
           Info (W).Separation = Distance (C, P (W).Position)));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Free (0) =
           Free_Acceleration (P (W).Mass, Model_Force (P, E, W).Spring (0),
             Model_Force (P, E, W).Damper (0), Applied (W) (0), Gravity (0))));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Free (1) =
           Free_Acceleration (P (W).Mass, Model_Force (P, E, W).Spring (1),
             Model_Force (P, E, W).Damper (1), Applied (W) (1), Gravity (1))));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Free (2) =
           Free_Acceleration (P (W).Mass, Model_Force (P, E, W).Spring (2),
             Model_Force (P, E, W).Damper (2), Applied (W) (2), Gravity (2))));
         pragma Loop_Invariant (Static => (for all W in 1 .. V =>
           Load_Result'(Info (W).Accepted, Info (W).Force) =
             (if Ranks (W) = 0 then Load_Result'(True, 0.0)
              else MJ.Flex_Contact_Kernels.Model.Load (C, P (W), H, Info (W).Free))));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Acceleration (0) =
           (if P (W).Pinned then 0.0 else Accelerated
             (Info (W).Free (0), Info (W).Force, C.Normal (0), 1.0 / P (W).Mass))));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Acceleration (1) =
           (if P (W).Pinned then 0.0 else Accelerated
             (Info (W).Free (1), Info (W).Force, C.Normal (1), 1.0 / P (W).Mass))));
         pragma Loop_Invariant (Static => (for all W in 1 .. V => Info (W).Acceleration (2) =
           (if P (W).Pinned then 0.0 else Accelerated
             (Info (W).Free (2), Info (W).Force, C.Normal (2), 1.0 / P (W).Mass))));
      end loop;
   end Evaluate;

   procedure Step (C : Configuration; P : in out Particle_Array; E : Edge_Array;
     Applied : Input_Array; Gravity : Input_Vector; H : Time_Step;
     Info : out Evaluation_Array; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model_Force);
      Candidate : Particle_Array (P'Range) := P;
      Next : Particle;
      Accepted : Boolean;
   begin
      Evaluate (C, P, E, Applied, Gravity, H, Info, Result);
      if Result /= Success then return; end if;
      for V in P'Range loop
         Next := P (V);
         Integrate (Next, Info (V).Acceleration, H, Accepted);
         if not Accepted then Result := Numeric_Limit; return; end if;
         pragma Assert (if not P (V).Pinned then Next.Velocity (0) =
           Velocity_After (P (V).Velocity (0), Info (V).Acceleration (0), H));
         pragma Assert (if not P (V).Pinned then Next.Velocity (1) =
           Velocity_After (P (V).Velocity (1), Info (V).Acceleration (1), H));
         pragma Assert (if not P (V).Pinned then Next.Velocity (2) =
           Velocity_After (P (V).Velocity (2), Info (V).Acceleration (2), H));
         Candidate (V) := Next;
         pragma Loop_Invariant (for all W in P'Range =>
           Candidate (W).Mass = P (W).Mass and then Candidate (W).Pinned = P (W).Pinned
           and then (if P (W).Pinned then Candidate (W) = P (W)));
         pragma Loop_Invariant (for all W in V + 1 .. P'Last => Candidate (W) = P (W));
         pragma Loop_Invariant (for all W in 1 .. V => (if not P (W).Pinned then
           Candidate (W).Velocity (0) = Velocity_After (P (W).Velocity (0), Info (W).Acceleration (0), H)));
         pragma Loop_Invariant (for all W in 1 .. V => (if not P (W).Pinned then
           Candidate (W).Position (0) = P (W).Position (0) + H * Candidate (W).Velocity (0)));
         pragma Loop_Invariant (for all W in 1 .. V => (if not P (W).Pinned then
           Candidate (W).Velocity (1) = Velocity_After (P (W).Velocity (1), Info (W).Acceleration (1), H)));
         pragma Loop_Invariant (for all W in 1 .. V => (if not P (W).Pinned then
           Candidate (W).Position (1) = P (W).Position (1) + H * Candidate (W).Velocity (1)));
         pragma Loop_Invariant (for all W in 1 .. V => (if not P (W).Pinned then
           Candidate (W).Velocity (2) = Velocity_After (P (W).Velocity (2), Info (W).Acceleration (2), H)));
         pragma Loop_Invariant (for all W in 1 .. V => (if not P (W).Pinned then
           Candidate (W).Position (2) = P (W).Position (2) + H * Candidate (W).Velocity (2)));
      end loop;
      P := Candidate;
   end Step;
end MJ.Flex_Contact_Network;

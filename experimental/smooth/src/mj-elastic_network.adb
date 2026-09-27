package body MJ.Elastic_Network with SPARK_Mode is
   procedure Bound_Add (A, B : Real; N : Count) is
   begin
      pragma Assert (Budget (N) + 1.0e74 <= Budget (N + 1));
      pragma Assert (-Budget (N) - 1.0e74 >= -Budget (N + 1));
   end Bound_Add;
   function Load (P : Particle_Array; E : Edge) return Edge_Force is
     (Force (Measure (P (E.A), P (E.B)), E.Rest, E.Stiffness, E.Damping));
   function Model_Add (A, B : Real; N : Count) return Accumulated_Value is
   begin
      Bound_Add (A, B, N);
      return A + B;
   end Model_Add;
   procedure Prove_Component (P : Particle_Array; Item : Edge; Contribution : Edge_Force)
     with Ghost => Static, Global => null,
     Pre => P'First = 1 and then P'Length in 1 .. Max_Count
       and then Item.A in P'Range and then Item.B in P'Range and then Item.A /= Item.B
       and then Contribution = Load (P, Item),
     Post => (for all V in P'Range => (for all K in Axis =>
       Component (P, Item, V, K, False) =
         (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (K)
          elsif V = Item.B then Contribution.Spring (K) else 0.0)
       and then Component (P, Item, V, K, True) =
         (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (K)
          elsif V = Item.B then Contribution.Damper (K) else 0.0)));
   procedure Prove_Component (P : Particle_Array; Item : Edge; Contribution : Edge_Force) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
   begin
      null;
   end Prove_Component;
   procedure Accumulate_Edge (P : Particle_Array; Item : Edge; Contribution : Edge_Force; F : in out Force_Array)
     with Global => null,
     Pre => P'First = 1 and then P'Length in 1 .. Max_Count
       and then F'First = P'First and then F'Last = P'Last
       and then Item.A in P'Range and then Item.B in P'Range and then Item.A /= Item.B
       and then (for all V in F'Range => Bounded (F (V).Spring, 1.0e80)
         and then Bounded (F (V).Damper, 1.0e80))
       and then Bounded (Contribution.Spring, 1.0e74)
       and then Bounded (Contribution.Damper, 1.0e74);
   pragma Postcondition (Static => (for all V in F'Range =>
      F (V).Spring (0) = F'Old (V).Spring (0) + (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (0)
        elsif V = Item.B then Contribution.Spring (0) else 0.0)));
   pragma Postcondition (Static => (for all V in F'Range =>
      F (V).Spring (1) = F'Old (V).Spring (1) + (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (1)
        elsif V = Item.B then Contribution.Spring (1) else 0.0)));
   pragma Postcondition (Static => (for all V in F'Range =>
      F (V).Spring (2) = F'Old (V).Spring (2) + (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (2)
        elsif V = Item.B then Contribution.Spring (2) else 0.0)));
   pragma Postcondition (Static => (for all V in F'Range =>
      F (V).Damper (0) = F'Old (V).Damper (0) + (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (0)
        elsif V = Item.B then Contribution.Damper (0) else 0.0)));
   pragma Postcondition (Static => (for all V in F'Range =>
      F (V).Damper (1) = F'Old (V).Damper (1) + (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (1)
        elsif V = Item.B then Contribution.Damper (1) else 0.0)));
   pragma Postcondition (Static => (for all V in F'Range =>
      F (V).Damper (2) = F'Old (V).Damper (2) + (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (2)
        elsif V = Item.B then Contribution.Damper (2) else 0.0)));
   procedure Accumulate_Edge (P : Particle_Array; Item : Edge; Contribution : Edge_Force; F : in out Force_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Component);
   begin
      if not P (Item.A).Pinned then
         F (Item.A) := Add_Vertex (F (Item.A), Contribution, True);
      end if;
      if not P (Item.B).Pinned then
         F (Item.B) := Add_Vertex (F (Item.B), Contribution, False);
      end if;
   end Accumulate_Edge;
   procedure Prove_Add_Equality (A : Accumulated_Value; B, C : Force_Value; X : Real)
     with Ghost => Static, Global => null, Pre => B = C and then X = A + B,
     Post => X = A + C is
   begin
      null;
   end Prove_Add_Equality;
   procedure Prove_Edge_Relation (P : Particle_Array; Item : Edge; Contribution : Edge_Force;
     Before, After : Force_Array)
     with Ghost => Static, Global => null,
     Pre => P'First = 1 and then P'Length in 1 .. Max_Count
       and then Before'First = 1 and then Before'Last = P'Last
       and then After'First = 1 and then After'Last = P'Last
       and then Item.A in P'Range and then Item.B in P'Range and then Item.A /= Item.B
       and then Contribution = Load (P, Item)
       and then (for all V in P'Range => Bounded (Before (V).Spring, 1.0e80)
         and then Bounded (Before (V).Damper, 1.0e80));
   pragma Precondition (Static => (for all V in P'Range => After (V).Spring (0) = Before (V).Spring (0) +
     (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (0)
      elsif V = Item.B then Contribution.Spring (0) else 0.0)));
   pragma Precondition (Static => (for all V in P'Range => After (V).Spring (1) = Before (V).Spring (1) +
     (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (1)
      elsif V = Item.B then Contribution.Spring (1) else 0.0)));
   pragma Precondition (Static => (for all V in P'Range => After (V).Spring (2) = Before (V).Spring (2) +
     (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (2)
      elsif V = Item.B then Contribution.Spring (2) else 0.0)));
   pragma Precondition (Static => (for all V in P'Range => After (V).Damper (0) = Before (V).Damper (0) +
     (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (0)
      elsif V = Item.B then Contribution.Damper (0) else 0.0)));
   pragma Precondition (Static => (for all V in P'Range => After (V).Damper (1) = Before (V).Damper (1) +
     (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (1)
      elsif V = Item.B then Contribution.Damper (1) else 0.0)));
   pragma Precondition (Static => (for all V in P'Range => After (V).Damper (2) = Before (V).Damper (2) +
     (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (2)
      elsif V = Item.B then Contribution.Damper (2) else 0.0)));
   pragma Postcondition (Static => (for all V in P'Range => (for all K in Axis =>
     After (V).Spring (K) = Before (V).Spring (K) + Component (P, Item, V, K, False)
     and then After (V).Damper (K) = Before (V).Damper (K) + Component (P, Item, V, K, True))));
   procedure Prove_Edge_Relation (P : Particle_Array; Item : Edge; Contribution : Edge_Force;
     Before, After : Force_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Component);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
   begin
      Prove_Component (P, Item, Contribution);
      for V in P'Range loop
         Prove_Add_Equality (Before (V).Spring (0),
           (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (0)
            elsif V = Item.B then Contribution.Spring (0) else 0.0),
           Component (P, Item, V, 0, False), After (V).Spring (0));
         Prove_Add_Equality (Before (V).Spring (1),
           (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (1)
            elsif V = Item.B then Contribution.Spring (1) else 0.0),
           Component (P, Item, V, 1, False), After (V).Spring (1));
         Prove_Add_Equality (Before (V).Spring (2),
           (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Spring (2)
            elsif V = Item.B then Contribution.Spring (2) else 0.0),
           Component (P, Item, V, 2, False), After (V).Spring (2));
         Prove_Add_Equality (Before (V).Damper (0),
           (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (0)
            elsif V = Item.B then Contribution.Damper (0) else 0.0),
           Component (P, Item, V, 0, True), After (V).Damper (0));
         Prove_Add_Equality (Before (V).Damper (1),
           (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (1)
            elsif V = Item.B then Contribution.Damper (1) else 0.0),
           Component (P, Item, V, 1, True), After (V).Damper (1));
         Prove_Add_Equality (Before (V).Damper (2),
           (if P (V).Pinned then 0.0 elsif V = Item.A then -Contribution.Damper (2)
            elsif V = Item.B then Contribution.Damper (2) else 0.0),
           Component (P, Item, V, 2, True), After (V).Damper (2));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Spring (0) =
           Before (W).Spring (0) + Component (P, Item, W, 0, False));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Spring (1) =
           Before (W).Spring (1) + Component (P, Item, W, 1, False));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Spring (2) =
           Before (W).Spring (2) + Component (P, Item, W, 2, False));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Damper (0) =
           Before (W).Damper (0) + Component (P, Item, W, 0, True));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Damper (1) =
           Before (W).Damper (1) + Component (P, Item, W, 1, True));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Damper (2) =
           Before (W).Damper (2) + Component (P, Item, W, 2, True));
      end loop;
   end Prove_Edge_Relation;
   procedure Prove_Prefix_Add (P : Particle_Array; E : Edge_Array; N, V : Vertex;
     K : Axis; Damper : Boolean; Previous, Current : Real)
     with Ghost => Static, Global => null,
     Pre => Valid (P, E) and then N in E'Range and then V in P'Range
       and then Previous = Prefix (P, E, N - 1, V, K, Damper)
       and then Current = Previous + Component (P, E (N), V, K, Damper),
     Post => Current in Accumulated_Value and then Current = Prefix (P, E, N, V, K, Damper);
   procedure Prove_Prefix_Add (P : Particle_Array; E : Edge_Array; N, V : Vertex;
     K : Axis; Damper : Boolean; Previous, Current : Real) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Component);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Prefix);
      Value : constant Accumulated_Value := Prefix (P, E, N, V, K, Damper);
   begin
      pragma Assert (Value = Current);
   end Prove_Prefix_Add;
   procedure Prove_Accumulation (P : Particle_Array; E : Edge_Array; N : Vertex;
     Before, After : Force_Array)
     with Ghost => Static, Global => null,
     Pre => Valid (P, E) and then N in E'Range
       and then Before'First = 1 and then Before'Last = P'Last
       and then After'First = 1 and then After'Last = P'Last
       and then (for all V in P'Range => (for all K in Axis =>
         Before (V).Spring (K) = Prefix (P, E, N - 1, V, K, False)
         and then Before (V).Damper (K) = Prefix (P, E, N - 1, V, K, True)
         and then After (V).Spring (K) = Before (V).Spring (K) + Component (P, E (N), V, K, False)
         and then After (V).Damper (K) = Before (V).Damper (K) + Component (P, E (N), V, K, True))),
     Post => (for all V in P'Range =>
       Bounded (After (V).Spring, 1.0e80) and then Bounded (After (V).Damper, 1.0e80)
       and then (for all K in Axis => After (V).Spring (K) = Prefix (P, E, N, V, K, False)
         and then After (V).Damper (K) = Prefix (P, E, N, V, K, True)));
   procedure Prove_Accumulation (P : Particle_Array; E : Edge_Array; N : Vertex;
     Before, After : Force_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Component);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
   begin
      for V in P'Range loop
         Prove_Prefix_Add (P, E, N, V, 0, False, Before (V).Spring (0), After (V).Spring (0));
         Prove_Prefix_Add (P, E, N, V, 0, True, Before (V).Damper (0), After (V).Damper (0));
         Prove_Prefix_Add (P, E, N, V, 1, False, Before (V).Spring (1), After (V).Spring (1));
         Prove_Prefix_Add (P, E, N, V, 1, True, Before (V).Damper (1), After (V).Damper (1));
         Prove_Prefix_Add (P, E, N, V, 2, False, Before (V).Spring (2), After (V).Spring (2));
         Prove_Prefix_Add (P, E, N, V, 2, True, Before (V).Damper (2), After (V).Damper (2));
         pragma Loop_Invariant (for all W in 1 .. V =>
           Bounded (After (W).Spring, 1.0e80) and then Bounded (After (W).Damper, 1.0e80));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Spring (0) = Prefix (P, E, N, W, 0, False));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Damper (0) = Prefix (P, E, N, W, 0, True));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Spring (1) = Prefix (P, E, N, W, 1, False));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Damper (1) = Prefix (P, E, N, W, 1, True));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Spring (2) = Prefix (P, E, N, W, 2, False));
         pragma Loop_Invariant (for all W in 1 .. V => After (W).Damper (2) = Prefix (P, E, N, W, 2, True));
      end loop;
   end Prove_Accumulation;
   type Evaluation is record
      Admissible : Boolean;
      Value : Edge_Force;
   end record;
   function Evaluate_Edge (P : Particle_Array; Item : Edge) return Evaluation
     with Global => null, Pre => Item.A in P'Range and then Item.B in P'Range,
     Post => Bounded (Evaluate_Edge'Result.Value.Spring, 1.0e74)
       and then Bounded (Evaluate_Edge'Result.Value.Damper, 1.0e74);
   pragma Postcondition (Static => Evaluate_Edge'Result.Value = Load (P, Item)
     and then Evaluate_Edge'Result.Admissible = Measure (P (Item.A), P (Item.B)).Admissible);
   function Evaluate_Edge (P : Particle_Array; Item : Edge) return Evaluation is
      G : constant Geometry := Measure (P (Item.A), P (Item.B));
   begin
      return (G.Admissible, Force (G, Item.Rest, Item.Stiffness, Item.Damping));
   end Evaluate_Edge;
   --  One edge is a separate proof boundary; all model traversals are static
   --  ghost code and disappear from the executable.
   procedure Accumulate_Next (P : Particle_Array; E : Edge_Array; I : Vertex;
     F : in out Force_Array; Accepted : out Boolean)
     with Global => null,
     Pre => Valid (P, E) and then I in E'Range
       and then F'First = 1 and then F'Last = P'Last
       and then (for all V in P'Range => Bounded (F (V).Spring, 1.0e80)
         and then Bounded (F (V).Damper, 1.0e80));
   pragma Precondition (Static => (for all V in P'Range =>
     F (V).Spring (0) = Prefix (P, E, I - 1, V, 0, False)));
   pragma Precondition (Static => (for all V in P'Range =>
     F (V).Spring (1) = Prefix (P, E, I - 1, V, 1, False)));
   pragma Precondition (Static => (for all V in P'Range =>
     F (V).Spring (2) = Prefix (P, E, I - 1, V, 2, False)));
   pragma Precondition (Static => (for all V in P'Range =>
     F (V).Damper (0) = Prefix (P, E, I - 1, V, 0, True)));
   pragma Precondition (Static => (for all V in P'Range =>
     F (V).Damper (1) = Prefix (P, E, I - 1, V, 1, True)));
   pragma Precondition (Static => (for all V in P'Range =>
     F (V).Damper (2) = Prefix (P, E, I - 1, V, 2, True)));
   pragma Postcondition (Static => (for all V in P'Range =>
     Bounded (F (V).Spring, 1.0e80) and then Bounded (F (V).Damper, 1.0e80)));
   pragma Postcondition (Static => (if Accepted then (for all V in P'Range =>
     F (V).Spring (0) = Prefix (P, E, I, V, 0, False))));
   pragma Postcondition (Static => (if Accepted then (for all V in P'Range =>
     F (V).Spring (1) = Prefix (P, E, I, V, 1, False))));
   pragma Postcondition (Static => (if Accepted then (for all V in P'Range =>
     F (V).Spring (2) = Prefix (P, E, I, V, 2, False))));
   pragma Postcondition (Static => (if Accepted then (for all V in P'Range =>
     F (V).Damper (0) = Prefix (P, E, I, V, 0, True))));
   pragma Postcondition (Static => (if Accepted then (for all V in P'Range =>
     F (V).Damper (1) = Prefix (P, E, I, V, 1, True))));
   pragma Postcondition (Static => (if Accepted then (for all V in P'Range =>
     F (V).Damper (2) = Prefix (P, E, I, V, 2, True))));
   procedure Accumulate_Next (P : Particle_Array; E : Edge_Array; I : Vertex;
     F : in out Force_Array; Accepted : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Component);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
      Computed : constant Evaluation := Evaluate_Edge (P, E (I));
      Before : constant Force_Array := F with Ghost => Static;
   begin
      Accepted := Computed.Admissible;
      if not Accepted then return; end if;
      Accumulate_Edge (P, E (I), Computed.Value, F);
      Prove_Edge_Relation (P, E (I), Computed.Value, Before, F);
      Prove_Accumulation (P, E, I, Before, F);
   end Accumulate_Next;
   procedure Forces (P : Particle_Array; E : Edge_Array; F : out Force_Array; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Component);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
      Accepted : Boolean;
   begin
      Result := Numeric_Limit;
      F := [others => (Spring => Zero, Damper => Zero)];
      if E'Length = 0 then
         Result := Success;
         return;
      end if;
      for I in E'Range loop
         Accumulate_Next (P, E, I, F, Accepted);
         if not Accepted then
            F := [others => (Spring => Zero, Damper => Zero)];
            return;
         end if;
         pragma Loop_Invariant (for all V in F'Range =>
           Bounded (F (V).Spring, 1.0e80) and then Bounded (F (V).Damper, 1.0e80));
         pragma Loop_Invariant (Static => (for all V in P'Range =>
           F (V).Spring (0) = Prefix (P, E, I, V, 0, False)));
         pragma Loop_Invariant (Static => (for all V in P'Range =>
           F (V).Spring (1) = Prefix (P, E, I, V, 1, False)));
         pragma Loop_Invariant (Static => (for all V in P'Range =>
           F (V).Spring (2) = Prefix (P, E, I, V, 2, False)));
         pragma Loop_Invariant (Static => (for all V in P'Range =>
           F (V).Damper (0) = Prefix (P, E, I, V, 0, True)));
         pragma Loop_Invariant (Static => (for all V in P'Range =>
           F (V).Damper (1) = Prefix (P, E, I, V, 1, True)));
         pragma Loop_Invariant (Static => (for all V in P'Range =>
           F (V).Damper (2) = Prefix (P, E, I, V, 2, True)));
      end loop;
      Result := Success;
   end Forces;
   procedure Advance_Particle (P : in out Particle; F : Edge_Force;
     Applied, Gravity : Input_Vector; Dt : Time_Step; Result : out Status)
     with Global => null,
     Pre => Bounded (F.Spring, 1.0e80) and then Bounded (F.Damper, 1.0e80),
     Post => (if Result /= Success or else P'Old.Pinned then P = P'Old else
       P.Mass = P'Old.Mass and then P.Pinned = P'Old.Pinned and then
       (for all K in Axis => P.Velocity (K) = Advance_Velocity
         (P'Old.Velocity (K), P'Old.Mass, F.Spring (K), F.Damper (K), Applied (K), Gravity (K), Dt)
         and then P.Position (K) = P'Old.Position (K) + Dt * P.Velocity (K)));
   procedure Advance_Particle (P : in out Particle; F : Edge_Force;
     Applied, Gravity : Input_Vector; Dt : Time_Step; Result : out Status) is
      Candidate : Particle := P;
      Accepted : Boolean;
   begin
      Result := Success;
      if P.Pinned then return; end if;
      Result := Numeric_Limit;
      for K in Axis loop
         Advance_Coordinate (Candidate.Position (K), Candidate.Velocity (K), P.Mass,
           F.Spring (K), F.Damper (K), Applied (K), Gravity (K), Dt, Accepted);
         if not Accepted then return; end if;
      end loop;
      P := Candidate;
      Result := Success;
   end Advance_Particle;
   procedure Prove_Velocity_Replacement (Velocity : Tier0_Real; Mass : Mass_Value;
     Spring, Damper, Expected_Spring, Expected_Damper : Accumulated_Value;
     Applied, Gravity : Tier0_Real; Dt : Time_Step; Actual : Tier0_Real)
     with Ghost => Static, Global => null,
     Pre => Spring = Expected_Spring and then Damper = Expected_Damper
       and then Actual = Advance_Velocity (Velocity, Mass, Spring, Damper, Applied, Gravity, Dt),
     Post => Actual = Advance_Velocity (Velocity, Mass, Expected_Spring, Expected_Damper, Applied, Gravity, Dt) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Advance_Velocity);
   begin
      null;
   end Prove_Velocity_Replacement;
   procedure Prove_Vertex_Step (P : Particle_Array; E : Edge_Array; V : Vertex;
     After : Particle; F : Edge_Force; Applied, Gravity : Input_Vector; Dt : Time_Step)
     with Ghost => Static, Global => null,
     Pre => Valid (P, E) and then V in P'Range
       and then Bounded (F.Spring, 1.0e80) and then Bounded (F.Damper, 1.0e80)
       and then (for all K in Axis => F.Spring (K) = Prefix (P, E, E'Length, V, K, False)
         and then F.Damper (K) = Prefix (P, E, E'Length, V, K, True))
       and then (if not P (V).Pinned then (for all K in Axis => After.Velocity (K) = Advance_Velocity
         (P (V).Velocity (K), P (V).Mass, F.Spring (K), F.Damper (K), Applied (K), Gravity (K), Dt))),
     Post => (if not P (V).Pinned then (for all K in Axis => After.Velocity (K) = Advance_Velocity
       (P (V).Velocity (K), P (V).Mass, Prefix (P, E, E'Length, V, K, False),
        Prefix (P, E, E'Length, V, K, True), Applied (K), Gravity (K), Dt)));
   procedure Prove_Vertex_Step (P : Particle_Array; E : Edge_Array; V : Vertex;
     After : Particle; F : Edge_Force; Applied, Gravity : Input_Vector; Dt : Time_Step) is
   begin
      if P (V).Pinned then return; end if;
      for K in Axis loop
         Prove_Velocity_Replacement (P (V).Velocity (K), P (V).Mass, F.Spring (K), F.Damper (K),
           Prefix (P, E, E'Length, V, K, False), Prefix (P, E, E'Length, V, K, True),
           Applied (K), Gravity (K), Dt, After.Velocity (K));
      end loop;
   end Prove_Vertex_Step;
   procedure Step (P : in out Particle_Array; E : Edge_Array;
                   Applied : Input_Array; Gravity : Input_Vector;
                   Dt : Time_Step; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Component);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Load);
      F : Force_Array (P'Range);
      Next : Particle_Array := P;
   begin
      Forces (P, E, F, Result);
      if Result /= Success then return; end if;
      for V in P'Range loop
         pragma Loop_Invariant (Static => (for all W in V .. P'Last => Next (W) = P (W)));
         pragma Loop_Invariant (Static => (for all W in P'Range =>
           Next (W).Mass = P (W).Mass and then Next (W).Pinned = P (W).Pinned));
         pragma Loop_Invariant (Static => (for all W in 1 .. V - 1 =>
           (if P (W).Pinned then Next (W) = P (W) else
            (for all K in Axis =>
              Next (W).Velocity (K) = Advance_Velocity
                (P (W).Velocity (K), P (W).Mass, Prefix (P, E, E'Length, W, K, False), Prefix (P, E, E'Length, W, K, True),
                 Applied (W) (K), Gravity (K), Dt)
              and then Next (W).Position (K) = P (W).Position (K) + Dt * Next (W).Velocity (K)))));
         Advance_Particle (Next (V), F (V), Applied (V), Gravity, Dt, Result);
         if Result /= Success then return; end if;
         Prove_Vertex_Step (P, E, V, Next (V), F (V), Applied (V), Gravity, Dt);
      end loop;
      P := Next;
      Result := Success;
   end Step;
end MJ.Elastic_Network;

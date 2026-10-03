package body MJ.Model_Compiler.Addresses with SPARK_Mode is
   procedure Reveal_Flag_Count (Flags : Flag_Array; Count : Natural) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Flag_Count);
   begin
      null;
   end Reveal_Flag_Count;

   procedure Compile_Mocap
     (Flags : Flag_Array; Ids : in out Int_Array;
      Count : in out Size_Type; Status : out Result)
   is
      Cursor : Size_Type := 0;
   begin
      Status := Invalid_Shape;
      if Flags'First /= 0 or else Ids'First /= 0 or else Ids'Length /= Flags'Length then return; end if;
      Status := Capacity_Limit;
      if Flags'Length > Max_Elements then return; end if;
      Reveal_Flag_Count (Flags, 0);
      for I in Flags'Range loop
         pragma Loop_Invariant (Static => Cursor <= I);
         pragma Loop_Invariant (Static => Cursor = Flag_Count (Flags, I));
         pragma Loop_Invariant (Static =>
           (for all K in 0 .. I - 1 => Ids (K) = (if Flags (K) then Flag_Count (Flags, K) else -1)));
         Ids (I) := (if Flags (I) then Cursor else -1);
         if Flags (I) then Cursor := Cursor + 1; end if;
         Reveal_Flag_Count (Flags, I + 1);
      end loop;
      Count := Cursor; Status := Success;
   end Compile_Mocap;

   procedure Compile_Ordinals (Ids : in out Int_Array; Status : out Result) is
   begin
      Status := Invalid_Shape;
      if Ids'First /= 0 then return; end if;
      Status := Capacity_Limit;
      if Ids'Length > Max_Elements then return; end if;
      for I in Ids'Range loop
         pragma Loop_Invariant (Static => (for all K in 0 .. I - 1 => Ids (K) = K));
         Ids (I) := I;
      end loop;
      Status := Success;
   end Compile_Ordinals;

   procedure Reveal_Prefix (Blocks : Actuator_Array; Count : Natural) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Prefix);
   begin
      null;
   end Reveal_Prefix;

   procedure Prefix_Monotonic (Blocks : Actuator_Array; First, Last : Natural) is
   begin
      if First < Last then
         Prefix_Monotonic (Blocks, First, Last - 1);
         Reveal_Prefix (Blocks, Last);
         pragma Assert (Static =>
           Prefix (Blocks, Last).Control = Prefix (Blocks, Last - 1).Control + Int64 (Blocks (Last - 1).Controls)
           and then Prefix (Blocks, Last).Output = Prefix (Blocks, Last - 1).Output + Int64 (Blocks (Last - 1).Outputs)
           and then Prefix (Blocks, Last).Activation = Prefix (Blocks, Last - 1).Activation + Int64 (Blocks (Last - 1).Activations));
      end if;
   end Prefix_Monotonic;

   procedure Compile_Joints
     (Kinds : Joint_Array; Position, Velocity : in out Int_Array;
      Nq, Nv : in out Size_Type; Status : out Result)
   is
      Q, V : Size_Type := 0;
   begin
      Status := Invalid_Shape;
      if Kinds'First /= 0 or else Position'First /= 0 or else Velocity'First /= 0
        or else Position'Length /= Kinds'Length or else Velocity'Length /= Kinds'Length
      then return; end if;
      Status := Capacity_Limit;
      if Kinds'Length > Max_Elements then return; end if;
      for I in Kinds'Range loop
         pragma Loop_Invariant (Static => Q <= I * 7 and then V <= I * 6);
         pragma Loop_Invariant
           (Static => (for all K in 0 .. I - 1 => Position (K) in 0 .. K * 7
             and then Velocity (K) in 0 .. K * 6
             and then (if K = 0 then Position (K) = 0 and then Velocity (K) = 0
               else Position (K) = Position (K - 1) + Position_Width (Kinds (K - 1))
                 and then Velocity (K) = Velocity (K - 1) + Velocity_Width (Kinds (K - 1)))));
         pragma Loop_Invariant
           (Static => (if I > 0 then Q = Position (I - 1) + Position_Width (Kinds (I - 1))
             and then V = Velocity (I - 1) + Velocity_Width (Kinds (I - 1))));
         Position (I) := Q;
         Velocity (I) := V;
         Q := Q + Position_Width (Kinds (I));
         V := V + Velocity_Width (Kinds (I));
      end loop;
      Nq := Q; Nv := V; Status := Success;
   end Compile_Joints;

   procedure Compile_Actuators
     (Blocks : Actuator_Array; Addresses : in out Actuator_Address_Array;
      Counts : in out Totals; Status : out Result)
   is
      Total : Totals := (0, 0, 0);
      Cursor : Totals := (0, 0, 0);
   begin
      Status := Invalid_Shape;
      if Blocks'First /= 0 or else Addresses'First /= 0
        or else Addresses'Length /= Blocks'Length then return; end if;
      Status := Capacity_Limit;
      if Blocks'Length > Max_Elements then return; end if;
      --  Preflight all three streams before publishing any address.
      Reveal_Prefix (Blocks, 0);
      for I in Blocks'Range loop
         pragma Loop_Invariant
           (Static => Int64 (Total.Control) = Prefix (Blocks, I).Control
            and then Int64 (Total.Output) = Prefix (Blocks, I).Output
            and then Int64 (Total.Activation) = Prefix (Blocks, I).Activation);
         if Blocks (I).Controls > Max_Size - Total.Control
           or else Blocks (I).Outputs > Max_Size - Total.Output
           or else Blocks (I).Activations > Max_Size - Total.Activation then return; end if;
         Total.Control := Total.Control + Blocks (I).Controls;
         Total.Output := Total.Output + Blocks (I).Outputs;
         Total.Activation := Total.Activation + Blocks (I).Activations;
         Reveal_Prefix (Blocks, I + 1);
         pragma Assert (Static =>
           Int64 (Total.Control) = Prefix (Blocks, I + 1).Control
           and then Int64 (Total.Output) = Prefix (Blocks, I + 1).Output
           and then Int64 (Total.Activation) = Prefix (Blocks, I + 1).Activation);
      end loop;
      for I in Blocks'Range loop
         pragma Loop_Invariant
           (Static => Cursor.Control <= Total.Control and then Cursor.Output <= Total.Output
             and then Cursor.Activation <= Total.Activation);
         pragma Loop_Invariant
           (Static => Int64 (Cursor.Control) = Prefix (Blocks, I).Control
            and then Int64 (Cursor.Output) = Prefix (Blocks, I).Output
            and then Int64 (Cursor.Activation) = Prefix (Blocks, I).Activation);
         pragma Loop_Invariant
           (Static => Int64 (Total.Control) = Prefix (Blocks, Blocks'Length).Control
            and then Int64 (Total.Output) = Prefix (Blocks, Blocks'Length).Output
            and then Int64 (Total.Activation) = Prefix (Blocks, Blocks'Length).Activation);
         pragma Loop_Invariant
           (Static => (for all K in 0 .. I - 1 =>
             Int64 (Addresses (K).Control) =
               (if Blocks (K).Controls = 0 then -1 else Prefix (Blocks, K).Control)
             and then Int64 (Addresses (K).Output) = Prefix (Blocks, K).Output
             and then Int64 (Addresses (K).Activation) =
               (if Blocks (K).Activations = 0 then -1 else Prefix (Blocks, K).Activation)));
         Reveal_Prefix (Blocks, I + 1);
         pragma Assert (Static =>
           Prefix (Blocks, I + 1).Control = Int64 (Cursor.Control) + Int64 (Blocks (I).Controls)
           and then Prefix (Blocks, I + 1).Output = Int64 (Cursor.Output) + Int64 (Blocks (I).Outputs)
           and then Prefix (Blocks, I + 1).Activation = Int64 (Cursor.Activation) + Int64 (Blocks (I).Activations));
         Prefix_Monotonic (Blocks, I + 1, Blocks'Length);
         --  Preflight guarantees these sums fit. The following guards retain a
         --  checked numerical boundary; they are proved unreachable here.
         pragma Assert (Static =>
           Blocks (I).Controls <= Total.Control - Cursor.Control
           and then Blocks (I).Outputs <= Total.Output - Cursor.Output
           and then Blocks (I).Activations <= Total.Activation - Cursor.Activation);
         Addresses (I) :=
           (Control => (if Blocks (I).Controls = 0 then -1 else Cursor.Control),
            Output => Cursor.Output,
            Activation => (if Blocks (I).Activations = 0 then -1 else Cursor.Activation));
         Cursor.Control := Cursor.Control + Blocks (I).Controls;
         Cursor.Output := Cursor.Output + Blocks (I).Outputs;
         Cursor.Activation := Cursor.Activation + Blocks (I).Activations;
      end loop;
      Counts := Total; Status := Success;
   end Compile_Actuators;
end MJ.Model_Compiler.Addresses;

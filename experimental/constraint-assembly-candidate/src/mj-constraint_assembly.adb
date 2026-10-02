--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see the repository LICENSE.
--  Modified: Ada/SPARK translation, bounded storage and formal contracts.
package body MJ.Constraint_Assembly with SPARK_Mode is
   procedure Reset (B : in out Storage; Dofs : Dof_Count) is
   begin
      B.Dofs := Dofs;
      B.Rows := 0;
      B.Used := 0;
      B.Ne := 0;
      B.Nf := 0;
      B.Nl := 0;
   end Reset;

   --  One contiguous copy per row. Keeping this primitive separate also keeps
   --  the array frame proof independent of the block/counter proof.
   procedure Copy_Row
     (B : in out Storage; Target : Positive; Base : Entry_Count;
      Chain : Column_Array; J : Matrix; Source : Positive;
      Pos : Parameters; Loss : Nonneg_Tier0; Kind : Constraint_Kind; Id : Natural)
   with
     Global => null,
     Pre => Valid (B) and then Target in B.Descriptors'Range
       and then Chain'First = 1 and then Chain'Length <= Max_Dofs
       and then Source in J'Range (1) and then Source <= Max_Block
       and then Base + Source * Chain'Length <= B.Entry_Cap
       and then J'First (2) = 1 and then J'Length (2) = Chain'Length,
     Post => (Static => B.Dofs = B.Dofs'Old and then B.Rows = B.Rows'Old
       and then B.Used = B.Used'Old and then B.Ne = B.Ne'Old
       and then B.Nf = B.Nf'Old and then B.Nl = B.Nl'Old
       and then Row_Is (B.Descriptors (Target), Base + (Source - 1) * Chain'Length,
                       Chain'Length, Pos, Loss, Kind, Id)
       and then (for all C in Chain'Range =>
         B.Values ((Base + (Source - 1) * Chain'Length) + C) = J (Source, C))
       and then (for all C in Chain'Range =>
         B.Columns ((Base + (Source - 1) * Chain'Length) + C) = Chain (C))
       and then (for all R in B.Descriptors'Range =>
         (if R /= Target then B.Descriptors (R) = B.Descriptors'Old (R)))
       and then (for all C in B.Values'Range =>
         (if C <= Base + (Source - 1) * Chain'Length
             or else C > Base + Source * Chain'Length then
           B.Values (C) = B.Values'Old (C) and then B.Columns (C) = B.Columns'Old (C)))
       --  The same frame property, expressed in the caller's row coordinates.
       --  This supplies a direct trigger for preservation of earlier rows.
       and then (for all Q in 1 .. Source - 1 => (for all C in Chain'Range =>
         B.Values ((Base + (Q - 1) * Chain'Length) + C) =
           B.Values'Old ((Base + (Q - 1) * Chain'Length) + C)))
       and then (for all Q in 1 .. Source - 1 => (for all C in Chain'Range =>
         B.Columns ((Base + (Q - 1) * Chain'Length) + C) =
           B.Columns'Old ((Base + (Q - 1) * Chain'Length) + C))))
   is
      Offset : constant Entry_Count := Base + (Source - 1) * Chain'Length;
   begin
      for C in Chain'Range loop
         B.Values (Offset + C) := J (Source, C);
         B.Columns (Offset + C) := Chain (C);
         pragma Loop_Invariant (Static => (for all K in 1 .. C =>
           B.Values (Offset + K) = J (Source, K) and then B.Columns (Offset + K) = Chain (K)));
         pragma Loop_Invariant (Static => (for all K in B.Values'Range =>
           (if K <= Offset or else K > Offset + C then
             B.Values (K) = B.Values'Loop_Entry (K) and then B.Columns (K) = B.Columns'Loop_Entry (K))));
      end loop;
      B.Descriptors (Target) := (Offset, Chain'Length, Pos, Loss, Kind, Id);
   end Copy_Row;

   procedure Reframe_Row
     (D : Row; Offset : Entry_Count; Width : Dof_Count; Pos, Expected : Parameters;
      Loss : Nonneg_Tier0; Kind : Constraint_Kind; Id : Natural)
   with
     Ghost => Static, Global => null,
     Pre => Row_Is (D, Offset, Width, Pos, Loss, Kind, Id)
       and then Parameter_Is (Pos, Expected),
     Post => Row_Is (D, Offset, Width, Expected, Loss, Kind, Id)
   is
   begin
      null;
   end Reframe_Row;

   --  Compose the independently proved contact formula and CSR copy one entry
   --  at a time. The entire helper is static ghost code, including its loop.
   procedure Reframe_Contact_Values
     (B : Storage; Base : Entry_Count; Dim : Contact_Dimension;
      Cone : Cone_Kind; Chain : Column_Array; J, Prepared : Matrix; Mu : Friction_Array)
   with
     Ghost => Static, Global => null,
     Pre => Chain'First = 1 and then Chain'Length <= Max_Dofs
       and then J'First (1) = 1 and then J'Length (1) = Dim
       and then J'First (2) = 1 and then J'Length (2) = Chain'Length
       and then (for all JR in J'Range (1) => (for all JC in J'Range (2) =>
         J (JR, JC) in -1.0e20 .. 1.0e20))
       and then Prepared'First (1) = 1
       and then Prepared'Length (1) = Contact_Rows (Dim, Cone)
       and then Prepared'First (2) = 1 and then Prepared'Length (2) = Chain'Length
       and then Base + Contact_Rows (Dim, Cone) * Chain'Length <= B.Entry_Cap
       and then (for all R in 1 .. Contact_Rows (Dim, Cone) => (for all C in Chain'Range =>
         B.Values ((Base + (R - 1) * Chain'Length) + C) = Prepared (R, C)))
       and then (for all R in 1 .. Contact_Rows (Dim, Cone) => (for all C in Chain'Range =>
         Prepared (R, C) = Contact_Value (Dim, Cone, J, Mu, R, C))),
     Post => (for all R in 1 .. Contact_Rows (Dim, Cone) => (for all C in Chain'Range =>
       B.Values ((Base + (R - 1) * Chain'Length) + C) =
         Contact_Value (Dim, Cone, J, Mu, R, C)))
   is
   begin
      for R in 1 .. Contact_Rows (Dim, Cone) loop
         for C in Chain'Range loop
            pragma Assert (B.Values ((Base + (R - 1) * Chain'Length) + C) = Prepared (R, C));
            pragma Assert (Prepared (R, C) = Contact_Value (Dim, Cone, J, Mu, R, C));
            pragma Loop_Invariant (for all K in 1 .. C =>
              B.Values ((Base + (R - 1) * Chain'Length) + K) =
                Contact_Value (Dim, Cone, J, Mu, R, K));
         end loop;
         pragma Loop_Invariant (for all Q in 1 .. R => (for all C in Chain'Range =>
           B.Values ((Base + (Q - 1) * Chain'Length) + C) =
             Contact_Value (Dim, Cone, J, Mu, Q, C)));
      end loop;
   end Reframe_Contact_Values;

   procedure Append
     (B : in out Storage; Kind : Constraint_Kind; Id : Natural;
      Chain : Column_Array; J : Matrix; Pos : Parameter_Array;
      Loss : Nonneg_Tier0; Status : out Result)
   is
      Old_Rows : constant Row_Count := B.Rows;
      Old_Used : constant Entry_Count := B.Used;
      Width : constant Dof_Count := Chain'Length;
   begin
      Status := Skipped;
      if Width = 0 and then not Is_Contact (Kind) then
         return;
      end if;
      Status := Capacity_Limit;
      if not Fits (B, Pos'Length, Width) then
         return;
      end if;
      for R in Pos'Range loop
         Copy_Row (B, Old_Rows + R, Old_Used,
                   Chain, J, R, Pos (R), Loss, Kind, Id);
         pragma Loop_Invariant (B.Rows = Old_Rows and then B.Used = Old_Used);
         pragma Loop_Invariant (B.Dofs = B.Dofs'Loop_Entry
           and then B.Ne = B.Ne'Loop_Entry and then B.Nf = B.Nf'Loop_Entry and then B.Nl = B.Nl'Loop_Entry);
         pragma Loop_Invariant (Static => (for all Q in 1 .. R =>
           Row_Is (B.Descriptors (Old_Rows + Q),
             Old_Used + (Q - 1) * Width, Width, Pos (Q), Loss, Kind, Id)));
         pragma Loop_Invariant (Static => (for all Q in 1 .. R => (for all C in Chain'Range =>
           B.Values ((Old_Used + (Q - 1) * Width) + C) = J (Q, C))));
         pragma Loop_Invariant (Static => (for all Q in 1 .. R => (for all C in Chain'Range =>
           B.Columns ((Old_Used + (Q - 1) * Width) + C) = Chain (C))));
         pragma Loop_Invariant (Static => (for all Q in B.Descriptors'Range =>
           (if Q <= Old_Rows or else Q > Old_Rows + R then
              B.Descriptors (Q) = B.Descriptors'Loop_Entry (Q))));
         pragma Loop_Invariant (Static => (for all C in B.Values'Range =>
           (if C <= Old_Used or else C > Old_Used + R * Width then
              B.Values (C) = B.Values'Loop_Entry (C) and then B.Columns (C) = B.Columns'Loop_Entry (C))));
      end loop;
      B.Rows := Old_Rows + Pos'Length;
      B.Used := Old_Used + Pos'Length * Width;
      case Kind is
         when Equality => B.Ne := B.Ne + Pos'Length;
         when Friction_Dof | Friction_Tendon => B.Nf := B.Nf + Pos'Length;
         when Limit_Joint | Limit_Tendon => B.Nl := B.Nl + Pos'Length;
         when others => null;
      end case;
      Status := Success;
   end Append;

   procedure Build_Contact
     (Dim : Contact_Dimension; Cone : Cone_Kind; J : Matrix;
      Mu : Friction_Array; Distance, Margin : Tier1_Real;
      Values : out Matrix; Pos : out Parameter_Array)
   is
   begin
      for R in Values'Range (1) loop
         pragma Loop_Invariant (Static => (for all Q in 1 .. R - 1 => Pos (Q)'Initialized));
         pragma Loop_Invariant (Static => (for all Q in 1 .. R - 1 =>
           (for all C in Values'Range (2) => Values (Q, C)'Initialized)));
         pragma Loop_Invariant (Static => (for all Q in 1 .. R - 1 =>
           Parameter_Is (Pos (Q), Contact_Parameter (Dim, Cone, Q, Distance, Margin))));
         pragma Loop_Invariant (Static => (for all Q in 1 .. R - 1 => (for all C in Values'Range (2) =>
           Values (Q, C) = Contact_Value (Dim, Cone, J, Mu, Q, C))));
         Pos (R) := Contact_Parameter (Dim, Cone, R, Distance, Margin);
         for C in Values'Range (2) loop
            pragma Loop_Invariant (Static => (for all Q in 1 .. R - 1 =>
              (for all K in Values'Range (2) => Values (Q, K)'Initialized
                and then Values (Q, K) = Contact_Value (Dim, Cone, J, Mu, Q, K))));
            pragma Loop_Invariant (Static => (for all K in 1 .. C - 1 => Values (R, K)'Initialized));
            pragma Loop_Invariant (Static => (for all K in 1 .. C - 1 =>
              Values (R, K) = Contact_Value (Dim, Cone, J, Mu, R, K)));
            if Dim = 1 or else Cone = Elliptic then
               Values (R, C) := J (R, C);
            elsif R mod 2 = 1 then
               Values (R, C) := Edge_Value (J (1, C), J (1 + (R + 1) / 2, C), Mu ((R + 1) / 2));
            else
               Values (R, C) := Edge_Value (J (1, C), J (1 + (R + 1) / 2, C), -Mu ((R + 1) / 2));
            end if;
         end loop;
      end loop;
   end Build_Contact;

   procedure Add_Contact
     (B : in out Storage; Id : Natural; Dim : Contact_Dimension; Cone : Cone_Kind;
      Chain : Column_Array; J : Matrix; Mu : Friction_Array;
      Distance, Margin : Tier1_Real; Status : out Result)
   is
      Values : Matrix (1 .. Contact_Rows (Dim, Cone), 1 .. Chain'Length);
      Pos : Parameter_Array (1 .. Contact_Rows (Dim, Cone));
      Old_Rows : constant Row_Count := B.Rows with Ghost => Static;
      Old_Used : constant Entry_Count := B.Used with Ghost => Static;
   begin
      if Chain'Length = 0 then
         Status := Skipped;
         return;
      end if;
      if not Fits (B, Contact_Rows (Dim, Cone), Chain'Length) then
         Status := Capacity_Limit;
         return;
      end if;
      Build_Contact (Dim, Cone, J, Mu, Distance, Margin, Values, Pos);
      pragma Assert (Static => (for all R in Pos'Range =>
        Parameter_Is (Pos (R), Contact_Parameter (Dim, Cone, R, Distance, Margin))));
      Append (B, Contact_Type (Dim, Cone), Id, Chain, Values, Pos, 0.0, Status);
      pragma Assert (Static => Status = Success);
      pragma Assert (Static => (for all R in 1 .. Pos'Length => (for all C in Chain'Range =>
        B.Values ((Old_Used + (R - 1) * Chain'Length) + C) = Values (R, C))));
      Reframe_Contact_Values (B, Old_Used, Dim, Cone, Chain, J, Values, Mu);
      --  Only ghost calls/assertions: no row traversal remains after static
      --  ghost removal and normal dead-loop elimination in either profile.
      for R in Pos'Range loop
         Reframe_Row (B.Descriptors (Old_Rows + R),
           Old_Used + (R - 1) * Chain'Length, Chain'Length, Pos (R),
           Contact_Parameter (Dim, Cone, R, Distance, Margin),
           0.0, Contact_Type (Dim, Cone), Id);
         pragma Loop_Invariant (Static => (for all Q in 1 .. R =>
           Row_Is (B.Descriptors (Old_Rows + Q),
             Old_Used + (Q - 1) * Chain'Length, Chain'Length,
             Contact_Parameter (Dim, Cone, Q, Distance, Margin),
             0.0, Contact_Type (Dim, Cone), Id)));
      end loop;
   end Add_Contact;

   procedure Add_Dof_Friction
     (B : in out Storage; Dof : Column; Loss : Nonneg_Tier0; Status : out Result)
   is
      Chain : constant Column_Array (1 .. 1) := (1 => Dof);
      J : constant Matrix (1 .. 1, 1 .. 1) := (1 => (1 => 1.0));
      Pos : constant Parameter_Array (1 .. 1) := (1 => (0.0, 0.0));
   begin
      if Loss = 0.0 then
         Status := Skipped;
         return;
      end if;
      Append (B, Friction_Dof, Dof, Chain, J, Pos, Loss, Status);
   end Add_Dof_Friction;

   procedure Add_Scalar_Limit
     (B : in out Storage; Id : Natural; Dof : Column; Side : Limit_Side;
      Value, Bound, Margin : Tier0_Real; Status : out Result)
   is
      Distance : constant Tier1_Real := Limit_Distance (Value, Bound, Side);
      Chain : constant Column_Array (1 .. 1) := (1 => Dof);
      J : constant Matrix (1 .. 1, 1 .. 1) := (1 => (1 => (if Side = Lower then 1.0 else -1.0)));
      Pos : constant Parameter_Array (1 .. 1) := (1 => (Distance, Margin));
   begin
      if Distance >= Margin then
         Status := Skipped;
         return;
      end if;
      Append (B, Limit_Joint, Id, Chain, J, Pos, 0.0, Status);
   end Add_Scalar_Limit;
end MJ.Constraint_Assembly;

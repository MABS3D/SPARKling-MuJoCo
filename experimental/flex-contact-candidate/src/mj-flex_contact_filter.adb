package body MJ.Flex_Contact_Filter with SPARK_Mode is
   procedure Relate_Distance (A, B, X, Y : Point)
     with Ghost => Static, Global => null, Pre => A = B and then X = Y,
     Post => Distance2 (A, X) = Distance2 (B, Y);
   procedure Relate_Distance (A, B, X, Y : Point) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Distance2);
   begin
      pragma Assert (A (0) = B (0) and then X (0) = Y (0));
      pragma Assert (A (1) = B (1) and then X (1) = Y (1));
      pragma Assert (A (2) = B (2) and then X (2) = Y (2));
      pragma Assert (A (0) - X (0) = B (0) - Y (0));
      pragma Assert (A (1) - X (1) = B (1) - Y (1));
      pragma Assert (A (2) - X (2) = B (2) - Y (2));
   end Relate_Distance;
   procedure Relate_Updated (A, B : State; I : Vertex)
     with Ghost => Static, Global => null,
     Pre => A = B and then A.Best in 1 .. A.Used and then B.Best in 1 .. B.Used
       and then I <= A.Capacity and then I <= B.Capacity,
     Post => Updated (A, I) = Updated (B, I);
   procedure Relate_Updated (A, B : State; I : Vertex) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Updated);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Distance2);
   begin
      pragma Assert (A.Capacity = B.Capacity and then A.Used = B.Used and then A.Best = B.Best);
      pragma Assert (A.Marked (I) = B.Marked (I) and then A.Minima (I) = B.Minima (I));
      for K in Axis loop
         pragma Assert (A.Items (I).Position (K) = B.Items (I).Position (K));
         pragma Assert (A.Items (A.Best).Position (K) = B.Items (B.Best).Position (K));
         pragma Loop_Invariant (for all J in Axis'First .. K =>
           A.Items (I).Position (J) = B.Items (I).Position (J)
           and then A.Items (A.Best).Position (J) = B.Items (B.Best).Position (J));
      end loop;
      Relate_Distance (A.Items (I).Position, B.Items (I).Position,
                       A.Items (A.Best).Position, B.Items (B.Best).Position);
   end Relate_Updated;
   procedure Relate_Next (A, B : State; N : Count)
     with Ghost => Static, Global => null,
     Pre => A = B and then A.Best in 1 .. A.Used and then B.Best in 1 .. B.Used
       and then N <= A.Used and then N <= B.Used,
     Post => Model.Next_Best (A, N) = Model.Next_Best (B, N),
     Subprogram_Variant => (Decreases => N);
   procedure Relate_Next (A, B : State; N : Count) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Next_Best);
      Previous : Count;
   begin
      if N = 0 then return; end if;
      Relate_Next (A, B, N - 1);
      Relate_Updated (A, B, N);
      Previous := Model.Next_Best (A, N - 1);
      if Previous > 0 then Relate_Updated (A, B, Previous); end if;
   end Relate_Next;
   procedure Relate_Transition (A, B : State)
     with Ghost => Static, Global => null,
     Pre => A = B and then A.Used > Max_Contacts and then B.Used > Max_Contacts
       and then A.Best <= A.Used and then B.Best <= B.Used
       and then A.Kept < Max_Contacts and then B.Kept < Max_Contacts,
     Post => Model.Transition (A) = Model.Transition (B);
   procedure Relate_Transition (A, B : State) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Transition);
   begin
      if A.Best = 0 then return; end if;
      Relate_Next (A, B, A.Used);
      for I in 1 .. A.Capacity loop
         Relate_Updated (A, B, I);
         pragma Loop_Invariant (for all J in 1 .. I => Updated (A, J) = Updated (B, J));
      end loop;
   end Relate_Transition;
   procedure Relate_Deepest (A, B : State; N : Vertex)
     with Ghost => Static, Global => null,
     Pre => A = B and then N <= A.Used and then N <= B.Used,
     Post => Model.Deepest (A, N) = Model.Deepest (B, N),
     Subprogram_Variant => (Decreases => N);
   procedure Relate_Deepest (A, B : State; N : Vertex) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Deepest);
      Previous : Vertex;
   begin
      if N = 1 then return; end if;
      Relate_Deepest (A, B, N - 1);
      Previous := Model.Deepest (A, N - 1);
      pragma Assert (A.Items (Previous).Separation = B.Items (Previous).Separation);
      pragma Assert (A.Items (N).Separation = B.Items (N).Separation);
   end Relate_Deepest;
   procedure Relate_Run (A, B : State; N : Rank)
     with Ghost => Static, Global => null,
     Pre => A = B and then A.Used > Max_Contacts and then B.Used > Max_Contacts
       and then A.Best <= A.Used and then B.Best <= B.Used
       and then A.Kept = 0 and then B.Kept = 0,
     Post => Model.Run (A, N) = Model.Run (B, N),
     Subprogram_Variant => (Decreases => N);
   procedure Relate_Run (A, B : State; N : Rank) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Run);
   begin
      if N = 0 then return; end if;
      Relate_Run (A, B, N - 1);
      Relate_Transition (Model.Run (A, N - 1), Model.Run (B, N - 1));
   end Relate_Run;
   procedure Relate_Filtered (A, B : State)
     with Ghost => Static, Global => null,
     Pre => A = B and then A.Kept = 0 and then B.Kept = 0,
     Post => Model.Filtered (A) = Model.Filtered (B);
   procedure Relate_Filtered (A, B : State) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Filtered);
   begin
      if A.Used <= Max_Contacts then return; end if;
      Relate_Deepest (A, B, A.Used);
      Relate_Run ((A with delta Best => Model.Deepest (A, A.Used)),
                  (B with delta Best => Model.Deepest (B, B.Used)), Max_Contacts);
   end Relate_Filtered;
   procedure Relate_Ranks (A, B : State; N : Rank)
     with Ghost => Static, Global => null,
     Pre => A = B and then Within (A, A.Capacity) and then Within (B, B.Capacity)
       and then N <= A.Capacity and then N <= B.Capacity,
     Post => Model.Ranks (A, N) = Model.Ranks (B, N),
     Subprogram_Variant => (Decreases => N);
   procedure Relate_Ranks (A, B : State; N : Rank) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Ranks);
   begin
      if N = 0 then return; end if;
      Relate_Ranks (A, B, N - 1);
      pragma Assert (A.Items (N).Id = B.Items (N).Id);
   end Relate_Ranks;
   procedure Collect (C : Configuration; P : Particle_Array; S : out State) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Contacts);
   begin
      S := (Capacity => P'Length, Items => [others => <>], Used => 0, Marked => [others => False], Minima => [others => 1.0e10], Best => 0, Kept => 0);
      for V in P'Range loop
         if Included (C, P (V).Position) then
            S.Used := S.Used + 1;
            S.Items (S.Used) := (V, Distance (C, P (V).Position), Contact_Point (C, P (V).Position));
         end if;
         pragma Loop_Invariant (Static => S = Model.Contacts (C, P, V));
      end loop;
   end Collect;
   function Deepest (S : State) return Vertex is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Deepest);
      B : Vertex := 1;
   begin
      for I in 2 .. S.Used loop
         if -S.Items (I).Separation > -S.Items (B).Separation then B := I; end if;
         pragma Loop_Invariant (Static => B = Model.Deepest (S, I));
      end loop;
      return B;
   end Deepest;
   procedure Scan (S : in out State; Next : out Count) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Next_Best);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Updated);
      Before : constant State := S with Ghost => Static;
      D2 : Squared_Distance;
      Best_Distance : Real range -1.0 .. 1.0e10 := -1.0;
   begin
      Next := 0;
      S.Marked (S.Best) := True;
      for I in 1 .. S.Used loop
         if not S.Marked (I) then
            Relate_Distance (S.Items (I).Position, Before.Items (I).Position,
              S.Items (S.Best).Position, Before.Items (Before.Best).Position);
            D2 := Distance2 (S.Items (I).Position, S.Items (S.Best).Position);
            if D2 < S.Minima (I) then S.Minima (I) := D2; end if;
            if S.Minima (I) > Best_Distance then
               Next := I; Best_Distance := S.Minima (I);
            end if;
         end if;
         pragma Assert (Static => S.Minima (I) = Updated (Before, I));
         pragma Loop_Invariant (Static => S.Items = Before.Items and then S.Used = Before.Used
           and then S.Best = Before.Best and then S.Kept = Before.Kept);
         pragma Loop_Invariant (Static => S.Marked = (Before.Marked with delta S.Best => True));
         pragma Loop_Invariant (Static => (for all J in 1 .. I => S.Minima (J) = Updated (Before, J)));
         pragma Loop_Invariant (Static => (for all J in I + 1 .. S.Capacity => S.Minima (J) = Before.Minima (J)));
         pragma Loop_Invariant (Static => Next = Model.Next_Best (Before, I));
         pragma Loop_Invariant (Static => Best_Distance = (if Next = 0 then -1.0 else Updated (Before, Next)));
      end loop;
   end Scan;
   procedure Advance (S : in out State) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Transition);
      Next : Count;
      Temp : Contact;
   begin
      if S.Best = 0 then return; end if;
      Scan (S, Next);
      if S.Kept < Max_Contacts - 1 then
         Temp := S.Items (S.Kept + 1);
         S.Items (S.Kept + 1) := S.Items (S.Best);
         S.Items (S.Best) := Temp;
         if Next = S.Kept + 1 then Next := S.Best; end if;
      end if;
      S.Kept := S.Kept + 1;
      S.Best := Next;
   end Advance;
   procedure Reduce (S : in out State) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Filtered);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Run);
   begin
      if S.Used <= Max_Contacts then S.Kept := S.Used; return; end if;
      S.Best := Deepest (S);
      declare
         Initial : constant State := S with Ghost => Static;
      begin
      for I in 1 .. Max_Contacts loop
         pragma Loop_Invariant (Static => S = Model.Run (Initial, I - 1));
         pragma Loop_Invariant (Static => (for all L in Vertex =>
           (if Within (Initial, L) then Within (S, L))));
         Relate_Transition (S, Model.Run (Initial, I - 1));
         Advance (S);
         pragma Assert (Static => S = Model.Transition (Model.Run (Initial, I - 1)));
         pragma Assert (Static => Model.Run (Initial, I) = Model.Transition (Model.Run (Initial, I - 1)));
         pragma Assert (Static => S = Model.Run (Initial, I));
      end loop;
      end;
   end Reduce;
   procedure Select_Contacts (C : Configuration; P : Particle_Array; R : out Rank_Array) is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Selection);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Ranks);
      S : State (P'Length);
      Expected : constant State := Model.Filtered (Model.Contacts (C, P, P'Length)) with Ghost => Static;
   begin
      Collect (C, P, S);
      pragma Assert (Static => Within (S, P'Last));
      Relate_Filtered (S, Model.Contacts (C, P, P'Length));
      Reduce (S);
      pragma Assert (Static => S = Expected);
      pragma Assert (Static => Within (S, P'Last));
      R := [others => 0];
      for I in 1 .. S.Kept loop
         R (S.Items (I).Id) := I;
         pragma Loop_Invariant (Static => R = Model.Ranks (S, I));
      end loop;
      Relate_Ranks (S, Expected, S.Kept);
   end Select_Contacts;
end MJ.Flex_Contact_Filter;

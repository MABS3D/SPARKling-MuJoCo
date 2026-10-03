with MJ.Sleep_Bytes;
package body MJ.Sleep_Manager with SPARK_Mode is
   use type K.Object_State;
   procedure Wake_Island (T : in out Tree_Array; Start : Integer; Value : K.Counter;
     Woke : out Natural; Status : out Result) is
      Current, Next : Integer;
   begin
      Woke := 0; Status := Invalid_Cycle;
      if Start not in T'Range then return; end if;
      if T (Start) < 0 then
         T (Start) := K.Wake_Value (T (Start), Value);
         Status := Success; return;
      end if;
      if Sleep_Cycle (T, Start) < 0 then return; end if;
      Status := Success; Current := Start;
      for Count in 1 .. T'Length loop
         pragma Loop_Invariant (Current in T'Range);
         pragma Loop_Invariant (Woke = Count-1);
         pragma Loop_Invariant (Static =>
           (for all J in T'Range =>
             (T (J) = T'Loop_Entry (J) or T (J) = Value)
             and then (if T'Loop_Entry (J) < 0 then T (J) = T'Loop_Entry (J))));
         Next := T (Current);
         --  The checked cycle must end at Start; guard also keeps invalid data
         --  from accessing any array if callers bypass static preconditions.
         if Next not in T'Range then exit; end if;
         T (Current) := Value; Woke := Woke + 1; Current := Next;
         exit when Current = Start;
      end loop;
   end Wake_Island;

   procedure Update (M : Topology; S : in out State; Static_Awake : Boolean := False) is
      B : Integer;
   begin
      S.Trees_Awake := 0; S.Bodies_Awake := 0; S.Parents_Awake := 0; S.Dofs_Awake := 0;
      for T in M.Trees'Range loop
         pragma Loop_Invariant (S.Trees_Awake <= T);
         pragma Loop_Invariant (Static =>
           (for all I in M.Trees'First .. T-1 =>
             S.Tree_Awake (I) = (S.Tree_Asleep (I) < 0)));
         S.Tree_Awake (T) := S.Tree_Asleep (T) < 0;
         if S.Tree_Awake (T) then S.Trees_Awake := S.Trees_Awake + 1; end if;
      end loop;
      for J in M.Bodies'Range loop
         pragma Loop_Invariant (S.Bodies_Awake <= J and S.Parents_Awake <= J);
         pragma Loop_Invariant (Static =>
           (for all I in M.Bodies'First .. J-1 =>
             S.Body_Awake (I) = K.Body_State (M.Bodies (I).Tree,
               (if M.Bodies (I).Tree >= 0 then S.Tree_Awake (M.Bodies (I).Tree) else False),
               M.Bodies (I).Mocap_Root, Static_Awake)));
         S.Body_Awake (J) := K.Body_State (M.Bodies (J).Tree,
           (if M.Bodies (J).Tree >= 0 then S.Tree_Awake (M.Bodies (J).Tree) else False),
           M.Bodies (J).Mocap_Root, Static_Awake);
         if S.Body_Awake (J) /= K.Asleep then
            S.Body_Index (S.Bodies_Awake) := J; S.Bodies_Awake := S.Bodies_Awake + 1;
         end if;
         if J > 0 and then S.Body_Awake (M.Bodies (J).Parent) /= K.Asleep then
            S.Parent_Index (S.Parents_Awake) := J; S.Parents_Awake := S.Parents_Awake + 1;
         end if;
      end loop;
      for V in M.Dof_Body'Range loop
         pragma Loop_Invariant (S.Dofs_Awake <= V);
         B := M.Dof_Body (V);
         if M.Bodies (B).Tree >= 0 and then S.Body_Awake (B) = K.Awake then
            S.Dof_Index (S.Dofs_Awake) := V; S.Dofs_Awake := S.Dofs_Awake + 1;
         end if;
      end loop;
   end Update;

   function Can_Sleep (M : Topology; Tree : Natural; Qvel, Applied, External : K.Samples;
     Tol : Nonneg_Tier0) return Boolean is
      T : Tree_Parameters renames M.Trees (Tree);
   begin
      if T.Sleep_Policy in 1 | 3 then return False; end if;
      for J in 6*T.Body_First .. 6*(T.Body_First+T.Bodies)-1 loop
         if not MJ.Sleep_Bytes.Positive_Zero (External (J)) then return False; end if;
      end loop;
      for V in T.Dof_First .. T.Dof_First+T.Dofs-1 loop
         if not MJ.Sleep_Bytes.Positive_Zero (Applied (V)) then return False; end if;
      end loop;
      if Tol = 0.0 then
         for V in T.Dof_First .. T.Dof_First+T.Dofs-1 loop
            if not MJ.Sleep_Bytes.Positive_Zero (Qvel (V)) then return False; end if;
         end loop;
         return True;
      end if;
      return K.Under_Tolerance
        (Qvel (T.Dof_First .. T.Dof_First+T.Dofs-1), M.Length (T.Dof_First .. T.Dof_First+T.Dofs-1), Tol);
   end Can_Sleep;

   procedure Wake_Perturbations (M : Topology; S : in out State; Enabled : Boolean;
     Pose_Changed : Flags; Qvel, Applied, External : K.Samples;
     Woke : out Natural; Status : out Result) is
      N : Natural; R : Result;
   begin
      Woke := 0; Status := Success;
      for T in Pose_Changed'Range loop
         if Pose_Changed (T) then S.Tree_Awake (T) := True; end if;
      end loop;
      if not Enabled then
         if S.Trees_Awake < M.Nt then S.Tree_Asleep := (others => K.Fully_Awake); end if;
         Woke := M.Nt - S.Trees_Awake; return;
      end if;
      for T in M.Trees'Range loop
         if S.Tree_Asleep (T) >= 0 and then
           (S.Tree_Awake (T) or Pose_Changed (T) or not Can_Sleep (M, T, Qvel, Applied, External, 0.0)) then
            Wake_Island (S.Tree_Asleep, T, K.Fully_Awake, N, R);
            if R /= Success then Status := R; return; end if;
            Woke := Woke + N;
         end if;
      end loop;
   end Wake_Perturbations;

   procedure Wake_Connections (M : Topology; S : in out State; Edges : Pairs;
     Equality, Enabled : Boolean; Woke : out Natural; Status : out Result) is
      A, B, Target : Integer; SA, SB : K.Object_State;
      N : Natural; R : Result; Value : K.Counter;
      procedure Wake (T : Integer; V : K.Counter) is
      begin
         Wake_Island (S.Tree_Asleep, T, V, N, R);
         if R /= Success then Status := R; else Woke := Woke + N; end if;
      end Wake;
   begin
      Woke := 0; Status := Success;
      if not Enabled then return; end if;
      for E of Edges loop
         A := (if E.A < 0 then -1 else M.Bodies (E.A).Tree);
         B := (if E.B < 0 then -1 else M.Bodies (E.B).Tree);
         SA := (if A >= 0 then (if S.Tree_Awake (A) then K.Awake else K.Asleep)
                elsif E.A >= 0 then S.Body_Awake (E.A) else K.Static_Body);
         SB := (if B >= 0 then (if S.Tree_Awake (B) then K.Awake else K.Asleep)
                elsif E.B >= 0 then S.Body_Awake (E.B) else K.Static_Body);
         if Equality then
            if (SA /= K.Asleep and SB /= K.Asleep) or SA = K.Static_Body or SB = K.Static_Body or A = B then
               null;
            elsif SA = K.Asleep and SB = K.Asleep then
               if Sleep_Cycle (S.Tree_Asleep, A) /= Sleep_Cycle (S.Tree_Asleep, B) then
                  Wake (A, K.Fully_Awake); if Status /= Success then return; end if;
                  Wake (B, K.Fully_Awake);
               end if;
            else
               Wake ((if SA = K.Asleep then A else B), K.Fully_Awake);
            end if;
         elsif A < 0 or B < 0 then
            Target := (if A < 0 then B else A);
            if Target >= 0 and then not S.Tree_Awake (Target)
              and then (if A < 0 then SA else SB) = K.Awake then Wake (Target, K.Fully_Awake); end if;
         elsif SA = K.Awake and SB = K.Awake then null;
         elsif SA = K.Asleep and SB = K.Asleep then
            Status := Invalid_Connection; return;
         else
            Target := (if SA = K.Awake then B else A);
            Value := S.Tree_Asleep ((if SA = K.Awake then A else B));
            if Value >= 0 then Status := Invalid_Connection; return; end if;
            Wake (Target, Value);
         end if;
         if Status /= Success then return; end if;
      end loop;
   end Wake_Connections;

   procedure Wake_Groups (S : in out State; Lists : Groups; Trees : Indices;
     Flex_Equality, Enabled : Boolean; Woke : out Natural; Status : out Result) is
      First_Awake : Integer; V : K.Counter; N : Natural; R : Result;
   begin
      Woke := 0; Status := Success;
      if not Enabled then return; end if;
      for G of Lists loop
         if G.Active and G.Size >= (if Flex_Equality then 1 else 2) then
            First_Awake := -1; V := -1;
            for J in G.First .. G.First + G.Size - 1 loop
               if S.Tree_Awake (Trees (J)) then
                  if S.Tree_Asleep (Trees (J)) >= 0 then Status := Invalid_Connection; return; end if;
                  if First_Awake < 0 then First_Awake := Trees (J); V := S.Tree_Asleep (First_Awake);
                  elsif not Flex_Equality then V := K.Wake_Value (V, S.Tree_Asleep (Trees (J))); end if;
                  exit when Flex_Equality;
               end if;
            end loop;
            if First_Awake >= 0 then
               for J in G.First .. G.First + G.Size - 1 loop
                  if (if Flex_Equality or G.Size = 2 then not S.Tree_Awake (Trees (J))
                      else S.Tree_Asleep (Trees (J)) >= 0) then
                     Wake_Island (S.Tree_Asleep, Trees (J), V, N, R);
                     if R /= Success then Status := R; return; end if;
                     Woke := Woke + N;
                     exit when Flex_Equality;
                  end if;
               end loop;
            end if;
         end if;
      end loop;
   end Wake_Groups;

   procedure Sleep (M : Topology; S : in out State; I : Islands;
     Enabled, Has_Constraints : Boolean; Tol : Nonneg_Tier0;
     Qvel, Qacc : in out K.Samples; Applied, External : K.Samples;
     Slept : out Natural; Status : out Result) is
      Start : Natural := 0; Ready : Boolean;
      procedure Sleep_Trees (List : Indices) is
         Current, Next : Integer; T : Tree_Parameters;
      begin
         for J in List'Range loop
            if S.Tree_Asleep (List (J)) /= -1 then Status := Invalid_Cycle; return; end if;
         end loop;
         for J in List'Range loop
            Current := List (J); Next := (if J = List'Last then List (List'First) else List (J+1));
            S.Tree_Asleep (Current) := Next; T := M.Trees (Current);
            for V in T.Dof_First .. T.Dof_First + T.Dofs - 1 loop Qvel (V) := 0.0; Qacc (V) := 0.0; end loop;
         end loop;
         Slept := Slept + List'Length;
      end Sleep_Trees;
   begin
      Slept := 0; Status := Success;
      if not Enabled or (Has_Constraints and I.Count = 0) then return; end if;
      for T in M.Trees'Range loop
         if S.Tree_Asleep (T) < 0 then
            S.Tree_Asleep (T) := K.Advance (S.Tree_Asleep (T), Can_Sleep (M, T, Qvel, Applied, External, Tol));
         end if;
      end loop;
      for J in I.First'Range loop
         Ready := True;
         for P in I.First (J) .. I.First (J) + I.Size (J)-1 loop
            if S.Tree_Asleep (I.Tree (P)) < -1 then Ready := False; exit;
            elsif S.Tree_Asleep (I.Tree (P)) >= 0 then Status := Invalid_Cycle; return; end if;
         end loop;
         if Ready then
            Sleep_Trees (I.Tree (I.First (J) .. I.First (J)+I.Size (J)-1));
            if Status /= Success then return; end if;
         end if;
         Start := I.First (J) + I.Size (J);
      end loop;
      for P in Start .. Integer (M.Nt)-1 loop
         declare T : constant Integer := (if I.Count = 0 then P else I.Tree (P)); begin
            if S.Tree_Asleep (T) = -1 then Sleep_Trees (Indices'(0 => T)); end if;
         end;
      end loop;
   end Sleep;
end MJ.Sleep_Manager;

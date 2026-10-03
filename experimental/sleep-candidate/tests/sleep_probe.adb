with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Sleep_Manager; use MJ.Sleep_Manager;
procedure Sleep_Probe is
   package F is new Ada.Text_IO.Float_IO (Real);
   function Int return Integer is X : Integer; begin Ada.Integer_Text_IO.Get (X); return X; end;
   function Float return Real is X : Real; begin F.Get (X); return X; end;
   Nt : constant Tree_Count := Int;
   Nb : constant Body_Count := Int;
   Nv : constant Dof_Count := Int;
   Nop : constant Natural := Int;
   M : Topology (Integer (Nt)-1, Integer (Nb)-1, Integer (Nv)-1);
   S : State (Integer (Nt)-1, Integer (Nb)-1, Integer (Nv)-1);
   Q, A, Applied : K.Samples (0 .. Integer (Nv)-1);
   External : K.Samples (0 .. 6*Integer (Nb)-1);
   R : Result; N : Natural; Code : Integer;
   procedure Dump is
   begin
      Put (" " & Integer'Image (Code)); Put (" " & Natural'Image (N));
      for X of S.Tree_Asleep loop Put (" " & Integer'Image (X)); end loop;
      Put (" " & Natural'Image (S.Trees_Awake)); Put (" " & Natural'Image (S.Bodies_Awake));
      Put (" " & Natural'Image (S.Parents_Awake)); Put (" " & Natural'Image (S.Dofs_Awake));
      for X of S.Tree_Awake loop Put (" " & Integer'Image (Boolean'Pos (X))); end loop;
      for X of S.Body_Awake loop Put (" " & Integer'Image (K.Object_State'Enum_Rep (X))); end loop;
      for I in 0 .. S.Bodies_Awake-1 loop Put (" " & Integer'Image (S.Body_Index (I))); end loop;
      for I in 0 .. S.Parents_Awake-1 loop Put (" " & Integer'Image (S.Parent_Index (I))); end loop;
      for I in 0 .. Integer (S.Dofs_Awake)-1 loop Put (" " & Integer'Image (S.Dof_Index (I))); end loop;
      for X of Q loop Put (" " & Real'Image (X)); end loop;
      for X of A loop Put (" " & Real'Image (X)); end loop;
      New_Line;
   end Dump;
begin
   for I in M.Trees'Range loop
      M.Trees (I).Body_First := Int; M.Trees (I).Bodies := Int;
      M.Trees (I).Dof_First := Int; M.Trees (I).Dofs := Int;
      M.Trees (I).Sleep_Policy := Int; S.Tree_Asleep (I) := Int;
   end loop;
   for I in M.Bodies'Range loop
      M.Bodies (I).Tree := Int; M.Bodies (I).Parent := Int; M.Bodies (I).Mocap_Root := Int /= 0;
   end loop;
   for I in M.Dof_Body'Range loop M.Dof_Body (I) := Int; M.Length (I) := Float; end loop;
   for I in Q'Range loop Q (I) := Float; A (I) := Float; Applied (I) := Float; end loop;
   for I in External'Range loop External (I) := Float; end loop;
   Update (M, S);
   for Op in 1 .. Nop loop
      declare Kind : constant Integer := Int; begin
         N := 0; Code := 0;
         case Kind is
            when 0 => declare I : constant Integer := Int; begin Code := Sleep_Cycle (S.Tree_Asleep, I); end;
            when 1 => declare I : constant Integer := Int; V : constant K.Counter := Int; begin
               Wake_Island (S.Tree_Asleep, I, V, N, R); Code := Result'Pos (R); end;
            when 2 => Update (M, S, Int /= 0);
            when 3 => declare Enabled : constant Boolean := Int /= 0; Changed : Flags (S.Tree_Awake'Range); begin
               for I in Changed'Range loop Changed (I) := Int /= 0; end loop;
               Wake_Perturbations (M, S, Enabled, Changed, Q, Applied, External, N, R); Code := Result'Pos (R); end;
            when 4 => declare Eq : constant Boolean := Int /= 0; Enabled : constant Boolean := Int /= 0;
               Count : constant Natural := Int; E : Pairs (0 .. Integer (Count)-1); begin
               for I in E'Range loop E (I).A := Int; E (I).B := Int; end loop;
               Wake_Connections (M, S, E, Eq, Enabled, N, R); Code := Result'Pos (R); end;
            when 5 => declare Flex : constant Boolean := Int /= 0; Enabled : constant Boolean := Int /= 0;
               Count : constant Natural := Int; Width : constant Natural := Int;
               G : Groups (0 .. Integer (Count)-1); T : Indices (0 .. Integer (Width)-1); begin
               for I in G'Range loop G (I).First := Int; G (I).Size := Int; G (I).Active := Int /= 0; end loop;
               for I in T'Range loop T (I) := Int; end loop;
               Wake_Groups (S, G, T, Flex, Enabled, N, R); Code := Result'Pos (R); end;
            when 6 => declare Enabled : constant Boolean := Int /= 0; Constraints : constant Boolean := Int /= 0;
               Tol : constant Nonneg_Tier0 := Float; Count : constant Tree_Count := Int; I : Islands (Integer (Nt)-1, Integer (Count)-1); begin
               for J in I.First'Range loop I.First (J) := Int; I.Size (J) := Int; end loop;
               for J in I.Tree'Range loop I.Tree (J) := Int; end loop;
               Sleep (M, S, I, Enabled, Constraints, Tol, Q, A, Applied, External, N, R); Code := Result'Pos (R); end;
            when others => raise Program_Error;
         end case;
         Dump;
      end;
   end loop;
end Sleep_Probe;

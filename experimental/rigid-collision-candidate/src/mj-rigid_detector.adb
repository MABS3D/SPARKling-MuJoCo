with MJ.Rigid_Math; use MJ.Rigid_Math;
with MJ.Rigid_Support; use MJ.Rigid_Support;
with MJ.Rigid_Narrowphase; use MJ.Rigid_Narrowphase;

package body MJ.Rigid_Detector with SPARK_Mode is
   use type Interfaces.Unsigned_32;
   function Geom_Count (S : Scene) return Count is (S.N);
   function Candidate_Count (S : Scene) return Natural is (S.Candidates);
   function Narrowphase_Count (S : Scene) return Natural is (S.Calls);
   function Initialized (S : Scene) return Boolean is (S.Ready);
   function Key (A, B : Natural) return Interfaces.Unsigned_32 is
     (Interfaces.Unsigned_32 (Natural'Min (A, B))*65536+Interfaces.Unsigned_32 (Natural'Max (A, B)))
     with Pre => A <= 65535 and B <= 65535,
       Post => Interfaces.Shift_Right (Key'Result, 16) = Interfaces.Unsigned_32 (Natural'Min (A, B))
         and (Key'Result and 65535) = Interfaces.Unsigned_32 (Natural'Max (A, B));

   function Ordered (Keys : Key_Array; N : Natural) return Boolean is
     (for all I in 0 .. N-1 => (for all J in I+1 .. N-1 => Keys (I) <= Keys (J)))
     with Ghost, Pre => N <= Max_Pairs;
   function Present (Keys : Key_Array; N : Natural; V : Interfaces.Unsigned_32) return Boolean is
     (for some I in 0 .. N-1 => Keys (I) = V) with Ghost, Pre => N <= Max_Pairs;

   procedure Sort_Keys (Keys : in out Key_Array; N : Natural) is
      V : Interfaces.Unsigned_32;
      J : Natural;
   begin
      if N < 2 then return; end if;
      for I in 1 .. N-1 loop
         V := Keys (I); J := I;
         while J > 0 and then Keys (J-1) > V loop Keys (J) := Keys (J-1); J := J-1; end loop;
         Keys (J) := V;
      end loop;
   end Sort_Keys;

   function Contains (Keys : Key_Array; N : Natural; V : Interfaces.Unsigned_32) return Boolean
     with Pre => N <= Max_Pairs and then Ordered (Keys, N),
       Post => Contains'Result = Present (Keys, N, V)
   is
      Lo : Natural := 0;
      Hi : Natural := N;
      Mid : Natural;
   begin
      while Lo < Hi loop
         pragma Loop_Invariant (Lo <= Hi and Hi <= N);
         pragma Loop_Invariant (for all I in 0 .. Lo-1 => Keys (I) < V);
         pragma Loop_Invariant (for all I in Hi .. N-1 => Keys (I) >= V);
         pragma Loop_Variant (Decreases => Hi-Lo);
         Mid := Lo+(Hi-Lo)/2;
         if Keys (Mid) < V then Lo := Mid+1; else Hi := Mid; end if;
      end loop;
      return Lo < N and then Keys (Lo) = V;
   end Contains;

   procedure Initialize
     (S : in out Scene; Geoms : Shape_Array; Explicit_Pairs : Explicit_Array;
      Exclusions : Exclusion_Array; O : Options; Result : out Status;
      Margin_Override : Real := -1.0)
   is
      type Body_Map is array (Natural range 0 .. 65535) of Count;
      Group_Map : Body_Map := [others => Max_Geoms];
      Group : Geom_Id;
   begin
      S.NG := 0;
      S.Ready := False; S.Have_Order := False; S.N := 0; S.E := 0; S.X := 0; Result := Invalid_Input;
      if Margin_Override /= -1.0 and then Margin_Override not in 0.0 .. 1.0e10 then return; end if;
      if Geoms'Length > Max_Geoms or Explicit_Pairs'Length > Max_Pairs or Exclusions'Length > Max_Pairs then
         Result := Capacity_Limit; return;
      end if;
      for G of Geoms loop if not Valid_Shape (G) then return; end if; end loop;
      for P of Explicit_Pairs loop
         if P.Geoms.First >= Geoms'Length or P.Geoms.Second >= Geoms'Length or P.Geoms.First = P.Geoms.Second then return; end if;
      end loop;
      for I in 0 .. Geoms'Length-1 loop
         S.Shapes (I) := Geoms (Geoms'First+I); S.Rbound (I) := Radius (S.Shapes (I)); S.Known_Rotation (I) := False;
         if Group_Map (S.Shapes (I).Body_Id) = Max_Geoms then
            Group := S.NG; S.NG := S.NG+1;
            Group_Map (S.Shapes (I).Body_Id) := Group; S.Groups (Group) := S.Shapes (I);
         else
            Group := Group_Map (S.Shapes (I).Body_Id);
            if S.Groups (Group).Weld /= S.Shapes (I).Weld
              or S.Groups (Group).Weld_Parent /= S.Shapes (I).Weld_Parent
              or S.Groups (Group).Dynamic /= S.Shapes (I).Dynamic then return; end if;
            S.Groups (Group).Contype := S.Groups (Group).Contype or S.Shapes (I).Contype;
            S.Groups (Group).Conaffinity := S.Groups (Group).Conaffinity or S.Shapes (I).Conaffinity;
         end if;
         S.Group_Of (I) := Group;
      end loop;
      S.N := Geoms'Length; S.Config := O; S.Override_Margin := Margin_Override;
      for P of Explicit_Pairs loop
         S.Explicit_Pairs (S.E) := P;
         S.Explicit_Keys (S.E) := Key (P.Geoms.First, P.Geoms.Second); S.E := S.E+1;
      end loop;
      Sort_Keys (S.Explicit_Keys, S.E);
      for I in 1 .. S.E-1 loop
         if S.Explicit_Keys (I) = S.Explicit_Keys (I-1) then return; end if;
      end loop;
      for P of Exclusions loop
         S.Excluded (S.X) := Key (P.First, P.Second); S.X := S.X+1;
      end loop;
      Sort_Keys (S.Excluded, S.X); S.Ready := True; Result := Success;
   end Initialize;

   function Less (A, B : Endpoint) return Boolean is
     (A.Value < B.Value or else (A.Value = B.Value and then A.Tag mod 2 = 0 and then B.Tag mod 2 = 1));

   procedure Sort_Endpoints (S : in out Scene; N : Endpoint_Count) is
      Width : Positive := 1;
      Start, Mid, Last, I, J, K : Natural;
      Swaps : Natural := 0;
      V : Endpoint;
   begin
      --  Retain the prior frame's endpoint order. Bounded insertion repair is
      --  linear for coherent motion; a merge fallback caps adversarial work.
      for I in 1 .. N-1 loop
         V := S.Sorted (I); J := I;
         while J > 0 and then Less (V, S.Sorted (J-1)) loop
            S.Sorted (J) := S.Sorted (J-1); J := J-1; Swaps := Swaps+1;
         end loop;
         S.Sorted (J) := V;
         if Swaps > 4*N then exit; end if;
         if I = N-1 then return; end if;
      end loop;
      while Width < N loop
         Start := 0;
         while Start < N loop
            Mid := Natural'Min (N, Start+Width); Last := Natural'Min (N, Mid+Width);
            I := Start; J := Mid; K := Start;
            while I < Mid and J < Last loop
               if Less (S.Sorted (J), S.Sorted (I)) then S.Merge (K) := S.Sorted (J); J := J+1;
               else S.Merge (K) := S.Sorted (I); I := I+1; end if;
               K := K+1;
            end loop;
            while I < Mid loop S.Merge (K) := S.Sorted (I); I := I+1; K := K+1; end loop;
            while J < Last loop S.Merge (K) := S.Sorted (J); J := J+1; K := K+1; end loop;
            Start := Last;
         end loop;
         for I in 0 .. N-1 loop S.Sorted (I) := S.Merge (I); end loop;
         Width := Width*2;
      end loop;
   end Sort_Endpoints;

   procedure Append_Pair (A, B : Geom_Id; Margin : Real;
                          Explicit_Index : Natural; With_Metadata : Boolean;
                          Hits : in out Pair_List; Details : in out Metadata_Array)
     with Pre => A /= B and Hits.Length < Max_Pairs
       and Margin in 0.0 .. 4.0e10 and Explicit_Index <= Max_Pairs
       and Details'First = 0 and Details'Last = Max_Pairs-1,
       Post => Hits.Length = Hits.Length'Old+1
         and then Hits.Items (Hits.Length'Old) = Canonical (A, B)
         and then (for all I in 0 .. Hits.Length'Old-1 => Hits.Items (I) = Hits.Items'Old (I))
         and then (if With_Metadata then Details (Hits.Length'Old)'Initialized
           and then Details (Hits.Length'Old).Detection_Margin = Margin
           and then Details (Hits.Length'Old).Explicit_Index = Explicit_Index)
   is
   begin
      Hits.Items (Hits.Length) := Canonical (A, B);
      if With_Metadata then Details (Hits.Length) := (Margin, Explicit_Index); end if;
      Hits.Length := Hits.Length+1;
   end Append_Pair;

   procedure Traverse (S : in out Scene; Poses : Pose_Array;
                       Hits : in out Pair_List; Details : in out Metadata_Array;
                       With_Narrowphase : Boolean; Result : out Status)
     with Pre => Details'First = 0 and Details'Last = Max_Pairs-1,
       Post => (if not With_Narrowphase then Narrowphase_Count (S) = 0)
         and then (if Result /= Success then Hits.Length = 0)
         and then (if not With_Narrowphase and Result = Success then
           (for all P of Poses => Valid_Pose (P)))
         and then (for all I in 0 .. Hits.Length-1 =>
           Hits.Items (I).First < Hits.Items (I).Second
           and then Hits.Items (I).Second < Geom_Count (S)
           and then (if not With_Narrowphase then Details (I)'Initialized))
   is
      Min_C, Max_C : Vec := Zero;
      A_X, A_Y, A_Z : Axis := 0;
      NE : Endpoint_Count := 0;
      NA : Count := 0;
      Id, Other, Position : Geom_Id;
      Reuse_Order, Grouped, Diagonal : Boolean;
      Projection_Id : Natural range 0 .. 3;
      NGA : Count := 0;
      Group, Other_Group : Geom_Id;
      Cursor, Previous, Following : Count;
      Filter_Options : Options;
      Awake : constant Pose := (others => <>);
      Broad_Shape : Shape;

      procedure Try_Pair (A, B : Geom_Id; Explicit_Index : Natural; M : Real) is
         PA : constant Pose := Poses (Poses'First+A);
         PB : constant Pose := Poses (Poses'First+B);
         Margin : Real := M;
         D : Vec;
         R : Real;
         Test_Result : Decision;
      begin
         if Result /= Success then return; end if;
         S.Candidates := S.Candidates+1;
         if Explicit_Index = 0 then
            if not Compatible (S.Shapes (A), S.Shapes (B))
              or else not Body_Allowed (S.Shapes (A), S.Shapes (B), PA, PB, S.Config)
              or else Contains (S.Excluded, S.X, Key (S.Shapes (A).Body_Id, S.Shapes (B).Body_Id))
              or else Contains (S.Explicit_Keys, S.E, Key (A, B)) then return;
            end if;
            Margin := (if S.Override_Margin >= 0.0 then S.Override_Margin
                       else S.Shapes (A).Margin+S.Shapes (B).Margin)
              +(S.Shapes (A).Gap+S.Shapes (B).Gap);
         elsif S.Config.Sleep_Filter and then PA.Asleep and then PB.Asleep then return;
         end if;
         if S.Shapes (A).Kind /= Plane and S.Shapes (B).Kind /= Plane then
            D := Sub (PA.Position, PB.Position); R := (S.Rbound (A)+S.Rbound (B))+Margin;
            if Dot (D, D) > R*R then return; end if;
         end if;
         Test_Result := Contact;
         if With_Narrowphase then
            S.Calls := S.Calls+1;
            Test_Result := Test (S.Shapes (A), S.Shapes (B), PA, PB, Margin, S.Config);
            if Test_Result = Unresolved then Result := Iteration_Limit; return; end if;
         end if;
         if Test_Result = Contact then
            if Hits.Length = Max_Pairs then Result := Capacity_Limit; return; end if;
            Append_Pair (A, B, Margin, Explicit_Index, not With_Narrowphase, Hits, Details);
         end if;
      end Try_Pair;
   begin
      Hits.Length := 0; S.Candidates := 0; S.Calls := 0; Result := Invalid_Input;
      if not S.Ready or Poses'Length /= S.N then return; end if;
      for I in 0 .. S.N-1 loop
         if (for some X of Poses (Poses'First+I).Position => X not in Coordinate) then return; end if;
         if (S.Shapes (I).Kind /= Sphere or else not With_Narrowphase) and then
           (not S.Known_Rotation (I) or else S.Last_Rotation (I) /= Poses (Poses'First+I).Rotation) then
            if not Valid_Pose (Poses (Poses'First+I)) then return; end if;
            S.Last_Rotation (I) := Poses (Poses'First+I).Rotation; S.Known_Rotation (I) := True;
         end if;
      end loop;
      Result := Success;
      if not S.Config.Enabled then return; end if;
      if S.N = 0 then return; end if;
      Min_C := Poses (Poses'First).Position; Max_C := Min_C;
      for I in 0 .. S.N-1 loop
         for K in Axis loop
            Min_C (K) := Real'Min (Min_C (K), Poses (Poses'First+I).Position (K));
            Max_C (K) := Real'Max (Max_C (K), Poses (Poses'First+I).Position (K));
         end loop;
      end loop;
      for K in Axis loop
         if Max_C (K)-Min_C (K) > Max_C (A_X)-Min_C (A_X) then A_X := K; end if;
      end loop;
      A_Y := (if A_X = 0 then 1 else 0); A_Z := (if A_X = 2 then 1 else 2);
      --  C uses covariance-frame sweep axes. In a nearly isotropic 3D
      --  distribution, a diagonal avoids large sets of tied axis projections.
      Diagonal := Max_C (A_X)-Min_C (A_X) <= 1.25*Real'Min (Max_C (0)-Min_C (0),
          Real'Min (Max_C (1)-Min_C (1), Max_C (2)-Min_C (2)))
        and then Max_C (A_X) > Min_C (A_X);
      Projection_Id := (if Diagonal then 3 else A_X);
      Reuse_Order := S.Have_Order and S.Axis_Used = Projection_Id;
      for I in 0 .. S.N-1 loop
         if S.Shapes (I).Kind /= Plane then
            Broad_Shape := S.Shapes (I);
            if S.Override_Margin >= 0.0 then
               --  Conservative per-geom padding, including the smallest
               --  subnormal margins (halving those can round down to zero).
               Broad_Shape.Margin := S.Override_Margin;
            end if;
            Bounds (Broad_Shape, Poses (Poses'First+I), S.Lo (I), S.Hi (I));
            if (for some X of S.Lo (I) => X not in -1.0e12 .. 1.0e12)
              or else (for some X of S.Hi (I) => X not in -1.0e12 .. 1.0e12) then Result := Numeric_Limit; return; end if;
            if Diagonal then Projection_Bounds (Broad_Shape, Poses (Poses'First+I), S.Projection_Lo (I), S.Projection_Hi (I));
            else S.Projection_Lo (I) := S.Lo (I) (A_X); S.Projection_Hi (I) := S.Hi (I) (A_X); end if;
            if not Reuse_Order then
               S.Sorted (NE) := (Float (S.Projection_Lo (I)), 2*I);
               S.Sorted (NE+1) := (Float (S.Projection_Hi (I)), 2*I+1);
            end if;
            NE := NE+2;
         end if;
      end loop;
      if Reuse_Order then
         for E in 0 .. NE-1 loop
            Id := S.Sorted (E).Tag/2;
            S.Sorted (E).Value := Float ((if S.Sorted (E).Tag mod 2 = 1 then S.Projection_Hi (Id) else S.Projection_Lo (Id)));
         end loop;
      end if;
      Sort_Endpoints (S, NE); S.Have_Order := True; S.Axis_Used := Projection_Id;
      for E in 0 .. S.E-1 loop
         Try_Pair (S.Explicit_Pairs (E).Geoms.First, S.Explicit_Pairs (E).Geoms.Second, E+1, S.Explicit_Pairs (E).Margin);
      end loop;
      for I in 0 .. S.N-1 loop
         if S.Shapes (I).Kind = Plane then
            for J in 0 .. S.N-1 loop
               if S.Shapes (J).Kind /= Plane then Try_Pair (I, J, 0, 0.0); end if;
            end loop;
         end if;
      end loop;
      Grouped := S.NG < S.N/4;
      Filter_Options := S.Config; Filter_Options.Sleep_Filter := False;
      if Grouped then for G in 0 .. S.NG-1 loop S.Group_Head (G) := Max_Geoms; end loop; end if;
      for E in 0 .. NE-1 loop
         Id := S.Sorted (E).Tag/2;
         if S.Sorted (E).Tag mod 2 = 0 then
            if Grouped then
               Group := S.Group_Of (Id);
               for J in 0 .. NGA-1 loop
                  Other_Group := S.Active_Groups (J);
                  if Compatible (S.Groups (Group), S.Groups (Other_Group))
                    and then Body_Allowed (S.Groups (Group), S.Groups (Other_Group), Awake, Awake, Filter_Options)
                    and then not Contains (S.Excluded, S.X, Key (S.Groups (Group).Body_Id, S.Groups (Other_Group).Body_Id))
                  then
                     Cursor := S.Group_Head (Other_Group);
                     while Cursor < Max_Geoms loop
                        Other := Cursor;
                        if S.Lo (Other) (A_Y) <= S.Hi (Id) (A_Y) and S.Lo (Id) (A_Y) <= S.Hi (Other) (A_Y)
                          and S.Lo (Other) (A_Z) <= S.Hi (Id) (A_Z) and S.Lo (Id) (A_Z) <= S.Hi (Other) (A_Z)
                        then Try_Pair (Other, Id, 0, 0.0); end if;
                        Cursor := S.Next_Id (Other);
                     end loop;
                  end if;
               end loop;
               Cursor := S.Group_Head (Group);
               if Cursor = Max_Geoms then
                  S.Active_Groups (NGA) := Group; S.Active_Group_Position (Group) := NGA; NGA := NGA+1;
               else S.Previous_Id (Cursor) := Id; end if;
               S.Next_Id (Id) := Cursor; S.Previous_Id (Id) := Max_Geoms; S.Group_Head (Group) := Id;
            else
               for J in 0 .. NA-1 loop
                  Other := S.Active (J);
                  if S.Lo (Other) (A_Y) <= S.Hi (Id) (A_Y) and S.Lo (Id) (A_Y) <= S.Hi (Other) (A_Y)
                    and S.Lo (Other) (A_Z) <= S.Hi (Id) (A_Z) and S.Lo (Id) (A_Z) <= S.Hi (Other) (A_Z)
                  then Try_Pair (Other, Id, 0, 0.0); end if;
               end loop;
            end if;
            S.Active (NA) := Id; S.Active_Position (Id) := NA; NA := NA+1;
         else
            if Grouped then
               Group := S.Group_Of (Id); Previous := S.Previous_Id (Id); Following := S.Next_Id (Id);
               if Previous = Max_Geoms then S.Group_Head (Group) := Following; else S.Next_Id (Previous) := Following; end if;
               if Following < Max_Geoms then S.Previous_Id (Following) := Previous; end if;
               if S.Group_Head (Group) = Max_Geoms then
                  Position := S.Active_Group_Position (Group); NGA := NGA-1;
                  S.Active_Groups (Position) := S.Active_Groups (NGA);
                  S.Active_Group_Position (S.Active_Groups (Position)) := Position;
               end if;
            end if;
            Position := S.Active_Position (Id); NA := NA-1;
            S.Active (Position) := S.Active (NA); S.Active_Position (S.Active (Position)) := Position;
         end if;
      end loop;
      if Result /= Success then Hits.Length := 0; end if;
   end Traverse;

   procedure Detect (S : in out Scene; Poses : Pose_Array;
                     Hits : in out Pair_List; Result : out Status) is
      Unused : Metadata_Array (0 .. Max_Pairs-1);
   begin
      Traverse (S, Poses, Hits, Unused, True, Result);
   end Detect;

   procedure Find_Candidates (S : in out Scene; Poses : Pose_Array;
                             Hits : in out Candidate_List; Result : out Status) is
   begin
      Traverse (S, Poses, Hits.Pairs, Hits.Metadata, False, Result);
   end Find_Candidates;
end MJ.Rigid_Detector;

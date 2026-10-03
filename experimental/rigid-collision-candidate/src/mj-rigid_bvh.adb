package body MJ.Rigid_BVH with SPARK_Mode is
   procedure Merge_Bounds
     (ALo, AHi, BLo, BHi : Vec; Lo, Hi : out Vec) is
   begin
      Lo := [for K in Axis => Real'Min (ALo (K), BLo (K))];
      Hi := [for K in Axis => Real'Max (AHi (K), BHi (K))];
   end Merge_Bounds;

   procedure Append_Id (Items : in out Id_Array; N : in out Count; Id : Geom_Id) is
   begin
      Items (N) := Id; N := N + 1;
   end Append_Id;

   function Available (C : Cache; Group : Geom_Id) return Boolean is
     (C.Ready and then Group < C.NG and then C.Roots (Group) < C.Length
      and then not C.Uniform (Group));
   function Selected_Count (C : Cache) return Count is (C.Hits);
   function Selected_Id (C : Cache; I : Geom_Id) return Geom_Id is (C.Items (I));
   function Node_Tests (C : Cache) return Natural is (C.Visited);
   function Leaf_Tests (C : Cache) return Natural is (C.Leaves);
   function Selection_Matches
     (C : Cache; Group : Geom_Id; Lo, Hi : Vec; Y, Z : Axis;
      Active : Boolean_Array; Rank : Rank_Array) return Boolean is
     (C.Hits <= C.Sizes (Group)
      and then (for all I in 0 .. C.Hits - 1 =>
        Active (C.Items (I))
        and then C.Leaf_Node (C.Items (I)) < C.Length
        and then Overlaps (Lo, Hi, C.Nodes (C.Leaf_Node (C.Items (I))).Lo,
                          C.Nodes (C.Leaf_Node (C.Items (I))).Hi, Y, Z)
        and then (for some J in 0 .. C.Sizes (Group) - 1 =>
          C.Order (C.Starts (Group) + J) = C.Items (I))
        and then (if I > 0 then Rank (C.Items (I - 1)) >= Rank (C.Items (I))))
      and then (for all J in 0 .. C.Sizes (Group) - 1 =>
        C.Leaf_Node (C.Order (C.Starts (Group) + J)) < C.Length
        and then ((Active (C.Order (C.Starts (Group) + J))
          and then Overlaps (Lo, Hi,
            C.Nodes (C.Leaf_Node (C.Order (C.Starts (Group) + J))).Lo,
            C.Nodes (C.Leaf_Node (C.Order (C.Starts (Group) + J))).Hi, Y, Z)) =
          (for some I in 0 .. C.Hits - 1 => C.Items (I) = C.Order (C.Starts (Group) + J)))));
   procedure Reset_Statistics (C : in out Cache) is
   begin
      C.Visited := 0; C.Leaves := 0; C.Hits := 0;
   end Reset_Statistics;

   procedure Configure (C : in out Cache; Groups : Id_Array;
                        Shapes : Shape_Array; Group_Count : Count) is
      Next : Count_Array := [others => 0];
      Total : Count := 0;
      G : Geom_Id;
   begin
      C.Ready := False; C.Length := 0; C.N := Shapes'Length; C.NG := Group_Count;
      Reset_Statistics (C);
      for I in 0 .. C.N - 1 loop C.Leaf_Node (I) := Max_Nodes; end loop;
      for I in 0 .. Group_Count - 1 loop C.Sizes (I) := 0; C.Roots (I) := Max_Nodes; end loop;
      for I in Shapes'Range loop
         if Shapes (I).Kind /= Plane then
            G := Groups (I); C.Sizes (G) := C.Sizes (G) + 1;
         end if;
      end loop;
      for I in 0 .. Group_Count - 1 loop
         C.Starts (I) := Total; Next (I) := Total;
         if C.Sizes (I) >= Min_Leaves then Total := Total + C.Sizes (I); end if;
      end loop;
      for I in Shapes'Range loop
         G := Groups (I);
         if Shapes (I).Kind /= Plane and then C.Sizes (G) >= Min_Leaves then
            C.Order (Next (G)) := I; Next (G) := Next (G) + 1;
         end if;
      end loop;
   end Configure;

   procedure Build_Group (C : in out Cache; G : Geom_Id; Lo, Hi : Vec_Array) is
      Base : constant Natural := C.Length;
      Last_Node : constant Natural := Base + 2 * C.Sizes (G) - 2;
      I, J, Mid, Position, V : Natural;
      K : Axis;
      L, H, Next_L, Next_H : Vec;
      Id : Geom_Id;
   begin
      C.Roots (G) := Base;
      C.Nodes (Base).First := C.Starts (G);
      C.Nodes (Base).Last := C.Starts (G) + C.Sizes (G) - 1;
      for N in Base .. Last_Node loop
         I := C.Nodes (N).First; J := C.Nodes (N).Last;
         if I = J then
            Id := C.Order (I); C.Nodes (N).Id := Id;
            C.Leaf_Node (Id) := N;
         else
            Id := C.Order (I); L := Lo (Id); H := Hi (Id);
            for P in I + 1 .. J loop
               Merge_Bounds (L, H, Lo (C.Order (P)), Hi (C.Order (P)), Next_L, Next_H);
               L := Next_L; H := Next_H;
            end loop;
            K := 0;
            for A in Axis loop
               if H (A) - L (A) > H (K) - L (K) then K := A; end if;
            end loop;
            --  Sorting only at construction; refits preserve the partition.
            --  Compare the endpoint sum: no center/half conversion or scan.
            for P in I + 1 .. J loop
               Id := C.Order (P); Position := P;
               while Position > I and then
                 Lo (C.Order (Position - 1)) (K) + Hi (C.Order (Position - 1)) (K) > Lo (Id) (K) + Hi (Id) (K)
               loop
                  C.Order (Position) := C.Order (Position - 1); Position := Position - 1;
               end loop;
               C.Order (Position) := Id;
            end loop;
            Mid := I + (J - I) / 2; V := N + 2 * (Mid - I + 1);
            C.Nodes (N).Id := Max_Geoms;
            C.Nodes (N).Left := N + 1; C.Nodes (N).Right := V;
            C.Nodes (N + 1).First := I; C.Nodes (N + 1).Last := Mid;
            C.Nodes (V).First := Mid + 1; C.Nodes (V).Last := J;
         end if;
      end loop;
      C.Length := Last_Node + 1;
   end Build_Group;

   procedure Update (C : in out Cache; Lo, Hi : Vec_Array; Groups : Id_Array) is
      L, H : Vec;
      G, First : Geom_Id;
   begin
      if not C.Ready then
         for G in 0 .. C.NG - 1 loop
            if C.Sizes (G) >= Min_Leaves then Build_Group (C, G, Lo, Hi); end if;
         end loop;
         C.Ready := True;
      end if;
      for I in 0 .. C.NG - 1 loop C.Uniform (I) := True; end loop;
      for I in reverse 0 .. C.Length - 1 loop
         if C.Nodes (I).Id < Max_Geoms then
            C.Nodes (I).Lo := Lo (C.Nodes (I).Id); C.Nodes (I).Hi := Hi (C.Nodes (I).Id);
            G := Groups (C.Nodes (I).Id); First := C.Order (C.Starts (G));
            if C.Uniform (G) and then
              (Lo (C.Nodes (I).Id) /= Lo (First) or else Hi (C.Nodes (I).Id) /= Hi (First))
            then C.Uniform (G) := False; end if;
         else
            Merge_Bounds
              (C.Nodes (C.Nodes (I).Left).Lo, C.Nodes (C.Nodes (I).Left).Hi,
               C.Nodes (C.Nodes (I).Right).Lo, C.Nodes (C.Nodes (I).Right).Hi, L, H);
            C.Nodes (I).Lo := L; C.Nodes (I).Hi := H;
         end if;
      end loop;
   end Update;

   procedure Sort_Selected (C : in out Cache; Rank : Rank_Array) is
      Width : Positive := 1;
      Start, Mid, Last, I, J, K : Natural;
   begin
      --  The original body's active list is newest-first. Keep precisely that
      --  sweep order, including ties resolved by its existing endpoint sort.
      while Width < C.Hits loop
         Start := 0;
         while Start < C.Hits loop
            Mid := Natural'Min (C.Hits, Start + Width);
            Last := Natural'Min (C.Hits, Mid + Width); I := Start; J := Mid; K := Start;
            while I < Mid and then J < Last loop
               if Rank (C.Items (I)) >= Rank (C.Items (J)) then
                  C.Scratch (K) := C.Items (I); I := I + 1;
               else C.Scratch (K) := C.Items (J); J := J + 1; end if;
               K := K + 1;
            end loop;
            while I < Mid loop C.Scratch (K) := C.Items (I); I := I + 1; K := K + 1; end loop;
            while J < Last loop C.Scratch (K) := C.Items (J); J := J + 1; K := K + 1; end loop;
            Start := Last;
         end loop;
         for I in 0 .. C.Hits - 1 loop C.Items (I) := C.Scratch (I); end loop;
         Width := Width * 2;
      end loop;
   end Sort_Selected;

   procedure Query (C : in out Cache; Group : Geom_Id; Lo, Hi : Vec;
                    Y, Z : Axis; Active : Boolean_Array; Rank : Rank_Array) is
      Top : Natural := 1;
      N : Node_Id;
      Id : Geom_Id;
   begin
      C.Hits := 0; C.Stack (0) := C.Roots (Group);
      while Top > 0 loop
         Top := Top - 1; N := C.Stack (Top); C.Visited := C.Visited + 1;
         if Overlaps (Lo, Hi, C.Nodes (N).Lo, C.Nodes (N).Hi, Y, Z) then
            if C.Nodes (N).Id < Max_Geoms then
               Id := C.Nodes (N).Id; C.Leaves := C.Leaves + 1;
               if Active (Id) then Append_Id (C.Items, C.Hits, Id); end if;
            else
               C.Stack (Top) := C.Nodes (N).Right;
               C.Stack (Top + 1) := C.Nodes (N).Left; Top := Top + 2;
            end if;
         end if;
      end loop;
      Sort_Selected (C, Rank);
   end Query;
end MJ.Rigid_BVH;

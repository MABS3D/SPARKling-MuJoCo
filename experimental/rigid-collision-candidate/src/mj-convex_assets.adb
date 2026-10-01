with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.Convex_Assets with SPARK_Mode is
   function Valid_Graph (S : Object; G : Graph_Array) return Boolean is
      N, Edge_Start, Start, Last, Neighbour : Natural;
      Terminated : Boolean;
   begin
      if S.Graph_Length = 0 then return True; end if;
      if not Graph_Header (S, G) then return False; end if;
      N := Natural (G (S.First_Graph));
      Edge_Start := S.First_Graph+2+2*N; Last := S.First_Graph+(S.Graph_Length-1);
      if S.Packed_Graph and then (S.Length > Graph_Index_Base or N > Graph_Index_Base) then return False; end if;
      for K in 0 .. N-1 loop
         Start := Edge_Start+G (S.First_Graph+2+K); Terminated := False;
         if S.Packed_Degrees and then Local_Id (G (S.First_Graph+2+N+K)) /= Find_End (G, Start, Last) then return False; end if;
         for J in Start .. Last loop
            if G (J) < 0 then Terminated := True; exit; end if;
            if S.Packed_Graph then
               Neighbour := Local_Id (G (J));
               if Neighbour >= N then return False; end if;
               pragma Assert (G (S.First_Graph+2+N+Neighbour) >= 0);
               if Global_Id (G (J)) /=
                 (if S.Packed_Degrees then Global_Id (G (S.First_Graph+2+N+Neighbour)) else G (S.First_Graph+2+N+Neighbour)) then return False; end if;
            elsif G (J) >= N then return False; end if;
         end loop;
         if not Terminated then return False; end if;
      end loop;
      return True;
   end Valid_Graph;
   function Seed_Coordinate (X : Real) return Natural is
     (1 + Boolean'Pos (X > 0.4) - Boolean'Pos (X < -0.4));
   function Encode_Neighbour (Local_Id, Global_Id : Natural) return Natural is
     (Local_Id*Graph_Index_Base+Global_Id);
   procedure Compile_Graph (S : in out Object; G : in out Graph_Array) is
      N, First_Edge, Last : Natural;
   begin
      if S.Graph_Length = 0 or S.Length > Graph_Index_Base then return; end if;
      N := G (S.First_Graph);
      if N > Graph_Index_Base then return; end if;
      First_Edge := S.First_Graph+2+2*N; Last := S.First_Graph+(S.Graph_Length-1);
      for J in First_Edge .. Last loop
         pragma Loop_Invariant (G (S.First_Graph) = N);
         pragma Loop_Invariant (for all V in 0 .. N-1 =>
           G (S.First_Graph+2+N+V) = G'Loop_Entry (S.First_Graph+2+N+V)
           and then G (S.First_Graph+2+N+V) in 0 .. S.Length-1);
         pragma Loop_Invariant (for all K in G'Range =>
           (if K in First_Edge .. J-1 and then G'Loop_Entry (K) in 0 .. N-1
            then G (K) = Encode_Neighbour (G'Loop_Entry (K), G'Loop_Entry (S.First_Graph+2+N+G'Loop_Entry (K)))
            else G (K) = G'Loop_Entry (K)));
         if G (J) in 0 .. N-1 then
            G (J) := Encode_Neighbour (G (J), G (S.First_Graph+2+N+G (J)));
         end if;
      end loop;
      S.Packed_Graph := True;
   end Compile_Graph;
   function Find_End (G : Graph_Array; First, Last : Natural) return Integer is
   begin
      for K in First .. Last loop
         pragma Loop_Invariant (for all J in First .. K-1 => G (J) >= 0);
         if G (K) < 0 then return K-First; end if;
      end loop;
      return -1;
   end Find_End;
   function Encode_Parts (High, Low : Natural) return Natural is
     (High*Graph_Index_Base+Low);
   procedure Compile_Degrees (S : in out Object; G : in out Graph_Array) is
      type Counts_Array is array (Natural range 0 .. Graph_Index_Base-1) of Natural;
      Counts : Counts_Array := [others => 0];
      type Ids_Array is array (Natural range 0 .. Graph_Index_Base-1) of Natural range 0 .. Graph_Index_Base-1;
      Ids : Ids_Array := [others => 0];
      N, Edge_Start, Last, Slot : Natural;
      C : Integer;
   begin
      if not S.Packed_Graph or S.Graph_Length = 0 then return; end if;
      N := G (S.First_Graph);
      if N > Graph_Index_Base then return; end if;
      Edge_Start := S.First_Graph+2+2*N; Last := S.First_Graph+(S.Graph_Length-1);
      for K in 0 .. N-1 loop
         C := Find_End (G, Edge_Start+G (S.First_Graph+2+K), Last);
         if C < 0 or C > Natural'Last/Graph_Index_Base then return; end if;
         Counts (K) := C;
         Ids (K) := G (S.First_Graph+2+N+K);
         pragma Loop_Invariant (for all J in 0 .. K =>
           Ids (J) = G (S.First_Graph+2+N+J)
           and then Counts (J) <= Natural'Last/Graph_Index_Base
           and then Counts (J) = Find_End (G, Edge_Start+G (S.First_Graph+2+J), Last));
      end loop;
      for K in 0 .. N-1 loop
         pragma Loop_Invariant (G (S.First_Graph) = N);
         pragma Loop_Invariant (for all J in G'Range =>
           (if J in S.First_Graph+2+N .. S.First_Graph+1+N+K
            then Long_Long_Integer (G (J)) = Long_Long_Integer (Counts (J-(S.First_Graph+2+N)))*Graph_Index_Base+Long_Long_Integer (Ids (J-(S.First_Graph+2+N)))
            else G (J) = G'Loop_Entry (J)));
         Slot := S.First_Graph+2+N+K;
         G (Slot) := Encode_Parts (Counts (K), Ids (K));
      end loop;
      S.Packed_Degrees := True;
   end Compile_Degrees;
   function Best_Vertex (V : Vertex_Array; First, Length : Natural; D : Vec; Seed : Natural) return Natural is
      Best : Natural := Seed;
      Seed_Value : constant Real := Dot (V (Seed), D);
      Best_Value : Real := Seed_Value;
      Value : Real;
   begin
      for K in First .. First+(Length-1) loop
         pragma Loop_Invariant (Best in First .. First+(Length-1));
         pragma Loop_Invariant (Bounded (V (Best)));
         pragma Loop_Invariant (Best_Value = Dot (V (Best), D));
         pragma Loop_Invariant (for all J in First .. K-1 => Dot (V (J), D) <= Best_Value);
         pragma Loop_Invariant (Seed_Value <= Best_Value);
         pragma Loop_Invariant (if Best_Value = Seed_Value then Best = Seed);
         Value := Dot (V (K), D);
         if Value > Best_Value then Best := K; Best_Value := Value; end if;
      end loop;
      return Best;
   end Best_Vertex;
end MJ.Convex_Assets;

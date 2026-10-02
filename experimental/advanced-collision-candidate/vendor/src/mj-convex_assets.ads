with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Rigid_Math;
package MJ.Convex_Assets with SPARK_Mode is
   --  Run once when immutable assets are installed.  Collision procedures
   --  carry this predicate as a precondition, rather than rescanning assets.
   function Graph_Header (S : Object; G : Graph_Array) return Boolean is
     (S.Graph_Length = 0 or else
       (S.Kind = Hull and then (not S.Packed_Degrees or else S.Packed_Graph)
        and then S.First_Graph in G'Range
        and then S.Graph_Length >= 3 and then S.Graph_Length-1 <= G'Last-S.First_Graph
        and then G (S.First_Graph) > 0
        and then G (S.First_Graph) <= (S.Graph_Length-3)/2
        and then (not S.Packed_Graph or else
          (S.Length <= 8192 and then G (S.First_Graph) <= 8192))
        and then (for all Seed of S.Extrema => Seed < G (S.First_Graph))
        and then (for all K in 0 .. G (S.First_Graph)-1 =>
          G (S.First_Graph+2+G (S.First_Graph)+K) >= 0)
        and then (if S.Packed_Degrees then
          (for all K in 0 .. G (S.First_Graph)-1 =>
            G (S.First_Graph+2+G (S.First_Graph)+K) mod 8192 < S.Length)
          else (for all K in 0 .. G (S.First_Graph)-1 =>
            G (S.First_Graph+2+G (S.First_Graph)+K) < S.Length))
        and then (for all K in 0 .. G (S.First_Graph)-1 =>
          G (S.First_Graph+2+K) in 0 .. S.Graph_Length-3-2*G (S.First_Graph))))
     with Global => null;
   function Valid_Graph (S : Object; G : Graph_Array) return Boolean
     with Global => null, Post => (if Valid_Graph'Result then Graph_Header (S, G));
   function Seed_Coordinate (X : Real) return Natural
     with Global => null, Inline,
       Post => Seed_Coordinate'Result = (if X > 0.4 then 2 elsif X < -0.4 then 0 else 1);
   Graph_Index_Base : constant := 8192;
   function Encode_Neighbour (Local_Id, Global_Id : Natural) return Natural
     with Global => null, Inline,
       Pre => Local_Id < Graph_Index_Base and Global_Id < Graph_Index_Base,
       Post => Encode_Neighbour'Result = Local_Id*Graph_Index_Base+Global_Id;
   function Local_Id (Code : Natural) return Natural is (Code/Graph_Index_Base)
     with Global => null, Inline;
   function Global_Id (Code : Natural) return Natural is (Code mod Graph_Index_Base)
     with Global => null, Inline;
   function Find_End (G : Graph_Array; First, Last : Natural) return Integer
     with Global => null,
       Pre => First in G'Range and then Last in G'Range and then First <= Last,
       Post => (if Find_End'Result < 0 then Find_End'Result = -1
         and then (for all K in First .. Last => G (K) >= 0)
         else Find_End'Result <= Last-First and then G (First+Find_End'Result) < 0
           and then (for all K in First .. First+Find_End'Result-1 => G (K) >= 0));
   function Encode_Parts (High, Low : Natural) return Natural
     with Global => null, Inline,
       Pre => High <= Natural'Last/Graph_Index_Base and Low < Graph_Index_Base,
       Post => Encode_Parts'Result = High*Graph_Index_Base+Low;
   procedure Compile_Degrees (S : in out Object; G : in out Graph_Array)
     with Global => null, Pre => Valid_Graph (S, G) and not S.Packed_Degrees,
       Post => S = (S'Old with delta Packed_Degrees => S.Packed_Degrees)
         and then (if not S.Packed_Degrees then G = G'Old)
         and then (if S.Packed_Degrees then S.Packed_Graph and then S.Graph_Length > 0
           and then (for all J in G'Range =>
             (if J in S.First_Graph+2+G'Old (S.First_Graph) .. S.First_Graph+1+2*G'Old (S.First_Graph)
              then Long_Long_Integer (G (J)) =
                Long_Long_Integer (Find_End (G'Old, S.First_Graph+2+2*G'Old (S.First_Graph)+G'Old (S.First_Graph+2+(J-(S.First_Graph+2+G'Old (S.First_Graph)))), S.First_Graph+(S.Graph_Length-1)))*Graph_Index_Base+Long_Long_Integer (G'Old (J))
              else G (J) = G'Old (J))));
   --  Compile the local/global index pair once.  Large assets retain the
   --  original graph representation; negative terminators are unchanged.
   procedure Compile_Graph (S : in out Object; G : in out Graph_Array)
     with Global => null,
       Pre => Valid_Graph (S, G) and not S.Packed_Graph and not S.Packed_Degrees,
       Post => S = (S'Old with delta Packed_Graph => S.Packed_Graph)
         and then (if not S.Packed_Graph then G = G'Old)
         and then (if S.Packed_Graph then
           S.Graph_Length > 0 and then S.Length <= Graph_Index_Base
           and then G (S.First_Graph) in 1 .. Graph_Index_Base
           and then (for all J in G'Range =>
             (if J in S.First_Graph+2+2*G'Old (S.First_Graph) .. S.First_Graph+(S.Graph_Length-1)
                and then G'Old (J) in 0 .. G'Old (S.First_Graph)-1
              then G (J) = Encode_Neighbour (G'Old (J), G'Old (S.First_Graph+2+G'Old (S.First_Graph)+G'Old (J)))
              else G (J) = G'Old (J))));
   function Best_Vertex (V : Vertex_Array; First, Length : Natural; D : Vec; Seed : Natural) return Natural
     with Global => null,
       Pre => Length > 0 and then First in V'Range and then Length-1 <= V'Last-First
         and then Seed in First .. First+(Length-1) and then MJ.Rigid_Math.Bounded (D)
         and then (for all K in First .. First+(Length-1) => MJ.Rigid_Math.Bounded (V (K))),
       Post => Best_Vertex'Result in First .. First+(Length-1)
         and then (for all K in First .. First+(Length-1) =>
           MJ.Rigid_Math.Dot (V (K), D) <= MJ.Rigid_Math.Dot (V (Best_Vertex'Result), D))
         and then (if (for all K in First .. First+(Length-1) =>
           MJ.Rigid_Math.Dot (V (K), D) <= MJ.Rigid_Math.Dot (V (Seed), D)) then Best_Vertex'Result = Seed);
end MJ.Convex_Assets;

--  Witness-preserving GJK/EPA, adapted from MuJoCo 3.14.0 (Apache-2.0).
--  The horizon uses an explicit stack in place of C's recursive traversal.
with MJ.Flex_Support;
with MJ.Rigid_Math; use MJ.Rigid_Math;
with MJ.Rigid_Support;
with MJ.Convex_Assets;
with MJ.Contact_Features;
with MJ.Contact_Inflation;
with MJ.Rigid_Simplex; use MJ.Rigid_Simplex;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;

package body MJ.Convex_Contacts with SPARK_Mode is
   --  The small-mesh callback in C has no primitive dispatch or graph setup.
   --  Keep this path small enough to inline into the repeated GJK supports.
   procedure Linear_Support (S : Object; P : Pose; V : Vertex_Array; D : Vec;
                             Cache : in out Integer; Point : out Vec; Index : out Integer)
     with Inline
   is
      Direction : constant Vec := Local (P.Rotation, D);
      GI : Natural := (if Cache >= 0 and then Cache in Integer (S.First) .. Integer (S.First+(S.Length-1))
                       then Natural (Cache) else S.First);
   begin
      GI := MJ.Convex_Assets.Best_Vertex (V, S.First, S.Length, Direction, GI);
      Cache := Integer (GI); Index := Integer (GI);
      Point := Add (P.Position, Transform (P.Rotation, V (GI)));
      if S.Skin > 0.0 then Point := Add (Point, Scale (D, S.Skin)); end if;
   end Linear_Support;

   procedure Support_Point (S : Object; P : Pose; V : Vertex_Array; D : Vec;
                            Point : out Vec; Index : out Integer) is
      Direction, Local_Point : Vec;
      Best, Value, Length : Real;
      K : Natural;
   begin
      Index := -1;
      if S.Kind = Primitive then
         if S.Rigid.Kind in Box | Cylinder then
            --  Compute the local direction once for both witness and feature.
            Direction := Local (P.Rotation, D);
            if S.Rigid.Kind = Box then
               Index := 0;
               for I in Axis loop
                  Local_Point (I) := (if Direction (I) >= 0.0 then S.Rigid.Size (I) else -S.Rigid.Size (I));
                  if Direction (I) >= 0.0 then Index := Index+2**I; end if;
               end loop;
            else
               Local_Point := Zero;
               Length := Sqrt (Direction (0)*Direction (0)+Direction (1)*Direction (1));
               if Length >= Min_Val then
                  Length := S.Rigid.Size (0)/Length;
                  Local_Point (0) := Length*Direction (0); Local_Point (1) := Length*Direction (1);
               end if;
               Local_Point (2) := (if Direction (2) >= 0.0 then S.Rigid.Size (1) else -S.Rigid.Size (1));
               Index := (if Direction (2) >= 0.0 then 0 else 1);
            end if;
            Point := Add (P.Position, Transform (P.Rotation, Local_Point));
         else
            Point := MJ.Rigid_Support.Support (S.Rigid, P, D);
         end if;
      elsif S.Kind = Flex_Element then
         Direction:=Local (P.Rotation,D);
         K:=MJ.Flex_Support.Select_Vertex (S.Prism_Vertices (0 .. S.Length-1),Direction);
         Index:=Integer (K); Point:=Add (P.Position,Transform (P.Rotation,S.Prism_Vertices (K)));
      elsif S.Kind = Prism then
         Direction := Local (P.Rotation, D); K := (if Direction (2) < 0.0 then 0 else 3); Best := Dot (S.Prism_Vertices (K), Direction);
         for I in K+1 .. K+2 loop Value := Dot (S.Prism_Vertices (I), Direction); if Value > Best then Best := Value; K := I; end if; end loop;
         Index := Integer (K); Point := Add (P.Position, Transform (P.Rotation, S.Prism_Vertices (K)));
      else
         Direction := Local (P.Rotation, D); K := S.First;
         Best := Dot (V (K), Direction);
         for I in S.First+1 .. S.First+S.Length-1 loop
            Value := Dot (V (I), Direction);
            if Value > Best then Best := Value; K := I; end if;
         end loop;
         Index := Integer (K); Point := Add (P.Position, Transform (P.Rotation, V (K)));
      end if;
      if S.Skin > 0.0 then Point := Add (Point, Scale (D, S.Skin)); end if;
   end Support_Point;

   --  C's directional 3x3x3 seed, cached starting vertex, and ordered
   --  graph hill climb.  The compiled graph is immutable and shared.
   procedure Graph_Support (S : Object; P : Pose; V : Vertex_Array; D : Vec;
                             Graphs : Graph_Array; Cache : in out Integer;
                             Point : out Vec; Index : out Integer) is
      Direction : Vec;
      Best, Value : Real;
      K, Seed, Prev, GI, N, Edge_Start, Offset, Neighbour, Degree : Natural;
      GX, GY, GZ : Natural range 0 .. 2;
      function Vertex_Index (Local_Id : Natural) return Natural is
        (S.First+(if S.Packed_Degrees then MJ.Convex_Assets.Global_Id (Graphs (S.First_Graph+2+N+Local_Id))
                   else Natural (Graphs (S.First_Graph+2+N+Local_Id))));
   begin
      Direction := Local (P.Rotation, D);
      --  The admitted immutable graph satisfies Valid_Graph in the public
      --  precondition.  Its header/range checks need not be repeated here.
         N := Natural (Graphs (S.First_Graph));
         GX := MJ.Convex_Assets.Seed_Coordinate (Direction (0));
         GY := MJ.Convex_Assets.Seed_Coordinate (Direction (1));
         GZ := MJ.Convex_Assets.Seed_Coordinate (Direction (2));
         Seed := S.Extrema (GX*9+GY*3+GZ); K := Seed;
         if Cache >= 0 then
            K := Natural (Cache);
            if Dot (V (Vertex_Index (Seed)), Direction) > Dot (V (Vertex_Index (K)), Direction) then K := Seed; end if;
         end if;
         Best := Dot (V (Vertex_Index (K)), Direction); Edge_Start := S.First_Graph+2+2*N;
         for Step in 0 .. N-1 loop
            Prev := K; Offset := Natural (Graphs (S.First_Graph+2+K));
            if S.Packed_Degrees then
               Degree := MJ.Convex_Assets.Local_Id (Graphs (S.First_Graph+2+N+K));
               for E in Edge_Start+Offset .. Edge_Start+Offset+(Degree-1) loop
                  Neighbour := MJ.Convex_Assets.Local_Id (Graphs (E));
                  Value := Dot (V (S.First+MJ.Convex_Assets.Global_Id (Graphs (E))), Direction);
                  if Value > Best then Best := Value; K := Neighbour; end if;
               end loop;
            elsif S.Packed_Graph then
               for E in Edge_Start+Offset .. S.First_Graph+S.Graph_Length-1 loop
                  exit when Graphs (E) < 0;
                  Neighbour := MJ.Convex_Assets.Local_Id (Graphs (E));
                  Value := Dot (V (S.First+MJ.Convex_Assets.Global_Id (Graphs (E))), Direction);
                  if Value > Best then Best := Value; K := Neighbour; end if;
               end loop;
            else
               for E in Edge_Start+Offset .. S.First_Graph+S.Graph_Length-1 loop
                  exit when Graphs (E) < 0;
                  Neighbour := Natural (Graphs (E)); Value := Dot (V (Vertex_Index (Neighbour)), Direction);
                  if Value > Best then Best := Value; K := Neighbour; end if;
               end loop;
            end if;
            exit when K = Prev;
         end loop;
         Cache := Integer (K); GI := Vertex_Index (K);
      Index := Integer (GI); Point := Add (P.Position, Transform (P.Rotation, V (GI)));
      if S.Skin > 0.0 then Point := Add (Point, Scale (D, S.Skin)); end if;
   end Graph_Support;

   procedure Support_Cached (S : Object; P : Pose; V : Vertex_Array; D : Vec;
                             Graphs : Graph_Array; Cache : in out Integer;
                             Point : out Vec; Index : out Integer) is
   begin
      if S.Kind /= Hull then Support_Point (S, P, V, D, Point, Index);
      elsif S.Length < 10 or S.Graph_Length = 0 then
         Linear_Support (S, P, V, D, Cache, Point, Index);
      else
         Graph_Support (S, P, V, D, Graphs, Cache, Point, Index);
      end if;
   end Support_Cached;

   type Simplex is array (Natural range 0 .. 3) of Vertex;
   type GJK_Result is record
      Points : Simplex;
      N : Natural range 0 .. 4 := 0;
      First, Second : Vec := Zero;
      Distance : Real := 0.0;
      Separated, Exhausted : Boolean := False;
   end record;

   procedure Generate (A, B : Object; PA, PB : Pose; V : Vertex_Array;
                       Margin : Real; O : Options; W : in out Workspace;
                       M : in out Manifold; Result : out Status;
                       Facets : Facet_Array := Empty_Facets; Multiple : Boolean := False;
                       Inflation1, Inflation2, Output_Margin : Real := -1.0; Graphs : Graph_Array := Empty_Graph;
                       Incidence : MJ.Contact_Incidence.Lookup := MJ.Contact_Incidence.Empty_Lookup) is
      M1 : constant Real := (if Inflation1 < 0.0 then Margin else Inflation1);
      M2 : constant Real := (if Inflation2 < 0.0 then Margin else Inflation2);
      Out_Margin : constant Real := (if Output_Margin < 0.0 then Margin else Output_Margin);
      R : GJK_Result;
      Full1, Full2, Full : Real := 0.0;
      Discrete : constant Boolean := M1 = 0.0 and M2 = 0.0 and A.Skin = 0.0 and B.Skin = 0.0
        and (A.Kind in Hull | Prism | Flex_Element or else A.Rigid.Kind = Box)
        and (B.Kind in Hull | Prism | Flex_Element or else B.Rigid.Kind = Box);
      Failed : Boolean := False;
      Seeded : Boolean;
      Cache1, Cache2 : Integer := -1;
      Chosen, Previous : Integer;
      Lower2, Lower, Upper, Upper2, Trial_Upper, Tolerance, D : Real;
      Added, Initial_Faces, H, Edge, F, NEdges, F1, F2 : Natural;
      Coef : Vec;
      Minor : Real;
      X1, X2 : Vec;
      Added_Point : Vertex;

      function Point (S : Object; P : Pose; Dir : Vec; Shrink : Boolean; Inflation : Real; Cache : in out Integer;
                      Id : out Integer) return Vec with Side_Effects is
         Value : Vec;
         Axis_Z : Vec;
      begin
         Id := -1;
         if Shrink and S.Kind = Primitive and S.Rigid.Kind = Sphere then return P.Position;
         elsif Shrink and S.Kind = Primitive and S.Rigid.Kind = Capsule then
            Axis_Z := Column (P.Rotation, 2);
            return Add (P.Position, Scale (Axis_Z, (if Dot (Axis_Z, Dir) >= 0.0 then S.Rigid.Size (1) else -S.Rigid.Size (1))));
         end if;
         if S.Kind = Hull and then (S.Length < 10 or S.Graph_Length = 0) then
            Linear_Support (S, P, V, Dir, Cache, Value, Id);
         elsif S.Kind = Hull then
            Graph_Support (S, P, V, Dir, Graphs, Cache, Value, Id);
         else
            Support_Point (S, P, V, Dir, Value, Id);
         end if;
         if Inflation > 0.0 then Value := Add (Value, Scale (Dir, 0.5*Inflation)); end if;
         return Value;
      end Point;

      function Support (Dir : Vec; Shrink : Boolean := False) return Vertex with Side_Effects is
         P : Vertex;
         Id1, Id2 : Integer;
      begin
         P.First := Point (A, PA, Dir, Shrink, M1, Cache1, Id1);
         P.Second := Point (B, PB, Scale (Dir, -1.0), Shrink, M2, Cache2, Id2);
         P.Index1 := Id1; P.Index2 := Id2;
         P.Point := Sub (P.First, P.Second); return P;
      end Support;

      --  Native EPA divides each component by the length.  Multiplying by
      --  a rounded reciprocal changes the support path on curved boundaries.
      function EPA_Support (D : Vec; L : Real) return Vertex with Side_Effects is
         Ret : Vertex;
      begin
         if L > Min_Val then Ret := Support ([D (0)/L, D (1)/L, D (2)/L]);
         else Ret := Support ([1.0, 0.0, 0.0]); end if;
         return Ret;
      end EPA_Support;

      procedure Intersection (S : in out Simplex; K : in out Natural; Ret : out Integer)
        with Always_Terminates is
         type Indices is array (Natural range 0 .. 3) of Natural range 0 .. 3;
         Order : Indices := [0, 1, 2, 3];
         Normals : Vertices := [others => Zero];
         Distances : Coefficients := [others => 0.0];
         I, J, Worst, Temp : Natural;
         Saved : Simplex;
         procedure Distance (X, Y, Z : Vec; N : out Vec; Dist : out Real) is
            Length2 : Real;
         begin
            N := Cross (Sub (Z, X), Sub (Y, X)); Length2 := Dot (N, N);
            if Length2 > Min_Val*Min_Val and Length2 < 1.0e20 then
               N := Scale (N, 1.0/Sqrt (Length2)); Dist := Dot (N, X);
            else Dist := 1.0e100; end if;
         end Distance;
      begin
         Ret := -1;
         while K < O.Iterations loop
            pragma Loop_Variant (Increases => K);
            Distance (S (Order (2)).Point, S (Order (1)).Point, S (Order (3)).Point, Normals (0), Distances (0));
            Distance (S (Order (0)).Point, S (Order (2)).Point, S (Order (3)).Point, Normals (1), Distances (1));
            Distance (S (Order (1)).Point, S (Order (0)).Point, S (Order (3)).Point, Normals (2), Distances (2));
            Distance (S (Order (0)).Point, S (Order (1)).Point, S (Order (2)).Point, Normals (3), Distances (3));
            if (for some X of Distances => X = 0.0) then return; end if;
            I := (if Distances (0) < Distances (1) then 0 else 1);
            J := (if Distances (2) < Distances (3) then 2 else 3);
            Worst := (if Distances (I) < Distances (J) then I else J);
            if Distances (Worst) > 0.0 then
               Saved := S; for X in 0 .. 3 loop S (X) := Saved (Order (X)); end loop;
               Ret := 1; return;
            end if;
            S (Order (Worst)) := Support (Normals (Worst));
            if Dot (Normals (Worst), S (Order (Worst)).Point) < 0.0 then Ret := 0; return; end if;
            I := (Worst+1) mod 4; J := (Worst+2) mod 4;
            Temp := Order (I); Order (I) := Order (J); Order (J) := Temp; K := K+1;
         end loop;
      end Intersection;

      function Blend (S : Simplex; L : Coefficients; N : Natural; Which : Natural) return Vec with Inline is
         Ret, Term : Vec;
         function Get (I : Natural) return Vec is
           (if Which = 0 then S (I).Point elsif Which = 1 then S (I).First else S (I).Second);
      begin
         Ret := Scale (Get (0), L (0));
         for I in 1 .. N-1 loop Term := Scale (Get (I), L (I)); Ret := Add (Ret, Term); end loop;
         return Ret;
      end Blend;

      function GJK (Shrink : Boolean; Cutoff : Real) return GJK_Result with Side_Effects is
         G : GJK_Result;
         Lambdas : Coefficients := [others => 0.0];
         Points : Vertices := [others => Zero];
         X : Vec := Sub (Add (PA.Position, Transform (PA.Rotation, A.Center_Offset)), Add (PB.Position, Transform (PB.Rotation, B.Center_Offset)));
         S : Vertex;
         Length : Real := Norm (X);
         Last_Length : Real := 0.0;
         Epsilon : constant Real := (if Discrete then 0.0 else 0.5*O.Tolerance*O.Tolerance);
         Minimum : constant Real := (if Discrete then Min_Val else O.Tolerance);
         Bound : Real;
         K, NN : Natural := 0;
         Backup : Boolean := Cutoff = 0.0;
         Ret : Integer;
      begin
         G.First := Add (PA.Position, Transform (PA.Rotation, A.Center_Offset)); G.Second := Add (PB.Position, Transform (PB.Rotation, B.Center_Offset));
         --  Deterministic seed for coincident centres, for which native 3.14.0
         --  exits without a simplex even though positive rigid bodies overlap.
         if Length = 0.0 then X := [1.0, 0.0, 0.0]; Length := 1.0; end if;
         while K < O.Iterations loop
            pragma Loop_Variant (Increases => K);
            exit when Length < Minimum or else abs (Last_Length-Length) < Min_Val;
            S := Support (Scale (Scale (X, 1.0/Length), -1.0), Shrink);
            exit when Dot (X, Sub (X, S.Point)) < Epsilon;
            Bound := Dot (X, S.Point);
            if Bound > 0.0 and then (Cutoff = 0.0 or else Bound >= Cutoff*Length) then
               G.Separated := True; G.Distance := 1.0e100; G.N := 0; return G;
            end if;
            G.Points (G.N) := S;
            if G.N = 3 and Backup then
               Intersection (G.Points, K, Ret);
               if Ret /= -1 then
                  G.Separated := Ret = 0; G.N := (if Ret = 1 then 4 else 0);
                  G.Distance := (if Ret = 1 then 0.0 else 1.0e100); return G;
               end if;
               Backup := False;
            end if;
            G.N := G.N+1;
            for I in 0 .. G.N-1 loop Points (I) := G.Points (I).Point; end loop;
            Closest (Points, G.N, Lambdas); NN := 0;
            for I in 0 .. G.N-1 loop
               if Lambdas (I) /= 0.0 then G.Points (NN) := G.Points (I); Lambdas (NN) := Lambdas (I); NN := NN+1; end if;
            end loop;
            G.N := NN;
            if G.N = 0 then G.Separated := True; G.Distance := 1.0e100; return G; end if;
            X := Blend (G.Points, Lambdas, G.N, 0); Last_Length := Length; Length := Norm (X);
            exit when G.N = 4;
            K := K+1;
         end loop;
         G.Exhausted := K >= O.Iterations;
         if G.N > 0 then G.First := Blend (G.Points, Lambdas, G.N, 1); G.Second := Blend (G.Points, Lambdas, G.N, 2); end if;
         if Length > 0.0 then
            S := Support (Scale (Scale (X, 1.0/Length), -1.0), Shrink); G.Separated := Dot (X, S.Point) > 0.0;
         end if;
         G.Distance := (if G.N = 4 and not G.Separated then 0.0 else Length); return G;
      end GJK;

      function Insert (P : Vertex) return Natural with Side_Effects is
         I : constant Natural := W.NV;
      begin
         if W.NV = Max_Vertices then Failed := True; return 0; end if;
         W.Vertices (I) := P; W.NV := W.NV+1; return I;
      end Insert;

      function Attach (I, J, K, Adj1, Adj2, Adj3 : Natural) return Real with Side_Effects is
         Id : constant Natural := W.NF;
         Projection_Point : Vec;
         Degenerate : Boolean;
      begin
         if W.NF = Max_Faces then Failed := True; return 0.0; end if;
         W.NF := W.NF+1;
         Projection (W.Vertices (K).Point, W.Vertices (J).Point, W.Vertices (I).Point, Projection_Point, Degenerate);
         W.Faces (Id) := (Vertices => [I, J, K], Adjacent => [Adj1, Adj2, Adj3],
                           Projection => Projection_Point, Distance2 => 0.0, Map_Index => -1);
         if Degenerate then return 0.0; end if;
         if Dot (Projection_Point, Sub (W.Vertices (I).Point, W.Center)) < 0.0 then
            W.Faces (Id).Projection := Scale (Projection_Point, -1.0);
         end if;
         W.Faces (Id).Distance2 := Dot (Projection_Point, Projection_Point);
         return W.Faces (Id).Distance2;
      end Attach;

      function Triangle_Point (I, J, K : Natural; P : Vec) return Boolean is
         Coeff : Vec;
         Minor : Real;
         X : Vec;
      begin
         Affine (W.Vertices (I).Point, W.Vertices (J).Point, W.Vertices (K).Point, P, Coeff, Minor);
         if Minor = 0.0 then return False; end if;
         Coeff := [Coeff (0)/Minor, Coeff (1)/Minor, Coeff (2)/Minor];
         if (for some X of Coeff => X < 0.0) then return False; end if;
         X := Add (Add (Scale (W.Vertices (I).Point, Coeff (0)), Scale (W.Vertices (J).Point, Coeff (1))), Scale (W.Vertices (K).Point, Coeff (2)));
         return Norm (Sub (X, P)) < Min_Val;
      end Triangle_Point;

      procedure Populate_Map is
      begin
         W.NM := W.NF;
         for I in 0 .. W.NF-1 loop W.Map (I) := I; W.Faces (I).Map_Index := I; end loop;
      end Populate_Map;

      function Polytope_3 (P1, P2, P3 : Vertex) return Boolean with Side_Effects is
         Copy1 : constant Vertex := P1;
         Copy2 : constant Vertex := P2;
         Copy3 : constant Vertex := P3;
         N : constant Vec := Cross (Sub (Copy2.Point, Copy1.Point), Sub (Copy3.Point, Copy1.Point));
         Len : constant Real := Norm (N);
         I1, I2, I3, I4, I5 : Natural;
         Added_Point : Vertex; Dummy : Real;
      begin
         W.NV := 0; W.NF := 0; W.NM := 0;
         W.Center := Scale (Add (Add (Copy1.Point, Copy2.Point), Copy3.Point), 1.0/3.0);
         if Len < Min_Val then return False; end if;
         I1 := Insert (Copy1); I2 := Insert (Copy2); I3 := Insert (Copy3);
         Added_Point := EPA_Support (Scale (N, -1.0), Len); I5 := Insert (Added_Point);
         Added_Point := EPA_Support (N, Len); I4 := Insert (Added_Point);
         if Triangle_Point (I1, I2, I3, W.Vertices (I4).Point)
           or else Triangle_Point (I1, I2, I3, W.Vertices (I5).Point) then return False; end if;
         Dummy := Attach (I4, I1, I2, 1, 3, 2); if Dummy < Min_Val*Min_Val then return False; end if;
         Dummy := Attach (I4, I3, I1, 2, 4, 0); if Dummy < Min_Val*Min_Val then return False; end if;
         Dummy := Attach (I4, I2, I3, 0, 5, 1); if Dummy < Min_Val*Min_Val then return False; end if;
         Dummy := Attach (I5, I2, I1, 5, 0, 4); if Dummy < Min_Val*Min_Val then return False; end if;
         Dummy := Attach (I5, I1, I3, 3, 1, 5); if Dummy < Min_Val*Min_Val then return False; end if;
         Dummy := Attach (I5, I3, I2, 4, 2, 3); if Dummy < Min_Val*Min_Val then return False; end if;
         Populate_Map; return True;
      end Polytope_3;

      --  Snapshot the selected vertices before Polytope_3 resets W.  Passing
      --  components of W directly would alias its writable global state.
      function Polytope_At (I, J, K : Natural) return Boolean with Side_Effects is
         P1 : constant Vertex := W.Vertices (I);
         P2 : constant Vertex := W.Vertices (J);
         P3 : constant Vertex := W.Vertices (K);
         Ret : Boolean;
      begin
         Ret := Polytope_3 (P1, P2, P3); return Ret;
      end Polytope_At;

      function Seed return Boolean with Side_Effects is
         Diff, E, U, D1, D2, D3 : Vec;
         Rotation : Matrix;
         Len, Vol1, Vol2, Vol3, Dummy : Real;
         K : Axis := 0;
         I : Natural; Added_Point : Vertex; Ret : Boolean;
      begin
         W.NV := 0; W.NF := 0; W.NM := 0; W.NH := 0;
         if R.N = 3 then Ret := Polytope_3 (R.Points (0), R.Points (1), R.Points (2)); return Ret; end if;
         for J in 0 .. R.N-1 loop I := Insert (R.Points (J)); end loop;
         if R.N = 4 then
            W.Center := Scale (Add (Add (Add (R.Points (0).Point, R.Points (1).Point), R.Points (2).Point), R.Points (3).Point), 0.25);
            Dummy := Attach (0, 1, 2, 1, 3, 2); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (0, 1, 2); return Ret; end if;
            Dummy := Attach (0, 3, 1, 2, 3, 0); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (0, 3, 1); return Ret; end if;
            Dummy := Attach (0, 2, 3, 0, 3, 1); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (0, 2, 3); return Ret; end if;
            Dummy := Attach (3, 2, 1, 2, 0, 1); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (3, 2, 1); return Ret; end if;
            if not Strict_Tetrahedron (W.Vertices (0).Point, W.Vertices (1).Point, W.Vertices (2).Point, W.Vertices (3).Point) then return False; end if;
            Populate_Map; return True;
         elsif R.N /= 2 then return False; end if;
         W.Center := Scale (Add (R.Points (0).Point, R.Points (1).Point), 0.5);
         Diff := Sub (R.Points (1).Point, R.Points (0).Point); Len := Norm (Diff);
         if Len = 0.0 then return False; end if;
         for J in 1 .. 2 loop if abs Diff (J) < abs Diff (K) then K := J; end if; end loop;
         E := Zero; E (K) := 1.0; D1 := Cross (E, Diff); U := [Diff (0)/Len, Diff (1)/Len, Diff (2)/Len];
         --  Native 3.14.0's EPA seed matrix, including its R(6) expression.
         --  This is a search seed; no orthogonal-rotation property is claimed.
         Rotation := [-0.5+U (0)*U (0)*1.5, U (0)*U (1)*1.5-U (2)*0.86602540378, U (0)*U (2)*1.5+U (1)*0.86602540378,
                      U (1)*U (0)*1.5+U (2)*0.86602540378, -0.5+U (1)*U (1)*1.5, U (1)*U (2)*1.5-U (0)*0.86602540378,
                      U (1)*U (2)*1.5-U (1)*0.86602540378, U (2)*U (1)*1.5+U (0)*0.86602540378, -0.5+U (2)*U (2)*1.5];
         D2 := Transform (Rotation, D1); D3 := Transform (Rotation, D2);
         Added_Point := EPA_Support (D1, Norm (D1)); I := Insert (Added_Point);
         Added_Point := EPA_Support (D2, Norm (D2)); I := Insert (Added_Point);
         Added_Point := EPA_Support (D3, Norm (D3)); I := Insert (Added_Point);
         Dummy := Attach (0, 2, 3, 1, 3, 2); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (0, 2, 3); return Ret; end if;
         Dummy := Attach (0, 4, 2, 2, 4, 0); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (0, 4, 2); return Ret; end if;
         Dummy := Attach (0, 3, 4, 0, 5, 1); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (0, 3, 4); return Ret; end if;
         Dummy := Attach (1, 3, 2, 5, 0, 4); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (1, 3, 2); return Ret; end if;
         Dummy := Attach (1, 2, 4, 3, 1, 5); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (1, 2, 4); return Ret; end if;
         Dummy := Attach (1, 4, 3, 4, 2, 3); if Dummy < Min_Val*Min_Val then Ret := Polytope_At (1, 4, 3); return Ret; end if;
         Vol1 := Determinant (Sub (W.Vertices (2).Point, W.Vertices (0).Point), Sub (W.Vertices (3).Point, W.Vertices (0).Point), Diff);
         Vol2 := Determinant (Sub (W.Vertices (3).Point, W.Vertices (0).Point), Sub (W.Vertices (4).Point, W.Vertices (0).Point), Diff);
         Vol3 := Determinant (Sub (W.Vertices (4).Point, W.Vertices (0).Point), Sub (W.Vertices (2).Point, W.Vertices (0).Point), Diff);
         if not ((Vol1 >= 0.0 and Vol2 >= 0.0 and Vol3 >= 0.0) or (Vol1 <= 0.0 and Vol2 <= 0.0 and Vol3 <= 0.0)) then return False; end if;
         Populate_Map; return True;
      end Seed;

      procedure Delete_Face (Id : Natural) is
         Index : constant Integer := W.Faces (Id).Map_Index;
      begin
         if Index >= 0 then
            W.NM := W.NM-1; W.Map (Index) := W.Map (W.NM); W.Faces (W.Map (Index)).Map_Index := Index;
         end if;
         W.Faces (Id).Map_Index := -2;
      end Delete_Face;

      function Edge_Of (Id, Vertex_Index : Natural) return Axis is
        (if W.Faces (Id).Vertices (0) = Vertex_Index then 0
         elsif W.Faces (Id).Vertices (1) = Vertex_Index then 1 else 2);

      procedure Horizon (Id : Natural; P : Vec) is
         type Stack_Entry is record Face_Index : Natural; Edge_Index : Axis; end record;
         type Stack_Array is array (Natural range 0 .. 2*Max_Faces+2) of Stack_Entry with Relaxed_Initialization;
         Stack : Stack_Array;
         SP : Natural := 0;
         Cur : Stack_Entry;
         Adj : Natural;
         E : Axis;
         procedure Push (Face_Index : Natural; Edge_Index : Axis) is
         begin
            if SP = Stack'Length then Failed := True; return; end if;
            Stack (SP) := (Face_Index, Edge_Index); SP := SP+1;
         end Push;
      begin
         W.NH := 0; Delete_Face (Id);
         for K in reverse Axis loop
            Adj := W.Faces (Id).Adjacent (K); E := Edge_Of (Adj, W.Faces (Id).Vertices ((K+1) mod 3)); Push (Adj, E);
         end loop;
         for Step in 0 .. 3*W.NF loop
            exit when SP = 0 or Failed;
            SP := SP-1; Cur := Stack (SP);
            if W.Faces (Cur.Face_Index).Map_Index > -2 then
               if Dot (W.Faces (Cur.Face_Index).Projection, P)-W.Faces (Cur.Face_Index).Distance2 > Min_Val then
                  Delete_Face (Cur.Face_Index);
                  for J in reverse 1 .. 2 loop
                     E := (Cur.Edge_Index+J) mod 3; Adj := W.Faces (Cur.Face_Index).Adjacent (E);
                     Push (Adj, Edge_Of (Adj, W.Faces (Cur.Face_Index).Vertices ((E+1) mod 3)));
                  end loop;
               else
                  if W.NH = Max_Faces then Failed := True; return; end if;
                  W.Horizon_Faces (W.NH) := Cur.Face_Index; W.Horizon_Edges (W.NH) := Cur.Edge_Index; W.NH := W.NH+1;
               end if;
            end if;
         end loop;
         if SP /= 0 then Failed := True; end if;
      end Horizon;

      procedure Emit (First, Second : Vec; Distance : Real) is
      begin
         M.Length := 1;
         M.Items (0) := (Position => Scale (Add (First, Second), 0.5),
                         Normal => Unit (Sub (First, Second)), Tangent => Zero, Distance => Out_Margin+Distance);
      end Emit;

   begin
      M.Length := 0; Result := Success;
      if A.Kind = Primitive and A.Rigid.Kind in Sphere | Capsule then Full1 := A.Rigid.Size (0)+0.5*M1; end if;
      if B.Kind = Primitive and B.Rigid.Kind in Sphere | Capsule then Full2 := B.Rigid.Size (0)+0.5*M2; end if;
      Full := Full1+Full2;
      if Full > 0.0 then
         R := GJK (True, Full);
         if R.Exhausted and not R.Separated and R.N < 4 then Result := Iteration_Limit; return; end if;
         if R.Distance > O.Tolerance then
            if R.Distance-Full < 0.0 then
               --  C normalizes the recovered witness difference again.  The
               --  GJK Minkowski distance is rounded through a different
               --  reduction and cannot replace that length in binary64.
               MJ.Contact_Inflation.Inflate (R.First, R.Second, Full1, Full2, X1, X2);
               Emit (X1, X2, R.Distance-Full);
            end if;
            return;
         end if;
      end if;
      R := GJK (False, 0.0);
      if R.Exhausted and not R.Separated and R.N < 4 then Result := Iteration_Limit; return; end if;
      if R.Separated or R.Distance > O.Tolerance or R.N < 2 then return; end if;
      Seeded := Seed;
      if not Seeded then
         if Failed then Result := Capacity_Limit; end if;
         return;
      end if;
      Chosen := -1; Upper := 1.0e100; Upper2 := 1.0e100;
      Tolerance := (if Discrete then Min_Val else O.Tolerance);
      for Iteration in 0 .. O.Iterations-1 loop
         Previous := Chosen; Lower2 := 1.0e100;
         for I in 0 .. W.NM-1 loop
            if W.Faces (W.Map (I)).Distance2 < Lower2 then Chosen := W.Map (I); Lower2 := W.Faces (W.Map (I)).Distance2; end if;
         end loop;
         if Lower2 > Upper2 or Chosen < 0 then Chosen := Previous; exit; end if;
         exit when Lower2 <= 0.0;
         Lower := Sqrt (Lower2); Added_Point := EPA_Support (W.Faces (Chosen).Projection, Lower); Added := Insert (Added_Point);
         if Failed then Result := Capacity_Limit; M.Length := 0; return; end if;
         Trial_Upper := Dot (W.Faces (Chosen).Projection, W.Vertices (Added).Point)/Lower;
         if Trial_Upper < Upper then Upper := Trial_Upper; Upper2 := Upper*Upper; end if;
         if Upper-Lower < Tolerance then
            if Iteration = 0 and Upper < Lower-1.0e-10 then Chosen := -1; end if;
            exit;
         end if;
         if Discrete then
            declare Repeated : Boolean := False; begin
               for I in 0 .. W.NV-2 loop
                  if W.Vertices (I).Index1 = W.Vertices (Added).Index1 and W.Vertices (I).Index2 = W.Vertices (Added).Index2 then Repeated := True; exit; end if;
               end loop;
               exit when Repeated;
            end;
         end if;
            declare
               Added_Position : constant Vec := W.Vertices (Added).Point;
            begin
               Horizon (Chosen, Added_Position);
            end;
         if W.NH < 3 or Failed then Result := Numeric_Limit; M.Length := 0; return; end if;
         Initial_Faces := W.NF; NEdges := W.NH;
         if NEdges > Max_Faces-W.NF then Result := Capacity_Limit; M.Length := 0; return; end if;
         for I in 0 .. NEdges-1 loop
            H := W.Horizon_Faces (I); Edge := W.Horizon_Edges (I);
            F1 := W.Faces (H).Vertices (Edge); F2 := W.Faces (H).Vertices ((Edge+1) mod 3);
            W.Faces (H).Adjacent (Edge) := W.NF;
            D := Attach (Added, F2, F1, Initial_Faces+(I+NEdges-1) mod NEdges, H, Initial_Faces+(I+1) mod NEdges);
            if D = 0.0 or Failed then Result := Numeric_Limit; M.Length := 0; return; end if;
            if D >= Lower2 and D <= Upper2 then
               W.Map (W.NM) := W.NF-1; W.Faces (W.NF-1).Map_Index := W.NM; W.NM := W.NM+1;
            end if;
         end loop;
         W.NH := 0;
         exit when W.NM = 0;
      end loop;
      if Chosen < 0 then return; end if;
      F := Natural (Chosen);
      Affine (W.Vertices (W.Faces (F).Vertices (0)).Point, W.Vertices (W.Faces (F).Vertices (1)).Point,
              W.Vertices (W.Faces (F).Vertices (2)).Point, W.Faces (F).Projection, Coef, Minor);
      if Minor = 0.0 then Result := Numeric_Limit; return; end if;
      Coef := [Coef (0)/Minor, Coef (1)/Minor, Coef (2)/Minor];
      X1 := Add (Add (Scale (W.Vertices (W.Faces (F).Vertices (0)).First, Coef (0)),
                     Scale (W.Vertices (W.Faces (F).Vertices (1)).First, Coef (1))),
                     Scale (W.Vertices (W.Faces (F).Vertices (2)).First, Coef (2)));
      X2 := Add (Add (Scale (W.Vertices (W.Faces (F).Vertices (0)).Second, Coef (0)),
                     Scale (W.Vertices (W.Faces (F).Vertices (1)).Second, Coef (1))),
                     Scale (W.Vertices (W.Faces (F).Vertices (2)).Second, Coef (2)));
      if W.Faces (F).Distance2 > 0.0 then Emit (X1, X2, -Sqrt (W.Faces (F).Distance2)); end if;
      if Multiple and Margin = 0.0 and M.Length = 1 and A.Skin = 0.0 and B.Skin = 0.0 then
         declare
            Indices1, Indices2 : MJ.Contact_Features.Feature_Indices;
            Points1, Points2 : MJ.Contact_Features.Feature_Points;
         begin
            for I in Axis loop
               Indices1 (I) := W.Vertices (W.Faces (F).Vertices (I)).Index1;
               Indices2 (I) := W.Vertices (W.Faces (F).Vertices (I)).Index2;
               Points1 (I) := W.Vertices (W.Faces (F).Vertices (I)).First;
               Points2 (I) := W.Vertices (W.Faces (F).Vertices (I)).Second;
            end loop;
            MJ.Contact_Features.Expand (A, B, PA, PB, V, Facets, Indices1, Indices2, Points1, Points2, M, Result, Incidence);
         end;
      end if;
      if M.Length > 0 and then not Finite (M.Items (0)) then M.Length := 0; Result := Numeric_Limit; end if;
   end Generate;
end MJ.Convex_Contacts;

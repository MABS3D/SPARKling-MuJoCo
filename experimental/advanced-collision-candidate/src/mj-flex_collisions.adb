with MJ.Rigid_Math; use MJ.Rigid_Math;
with MJ.Flex_Kernels;
with MJ.Flex_Normals;
with MJ.Flex_Terrain;
with MJ.Collision_SAP;
with MJ.Primitive_Contacts;
with MJ.Advanced_Contacts;
with MJ.Convex_Assets;
package body MJ.Flex_Collisions with SPARK_Mode is
   use type Interfaces.Unsigned_32;
   Origin : constant Pose := (others => <>);
   function Compatible (A, B : Flex) return Boolean is
     ((A.Contype and B.Conaffinity) /= 0 or (B.Contype and A.Conaffinity) /= 0);
   function Bounds (F : Flex; E : Element; V : Vertex_Array) return MJ.BVH.Box is
      Lo, Hi : Vec := V (E.Vertices (0));
      R : MJ.BVH.Box;
   begin
      for J in 1 .. F.Dimension loop
         for K in Axis loop
            Lo (K) := Real'Min (Lo (K),V (E.Vertices (J))(K));
            Hi (K) := Real'Max (Hi (K),V (E.Vertices (J))(K));
         end loop;
      end loop;
      for K in Axis loop R.Center (K):=0.5*(Hi (K)+Lo (K)); R.Half (K):=0.5*(Hi (K)-Lo (K))+F.Radius; end loop;
      return R;
   end Bounds;
   function As_Object (F : Flex; E : Element; V : Vertex_Array) return Object is
      S : Object := (Kind=>Flex_Element,Length=>F.Dimension+1,Skin=>F.Radius,others=><>);
      B : constant MJ.BVH.Box := Bounds (F,E,V);
   begin
      for J in 0 .. 5 loop S.Prism_Vertices (J):=V (E.Vertices (J mod (F.Dimension+1))); end loop;
      S.Center_Offset:=B.Center; return S;
   end As_Object;
   function Corners (E : Element; V : Vertex_Array) return MJ.Flex_Kernels.Triangle_Vertices is
     ([V (E.Vertices (0)),V (E.Vertices (1)),V (E.Vertices (2))]);
   function Valid_Array (F : Flex; E : Element_Array; V : Vertex_Array; B : Body_Array) return Boolean is
     (E'Length <= MJ.BVH.Max_Leaves and then E'First=0 and then (for all X of E => Valid (F,X,V,B)));
   function Fits (F : Flex; E : Element_Array; V : Vertex_Array; T : MJ.BVH.Tree) return Boolean is
      Seen : array (Natural range 0 .. MJ.BVH.Max_Leaves-1) of Boolean := [others=>False];
      Box : MJ.BVH.Box;
      Item : Integer;
   begin
      if E'First/=0 or E'Length>MJ.BVH.Max_Leaves then return False; end if;
      for Elem of E loop
         if (for some K in 0 .. F.Dimension => Elem.Vertices (K) not in V'Range
           or else (for some X of V (Elem.Vertices (K)) => X not in Coordinate)) then return False; end if;
      end loop;
      for I in 0 .. T.Length-1 loop
         Item:=T.Nodes (I).Item;
         if Item>=0 then
            if Item not in E'Range then return False; end if;
            Box:=Bounds (F,E (Item),V);
            if not MJ.BVH.Valid (Box) or else not MJ.BVH.Contains (T.Nodes (I).Bounds,Box) then return False; end if;
            Seen (Item):=True;
         end if;
      end loop;
      return (for all I in E'Range => (if Active (F,E (I)) then Seen (I)));
   end Fits;
   procedure Update_Tree (F : Flex; E : Element_Array; V : Vertex_Array;
                          T : in out MJ.BVH.Tree; Rebuild : Boolean; Result : out Status) is
      B : MJ.BVH.Box_Array (E'Range);
   begin
      Result:=Invalid_Input;
      if E'First/=0 or else E'Length>MJ.BVH.Max_Leaves or else (for some X of E =>
        (for some K in 0 .. F.Dimension => X.Vertices (K) not in V'Range or else
          (for some Q of V (X.Vertices (K)) => Q not in -1.0e10 .. 1.0e10))) then T.Length:=0; return; end if;
      if not Rebuild and then T.Length/=(if E'Length=0 then 0 else 2*E'Length-1) then
         T.Length:=0; return;
      end if;
      for I in E'Range loop
         B (I):=Bounds (F,E (I),V);
         if not MJ.BVH.Valid (B (I)) then T.Length:=0; Result:=Numeric_Limit; return; end if;
      end loop;
      if Rebuild then MJ.BVH.Build (B,T,Result); else MJ.BVH.Refit (B,T,Result); end if;
   end Update_Tree;
   procedure Geom_Element (G : Object; PG : Pose; Assets : Vertex_Array;
                           F : Flex; E : Element; V : Vertex_Array; Bodies : Body_Array;
                           Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                           M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph) is
      S : Shape; P : Pose;
      Obj : constant Object := As_Object (F,E,V);
   begin
      M.Length:=0; Result:=Success;
      if not Active (F,E) then return; end if;
      for J in 0 .. F.Dimension loop if Bodies (E.Vertices (J))=G.Rigid.Body_Id then return; end if; end loop;
      if G.Kind=Primitive and G.Rigid.Kind=Plane then
         Result:=Invalid_Input; return; --  Plane uses the batched vertex route.
      end if;
      if F.Dimension=2 and G.Kind=Primitive then
         case G.Rigid.Kind is
            when Sphere => MJ.Flex_Kernels.Sphere_Triangle (PG.Position,G.Rigid.Size (0),Corners (E,V),F.Radius,Margin,M); return;
            when Box => MJ.Flex_Kernels.Box_Triangle (PG,G.Rigid.Size,Corners (E,V),F.Radius,Margin,M); return;
            when Capsule => MJ.Flex_Kernels.Capsule_Triangle (PG,G.Rigid.Size (0),G.Rigid.Size (1),Corners (E,V),F.Radius,Margin,M); return;
            when others => null;
         end case;
      end if;
      if F.Dimension=1 and G.Kind=Primitive and G.Rigid.Kind in Sphere | Capsule | Box then
         MJ.Flex_Kernels.Capsule_From_Segment (V (E.Vertices (0)),V (E.Vertices (1)),F.Radius,S,P);
         if Valid_Shape (S) and Valid_Pose (P) then
            MJ.Primitive_Contacts.Generate (G.Rigid,S,PG,P,Margin,O,W,M,Result); return;
         end if;
      end if;
      if not MJ.Convex_Assets.Valid_Graph (G,Graphs) then Result:=Invalid_Input; return; end if;
      MJ.Convex_Contacts.Generate (G,Obj,PG,Origin,Assets,Margin,O,W,M,Result,Graphs=>Graphs);
      if Result=Success and F.Dimension=2 and G.Kind=Primitive then
         MJ.Flex_Normals.Correct (G.Rigid,PG,M,Result);
      end if;
   end Geom_Element;
   procedure Elements (A : Flex; EA : Element; VA : Vertex_Array; BA : Body_Array;
                       B : Flex; EB : Element; VB : Vertex_Array; BB : Body_Array;
                       Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status) is
      Used_Margin : constant Real := (if A.Id=B.Id then 0.0 else Margin);
      A_Box : constant MJ.BVH.Box := Bounds (A,EA,VA);
      B_Box : constant MJ.BVH.Box := Bounds (B,EB,VB);
      SA, SB : Shape; PA, PB : Pose;
   begin
      M.Length:=0; Result:=Success;
      if not Active (A,EA) or not Active (B,EB) then return; end if;
      if not MJ.BVH.Valid (A_Box) or not MJ.BVH.Valid (B_Box) then Result:=Numeric_Limit; return; end if;
      if not MJ.BVH.Overlap (A_Box,B_Box,Used_Margin) then return; end if;
      for I in 0 .. A.Dimension loop
         for J in 0 .. B.Dimension loop
            if BA (EA.Vertices (I))>=0 and then BA (EA.Vertices (I))=BB (EB.Vertices (J)) then return; end if;
         end loop;
      end loop;
      if A.Dimension=1 and B.Dimension=1 then
         MJ.Flex_Kernels.Capsule_From_Segment (VA (EA.Vertices (0)),VA (EA.Vertices (1)),A.Radius,SA,PA);
         MJ.Flex_Kernels.Capsule_From_Segment (VB (EB.Vertices (0)),VB (EB.Vertices (1)),B.Radius,SB,PB);
         if Valid_Shape (SA) and Valid_Shape (SB) and Valid_Pose (PA) and Valid_Pose (PB) then
            MJ.Primitive_Contacts.Generate (SA,SB,PA,PB,Used_Margin,O,W,M,Result); return;
         end if;
      end if;
      MJ.Convex_Contacts.Generate (As_Object (A,EA,VA),As_Object (B,EB,VB),Origin,Origin,Empty_Vertices,
                                  Used_Margin,O,W,M,Result);
   end Elements;
   procedure Element_Vertex (F : Flex; E : Element; V : Vertex_Array; Vertex : Natural;
                             O : Options; W : in out MJ.Convex_Contacts.Workspace;
                             M : in out Manifold; Result : out Status) is
      S : Shape; P : Pose;
      Point_Obj : Object := (Kind=>Flex_Element,Length=>1,Skin=>F.Radius,others=><>);
      B : MJ.BVH.Box;
   begin
      M.Length:=0; Result:=Invalid_Input;
      if Vertex not in V'Range or else (for some Q of V (Vertex) => Q not in -1.0e10 .. 1.0e10)
        or else (for some K in 0 .. F.Dimension => E.Vertices (K) not in V'Range
          or else (for some Q of V (E.Vertices (K)) => Q not in -1.0e10 .. 1.0e10)) then return; end if;
      B:=Bounds (F,E,V); Result:=Numeric_Limit; if not MJ.BVH.Valid (B) then return; end if;
      Result:=Success; if not MJ.BVH.Sphere_Overlap (V (Vertex),F.Radius,B) then return; end if;
      if F.Dimension=2 then
         MJ.Flex_Kernels.Sphere_Triangle (V (Vertex),F.Radius,Corners (E,V),F.Radius,0.0,M);
         return;
      elsif F.Dimension=1 and F.Radius>0.0 then
         MJ.Flex_Kernels.Capsule_From_Segment (V (E.Vertices (0)),V (E.Vertices (1)),F.Radius,S,P);
         if Valid_Shape (S) and Valid_Pose (P) then
            MJ.Primitive_Contacts.Generate ((Kind=>Sphere,Size=>[F.Radius,0.0,0.0],others=><>),S,
              (Position=>V (Vertex),others=><>),P,0.0,O,W,M,Result); return;
         end if;
      end if;
      Point_Obj.Prism_Vertices:=[others=>V (Vertex)]; Point_Obj.Center_Offset:=V (Vertex);
      MJ.Convex_Contacts.Generate (Point_Obj,As_Object (F,E,V),Origin,Origin,Empty_Vertices,0.0,O,W,M,Result);
   end Element_Vertex;
   procedure Heightfield_Element (H : MJ.Heightfield_Contacts.Heightfield;
                                  Elevation : MJ.Heightfield_Contacts.Elevation_Array;
                                  PH : Pose; F : Flex; E : Element; V : Vertex_Array;
                                  Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                                  M : in out Manifold; Result : out Status) is
   begin
      M.Length:=0; Result:=Invalid_Input;
      if not MJ.Heightfield_Contacts.Valid (H,Elevation) or else not Valid_Pose (PH)
        or else Margin not in 0.0 .. 1.0e10 or else
        (for some K in 0 .. F.Dimension => E.Vertices (K) not in V'Range
          or else (for some Q of V (E.Vertices (K)) => Q not in -1.0e10 .. 1.0e10)) then return; end if;
      declare
         Vertices : Vertex_Array (0 .. F.Dimension);
         B : constant MJ.BVH.Box:=Bounds (F,E,V);
      begin
         for I in Vertices'Range loop Vertices (I):=V (E.Vertices (I)); end loop;
         MJ.Flex_Terrain.Generate (H,Elevation,PH,Vertices,B.Center,F.Radius,Margin,O,W,M,Result);
      end;
   end Heightfield_Element;
   procedure Append (M : Manifold; A, B, VA, VB : Integer; C : in out Batch; Result : out Status) is
   begin
      Result:=Success;
      if M.Length>C.Capacity-C.Length then Result:=Capacity_Limit; return; end if;
      for I in 0 .. M.Length-1 loop
         if not Finite (M.Items (I)) then Result:=Numeric_Limit; return; end if;
         C.Items (C.Length):=(M.Items (I),A,B,VA,VB); C.Length:=C.Length+1;
      end loop;
   end Append;
   procedure Plane (P : Pose; F : Flex; V : Vertex_Array; Margin : Real;
                    C : in out Batch; Result : out Status) is
      Normal : constant Vec := Column (P.Rotation,2);
      D : Real;
   begin
      C.Length:=0; Result:=Invalid_Input;
      if not Valid_Pose (P) or else Margin not in 0.0 .. 1.0e10 or else
        (for some Point of V => (for some Q of Point => Q not in -1.0e10 .. 1.0e10)) then return; end if;
      Result:=Success;
      for I in V'Range loop
         D:=Dot (Sub (V (I),P.Position),Normal);
         if D<=Margin+F.Radius then
            if C.Length=C.Capacity then Result:=Capacity_Limit; C.Length:=0; return; end if;
            C.Items (C.Length):=(Geometry=>(Distance=>D-F.Radius,Normal=>Normal,Tangent=>Zero,
              Position=>Add (V (I),Scale (Normal,-(D-F.Radius)*0.5-F.Radius))),
              Second_Vertex=>I,others=><>); C.Length:=C.Length+1;
         end if;
      end loop;
   end Plane;
   procedure Filter (C : in out Batch; Start : Natural := 0) is
      N : constant Natural := C.Length-Start;
      Selected : array (Natural range 0 .. N-1) of Boolean := [others=>False];
      Min_Dist : array (Natural range 0 .. N-1) of Real := [others=>Max_Val];
      Count : Natural := 0;
      Best, Next : Integer := 0;
      Best_Dist, Next_Dist, D2 : Real;
      Point : Vec;
      Temp : Flex_Contact;
   begin
      if N<=Max_Manifold then return; end if;
      Best_Dist:=-C.Items (Start).Geometry.Distance;
      for I in 1 .. N-1 loop
         if -C.Items (Start+I).Geometry.Distance>Best_Dist then Best_Dist:=-C.Items (Start+I).Geometry.Distance; Best:=I; end if;
      end loop;
      while Count<Max_Manifold and Best>=0 loop
         Selected (Best):=True; Point:=C.Items (Start+Best).Geometry.Position;
         Next:=-1; Next_Dist:=-1.0;
         for I in 0 .. N-1 loop
            if not Selected (I) then
               D2:=Dot (Sub (C.Items (Start+I).Geometry.Position,Point),Sub (C.Items (Start+I).Geometry.Position,Point));
               if D2<Min_Dist (I) then Min_Dist (I):=D2; end if;
               if Min_Dist (I)>Next_Dist then Next_Dist:=Min_Dist (I); Next:=I; end if;
            end if;
         end loop;
         if Count<Max_Manifold-1 then
            Temp:=C.Items (Start+Count); C.Items (Start+Count):=C.Items (Start+Best); C.Items (Start+Best):=Temp;
            if Next=Count then Next:=Best; end if;
         end if;
         Count:=Count+1; Best:=Next;
      end loop;
      C.Length:=Start+Count;
   end Filter;
   procedure Self_Contacts (F : Flex; E : Element_Array; V : Vertex_Array; Bodies : Body_Array;
                            T : MJ.BVH.Tree; Internal_Pairs : Internal_Array;
                            Midphase : Boolean; O : Options;
                            W : in out MJ.Convex_Contacts.Workspace; C : in out Batch; Result : out Status) is
      M : Manifold;
      Pairs : MJ.BVH.Pair_Array (0 .. 65535);
      N, Before : Natural;
      Mask : MJ.Collision_SAP.Mask_Array (E'Range);
      K : Axis := 0;
      Bounds_Array : MJ.BVH.Box_Array (E'Range);
      Hit : Boolean;
      Triangle : MJ.Flex_Kernels.Triangle_Vertices;
      Faces : constant array (Natural range 0 .. 3) of Vertex_Indices :=
        [[0,1,2,3],[0,2,3,1],[0,3,1,2],[1,3,2,0]];
      procedure Test (A,B : Natural) is
      begin
         if A not in E'Range or B not in E'Range then Result:=Invalid_Input; return; end if;
         Elements (F,E (A),V,Bodies,F,E (B),V,Bodies,0.0,O,W,M,Result);
         if Result=Success then Append (M,A,B,-1,-1,C,Result); end if;
      end Test;
   begin
      C.Length:=0; Result:=Invalid_Input;
      if not Valid_Array (F,E,V,Bodies) then return; end if;
      Result:=Success; if F.Rigid or not O.Enabled then return; end if;
      if F.Internal then
         for P of Internal_Pairs loop
            if P.Elem not in E'Range then Result:=Invalid_Input; C.Length:=0; return; end if;
            Element_Vertex (F,E (P.Elem),V,P.Vert,O,W,M,Result);
            if Result=Success then Append (M,P.Elem,-1,-1,P.Vert,C,Result); end if;
            if Result/=Success then C.Length:=0; return; end if;
         end loop;
         if F.Dimension=3 then
            for A in E'Range loop
               for Face of Faces loop
                  for Q in 0 .. 2 loop Triangle (Q):=V (E (A).Vertices (Face (Q))); end loop;
                  MJ.Flex_Kernels.Plane_Vertex (Triangle,V (E (A).Vertices (Face (3))),F.Radius,M.Items (0),Hit);
                  M.Length:=(if Hit then 1 else 0);
                  Append (M,A,-1,-1,E (A).Vertices (Face (3)),C,Result);
                  if Result/=Success then C.Length:=0; return; end if;
               end loop;
            end loop;
         end if;
         Filter (C);
      end if;
      Before:=C.Length;
      if F.Self_Collision=None then return; end if;
      if Midphase and T.Length>0 and (F.Self_Collision=BVH or (F.Self_Collision=Auto and F.Dimension=3)) then
         MJ.BVH.Traverse (T,T,Origin,Origin,0.0,True,False,Pairs,N,Result);
         if Result/=Success then C.Length:=0; return; end if;
         for Q in 0 .. N-1 loop
            Test (Pairs (Q).First,Pairs (Q).Second);
            if Result/=Success then C.Length:=0; return; end if;
         end loop;
      elsif Midphase and T.Length>0 and F.Self_Collision/=Narrow then
         if T.Nodes (0).Bounds.Half (0)>T.Nodes (0).Bounds.Half (1) and
            T.Nodes (0).Bounds.Half (0)>T.Nodes (0).Bounds.Half (2) then K:=0;
         elsif T.Nodes (0).Bounds.Half (1)>T.Nodes (0).Bounds.Half (2) then K:=1; else K:=2; end if;
         for Q in E'Range loop
            Bounds_Array (Q):=Bounds (F,E (Q),V); Mask (Q):=Active (F,E (Q));
         end loop;
         MJ.Collision_SAP.Sweep (Bounds_Array,Mask,K,Pairs,N,Result);
         if Result/=Success then C.Length:=0; return; end if;
         for Q in 0 .. N-1 loop
            Test (Pairs (Q).First,Pairs (Q).Second);
            if Result/=Success then C.Length:=0; return; end if;
         end loop;
      else
         for A in E'Range loop
            for B in A+1 .. E'Last loop
               Test (A,B); if Result/=Success then C.Length:=0; return; end if;
            end loop;
         end loop;
      end if;
      Filter (C,Before);
   end Self_Contacts;
   procedure Flex_Pair (A : Flex; EA : Element_Array; VA : Vertex_Array; BA : Body_Array; TA : MJ.BVH.Tree;
                        B : Flex; EB : Element_Array; VB : Vertex_Array; BB : Body_Array; TB : MJ.BVH.Tree;
                        Midphase : Boolean; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                        C : in out Batch; Result : out Status) is
      M : Manifold;
      Pairs : MJ.BVH.Pair_Array (0 .. 65535);
      N : Natural;
      procedure Test (I,J : Natural) is
      begin
         if I not in EA'Range or J not in EB'Range then Result:=Invalid_Input; return; end if;
         Elements (A,EA (I),VA,BA,B,EB (J),VB,BB,A.Margin+B.Margin+A.Gap+B.Gap,O,W,M,Result);
         if Result=Success then Append (M,I,J,-1,-1,C,Result); end if;
      end Test;
   begin
      C.Length:=0; Result:=Invalid_Input;
      if not Valid_Array (A,EA,VA,BA) or not Valid_Array (B,EB,VB,BB) or A.Id=B.Id then return; end if;
      Result:=Success; if not O.Enabled or not Compatible (A,B) or (A.Rigid and B.Rigid) then return; end if;
      if A.Margin+B.Margin+A.Gap+B.Gap>1.0e10 then Result:=Numeric_Limit; return; end if;
      if Midphase and TA.Length>0 and TB.Length>0 then
         MJ.BVH.Traverse (TA,TB,Origin,Origin,A.Margin+B.Margin+A.Gap+B.Gap,False,False,Pairs,N,Result);
         if Result/=Success then return; end if;
         for Q in 0 .. N-1 loop
            Test (Pairs (Q).First,Pairs (Q).Second); if Result/=Success then C.Length:=0; return; end if;
         end loop;
      else
         for I in EA'Range loop
            for J in EB'Range loop Test (I,J); if Result/=Success then C.Length:=0; return; end if; end loop;
         end loop;
      end if;
      Filter (C);
   end Flex_Pair;
end MJ.Flex_Collisions;

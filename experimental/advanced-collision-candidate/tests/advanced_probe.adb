with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.BVH;
with MJ.SDF_Fields;
with MJ.Builtin_SDF;
with MJ.Builtin_Flex;
with MJ.Flex_Kernels;
with MJ.Flex_Collisions;
with MJ.Convex_Contacts;
with MJ.Heightfield_Contacts;
procedure Advanced_Probe is
   package FC renames MJ.Flex_Collisions;
   package SF renames MJ.SDF_Fields;
   package SD renames MJ.Builtin_SDF;
   W : MJ.Convex_Contacts.Workspace;
   R : Status;
   M : Manifold;
   Command, Kind, Mode, N, N2, Flag, Iterations, Body_ID : Integer;
   S, S2 : Shape;
   PA, PB : Pose;
   V, G : Vec;
   D, Skin, Margin : Real;
   F, F2 : SF.Field;
   procedure Get_R (X : out Real) is begin Ada.Long_Float_Text_IO.Get (X); end Get_R;
   procedure Read_Vec (X : out Vec) is begin for K in Axis loop Get_R (X (K)); end loop; end Read_Vec;
   procedure Read_Pose (P : out Pose) is
   begin Read_Vec (P.Position); for K in P.Rotation'Range loop Get_R (P.Rotation (K)); end loop; P.Asleep:=False; end Read_Pose;
   procedure Read_Box (B : out MJ.BVH.Box) is begin Read_Vec (B.Center); Read_Vec (B.Half); end Read_Box;
   procedure Read_Shape (X : out Shape) is
   begin Get (Kind); X:=(Kind=>Shape_Kind'Val (Kind),others=><>); Read_Vec (X.Size); end Read_Shape;
   procedure Put_R (X : Real) is begin Put (" "); Ada.Long_Float_Text_IO.Put (X,Fore=>1,Aft=>17,Exp=>3); end Put_R;
   procedure Put_V (X : Vec) is begin for Q of X loop Put_R (Q); end loop; end Put_V;
   procedure Header (Count : Natural) is begin Put (Integer'Image (Status'Pos (R)) & Natural'Image (Count)); end Header;
   procedure Output is
   begin
      Header (M.Length);
      for I in 0 .. M.Length-1 loop
         Put_R (M.Items (I).Distance); Put_V (M.Items (I).Position); Put_V (M.Items (I).Normal); Put_V (M.Items (I).Tangent);
      end loop; New_Line;
   end Output;
   procedure Output_Batch (C : FC.Batch) is
   begin
      Header (C.Length);
      for I in 0 .. C.Length-1 loop
         Put_R (C.Items (I).Geometry.Distance); Put_V (C.Items (I).Geometry.Position);
         Put_V (C.Items (I).Geometry.Normal); Put_V (C.Items (I).Geometry.Tangent);
         Put (" "&Integer'Image (C.Items (I).First_Element)&" "&Integer'Image (C.Items (I).Second_Element)
              &" "&Integer'Image (C.Items (I).First_Vertex)&" "&Integer'Image (C.Items (I).Second_Vertex));
      end loop; New_Line;
   end Output_Batch;
   procedure Read_Octree (T : out SF.Octree) is
   begin
      for I in T'Range loop
         Read_Box (T (I).Bounds);
         for J in 0 .. 7 loop Get (T (I).Child (J)); end loop;
         for J in 0 .. 7 loop Get_R (T (I).Coeff (J)); end loop;
      end loop;
   end Read_Octree;
   procedure Read_Flex (X : out FC.Flex; E : out FC.Element; V : out Vertex_Array; B : out FC.Body_Array) is
   begin
      Get (Mode); X.Dimension:=Mode; Get_R (X.Radius); Get (X.Id); E:=(others=><>);
      for I in V'Range loop Read_Vec (V (I)); Get (B (I)); end loop;
      for J in 0 .. X.Dimension loop E.Vertices (J):=J; end loop;
   end Read_Flex;
begin
   while not End_Of_File loop
      Get (Command); R:=Success; M.Length:=0;
      case Command is
         when 1 =>
            Read_Shape (S); Read_Vec (V); Get (Flag);
            F:=(Geometry=>S,others=><>);
            SF.Evaluate (F,SF.Empty_Octree,V,Flag/=0,D,G,R);
            Header (0); Put_R (D); Put_V (G); New_Line;
         when 2 =>
            Get (N); Read_Vec (V); Get (Flag);
            declare T : SF.Octree (0 .. N-1); begin
               Read_Octree (T); F:=(Kind=>SF.Sampled,Length=>N,Bounds=>T (0).Bounds,others=><>);
               if not SF.Valid (F,T) then R:=Invalid_Input; D:=0.0; G:=Zero;
               else SF.Evaluate (F,T,V,Flag/=0,D,G,R); end if;
               Header (0); Put_R (D); Put_V (G); New_Line;
            end;
         when 3 =>
            Read_Shape (S); Read_Pose (PA); Get_R (Skin); Get_R (Margin);
            declare Corners : MJ.Flex_Kernels.Triangle_Vertices; begin
               for I in 0 .. 2 loop Read_Vec (Corners (I)); end loop;
               case S.Kind is
                  when Sphere => MJ.Flex_Kernels.Sphere_Triangle (PA.Position,S.Size (0),Corners,Skin,Margin,M);
                  when Capsule => MJ.Flex_Kernels.Capsule_Triangle (PA,S.Size (0),S.Size (1),Corners,Skin,Margin,M);
                  when Box => MJ.Flex_Kernels.Box_Triangle (PA,S.Size,Corners,Skin,Margin,M);
                  when others => R:=Invalid_Input;
               end case; Output;
            end;
         when 4 =>
            Get (N); Get (N2); Get (Flag); Get (Mode); Get (Iterations); Get_R (Margin); Read_Pose (PA); Read_Pose (PB);
            declare
               A : MJ.BVH.Box_Array (0 .. N-1); B : MJ.BVH.Box_Array (0 .. N2-1);
               TA, TB : MJ.BVH.Tree; Pairs : MJ.BVH.Pair_Array (0 .. 65535); Count : Natural;
            begin
               for X of A loop Read_Box (X); end loop; for X of B loop Read_Box (X); end loop;
               MJ.BVH.Build (A,TA,R); if R/=Success then Header (0); New_Line; else
                  MJ.BVH.Build (B,TB,R);
                  if Iterations/=0 then
                     for X of A loop Read_Box (X); end loop; for X of B loop Read_Box (X); end loop;
                     MJ.BVH.Refit (A,TA,R); MJ.BVH.Refit (B,TB,R);
                  end if;
                  if R=Success then
                     if Flag/=0 then MJ.BVH.Traverse (TA,TA,PA,PA,Margin,True,Mode/=0,Pairs,Count,R);
                     else MJ.BVH.Traverse (TA,TB,PA,PB,Margin,False,Mode/=0,Pairs,Count,R); end if;
                  else Count:=0; end if;
                  Header (Count); for I in 0 .. Count-1 loop Put (Natural'Image (Pairs (I).First)&Natural'Image (Pairs (I).Second)); end loop; New_Line;
               end if;
            end;
         when 5 =>
            Read_Shape (S); Read_Shape (S2); Read_Pose (PA); Get (Mode); Read_Vec (V); Get (Iterations);
            declare P : SD.Problem := (A=>(Geometry=>S,others=><>),B=>(Geometry=>S2,others=><>),Relative=>PA,Kind=>SD.Objective'Val (Mode)); begin
               if Iterations<0 then SD.Evaluate (P,SF.Empty_Octree,V,True,D,G,R); Header (0); Put_R (D); Put_V (G);
               else SD.Descent (P,SF.Empty_Octree,Iterations,V,D,R); Header (0); Put_R (D); Put_V (V); end if; New_Line;
            end;
         when 6 =>
            Read_Shape (S); Read_Shape (S2); Read_Pose (PA); Read_Pose (PB);
            F:=(Geometry=>S,others=><>); F2:=(Geometry=>S2,others=><>); Read_Box (F.Bounds); Read_Box (F2.Bounds);
            Get (N); Get (Iterations); SD.Generate (F,F2,SF.Empty_Octree,PA,PB,(Starts=>N,Iterations=>Iterations),M,R); Output;
         when 7 =>
            Read_Shape (S); Read_Pose (PA); Get (Body_ID); S.Body_Id:=Body_ID; Get (Mode); Get_R (Skin); Get_R (Margin);
            declare
               X : FC.Flex := (Dimension=>Mode,Radius=>Skin,others=><>); E : FC.Element;
               Points : Vertex_Array (0 .. Mode); Bodies : FC.Body_Array (0 .. Mode);
            begin
               for I in Points'Range loop Read_Vec (Points (I)); Get (Bodies (I)); E.Vertices (I):=I; end loop;
               FC.Geom_Element (As_Object (S),PA,Empty_Vertices,X,E,Points,Bodies,Margin,(others=><>),W,M,R); Output;
            end;
         when 8 =>
            Get_R (Margin); Get (N); Get (N2);
            declare
               A,B : FC.Flex; EA,EB : FC.Element;
               VA : Vertex_Array (0 .. N); VB : Vertex_Array (0 .. N2);
               BA : FC.Body_Array (0 .. N); BB : FC.Body_Array (0 .. N2);
            begin
               Read_Flex (A,EA,VA,BA); Read_Flex (B,EB,VB,BB);
               FC.Elements (A,EA,VA,BA,B,EB,VB,BB,Margin,(others=><>),W,M,R); Output;
            end;
         when 9 =>
            Get (Mode); Get_R (Skin);
            declare
               X : FC.Flex := (Dimension=>Mode,Radius=>Skin,others=><>); E : FC.Element;
               Points : Vertex_Array (0 .. Mode+1);
            begin
               for I in Points'Range loop Read_Vec (Points (I)); end loop;
               for I in 0 .. Mode loop E.Vertices (I):=I; end loop;
               FC.Element_Vertex (X,E,Points,Mode+1,(others=><>),W,M,R); Output;
            end;
         when 10 =>
            Read_Pose (PA); Get_R (Skin); Get_R (Margin); Get (N); Get (N2);
            declare X : FC.Flex := (Radius=>Skin,others=><>); Points : Vertex_Array (0 .. N-1); C : FC.Batch (N2); begin
               for Point of Points loop Read_Vec (Point); end loop;
               FC.Plane (PA,X,Points,Margin,C,R); Output_Batch (C);
            end;
         when 11 | 12 =>
            Get (Mode); Get_R (Skin); Get (N); Get (Flag); Get (Body_ID); Get (Iterations); Get (N2);
            declare
               X : FC.Flex := (Dimension=>Mode,Radius=>Skin,Self_Collision=>FC.Self_Mode'Val (Body_ID),Internal=>Iterations/=0,others=><>);
               Elements : FC.Element_Array (0 .. N-1);
               Points : Vertex_Array (0 .. N*(Mode+1)-1); Bodies : FC.Body_Array (Points'Range);
               T : MJ.BVH.Tree; C : FC.Batch (N2);
               Empty : FC.Internal_Array (1 .. 0);
               G : MJ.Builtin_Flex.Collider;
               Empty_H : MJ.Heightfield_Contacts.Elevation_Array (1 .. 0);
            begin
               for I in Points'Range loop Read_Vec (Points (I)); Get (Bodies (I)); end loop;
               for I in Elements'Range loop
                  Get (Elements (I).Layer); for J in 0 .. Mode loop Elements (I).Vertices (J):=I*(Mode+1)+J; end loop;
               end loop;
               FC.Update_Tree (X,Elements,Points,T,True,R);
               if Command=11 then
                  FC.Self_Contacts (X,Elements,Points,Bodies,T,Empty,Flag/=0,(others=><>),W,C,R);
               else
                  Read_Shape (G.Geometry.Rigid); Read_Pose (G.Placement); Get_R (G.Geometry.Rigid.Margin);
                  MJ.Builtin_Flex.Collide (G,Empty_Vertices,Empty_H,X,Elements,Points,Bodies,T,SF.Empty_Octree,Flag/=0,
                      (others=><>),(others=><>),W,C,R);
               end if; Output_Batch (C);
            end;
         when 13 =>
            Get (N); Get (Flag); Read_Pose (PA); Read_Pose (PB); Read_Shape (S); Get (N2); Get (Iterations);
            declare
               Faces : SD.Triangle_Array (0 .. N-1); B : MJ.BVH.Box_Array (Faces'Range); T : MJ.BVH.Tree;
               IDs : SD.Id_Array (0 .. Max_Manifold-1); X : FC.Flex := (Dimension=>2,others=><>);
               E : FC.Element := (Vertices=>[0,1,2,0],others=><>);
            begin
               for I in Faces'Range loop
                  for J in 0 .. 2 loop Read_Vec (Faces (I).Corners (J)); end loop;
                  Faces (I).Id:=I; B (I):=FC.Bounds (X,E,Faces (I).Corners);
               end loop;
               MJ.BVH.Build (B,T,R); F:=(Geometry=>S,others=><>);
               SD.Triangles (F,SF.Empty_Octree,Faces,T,PA,PB,SD.Triangle_Path'Val (Flag),
                  (Starts=>N2,Iterations=>Iterations),M,IDs,R); Output;
            end;
         when 14 =>
            Get (Mode); Get_R (Skin); Get_R (Margin); Read_Pose (PA); Get (N); Get (N2);
            declare
               H : MJ.Heightfield_Contacts.Heightfield:= (Rows=>N,Columns=>N2,others=><>);
               Elevation : MJ.Heightfield_Contacts.Elevation_Array (0 .. N*N2-1);
               X : FC.Flex := (Dimension=>Mode,Radius=>Skin,others=><>);
               E : FC.Element;
               Points : Vertex_Array (0 .. Mode);
            begin
               Get_R (H.Half_X); Get_R (H.Half_Y); Get_R (H.Height); Get_R (H.Base);
               for V of Elevation loop Get_R (V); end loop;
               for I in Points'Range loop Read_Vec (Points (I)); E.Vertices (I):=I; end loop;
               FC.Heightfield_Element (H,Elevation,PA,X,E,Points,Margin,(others=><>),W,M,R); Output;
            end;
         when others => raise Program_Error;
      end case;
   end loop;
end Advanced_Probe;

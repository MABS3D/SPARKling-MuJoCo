with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.BVH;
with MJ.SDF_Fields;
with MJ.Flex_Collisions;
with MJ.Flex_Support;
with MJ.Collision_SAP;
with MJ.Rigid_Math;
with MJ.Convex_Contacts;
with MJ.SDF_Collisions;
with Ada.Text_IO;
procedure Advanced_Checks is
   T : MJ.BVH.Tree;
   B : MJ.BVH.Box_Array (0 .. 2) := [others=>(Center=>Zero,Half=>[1.0,1.0,1.0])];
   Pairs : MJ.BVH.Pair_Array (1 .. 0);
   Count : Natural;
   R : Status;
   F : MJ.Flex_Collisions.Flex := (Dimension=>2,Radius=>0.01,others=><>);
   E : MJ.Flex_Collisions.Element_Array (0 .. 0) := [(Vertices=>[0,1,2,0],others=><>)];
   V : Vertex_Array (0 .. 2):=[[0.0,0.0,0.0],[1.0,0.0,0.0],[0.0,1.0,0.0]];
   procedure Check (OK : Boolean) is begin if not OK then raise Program_Error; end if; end Check;
   --  Exercise native Ada callback dispatch, failure and numerical admission.
   procedure Provider (Key : Natural; X : Vec; Need_Gradient : Boolean;
                       Value : out Real; Gradient : out Vec; Result : out Status) is
   begin
      Value:=X (2); Gradient:=(if Need_Gradient then [0.0,0.0,1.0] else Zero); Result:=Success;
      if Key=1 then Result:=Invalid_Input;
      elsif Key=2 then Value:=1.0e200; end if;
   end Provider;
   package Custom_SDF is new MJ.SDF_Collisions (Provider);
begin
   Check (MJ.BVH.Valid (T));
   MJ.Flex_Collisions.Update_Tree (F,E,V,T,False,R); Check (R=Invalid_Input and T.Length=0);
   MJ.BVH.Build (B,T,R); Check (R=Success and then MJ.BVH.Valid (T));
   MJ.BVH.Traverse (T,T,(others=><>),(others=><>),0.0,True,False,Pairs,Count,R);
   Check (R=Capacity_Limit and Count=0);
   T.Nodes (0).Left:=0; Check (not MJ.BVH.Valid (T));
   MJ.BVH.Build (B,T,R); T.Nodes (0).Right:=T.Nodes (0).Left; Check (not MJ.BVH.Valid (T));
   MJ.Flex_Collisions.Update_Tree (F,E,V,T,True,R); Check (R=Success and then MJ.Flex_Collisions.Fits (F,E,V,T));
   V (0):=[100.0,0.0,0.0]; Check (not MJ.Flex_Collisions.Fits (F,E,V,T));
   MJ.Flex_Collisions.Update_Tree (F,E,V,T,False,R); Check (R=Success and then MJ.Flex_Collisions.Fits (F,E,V,T));
   Check (MJ.Flex_Support.Select_Vertex (V,[1.0,0.0,0.0])=0);
   Check (MJ.Flex_Support.Select_Vertex (V,Zero)=0);
   F.Dimension:=3; F.Active_Layers:=1;
   Check (MJ.Flex_Collisions.Active (F,(Layer=>0,others=><>)));
   Check (not MJ.Flex_Collisions.Active (F,(Layer=>1,others=><>)));
   declare
      Mask : MJ.Collision_SAP.Mask_Array (B'Range):=[others=>True];
      PB : MJ.BVH.Pair_Array (0 .. 9);
   begin
      MJ.Collision_SAP.Sweep (B,Mask,0,PB,Count,R); Check (R=Success and Count=3);
      Mask:=[others=>False]; MJ.Collision_SAP.Sweep (B,Mask,0,PB,Count,R); Check (R=Success and Count=0);
   end;
   declare
      Problem : Custom_SDF.Problem := (A=>(Kind=>MJ.SDF_Fields.Custom,others=><>),others=><>);
      Value : Real; Gradient : Vec;
   begin
      Custom_SDF.Evaluate (Problem,MJ.SDF_Fields.Empty_Octree,[1.0,2.0,3.0],True,Value,Gradient,R);
      Check (R=Success and Value=3.0 and Gradient=[0.0,0.0,1.0]);
      Problem.A.Key:=1;
      Custom_SDF.Evaluate (Problem,MJ.SDF_Fields.Empty_Octree,Zero,True,Value,Gradient,R);
      Check (R=Invalid_Input);
      Problem.A.Key:=2;
      Custom_SDF.Evaluate (Problem,MJ.SDF_Fields.Empty_Octree,Zero,True,Value,Gradient,R);
      Check (R=Numeric_Limit and Value=0.0 and Gradient=Zero);
   end;
   declare
      A : MJ.Flex_Collisions.Flex := (Id=>1,Dimension=>1,Radius=>0.03,others=><>);
      B : MJ.Flex_Collisions.Flex := (Id=>2,Dimension=>1,Radius=>0.03,others=><>);
      EA : MJ.Flex_Collisions.Element_Array (0 .. 0) := [(Vertices=>[0,1,0,0],others=><>)];
      VA : Vertex_Array (0 .. 1) := [[-0.1,0.0,0.0],[0.1,0.0,0.0]];
      VB : Vertex_Array (0 .. 1) := [[-0.1,0.0,0.02],[0.1,0.0,0.02]];
      BA : MJ.Flex_Collisions.Body_Array (0 .. 1):=[1,2];
      BB : MJ.Flex_Collisions.Body_Array (0 .. 1):=[3,4];
      TA,TB : MJ.BVH.Tree;
      W : MJ.Convex_Contacts.Workspace;
      C : MJ.Flex_Collisions.Batch (100);
      N : Natural;
   begin
      MJ.Flex_Collisions.Update_Tree (A,EA,VA,TA,True,R); Check (R=Success);
      MJ.Flex_Collisions.Update_Tree (B,EA,VB,TB,True,R); Check (R=Success);
      MJ.Flex_Collisions.Flex_Pair (A,EA,VA,BA,TA,B,EA,VB,BB,TB,False,(others=><>),W,C,R);
      Check (R=Success and C.Length>0); N:=C.Length;
      MJ.Flex_Collisions.Flex_Pair (A,EA,VA,BA,TA,B,EA,VB,BB,TB,True,(others=><>),W,C,R);
      Check (R=Success and C.Length=N and (for all I in 0 .. C.Length-1 => Finite (C.Items (I).Geometry)));
      BB (0):=BA (0);
      MJ.Flex_Collisions.Flex_Pair (A,EA,VA,BA,TA,B,EA,VB,BB,TB,True,(others=><>),W,C,R);
      Check (R=Success and C.Length=0); BB (0):=3;
      A.Contype:=0; A.Conaffinity:=0;
      MJ.Flex_Collisions.Flex_Pair (A,EA,VA,BA,TA,B,EA,VB,BB,TB,True,(others=><>),W,C,R);
      Check (R=Success and C.Length=0);
   end;
   --  Property checks for cancellation, degeneracy, subnormals and domain limits.
   --  The oracle is containment of both input endpoints, not the union formula.
   declare
      Centers : constant array (Natural range <>) of Real :=
        [-1.0e10, -1.0e5, -1.0, -1.0e-300, 0.0, 1.0e-300, 1.0, 1.0e5, 1.0e10];
      Halves : constant array (Natural range <>) of Real :=
        [0.0, Real'Succ (0.0), 1.0e-20, 1.0e-5, 1.0, 1.0e5, 1.0e10];
      A, B, U : MJ.BVH.Box;
      Cases : Natural := 0;
   begin
      for CA of Centers loop
         for CB of Centers loop
            for HA of Halves loop
               for HB of Halves loop
                  A := (Center => [CA, -CA, CA], Half => [HA, 0.0, HA]);
                  B := (Center => [CB, CB, -CB], Half => [HB, HB, 0.0]);
                  U := MJ.BVH.Union_Box (A, B);
                  Check (MJ.BVH.Contains (U, A) and MJ.BVH.Contains (U, B));
                  Check (for all K in Axis => U.Center (K) in -6.0e10 .. 6.0e10
                    and U.Half (K) in 0.0 .. 1.0e11);
                  Cases := Cases + 1;
               end loop;
            end loop;
         end loop;
      end loop;
      Ada.Text_IO.Put_Line ("BVH union boundary cases:" & Natural'Image (Cases));
   end;
   Ada.Text_IO.Put_Line ("checks passed");
end Advanced_Checks;

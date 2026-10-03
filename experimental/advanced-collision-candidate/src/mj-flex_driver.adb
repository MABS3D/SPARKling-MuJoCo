with MJ.Rigid_Math; use MJ.Rigid_Math;
with Interfaces;
with MJ.Convex_Assets;
package body MJ.Flex_Driver with SPARK_Mode is
   use type Interfaces.Unsigned_32;
   procedure Collide (G : Collider; Assets : Vertex_Array;
                      Elevation : MJ.Heightfield_Contacts.Elevation_Array;
                      F : Flex; E : Element_Array; V : Vertex_Array; Bodies : Body_Array;
                      T : MJ.BVH.Tree; Samples : MJ.SDF_Fields.Octree;
                      Midphase : Boolean; O : Options; Search : SDF.Search_Options;
                      W : in out MJ.Convex_Contacts.Workspace; C : in out Batch; Result : out Status;
                      Graphs : Graph_Array := Empty_Graph) is
      M : Manifold;
      Margin : constant Real := ((G.Geometry.Rigid.Margin+F.Margin)+G.Geometry.Rigid.Gap)+F.Gap;
      Faces : SDF.Triangle_Array (E'Range);
      IDs : SDF.Id_Array (0 .. Max_Manifold-1);
      type Stack_Array is array (Natural range 0 .. MJ.BVH.Max_Nodes-1) of Natural with Relaxed_Initialization;
      Stack : Stack_Array;
      Top, Node : Natural;
      Cache : MJ.BVH.Frame_Cache;
      Bound : MJ.BVH.Box;
      Shape_Size : constant Vec := G.Geometry.Rigid.Size;
      Hit : Boolean;
      Lo, Hi, Direction, Support : Vec := Zero;
      Vertex_ID, Support_Cache : Integer:= -1;
      Origin : constant Pose := (others=><>);
      procedure Test (I : Natural) is
      begin
         if I not in E'Range then Result:=Invalid_Input; return; end if;
         if not Active (F,E (I)) then return; end if;
         if G.Kind=Terrain_Geom then
            MJ.Flex_Collisions.Heightfield_Element (G.Terrain,Elevation,G.Placement,F,E (I),V,Margin,O,W,M,Result);
         else
            MJ.Flex_Collisions.Geom_Element (G.Geometry,G.Placement,Assets,F,E (I),V,Bodies,Margin,O,W,M,Result,Graphs);
         end if;
         if Result/=Success then return; end if;
         if M.Length>C.Capacity-C.Length then Result:=Capacity_Limit; return; end if;
         for K in 0 .. M.Length-1 loop
            if not Finite (M.Items (K)) then Result:=Numeric_Limit; return; end if;
            C.Items (C.Length):=(Geometry=>M.Items (K),Second_Element=>I,others=><>); C.Length:=C.Length+1;
         end loop;
      end Test;
   begin
      C.Length:=0; Result:=Invalid_Input;
      if E'First/=0 or else E'Length>MJ.BVH.Max_Leaves or else not Valid_Pose (G.Placement)
        or else (for some Elem of E => not Valid (F,Elem,V,Bodies)) then return; end if;
      if G.Kind=Rigid_Geom and then not Valid_Object (G.Geometry,Assets) then return; end if;
      if G.Kind=Terrain_Geom and then not MJ.Heightfield_Contacts.Valid (G.Terrain,Elevation) then return; end if;
      if G.Kind=SDF_Geom and then not Fields_Admitted
        and then not MJ.SDF_Fields.Valid (G.Field,Samples) then return; end if;
      Result:=Success;
      if not O.Enabled or else ((G.Geometry.Rigid.Contype and F.Conaffinity)=0 and
        (F.Contype and G.Geometry.Rigid.Conaffinity)=0) then return; end if;
      if Margin>1.0e10 then Result:=Numeric_Limit; return; end if;
      if G.Kind=SDF_Geom then
         if F.Dimension/=2 then return; end if; --  Same scope as C 3.14.
         for I in E'Range loop
            for K in 0 .. 2 loop Faces (I).Corners (K):=V (E (I).Vertices (K)); end loop;
            Faces (I).Id:=I;
         end loop;
         SDF.Triangles (G.Field,Samples,Faces,T,Origin,G.Placement,
           (if T.Length=0 then SDF.Linear_Flex elsif Midphase then SDF.Tree_Flex
            else SDF.Tree_Flex_Zero_Bounds),Search,M,IDs,Result);
         if Result/=Success then return; end if;
         if M.Length>C.Capacity then Result:=Capacity_Limit; return; end if;
         for I in 0 .. M.Length-1 loop
            C.Items (I):=(Geometry=>M.Items (I),Second_Element=>IDs (I),others=><>);
         end loop; C.Length:=M.Length; return;
      end if;
      if G.Kind=Rigid_Geom and G.Geometry.Kind=Primitive and G.Geometry.Rigid.Kind=Plane then
         MJ.Flex_Collisions.Plane (G.Placement,F,V,Margin,C,Result);
         if Result=Success then MJ.Flex_Collisions.Filter (C); end if; return;
      end if;
      if G.Kind=Terrain_Geom then Bound:=(Center=>[0.0,0.0,0.5*(G.Terrain.Height-G.Terrain.Base)],
          Half=>[G.Terrain.Half_X,G.Terrain.Half_Y,0.5*(G.Terrain.Height+G.Terrain.Base)]);
      elsif G.Geometry.Kind=Primitive then
         case G.Geometry.Rigid.Kind is
            when Sphere => Bound:=(Center=>Zero,Half=>[others=>Shape_Size (0)]);
            when Capsule | Cylinder => Bound:=(Center=>Zero,Half=>[Shape_Size (0),Shape_Size (0),Shape_Size (1)+(if G.Geometry.Rigid.Kind=Capsule then Shape_Size (0) else 0.0)]);
            when others => Bound:=(Center=>Zero,Half=>Shape_Size);
         end case;
      else
         if not MJ.Convex_Assets.Valid_Graph (G.Geometry,Graphs) then Result:=Invalid_Input; return; end if;
         for K in Axis loop
            Direction:=Zero; Direction (K):=1.0;
            MJ.Convex_Contacts.Support_Cached (G.Geometry,Origin,Assets,Direction,Graphs,Support_Cache,Support,Vertex_ID); Hi (K):=Support (K);
            Direction (K):= -1.0;
            MJ.Convex_Contacts.Support_Cached (G.Geometry,Origin,Assets,Direction,Graphs,Support_Cache,Support,Vertex_ID); Lo (K):=Support (K);
            Bound.Center (K):=0.5*(Hi (K)+Lo (K));
            Bound.Half (K):=0.5*(Hi (K)-Lo (K))+32.0*Real'Model_Epsilon*Real'Max (1.0,Real'Max (abs Lo (K),abs Hi (K)));
         end loop;
      end if;
      if not MJ.BVH.Valid (Bound) then Result:=Numeric_Limit; return; end if;
      if Midphase and T.Length>0 then
         MJ.BVH.Prepare (G.Placement,Origin,Cache); Stack (0):=0; Top:=1;
         while Top>0 loop
            pragma Loop_Invariant (for all I in 0 .. Top-1 => Stack (I)'Initialized);
            Top:=Top-1; Node:=Stack (Top);
            Hit:=MJ.BVH.Oriented_Overlap (Bound,T.Nodes (Node).Bounds,Cache,Margin);
            if Hit then
               if T.Nodes (Node).Item>=0 then Test (T.Nodes (Node).Item);
               else Stack (Top):=T.Nodes (Node).Left; Stack (Top+1):=T.Nodes (Node).Right; Top:=Top+2; end if;
               if Result/=Success then C.Length:=0; return; end if;
            end if;
         end loop;
      else
         for I in E'Range loop Test (I); if Result/=Success then C.Length:=0; return; end if; end loop;
      end if;
      MJ.Flex_Collisions.Filter (C);
   end Collide;
end MJ.Flex_Driver;

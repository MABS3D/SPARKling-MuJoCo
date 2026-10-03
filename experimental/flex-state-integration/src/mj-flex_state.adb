with Interfaces; use type Interfaces.Unsigned_8; use type Interfaces.Unsigned_32;
with MJ.Flex_State_Kernels;
with MJ.Smooth_Math;
with MJ.SDF_Fields;
with MJ.Heightfield_Contacts;
package body MJ.Flex_State with SPARK_Mode is
   use type RG.Status;
   package K renames MJ.Flex_State_Kernels;
   package SM renames MJ.Smooth_Math;
   function Flag (Flags, Bit : Integer) return Boolean is ((Flags / Bit) mod 2 = 1);
   function Failure (R : RG.Status) return Status is
     (if R=RG.Capacity_Limit then Capacity_Limit elsif R=RG.Invalid_Input then Invalid_Input else Numeric_Limit);
   function Vector_At (A : Real_Array; I : Natural) return RG.Vec is
     ([A (3*I), A (3*I+1), A (3*I+2)]);
   function Material_At (Priority, Dim : Int_Array; Mix, Ref, Imp, Fri : Real_Array;
                         I : Natural) return CP.Material is
     (Priority => Priority (I), Dim => Dim (I), Mix => Mix (I),
      Ref => [Ref (2*I), Ref (2*I+1)],
      Imp => [for J in 0 .. 4 => Imp (5*I+J)],
      Fri => [for J in 0 .. 2 => Fri (3*I+J)], Adhesion => 0.0);
   procedure Free (S : in out State) is
   begin
      S.Initialized := False; S.Positions_Current := False;
      S.Nf := 0; S.Ng := 0; S.Nb := 0; S.Group.Length := 0;
   end Free;
   procedure Create (M : MJ.Models.Model; S : in out State; Result : out Status) is
   begin
      Result := Already_Allocated;
      if Ready (S) then return; end if;
      Free (S); Result := Invalid_Model;
      if not MJ.Models.Sizes_In_Range (M.S)
        or else not MJ.Models.Flex_Layout_OK (M.S,M.Flexes)
        or else not MJ.Models.Geom_Layout_OK (M.S,M.Geoms)
        or else not MJ.Models.Body_Layout_OK (M.S,M.Bodies) then return; end if;
      if M.S.Nflex > Max_Flex or M.S.Nbody not in 1 .. Max_Bodies
        or M.S.Ngeom > Max_Geometries then Result := Capacity_Limit; return; end if;
      if M.S.Nplugin /= 0 or M.S.Nmocap /= 0 or M.S.Npair /= 0 or M.S.Nexclude /= 0
        or M.Opt.Enableflags /= 0 or M.Flg_Adhesion then Result := Unsupported_Feature; return; end if;
      S.Nf := M.S.Nflex; S.Ng := M.S.Ngeom; S.Nb := M.S.Nbody;
      S.Midphase := not Flag (M.Opt.Disableflags,16384);
      S.Options := (Enabled => not Flag (M.Opt.Disableflags,16),
        Tolerance => M.Opt.Ccd_Tolerance, Iterations => M.Opt.Ccd_Iterations, others => <>);
      for F in 0 .. S.Nf-1 loop
         declare
            B : Flex_Block renames S.Flexes (F);
            Vadr : constant Integer := M.Flexes.Flex_Vertadr (F);
            Eadr : constant Integer := M.Flexes.Flex_Elemadr (F);
            Data : constant Integer := M.Flexes.Flex_Elemdataadr (F);
            Iadr : constant Integer := M.Flexes.Flex_Evpairadr (F);
            Dim : constant Integer := M.Flexes.Flex_Dim (F);
         begin
            if M.Flexes.Flex_Interp (F) /= 0 then Result := Unsupported_Feature; Free (S); return; end if;
            if Dim not in 1 .. 3 or M.Flexes.Flex_Vertnum (F) not in 1 .. Max_Vertices
              or M.Flexes.Flex_Elemnum (F) not in 0 .. Max_Elements
              or M.Flexes.Flex_Evpairnum (F) not in 0 .. Max_Elements
              or M.Flexes.Flex_Condim (F) not in 1 | 3 | 4 | 6
              or M.Flexes.Flex_Selfcollide (F) not in 0 .. 4
              or M.Flexes.Flex_Activelayers (F) < 0
              or M.Flexes.Flex_Centered (F) > 1 or M.Flexes.Flex_Rigid (F) > 1
              or M.Flexes.Flex_Internal (F) > 1
              or M.Flexes.Flex_Radius (F) not in 0.0 .. 1.0e10
              or M.Flexes.Flex_Margin (F) not in 0.0 .. 1.0e10
              or M.Flexes.Flex_Gap (F) not in 0.0 .. 1.0e10 then Free (S); return; end if;
            B.Nv := M.Flexes.Flex_Vertnum (F); B.Ne := M.Flexes.Flex_Elemnum (F);
            B.Ni := M.Flexes.Flex_Evpairnum (F); B.Tree.Length := 0;
            if Vadr not in 0 .. M.S.Nflexvert-B.Nv
              or Eadr not in 0 .. M.S.Nflexelem-B.Ne
              or (B.Ne > 0 and then Data not in 0 .. M.S.Nflexelemdata-B.Ne*(Dim+1))
              or (B.Ni > 0 and then Iadr not in 0 .. M.S.Nflexevpair-B.Ni) then Free (S); return; end if;
            B.Centered := M.Flexes.Flex_Centered (F) /= 0;
            B.Description := (Id=>F, Dimension=>Dim, Radius=>M.Flexes.Flex_Radius (F),
              Margin=>M.Flexes.Flex_Margin (F), Gap=>M.Flexes.Flex_Gap (F),
              Contype=>Interfaces.Unsigned_32'Mod (M.Flexes.Flex_Contype (F)),
              Conaffinity=>Interfaces.Unsigned_32'Mod (M.Flexes.Flex_Conaffinity (F)),
              Active_Layers=>M.Flexes.Flex_Activelayers (F),
              Self_Collision=>FC.Self_Mode'Val (M.Flexes.Flex_Selfcollide (F)),
              Rigid=>M.Flexes.Flex_Rigid (F) /= 0, Internal=>M.Flexes.Flex_Internal (F) /= 0);
            B.Material := Material_At (M.Flexes.Flex_Priority.all,M.Flexes.Flex_Condim.all,
              M.Flexes.Flex_Solmix.all,M.Flexes.Flex_Solref.all,M.Flexes.Flex_Solimp.all,
              M.Flexes.Flex_Friction.all,F);
            if not CP.Valid (B.Material) then Free (S); return; end if;
            for V in 0 .. B.Nv-1 loop
               B.Bodies (V) := M.Flexes.Flex_Vertbodyid (Vadr+V);
               B.Local (V) := Vector_At (M.Flexes.Flex_Vert.all,Vadr+V);
               B.World (V) := RG.Zero;
               if B.Bodies (V) not in 0 .. S.Nb-1
                 or (for some X of B.Local (V) => X not in RG.Coordinate) then Free (S); return; end if;
            end loop;
            for E in 0 .. B.Ne-1 loop
               B.Elements (E) := (Layer=>M.Flexes.Flex_Elemlayer (Eadr+E),others=><>);
               for J in 0 .. Dim loop
                  if M.Flexes.Flex_Elem (Data+E*(Dim+1)+J) not in 0 .. B.Nv-1 then Free (S); return; end if;
                  B.Elements (E).Vertices (J) := M.Flexes.Flex_Elem (Data+E*(Dim+1)+J);
               end loop;
            end loop;
            for I in 0 .. B.Ni-1 loop
               if M.Flexes.Flex_Evpair (2*(Iadr+I)) not in 0 .. B.Ne-1
                 or M.Flexes.Flex_Evpair (2*(Iadr+I)+1) not in 0 .. B.Nv-1 then Free (S); return; end if;
               B.Internal (I) := (M.Flexes.Flex_Evpair (2*(Iadr+I)),M.Flexes.Flex_Evpair (2*(Iadr+I)+1));
            end loop;
         end;
      end loop;
      for G in 0 .. S.Ng-1 loop
         declare
            B : Geom_Block renames S.Geoms (G);
            Kind : constant Integer := M.Geoms.Geom_Type (G);
            Q : constant SM.Quaternion := [for I in 0 .. 3 => M.Geoms.Geom_Quat (4*G+I)];
            R : SM.Matrix;
         begin
            if Kind not in 0 | 2 .. 6 then Result := Unsupported_Feature; Free (S); return; end if;
            if M.Geoms.Geom_Bodyid (G) not in 0 .. S.Nb-1
              or M.Geoms.Geom_Condim (G) not in 1 | 3 | 4 | 6
              or M.Geoms.Geom_Margin (G) not in 0.0 .. 1.0e10
              or M.Geoms.Geom_Gap (G) not in 0.0 .. 1.0e10
              or not SM.Unit_Quaternion (Q) then Free (S); return; end if;
            B.Body_Id := M.Geoms.Geom_Bodyid (G);
            B.Local.Position := Vector_At (M.Geoms.Geom_Pos.all,G);
            R := SM.Rotation (Q);
            for I in RG.Axis loop
               for J in RG.Axis loop B.Local.Rotation (3*I+J) := R (I,J); end loop;
            end loop;
            if not RG.Valid_Pose (B.Local) then Free (S); return; end if;
            B.Collider.Kind := MJ.Builtin_Flex.Rigid_Geom;
            B.Collider.Geometry := (Kind=>CG.Primitive, Rigid=>
              (Kind=>RG.Shape_Kind'Val ((if Kind=0 then 0 else Kind-1)),
               Size=>Vector_At (M.Geoms.Geom_Size.all,G), Body_Id=>B.Body_Id,
               Margin=>M.Geoms.Geom_Margin (G), Gap=>M.Geoms.Geom_Gap (G),
               Contype=>Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Contype (G)),
               Conaffinity=>Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Conaffinity (G)), others=><>),others=><>);
            if not RG.Valid_Shape (B.Collider.Geometry.Rigid) then Free (S); return; end if;
            B.Material := Material_At (M.Geoms.Geom_Priority.all,M.Geoms.Geom_Condim.all,
              M.Geoms.Geom_Solmix.all,M.Geoms.Geom_Solref.all,M.Geoms.Geom_Solimp.all,
              M.Geoms.Geom_Friction.all,G);
            if not CP.Valid (B.Material) then Free (S); return; end if;
         end;
      end loop;
      S.Initialized := True; Result := Success;
   exception
      when Constraint_Error => Free (S); Result := Invalid_Model;
   end Create;
   procedure Update (S : in out State; Bodies : RG.Pose_Array; Result : out Status;
                     Geometries : RG.Pose_Array := [1 .. 0 => <>]) is
      R : RG.Status;
   begin
      Result := Not_Allocated; if not Ready (S) then return; end if;
      S.Positions_Current := False; Result := Invalid_Input;
      if Bodies'First /= 0 or Bodies'Length /= S.Nb
        or (for some P of Bodies => not RG.Valid_Pose (P)) then return; end if;
      if Geometries'Length /= 0 and then
        (Geometries'First /= 0 or else Geometries'Length /= S.Ng
         or else (for some P of Geometries => not RG.Valid_Pose (P))) then return; end if;
      Result := Numeric_Limit;
      for F in 0 .. S.Nf-1 loop
         declare B : Flex_Block renames S.Flexes (F); begin
            for V in 0 .. B.Nv-1 loop
               B.Candidate (V) := K.Point (Bodies (B.Bodies (V)),B.Local (V),B.Centered);
               if (for some X of B.Candidate (V) => X not in RG.Coordinate) then return; end if;
            end loop;
         end;
      end loop;
      for G in 0 .. S.Ng-1 loop
         declare B : Geom_Block renames S.Geoms (G); begin
            S.Geom_Candidate (G) := (if Geometries'Length > 0 then Geometries (G)
              else (Position=>K.Point (Bodies (B.Body_Id),B.Local.Position,False),
              Rotation=>K.Compose (Bodies (B.Body_Id).Rotation,B.Local.Rotation),Asleep=>Bodies (B.Body_Id).Asleep));
            if not RG.Valid_Pose (S.Geom_Candidate (G)) then return; end if;
         end;
      end loop;
      for F in 0 .. S.Nf-1 loop
         declare B : Flex_Block renames S.Flexes (F); begin
            FC.Update_Tree (B.Description,B.Elements (0 .. B.Ne-1),B.Candidate (0 .. B.Nv-1),
              B.Tree,B.Tree.Length=0,R);
            if R /= RG.Success then Result := Failure (R); return; end if;
         end;
      end loop;
      for F in 0 .. S.Nf-1 loop
         declare B : Flex_Block renames S.Flexes (F); begin
            B.World (0 .. B.Nv-1) := B.Candidate (0 .. B.Nv-1);
         end;
      end loop;
      for G in 0 .. S.Ng-1 loop S.Geoms (G).Collider.Placement := S.Geom_Candidate (G); end loop;
      S.Positions_Current := True; Result := Success;
   end Update;
   procedure Detect (S : in out State; Contacts : in out Contact_List; Result : out Status) is
      N : Natural := 0;
      R : RG.Status;
      Samples : MJ.SDF_Fields.Octree (1 .. 0);
      -- C only suppresses self-collision for rigid flexes. Distinct rigid
      -- flexes still collide; the isolated candidate's both-rigid early exit
      -- therefore cannot be used at this Model/Data boundary.
      procedure Cross (F,Q : Natural; R : out RG.Status) is
         A : Flex_Block renames S.Flexes (F);
         B : Flex_Block renames S.Flexes (Q);
         Pairs : MJ.BVH.Pair_Array (0 .. 65535);
         Count : Natural;
         M : CG.Manifold;
         Origin : constant RG.Pose := (others=><>);
         Margin : constant Real := ((A.Description.Margin+B.Description.Margin)
           +A.Description.Gap)+B.Description.Gap;
         procedure Test (I,J : Natural) is
         begin
            FC.Elements (A.Description,A.Elements (I),A.World (0 .. A.Nv-1),A.Bodies (0 .. A.Nv-1),
              B.Description,B.Elements (J),B.World (0 .. B.Nv-1),B.Bodies (0 .. B.Nv-1),
              Margin,S.Options,S.Work,M,R);
            if R/=RG.Success then return; end if;
            if M.Length>S.Group.Capacity-S.Group.Length then R:=RG.Capacity_Limit; return; end if;
            for K in 0 .. M.Length-1 loop
               S.Group.Items (S.Group.Length) := (Geometry=>M.Items (K),
                 First_Element=>I,Second_Element=>J,others=><>);
               S.Group.Length := S.Group.Length+1;
            end loop;
         end Test;
      begin
         S.Group.Length := 0; R := RG.Success;
         if not FC.Compatible (A.Description,B.Description) then return; end if;
         if Margin not in 0.0 .. 1.0e10 then R:=RG.Numeric_Limit; return; end if;
         if S.Midphase and A.Tree.Length>0 and B.Tree.Length>0 then
            MJ.BVH.Traverse (A.Tree,B.Tree,Origin,Origin,Margin,False,False,Pairs,Count,R);
            if R/=RG.Success then return; end if;
            for K in 0 .. Count-1 loop
               Test (Pairs (K).First,Pairs (K).Second);
               if R/=RG.Success then S.Group.Length:=0; return; end if;
            end loop;
         else
            for I in 0 .. A.Ne-1 loop
               for J in 0 .. B.Ne-1 loop
                  Test (I,J); if R/=RG.Success then S.Group.Length:=0; return; end if;
               end loop;
            end loop;
         end if;
         FC.Filter (S.Group);
      end Cross;
      procedure Append (G, F1, F2 : Integer; Mixed : CP.Parameters; Margin, Gap : Real) is
         P : CP.Parameters := Mixed;
      begin
         CP.Configure (P,Margin,Gap,(others=><>));
         if S.Group.Length > Contacts.Capacity-N or S.Group.Length > Max_Contacts-N then
            Result := Capacity_Limit; return;
         end if;
         for I in 0 .. S.Group.Length-1 loop
            declare C : FC.Flex_Contact renames S.Group.Items (I); begin
               S.Pending (N) := (Geometry=>C.Geometry,Geom=>G,Flex_First=>F1,Flex_Second=>F2,
                 Elem_First=>C.First_Element,Elem_Second=>C.Second_Element,
                 Vert_First=>C.First_Vertex,Vert_Second=>C.Second_Vertex,Parameters=>P);
               if F1 = F2 and (C.First_Vertex >= 0 or C.Second_Vertex >= 0) then
                  S.Pending (N).Parameters.Dim := 1;
               end if;
               N := N+1;
            end;
         end loop;
      end Append;
   begin
      Contacts.Length := 0; Result := Not_Allocated; if not Ready (S) then return; end if;
      Result := Stale_State; if not Current (S) then return; end if;
      Result := Success; if not S.Options.Enabled then return; end if;
      for F in 0 .. S.Nf-1 loop
         declare B : Flex_Block renames S.Flexes (F); begin
            if (B.Description.Contype and B.Description.Conaffinity) /= 0 then
               FC.Self_Contacts (B.Description,B.Elements (0 .. B.Ne-1),B.World (0 .. B.Nv-1),
                 B.Bodies (0 .. B.Nv-1),B.Tree,B.Internal (0 .. B.Ni-1),S.Midphase,
                 S.Options,S.Work,S.Group,R);
               if R /= RG.Success then Result := Failure (R); return; end if;
               Append (-1,F,F,CP.Combine (B.Material,B.Material),0.0,0.0);
               if Result /= Success then return; end if;
            end if;
            for G in 0 .. S.Ng-1 loop
               MJ.Builtin_Flex.Collide (S.Geoms (G).Collider,CG.Empty_Vertices,
                 MJ.Heightfield_Contacts.Elevation_Array'(1 .. 0 => 0.0),
                 B.Description,B.Elements (0 .. B.Ne-1),B.World (0 .. B.Nv-1),
                 B.Bodies (0 .. B.Nv-1),B.Tree,Samples,S.Midphase,S.Options,
                 (others=><>),S.Work,S.Group,R);
               if R /= RG.Success then Result := Failure (R); return; end if;
               Append (G,-1,F,CP.Combine (S.Geoms (G).Material,B.Material),
                 S.Geoms (G).Collider.Geometry.Rigid.Margin+B.Description.Margin,
                 S.Geoms (G).Collider.Geometry.Rigid.Gap+B.Description.Gap);
               if Result /= Success then return; end if;
            end loop;
            for Q in F+1 .. S.Nf-1 loop
               declare A : Flex_Block renames S.Flexes (Q); begin
                  Cross (F,Q,R);
                  if R /= RG.Success then Result := Failure (R); return; end if;
                  Append (-1,F,Q,CP.Combine (B.Material,A.Material),B.Description.Margin+A.Description.Margin,
                    B.Description.Gap+A.Description.Gap);
                  if Result /= Success then return; end if;
               end;
            end loop;
         end;
      end loop;
      Contacts.Items (1 .. N) := S.Pending (0 .. N-1); Contacts.Length := N;
   end Detect;
end MJ.Flex_State;

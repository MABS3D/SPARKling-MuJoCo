with MJ.Models.Validity;
with MJ.Smooth_Math;
with MJ.Quaternion_Math;
package body MJ.Rays with SPARK_Mode is
   use type MJ.Ray_Geometry.Kind;
   package G renames MJ.Ray_Geometry;
   package SM renames MJ.Smooth_Math;
   function Read_V (A : Real_Array; Offset : Natural) return Vector is
     ([A (Offset), A (Offset+1), A (Offset+2)]);
   function Read_R (A : Real_Array; Offset : Natural) return Matrix is
      R : constant SM.Matrix := SM.Rotation
        (SM.Read_Quaternion (A, Offset));
   begin return [for I in Axis => [for J in Axis => R (I,J)]]; end Read_R;
   procedure Clear (S : in out Scene) is
   begin S.Initialized:=False; S.Ng:=0; S.Nb:=0; S.Posed_Bodies:=0; end Clear;
   procedure Initialize (M : MJ.Models.Model; S : in out Scene; State : out Status) is
   begin
      if S.Initialized then State:=Already_Ready; return; end if;
      Clear (S); State:=Invalid_Model;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      if M.S.Nbody>Max_Bodies or else M.S.Ngeom>Max_Geometries or else M.S.Nmesh>Max_Assets or else M.S.Nhfield>Max_Assets
        or else M.S.Nmeshvert>Max_Vertices or else M.S.Nmeshface>Max_Faces
        or else M.S.Nbvhstatic>Max_Nodes or else M.S.Nhfielddata>Max_Heights
      then State:=Capacity_Exceeded; return; end if;
      for B in 0 .. M.S.Nbody-1 loop S.First_Geom (B):=-1; S.Posed (B):=False; end loop;
      for I in 0 .. M.S.Ngeom-1 loop
         if M.Geoms.Geom_Type (I) not in 0 .. 7 then State:=Unsupported_Feature; return; end if;
         declare
            X : Geometry renames S.Shapes (I);
            Mat : constant Integer := M.Geoms.Geom_Matid (I);
         begin
            X.Shape:=G.Kind'Val (M.Geoms.Geom_Type (I));
            X.Body_Id:=M.Geoms.Geom_Bodyid (I); X.Weld_Id:=M.Bodies.Body_Weldid (X.Body_Id);
            S.Next_Geom (I):=S.First_Geom (X.Body_Id); S.First_Geom (X.Body_Id):=I;
            X.Group_Id:=M.Geoms.Geom_Group (I); X.Data_Id:=M.Geoms.Geom_Dataid (I);
            X.Size:=Read_V (M.Geoms.Geom_Size.all,3*I);
            X.Local_Position:=Read_V (M.Geoms.Geom_Pos.all,3*I);
            X.Local_Rotation:=Read_R (M.Geoms.Geom_Quat.all,4*I);
            X.Visible:=(if Mat<0 then M.Geoms.Geom_Rgba (4*I+3)/=0.0 else M.Materials.Mat_Rgba (4*Mat+3)/=0.0);
            if not (for all V of X.Local_Position => V in -1.0e10 .. 1.0e10)
              or else not (for all V of X.Size => V in 0.0 .. 1.0e10)
              or else (X.Shape=G.Ellipsoid and then (for some V of X.Size => V<1.0e-10))
            then State:=Numeric_Limit; return; end if;
         end;
      end loop;
      for I in 0 .. M.S.Nmeshvert-1 loop
         S.Points (I):=[for J in Axis => Real (M.Meshes.Mesh_Vert (3*I+J))];
         if not (for all V of S.Points (I) => V in -1.0e10 .. 1.0e10) then State:=Numeric_Limit; return; end if;
      end loop;
      for I in 0 .. M.S.Nmeshface-1 loop S.Triangles (I):=[for J in Axis => M.Meshes.Mesh_Face (3*I+J)]; end loop;
      for I in 0 .. M.S.Nmesh-1 loop
         S.Mesh_Data (I):=(M.Meshes.Mesh_Faceadr (I), M.Meshes.Mesh_Vertadr (I),
           M.Meshes.Mesh_Bvhadr (I),M.Meshes.Mesh_Bvhnum (I));
      end loop;
      for I in 0 .. M.S.Nbvhstatic-1 loop
         S.Tree (I):=(M.Bvh.Bvh_Child (2*I),M.Bvh.Bvh_Child (2*I+1),M.Bvh.Bvh_Nodeid (I),
           Read_V (M.Bvh.Bvh_Aabb.all,6*I),Read_V (M.Bvh.Bvh_Aabb.all,6*I+3));
      end loop;
      for I in 0 .. M.S.Nhfield-1 loop
         S.Terrain_Data (I):=(M.Hfields.Hfield_Nrow (I),M.Hfields.Hfield_Ncol (I),
           M.Hfields.Hfield_Adr (I),Read_V (M.Hfields.Hfield_Size.all,4*I),M.Hfields.Hfield_Size (4*I+3));
         if S.Terrain_Data (I).Rows<2 or else S.Terrain_Data (I).Columns<2
           or else (for some V of S.Terrain_Data (I).Size => V not in 1.0e-10 .. 1.0e10)
           or else S.Terrain_Data (I).Base_Depth not in 1.0e-10 .. 1.0e10
         then State:=Numeric_Limit; return; end if;
      end loop;
      for I in 0 .. M.S.Nhfielddata-1 loop
         S.Elevations (I):=Real (M.Hfields.Hfield_Data (I));
         if S.Elevations (I) not in 0.0 .. 1.0 then State:=Numeric_Limit; return; end if;
      end loop;
      S.Ng:=M.S.Ngeom; S.Nb:=M.S.Nbody; S.Initialized:=True; State:=Success;
   exception
      when Constraint_Error => Clear (S); State:=Invalid_Model;
   end Initialize;
   procedure Set_Body_Pose (S : in out Scene; Body_Id : Natural;
                            Position : Vector; Rotation : Matrix) is
      I : Integer;
   begin
      if not S.Initialized or else Body_Id>=S.Nb then raise Constraint_Error with "ray body index"; end if;
      if not (for all V of Position => V in -1.0e10 .. 1.0e10)
        or else not (for all J in Axis => (for all K in Axis => Rotation (J,K) in -16.0 .. 16.0))
      then raise Constraint_Error with "ray pose numeric domain"; end if;
      I:=S.First_Geom (Body_Id);
      while I>=0 loop
            declare X : Geometry renames S.Shapes (I); V : constant Vector:=G.Rotate (Rotation,X.Local_Position);
            begin
               X.Position:=[for J in Axis => Position (J)+V (J)];
               X.Rotation:=[for J in Axis => [for K in Axis =>
                 (Rotation (J,0)*X.Local_Rotation (0,K)+Rotation (J,1)*X.Local_Rotation (1,K))
                  + Rotation (J,2)*X.Local_Rotation (2,K)]];
            end;
         I:=S.Next_Geom (I);
      end loop;
      if not S.Posed (Body_Id) then S.Posed (Body_Id):=True; S.Posed_Bodies:=S.Posed_Bodies+1; end if;
   end Set_Body_Pose;
   function Mesh_Hit (S : Scene; X : Geometry; Point, Direction : Vector) return G.Hit is
      Info : constant Mesh_Info:=S.Mesh_Data (X.Data_Id);
      Stack : array (0 .. Max_Tree_Depth-1) of Integer := [others => 0];
      Nstack : Natural:=1;
      P : constant Vector:=G.Map (X.Rotation,[for I in Axis => Point (I)-X.Position (I)]);
      V : constant Vector:=G.Map (X.Rotation,Direction);
      B0,B1 : Vector; Result, Candidate : G.Hit; T : G.Triangle;
      Current, F : Integer;
   begin
      if G.Intersect (G.Box,X.Position,X.Rotation,X.Size,Point,Direction).Distance<0.0 then return Result; end if;
      G.Basis (V,B0,B1);
      while Nstack>0 loop
         Nstack:=Nstack-1; Current:=Stack (Nstack)+Info.Node_Start;
         if G.Slab (S.Tree (Current).Center,S.Tree (Current).Half_Size,P,V) then
            if S.Tree (Current).Face_Id>=0 then
               F:=Info.Face_Start+S.Tree (Current).Face_Id;
               T:=[for I in Axis => S.Points (Info.Vertex_Start+S.Triangles (F) (I))];
               Candidate:=G.Intersect_Triangle (T,P,V,B0,B1);
               if Better (Candidate.Distance,Result.Distance) then Result:=Candidate; end if;
            else
               for Child of Face'(S.Tree (Current).Child_0,S.Tree (Current).Child_1,-1) loop
                  if Child>=0 then Stack (Nstack):=Child; Nstack:=Nstack+1; end if;
               end loop;
            end if;
         end if;
      end loop;
      if Result.Distance>=0.0 then Result.Normal:=G.Rotate (X.Rotation,Result.Normal); end if;
      return Result;
   end Mesh_Hit;
   function Terrain_Hit (S : Scene; X : Geometry; Point, Direction : Vector) return G.Hit is
      H : constant Terrain_Info:=S.Terrain_Data (X.Data_Id);
      Base_Position, Top_Position : Vector;
      Result, Top, Candidate : G.Hit; All_Faces : G.Face_Hits;
      P,V,B0,B1,N : Vector; T : G.Triangle;
      Lo,Hi,DX,DY,Z,Y,Y0,Z0,Z1 : Real;
      SX,SY : array (0 .. 1) of Real;
      Rmin,Rmax,Cmin,Cmax,L,Col,Row : Integer;
      function Vertex (R,C : Integer) return Vector is
        ([DX*Real (C)-H.Size (0),DY*Real (R)-H.Size (1),S.Elevations (H.Start+R*H.Columns+C)*H.Size (2)]);
   begin
      Base_Position:=[for I in Axis => X.Position (I)-X.Rotation (I,2)*H.Base_Depth*0.5];
      Result:=G.Intersect (G.Box,Base_Position,X.Rotation,[H.Size (0),H.Size (1),H.Base_Depth*0.5],Point,Direction);
      Top_Position:=[for I in Axis => X.Position (I)+X.Rotation (I,2)*H.Size (2)*0.5];
      G.Box_Faces (Top_Position,X.Rotation,[H.Size (0),H.Size (1),H.Size (2)*0.5],Point,Direction,Top,All_Faces);
      if Top.Distance<0.0 then return Result; end if;
      P:=G.Map (X.Rotation,[for I in Axis => Point (I)-X.Position (I)]); V:=G.Map (X.Rotation,Direction);
      G.Basis (V,B0,B1);
      N:=(if Result.Distance>=0.0 then G.Map (X.Rotation,Result.Normal) else Zero);
      Lo:=0.0; Hi:=Top.Distance;
      for F of All_Faces loop if F>Hi then Lo:=Top.Distance; Hi:=F; end if; end loop;
      DX:=(2.0*H.Size (0))/Real (H.Columns-1); DY:=(2.0*H.Size (1))/Real (H.Rows-1);
      for I in 0 .. 1 loop
         SX (I):=(Along (P (0),V (0),(if I=0 then Lo else Hi))+H.Size (0))/DX;
         SY (I):=(Along (P (1),V (1),(if I=0 then Lo else Hi))+H.Size (1))/DY;
      end loop;
      Cmin:=Integer'Max (0,Integer (Real'Floor (Real'Min (SX (0),SX (1))))-1);
      Cmax:=Integer'Min (H.Columns-1,Integer (Real'Ceiling (Real'Max (SX (0),SX (1))))+1);
      Rmin:=Integer'Max (0,Integer (Real'Floor (Real'Min (SY (0),SY (1))))-1);
      Rmax:=Integer'Min (H.Rows-1,Integer (Real'Ceiling (Real'Max (SY (0),SY (1))))+1);
      for R in Rmin .. Rmax-1 loop
         for C in Cmin .. Cmax-1 loop
            T:=[Vertex (R,C),Vertex (R,C+1),Vertex (R+1,C+1)];
            Candidate:=G.Intersect_Triangle (T,P,V,B0,B1);
            if Better (Candidate.Distance,Result.Distance) then Result:=Candidate; N:=Candidate.Normal; end if;
            T:=[Vertex (R,C),Vertex (R+1,C+1),Vertex (R+1,C)];
            Candidate:=G.Intersect_Triangle (T,P,V,B0,B1);
            if Better (Candidate.Distance,Result.Distance) then Result:=Candidate; N:=Candidate.Normal; end if;
         end loop;
      end loop;
      for I in 0 .. 3 loop
         if Better (All_Faces (I),Result.Distance) then
            Z:=Along (P (2),V (2),All_Faces (I))/H.Size (2);
            if I<2 then
               Y:=(Along (P (1),V (1),All_Faces (I))+H.Size (1))/DY;
               Y0:=Real'Max (0.0,Real'Min (Real (H.Rows-2),Real'Floor (Y)));
               L:=Integer (Y0); Col:=(if I=1 then H.Columns-1 else 0);
               Z0:=S.Elevations (H.Start+L*H.Columns+Col); Z1:=S.Elevations (H.Start+(L+1)*H.Columns+Col);
            else
               Y:=(Along (P (0),V (0),All_Faces (I))+H.Size (0))/DX;
               Y0:=Real'Max (0.0,Real'Min (Real (H.Columns-2),Real'Floor (Y)));
               L:=Integer (Y0); Row:=(if I=3 then H.Rows-1 else 0);
               Z0:=S.Elevations (H.Start+Row*H.Columns+L); Z1:=S.Elevations (H.Start+Row*H.Columns+L+1);
            end if;
            if Z<Z0*(Y0+1.0-Y)+Z1*(Y-Y0) then
               Result.Distance:=All_Faces (I); N:=Zero;
               N (I/2):=(if I mod 2=0 then -1.0 else 1.0);
            end if;
         end if;
      end loop;
      if Result.Distance>=0.0 then Result.Normal:=G.Rotate (X.Rotation,N); end if;
      return Result;
   end Terrain_Hit;
   procedure Cast (S : Scene; Point, Direction : Vector; Hit : out Result;
                   State : out Status; Filter : Options := (others => <>)) is
      Best : Result; Candidate : G.Hit;
   begin
      Hit:=(others => <>); State:=Not_Ready;
      if not S.Initialized or else S.Posed_Bodies/=S.Nb then return; end if;
      State:=Invalid_Ray;
      if not (for all V of Point => V in -1.0e10 .. 1.0e10)
        or else not (for all V of Direction => V in -1.0e10 .. 1.0e10)
        or else MJ.Quaternion_Math.Sqrt (Dot (Direction,Direction))<Min_Val or else Filter.Cutoff<0.0
      then return; end if;
      for I in 0 .. Integer (S.Ng)-1 loop
         declare X : Geometry renames S.Shapes (I);
         begin
            if Eligible (X.Body_Id,X.Weld_Id,X.Group_Id,Filter.Excluded_Body,
              X.Visible,Filter.Include_Static,Filter.Filter_Groups,Filter.Mask) then
               Candidate:=(case X.Shape is
                 when G.Mesh => Mesh_Hit (S,X,Point,Direction),
                 when G.Heightfield => Terrain_Hit (S,X,Point,Direction),
                 when others => G.Intersect (X.Shape,X.Position,X.Rotation,X.Size,Point,Direction));
               if Candidate.Distance<=Filter.Cutoff and then Better (Candidate.Distance,Best.Distance) then
                  Best:=(Candidate.Distance,I,Candidate.Normal);
               end if;
            end if;
         end;
      end loop;
      Hit:=Best; State:=Success;
   exception
      when Constraint_Error => Hit:=(others => <>); State:=Numeric_Limit;
   end Cast;
   procedure Cast_Many (S : Scene; Point : Vector; Vectors : Directions;
                        Hits : out Results; State : out Status; Filter : Options := (others => <>)) is
      One : Status;
   begin
      Hits:=[others => (others => <>)]; State:=Invalid_Ray;
      if Hits'Length/=Vectors'Length then return; end if;
      if not S.Initialized or else S.Posed_Bodies/=S.Nb then State:=Not_Ready; return; end if;
      for I in Vectors'Range loop
         --  Match mj_multiRay's squared-norm gate (different from mj_ray).
         if (for all V of Vectors (I) => V in -1.0e10 .. 1.0e10)
           and then Dot (Vectors (I),Vectors (I))<Min_Val then
            One:=Success;
         else
            Cast (S,Point,Vectors (I),Hits (Hits'First+I-Vectors'First),One,Filter);
         end if;
         if One/=Success then Hits:=[others => (others => <>)]; State:=One; return; end if;
      end loop;
      State:=(if Ready (S) then Success else Not_Ready);
   end Cast_Many;
end MJ.Rays;

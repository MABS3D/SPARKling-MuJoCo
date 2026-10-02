with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.Flex_Terrain with SPARK_Mode is
   procedure Generate (H : Heightfield; Elevation : Elevation_Array; P : Pose;
                       Vertices : Vertex_Array; Center : Vec; Radius, Margin : Real;
                       O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status) is
      Origin : constant Pose:=(others=><>);
      Elem : Object:=(Kind=>Flex_Element,Length=>Vertices'Length,Skin=>Radius,others=><>);
      Prism_Obj : Object:=(Kind=>Prism,others=><>);
      Lo,Hi,Q : Vec;
      CMin,CMax,RMin,RMax : Integer;
      DX : constant Real:=2.0*H.Half_X/Real (H.Columns-1);
      DY : constant Real:=2.0*H.Half_Y/Real (H.Rows-1);
      Trial : Manifold;
      function Grid (X,Half : Real; N : Natural; Upper : Boolean) return Integer is
         T : constant Real:=((X+Half)/(2.0*Half))*Real (N-1);
      begin
         if T<=0.0 then return 0; elsif T>=Real (N-1) then return N-1;
         else return Integer ((if Upper then Real'Ceiling (T) else Real'Floor (T))); end if;
      end Grid;
      procedure Add_Vertex (Row,Col,Which : Natural) is
         X : constant Real:=DX*Real (Col)-H.Half_X;
         Y : constant Real:=DY*Real (Row+1-Which)-H.Half_Y;
         Z : constant Real:=Elevation (Elevation'First+(Row+1-Which)*H.Columns+Col)*H.Height+Margin;
      begin
         Prism_Obj.Prism_Vertices (0):=Prism_Obj.Prism_Vertices (1);
         Prism_Obj.Prism_Vertices (1):=Prism_Obj.Prism_Vertices (2);
         Prism_Obj.Prism_Vertices (3):=Prism_Obj.Prism_Vertices (4);
         Prism_Obj.Prism_Vertices (4):=Prism_Obj.Prism_Vertices (5);
         Prism_Obj.Prism_Vertices (2):=[X,Y,-H.Base]; Prism_Obj.Prism_Vertices (5):=[X,Y,Z];
      end Add_Vertex;
   begin
      M.Length:=0; Result:=Success;
      for I in Vertices'Range loop
         Q:=Local (P.Rotation,Sub (Vertices (I),P.Position));
         if (for some X of Q => X not in Coordinate) then Result:=Numeric_Limit; return; end if;
         Elem.Prism_Vertices (I-Vertices'First):=Q;
      end loop;
      Elem.Center_Offset:=Local (P.Rotation,Sub (Center,P.Position));
      Lo:=Elem.Prism_Vertices (0); Hi:=Lo;
      for I in 1 .. Vertices'Length-1 loop
         for K in Axis loop Lo (K):=Real'Min (Lo (K),Elem.Prism_Vertices (I)(K)); Hi (K):=Real'Max (Hi (K),Elem.Prism_Vertices (I)(K)); end loop;
      end loop;
      if Lo (0)-Margin>H.Half_X or Hi (0)+Margin< -H.Half_X
        or Lo (1)-Margin>H.Half_Y or Hi (1)+Margin< -H.Half_Y
        or Lo (2)-Margin>H.Height or Hi (2)+Margin< -H.Base then return; end if;
      CMin:=Grid (Lo (0),H.Half_X,H.Columns,False); CMax:=Grid (Hi (0),H.Half_X,H.Columns,True);
      RMin:=Grid (Lo (1),H.Half_Y,H.Rows,False); RMax:=Grid (Hi (1),H.Half_Y,H.Rows,True);
      for Row in RMin .. RMax-1 loop
         Add_Vertex (Row,CMin,0); Add_Vertex (Row,CMin,1);
         for Col in CMin+1 .. CMax loop
            for Which in 0 .. 1 loop
               Add_Vertex (Row,Col,Which);
               if Prism_Obj.Prism_Vertices (3)(2)>=Lo (2) or Prism_Obj.Prism_Vertices (4)(2)>=Lo (2) or Prism_Obj.Prism_Vertices (5)(2)>=Lo (2) then
                  Prism_Obj.Center_Offset:=Zero;
                  for K in 0 .. 5 loop Prism_Obj.Center_Offset:=Add (Prism_Obj.Center_Offset,Prism_Obj.Prism_Vertices (K)); end loop;
                  Prism_Obj.Center_Offset:=Scale (Prism_Obj.Center_Offset,1.0/6.0);
                  MJ.Convex_Contacts.Generate (Prism_Obj,Elem,Origin,Origin,Empty_Vertices,Margin,O,W,Trial,Result,
                    Inflation1=>0.0,Inflation2=>Margin,Output_Margin=>0.0);
                  if Result/=Success then M.Length:=0; return; end if;
                  if Trial.Length>0 then
                     M.Items (M.Length):=Trial.Items (0);
                     M.Items (M.Length).Normal:=Transform (P.Rotation,Trial.Items (0).Normal);
                     M.Items (M.Length).Position:=Add (P.Position,Transform (P.Rotation,Trial.Items (0).Position));
                     M.Length:=M.Length+1; if M.Length=Max_Manifold then return; end if;
                  end if;
               end if;
            end loop;
         end loop;
      end loop;
   end Generate;
end MJ.Flex_Terrain;

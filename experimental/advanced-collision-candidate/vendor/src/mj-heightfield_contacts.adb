--  MuJoCo's subgrid traversal and rolling triangular prisms.  No temporary
--  combined mesh pool or allocation is needed for each terrain triangle.
with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.Heightfield_Contacts with SPARK_Mode is
   procedure Generate (H : Heightfield; E : Elevation_Array; PH : Pose;
                       B : Object; PB : Pose; V : Vertex_Array;
                       Margin : Real; O : Options; W : in out MJ.Convex_Contacts.Workspace;
                       M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph) is
      P : Pose;
      Origin : constant Pose := (Position => Zero, Rotation => Identity, others => <>);
      Prism_Obj : Object := (Kind => Prism, others => <>);
      Dir, Point, Lo, Hi : Vec;
      Id : Integer; Cache : Integer := -1;
      CMin, CMax, RMin, RMax : Integer;
      DX : constant Real := 2.0*H.Half_X/Real (H.Columns-1);
      DY : constant Real := 2.0*H.Half_Y/Real (H.Rows-1);
      Trial : Manifold;
      function Grid (X, Half : Real; N : Natural; Upper : Boolean) return Integer is
         T : constant Real := ((X+Half)/(2.0*Half))*Real (N-1);
      begin
         if T <= 0.0 then return 0; elsif T >= Real (N-1) then return N-1;
         else return Integer ((if Upper then Real'Ceiling (T) else Real'Floor (T))); end if;
      end Grid;
      procedure Add_Vertex (Row, Col, Which : Natural) is
         X : constant Real := DX*Real (Col)-H.Half_X;
         Y : constant Real := DY*Real (Row+1-Which)-H.Half_Y;
         Z : constant Real := E (E'First+(Row+1-Which)*H.Columns+Col)*H.Height+Margin;
      begin
         Prism_Obj.Prism_Vertices (0) := Prism_Obj.Prism_Vertices (1);
         Prism_Obj.Prism_Vertices (1) := Prism_Obj.Prism_Vertices (2);
         Prism_Obj.Prism_Vertices (3) := Prism_Obj.Prism_Vertices (4);
         Prism_Obj.Prism_Vertices (4) := Prism_Obj.Prism_Vertices (5);
         Prism_Obj.Prism_Vertices (2) := [X, Y, -H.Base]; Prism_Obj.Prism_Vertices (5) := [X, Y, Z];
      end Add_Vertex;
   begin
      M.Length := 0; Result := Success;
      P.Position := Local (PH.Rotation, Sub (PB.Position, PH.Position));
      for I in Axis loop for J in Axis loop
         P.Rotation (3*I+J) := Dot (Column (PH.Rotation, I), Column (PB.Rotation, J));
      end loop; end loop;
      for I in Axis loop
         Dir := Zero; Dir (I) := 1.0; MJ.Convex_Contacts.Support_Cached (B, P, V, Dir, Graphs, Cache, Point, Id); Hi (I) := Point (I);
         Dir (I) := -1.0; MJ.Convex_Contacts.Support_Cached (B, P, V, Dir, Graphs, Cache, Point, Id); Lo (I) := Point (I);
      end loop;
      if Lo (0)-Margin > H.Half_X or Hi (0)+Margin < -H.Half_X
        or Lo (1)-Margin > H.Half_Y or Hi (1)+Margin < -H.Half_Y
        or Lo (2)-Margin > H.Height or Hi (2)+Margin < -H.Base then return; end if;
      CMin := Grid (Lo (0), H.Half_X, H.Columns, False); CMax := Grid (Hi (0), H.Half_X, H.Columns, True);
      RMin := Grid (Lo (1), H.Half_Y, H.Rows, False); RMax := Grid (Hi (1), H.Half_Y, H.Rows, True);
      for Row in RMin .. RMax-1 loop
         Add_Vertex (Row, CMin, 0); Add_Vertex (Row, CMin, 1);
         for Col in CMin+1 .. CMax loop
            for Which in 0 .. 1 loop
               Add_Vertex (Row, Col, Which);
               if Prism_Obj.Prism_Vertices (3) (2) >= Lo (2) or Prism_Obj.Prism_Vertices (4) (2) >= Lo (2) or Prism_Obj.Prism_Vertices (5) (2) >= Lo (2) then
                  Prism_Obj.Center_Offset := Zero;
                  for K in 0 .. 5 loop Prism_Obj.Center_Offset := Add (Prism_Obj.Center_Offset, Prism_Obj.Prism_Vertices (K)); end loop;
                  Prism_Obj.Center_Offset := Scale (Prism_Obj.Center_Offset, 1.0/6.0);
                  MJ.Convex_Contacts.Generate (Prism_Obj, B, Origin, P, V, Margin, O, W, Trial, Result,
                    Inflation1 => 0.0, Inflation2 => Margin, Output_Margin => 0.0, Graphs => Graphs);
                  if Result /= Success then M.Length := 0; return; end if;
                  if Trial.Length > 0 then
                     M.Items (M.Length) := Trial.Items (0);
                     M.Items (M.Length).Normal := Transform (PH.Rotation, Trial.Items (0).Normal);
                     M.Items (M.Length).Position := Add (PH.Position, Transform (PH.Rotation, Trial.Items (0).Position));
                     M.Length := M.Length+1;
                     --  Native mjMAXCONPAIR cap is part of terrain semantics.
                     if M.Length = Max_Manifold then return; end if;
                  end if;
               end if;
            end loop;
         end loop;
      end loop;
   end Generate;
end MJ.Heightfield_Contacts;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Command_Line;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Convex_Contacts;
with MJ.Convex_Assets;
with MJ.Primitive_Contacts;
with MJ.Advanced_Contacts;
with MJ.Heightfield_Contacts;
with MJ.Contact_Parameters;
with MJ.Full_Contacts;
with MJ.Collision_Contacts;
with MJ.Contact_Incidence;

procedure Contact_Probe is
   Objects : array (0 .. 1) of Object;
   Poses : Pose_Array (0 .. 1);
   Vertices : Vertex_Array (0 .. 8191);
   NV, NF, NG : Natural;
   Graphs : Graph_Array (0 .. 65535);
   Facets : Facet_Array (0 .. 8191);
   HF : MJ.Heightfield_Contacts.Heightfield;
   Elevation : MJ.Heightfield_Contacts.Elevation_Array (0 .. 65535);
   W : MJ.Convex_Contacts.Workspace;
   M : Manifold;
   Full : MJ.Full_Contacts.Full_Manifold;
   Params : MJ.Contact_Parameters.Parameters := MJ.Contact_Parameters.Default_Parameters;
   O : Options;
   Result : Status;
   Incidence : MJ.Contact_Incidence.Lookup;
   Incidence_Result : Status;
   Mode, Repeats, K, Count : Integer;
   Margin, Checksum, Original_X : Long_Float;
   Offsets : constant array (Natural range 0 .. 15) of Long_Float :=
     [0.0, 0.0003, 0.001, 0.0006, -0.0002, -0.001, -0.0007, 0.0002,
      0.0008, 0.0001, -0.0005, -0.0009, 0.0004, 0.0009, -0.0003, -0.0006];
   Start, Finish : Time;
   Reuse_Mesh : Boolean;
   procedure Real_Out (X : Long_Float) is
   begin
      Put (" "); Ada.Long_Float_Text_IO.Put (X, Fore => 1, Aft => 16, Exp => 3);
   end Real_Out;
begin
   --  Match the compiled model's CCD budget when diagnosing integrated
   --  trajectories; the historical standalone fixtures keep their default.
   if Ada.Command_Line.Argument_Count >= 1 then
      O.Iterations := Positive'Value (Ada.Command_Line.Argument (1));
   end if;
   if Ada.Command_Line.Argument_Count >= 2 then
      O.Tolerance := Long_Float'Value (Ada.Command_Line.Argument (2));
   end if;
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (Mode); Ada.Integer_Text_IO.Get (Repeats);
      Ada.Long_Float_Text_IO.Get (Margin); NV := 0; NF := 0; NG := 0; Reuse_Mesh := False;
      for I in 0 .. 1 loop
         Objects (I) := (others => <>);
         Ada.Integer_Text_IO.Get (K);
         if K = 7 then
            Objects (I).Kind := Hull;
         elsif K in 6 | 8 then Objects (I).Kind := Hull;
         else Objects (I).Rigid.Kind := Shape_Kind'Val (K); end if;
         for J in Axis loop Ada.Long_Float_Text_IO.Get (Objects (I).Rigid.Size (J)); end loop;
         for J in Axis loop Ada.Long_Float_Text_IO.Get (Poses (I).Position (J)); end loop;
         for J in 0 .. 8 loop Ada.Long_Float_Text_IO.Get (Poses (I).Rotation (J)); end loop;
         Ada.Long_Float_Text_IO.Get (Objects (I).Skin);
         Ada.Integer_Text_IO.Get (Count); Objects (I).First := NV; Objects (I).Length := Count;
         if K = 7 then
            Ada.Integer_Text_IO.Get (Count); HF.Rows := Count;
            Ada.Integer_Text_IO.Get (Count); HF.Columns := Count;
            Ada.Long_Float_Text_IO.Get (HF.Half_X); Ada.Long_Float_Text_IO.Get (HF.Half_Y);
            Ada.Long_Float_Text_IO.Get (HF.Height); Ada.Long_Float_Text_IO.Get (HF.Base);
            for J in 0 .. HF.Rows*HF.Columns-1 loop Ada.Long_Float_Text_IO.Get (Elevation (J)); end loop;
            Count := 0;
         end if;
         for J in 1 .. Count loop
            for C in Axis loop Ada.Long_Float_Text_IO.Get (Vertices (NV) (C)); end loop;
            NV := NV+1;
         end loop;
         Ada.Integer_Text_IO.Get (Count); Objects (I).First_Facet := NF; Objects (I).Facet_Count := Count;
         for J in 1 .. Count loop
            for C in Axis loop Ada.Long_Float_Text_IO.Get (Facets (NF).Normal (C)); end loop;
            Ada.Integer_Text_IO.Get (Count); Facets (NF).Length := Count;
            for C in 0 .. Count-1 loop Ada.Integer_Text_IO.Get (Count); Facets (NF).Indices (C) := Objects (I).First+Count; end loop;
            NF := NF+1;
         end loop;
         Ada.Integer_Text_IO.Get (Count); Objects (I).First_Graph := NG; Objects (I).Graph_Length := Count;
         if Count > 0 then
            for C in 0 .. 26 loop Ada.Integer_Text_IO.Get (Count); Objects (I).Extrema (C) := Count; end loop;
            for C in 1 .. Objects (I).Graph_Length loop Ada.Integer_Text_IO.Get (Count); Graphs (NG) := Count; NG := NG+1; end loop;
         end if;
         if K = 8 then
            if I /= 1 or Objects (0).Kind /= Hull or Objects (0).Length = 0 then raise Data_Error with "invalid mesh reference"; end if;
            Reuse_Mesh := True;
            Objects (I).First := Objects (0).First; Objects (I).Length := Objects (0).Length;
            Objects (I).First_Facet := Objects (0).First_Facet; Objects (I).Facet_Count := Objects (0).Facet_Count;
            Objects (I).First_Graph := Objects (0).First_Graph; Objects (I).Graph_Length := Objects (0).Graph_Length;
            Objects (I).Extrema := Objects (0).Extrema;
         end if;
      end loop;
      for I in 0 .. 1 loop
         if I = 1 and Reuse_Mesh then
            Objects (I).Packed_Graph := Objects (0).Packed_Graph;
            Objects (I).Packed_Degrees := Objects (0).Packed_Degrees;
         else
            --  Debug modes 9/10 compare raw/neighbor-only graph traversal.
            if Mode /= 9 then
               MJ.Convex_Assets.Compile_Graph (Objects (I), Graphs (0 .. NG-1));
               if Mode /= 10 then MJ.Convex_Assets.Compile_Degrees (Objects (I), Graphs (0 .. NG-1)); end if;
            end if;
         end if;
      end loop;
      --  Model compilation, like C's mesh_polymap, is outside the hot loop.
      MJ.Contact_Incidence.Build (0, NV, Facets (0 .. NF-1), Incidence, Incidence_Result);
      if Mode in 7 | 8 then Incidence := MJ.Contact_Incidence.Empty_Lookup; end if;
      Checksum := 0.0; Original_X := Poses (1).Position (0); Start := Clock;
      Params.Include_Margin := Margin; Params.Detection_Margin := Margin;
      if Mode = 5 then
         for I in 1 .. Repeats loop
            MJ.Collision_Contacts.Generate (Objects (0), Objects (1), Poses (0), Poses (1),
              Vertices (0 .. NV-1), Facets (0 .. NF-1), Graphs (0 .. NG-1), Params, (0, 1), O, W, Full, Result, Incidence);
            exit when Result /= Success;
         end loop;
      elsif Mode = 6 then
         for I in 1 .. Repeats loop
            MJ.Collision_Contacts.Generate_Terrain (HF, Elevation (0 .. HF.Rows*HF.Columns-1), Poses (0),
              Objects (1), Poses (1), Vertices (0 .. NV-1), Graphs (0 .. NG-1), Params, (0, 1), O, W, Full, Result);
            exit when Result /= Success;
         end loop;
      else
      for I in 1 .. Repeats loop
         if Mode in 1 | 4 | 8 then Poses (1).Position (0) := Original_X+Offsets (I mod 16); end if;
         if Mode = 3 or Mode = 4 then
            MJ.Heightfield_Contacts.Generate (HF, Elevation (0 .. HF.Rows*HF.Columns-1), Poses (0), Objects (1), Poses (1),
              Vertices (0 .. NV-1), Margin, O, W, M, Result, Graphs (0 .. NG-1));
         elsif Mode /= 2 and Objects (0).Kind = Primitive and Objects (1).Kind = Primitive then
            MJ.Primitive_Contacts.Generate (Objects (0).Rigid, Objects (1).Rigid,
              Poses (0), Poses (1), Margin, O, W, M, Result);
         elsif Mode /= 2 then
            MJ.Advanced_Contacts.Generate (Objects (0), Objects (1), Poses (0), Poses (1), Vertices (0 .. NV-1),
              Facets (0 .. NF-1), Margin, O, W, M, Result, Graphs (0 .. NG-1), Incidence);
         else
            MJ.Convex_Contacts.Generate (Objects (0), Objects (1), Poses (0), Poses (1), Vertices (0 .. NV-1), Margin, O, W, M, Result, Graphs => Graphs (0 .. NG-1));
         end if;
         exit when Result /= Success;
         for J in 0 .. M.Length-1 loop
            Checksum := Checksum+M.Items (J).Distance;
            for C in Axis loop Checksum := Checksum+M.Items (J).Position (C); end loop;
            for C in Axis loop Checksum := Checksum+M.Items (J).Normal (C); end loop;
            for C in Axis loop Checksum := Checksum+M.Items (J).Tangent (C); end loop;
            Checksum := Checksum+Long_Float (M.Length);
         end loop;
      end loop;
      end if;
      Finish := Clock;
      Put (Status'Image (Result)); Put (" ");
      Ada.Integer_Text_IO.Put ((if Mode in 5 | 6 then Full.Length else M.Length), Width => 0);
      if Mode in 5 | 6 then
         for I in 0 .. Full.Length-1 loop
            Real_Out (Full.Items (I).Distance);
            for X of Full.Items (I).Position loop Real_Out (X); end loop;
            for X of Full.Items (I).Frame loop Real_Out (X); end loop;
            Real_Out (Long_Float (Full.Items (I).Dim));
            for X of Full.Items (I).Param.Fri loop Real_Out (X); end loop;
            for X of Full.Items (I).Param.Ref loop Real_Out (X); end loop;
            for X of Full.Items (I).Param.Ref_Friction loop Real_Out (X); end loop;
            for X of Full.Items (I).Param.Imp loop Real_Out (X); end loop;
            Real_Out (Full.Items (I).Param.Include_Margin);
            Real_Out (Long_Float (Boolean'Pos (Full.Items (I).Excluded)));
            Real_Out (Full.Items (I).Param.Adhesion);
            Real_Out (Long_Float (Full.Items (I).Geoms.First)); Real_Out (Long_Float (Full.Items (I).Geoms.Second));
            Real_Out (Long_Float (Full.Items (I).Efc_Address)); Real_Out (Full.Items (I).Mu);
            for X of Full.Items (I).Hessian loop Real_Out (X); end loop;
         end loop;
      elsif Mode in 1 | 4 | 8 then
         Real_Out (Long_Float (To_Duration (Finish-Start))*1.0e9/Long_Float (Repeats)); Real_Out (Checksum);
      else
         for I in 0 .. M.Length-1 loop
            Real_Out (M.Items (I).Distance);
            for C in Axis loop Real_Out (M.Items (I).Position (C)); end loop;
            for C in Axis loop Real_Out (M.Items (I).Normal (C)); end loop;
            for C in Axis loop Real_Out (M.Items (I).Tangent (C)); end loop;
         end loop;
      end if;
      New_Line;
   end loop;
end Contact_Probe;

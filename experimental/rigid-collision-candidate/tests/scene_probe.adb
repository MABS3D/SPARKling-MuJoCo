with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;
with Interfaces;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Contact_Parameters; use MJ.Contact_Parameters;
with MJ.Heightfield_Contacts; use MJ.Heightfield_Contacts;
with MJ.Full_Contacts; use MJ.Full_Contacts;
with MJ.Collision_Scene; use MJ.Collision_Scene;

procedure Scene_Probe is
   --  The probe owns the bounded workspace outside the main thread's scene.
   type Scene_Access is access Scene;
   S : constant Scene_Access := new Scene;
   G : Geometry_Array (0 .. Max_Geoms-1);
   P : Pose_Array (0 .. Max_Geoms-1);
   type Declared_Access is access Declared_Array;
   Owned_EP : constant Declared_Access := new Declared_Array (0 .. Max_Pairs-1);
   EP : Declared_Array renames Owned_EP.all;
   X : Exclusion_Array (0 .. Max_Pairs-1);
   Verts : Vertex_Array (0 .. 65535);
   Elevations : Elevation_Array (0 .. 65535);
   type Full_Access is access Full_Array;
   Owned_Contacts : constant Full_Access := new Full_Array (3 .. 65538);
   Contacts : Full_Array renames Owned_Contacts.all;
   O : Options;
   Override : Override_Parameters;
   N, NE, NX, Mode, Frames, Flag, Kind, NV, NH, Capacity : Integer;
   Length : Natural;
   Result : Status;
   package UIO is new Integer_IO (Long_Long_Integer);
   U : Long_Long_Integer;
   procedure Read_Pose (I : Natural) is
   begin
      for K in Axis loop Ada.Long_Float_Text_IO.Get (P (I).Position (K)); end loop;
      for K in P (I).Rotation'Range loop Ada.Long_Float_Text_IO.Get (P (I).Rotation (K)); end loop;
      Ada.Integer_Text_IO.Get (Flag); P (I).Asleep := Flag /= 0;
   end Read_Pose;
   procedure Read_Geom (I : Natural) is
      R : Shape;
      L : Integer;
   begin
      Ada.Integer_Text_IO.Get (Kind);
      R.Kind := (if Kind <= 5 then Shape_Kind'Val (Kind) else Box);
      Ada.Integer_Text_IO.Get (Flag); R.Body_Id := Flag;
      Ada.Integer_Text_IO.Get (Flag); R.Weld := Flag;
      Ada.Integer_Text_IO.Get (Flag); R.Weld_Parent := Flag;
      Ada.Integer_Text_IO.Get (Flag); R.Dynamic := Flag /= 0;
      UIO.Get (U); R.Contype := Interfaces.Unsigned_32 (U);
      UIO.Get (U); R.Conaffinity := Interfaces.Unsigned_32 (U);
      Ada.Long_Float_Text_IO.Get (R.Margin); Ada.Long_Float_Text_IO.Get (R.Gap);
      for K in Axis loop Ada.Long_Float_Text_IO.Get (R.Size (K)); end loop;
      Read_Pose (I);
      G (I) := (Solid => As_Object (R), others => <>);
      if Kind = 6 then
         Ada.Integer_Text_IO.Get (L);
         G (I).Solid.Kind := Hull; G (I).Solid.First := NV; G (I).Solid.Length := L;
         for J in NV .. NV+L-1 loop
            for K in Axis loop Ada.Long_Float_Text_IO.Get (Verts (J) (K)); end loop;
         end loop;
         NV := NV+L;
         Ada.Long_Float_Text_IO.Get (G (I).Solid.Skin);
      elsif Kind = 7 then
         G (I).Terrain := True;
         Ada.Integer_Text_IO.Get (L); G (I).Field.Rows := L;
         Ada.Integer_Text_IO.Get (L); G (I).Field.Columns := L;
         Ada.Long_Float_Text_IO.Get (G (I).Field.Half_X); Ada.Long_Float_Text_IO.Get (G (I).Field.Half_Y);
         Ada.Long_Float_Text_IO.Get (G (I).Field.Height); Ada.Long_Float_Text_IO.Get (G (I).Field.Base);
         L := G (I).Field.Rows*G (I).Field.Columns;
         G (I).Elevation_First := NH; G (I).Elevation_Length := L;
         for J in NH .. NH+L-1 loop Ada.Long_Float_Text_IO.Get (Elevations (J)); end loop;
         NH := NH+L;
      end if;
   end Read_Geom;
   procedure Real_Out (Value : Long_Float) is
   begin Put (" "); Ada.Long_Float_Text_IO.Put (Value, Fore => 1, Aft => 16, Exp => 3); end Real_Out;
   procedure Emit is
   begin
      if Ada.Command_Line.Argument_Count > 0
        and then Ada.Command_Line.Argument (1) = "bvh-stats" then
         Put_Line (Standard_Error, "BVH" & BVH_Node_Tests (S.all)'Image
           & BVH_Leaf_Tests (S.all)'Image);
      end if;
      Put (Status'Image (Result));
      Put (Natural'Image (Length)); Put (Natural'Image (Selected_Count (S.all)));
      Put (Natural'Image (Generation_Count (S.all)));
      for I in Contacts'First .. Contacts'First+Length-1 loop
         Put (Geom_Id'Image (Contacts (I).Geoms.First)); Put (Geom_Id'Image (Contacts (I).Geoms.Second));
         Real_Out (Contacts (I).Distance);
         for Z of Contacts (I).Position loop Real_Out (Z); end loop;
         for Z of Contacts (I).Frame loop Real_Out (Z); end loop;
         Real_Out (Contacts (I).Param.Include_Margin);
         Put (Boolean'Pos (Contacts (I).Excluded)'Image); Put (Contacts (I).Dim'Image);
         for Z of Contacts (I).Param.Fri loop Real_Out (Z); end loop;
      end loop;
      New_Line;
   end Emit;
begin
   while not End_Of_File loop
      NV := 0; NH := 0; Length := 0;
      Ada.Integer_Text_IO.Get (Mode); Ada.Integer_Text_IO.Get (N);
      Ada.Integer_Text_IO.Get (NE); Ada.Integer_Text_IO.Get (NX); Ada.Integer_Text_IO.Get (Frames);
      Ada.Integer_Text_IO.Get (Flag); O.Filter_Parent := Flag /= 0;
      Ada.Integer_Text_IO.Get (Flag); O.Sleep_Filter := Flag /= 0;
      Ada.Integer_Text_IO.Get (Flag); O.Enabled := Flag /= 0;
      Ada.Integer_Text_IO.Get (Flag); Override.Enabled := Flag /= 0;
      Ada.Long_Float_Text_IO.Get (Override.Margin); Ada.Integer_Text_IO.Get (Capacity);
      for I in 0 .. N-1 loop Read_Geom (I); end loop;
      for I in 0 .. NE-1 loop
         EP (I) := (others => <>);
         Ada.Integer_Text_IO.Get (Flag); EP (I).Geoms.First := Flag;
         Ada.Integer_Text_IO.Get (Flag); EP (I).Geoms.Second := Flag;
         Ada.Long_Float_Text_IO.Get (EP (I).Margin); Ada.Long_Float_Text_IO.Get (EP (I).Gap);
         Ada.Integer_Text_IO.Get (Flag); EP (I).Param.Dim := Flag;
         for K in Friction'Range loop Ada.Long_Float_Text_IO.Get (EP (I).Param.Fri (K)); end loop;
      end loop;
      for I in 0 .. NX-1 loop
         Ada.Integer_Text_IO.Get (Flag); X (I).First := Flag;
         Ada.Integer_Text_IO.Get (Flag); X (I).Second := Flag;
      end loop;
      Initialize (S.all, G (0 .. N-1), Verts (0 .. NV-1), Elevations (0 .. NH-1),
        Empty_Graph, EP (0 .. NE-1), X (0 .. NX-1), O, Override, Result);
      for F in 1 .. Frames loop
         if F > 1 then for I in 0 .. N-1 loop Read_Pose (I); end loop; end if;
         if Initialized (S.all) then
            Generate (S.all, P (0 .. N-1), Verts (0 .. NV-1), Empty_Facets,
              Elevations (0 .. NH-1), Empty_Graph, Contacts (3 .. 2+Capacity), Length, Result);
         end if;
         Emit;
      end loop;
   end loop;
end Scene_Probe;

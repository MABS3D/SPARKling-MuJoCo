with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Interfaces;
with Interfaces.C;
with System;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Heightfield_Contacts; use MJ.Heightfield_Contacts;
with MJ.Full_Contacts; use MJ.Full_Contacts;
with MJ.Collision_Scene; use MJ.Collision_Scene;
with MJ.Convex_Assets;
with MJ.Contact_Incidence;

procedure Scene_Bench is
   procedure Escape (Buffer : System.Address; Length : Interfaces.C.int)
     with Import, Convention => C, External_Name => "scene_escape";
   type Scene_Access is access Scene;
   S : constant Scene_Access := new Scene;
   G : Geometry_Array (0 .. Max_Geoms-1);
   type Frame_Array is array (Natural range <>) of Pose_Array (0 .. Max_Geoms-1);
   type Frame_Access is access Frame_Array;
   Frames : Frame_Access;
   V : Vertex_Array (0 .. 8191);
   type Facet_Access is access Facet_Array;
   Facets : constant Facet_Access := new Facet_Array (0 .. 8191);
   Graphs : Graph_Array (0 .. 65535);
   Elevations : Elevation_Array (0 .. 65535);
   type Full_Access is access Full_Array;
   Contacts : constant Full_Access := new Full_Array (0 .. 65535);
   Incidence : MJ.Contact_Incidence.Lookup;
   Empty_Declared : Declared_Array (1 .. 0);
   Empty_Excluded : Exclusion_Array (1 .. 0);
   Mode, NF, Repetitions, N, Kind, Flag, Num : Integer;
   NV, NFacet, NG, NE, Length : Natural := 0;
   Result : Status;
   package UIO is new Integer_IO (Long_Long_Integer);
   U, Total : Long_Long_Integer := 0;
   Start, Finish : Time;
   Checksum : Long_Float := 0.0;
   procedure Read_Pose (F, I : Natural) is
   begin
      for K in Axis loop Ada.Long_Float_Text_IO.Get (Frames (F) (I).Position (K)); end loop;
      for K in 0 .. 8 loop Ada.Long_Float_Text_IO.Get (Frames (F) (I).Rotation (K)); end loop;
      Ada.Integer_Text_IO.Get (Flag); Frames (F) (I).Asleep := Flag /= 0;
   end Read_Pose;
   procedure Real_Out (Value : Long_Float) is
   begin Put (" "); Ada.Long_Float_Text_IO.Put (Value, Fore => 1, Aft => 16, Exp => 3); end Real_Out;
   procedure Generate_Frame (F : Natural) is
   begin
      Generate (S.all, Frames (F) (0 .. N-1), V (0 .. NV-1), Facets (0 .. NFacet-1),
        Elevations (0 .. NE-1), Graphs (0 .. NG-1), Contacts.all, Length, Result, Incidence);
   end Generate_Frame;
   procedure Emit is
   begin
      Put (Status'Image (Result)); Put (Length'Image);
      Put (Selected_Count (S.all)'Image); Put (Generation_Count (S.all)'Image);
      for I in 0 .. Length-1 loop
         Put (Contacts (I).Geoms.First'Image); Put (Contacts (I).Geoms.Second'Image);
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
   --  One prepared trajectory per process. All reads, allocations and asset
   --  compilation occur before the timer; both executables use this same main.
   Ada.Integer_Text_IO.Get (Mode); Ada.Integer_Text_IO.Get (NF);
   Ada.Integer_Text_IO.Get (Repetitions); Ada.Integer_Text_IO.Get (N);
   Frames := new Frame_Array (0 .. NF-1);
   for I in 0 .. N-1 loop
      Ada.Integer_Text_IO.Get (Kind);
      G (I).Solid.Rigid.Kind := (if Kind <= 5 then Shape_Kind'Val (Kind) else Box);
      Ada.Integer_Text_IO.Get (Flag); G (I).Solid.Rigid.Body_Id := Flag;
      Ada.Integer_Text_IO.Get (Flag); G (I).Solid.Rigid.Weld := Flag;
      Ada.Integer_Text_IO.Get (Flag); G (I).Solid.Rigid.Weld_Parent := Flag;
      Ada.Integer_Text_IO.Get (Flag); G (I).Solid.Rigid.Dynamic := Flag /= 0;
      UIO.Get (U); G (I).Solid.Rigid.Contype := Interfaces.Unsigned_32 (U);
      UIO.Get (U); G (I).Solid.Rigid.Conaffinity := Interfaces.Unsigned_32 (U);
      Ada.Long_Float_Text_IO.Get (G (I).Solid.Rigid.Margin);
      Ada.Long_Float_Text_IO.Get (G (I).Solid.Rigid.Gap);
      for K in Axis loop Ada.Long_Float_Text_IO.Get (G (I).Solid.Rigid.Size (K)); end loop;
      Read_Pose (0, I);
      if Kind = 6 then
         G (I).Solid.Kind := Hull;
         Ada.Integer_Text_IO.Get (Num); G (I).Solid.First := NV; G (I).Solid.Length := Num;
         for J in NV .. NV+Num-1 loop
            for K in Axis loop Ada.Long_Float_Text_IO.Get (V (J) (K)); end loop;
         end loop;
         NV := NV+Num;
         Ada.Integer_Text_IO.Get (Num); G (I).Solid.First_Facet := NFacet; G (I).Solid.Facet_Count := Num;
         for J in NFacet .. NFacet+Num-1 loop
            for K in Axis loop Ada.Long_Float_Text_IO.Get (Facets (J).Normal (K)); end loop;
            Ada.Integer_Text_IO.Get (Flag); Facets (J).Length := Flag;
            for K in 0 .. Facets (J).Length-1 loop
               Ada.Integer_Text_IO.Get (Flag); Facets (J).Indices (K) := G (I).Solid.First+Flag;
            end loop;
         end loop;
         NFacet := NFacet+Num;
         Ada.Integer_Text_IO.Get (Num); G (I).Solid.First_Graph := NG; G (I).Solid.Graph_Length := Num;
         if Num > 0 then
            for K in 0 .. 26 loop Ada.Integer_Text_IO.Get (Flag); G (I).Solid.Extrema (K) := Flag; end loop;
            for K in NG .. NG+Num-1 loop Ada.Integer_Text_IO.Get (Graphs (K)); end loop;
         end if;
         NG := NG+Num;
         MJ.Convex_Assets.Compile_Graph (G (I).Solid, Graphs (0 .. NG-1));
         MJ.Convex_Assets.Compile_Degrees (G (I).Solid, Graphs (0 .. NG-1));
      elsif Kind = 7 then
         G (I).Terrain := True;
         Ada.Integer_Text_IO.Get (Flag); G (I).Field.Rows := Flag;
         Ada.Integer_Text_IO.Get (Flag); G (I).Field.Columns := Flag;
         Ada.Long_Float_Text_IO.Get (G (I).Field.Half_X); Ada.Long_Float_Text_IO.Get (G (I).Field.Half_Y);
         Ada.Long_Float_Text_IO.Get (G (I).Field.Height); Ada.Long_Float_Text_IO.Get (G (I).Field.Base);
         G (I).Elevation_First := NE; G (I).Elevation_Length := G (I).Field.Rows*G (I).Field.Columns;
         for J in NE .. NE+G (I).Elevation_Length-1 loop Ada.Long_Float_Text_IO.Get (Elevations (J)); end loop;
         NE := NE+G (I).Elevation_Length;
      end if;
   end loop;
   for F in 1 .. NF-1 loop for I in 0 .. N-1 loop Read_Pose (F, I); end loop; end loop;
   MJ.Contact_Incidence.Build (0, NV, Facets (0 .. NFacet-1), Incidence, Result);
   if Result /= Success then Put_Line (Status'Image (Result)); return; end if;
   Initialize (S.all, G (0 .. N-1), V (0 .. NV-1), Elevations (0 .. NE-1),
     Graphs (0 .. NG-1), Empty_Declared, Empty_Excluded, (others => <>), (others => <>), Result);
   if Result /= Success then Put_Line (Status'Image (Result)); return; end if;
   if Mode = 0 then
      for F in 0 .. NF-1 loop Generate_Frame (F); Emit; end loop;
      return;
   end if;
   for R in 1 .. 4 loop for F in 0 .. NF-1 loop Generate_Frame (F); end loop; end loop;
   if Result /= Success then Put_Line (Status'Image (Result)); return; end if;
   Start := Clock;
   for R in 1 .. Repetitions loop
      for F in 0 .. NF-1 loop
         Generate_Frame (F);
         if Result /= Success then Put_Line (Status'Image (Result)); return; end if;
         Escape (Contacts.all'Address, Interfaces.C.int (Length));
         Total := Total+Long_Long_Integer (Length);
      end loop;
   end loop;
   Finish := Clock;
   for I in 0 .. Length-1 loop
      Checksum := Checksum+Long_Float (1+Contacts (I).Geoms.First*4096+Contacts (I).Geoms.Second);
      Checksum := Checksum+Contacts (I).Distance;
      for K in Axis loop Checksum := Checksum+Contacts (I).Position (K); end loop;
      for K in Axis loop Checksum := Checksum+Contacts (I).Frame (K); end loop;
   end loop;
   Put (Status'Image (Result));
   Real_Out (Long_Float (To_Duration (Finish-Start))*1.0e9/Long_Float (Repetitions*NF));
   Put (Total'Image); Real_Out (Checksum); New_Line;
end Scene_Bench;

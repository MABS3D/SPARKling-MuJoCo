with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Interfaces;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Rigid_Detector; use MJ.Rigid_Detector;
with MJ.Rigid_Narrowphase;

procedure Rigid_Probe is
   Scene_Data : Scene;
   G : Shape_Array (0 .. Max_Geoms-1);
   P : Pose_Array (0 .. Max_Geoms-1);
   E : Explicit_Array (0 .. Max_Pairs-1);
   X : Exclusion_Array (0 .. Max_Pairs-1);
   Hits : Pair_List;
   O : Options;
   N, NE, NX, Mode, Repeats, K, V : Integer;
   Margin : Long_Float;
   Result : Status;
   Start, Finish : Time;
   Checksum : Long_Long_Integer;
   type Frame_Array is array (Natural range <>) of Pose_Array (0 .. Max_Geoms-1);
   type Frame_Access is access Frame_Array;
   Frames : Frame_Access;
   NF : Integer;
   procedure Read_Geom (I : Natural) is
   begin
      Ada.Integer_Text_IO.Get (K); G (I).Kind := Shape_Kind'Val (K);
      Ada.Integer_Text_IO.Get (K); G (I).Body_Id := K;
      Ada.Integer_Text_IO.Get (K); G (I).Weld := K;
      Ada.Integer_Text_IO.Get (K); G (I).Weld_Parent := K;
      Ada.Integer_Text_IO.Get (K); G (I).Dynamic := K /= 0;
      declare U : Long_Long_Integer; package IO is new Integer_IO (Long_Long_Integer); begin
         IO.Get (U); G (I).Contype := Interfaces.Unsigned_32 (U);
         IO.Get (U); G (I).Conaffinity := Interfaces.Unsigned_32 (U);
      end;
      Ada.Long_Float_Text_IO.Get (G (I).Margin); Ada.Long_Float_Text_IO.Get (G (I).Gap);
      for J in Axis loop Ada.Long_Float_Text_IO.Get (G (I).Size (J)); end loop;
      for J in Axis loop Ada.Long_Float_Text_IO.Get (P (I).Position (J)); end loop;
      for J in 0 .. 8 loop Ada.Long_Float_Text_IO.Get (P (I).Rotation (J)); end loop;
      Ada.Integer_Text_IO.Get (K); P (I).Asleep := K /= 0;
   end Read_Geom;
   procedure Write_Hits is
   begin
      if Result /= Success then Put_Line (Status'Image (Result)); return; end if;
      Put ("SUCCESS "); Ada.Integer_Text_IO.Put (Hits.Length, Width => 0);
      for I in 0 .. Hits.Length-1 loop
         Put (" "); Ada.Integer_Text_IO.Put (Hits.Items (I).First, Width => 0);
         Put (" "); Ada.Integer_Text_IO.Put (Hits.Items (I).Second, Width => 0);
      end loop;
      New_Line;
   end Write_Hits;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (Mode); Ada.Integer_Text_IO.Get (N);
      Ada.Integer_Text_IO.Get (NE); Ada.Integer_Text_IO.Get (NX); Ada.Integer_Text_IO.Get (Repeats);
      Ada.Integer_Text_IO.Get (V); O.Filter_Parent := V /= 0;
      Ada.Integer_Text_IO.Get (V); O.Sleep_Filter := V /= 0;
      for I in 0 .. N-1 loop Read_Geom (I); end loop;
      for I in 0 .. NE-1 loop
         Ada.Integer_Text_IO.Get (V); E (I).Geoms.First := V;
         Ada.Integer_Text_IO.Get (V); E (I).Geoms.Second := V;
         Ada.Long_Float_Text_IO.Get (E (I).Margin);
      end loop;
      for I in 0 .. NX-1 loop
         Ada.Integer_Text_IO.Get (V); X (I).First := V;
         Ada.Integer_Text_IO.Get (V); X (I).Second := V;
      end loop;
      if Mode = 2 then
         Ada.Long_Float_Text_IO.Get (Margin);
         Put_Line (Decision'Image (MJ.Rigid_Narrowphase.Test (G (0), G (1), P (0), P (1), Margin, O)));
      else
         Initialize (Scene_Data, G (0 .. N-1), E (0 .. NE-1), X (0 .. NX-1), O, Result);
         if Result = Success then Detect (Scene_Data, P (0 .. N-1), Hits, Result); end if;
         if Result /= Success then Put_Line (Status'Image (Result));
         elsif Mode = 0 then Write_Hits;
         elsif Mode = 4 then
            Write_Hits;
            for F in 2 .. Repeats loop
               for I in 0 .. N-1 loop
                  for J in Axis loop Ada.Long_Float_Text_IO.Get (P (I).Position (J)); end loop;
                  for J in 0 .. 8 loop Ada.Long_Float_Text_IO.Get (P (I).Rotation (J)); end loop;
                  Ada.Integer_Text_IO.Get (V); P (I).Asleep := V /= 0;
               end loop;
               Detect (Scene_Data, P (0 .. N-1), Hits, Result); Write_Hits;
            end loop;
         elsif Mode = 5 then
            Ada.Integer_Text_IO.Get (NF);
            if NF not in 1 .. 16 then raise Constraint_Error; end if;
            Frames := new Frame_Array (0 .. NF-1);
            Frames (0) (0 .. N-1) := P (0 .. N-1);
            for F in 1 .. NF-1 loop
               for I in 0 .. N-1 loop
                  for J in Axis loop Ada.Long_Float_Text_IO.Get (Frames (F) (I).Position (J)); end loop;
                  for J in 0 .. 8 loop Ada.Long_Float_Text_IO.Get (Frames (F) (I).Rotation (J)); end loop;
                  Ada.Integer_Text_IO.Get (V); Frames (F) (I).Asleep := V /= 0;
               end loop;
            end loop;
            for F in 0 .. NF-1 loop Detect (Scene_Data, Frames (F) (0 .. N-1), Hits, Result); end loop;
            Checksum := 0; Start := Clock;
            for I in 1 .. Repeats loop
               for F in 0 .. NF-1 loop
                  Detect (Scene_Data, Frames (F) (0 .. N-1), Hits, Result);
                  exit when Result /= Success;
                  for J in 0 .. Hits.Length-1 loop
                     Checksum := Checksum+1+Long_Long_Integer (Hits.Items (J).First)*4096
                       +Long_Long_Integer (Hits.Items (J).Second);
                  end loop;
               end loop;
               exit when Result /= Success;
            end loop;
            Finish := Clock;
            Put (Status'Image (Result)&" ");
            Ada.Long_Float_Text_IO.Put (Long_Float (To_Duration (Finish-Start))*1.0e9/Long_Float (Repeats*NF), Fore => 1, Aft => 6, Exp => 0);
            Put_Line (Long_Long_Integer'Image (Checksum));
         else
            Checksum := 0; Start := Clock;
            for I in 1 .. Repeats loop
               Detect (Scene_Data, P (0 .. N-1), Hits, Result);
               exit when Result /= Success;
               for J in 0 .. Hits.Length-1 loop
                  Checksum := Checksum+1+Long_Long_Integer (Hits.Items (J).First)*4096
                    +Long_Long_Integer (Hits.Items (J).Second);
               end loop;
            end loop;
            Finish := Clock;
            Put (Status'Image (Result)&" ");
            Ada.Long_Float_Text_IO.Put (Long_Float (To_Duration (Finish-Start))*1.0e9/Long_Float (Repeats), Fore => 1, Aft => 6, Exp => 0);
            Put_Line (Long_Long_Integer'Image (Checksum));
         end if;
      end if;
   end loop;
end Rigid_Probe;

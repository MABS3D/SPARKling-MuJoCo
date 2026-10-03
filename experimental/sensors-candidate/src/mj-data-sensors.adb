with Ada.Unchecked_Deallocation;
with MJ.Models.Validity;
with MJ.Data.Forward;
with MJ.Data.Euler;
with MJ.Data.Pipeline;
with MJ.Sensor_Kernels;
with MJ.Manifold_Math;
with MJ.Sensor_Geometry;
with MJ.Data.Rays;
with MJ.Ray_Kernels;
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Primitive_Contacts;
with MJ.Convex_Contacts;
with MJ.Contact_Geometry;
with MJ.Rigid_Geometry;
package body MJ.Data.Sensors with SPARK_Mode is
   package SK renames MJ.Sensor_Kernels;
   use type MJ.Rays.Status;
   procedure Release_Scene is new Ada.Unchecked_Deallocation (MJ.Rays.Scene, Ray_Scene_Access);
   procedure Release_Cache is new Ada.Unchecked_Deallocation (Cache, Cache_Access);
   procedure Release (C : in out Cache_Access) is
   begin
      if C /= null then Release_Scene (C.Ray_Scene); end if;
      Release_Cache (C);
   end Release;
   function Ready (S : Context) return Boolean is (S.C /= null);
   function Current (S : Context) return Boolean is (S.C /= null and then S.Valid);
   function Count (S : Context) return Natural is (if S.C = null then 0 else S.C.Sensors'Length);
   function Values (S : Context) return Real_Array is
     (if S.C = null then [1 .. 0 => 0.0] else S.C.Data);
   procedure Free (S : in out Context) is
   begin Release (S.C); S.Valid := False; end Free;
   procedure Invalidate (S : in out Context) is
   begin S.Valid := False; end Invalidate;
   procedure Reset (S : in out Context) is
   begin if S.C /= null then S.C.Data := [others => 0.0]; end if; S.Valid := False; end Reset;
   function Disabled (Flags, Bit : Integer) return Boolean is ((Flags / Bit) mod 2 = 1);

   procedure Initialize (M : MJ.Models.Model; S : in out Context; Result : out Status) is
      Candidate : Cache_Access := null;
      Enabled : constant Boolean := not Disabled (M.Opt.Disableflags, Dsbl_Sensor);
      procedure Copy_Poses (A : in out Pose_Array; Bodies : Int_Array;
                            Pos, Quat : Real_Array) is
      begin
         for I in A'Range loop
            A (I).Body_Id := Bodies (I);
            A (I).Position := Read_Vector (Pos, 3 * I);
            A (I).Orientation := Read_Quaternion (Quat, 4 * I);
         end loop;
      end Copy_Poses;
   begin
      Result := Already_Allocated; if Ready (S) then return; end if;
      Result := Invalid_Model; if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      Result := Capacity_Exceeded;
      if M.S.Nsensor > Max_Sensors or else M.S.Nsensordata > Max_Values then return; end if;
      Result := Unsupported_Feature;
      if Enabled then
         for I in 0 .. M.S.Nsensor - 1 loop
            if M.Sensors.Sensor_Type (I) not in 0 .. 46
              or else M.Sensors.Sensor_History (2 * I) /= 0
              or else M.Sensors.Sensor_Delay (I) /= 0.0
              or else M.Sensors.Sensor_Interval (2 * I) /= 0.0
            then return; end if;
            if M.Sensors.Sensor_Type (I) = 42 and then
              (M.Sensors.Sensor_Intprm (3 * I) not in 1 .. 127 or else M.Sensors.Sensor_Intprm (3 * I + 1) not in 0 .. 3)
            then return; end if;
            if M.Sensors.Sensor_Type (I) = 7 and then
              (M.Sensors.Sensor_Objtype (I) /= 6 or else M.Sensors.Sensor_Intprm (3 * I) not in 1 .. 63
               or else M.Sensors.Sensor_Dim (I) /= SK.Range_Width (M.Sensors.Sensor_Intprm (3 * I)))
            then return; end if;
            if M.Sensors.Sensor_Type (I) in 39 .. 41 | 46 then
               for G in 0 .. M.S.Ngeom - 1 loop
                  if M.Geoms.Geom_Type (G) not in 0 | 2 .. 6 then return; end if;
               end loop;
            end if;
            if (M.Sensors.Sensor_Objtype (I) = 7 and then M.Cameras.Cam_Mode (M.Sensors.Sensor_Objid (I)) /= 0)
              or else (M.Sensors.Sensor_Reftype (I) = 7 and then M.Sensors.Sensor_Refid (I) >= 0
                and then M.Cameras.Cam_Mode (M.Sensors.Sensor_Refid (I)) /= 0)
            then return; end if;
         end loop;
      end if;
      Candidate := new Cache (M.S.Nsensor - 1, M.S.Nsensordata - 1, M.S.Njnt - 1,
        M.S.Ngeom - 1, M.S.Nsite - 1, M.S.Ncam - 1, M.S.Nbody - 1);
      Candidate.Enabled := Enabled; Candidate.Nb := M.S.Nbody;
      Candidate.Nq := M.S.Nq; Candidate.Nv := M.S.Nv;
      Candidate.Magnetic := Vector (M.Opt.Magnetic);
      for I in Candidate.Sensors'Range loop
         Candidate.Sensors (I) := (M.Sensors.Sensor_Type (I), M.Sensors.Sensor_Datatype (I),
           M.Sensors.Sensor_Needstage (I), M.Sensors.Sensor_Objtype (I),
           M.Sensors.Sensor_Reftype (I), M.Sensors.Sensor_Dim (I), M.Sensors.Sensor_Adr (I),
           M.Sensors.Sensor_Objid (I), M.Sensors.Sensor_Refid (I), M.Sensors.Sensor_Cutoff (I),
           M.Sensors.Sensor_Intprm (3 * I), M.Sensors.Sensor_Intprm (3 * I + 1), M.Sensors.Sensor_Intprm (3 * I + 2), others => <>);
         if Candidate.Sensors (I).Kind = 46 then
            declare
               H : Descriptor renames Candidate.Sensors (I);
               Mesh : constant Natural := H.Objid;
               Vadr : constant Natural := M.Meshes.Mesh_Vertadr (Mesh);
               Nadr : constant Natural := M.Meshes.Mesh_Normaladr (Mesh);
               Stride : Natural := 3;
            begin
               H.Taxels := M.Meshes.Mesh_Vertnum (Mesh);
               H.Taxel_Frame := M.Meshes.Mesh_Normalnum (Mesh) = 3 * H.Taxels;
               if H.Taxel_Frame then Stride := 9; end if;
               if H.Taxels = 0 or else H.Dim /= 3 * H.Taxels then
                  Release (Candidate); Result := Unsupported_Feature; return;
               end if;
               for T in 0 .. H.Taxels - 1 loop
                  for A in 0 .. 2 loop
                     Candidate.Taxels (H.Adr + T).Position (A) := Real (M.Meshes.Mesh_Vert (3 * (Vadr + T) + A));
                     if H.Taxel_Frame then
                        Candidate.Taxels (H.Adr + T).Tangent1 (A) := Real (M.Meshes.Mesh_Normal (3 * Nadr + Stride * T + 3 + A));
                        Candidate.Taxels (H.Adr + T).Tangent2 (A) := Real (M.Meshes.Mesh_Normal (3 * Nadr + Stride * T + 6 + A));
                     end if;
                  end loop;
               end loop;
            end;
         end if;
         declare K : constant Natural := Candidate.Sensors (I).Kind; begin
            Candidate.Need_Pose := Candidate.Need_Pose or else K in 0 .. 8 | 26 .. 43 | 46;
            Candidate.Need_Motion := Candidate.Need_Motion or else K in 1 .. 5 | 19 | 31 .. 37 | 46;
            Candidate.Need_Jacobian := Candidate.Need_Jacobian or else K in 1 | 4 .. 5 | 33 .. 34;
            Candidate.Need_Subtree := Candidate.Need_Subtree or else K in 35 .. 38;
            Candidate.Need_Wrench := Candidate.Need_Wrench or else K in 4 .. 5;
         end;
      end loop;
      for B in Candidate.Weld'Range loop Candidate.Weld (B) := M.Bodies.Body_Weldid (B); end loop;
      Copy_Poses (Candidate.Sites, M.Sites.Site_Bodyid.all, M.Sites.Site_Pos.all, M.Sites.Site_Quat.all);
      Copy_Poses (Candidate.Geoms, M.Geoms.Geom_Bodyid.all, M.Geoms.Geom_Pos.all, M.Geoms.Geom_Quat.all);
      Copy_Poses (Candidate.Cameras, M.Cameras.Cam_Bodyid.all, M.Cameras.Cam_Pos.all, M.Cameras.Cam_Quat.all);
      for I in Candidate.Sites'Range loop
         Candidate.Sites (I).Kind := M.Sites.Site_Type (I);
         Candidate.Sites (I).Size := Read_Vector (M.Sites.Site_Size.all, 3 * I);
      end loop;
      for I in Candidate.Geoms'Range loop
         Candidate.Geoms (I).Kind := M.Geoms.Geom_Type (I);
         Candidate.Geoms (I).Size := Read_Vector (M.Geoms.Geom_Size.all, 3 * I);

      end loop;
      for I in Candidate.Cameras'Range loop
         declare P : Pose_Description renames Candidate.Cameras (I); begin
            P.Width := M.Cameras.Cam_Resolution (2 * I); P.Height := M.Cameras.Cam_Resolution (2 * I + 1);
            if M.Cameras.Cam_Sensorsize (2 * I) /= 0.0 and then M.Cameras.Cam_Sensorsize (2 * I + 1) /= 0.0 then
               P.Focal_X := Real (M.Cameras.Cam_Intrinsic (4 * I)) / Real (M.Cameras.Cam_Sensorsize (2 * I)) * Real (P.Width);
               P.Focal_Y := Real (M.Cameras.Cam_Intrinsic (4 * I + 1)) / Real (M.Cameras.Cam_Sensorsize (2 * I + 1)) * Real (P.Height);
            else
               P.Focal_Y := 0.5 / Ada.Numerics.Long_Elementary_Functions.Tan
                 (M.Cameras.Cam_Fovy (I) * Ada.Numerics.Pi / 360.0) * Real (P.Height);
               P.Focal_X := P.Focal_Y;
            end if;
         end;
      end loop;
      for I in Candidate.Qadr'Range loop
         Candidate.Qadr (I) := M.Joints.Jnt_Qposadr (I);
         Candidate.Vadr (I) := M.Joints.Jnt_Dofadr (I);
      end loop;
      if Enabled and then (for some H of Candidate.Sensors => H.Kind = 7) then
         declare Ray_Status : MJ.Rays.Status; begin
            Candidate.Ray_Scene := new MJ.Rays.Scene;
            MJ.Rays.Initialize (M, Candidate.Ray_Scene.all, Ray_Status);
            if Ray_Status /= MJ.Rays.Success then
               Release (Candidate);
               Result := (case Ray_Status is
                  when MJ.Rays.Capacity_Exceeded => Capacity_Exceeded,
                  when MJ.Rays.Unsupported_Feature => Unsupported_Feature,
                  when MJ.Rays.Numeric_Limit => Numeric_Limit,
                  when others => Invalid_Model);
               return;
            end if;
         end;
      end if;
      S.C := Candidate; S.Valid := False; Result := Success;
   exception when Constraint_Error => Release (Candidate); Result := Invalid_Model;
   end Initialize;

   procedure Create (M : MJ.Models.Model; D : in out Simulation;
                     S : in out Context; Result : out Status) is
   begin
      if not Is_Empty (D) or else Ready (S) then Result := Already_Allocated; return; end if;
      Initialize (M, S, Result); if Result /= Success then return; end if;
      MJ.Data.Create (M, D, Result);
      if Result /= Success then Free (S); end if;
   end Create;

   type Motion is record
      Position, Velocity, Angular, Acceleration, Alpha : Vector := Zero;
      Rotation : Matrix := Identity;
      Orientation : Quaternion := Identity_Quaternion;
      Body_Id : Natural := 0;
   end record;
   type Body_Work is record
      Com, Momentum, Angmom, Force, Torque : Vector := Zero;
      Mass : Real := 0.0;
   end record;
   type Work_Array is array (Natural range <>) of Body_Work;
   function Negated (Q : Quaternion) return Quaternion is ([Q (0), -Q (1), -Q (2), -Q (3)]);

   procedure Sample (D : in out Simulation; S : in out Context; Result : out Status;
     Limits : Limit_Array := No_Limits; Contacts : Contact_Array := No_Contacts;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      procedure Compute is
         C : Cache renames S.C.all;
         Output : Real_Array (C.Data'Range) := C.Data;
         Work : Work_Array (0 .. D.Nb - 1);
         Gravity : constant Vector := (if D.Gravity_Enabled then D.Gravity else Zero);
         function Frame (Kind, Id : Natural) return Motion is
            F : Motion;
            P : Pose_Description;
            R, Offset : Vector := Zero;
            B : Natural := Id;
         begin
            if Kind = 5 then P := C.Geoms (Id); B := P.Body_Id;
            elsif Kind = 6 then P := C.Sites (Id); B := P.Body_Id;
            elsif Kind = 7 then P := C.Cameras (Id); B := P.Body_Id;
            end if;
            declare T : Body_State renames D.Kinematic.Bodies (B); begin
               F.Body_Id := B; F.Position := T.Position; F.Rotation := T.Rotation; F.Orientation := T.Orientation;
               if Kind = 1 then
                  F.Position := T.Center; F.Rotation := T.Inertial_Rotation;
                  F.Orientation := Multiply (T.Orientation, D.Body_Config (B).Inertial_Orientation);
               elsif Kind in 5 .. 7 then
                  F.Position := T.Position + Apply (T.Rotation, P.Position);
                  F.Orientation := Multiply (T.Orientation, P.Orientation); F.Rotation := Rotation (F.Orientation);
               elsif Kind /= 2 then raise Constraint_Error; end if;
               R := F.Position - T.Position;
               F.Angular := T.Angular_Velocity;
               F.Velocity := T.Linear_Velocity + Cross (T.Angular_Velocity, R);
               F.Alpha := T.Angular_Bias;
               F.Acceleration := T.Linear_Bias + Cross (T.Angular_Bias, R)
                 + Cross (T.Angular_Velocity, Cross (T.Angular_Velocity, R)) - Gravity;
               if C.Need_Jacobian then
                  Offset := F.Position - T.Center;
                  for V in 0 .. D.Nv - 1 loop
                     declare
                        Jw : constant Vector := Read_Vector (D.Kinematic.Angular_Jacobian.all, 3 * (B * D.Nv + V));
                        Jv : constant Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, 3 * (B * D.Nv + V)) + Cross (Jw, Offset);
                        A : constant Real := D.Dynamics.Acceleration (V);
                     begin F.Alpha := F.Alpha + A * Jw; F.Acceleration := F.Acceleration + A * Jv; end;
                  end loop;
               end if;
            end;
            return F;
         end Frame;
         procedure Store (Adr : Natural; V : Vector) is
         begin for A in 0 .. 2 loop Output (Adr + A) := V (A); end loop; end Store;
         procedure Geometry_Distance (H : Descriptor) is
            package RG renames MJ.Rigid_Geometry;
            use type RG.Status;
            Minimum : Real := H.Cutoff;
            Start, Finish : Vector := Zero;
            W : MJ.Convex_Contacts.Workspace;
            Manifold : MJ.Contact_Geometry.Manifold;
            A, B : RG.Shape;
            PA, PB : RG.Pose;
            R : RG.Status;
            function Match (G : Natural; Kind, Id : Natural) return Boolean is
              (if Kind = 1 then C.Geoms (G).Body_Id = Id else G = Id);
         begin
            for I in C.Geoms'Range loop
               if Match (I, H.Objtype, H.Objid) then
               for J in C.Geoms'Range loop
                  if I /= J and then Match (J, H.Reftype, H.Refid) then
                     declare
                        F : constant Motion := Frame (5, I);
                        T : constant Motion := Frame (5, J);
                     begin
                        A.Kind := RG.Shape_Kind'Val ((if C.Geoms (I).Kind = 0 then 0 else C.Geoms (I).Kind - 1));
                        B.Kind := RG.Shape_Kind'Val ((if C.Geoms (J).Kind = 0 then 0 else C.Geoms (J).Kind - 1));
                        A.Size := RG.Vec (C.Geoms (I).Size); B.Size := RG.Vec (C.Geoms (J).Size);
                        PA.Position := RG.Vec (F.Position); PB.Position := RG.Vec (T.Position);
                        for X in 0 .. 2 loop for Y in 0 .. 2 loop
                           PA.Rotation (3 * X + Y) := F.Rotation (X, Y); PB.Rotation (3 * X + Y) := T.Rotation (X, Y);
                        end loop; end loop;
                        MJ.Primitive_Contacts.Generate (A, B, PA, PB, H.Cutoff, (others => <>), W, Manifold, R);
                        if R /= RG.Success then raise Constraint_Error; end if;
                        for K in 0 .. Manifold.Length - 1 loop
                           declare P : MJ.Contact_Geometry.Contact renames Manifold.Items (K); begin
                              if P.Distance < Minimum then
                                 Minimum := P.Distance;
                                 Start := Vector (P.Position) + (-0.5 * P.Distance) * Vector (P.Normal);
                                 Finish := Vector (P.Position) + (0.5 * P.Distance) * Vector (P.Normal);
                              end if;
                           end;
                        end loop;
                     end;
                  end if;
               end loop;
               end if;
            end loop;
            if H.Kind = 39 then Output (H.Adr) := Minimum;
            elsif H.Kind = 41 then Store (H.Adr, Start); Store (H.Adr + 3, Finish);
            else
               declare N : Vector := Finish - Start; Length : Real; begin
                  if N /= Zero then
                     Length := Ada.Numerics.Long_Elementary_Functions.Sqrt (Dot (N, N));
                     if Length >= Min_Val then N := (1.0 / Length) * N; else N := [1.0, 0.0, 0.0]; end if;
                  end if;
                  Store (H.Adr, N);
               end;
            end if;
         end Geometry_Distance;
         procedure Contact_Data (H : Descriptor) is
            type Selection is record Id : Natural := 0; Flip : Boolean := False; Criterion : Real := 0.0; end record;
            type Selection_Array is array (Natural range <>) of Selection;
            Selected : Selection_Array (0 .. Contacts'Length - 1);
            N, Width, Slot, Offset : Natural := 0;
            Sizes : constant Index_Array (0 .. 6) := [1, 3, 3, 1, 3, 3, 3];
            Total, Weight : Real := 0.0;
            Point, Force, Torque, V : Vector := Zero;
            function Match (Kind : Natural; Id : Integer; Body_Id, Geom_Id : Natural) return Boolean is
               B : Natural := Body_Id;
            begin
               if Kind in 0 | 6 then return True;
               elsif Kind = 5 then return Id = Geom_Id;
               elsif Kind = 1 then return Id = Body_Id;
               elsif Kind = 2 then
                  while B > Id loop B := D.Body_Config (B).Parent; end loop;
                  return B = Id;
               else return False; end if;
            end Match;
         begin
            Output (H.Adr .. H.Adr + H.Dim - 1) := [others => 0.0];
            for K in 0 .. 6 loop if (H.Dataspec / 2 ** K) mod 2 = 1 then Width := Width + Sizes (K); end if; end loop;
            for I in Contacts'Range loop
               declare
                  P : Contact_Reading renames Contacts (I);
                  M11 : constant Boolean := Match (H.Objtype, H.Objid, P.Body1, P.Geom1);
                  M12 : constant Boolean := Match (H.Objtype, H.Objid, P.Body2, P.Geom2);
                  M21 : constant Boolean := Match (H.Reftype, H.Refid, P.Body1, P.Geom1);
                  M22 : constant Boolean := Match (H.Reftype, H.Refid, P.Body2, P.Geom2);
                  In_Zone : Boolean := True;
               begin
                  if H.Objtype = 6 then
                     declare F : constant Motion := Frame (6, H.Objid); begin
                        In_Zone := MJ.Sensor_Geometry.Inside (C.Sites (H.Objid).Kind, C.Sites (H.Objid).Size,
                          Apply_Transpose (F.Rotation, P.Position - F.Position));
                     end;
                  end if;
                  if In_Zone and then (M11 or M12) and then (M21 or M22) then
                     Selected (N).Id := I;
                     Selected (N).Flip := (if H.Objtype /= 0 and H.Reftype /= 0 then M12 and M21 and not (M11 and M22)
                       elsif H.Objtype /= 0 then not M11 elsif H.Reftype /= 0 then not M22 else False);
                     Selected (N).Criterion := (if H.Reduction = 1 then P.Distance
                       elsif H.Reduction = 2 then -Dot (P.Local_Force, P.Local_Force) else 0.0);
                     N := N + 1;
                  end if;
               end;
            end loop;
            if H.Reduction in 1 .. 2 then
               for I in 1 .. N - 1 loop
                  declare Item : constant Selection := Selected (I); J : Natural := I; begin
                     while J > 0 and then (Selected (J - 1).Criterion > Item.Criterion
                       or else (Selected (J - 1).Criterion = Item.Criterion and then Selected (J - 1).Id > Item.Id)) loop
                        Selected (J) := Selected (J - 1); J := J - 1;
                     end loop;
                     Selected (J) := Item;
                  end;
               end loop;
            elsif H.Reduction = 3 then
               for I in 0 .. N - 1 loop
                  declare P : Contact_Reading renames Contacts (Selected (I).Id); begin
                     Weight := Ada.Numerics.Long_Elementary_Functions.Sqrt (Dot (P.Local_Force, P.Local_Force));
                     Point := Point + Weight * P.Position; Total := Total + Weight;
                  end;
               end loop;
               Point := (1.0 / Real'Max (Min_Val, Total)) * Point;
               for I in 0 .. N - 1 loop
                  declare P : Contact_Reading renames Contacts (Selected (I).Id);
                     Sign : constant Real := (if Selected (I).Flip then -1.0 else 1.0);
                     F : constant Vector := Sign * P.Force;
                  begin Force := Force + F; Torque := Torque + Sign * P.Torque + Cross (P.Position - Point, F); end;
               end loop;
               --  C publishes the global frame even when no contacts match.
               Offset := H.Adr;
               for K in 0 .. 6 loop
                  if (H.Dataspec / 2 ** K) mod 2 = 1 then
                     case K is
                        when 0 => Output (Offset) := Real (N);
                        when 1 => Store (Offset, Force);
                        when 2 => Store (Offset, Torque);
                        when 3 => Output (Offset) := 0.0;
                        when 4 => Store (Offset, Point);
                        when 5 => Store (Offset, [1.0, 0.0, 0.0]);
                        when 6 => Store (Offset, [0.0, 1.0, 0.0]);
                        when others => null;
                     end case;
                     Offset := Offset + Sizes (K);
                  end if;
               end loop;
               return;
            end if;
            for I in 0 .. Natural'Min (H.Dim / Width, N) - 1 loop
               declare
                  Item : Selection renames Selected (I); P : Contact_Reading renames Contacts (Item.Id);
               begin
                  Slot := H.Adr + I * Width; Offset := 0;
                  for K in 0 .. 6 loop
                     if (H.Dataspec / 2 ** K) mod 2 = 1 then
                        case K is
                           when 0 => Output (Slot + Offset) := Real (N);
                           when 1 | 2 =>
                              V := (if K = 1 then P.Local_Force else P.Local_Torque);
                              if Item.Flip then V (2) := -V (2); end if;
                              Store (Slot + Offset, V);
                           when 3 => Output (Slot + Offset) := P.Distance;
                           when 4 => Store (Slot + Offset, P.Position);
                           when 5 | 6 =>
                              V := (if K = 5 then P.Normal else P.Tangent);
                              if Item.Flip then V := -1.0 * V; end if;
                              Store (Slot + Offset, V);
                           when others => null;
                        end case;
                        Offset := Offset + Sizes (K);
                     end if;
                  end loop;
               end;
            end loop;
         end Contact_Data;
         procedure Tactile (H : Descriptor) is
            type Marks is array (C.Geoms'Range) of Boolean;
            Seen : Marks := [others => False];
            Geoms : Index_Array (C.Geoms'Range);
            N : Natural := 0;
            F : constant Motion := Frame (5, H.Refid);
            Sensor_Weld : constant Natural := C.Weld (F.Body_Id);
         begin
            Output (H.Adr .. H.Adr + H.Dim - 1) := [others => 0.0];
            for P of Contacts loop
               for Side in 0 .. 1 loop
                  declare
                     Body_Id : constant Natural := (if Side = 0 then P.Body1 else P.Body2);
                     G : constant Natural := (if Side = 0 then P.Geom2 else P.Geom1);
                  begin
                     if C.Weld (Body_Id) = Sensor_Weld and then G /= H.Refid and then not Seen (G) then
                        Seen (G) := True; Geoms (N) := G; N := N + 1;
                     end if;
                  end;
               end loop;
            end loop;
            for T in 0 .. H.Taxels - 1 loop
               declare
                  Tax : Taxel renames C.Taxels (H.Adr + T);
                  Position : constant Vector := F.Position + Apply (F.Rotation, Tax.Position);
                  Source : constant Motion := Frame (2, Sensor_Weld);
                  Source_Velocity : constant Vector := Source.Velocity + Cross (Source.Angular, Position - Source.Position);
                  Target : Motion;
                  Point, Velocity : Vector;
                  Depth : Real;
               begin
                  for I in 0 .. N - 1 loop
                     Target := Frame (5, Geoms (I));
                     Point := Apply_Transpose (Target.Rotation, Position - Target.Position);
                     Depth := Real'Min (MJ.Sensor_Geometry.Distance (C.Geoms (Geoms (I)).Kind, C.Geoms (Geoms (I)).Size, Point), 0.0);
                     if Depth /= 0.0 then
                        Output (H.Adr + T) := Real'Max (Output (H.Adr + T), -Depth);
                        if H.Taxel_Frame then
                           Velocity := Source_Velocity - (Target.Velocity + Cross (Target.Angular, Position - Target.Position));
                           Velocity := Apply_Transpose (F.Rotation, Velocity);
                           Output (H.Adr + H.Taxels + T) := Output (H.Adr + H.Taxels + T) + abs Dot (Velocity, Tax.Tangent1);
                           Output (H.Adr + 2 * H.Taxels + T) := Output (H.Adr + 2 * H.Taxels + T) + abs Dot (Velocity, Tax.Tangent2);
                        end if;
                     end if;
                  end loop;
               end;
            end loop;
         end Tactile;
         function Potential return Real is
            E : Real := 0.0;
            Displacement : Real;
            Rotation_Difference : Vector := Zero;
         begin
            for B in 1 .. D.Nb - 1 loop
               E := E - D.Body_Config (B).Mass * Dot (Gravity, D.Kinematic.Bodies (B).Center);
            end loop;
            if D.Spring_Enabled then
               for J in 0 .. D.Nv - 1 loop
                  declare P : Joint_Parameters renames D.Joint_Config (J); begin
                     if P.Group_Type in 0 .. 1 and then P.Kind = Hinge_Joint then
                        if P.Component = (if P.Group_Type = 0 then 3 else 0) then
                           Rotation_Difference := MJ.Manifold_Math.Difference
                             (Read_Quaternion (D.State.Qpos.all, P.Qadr), P.Spring_Quaternion);
                        end if;
                        Displacement := Rotation_Difference (P.Component - (if P.Group_Type = 0 then 3 else 0));
                     else Displacement := D.State.Qpos (P.Qadr) - P.Spring_Reference; end if;
                     E := E + ((0.5 * P.Stiffness) * Displacement) * Displacement;
                  end;
               end loop;
               if D.Tendons /= null then
                  for T in 0 .. Tendon_Count (D) - 1 loop
                     declare
                        L : constant Real := Tendon_Value (D, T, 0);
                        P : MJ.Spatial_Tendon_Models.Parameters renames D.Tendons.Tendons (T + 1);
                     begin
                        Displacement := (if L < P.Lower then L - P.Lower
                          elsif L > P.Upper then L - P.Upper else 0.0);
                        E := E + 0.5 * P.Stiffness * Displacement * Displacement
                          + (P.Spring_Linear / 3.0) * abs (Displacement ** 3)
                          + (P.Spring_Quadratic / 4.0) * Displacement ** 4;
                     end;
                  end loop;
               end if;
            end if;
            return E;
         end Potential;
      begin
         if C.Need_Motion then Pipeline.Ensure_Cartesian_Motion (D, Result); if Result /= Success then return; end if; end if;
         if C.Need_Jacobian then Pipeline.Ensure_Jacobians (D, Result); if Result /= Success then return; end if; end if;
         if C.Need_Subtree or else C.Need_Wrench then
            for B in 0 .. D.Nb - 1 loop
               declare
                  F : constant Motion := Frame (1, B);
                  P : Body_Parameters renames D.Body_Config (B);
                  W : Vector := Apply_Transpose (F.Rotation, F.Angular);
                  Alpha : Vector := Apply_Transpose (F.Rotation, F.Alpha);
               begin
                  Work (B).Mass := P.Mass;
                  Work (B).Com := P.Mass * F.Position;
                  Work (B).Momentum := P.Mass * F.Velocity;
                  for A in 0 .. 2 loop W (A) := W (A) * P.Inertia (A); Alpha (A) := Alpha (A) * P.Inertia (A); end loop;
                  W := Apply (F.Rotation, W);
                  Work (B).Angmom := W + Cross (F.Position, Work (B).Momentum);
                  Work (B).Force := P.Mass * F.Acceleration;
                  Work (B).Torque := Apply (F.Rotation, Alpha) + Cross (F.Angular, W)
                    + Cross (F.Position, Work (B).Force);
                  if External'Length > 0 then
                     declare
                        Force : constant Vector := [for I in 0 .. 2 => Real (External (B).Force (I))];
                        Torque : constant Vector := [for I in 0 .. 2 => Real (External (B).Torque (I))];
                     begin
                        Work (B).Force := Work (B).Force - Force;
                        Work (B).Torque := Work (B).Torque - Torque - Cross (F.Position, Force);
                     end;
                  end if;
               end;
            end loop;
            for Contact of Contacts loop
               if Contact.Active then
                  for Side in 0 .. 1 loop
                     declare
                        B : constant Natural := (if Side = 0 then Contact.Body1 else Contact.Body2);
                        Sign : constant Real := (if Side = 0 then -1.0 else 1.0);
                        F : constant Vector := Sign * Contact.Force;
                        T : constant Vector := Sign * Contact.Torque + Cross (Contact.Position, F);
                     begin Work (B).Force := Work (B).Force - F; Work (B).Torque := Work (B).Torque - T; end;
                  end loop;
               end if;
            end loop;
            for B in reverse 1 .. D.Nb - 1 loop
               declare Parent : constant Natural := D.Body_Config (B).Parent; begin
                  Work (Parent).Mass := Work (Parent).Mass + Work (B).Mass;
                  Work (Parent).Com := Work (Parent).Com + Work (B).Com;
                  Work (Parent).Momentum := Work (Parent).Momentum + Work (B).Momentum;
                  Work (Parent).Angmom := Work (Parent).Angmom + Work (B).Angmom;
                  Work (Parent).Force := Work (Parent).Force + Work (B).Force;
                  Work (Parent).Torque := Work (Parent).Torque + Work (B).Torque;
               end;
            end loop;
         end if;
         for Stage in 1 .. 3 loop
         for H of C.Sensors loop
            if H.Stage = Stage then
               declare
                  A : constant Natural := H.Adr;
                  F, Ref : Motion;
                  V : Vector := Zero;
                  Q : Quaternion;
                  X : Real := 0.0;
               begin
                  case H.Kind is
                     when 1 .. 6 =>
                        F := Frame (6, H.Objid);
                        if H.Kind = 1 then V := F.Acceleration;
                        elsif H.Kind = 2 then V := F.Velocity;
                        elsif H.Kind = 3 then V := F.Angular;
                        elsif H.Kind = 4 then V := Work (F.Body_Id).Force;
                        elsif H.Kind = 5 then V := Work (F.Body_Id).Torque - Cross (F.Position, Work (F.Body_Id).Force);
                        else V := C.Magnetic; end if;
                        Store (A, Apply_Transpose (F.Rotation, V));
                     when 9 => Output (A) := D.State.Qpos (C.Qadr (H.Objid));
                     when 7 =>
                        F := Frame (6, H.Objid);
                        declare
                           Hit : MJ.Rays.Result;
                           Ray_Status : MJ.Rays.Status;
                           Offset : Natural := A;
                           Direction : constant Vector := [for I in 0 .. 2 => F.Rotation (I, 2)];
                        begin
                           MJ.Rays.Cast (C.Ray_Scene.all,
                             MJ.Ray_Kernels.Vector'([for I in MJ.Ray_Kernels.Axis => F.Position (I)]),
                             MJ.Ray_Kernels.Vector'([for I in MJ.Ray_Kernels.Axis => F.Rotation (I, 2)]),
                             Hit, Ray_Status, (Excluded_Body => F.Body_Id, others => <>));
                           if Ray_Status /= MJ.Rays.Success then raise Constraint_Error; end if;
                           for Field in 0 .. 5 loop
                              if (H.Dataspec / 2 ** Field) mod 2 = 1 then
                                 if Field in 0 | 5 then
                                    Output (Offset) := Hit.Distance; Offset := Offset + 1;
                                 else
                                    V := Zero;
                                    if Field = 2 then V := F.Position;
                                    elsif Hit.Distance >= 0.0 then
                                       case Field is
                                          when 1 => V := Direction;
                                          when 3 => V := F.Position + Hit.Distance * Direction;
                                          when 4 => V := [for I in 0 .. 2 => Hit.Normal (I)];
                                          when others => null;
                                       end case;
                                    end if;
                                    Store (Offset, V); Offset := Offset + 3;
                                 end if;
                              end if;
                           end loop;
                        end;
                     when 8 =>
                        F := Frame (6, H.Objid); Ref := Frame (7, H.Refid);
                        V := Apply_Transpose (Ref.Rotation, F.Position - Ref.Position);
                        X := V (2);
                        if abs X < Min_Val then X := (if X < 0.0 then -Min_Val else Min_Val); end if;
                        Output (A) := SK.Projection (V (0), X, -C.Cameras (H.Refid).Focal_X, 0.5 * Real (C.Cameras (H.Refid).Width));
                        Output (A + 1) := SK.Projection (V (1), X, C.Cameras (H.Refid).Focal_Y, 0.5 * Real (C.Cameras (H.Refid).Height));
                     when 10 => Output (A) := D.State.Qvel (C.Vadr (H.Objid));
                     when 11 => Output (A) := Tendon_Value (D, H.Objid, 0);
                     when 12 => Output (A) := Tendon_Value (D, H.Objid, 1);
                     when 13 => Output (A) := D.Actuators.Length (H.Objid);
                     when 14 => Output (A) := D.Actuators.Velocity (H.Objid);
                     when 15 => Output (A) := D.Actuators.Force (H.Objid);
                     when 16 => Output (A) := D.Dynamics.Actuator (C.Vadr (H.Objid));
                     when 17 => Output (A) := 0.0; -- no tendon transmissions admitted by smooth
                     when 18 =>
                        Q := Read_Quaternion (D.State.Qpos.all, C.Qadr (H.Objid));
                        Normalize (Q, S.Valid); if not S.Valid then Result := Numeric_Limit; return; end if;
                        for I in 0 .. 3 loop Output (A + I) := Q (I); end loop;
                     when 19 => Store (A, Read_Vector (D.State.Qvel.all, C.Vadr (H.Objid)));
                     when 20 .. 25 =>
                        Output (A) := 0.0;
                        for L of Limits loop
                           if L.Id = H.Objid and then L.Tendon = (H.Kind in 23 .. 25) then
                              Output (A) := (case H.Kind is when 20 | 23 => L.Position,
                                when 21 | 24 => L.Velocity, when others => L.Force); exit;
                           end if;
                        end loop;
                     when 26 .. 34 =>
                        F := Frame (H.Objtype, H.Objid);
                        if H.Refid >= 0 then Ref := Frame (H.Reftype, H.Refid); end if;
                        case H.Kind is
                           when 26 => V := F.Position; if H.Refid >= 0 then V := Apply_Transpose (Ref.Rotation, V - Ref.Position); end if;
                           when 27 =>
                              Q := F.Orientation; if H.Refid >= 0 then Q := Multiply (Negated (Ref.Orientation), Q); end if;
                              for I in 0 .. 3 loop Output (A + I) := Q (I); end loop;
                           when 28 .. 30 =>
                              for I in 0 .. 2 loop V (I) := F.Rotation (I, H.Kind - 28); end loop;
                              if H.Refid >= 0 then V := Apply_Transpose (Ref.Rotation, V); end if;
                           when 31 =>
                              V := F.Velocity;
                              if H.Refid >= 0 then V := Apply_Transpose (Ref.Rotation,
                                V - Ref.Velocity + Cross (F.Position - Ref.Position, Ref.Angular)); end if;
                           when 32 =>
                              V := F.Angular; if H.Refid >= 0 then V := Apply_Transpose (Ref.Rotation, V - Ref.Angular); end if;
                           when 33 => V := F.Acceleration;
                           when others => V := F.Alpha;
                        end case;
                        if H.Kind /= 27 then Store (A, V); end if;
                     when 35 .. 37 =>
                        declare W : Body_Work renames Work (H.Objid); begin
                           if H.Kind = 35 then V := (1.0 / Real'Max (Min_Val, W.Mass)) * W.Com;
                           elsif H.Kind = 36 then V := (1.0 / Real'Max (Min_Val, W.Mass)) * W.Momentum;
                           else V := W.Angmom - Cross ((1.0 / Real'Max (Min_Val, W.Mass)) * W.Com, W.Momentum); end if;
                        end; Store (A, V);
                     when 0 =>
                        F := Frame (6, H.Objid); Output (A) := 0.0;
                        for Contact of Contacts loop
                           if Contact.Active and then Contact.Normal_Force > 0.0
                             and then F.Body_Id in Contact.Body1 | Contact.Body2 then
                              declare Hit : Real; Ok : Boolean; begin
                                 V := (if F.Body_Id = Contact.Body2 then -1.0 * Contact.Normal else Contact.Normal);
                                 MJ.Sensor_Geometry.Ray (C.Sites (H.Objid).Kind, C.Sites (H.Objid).Size,
                                   Apply_Transpose (F.Rotation, Contact.Position - F.Position),
                                   Apply_Transpose (F.Rotation, V), Hit, Ok);
                                 if not Ok then raise Constraint_Error; end if;
                                 if Hit >= 0.0 then Output (A) := Output (A) + Contact.Normal_Force; end if;
                              end;
                           end if;
                        end loop;
                     when 38 =>
                        F := Frame (H.Objtype, H.Objid); Ref := Frame (6, H.Refid);
                        if H.Objtype = 1 and then D.Body_Config (F.Body_Id).Mass < Min_Val
                          and then Work (F.Body_Id).Mass >= Min_Val then
                           F.Position := (1.0 / Work (F.Body_Id).Mass) * Work (F.Body_Id).Com;
                        end if;
                        Output (A) := (if MJ.Sensor_Geometry.Inside (C.Sites (H.Refid).Kind,
                          C.Sites (H.Refid).Size, Apply_Transpose (Ref.Rotation, F.Position - Ref.Position)) then 1.0 else 0.0);
                     when 43 => Output (A) := Potential;
                     when 39 .. 41 => Geometry_Distance (H);
                     when 42 => Contact_Data (H);
                     when 46 => Tactile (H);
                     when 44 =>
                        for I in 0 .. D.Nv - 1 loop
                           X := 0.0;
                           for J in 0 .. D.Nv - 1 loop X := X + D.Dynamics.Mass (I * D.Nv + J) * D.State.Qvel (J); end loop;
                           Output (A) := (if I = 0 then 0.0 else Output (A)) + D.State.Qvel (I) * X;
                        end loop;
                        Output (A) := 0.5 * Output (A);
                     when 45 => Output (A) := D.Clock;
                     when others => raise Constraint_Error;
                  end case;
                  for I in A .. A + H.Dim - 1 loop
                     Output (I) := SK.Clip (Output (I), H.Cutoff, H.Datatype, H.Kind);
                  end loop;
               end;
            end if;
         end loop;
         end loop;
         C.Data := Output; S.Valid := True; Result := Success;
      end Compute;
   begin
      S.Valid := False; Result := Not_Allocated;
      if not Ready (S) or else not Is_Ready (D) then return; end if;
      Result := Invalid_Size;
      if D.Nq /= S.C.Nq or else D.Nv /= S.C.Nv or else D.Nb /= S.C.Nb
        or else (External'Length > 0 and then (External'First /= 0 or else External'Length /= D.Nb)) then return; end if;
      Result := Stale_Results; if not Forces_Current (D) then return; end if;
      if not S.C.Enabled then Result := Success; return; end if;
      if S.C.Ray_Scene /= null then
         MJ.Data.Rays.Synchronize (D, S.C.Ray_Scene.all, Result);
         if Result /= Success then return; end if;
      end if;
      Compute;
   exception when Constraint_Error => S.Valid := False; Result := Numeric_Limit;
   end Sample;

   procedure Evaluate (D : in out Simulation; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Invalidate (S); if not Ready (S) then Result := Not_Allocated; return; end if;
      MJ.Data.Forward.Evaluate (D, Result, External);
      if Result = Success then Sample (D, S, Result, External => External); end if;
   end Evaluate;
   procedure Step (D : in out Simulation; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Evaluate (D, S, Result, External); if Result /= Success then return; end if;
      MJ.Data.Euler.Step (D, Result, External); if Result /= Success then Invalidate (S); end if;
   end Step;
end MJ.Data.Sensors;

with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
with MJ.Elastic_Contact_Math; use MJ.Elastic_Contact_Math;
with MJ.Elastic_Coordinates;

package body MJ.Elastic_Contacts with SPARK_Mode is
   subtype Dof is Integer range 0 .. 5;
   type Spatial is array (Dof) of Real;
   type Spatial_Array is array (Positive range <>) of Spatial;
   type Matrix is array (Axis, Axis) of Real;
   type Matrix_Array is array (Body_Index range <>) of Matrix;
   type Term is record
      Entity : Natural := 0;
      J : Spatial := [others => 0.0];
   end record;
   type Terms is array (Positive range 1 .. 4) of Term;
   type Row is record
      T : Terms;
      N : Natural range 0 .. 4 := 0;
      Active : Boolean := False;
      Approx, Diagonal, R, Reference, Force : Real := 0.0;
   end record;
   type Rows is array (Positive range <>) of Row;
   type Capsule_Data is record
      Center, Half_Axis, Axis_Unit : Vector;
      Radius : Real;
   end record;
   type Capsule_Array is array (Vertex range <>) of Capsule_Data;

   function V (A : Input_Vector) return Vector is
     ([A (0), A (1), A (2)]);
   function Input (A : Vector) return Input_Vector is
     ([A (0), A (1), A (2)]) with Pre => Bounded (A, 1.0e10);
   function Unit (A : Vector) return Vector is
      L : constant Real := Norm (A);
   begin
      if L < Min_Val then return [1.0, 0.0, 0.0]; end if;
      return Scale (A, 1.0/L);
   end Unit;
   function Rotation (Q : Quaternion) return Matrix is
      W : constant Real := Q (0); X : constant Real := Q (1);
      Y : constant Real := Q (2); Z : constant Real := Q (3);
   begin
      return [[W*W+X*X-Y*Y-Z*Z, 2.0*(X*Y-W*Z), 2.0*(X*Z+W*Y)],
              [2.0*(X*Y+W*Z), W*W-X*X+Y*Y-Z*Z, 2.0*(Y*Z-W*X)],
              [2.0*(X*Z-W*Y), 2.0*(Y*Z+W*X), W*W-X*X-Y*Y+Z*Z]];
   end Rotation;
   function Rotate (R : Matrix; A : Vector; Transpose : Boolean := False) return Vector is
      B : Vector;
   begin
      for K in Axis loop
         if Transpose then
            B (K) := (R (0, K)*A (0)+R (1, K)*A (1))+R (2, K)*A (2);
         else
            B (K) := (R (K, 0)*A (0)+R (K, 1)*A (1))+R (K, 2)*A (2);
         end if;
      end loop;
      return B;
   end Rotate;
   function Advance (Q : Quaternion; Omega : Vector; Dt : Time_Step) return Quaternion is
      L : constant Real := Norm (Omega);
      A : constant Vector := (if L < Min_Val then [1.0, 0.0, 0.0] else Scale (Omega, 1.0/L));
      Half_Angle : constant Real := 0.5*Dt*L;
      C : constant Real := Cos (Half_Angle);
      S : constant Vector := Scale (A, Sin (Half_Angle));
      R : Quaternion;
      Len : Real;
   begin
      R := [Q (0)*C-Q (1)*S (0)-Q (2)*S (1)-Q (3)*S (2),
            Q (0)*S (0)+Q (1)*C+Q (2)*S (2)-Q (3)*S (1),
            Q (0)*S (1)-Q (1)*S (2)+Q (2)*C+Q (3)*S (0),
            Q (0)*S (2)+Q (1)*S (1)-Q (2)*S (0)+Q (3)*C];
      Len := Sqrt (((R (0)*R (0)+R (1)*R (1))+R (2)*R (2))+R (3)*R (3));
      for K in R'Range loop R (K) := R (K)/Len; end loop;
      return R;
   end Advance;

   procedure Step
     (P : in out Particle_Array; Coordinates : in out MJ.Elastic_Coordinates.Frame_Array; E : Edge_Array;
      Bodies : in out Body_Array; Links : Attachment_Array; Shapes : Shape_Array;
      Applied : Input_Array; Applied_Bodies : Wrench_Array;
      Gravity : Input_Vector; Dt : Time_Step; Options : Settings;
      Particle_Contact : out Particle_Loads; Body_Contact : out Body_Loads;
      Info : out Report)
   is
      Candidate : Particle_Array := P;
      Candidate_Coordinates : MJ.Elastic_Coordinates.Frame_Array := Coordinates;
      Rigid : Body_Array := Bodies;
      Rot : Matrix_Array (Bodies'Range) := [others => [others => [others => 0.0]]];
      Inverse, Velocity, Smooth, Accel, Constraint_Load : Spatial_Array (1 .. P'Length+Bodies'Length)
        := [others => [others => 0.0]];
      Spring : Force_Array (P'Range);
      Caps : Capsule_Array (E'Range) := [others => (Zero, Zero, Zero, 0.0)];
      Capacity : constant Contact_Count := Info.Capacity;
      Constraints : Rows (1 .. Capacity);
      Network_Result : MJ.Elastic_Network.Status;
      PC : Particle_Loads (P'Range) := [others => Zero];
      BC : Body_Loads (Bodies'Range) := [others => (Zero, Zero)];
      Failed : Boolean := False;

      function Entity (I : Count) return Positive is
        (if Links (I).Body_Number = 0 then I else P'Length+Links (I).Body_Number);
      function World (Point : Input_Vector; B : Body_Id) return Vector is
        (if B = 0 then V (Point) else Add (V (Rigid (B).Position), Rotate (Rot (B), V (Point))));
      function Same_Body (I, J : Vertex) return Boolean is
        (I = J or else (Links (I).Body_Number /= 0
                       and then Links (I).Body_Number = Links (J).Body_Number));
      procedure Sync is
         X, U, Arm : Vector;
         B : Body_Id;
      begin
         for I in P'Range loop
            B := Links (I).Body_Number;
            if B /= 0 then
               Arm := Rotate (Rot (B), V (Links (I).Local_Point));
               X := Add (V (Rigid (B).Position), Arm);
               U := (if Rigid (B).Fixed then Zero else
                 Add (V (Rigid (B).Velocity),
                      Cross (Rotate (Rot (B), V (Rigid (B).Omega)), Arm)));
               if not Bounded (X, 1.0e10) or else not Bounded (U, 1.0e10) then
                  Failed := True; return;
               end if;
               Candidate (I).Position := Input (X); Candidate (I).Velocity := Input (U);
               --  Spring forces on attachments must reach their owner body.
               Candidate (I).Pinned := False;
            end if;
         end loop;
      end Sync;
      procedure Add_Load (Into : in out Spatial_Array; Id : Positive;
                          Force, Point : Vector) is
         Angular : Vector := Zero;
      begin
         if Id > P'Length then
            Angular := Rotate (Rot (Id-P'Length),
              Cross (Sub (Point, V (Rigid (Id-P'Length).Position)), Force), True);
         end if;
         for K in Axis loop
            Into (Id) (K) := Into (Id) (K)+Force (K);
            Into (Id) (K+3) := Into (Id) (K+3)+Angular (K);
         end loop;
      end Add_Load;
      function Weights (I, J : Vertex; Point : Vector) return Vector is
         A : constant Real := Weighted_Inverse (Norm (Sub (V (Candidate (I).Position), Point)));
         B : constant Real := Weighted_Inverse (Norm (Sub (V (Candidate (J).Position), Point)));
         Recip : constant Real := 1.0/(A+B);
      begin return [A*Recip, B*Recip, 0.0]; end Weights;
      procedure Add_Term (C : in out Row; Id : Positive;
                          Direction, Point : Vector; Weight : Real) is
         L : constant Vector := Scale (Direction, Weight);
         A : Vector := Zero;
         Slot : Natural := 0;
      begin
         if Id > P'Length then
            A := Rotate (Rot (Id-P'Length),
              Cross (Sub (Point, V (Rigid (Id-P'Length).Position)), L), True);
         end if;
         for K in 1 .. C.N loop
            if C.T (K).Entity = Id then Slot := K; exit; end if;
         end loop;
         if Slot = 0 then
            C.N := C.N+1; Slot := C.N; C.T (Slot).Entity := Id;
         end if;
         for K in Axis loop
            C.T (Slot).J (K) := C.T (Slot).J (K)+L (K);
            C.T (Slot).J (K+3) := C.T (Slot).J (K+3)+A (K);
         end loop;
         --  C efc_diagApprox uses LINEAR vertex weights; actual JMJ uses squares.
         C.Approx := C.Approx+abs (Weight)*Inverse (Id) (0);
      end Add_Term;
      procedure Add_Edge (C : in out Row; Edge_Id : Count;
                          Point, Direction : Vector; Sign : Real) is
         W : constant Vector := Weights (E (Edge_Id).A, E (Edge_Id).B, Point);
      begin
         Add_Term (C, Entity (E (Edge_Id).A), Direction, Point, Sign*W (0));
         Add_Term (C, Entity (E (Edge_Id).B), Direction, Point, Sign*W (1));
      end Add_Edge;
      function Row_Dot (C : Row; Values : Spatial_Array) return Real is
         Sum : Real := 0.0;
      begin
         for T in 1 .. C.N loop
            for K in Dof loop
               Sum := Sum+C.T (T).J (K)*Values (C.T (T).Entity) (K);
            end loop;
         end loop;
         return Sum;
      end Row_Dot;
      procedure Insert (Point, Normal : Vector; Distance : Real;
                        Left, Right : Count; Geom : Natural; PV : Count := 0) is
         C : Row;
         Imp, Ref_Vel : Real;
      begin
         if Failed or else Info.Result = Contact_Capacity then return; end if;
         if Left /= 0 then Add_Edge (C, Left, Point, Normal, -1.0); end if;
         if Geom /= 0 and then Shapes (Geom).Body_Number /= 0 then
            Add_Term (C, P'Length+Shapes (Geom).Body_Number, Normal, Point, -1.0);
         end if;
         if Right /= 0 then Add_Edge (C, Right, Point, Normal, 1.0); end if;
         if PV /= 0 then Add_Term (C, Entity (PV), Normal, Point, 1.0); end if;
         for T in 1 .. C.N loop
            for K in Dof loop
               C.Diagonal := C.Diagonal+(C.T (T).J (K)*Inverse (C.T (T).Entity) (K))*C.T (T).J (K);
            end loop;
         end loop;
         if Info.Count = Info.Capacity then Info.Result := Contact_Capacity; return; end if;
         --  Keep inactive geometric contacts through group filtering, as C does.
         --  Otherwise fixed vertices change the selection among moving ones.
         if C.Diagonal > 0.0 and then Distance < 0.0 then
            Imp := MJ.Contact_Rows.Impedance (Options.Contact, Distance, 0.0);
            Ref_Vel := Row_Dot (C, Velocity);
            if Imp not in MJ.Contact_Rows.Checked_Impedance
              or else C.Approx not in Inverse_Sum
              or else Ref_Vel not in Tier0_Real then Failed := True; return; end if;
            C.R := Regularizer (Imp, C.Approx);
            C.Reference := MJ.Contact_Rows.Reference
              (MJ.Contact_Rows.Stiffness (Options.Contact, Dt),
               MJ.Contact_Rows.Damping (Options.Contact, Dt), Imp, Distance, 0.0, Ref_Vel);
            C.Diagonal := C.Diagonal+C.R;
            if C.Diagonal not in Positive_Scalar then Failed := True; return; end if;
            C.Active := True;
         end if;
         Info.Count := Info.Count+1;
         Constraints (Info.Count) := C;
         Info.Contacts (Info.Count) := (Point, Normal, Distance, 0.0, Left, Right, Geom, PV);
      end Insert;
      procedure Spheres (A, B : Vector; R1, R2 : Real; Axis1, Axis2 : Vector;
                         Left, Right : Count; Geom : Natural) is
         D : constant Vector := Sub (B, A);
         D2 : constant Real := Dot (D, D);
         Distance : Real;
         N, Point : Vector;
      begin
         if D2 > (R1+R2)*(R1+R2) then return; end if;
         Distance := Sqrt (D2)-R1-R2;
         N := (if Sqrt (D2) < Min_Val then Unit (Cross (Axis1, Axis2)) else Unit (D));
         Point := Add (A, Scale (N, R1+Distance/2.0));
         Insert (Point, N, Distance, Left, Right, Geom);
      end Spheres;
      procedure Capsules (A, B : Capsule_Data; Left, Right : Count; Geom : Natural) is
         Dif : constant Vector := Sub (A.Center, B.Center);
         MA : constant Real := Dot (A.Half_Axis, A.Half_Axis);
         MB : constant Real := -Dot (A.Half_Axis, B.Half_Axis);
         MC : constant Real := Dot (B.Half_Axis, B.Half_Axis);
         U : constant Real := -Dot (A.Half_Axis, Dif);
         W : constant Real := Dot (B.Half_Axis, Dif);
         Det : constant Real := MA*MC-MB*MB;
         X1, X2 : Real;
         Before : constant Contact_Count := Info.Count;
         procedure Emit (T1, T2 : Real) is
         begin
            Spheres (Add (A.Center, Scale (A.Half_Axis, T1)),
                     Add (B.Center, Scale (B.Half_Axis, T2)), A.Radius, B.Radius,
                     A.Axis_Unit, B.Axis_Unit, Left, Right, Geom);
         end Emit;
      begin
         --  Defined point fallback for collapsed edges (C divides by zero here).
         if MA < Min_Val*Min_Val then
            Emit (0.0, (if MC < Min_Val*Min_Val then 0.0 else Clip (W/MC)));
         elsif MC < Min_Val*Min_Val then Emit (Clip (U/MA), 0.0);
         elsif abs (Det) >= Min_Val then
            X1 := (MC*U-MB*W)/Det; X2 := (MA*W-MB*U)/Det;
            if X1 > 1.0 then X1 := 1.0; X2 := (W-MB)/MC;
            elsif X1 < -1.0 then X1 := -1.0; X2 := (W+MB)/MC; end if;
            if X2 > 1.0 then X2 := 1.0; X1 := Clip ((U-MB)/MA);
            elsif X2 < -1.0 then X2 := -1.0; X1 := Clip ((U+MB)/MA); end if;
            Emit (X1, X2);
         else
            Emit (1.0, Clip ((W-MB)/MC)); Emit (-1.0, Clip ((W+MB)/MC));
            if Info.Count-Before >= 2 then return; end if;
            Emit (Clip ((U-MB)/MA), 1.0);
            if Info.Count-Before >= 2 then return; end if;
            Emit (Clip ((U+MB)/MA), -1.0);
         end if;
      end Capsules;
      procedure Filter_Group (Before : Contact_Count) is
         --  MuJoCo 3.14.0 engine_collision_driver.c::filterFlexContacts.
         --  Preserve its in-place swaps and tie-breaking, including the last
         --  unswapped slot; changing these changes which forces are solved.
         Last : constant Contact_Count := Info.Count;
         Selected : array (Positive range Before+1 .. Last) of Boolean := [others => False];
         Min_Distance : array (Positive range Before+1 .. Last) of Real := [others => 1.0e10];
         Best, Next_Best : Natural;
         Best_Distance, D2 : Real;
         Temp_Info : Contact_Info;
         Temp_Row : Row;
      begin
         if Info.Count-Before <= 50 then return; end if;
         Best := Before+1;
         Best_Distance := -Info.Contacts (Best).Distance;
         for I in Before+2 .. Info.Count loop
            if -Info.Contacts (I).Distance > Best_Distance then
               Best := I; Best_Distance := -Info.Contacts (I).Distance;
            end if;
         end loop;
         for Chosen in Before+1 .. Before+50 loop
            Selected (Best) := True;
            Next_Best := 0; Best_Distance := -1.0;
            for I in Before+1 .. Info.Count loop
               if not Selected (I) then
                  D2 := Dot (Sub (Info.Contacts (I).Point, Info.Contacts (Best).Point),
                             Sub (Info.Contacts (I).Point, Info.Contacts (Best).Point));
                  Min_Distance (I) := Real'Min (Min_Distance (I), D2);
                  if Min_Distance (I) > Best_Distance then
                     Best_Distance := Min_Distance (I); Next_Best := I;
                  end if;
               end if;
            end loop;
            if Chosen < Before+50 then
               Temp_Info := Info.Contacts (Chosen); Info.Contacts (Chosen) := Info.Contacts (Best);
               Info.Contacts (Best) := Temp_Info;
               Temp_Row := Constraints (Chosen); Constraints (Chosen) := Constraints (Best);
               Constraints (Best) := Temp_Row;
               if Next_Best = Chosen then Next_Best := Best; end if;
            end if;
            Best := Next_Best;
         end loop;
         Info.Count := Before+50;
      end Filter_Group;
      procedure Response (C : Row; Delta_Force : Real) is
         Id : Positive;
      begin
         for T in 1 .. C.N loop
            Id := C.T (T).Entity;
            for K in Dof loop
               Accel (Id) (K) := Accel (Id) (K)+(C.T (T).J (K)*Delta_Force)*Inverse (Id) (K);
               if Accel (Id) (K) not in Scalar then Failed := True; end if;
            end loop;
         end loop;
      end Response;
      procedure Rebuild_Response is
      begin
         Accel := Smooth;
         for C in 1 .. Info.Count loop Response (Constraints (C), Constraints (C).Force); end loop;
      end Rebuild_Response;
      function Correction (C : Row) return Real is
         Residual : constant Real := (Row_Dot (C, Accel)+C.R*C.Force)-C.Reference;
      begin
         if Residual not in Scalar then return 1.0e100; end if;
         return Project (C.Force, Residual, C.Diagonal)-C.Force;
      end Correction;
   begin
      Particle_Contact := [others => Zero]; Body_Contact := [others => (Zero, Zero)];
      Info := (Capacity => Info.Capacity, others => <>);
      if not MJ.Elastic_Network.Valid (P, E) or else Bodies'First /= 1
        or else Coordinates'First /= P'First or else Coordinates'Last /= P'Last
        or else Links'First /= P'First or else Links'Last /= P'Last
        or else Applied'First /= P'First or else Applied'Last /= P'Last
        or else Applied_Bodies'First /= Bodies'First or else Applied_Bodies'Last /= Bodies'Last
        or else Shapes'First /= 1 or else Shapes'Length > 4_096 then return; end if;
      for L of Links loop
         if L.Body_Number /= 0 and then L.Body_Number not in Bodies'Range then return; end if;
      end loop;
      for I in P'Range loop
         if Links (I).Body_Number = 0 then
            for K in Axis loop
               if P (I).Position (K) /= MJ.Elastic_Coordinates.World
                 (Coordinates (I).Origin (K), Coordinates (I).Offset (K)) then return; end if;
            end loop;
         end if;
      end loop;
      for B of Rigid loop
         declare
            Q : constant Quaternion := B.Orientation;
            L2 : constant Real := ((Q (0)*Q (0)+Q (1)*Q (1))+Q (2)*Q (2))+Q (3)*Q (3);
         begin
            if L2 not in 1.0-1.0e-12 .. 1.0+1.0e-12 then return; end if;
         end;
      end loop;
      for S of Shapes loop
         if (S.Body_Number /= 0 and then S.Body_Number not in Bodies'Range)
           or else (S.Kind = Plane and then S.Body_Number /= 0)
           or else (S.Kind /= Sphere and then Norm (V (S.Direction)) < Min_Val)
         then return; end if;
      end loop;
      Info.Result := Numeric_Limit;
      for B in Rigid'Range loop Rot (B) := Rotation (Rigid (B).Orientation); end loop;
      Sync; if Failed then return; end if;
      MJ.Elastic_Network.Forces (Candidate, E, Spring, Network_Result);
      if Network_Result /= MJ.Elastic_Network.Success then return; end if;
      for I in P'Range loop
         if Links (I).Body_Number = 0 and then not P (I).Pinned then
            for K in Axis loop
               Inverse (I) (K) := 1.0/P (I).Mass;
               Velocity (I) (K) := P (I).Velocity (K);
            end loop;
         end if;
         Add_Load (Smooth, Entity (I), Add (Add (Spring (I).Spring, Spring (I).Damper),
                   V (Applied (I))), V (Candidate (I).Position));
      end loop;
      for B in Rigid'Range loop
         declare
            Id : constant Positive := P'Length+B;
            IW : Vector;
            Torque : Vector := Rotate (Rot (B), V (Applied_Bodies (B).Torque), True);
         begin
            for K in Axis loop IW (K) := Rigid (B).Inertia (K)*Rigid (B).Omega (K); end loop;
            Torque := Sub (Torque, Cross (V (Rigid (B).Omega), IW));
            for K in Axis loop
               Smooth (Id) (K) := Smooth (Id) (K)+Applied_Bodies (B).Force (K);
               Smooth (Id) (K+3) := Smooth (Id) (K+3)+Torque (K);
               if not Rigid (B).Fixed then
                  Inverse (Id) (K) := 1.0/Rigid (B).Mass;
                  Inverse (Id) (K+3) := 1.0/Rigid (B).Inertia (K);
                  Velocity (Id) (K) := Rigid (B).Velocity (K);
                  Velocity (Id) (K+3) := Rigid (B).Omega (K);
               end if;
            end loop;
         end;
      end loop;
      for Id in Smooth'Range loop
         for K in Dof loop
            Smooth (Id) (K) := Smooth (Id) (K)*Inverse (Id) (K);
            if K in Axis and then Inverse (Id) (K) /= 0.0 then
               Smooth (Id) (K) := Smooth (Id) (K)+Gravity (K);
            end if;
            if Smooth (Id) (K) not in Scalar then return; end if;
         end loop;
      end loop;
      for I in E'Range loop
         declare
            A : constant Vector := V (Candidate (E (I).A).Position);
            B : constant Vector := V (Candidate (E (I).B).Position);
         begin
            Caps (I) := (Scale (Add (A, B), 0.5), Scale (Sub (A, B), 0.5), Unit (Sub (A, B)), Options.Radius);
         end;
      end loop;
      --  AABB rejection precedes the exact C capsule narrow phase.
      if Options.Self_Collision then
         for I in E'Range loop
            for J in I+1 .. E'Last loop
               if not Same_Body (E (I).A, E (J).A) and then not Same_Body (E (I).A, E (J).B)
                 and then not Same_Body (E (I).B, E (J).A) and then not Same_Body (E (I).B, E (J).B)
               then
                  declare
                     Overlap : Boolean := True;
                  begin
                     for K in Axis loop
                        if abs (Caps (I).Center (K)-Caps (J).Center (K)) >
                          abs (Caps (I).Half_Axis (K))+abs (Caps (J).Half_Axis (K))+2.0*Options.Radius
                        then Overlap := False; end if;
                     end loop;
                     if Overlap then Capsules (Caps (I), Caps (J), I, J, 0); end if;
                  end;
               end if;
            end loop;
         end loop;
         Filter_Group (0);
      end if;
      for G in Shapes'Range loop
         declare
            S : constant Shape := Shapes (G);
            Center : constant Vector := World (S.Center, S.Body_Number);
            Direction : constant Vector := (if S.Body_Number = 0 then Unit (V (S.Direction))
              else Rotate (Rot (S.Body_Number), Unit (V (S.Direction))));
            C : constant Capsule_Data := (Center,
              Scale (Direction, (if S.Kind = Sphere then 0.0 else S.Half_Length)), Direction, S.Radius);
            Before : constant Contact_Count := Info.Count;
         begin
            if S.Kind = Plane then
               for I in P'Range loop
                  declare
                     Dist : constant Real := Dot (Sub (V (Candidate (I).Position), Center), Direction)-Options.Radius;
                  begin
                     if Dist <= 0.0 then
                        Insert (Sub (V (Candidate (I).Position), Scale (Direction, Options.Radius+Dist/2.0)),
                                Direction, Dist, 0, 0, G, I);
                     end if;
                  end;
               end loop;
            else
               for I in E'Range loop
                  if S.Body_Number = 0 or else
                    (S.Body_Number /= Links (E (I).A).Body_Number and then
                     S.Body_Number /= Links (E (I).B).Body_Number)
                  then Capsules (C, Caps (I), 0, I, G); end if;
               end loop;
            end if;
            if not Failed and then Info.Result /= Contact_Capacity then Filter_Group (Before); end if;
         end;
      end loop;
      if Failed or else Info.Result = Contact_Capacity then return; end if;
      declare Kept : Contact_Count := 0; begin
         for I in 1 .. Info.Count loop
            if Constraints (I).Active then
               Kept := Kept+1;
               Constraints (Kept) := Constraints (I); Info.Contacts (Kept) := Info.Contacts (I);
            end if;
         end loop;
         Info.Count := Kept;
      end;
      Accel := Smooth;
      if Info.Count > 0 then
         for Sweep in 1 .. Options.Iterations loop
            for C in 1 .. Info.Count loop
               declare D : constant Real := Correction (Constraints (C)); begin
                  if D not in Scalar or else Constraints (C).Force+D not in 0.0 .. 1.0e80 then return; end if;
                  Constraints (C).Force := Constraints (C).Force+D;
                  Response (Constraints (C), D);
                  if Failed then return; end if;
               end;
            end loop;
            --  Recompute from forces to bound drift of incremental updates.
            Rebuild_Response; if Failed then return; end if;
            Info.Residual := 0.0;
            declare Scale_Force : Real := 1.0; begin
               for C in 1 .. Info.Count loop
                  Info.Residual := Real'Max (Info.Residual, abs (Correction (Constraints (C))));
                  Scale_Force := Real'Max (Scale_Force, Constraints (C).Force);
               end loop;
               Info.Residual := Info.Residual/Scale_Force;
            end;
            Info.Iterations := Sweep;
            exit when Info.Residual <= Options.Tolerance;
         end loop;
         if Info.Residual > Options.Tolerance then Info.Result := Iteration_Limit; return; end if;
      end if;
      for C in 1 .. Info.Count loop
         Info.Contacts (C).Force := Constraints (C).Force;
         for T in 1 .. Constraints (C).N loop
            declare Id : constant Positive := Constraints (C).T (T).Entity; begin
               for K in Dof loop
                  Constraint_Load (Id) (K) := Scatter
                    (Constraint_Load (Id) (K), Constraints (C).T (T).J (K), Constraints (C).Force);
               end loop;
            end;
         end loop;
      end loop;
      for I in P'Range loop
         PC (I) := [Constraint_Load (I) (0), Constraint_Load (I) (1), Constraint_Load (I) (2)];
         if Links (I).Body_Number = 0 and then not P (I).Pinned then
            for K in Axis loop
               declare
                  Accepted : Boolean;
               begin
                  MJ.Elastic_Coordinates.Integrate
                    (Candidate (I).Position (K), Candidate (I).Velocity (K),
                     Coordinates (I).Origin (K), Candidate_Coordinates (I).Offset (K),
                     Accel (I) (K), Dt, Accepted);
                  if not Accepted then return; end if;
               end;
            end loop;
         end if;
      end loop;
      for B in Rigid'Range loop
         declare Id : constant Positive := P'Length+B; begin
            BC (B).Force := [Constraint_Load (Id) (0), Constraint_Load (Id) (1), Constraint_Load (Id) (2)];
            BC (B).Torque := Rotate (Rot (B), [Constraint_Load (Id) (3), Constraint_Load (Id) (4), Constraint_Load (Id) (5)]);
            if not Rigid (B).Fixed then
               for K in Axis loop
                  declare
                     U : constant Real := Rigid (B).Velocity (K)+Dt*Accel (Id) (K);
                     W : constant Real := Rigid (B).Omega (K)+Dt*Accel (Id) (K+3);
                     X : constant Real := Rigid (B).Position (K)+Dt*U;
                  begin
                     if U not in Tier0_Real or else W not in Tier0_Real or else X not in Tier0_Real then return; end if;
                     Rigid (B).Velocity (K) := U; Rigid (B).Omega (K) := W; Rigid (B).Position (K) := X;
                  end;
               end loop;
               Rigid (B).Orientation := Advance (Rigid (B).Orientation, V (Rigid (B).Omega), Dt);
               Rot (B) := Rotation (Rigid (B).Orientation);
            end if;
         end;
      end loop;
      Sync; if Failed then return; end if;
      for I in P'Range loop Candidate (I).Pinned := P (I).Pinned; end loop;
      P := Candidate; Coordinates := Candidate_Coordinates;
      Bodies := Rigid; Particle_Contact := PC; Body_Contact := BC;
      Info.Result := Success;
   end Step;
end MJ.Elastic_Contacts;

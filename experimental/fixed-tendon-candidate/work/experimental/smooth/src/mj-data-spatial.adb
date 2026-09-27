with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;
with MJ.Smooth_Topology;

package body MJ.Data.Spatial with SPARK_Mode is
   package SK renames MJ.Spatial_Kernels;
   package SS renames MJ.Spatial_Storage;
   package T renames MJ.Smooth_Topology;
   use type SK.Motion;
   type Vector_Array is array (Natural range <>) of Vector;

   procedure Add_Moment (Target : in out Vector; Source : Vector; Ok : out Boolean)
     with Global => null,
     Pre => Bounded (Target, 1.0e24) and then Bounded (Source, 1.0e24),
     Post => Bounded (Target, 1.0e24)
       and then Ok = Bounded (Target'Old + Source, 1.0e24)
       and then Target = (if Ok then Target'Old + Source else Target'Old)
   is
      Sum : constant Vector := Target + Source;
   begin
      Ok := Bounded (Sum, 1.0e24);
      if Ok then Target := Sum; end if;
   end Add_Moment;
   pragma Inline_Always (Add_Moment);

   procedure Root_Center
     (Mass : Real; Moment, Body_Center : Vector; Value : out Vector; Ok : out Boolean)
     with Global => null,
     Pre => Mass in 0.0 .. 1.0e14 and then Bounded (Moment, 1.0e24)
       and then Bounded (Body_Center, Max_Val),
     Post => Bounded (Value, 1.0e40)
       and then Ok = Bounded (Value, Max_Val)
       and then Value = (if Mass < Min_Val then Body_Center else (1.0 / Mass) * Moment)
   is
   begin
      Value := (if Mass < Min_Val then Body_Center else (1.0 / Mass) * Moment);
      Ok := Bounded (Value, Max_Val);
   end Root_Center;
   pragma Inline_Always (Root_Center);

   procedure Set_Moment
     (Target : in out Vector_Array; Index : Natural; Mass : Nonneg_Tier0; Position : Vector)
     with Global => null,
     Pre => Index in Target'Range
       and then (for all K in Target'Range => Bounded (Target (K), 1.0e24))
       and then Bounded (Position, Max_Val),
     Post => (for all K in Target'Range => Bounded (Target (K), 1.0e24))
       and then Target (Index) = SK.Mass_Moment (Mass, Position)
       and then (for all K in Target'Range =>
         (if K /= Index then Target (K) = Target'Old (K)))
   is
   begin
      Target (Index) := SK.Mass_Moment (Mass, Position);
   end Set_Moment;
   pragma Inline_Always (Set_Moment);

   procedure Build_Centers
     (Config : Body_Parameter_Array; Poses : Body_State_Array;
      Topology : T.Cache; Center : out Vector_Array; Ok : out Boolean)
     with Global => null,
     Pre => Config'First = 0 and then Config'Length in 1 .. Max_Bodies
       and then Poses'First = 0 and then Poses'Last = Config'Last
       and then Center'First = 0 and then Center'Last = Config'Last
       and then Int64 (T.Body_Count (Topology)) = Int64 (Config'Length)
       and then (for all B in 1 .. Config'Last => Config (B).Parent < B),
     Post => (for all K in Center'Range => Bounded (Center (K), Max_Val))
       and then Center (0) = Zero
       and then (if Ok then (for all B in 1 .. Config'Last => Bounded (Poses (B).Center, Max_Val)))
   is
      Moment : Vector_Array (Config'Range) := [others => Zero];
   begin
      Ok := False;
      Center := [others => Zero];
      for B in 1 .. Config'Last loop
         if not Bounded (Poses (B).Center, Max_Val) then return; end if;
         Set_Moment (Moment, B, Config (B).Mass, Poses (B).Center);
         pragma Loop_Invariant (for all K in Moment'Range => Bounded (Moment (K), 1.0e24));
         pragma Loop_Invariant (for all K in 1 .. B => Bounded (Poses (K).Center, Max_Val));
      end loop;
      for B in reverse 1 .. Config'Last loop
         pragma Loop_Invariant (for all K in Moment'Range => Bounded (Moment (K), 1.0e24));
         declare
            P : constant Natural := Config (B).Parent;
            Accepted : Boolean;
            Child : constant Vector := Moment (B);
         begin
            if P > 0 then
               Add_Moment (Moment (P), Child, Accepted);
               if not Accepted then return; end if;
            end if;
         end;
      end loop;
      for B in 1 .. Config'Last loop
         pragma Loop_Invariant (for all K in Center'Range => Bounded (Center (K), Max_Val));
         if T.Root (Topology, B) = B then
            declare
               Mass : constant Real := T.Subtree_Mass (Topology, B);
               Value : Vector;
               Accepted : Boolean;
            begin
               Root_Center (Mass, Moment (B), Poses (B).Center, Value, Accepted);
               if not Accepted then return; end if;
               Center (B) := Value;
            end;
         end if;
      end loop;
      Ok := True;
   end Build_Centers;
   pragma Inline_Always (Build_Centers);

   procedure Expose_Motion_Direction (Poses : Joint_State_Array; Index : Natural)
     with Ghost => Static, Global => null,
     Pre => Index in Poses'Range
       and then (for all P of Poses => Bounded (P.Direction, 2.0)),
     Post => Bounded (Poses (Index).Direction, 2.0)
   is
   begin
      null;
   end Expose_Motion_Direction;

   procedure Write_Joint_Motion
     (Target : in out Real_Array; Base : Natural; Origin : Vector;
      Pose : Joint_State; Hinge : Boolean; Ok : out Boolean)
     with Global => null,
     Pre => Target'Length >= 6 and then Base >= Target'First
       and then Base <= Target'Last - 5
       and then Bounded (Origin, Max_Val) and then Bounded (Pose.Direction, 2.0),
     Post => Ok = Bounded (Pose.Anchor, Max_Val)
       and then (if Ok then
         (for all I in Base .. Base + 5 => Target (I) in -1.0e12 .. 1.0e12)
         and then (for all I in SK.Motion'Range => Target (Base + I) = SK.Joint_Motion
           (Pose.Direction, SK.Frame_Offset (Origin, Pose.Anchor), Hinge) (I))
         else Target = Target'Old)
       and then (for all I in Target'Range =>
         (if I < Base or else I > Base + 5 then Target (I) = Target'Old (I)))
       and then (for all I in Target'Range =>
         (if Target'Old (I) in -1.0e12 .. 1.0e12 then Target (I) in -1.0e12 .. 1.0e12))
   is
   begin
      Ok := Bounded (Pose.Anchor, Max_Val);
      if Ok then
         SS.Store_Motion (Target, Base, SK.Joint_Motion
           (Pose.Direction, SK.Frame_Offset (Origin, Pose.Anchor), Hinge));
      end if;
   end Write_Joint_Motion;
   pragma Inline_Always (Write_Joint_Motion);

   procedure Build_Body_Motions
     (Joints : Joint_Parameter_Array; Poses : Joint_State_Array;
      First : Natural; Count : Positive; Origin : Vector;
      Target : in out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Poses'First = Joints'First and then Poses'Last = Joints'Last
       and then Count <= Joints'Length and then First <= Joints'Length - Count
       and then Target'First = 0 and then Target'Last = 6 * Joints'Length - 1
       and then Bounded (Origin, Max_Val)
       and then (for all P of Poses => Bounded (P.Direction, 2.0)),
     Post => Ok = (for all J in First .. First + Count - 1 => Bounded (Poses (J).Anchor, Max_Val))
       and then (if Ok then
         (for all I in 6 * First .. 6 * (First + Count) - 1 => Target (I) in -1.0e12 .. 1.0e12)
         and then (for all J in First .. First + Count - 1 =>
           (for all I in SK.Motion'Range => Target (6 * J + I) = SK.Joint_Motion
             (Poses (J).Direction, SK.Frame_Offset (Origin, Poses (J).Anchor), Joints (J).Kind = Hinge_Joint) (I))))
       and then (for all I in Target'Range =>
         (if I < 6 * First or else I >= 6 * (First + Count) then Target (I) = Target'Old (I)))
       and then (for all I in Target'Range =>
         (if Target'Old (I) in -1.0e12 .. 1.0e12 then Target (I) in -1.0e12 .. 1.0e12))
   is
      Accepted : Boolean;
   begin
      Ok := False;
      for J in First .. First + Count - 1 loop
         Expose_Motion_Direction (Poses, J);
         Write_Joint_Motion (Target, 6 * J, Origin, Poses (J), Joints (J).Kind = Hinge_Joint, Accepted);
         if not Accepted then return; end if;
         pragma Loop_Invariant (Static => (for all K in First .. J => Bounded (Poses (K).Anchor, Max_Val)));
         pragma Loop_Invariant (Static => (for all I in 6 * First .. 6 * (J + 1) - 1 =>
           Target (I) in -1.0e12 .. 1.0e12));
         pragma Loop_Invariant (Static => (for all K in First .. J =>
           (for all I in SK.Motion'Range => Target (6 * K + I) = SK.Joint_Motion
             (Poses (K).Direction, SK.Frame_Offset (Origin, Poses (K).Anchor), Joints (K).Kind = Hinge_Joint) (I))));
         pragma Loop_Invariant (Static => (for all I in Target'Range =>
           (if I < 6 * First or else I >= 6 * (J + 1) then Target (I) = Target'Loop_Entry (I))));
         pragma Loop_Invariant (Static => (for all I in Target'Range =>
           (if Target'Loop_Entry (I) in -1.0e12 .. 1.0e12 then Target (I) in -1.0e12 .. 1.0e12)));
      end loop;
      Ok := True;
   end Build_Body_Motions;
   pragma Inline_Always (Build_Body_Motions);

   procedure Prove_Motion_Coverage
     (Joints : Joint_Parameter_Array; Body_Id, First, Count : Natural;
      Before, After : Real_Array)
     with Ghost => Static, Global => null,
     Pre => Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Count <= Joints'Length and then First <= Joints'Length - Count
       and then Before'First = 0 and then Before'Last = 6 * Joints'Length - 1
       and then After'First = Before'First and then After'Last = Before'Last
       and then (for all J in Joints'Range =>
         (if Joints (J).Body_Id = Body_Id then J in First .. First + Count - 1))
       and then (for all I in Before'Range =>
         (if Joints (I / 6).Body_Id < Body_Id then Before (I) in -1.0e12 .. 1.0e12))
       and then (for all I in After'Range =>
         (if Before (I) in -1.0e12 .. 1.0e12 then After (I) in -1.0e12 .. 1.0e12))
       and then (for all I in 6 * First .. 6 * (First + Count) - 1 => After (I) in -1.0e12 .. 1.0e12),
     Post => (for all I in After'Range =>
       (if Joints (I / 6).Body_Id <= Body_Id then After (I) in -1.0e12 .. 1.0e12))
   is
   begin
      null;
   end Prove_Motion_Coverage;

   procedure Prove_Complete_Motions
     (Joints : Joint_Parameter_Array; Last_Body : Natural; Target : Real_Array)
     with Ghost => Static, Global => null,
     Pre => Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Target'First = 0 and then Target'Last = 6 * Joints'Length - 1
       and then (for all J of Joints => J.Body_Id <= Last_Body)
       and then (for all I in Target'Range =>
         (if Joints (I / 6).Body_Id <= Last_Body then Target (I) in -1.0e12 .. 1.0e12)),
     Post => (for all X of Target => X in -1.0e12 .. 1.0e12)
   is
   begin
      null;
   end Prove_Complete_Motions;

   procedure Prove_Empty_Joint_Case (Joints : Joint_Parameter_Array; Last_Body : Natural)
     with Ghost => Static, Global => null,
     Pre => Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then (for all J of Joints => J.Body_Id in 1 .. Last_Body),
     Post => (if Last_Body = 0 then Joints'Length = 0)
   is
   begin
      null;
   end Prove_Empty_Joint_Case;

   procedure Build_One_Body
     (C : Body_Parameters; Pose : Body_State; Body_Id : Positive;
      Joints : Joint_Parameter_Array; Joint_Poses : Joint_State_Array; Origin : Vector;
      Inertias, Motions : in out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Body_Id < Max_Bodies
       and then Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Joint_Poses'First = 0 and then Joint_Poses'Last = Joints'Last
       and then C.Joint_Count <= Joints'Length
       and then (if C.Joint_Count > 0 then C.First_Joint >= 0
         and then C.First_Joint <= Joints'Length - C.Joint_Count)
       and then Inertias'First = 0 and then Inertias'Last >= 10 * Body_Id + 9
       and then Motions'First = 0 and then Motions'Last = 6 * Joints'Length - 1
       and then Bounded (Pose.Center, Max_Val) and then Bounded (Origin, Max_Val)
       and then Bounded (Pose.Inertial_Rotation, 16.0) and then Bounded (C.Inertia, Max_Val)
       and then (for all P of Joint_Poses => Bounded (P.Direction, 2.0)),
     Post => (for all I in 10 * Body_Id .. 10 * Body_Id + 9 => Inertias (I) in -1.0e36 .. 1.0e36)
       and then (for all I in SK.Inertia'Range => Inertias (10 * Body_Id + I) = SK.Make_Inertia
         (Pose.Inertial_Rotation, C.Inertia, C.Mass, SK.Frame_Offset (Pose.Center, Origin)) (I))
       and then (for all I in Inertias'Range =>
         (if I < 10 * Body_Id or else I > 10 * Body_Id + 9 then Inertias (I) = Inertias'Old (I)))
       and then (for all I in Inertias'Range =>
         (if Inertias'Old (I) in -1.0e36 .. 1.0e36 then Inertias (I) in -1.0e36 .. 1.0e36))
       and then Ok = (if C.Joint_Count = 0 then True else
         (for all J in C.First_Joint .. C.First_Joint + C.Joint_Count - 1 =>
           Bounded (Joint_Poses (J).Anchor, Max_Val)))
       and then (if Ok and then C.Joint_Count > 0 then
         (for all I in 6 * C.First_Joint .. 6 * (C.First_Joint + C.Joint_Count) - 1 => Motions (I) in -1.0e12 .. 1.0e12)
         and then (for all J in C.First_Joint .. C.First_Joint + C.Joint_Count - 1 =>
           (for all I in SK.Motion'Range => Motions (6 * J + I) = SK.Joint_Motion
             (Joint_Poses (J).Direction, SK.Frame_Offset (Origin, Joint_Poses (J).Anchor), Joints (J).Kind = Hinge_Joint) (I))))
       and then (for all I in Motions'Range =>
         (if C.Joint_Count = 0 or else I < 6 * C.First_Joint or else I >= 6 * (C.First_Joint + C.Joint_Count)
          then Motions (I) = Motions'Old (I)))
       and then (for all I in Motions'Range =>
         (if Motions'Old (I) in -1.0e12 .. 1.0e12 then Motions (I) in -1.0e12 .. 1.0e12))
   is
   begin
      SS.Store_Inertia (Inertias, 10 * Body_Id, SK.Make_Inertia
        (Pose.Inertial_Rotation, C.Inertia, C.Mass, SK.Frame_Offset (Pose.Center, Origin)));
      if C.Joint_Count > 0 then
         Build_Body_Motions (Joints, Joint_Poses, C.First_Joint, C.Joint_Count, Origin, Motions, Ok);
      else
         Ok := True;
      end if;
   end Build_One_Body;
   pragma Inline_Always (Build_One_Body);

   procedure Build_Buffers
     (Config : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Topology : T.Cache; Center : Vector_Array;
      Inertias, Motions : in out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Config'First = 0 and then Config'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Poses'First = 0 and then Poses'Last = Config'Last
       and then Joint_Poses'First = 0 and then Joint_Poses'Last = Joints'Last
       and then Center'First = 0 and then Center'Last = Config'Last
       and then Int64 (T.Body_Count (Topology)) = Int64 (Config'Length)
       and then Inertias'First = 0 and then Inertias'Last = 10 * Config'Length - 1
       and then Motions'First = 0 and then Motions'Last = 6 * Joints'Length - 1
       and then (for all B in Center'Range => Bounded (Center (B), Max_Val))
       and then (for all B in 1 .. Config'Last =>
         Bounded (Poses (B).Center, Max_Val)
         and then Bounded (Poses (B).Inertial_Rotation, 16.0)
         and then Bounded (Config (B).Inertia, Max_Val)
         and then Config (B).Joint_Count <= Joints'Length
         and then (if Config (B).Joint_Count > 0 then Config (B).First_Joint >= 0
           and then Config (B).First_Joint <= Joints'Length - Config (B).Joint_Count))
       and then (for all P of Joint_Poses => Bounded (P.Direction, 2.0))
       and then (for all J in Joints'Range => Joints (J).Body_Id in 1 .. Config'Last
         and then Config (Joints (J).Body_Id).Joint_Count > 0
         and then J in Config (Joints (J).Body_Id).First_Joint ..
           Config (Joints (J).Body_Id).First_Joint + Config (Joints (J).Body_Id).Joint_Count - 1),
     Post => (if Ok then
       (for all X of Inertias => X in -1.0e36 .. 1.0e36)
       and then (for all X of Motions => X in -1.0e12 .. 1.0e12))
   is
      Accepted : Boolean;
      Before : Real_Array (0 .. 6 * Joints'Length - 1) with Ghost => Static;
   begin
      Prove_Empty_Joint_Case (Joints, Config'Last);
      Ok := False;
      SS.Store_Inertia (Inertias, 0, [others => 0.0]);
      pragma Assert (Static => (if Config'Last = 0 then
        (for all X of Inertias => X in -1.0e36 .. 1.0e36)));
      for B in 1 .. Config'Last loop
         Before := Motions;
         Build_One_Body (Config (B), Poses (B), B, Joints, Joint_Poses,
           Center (T.Root (Topology, B)), Inertias, Motions, Accepted);
         if not Accepted then return; end if;
         Prove_Motion_Coverage
           (Joints, B, (if Config (B).Joint_Count = 0 then 0 else Config (B).First_Joint),
            Config (B).Joint_Count, Before, Motions);
         pragma Loop_Invariant (Static => (for all I in 0 .. 10 * (B + 1) - 1 =>
           Inertias (I) in -1.0e36 .. 1.0e36));
         pragma Loop_Invariant (Static => (for all I in Motions'Range =>
           (if Joints (I / 6).Body_Id <= B then
             Motions (I) in -1.0e12 .. 1.0e12)));
      end loop;
      pragma Assert (Static => (for all X of Inertias => X in -1.0e36 .. 1.0e36));
      Prove_Complete_Motions (Joints, Config'Last, Motions);
      Ok := True;
   end Build_Buffers;
   pragma Inline_Always (Build_Buffers);

   procedure Expose_Stable_Ready (D : Simulation) with Ghost => Static,
     Global => null, Pre => Stable_Ready (D),
     Post => Storage_Ready (D) and then Configuration_Bounded (D)
       and then Configuration_Valid (D.Body_Config.all, D.Joint_Config.all,
         D.Actuator_Config.all, D.Nb, D.Nj, D.Na)
   is
   begin
      null;
   end Expose_Stable_Ready;

   procedure Establish_Stable_Ready (D : Simulation) with Ghost => Static,
     Global => null,
     Pre => Storage_Ready (D) and then Configuration_Bounded (D)
       and then Configuration_Valid (D.Body_Config.all, D.Joint_Config.all,
         D.Actuator_Config.all, D.Nb, D.Nj, D.Na),
     Post => Stable_Ready (D)
   is
   begin
      null;
   end Establish_Stable_Ready;

   procedure Expose_Spatial_Layout (D : Simulation)
     with Ghost => Static, Global => null, Pre => Storage_Ready (D),
     Post => D.Kinematic.Spatial_Inertias /= null
       and then D.Kinematic.Spatial_Inertias'First = 0
       and then D.Kinematic.Spatial_Inertias'Last = 10 * D.Nb - 1
       and then D.Kinematic.Spatial_Motions /= null
       and then D.Kinematic.Spatial_Motions'First = 0
       and then D.Kinematic.Spatial_Motions'Last = 6 * D.Nj - 1
   is
   begin
      null;
   end Expose_Spatial_Layout;

   procedure Expose_Spatial_Poses (K : Kinematic_Buffers)
     with Ghost => Static, Global => null, Pre => Poses_Bounded (K),
     Post => K.Bodies /= null and then K.Joints /= null
       and then (for all B of K.Bodies.all => Bounded (B.Inertial_Rotation, 16.0))
       and then (for all J of K.Joints.all => Bounded (J.Direction, 2.0))
   is
   begin
      null;
   end Expose_Spatial_Poses;

   procedure Establish_Spatial_Layout (D : Simulation)
     with Ghost => Static, Global => null,
     Pre => D.Kinematic.Spatial_Inertias /= null
       and then D.Kinematic.Spatial_Inertias'First = 0
       and then D.Kinematic.Spatial_Inertias'Last = 10 * D.Nb - 1
       and then D.Kinematic.Spatial_Motions /= null
       and then D.Kinematic.Spatial_Motions'First = 0
       and then D.Kinematic.Spatial_Motions'Last = 6 * D.Nj - 1,
     Post => Has_Real_Layout (D.Kinematic.Spatial_Inertias, 10 * D.Nb)
       and then Has_Real_Layout (D.Kinematic.Spatial_Motions, 6 * D.Nj)
   is
   begin
      null;
   end Establish_Spatial_Layout;

   procedure Prepare_Buffers
     (Config : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Topology : T.Cache; Inertias, Motions : in out Real_Array;
      Valid : in out Boolean; Ok : out Boolean)
     with Global => null,
     Pre => Config'First = 0 and then Config'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Poses'First = 0 and then Poses'Last = Config'Last
       and then Joint_Poses'First = 0 and then Joint_Poses'Last = Joints'Last
       and then Int64 (T.Body_Count (Topology)) = Int64 (Config'Length)
       and then Inertias'First = 0 and then Inertias'Last = 10 * Config'Length - 1
       and then Motions'First = 0 and then Motions'Last = 6 * Joints'Length - 1
       and then (for all B in 1 .. Config'Last => Config (B).Parent < B
         and then Bounded (Poses (B).Inertial_Rotation, 16.0)
         and then Bounded (Config (B).Inertia, Max_Val)
         and then Config (B).Joint_Count <= Joints'Length
         and then (if Config (B).Joint_Count > 0 then Config (B).First_Joint >= 0
           and then Config (B).First_Joint <= Joints'Length - Config (B).Joint_Count))
       and then (for all P of Joint_Poses => Bounded (P.Direction, 2.0))
       and then (for all J in Joints'Range => Joints (J).Body_Id in 1 .. Config'Last
         and then Config (Joints (J).Body_Id).Joint_Count > 0
         and then J in Config (Joints (J).Body_Id).First_Joint ..
           Config (Joints (J).Body_Id).First_Joint + Config (Joints (J).Body_Id).Joint_Count - 1)
       and then (if Valid then (for all X of Inertias => X in -1.0e36 .. 1.0e36)
         and then (for all X of Motions => X in -1.0e12 .. 1.0e12)),
     Post => Valid = Ok
       and then (if Ok then (for all X of Inertias => X in -1.0e36 .. 1.0e36)
         and then (for all X of Motions => X in -1.0e12 .. 1.0e12))
       and then (if Valid'Old then Ok and then Inertias = Inertias'Old
         and then Motions = Motions'Old)
   is
      Center : Vector_Array (Config'Range);
   begin
      if Valid then
         Ok := True;
      else
         Build_Centers (Config, Poses, Topology, Center, Ok);
         if Ok then
            Build_Buffers (Config, Joints, Poses, Joint_Poses, Topology,
              Center, Inertias, Motions, Ok);
            Valid := Ok;
         end if;
      end if;
   end Prepare_Buffers;

   procedure Prepare (D : in out Simulation; Ok : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
   begin
      Prepare_Buffers
        (D.Body_Config.all, D.Joint_Config.all,
         D.Kinematic.Bodies.all, D.Kinematic.Joints.all, D.Topology,
         D.Kinematic.Spatial_Inertias.all, D.Kinematic.Spatial_Motions.all,
         D.Cache.Spatial_Valid, Ok);
   end Prepare;
end MJ.Data.Spatial;

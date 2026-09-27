with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;
with MJ.Smooth_Topology;

package body MJ.Data.Spatial with SPARK_Mode is
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
   procedure Prepare (D : in out Simulation; Ok : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      package SK renames MJ.Spatial_Kernels;
      package SS renames MJ.Spatial_Storage;
      package T renames MJ.Smooth_Topology;
      Nb : constant Natural := D.Nb;
      type Vector_Array is array (Natural range <>) of Vector;
      Moment, Center : Vector_Array (0 .. Nb - 1) := [others => Zero];
   begin
      Ok := False;
      if D.Cache.Spatial_Valid then Ok := True; return; end if;
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (Stable_Ready (D));
         pragma Loop_Invariant (for all K in Moment'Range => Bounded (Moment (K), 1.0e24));
         if not Bounded (D.Kinematic.Bodies (B).Center, Max_Val) then return; end if;
         Moment (B) := SK.Mass_Moment (D.Body_Config (B).Mass, D.Kinematic.Bodies (B).Center);
      end loop;
      for B in reverse 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (Stable_Ready (D));
         pragma Loop_Invariant (for all K in Moment'Range => Bounded (Moment (K), 1.0e24));
         declare
            P : constant Natural := D.Body_Config (B).Parent;
            Sum : Vector;
         begin
            if P > 0 then
               Sum := Moment (P) + Moment (B);
               if not Bounded (Sum, 1.0e24) then return; end if;
               Moment (P) := Sum;
            end if;
         end;
      end loop;
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (Stable_Ready (D));
         pragma Loop_Invariant (for all K in Center'Range => Bounded (Center (K), Max_Val));
         if T.Root (D.Topology, B) = B then
            declare
               Mass : constant Real := T.Subtree_Mass (D.Topology, B);
               Value : constant Vector :=
                 (if Mass < Min_Val then D.Kinematic.Bodies (B).Center else (1.0 / Mass) * Moment (B));
            begin
               if not Bounded (Value, Max_Val) then return; end if;
               Center (B) := Value;
            end;
         end if;
      end loop;
      SS.Store_Inertia (D.Kinematic.Spatial_Inertias.all, 0, [others => 0.0]);
      for B in 1 .. D.Nb - 1 loop
         pragma Loop_Invariant (Stable_Ready (D));
         declare
            C : constant Body_Parameters := D.Body_Config (B);
            Origin : constant Vector := Center (T.Root (D.Topology, B));
            Offset : constant Vector := SK.Frame_Offset (D.Kinematic.Bodies (B).Center, Origin);
         begin
            SS.Store_Inertia (D.Kinematic.Spatial_Inertias.all, 10 * B, SK.Make_Inertia
              (D.Kinematic.Bodies (B).Inertial_Rotation, C.Inertia, C.Mass, Offset));
            for K in 0 .. C.Joint_Count - 1 loop
               pragma Loop_Invariant (Stable_Ready (D));
               declare
                  J : constant Natural := C.First_Joint + K;
                  Joint : constant Joint_Parameters := D.Joint_Config (J);
                  Pose : constant Joint_State := D.Kinematic.Joints (J);
               begin
                  if not Bounded (Pose.Anchor, Max_Val) then return; end if;
                  SS.Store_Motion (D.Kinematic.Spatial_Motions.all, 6 * J, SK.Joint_Motion
                    (Pose.Direction, SK.Frame_Offset (Origin, Pose.Anchor), Joint.Kind = Hinge_Joint));
               end;
            end loop;
         end;
      end loop;
      D.Cache.Spatial_Valid := True;
      Ok := True;
      pragma Assert (Static => Stable_Ready (D));
   end Prepare;
end MJ.Data.Spatial;
